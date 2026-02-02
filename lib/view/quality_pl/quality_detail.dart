import 'package:flutter/material.dart';
// Import yang diperlukan untuk API Service
import 'package:wb_quality/services/api_config_service.dart';
// import '../login.dart';
// import 'quality_dashboard.dart';
// import 'quality_edit.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DetailQualityPL extends StatefulWidget {
  //ignore: must_be_immutable
  final List list;
  final int index;
  const DetailQualityPL({super.key, required this.index, required this.list});

  @override
  State<DetailQualityPL> createState() => _DetailQualityPLState();
}

class _DetailQualityPLState extends State<DetailQualityPL> {
  // =====================================================================
  // FUNGSI HAPUS DATA (FIXED: API DINAMIS & ASYNC)
  // =====================================================================
  void deleteDataQualityFunc() async {
    final baseUrl = await ApiConfigService.getBaseUrl();

    if (baseUrl.isEmpty) {
      _showSnackBar('❌ Gagal: Konfigurasi API belum diatur.');
      return;
    }

    // Menggunakan base URL dinamis
    var url = Uri.parse("${baseUrl}pl_deletedata.php");
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
  // HELPER WIDGETS
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
                  // Ini akan memicu refresh di halaman sebelumnya
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
            "Apakah anda yakin ingin menghapus data Tiket Timbang: ${widget.list[widget.index]['wbsid']}?"),
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

  // =====================================================================
  // BUILD METHOD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Quality PL",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            // Panggil dialog konfirmasi hapus
            onPressed: _showDeleteConfirmationDialog,
          ),
          // Tombol Edit (jika Anda memiliki halaman edit)
          // IconButton(
          //   icon: const Icon(Icons.edit, color: Colors.white),
          //   onPressed: () {
          //     // Navigasi ke halaman edit
          //   },
          // ),
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
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Table(
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(150),
                        1: FixedColumnWidth(15),
                        2: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Text("Plat Kendaraan"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['vehicleno']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Supir"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['driver']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Kode Komoditi"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['partcode']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Nama Komoditi"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['partname']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Kode Customer"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['csid']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Nama Customer"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['csname']}"),
                          ],
                        ),
                        const TableRow(
                          children: [
                            Text(""),
                            SizedBox.shrink(),
                            Text(""),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("FFA"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['ffa']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Moisture"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['moisture']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Dirt"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['kotoran']}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Dobi"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['dobi']}"),
                          ],
                        ),
                        const TableRow(
                          children: [
                            Text(""),
                            SizedBox.shrink(),
                            Text(""),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("No Segel"),
                            Container(width: 10, child: const Text(":")),
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
                            const Text("Storage Code"),
                            Container(width: 10, child: const Text(":")),
                            Text("${widget.list[widget.index]['storagecode']}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
