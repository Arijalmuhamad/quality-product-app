import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wb_quality/services/api_config_service.dart';

class ReportTransaksiTT {
  final String truck_in;
  final String siap_quality;
  final String sudah_quality;
  final String truck_out;

  ReportTransaksiTT({
    required this.truck_in,
    required this.siap_quality,
    required this.sudah_quality,
    required this.truck_out,
  });

  factory ReportTransaksiTT.fromJson(Map<String, dynamic> json) =>
      ReportTransaksiTT(
        truck_in: json["truck_in"] ?? '0',
        siap_quality: json["siap_quality"] ?? '0',
        sudah_quality: json["sudah_quality"] ?? '0',
        truck_out: json["truck_out"] ?? '0',
      );
}

Future<List<ReportTransaksiTT>> getReportTransaksiTT() async {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 1. Ambil Base URL secara dinamis
  final baseUrl = await ApiConfigService.getBaseUrl();

  if (baseUrl.isEmpty) {
    throw Exception('Gagal: Konfigurasi Base API URL belum diatur.');
  }

  // 2. Gabungkan Base URL dengan Endpoint spesifik TK
  var url = Uri.parse("${baseUrl}tt_getdataReportTransaksi.php");

  try {
    final response = await http.post(
      url,
      body: {"inputDate": dateStamp.toString()},
    ).timeout(const Duration(seconds: 15)); // Tambahkan timeout

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse
          .map((data) => ReportTransaksiTT.fromJson(data))
          .toList();
    } else {
      throw Exception(
          'Gagal mengambil data. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception(
        'Gagal koneksi atau timeout saat mengambil data Transaksi TK. Error: $e');
  }
}
