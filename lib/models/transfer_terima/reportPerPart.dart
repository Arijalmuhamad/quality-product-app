import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// ⭐ PENTING: Import API Config Service
import 'package:wb_quality/services/api_config_service.dart';

class ReportPerPartTT {
  ReportPerPartTT({
    required this.partCode,
    required this.partName,
    required this.rit,
    required this.netto,
  });

  final String partCode;
  final String partName;
  final String rit;
  final String netto;

  factory ReportPerPartTT.fromJson(Map<String, dynamic> json) =>
      ReportPerPartTT(
        partCode: json["partid"] ?? '',
        partName: json["partname"] ?? '',
        rit: json["rit"] ?? '0',
        netto: json["netto"] ?? '0',
      );

  get length => null;
}

Future<List<ReportPerPartTT>> getReportPerPartTT() async {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final baseUrl = await ApiConfigService.getBaseUrl();

  if (baseUrl.isEmpty) {
    throw Exception('Gagal: Konfigurasi Base API URL belum diatur.');
  }

  var url = Uri.parse("${baseUrl}tt_getdataPerPart.php");

  try {
    final response = await http.post(
      url,
      body: {"inputDate": dateStamp.toString()},
    ).timeout(const Duration(seconds: 15)); // Tambahkan timeout

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      // Menggunakan ReportPerPartTK.fromJson(data) untuk mapping
      return jsonResponse
          .map((data) => ReportPerPartTT.fromJson(data))
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
