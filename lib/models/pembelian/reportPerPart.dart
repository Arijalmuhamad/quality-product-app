import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportPerPartPB {
  ReportPerPartPB({
    required this.partCode,
    required this.partName,
    required this.rit,
    required this.netto,
  });

  final String partCode;
  final String partName;
  final String rit;
  final String netto;

  factory ReportPerPartPB.fromJson(Map<String, dynamic> json) =>
      ReportPerPartPB(
        partCode: json["partid"],
        partName: json["partname"],
        rit: json["rit"],
        netto: json["netto"],
      );

  get length => null;
}

Future<List<ReportPerPartPB>> getReportPerPartPB() async {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  var url = Uri.parse(
    "http://172.16.29.11:46/wb_quality/pb_getdataPerPart.php",
  );

  final response = await http.post(
    url,
    body: {"inputDate": dateStamp.toString()},
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse
        .map((data) => new ReportPerPartPB.fromJson(data))
        .toList();
  } else {
    throw Exception('Gagal mengambil data');
  }
}
