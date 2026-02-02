import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:wb_quality/services/api_config_service.dart'; // NEW: Import API Service
import 'dart:convert';
import '../login.dart';
import 'quality_dashboard.dart';

// Asumsi 'datauser' diimpor dari '../login.dart' dan memiliki struktur List<Map<String, dynamic>>
// Anda perlu memastikan 'datauser' benar-benar dapat diakses di scope ini,
// atau gunakan 'widget.Username' jika data user lengkap tidak diperlukan.
// Saya akan menggunakan datauser[0]['name'] seperti kode Anda.

class EditDataQualityPL extends StatefulWidget {
  final List list;
  final int index;

  final String Username;

  const EditDataQualityPL({
    super.key,
    required this.list,
    required this.index,
    required this.Username,
  });

  @override
  State<EditDataQualityPL> createState() => _EditDataQualityPLState();
}

class _EditDataQualityPLState extends State<EditDataQualityPL> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController? controllerWBSID;
  TextEditingController? controllerVehicleNo;
  TextEditingController? controllerDriver;
  TextEditingController? controllerPartId;
  TextEditingController? controllerPartName;
  TextEditingController? controllerCustomerId;
  TextEditingController? controllerCustomerName;

  TextEditingController? controllerFFA;
  TextEditingController? controllerMoisture;
  TextEditingController? controllerKotoran;
  TextEditingController? controllerDobi;

  // Deklarasi nilai quality
  double ffaValue = 0;
  double moistureValue = 0;
  double kotoranValue = 0;
  double dobiValue = 0;

  // GlobalKey untuk menangkap Context Dialog Loading
  BuildContext? _loadingDialogContext;

  // =====================================================================
  // FUNGSI EDIT DATA (FIXED: API DINAMIS & ASYNC)
  // =====================================================================
  Future<void> _editDataQualityPLFunc() async {
    final baseUrl = await ApiConfigService.getBaseUrl();

    if (baseUrl.isEmpty) {
      _showResultDialog('❌ Gagal: Konfigurasi API belum diatur.', false);
      return;
    }

    var url = Uri.parse("${baseUrl}pl_editdata.php");

    // Datetime edit sortase
    DateTime now = DateTime.now();
    String editDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    try {
      final response = await http.post(
        url,
        body: {
          "wbsid": controllerWBSID!.text,
          "ffa": controllerFFA!.text,
          "moisture": controllerMoisture!.text,
          "kotoran": controllerKotoran!.text,
          "dobi": controllerDobi!.text,
          "updated_at": editDate,
          // Menggunakan datauser[0]['name'] sesuai kode asli Anda.
          "updated_by":
              datauser.isNotEmpty ? datauser[0]['name'] : widget.Username,
        },
      ).timeout(const Duration(seconds: 15)); // Tambahkan timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['status'] == 'success') {
          _showResultDialog('✅ Data berhasil diperbarui!', true);
        } else {
          _showResultDialog(
              '⚠️ Gagal memperbarui data: ${result['message']}', false);
        }
      } else {
        _showResultDialog(
            '❌ Gagal: Server error ${response.statusCode}', false);
      }
    } catch (e) {
      _showResultDialog(
          '❌ Gagal koneksi: Pastikan server berjalan. Error: $e', false);
    }
  }

  // =====================================================================
  // HELPER WIDGETS
  // =====================================================================

  void _showLoadingDialog() {
    // Pastikan hanya menampilkan satu dialog loading
    if (_loadingDialogContext != null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _loadingDialogContext = context; // Simpan context untuk menutup nanti
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _closeLoadingDialog() {
    if (_loadingDialogContext != null && mounted) {
      // Pastikan context masih valid sebelum pop
      Navigator.pop(_loadingDialogContext!);
      _loadingDialogContext = null;
    }
  }

  void _showResultDialog(String message, bool isSuccess) {
    // Tutup loading dialog jika masih terbuka
    _closeLoadingDialog();

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
                Navigator.pop(dialogContext); // Tutup dialog hasil
                if (isSuccess) {
                  // Kembali ke dashboard (atau halaman detail yang akan refresh)
                  Navigator.pop(context);
                  // Opsional: jika ingin kembali ke dashboard utama, gunakan
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => QualityDashboardPL()));
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

  // =====================================================================
  // INIT STATE
  // =====================================================================

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller
    controllerWBSID = TextEditingController(
      text: widget.list[widget.index]['wbsid'],
    );
    controllerVehicleNo = TextEditingController(
      text: widget.list[widget.index]['vehicleno'],
    );
    controllerDriver = TextEditingController(
      text: widget.list[widget.index]['driver'],
    );
    controllerPartId = TextEditingController(
      text: widget.list[widget.index]['partcode'],
    );
    controllerPartName = TextEditingController(
      text: widget.list[widget.index]['partname'],
    );
    controllerCustomerId = TextEditingController(
      text: widget.list[widget.index]['csid'],
    );
    controllerCustomerName = TextEditingController(
      text: widget.list[widget.index]['csname'],
    );

    controllerFFA = TextEditingController(
      text: widget.list[widget.index]['ffa'],
    );
    controllerMoisture = TextEditingController(
      text: widget.list[widget.index]['moisture'],
    );
    controllerKotoran = TextEditingController(
      text: widget.list[widget.index]['kotoran'],
    );
    controllerDobi = TextEditingController(
      text: widget.list[widget.index]['dobi'],
    );

    // Inisialisasi nilai double untuk perhitungan
    ffaValue = double.tryParse(widget.list[widget.index]['ffa'] ?? '0') ?? 0;
    moistureValue =
        double.tryParse(widget.list[widget.index]['moisture'] ?? '0') ?? 0;
    kotoranValue =
        double.tryParse(widget.list[widget.index]['kotoran'] ?? '0') ?? 0;
    dobiValue = double.tryParse(widget.list[widget.index]['dobi'] ?? '0') ?? 0;
  }

  // =====================================================================
  // BUILD METHOD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Data Quality PL",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Column(
                children: [
                  TextFormField(
                    enabled: false,
                    controller: controllerWBSID,
                    decoration: InputDecoration(
                      hintText: "Tiket Timbang",
                      labelText: "Tiket Timbang",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerVehicleNo,
                    decoration: InputDecoration(
                      hintText: "Plat Kendaraan",
                      labelText: "Plat Kendaraan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerDriver,
                    decoration: InputDecoration(
                      hintText: "Supir",
                      labelText: "Supir",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerPartId,
                    decoration: InputDecoration(
                      hintText: "Kode Komoditi",
                      labelText: "Kode Komoditi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerPartName,
                    decoration: InputDecoration(
                      hintText: "Nama Komoditi",
                      labelText: "Nama Komoditi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerCustomerId,
                    decoration: InputDecoration(
                      hintText: "Kode Customer",
                      labelText: "Kode Customer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerCustomerName,
                    decoration: InputDecoration(
                      hintText: "Nama Customer",
                      labelText: "Nama Customer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Kolom FFA
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => ffaValue = 0);
                                } else {
                                  setState(() =>
                                      ffaValue = double.tryParse(value) ?? 0);
                                }
                              },
                              controller: controllerFFA,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: "FFA",
                                labelText: "FFA",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),
                          // Kolom Moisture
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => moistureValue = 0);
                                } else {
                                  setState(() => moistureValue =
                                      double.tryParse(value) ?? 0);
                                }
                              },
                              controller: controllerMoisture,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: "Moisture",
                                labelText: "Moisture",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Card kedua untuk Kotoran dan Dobi
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Kolom Dirt (Kotoran)
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => kotoranValue = 0);
                                } else {
                                  setState(() => kotoranValue =
                                      double.tryParse(value) ?? 0);
                                }
                              },
                              controller: controllerKotoran,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: "Dirt",
                                labelText: "Dirt",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),
                          // Kolom Dobi
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => dobiValue = 0);
                                } else {
                                  setState(() =>
                                      dobiValue = double.tryParse(value) ?? 0);
                                }
                              },
                              controller: controllerDobi,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: "Dobi",
                                labelText: "Dobi",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Konfirmasi Edit'),
                        content: const Text(
                            "Apakah anda yakin mengedit data quality?"),
                        actions: <Widget>[
                          // Tombol Batal
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, 'Cancel'),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: const Text('Tidak',
                                style: TextStyle(color: Colors.white)),
                          ),
                          // Tombol Konfirmasi Edit
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // 1. Tutup dialog konfirmasi
                                Navigator.pop(dialogContext);

                                // 2. Tampilkan dialog loading
                                _showLoadingDialog();

                                // 3. Panggil fungsi edit (sudah async)
                                await _editDataQualityPLFunc();

                                // Note: Dialog loading dan result akan ditangani di dalam _editDataQualityPLFunc
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.green),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: const Text('Ya',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                          const Size(double.infinity, 50)),
                      backgroundColor: WidgetStateProperty.all(Colors.green),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    child: const Text("EDIT",
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
