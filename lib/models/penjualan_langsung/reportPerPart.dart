import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async'; // Untuk TimeoutException
import 'dart:io'; // Untuk SocketException

// ⚠️ Pastikan path import ini benar (sesuaikan jika nama project Anda berbeda)
import 'package:wb_quality/services/api_config_service.dart';

class ReportPerPartPL {
  ReportPerPartPL({
    required this.partCode,
    required this.partName,
    required this.rit,
    required this.netto,
  });

  final String partCode;
  final String partName;
  final String rit;
  final String netto;

  factory ReportPerPartPL.fromJson(Map<String, dynamic> json) =>
      ReportPerPartPL(
        // Tambahkan operator null-aware ?? '' untuk safety saat decoding
        partCode: json["partid"] ?? '',
        partName: json["partname"] ?? 'N/A',
        rit: json["rit"] ?? '0',
        netto: json["netto"] ?? '0',
      );

  // Properti 'get length => null;' dihapus
}

// =========================================================================
// PERUBAHAN FUNGSI ASYNC CALL
// =========================================================================

Future<List<ReportPerPartPL>> getReportPerPartPL() async {
  final String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 1. Ambil BASE URL secara dinamis dari penyimpanan
  final baseUrl = await ApiConfigService.getBaseUrl();

  if (baseUrl.isEmpty) {
    throw Exception('Konfigurasi API Belum Diatur. Mohon atur IP/Port server.');
  }

  // 2. Susun URL lengkap dengan endpoint spesifik
  // Endpoint: wb_quality/pl_getdataPerPart.php
  final url = Uri.parse('${baseUrl}pl_getdataPerPart.php');

  try {
    final response = await http.post(
      url,
      body: {'inputDate': dateStamp.toString()},
    );

    if (response.statusCode == 200) {
      // Pastikan body tidak kosong sebelum decode
      if (response.body.isEmpty || response.body.trim() == '[]') {
        return []; // Kembalikan list kosong jika tidak ada data
      }

      final List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => ReportPerPartPL.fromJson(data))
          .toList();
    } else {
      // Menangani status code non-200
      throw Exception(
          'Gagal mengambil data. Status code: ${response.statusCode}');
    }
  } on SocketException {
    // Menangani kegagalan koneksi (jaringan putus/IP salah)
    throw Exception(
        'Koneksi ke server gagal. Cek jaringan atau konfigurasi IP.');
  } on TimeoutException {
    // Menangani timeout koneksi
    throw Exception('Permintaan ke server timeout.');
  } catch (e) {
    // Menangani error umum (termasuk error decoding JSON)
    throw Exception('Terjadi kesalahan saat memproses data: $e');
  }
}
