import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wb_quality/services/api_config_service.dart';

// Class SiteInfo ini sudah BENAR
class SiteInfo {
  final String companyName;
  final String siteId;

  SiteInfo({required this.companyName, required this.siteId});

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    return SiteInfo(
      companyName:
          json["company_name"]?.toString() ?? 'Nama Pabrik Tidak Ditemukan',
      siteId: json["siteid"]?.toString() ?? 'SITE ID Tidak Ditemukan',
    );
  }
}

// ⚠️ KOREKSI UTAMA: Ubah return type menjadi Future<SiteInfo>
Future<SiteInfo> getCompanyName() async {
  final baseUrl = await ApiConfigService.getBaseUrl();

  if (baseUrl.isEmpty) {
    // ⚠️ KOREKSI: Kembalikan objek SiteInfo, bukan String
    return SiteInfo(
        companyName: 'Nama Pabrik (API Belum Diatur)', siteId: 'ID: ---');
  }

  final url = Uri.parse('${baseUrl}getdataCompanyName.php');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        // ⚠️ KOREKSI: Gunakan factory constructor untuk mengembalikan SiteInfo
        return SiteInfo.fromJson(jsonResponse[0]);
      }

      // Jika data kosong, lempar Exception (akan ditangkap di blok catch)
      throw Exception('Data Pabrik Tidak Ditemukan di server.');
    } else {
      // Jika status code bukan 200, lempar Exception
      throw Exception('Gagal Memuat Site Info (Code: ${response.statusCode})');
    }
  } on http.ClientException {
    // Jika koneksi gagal, lempar Exception
    throw Exception('Koneksi Gagal (Cek IP/Jaringan)');
  } catch (e) {
    // ⚠️ KOREKSI: Tangkap semua Exception dan kembalikan objek SiteInfo untuk menampilkan error di UI
    return SiteInfo(
        companyName: e.toString().replaceFirst('Exception: ', ''),
        siteId: 'ID: ERR');
  }
}
