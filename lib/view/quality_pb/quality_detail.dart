import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // Untuk TimeoutException
import 'dart:io'; // Untuk SocketException

// ⚠️ Pastikan path import ini benar dan konsisten dengan project Anda
import 'package:wb_quality/services/api_config_service.dart';
import 'quality_dashboard.dart'; // Import QualityDashboardPB
import 'quality_edit.dart'; // Import EditDataQualityPB
import '../login.dart'; // Import datauser

//ignore: must_be_immutable
class DetailQualityPB extends StatefulWidget {
  //ignore: must_be_immutable
  List list;
  int index;
  DetailQualityPB({super.key, required this.index, required this.list});

  @override
  State<DetailQualityPB> createState() => _DetailQualityPBState();
}

class _DetailQualityPBState extends State<DetailQualityPB> {
  // Fungsi DELETE dengan dynamic URL dan error handling
  Future<void> deleteDataQualityFunc() async {
    final wbsid = widget.list[widget.index]['wbsid'];

    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      throw Exception('Konfigurasi API Belum Diatur.');
    }

    var url = Uri.parse("${baseUrl}wb_quality/pb_deletedata.php");

    try {
      final response = await http.post(
        url,
        body: {"wbsid": wbsid},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Gagal menghubungi server. Status: ${response.statusCode}');
      }

      // Asumsi server merespons "success" untuk menandakan berhasil
      final responseBody = response.body;
      if (responseBody.contains("success")) {
        // Delete successful
      } else {
        throw Exception('Penghapusan gagal di server: $responseBody');
      }
    } on SocketException {
      throw Exception(
          'Koneksi ke server gagal. Cek jaringan atau konfigurasi IP.');
    } on TimeoutException {
      throw Exception('Permintaan data timeout saat menghapus data.');
    } catch (e) {
      // Handle other errors
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Quality PB"),
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),

              Text(
                "Tiket Timbang : ${widget.list[widget.index]['wbsid']}",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),

              SizedBox(height: 30),

              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Table(
                      // border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(150),
                        1: FixedColumnWidth(15),
                        2: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            Text("Plat Kendaraan"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['vehicleno']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Supir"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['driver']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Kode Komoditi"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['partcode']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Nama Komoditi"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['partname']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Kode Customer"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['csid']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Nama Customer"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['csname']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(""),
                            Container(width: 10, child: Text("")),
                            Text(""),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("FFA"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['ffa']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Moisture"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['moisture']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Dirt"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['kotoran']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("Dobi"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['dobi']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(""),
                            Container(width: 10, child: Text("")),
                            Text(""),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text("No Segel"),
                            Container(width: 10, child: Text(":")),
                            Text("${widget.list[widget.index]['nosegel']}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Tombol EDIT dan DELETE diaktifkan
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Tombol EDIT
                  ElevatedButton(
                    onPressed: () {
                      if (datauser != null && datauser.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EditDataQualityPB(
                              // Ganti dari EditDataQualityPL ke EditDataQualityPB
                              list: widget.list,
                              index: widget.index,
                              Username: datauser[0]['name'],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sesi pengguna tidak valid.')),
                        );
                      }
                    },
                    child: Text("EDIT"),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.green),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Tombol DELETE
                  ElevatedButton(
                    onPressed: () => showDialog<String>(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text('Konfirmasi Hapus'),
                        content: Text(
                            "Apakah anda yakin hapus data quality dengan tiket timbang ${widget.list[widget.index]['wbsid']} ?"),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: Text('Tidak'),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.green),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop(); // Tutup dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Menghapus data...')),
                              );
                              try {
                                await deleteDataQualityFunc();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Data berhasil dihapus!')),
                                );
                                // Navigasi ke dashboard pembelian
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        QualityDashboardPB(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Gagal hapus data: ${e.toString().replaceAll('Exception: ', '')}')),
                                );
                              }
                            },
                            child: Text('Ya'),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: Text("DELETE"),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.red),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
