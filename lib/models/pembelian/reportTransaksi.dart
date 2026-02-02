import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportTransaksiPB {
  final String truck_in;
  final String siap_quality;
  final String sudah_quality;
  final String truck_out;

  ReportTransaksiPB({
    required this.truck_in,
    required this.siap_quality,
    required this.sudah_quality,
    required this.truck_out,
  });

  factory ReportTransaksiPB.fromJson(Map<String, dynamic> json) =>
      ReportTransaksiPB(
        truck_in: json["truck_in"],
        siap_quality: json["siap_quality"],
        sudah_quality: json["sudah_quality"],
        truck_out: json["truck_out"],
      );
}

Future<List<ReportTransaksiPB>> getReportTransaksiPB() async {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  var url = Uri.parse(
    "http://172.16.29.11:46/wb_quality/pb_getdataReportTransaksi.php",
  );

  final response = await http.post(
    url,
    body: {"inputDate": dateStamp.toString()},
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse
        .map((data) => new ReportTransaksiPB.fromJson(data))
        .toList();
  } else {
    throw Exception('Gagal mengambil data');
  }
}
