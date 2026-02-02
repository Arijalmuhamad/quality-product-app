import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// ⭐ PENTING: Import API Config Service
import 'package:wb_quality/services/api_config_service.dart';

class ReportPerPartTK {
  ReportPerPartTK({
    required this.partCode,
    required this.partName,
    required this.rit,
    required this.netto,
  });

  final String partCode;
  final String partName;
  final String rit;
  final String netto;

  factory ReportPerPartTK.fromJson(Map<String, dynamic> json) =>
      ReportPerPartTK(
        partCode: json["partid"] ?? '',
        partName: json["partname"] ?? '',
        rit: json["rit"] ?? '0',
        netto: json["netto"] ?? '0',
      );

  get length => null;
}

// ⭐ FUNGSI GET DATA (API DINAMIS)
Future<List<ReportPerPartTK>> getReportPerPartTK() async {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 1. Ambil Base URL secara dinamis
  final baseUrl = await ApiConfigService.getBaseUrl();

  if (baseUrl.isEmpty) {
    throw Exception('Gagal: Konfigurasi Base API URL belum diatur.');
  }

  // 2. Gabungkan Base URL dengan Endpoint spesifik TK
  var url = Uri.parse("${baseUrl}tk_getdataPerPart.php");

  try {
    final response = await http.post(
      url,
      body: {"inputDate": dateStamp.toString()},
    ).timeout(const Duration(seconds: 15)); // Tambahkan timeout

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      // Menggunakan ReportPerPartTK.fromJson(data) untuk mapping
      return jsonResponse
          .map((data) => ReportPerPartTK.fromJson(data))
          .toList();
    } else {
      throw Exception(
          'Gagal mengambil data. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception(
        'Gagal koneksi atau timeout saat mengambil data per part TK. Error: $e');
  }
}
