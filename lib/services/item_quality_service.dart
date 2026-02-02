// File: services/quality_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Untuk TimeoutException

import '../models/quality_item_model.dart';
// Memastikan import dan nama kelas yang digunakan sudah benar
import 'package:wb_quality/services/api_config_service.dart';

class QualityService {
  // Fungsi untuk mengambil daftar item kualitas
  Future<List<QualityItem>> fetchQualityItems() async {
    // 1. Ambil Base URL (yang sudah mencakup IP, port, dan /wb_quality/)
    final baseUrl = await ApiConfigService.getBaseUrl();

    // Validasi jika Base URL belum diatur
    if (baseUrl.isEmpty) {
      throw Exception(
          'Alamat API belum diatur. Harap setel di Pengaturan API terlebih dahulu.');
    }

    // 2. Gabungkan Base URL dengan endpoint file PHP
    // Base URL dari getBaseUrl() dijamin diakhiri dengan '/' (misal: http://.../wb_quality/)
    const String endpoint = 'getdataItemQuality.php';
    final fullUrl = '$baseUrl$endpoint';

    final uri = Uri.parse(fullUrl);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Menggunakan utf8.decode untuk menangani karakter non-ASCII (misalnya, karakter bahasa Indonesia)
        final List<dynamic> jsonList =
            json.decode(utf8.decode(response.bodyBytes));

        return jsonList.map((json) => QualityItem.fromJson(json)).toList();
      } else {
        throw Exception(
            'Gagal memuat item kualitas. Status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception(
          'Gagal koneksi ke server. Mohon periksa jaringan atau IP server: $e');
    } on TimeoutException catch (_) {
      throw Exception('Permintaan ke server melebihi batas waktu (10 detik).');
    } catch (e) {
      // Menangkap Format Error, dll.
      throw Exception(
          'Terjadi kesalahan tak terduga saat mengambil data item kualitas: $e');
    }
  }
}
