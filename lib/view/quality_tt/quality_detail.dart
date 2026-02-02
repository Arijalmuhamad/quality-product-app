import 'package:flutter/material.dart';
import 'package:wb_quality/services/api_config_service.dart';
import 'package:http/http.dart' as http;

//ignore: must_be_immutable
class DetailQualityTT extends StatefulWidget {
  //ignore: must_be_immutable
  final List list;
  final int index;
  const DetailQualityTT({super.key, required this.index, required this.list});

  @override
  State<DetailQualityTT> createState() => _DetailQualityTTState();
}

class _DetailQualityTTState extends State<DetailQualityTT> {
  // =====================================================================
  // FUNGSI HAPUS DATA (API DINAMIS & ASYNC)
  // =====================================================================
  void deleteDataQualityFunc() async {
    final baseUrl = await ApiConfigService.getBaseUrl();

    if (baseUrl.isEmpty) {
      _showSnackBar('❌ Gagal: Konfigurasi API belum diatur.');
      return;
    }

    // Menggunakan base URL dinamis untuk endpoint TK
    var url = Uri.parse("${baseUrl}tt_deletedata.php");
    String wbsidToDelete = widget.list[widget.index]['wbsid'];

    try {
      // Tambahkan timeout untuk mencegah masalah "muter-muter"
      final response = await http.post(
        url,
        body: {"wbsid": wbsidToDelete},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Asumsi server mengembalikan 200 OK untuk sukses delete
        _showSuccessDialog(
            "Data Tiket Timbang $wbsidToDelete berhasil dihapus.", true);
      } else {
        _showSnackBar('❌ Gagal hapus. Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('❌ Gagal hapus. Error koneksi/timeout: $e');
    }
  }

  // =====================================================================
  // HELPER WIDGETS (Disalin dan disesuaikan dari versi PL)
  // =====================================================================

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.startsWith('❌') ? Colors.red : Colors.green,
        ),
      );
    }
  }

  void _showSuccessDialog(String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isSuccess ? "Sukses" : "Gagal"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog
                if (isSuccess) {
                  // Kembali ke halaman dashboard setelah sukses hapus
                  Navigator.pop(context);
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    isSuccess ? Colors.green : Colors.red),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)),
                ),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            "Apakah anda yakin ingin menghapus data Quality Transfer Kirim Tiket Timbang: ${widget.list[widget.index]['wbsid']}?"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'Tidak'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0)),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi
              deleteDataQualityFunc(); // Panggil fungsi hapus
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Quality Transfer Terima",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(
                "Tiket Timbang : ${widget.list[widget.index]['wbsid']}",
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
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
                        TableRow(
                          children: [
                            const Text("Segel Qty"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['segelqty']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Storage From"),
                            Container(width: 10, child: const Text(":")),
                            Text(
                                "${widget.list[widget.index]['storage_from']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Storage To"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['storage_to']}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: <Widget> [
              //     ElevatedButton(
              //       onPressed: ()=>Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (BuildContext context) => EditDataQualityTK(list:widget.list, index:widget.index, Username: datauser[0]['name'],),
              //           ),
              //         ),
              //       child: Text("EDIT"),
              //       style: ButtonStyle(
              //         backgroundColor: MaterialStateProperty.all(Colors.green),
              //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //           RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(18.0),
              //             side: BorderSide(color: Colors.green)
              //           )
              //         )
              //       )
              //     ),

              //     SizedBox(width: 10,),

              //     ElevatedButton(
              //           onPressed: () => showDialog<String>(
              //             barrierDismissible : false,
              //             context: context,
              //             builder: (BuildContext context) => AlertDialog(
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(20)
              //               ),
              //               title: Text('Konfirmasi Hapus'),
              //               content: Text("Apakah anda yakin hapus data quality dengan tiket timbang ${widget.list[widget.index]['wbsid']} ?"),
              //               actions: <Widget>[
              //                 ElevatedButton(
              //                   onPressed: () => Navigator.pop(context, 'Cancel'),
              //                   child: Text('Tidak'),
              //                     style: ButtonStyle(
              //                       backgroundColor: MaterialStateProperty.all(Colors.green),
              //                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //                         RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(18.0),
              //                           side: BorderSide(color: Colors.green)
              //                         )
              //                       )
              //                     )
              //                 ),
              //                 ElevatedButton(
              //                   onPressed: () async {
              //                     deleteDataQualityFunc();
              //                     Navigator.of(context).push(
              //                       new MaterialPageRoute(
              //                         builder: (BuildContext context) => QualityDashboardTK(),
              //                         ),
              //                       );
              //                   },
              //                   child: Text('Ya'),
              //                   style: ButtonStyle(
              //                       backgroundColor: MaterialStateProperty.all(Colors.red),
              //                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //                         RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(18.0),
              //                           side: BorderSide(color: Colors.red)
              //                         )
              //                       )
              //                     )
              //                 ),
              //               ],
              //             ),
              //           ),
              //         child: Text("DELETE"),
              //         style: ButtonStyle(
              //           backgroundColor: MaterialStateProperty.all(Colors.red),
              //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //             RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(18.0),
              //               side: BorderSide(color: Colors.red)
              //             )
              //           )
              //         )
              //       )

              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
