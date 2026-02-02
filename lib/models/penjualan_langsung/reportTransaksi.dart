import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async'; // Untuk TimeoutException
import 'dart:io'; // Untuk SocketException

// ⚠️ Pastikan path import ini benar dan konsisten dengan project Anda
import 'package:wb_quality/services/api_config_service.dart';

class ReportTransaksiPL {
  final String truck_in;
  final String siap_quality;
  final String sudah_quality;
  final String truck_out;

  ReportTransaksiPL({
    required this.truck_in,
    required this.siap_quality,
    required this.sudah_quality,
    required this.truck_out,
  });

  factory ReportTransaksiPL.fromJson(Map<String, dynamic> json) =>
      ReportTransaksiPL(
        // Tambahkan operator null-aware ?? '' untuk safety
        truck_in: json["truck_in"] ?? '0',
        siap_quality: json["siap_quality"] ?? '0',
        sudah_quality: json["sudah_quality"] ?? '0',
        truck_out: json["truck_out"] ?? '0',
      );
}

// =========================================================================
// PERUBAHAN FUNGSI ASYNC CALL
// =========================================================================

Future<List<ReportTransaksiPL>> getReportTransaksiPL() async {
  final String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 1. Ambil BASE URL secara dinamis dari penyimpanan
  final baseUrl = await ApiConfigService.getBaseUrl();

  if (baseUrl.isEmpty) {
    throw Exception('Konfigurasi API Belum Diatur. Mohon atur IP/Port server.');
  }

  // 2. Susun URL lengkap dengan endpoint spesifik
  // Endpoint: wb_quality/pl_getdataReportTransaksi.php
  final url = Uri.parse('${baseUrl}pl_getdataReportTransaksi.php');

  try {
    final response = await http.post(
      url,
      body: {'inputDate': dateStamp.toString()},
    );

    if (response.statusCode == 200) {
      // Pastikan body tidak kosong atau hanya array kosong
      if (response.body.isEmpty || response.body.trim() == '[]') {
        return []; // Kembalikan list kosong jika tidak ada data
      }

      // Logika decoding yang lebih aman
      // print('Response body: ${response.body}'); // Opsional, untuk debugging
      final List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => ReportTransaksiPL.fromJson(data))
          .toList();
    } else {
      // Menangani status code non-200
      // print('Status code: ${response.statusCode}'); // Opsional, untuk debugging
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
    // Menangani error umum (termasuk error decoding JSON yang sudah Anda tambahkan)
    // print('JSON Decode error: $e'); // Opsional, untuk debugging
    throw Exception(
        'Terjadi kesalahan saat memproses data atau format data tidak sesuai: $e');
  }
}
