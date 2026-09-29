import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/announcement.dart';

class AnnouncementApi {
  AnnouncementApi({
    http.Client? client,
    this.modeSimulasi = false,
  })  : _client = client ?? http.Client(),
        _milikSendiri = client == null;

  final http.Client _client;
  final bool _milikSendiri;
  final bool modeSimulasi;

  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  static const Duration batasWaktu = Duration(seconds: 10);

  static const List<String> daftarKategori = <String>[
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  Future<List<Announcement>> ambilPengumuman() async {
    if (modeSimulasi) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return Announcement.getSampleAnnouncements();
    }

    final http.Response response;

    try {
      response = await _client
          .get(
            Uri.parse('$baseUrl/posts?_limit=10'),
          )
          .timeout(batasWaktu);
    } on TimeoutException {
      throw Exception(
        'Koneksi ke server timeout. Periksa sambungan internet Anda.',
      );
    } on http.ClientException {
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi data atau Wi-Fi Anda.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Server merespons dengan status ${response.statusCode}.',
      );
    }

    final List<dynamic> baris =
        jsonDecode(response.body) as List<dynamic>;

    return baris
        .map(
          (item) => Announcement.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  void tutup() {
    if (_milikSendiri) {
      _client.close();
    }
  }
}