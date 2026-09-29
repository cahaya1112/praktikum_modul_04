import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({
    super.key,
    this.api,
  });

  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState
    extends State<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  late final AnnouncementApi _api =
      widget.api ?? AnnouncementApi();

  late Future<List<Announcement>> _futurePengumuman;

  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();

    _futurePengumuman = _api.ambilPengumuman();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  void _muatUlang() {
    setState(() {
      _futurePengumuman = _api.ambilPengumuman();
    });
  }

  void _bukaDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Pengumuman TRPL'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kategori.map((kategori) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(kategori),
                      selected: _kategoriTerpilih == kategori,
                      onSelected: (selected) {
                        setState(() {
                          _kategoriTerpilih = kategori;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _futurePengumuman,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
    ConnectionState.waiting) {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Memuat pengumuman dari server...'),
      ],
    ),
  );
}

                if (snapshot.hasError) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${snapshot.error}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

                final pengumuman =
                    snapshot.data ?? <Announcement>[];

                if (pengumuman.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.inbox_outlined,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Tidak ada pengumuman untuk kategori '
          '"$_kategoriTerpilih".',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

                final pengumumanTerfilter =
                    _kategoriTerpilih == 'Semua'
                        ? pengumuman
                        : pengumuman
                            .where(
                              (item) =>
                                  item.category ==
                                  _kategoriTerpilih,
                            )
                            .toList();

                if (pengumumanTerfilter.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.inbox_outlined,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Tidak ada pengumuman untuk kategori '
          '"$_kategoriTerpilih".',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

                return RefreshIndicator(
                  onRefresh: () async {
                    _muatUlang();
                    await _futurePengumuman;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pengumumanTerfilter.length,
                    itemBuilder: (context, index) {
                      final item = pengumumanTerfilter[index];

                      return AnnouncementCard(
                        announcement: item,
                        onTap: () => _bukaDetail(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}