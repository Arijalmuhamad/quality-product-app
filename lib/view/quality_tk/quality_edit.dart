import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:wb_quality/services/api_config_service.dart'; // Import API Service

// PERHATIAN: Pastikan QualityDashboardTK ada di jalur 'quality_dashboard.dart'
// import '../login.dart';
import 'quality_dashboard.dart';

// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

class EditDataQualityTK extends StatefulWidget {
  final List list;
  final int index;
  final String Username; // Digunakan sebagai 'updated_by'

  // Tambahkan super.key
  const EditDataQualityTK({
    super.key,
    required this.list,
    required this.index,
    required this.Username,
  });

  @override
  State<EditDataQualityTK> createState() => _EditDataQualityTKState();
}

class _EditDataQualityTKState extends State<EditDataQualityTK> {
  final _formKey = GlobalKey<FormState>();

  // Menggunakan late final untuk inisialisasi di initState
  late final TextEditingController controllerWBSID;
  late final TextEditingController controllerVehicleNo;
  late final TextEditingController controllerDriver;
  late final TextEditingController controllerPartId;
  late final TextEditingController controllerPartName;
  late final TextEditingController controllerCustomerId;
  late final TextEditingController controllerCustomerName;

  late final TextEditingController controllerFFA;
  late final TextEditingController controllerMoisture;
  late final TextEditingController controllerKotoran;
  late final TextEditingController controllerDobi;

  // Deklarasi nilai quality (disimpan di sini, namun tidak wajib untuk fungsi ini)
  double ffaValue = 0;
  double moistureValue = 0;
  double kotoranValue = 0;
  double dobiValue = 0;

  // =====================================================================
  // HELPER FUNCTIONS (SnackBar & Dialog)
  // =====================================================================
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Sukses"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog
                // Navigasi kembali ke halaman sebelumnya (dashboard) setelah sukses
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
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
  // FUNGSI UTAMA EDIT DATA (ASYNC)
  // =====================================================================
  Future<void> EditDataQualityTKFunc() async {
    // Tampilkan loading sebelum proses API
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Dapatkan Base URL dinamis
    final baseUrl = await ApiConfigService.getBaseUrl();

    // Tutup loading
    if (mounted) Navigator.pop(context);

    if (baseUrl.isEmpty) {
      _showSnackBar('❌ Gagal: Konfigurasi API belum diatur.', isError: true);
      return;
    }

    // Tentukan endpoint
    var url = Uri.parse("${baseUrl}tk_editdata.php");

    // Datetime edit
    DateTime now = DateTime.now();
    String editDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    try {
      final response = await http.post(
        url,
        body: {
          "wbsid": controllerWBSID.text,
          "ffa": controllerFFA.text,
          "moisture": controllerMoisture.text,
          "kotoran": controllerKotoran.text,
          "dobi": controllerDobi.text,
          "updated_at": editDate,
          // Menggunakan widget.Username sebagai updated_by
          "updated_by": widget.Username,
        },
      ).timeout(const Duration(seconds: 15)); // Tambahkan timeout

      if (response.statusCode == 200) {
        // Asumsi server mengembalikan 200 OK
        _showSuccessDialog(
            "Data Tiket Timbang ${controllerWBSID.text} berhasil diperbarui.");
      } else {
        _showSnackBar('❌ Gagal: Server error ${response.statusCode}',
            isError: true);
      }
    } catch (e) {
      // Tangani error koneksi atau timeout
      _showSnackBar('❌ Gagal: Error koneksi/timeout: $e', isError: true);
    }
  }

  // =====================================================================
  // INIT STATE & DISPOSE
  // =====================================================================
  @override
  void initState() {
    super.initState();
    // Gunakan operator null-aware (??) untuk menangani nilai null/kosong
    controllerWBSID = TextEditingController(
      text: widget.list[widget.index]['wbsid'] ?? '',
    );
    controllerVehicleNo = TextEditingController(
      text: widget.list[widget.index]['vehicleno'] ?? '',
    );
    controllerDriver = TextEditingController(
      text: widget.list[widget.index]['driver'] ?? '',
    );
    controllerPartId = TextEditingController(
      text: widget.list[widget.index]['partcode'] ?? '',
    );
    controllerPartName = TextEditingController(
      text: widget.list[widget.index]['partname'] ?? '',
    );
    controllerCustomerId = TextEditingController(
      text: widget.list[widget.index]['csid'] ?? '',
    );
    controllerCustomerName = TextEditingController(
      text: widget.list[widget.index]['csname'] ?? '',
    );

    controllerFFA = TextEditingController(
      text: widget.list[widget.index]['ffa'] ?? '0.0',
    );
    controllerMoisture = TextEditingController(
      text: widget.list[widget.index]['moisture'] ?? '0.0',
    );
    controllerKotoran = TextEditingController(
      text: widget.list[widget.index]['kotoran'] ?? '0.0',
    );
    controllerDobi = TextEditingController(
      text: widget.list[widget.index]['dobi'] ?? '0.0',
    );

    // Inisialisasi nilai double
    ffaValue = double.tryParse(controllerFFA.text) ?? 0.0;
    moistureValue = double.tryParse(controllerMoisture.text) ?? 0.0;
    kotoranValue = double.tryParse(controllerKotoran.text) ?? 0.0;
    dobiValue = double.tryParse(controllerDobi.text) ?? 0.0;
  }

  @override
  void dispose() {
    // Bersihkan semua controller
    controllerWBSID.dispose();
    controllerVehicleNo.dispose();
    controllerDriver.dispose();
    controllerPartId.dispose();
    controllerPartName.dispose();
    controllerCustomerId.dispose();
    controllerCustomerName.dispose();
    controllerFFA.dispose();
    controllerMoisture.dispose();
    controllerKotoran.dispose();
    controllerDobi.dispose();
    super.dispose();
  }

  // =====================================================================
  // BUILD METHOD & WIDGETS
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Data Quality TK",
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
                  // --- READONLY FIELDS ---
                  _buildReadOnlyTextField(controllerWBSID, "Tiket Timbang"),
                  const SizedBox(height: 15),
                  _buildReadOnlyTextField(
                      controllerVehicleNo, "Plat Kendaraan"),
                  const SizedBox(height: 15),
                  _buildReadOnlyTextField(controllerDriver, "Supir"),
                  const SizedBox(height: 15),
                  _buildReadOnlyTextField(controllerPartId, "Kode Komoditi"),
                  const SizedBox(height: 15),
                  _buildReadOnlyTextField(controllerPartName, "Nama Komoditi"),
                  const SizedBox(height: 15),
                  _buildReadOnlyTextField(
                      controllerCustomerId, "Kode Customer"),
                  const SizedBox(height: 15),
                  _buildReadOnlyTextField(
                      controllerCustomerName, "Nama Customer"),
                  const SizedBox(height: 15),

                  // --- CARD INPUT NILAI QUALITY (FFA, Moisture, Dirt) ---
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQualityField(controllerFFA, "FFA"),
                          _buildQualityField(controllerMoisture, "Moisture"),
                          _buildQualityField(controllerKotoran, "Dirt"),
                        ],
                      ),
                    ),
                  ),

                  // --- CARD INPUT NILAI QUALITY (DOBI) ---
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQualityField(controllerDobi, "Dobi"),
                          // Tambahkan SizedBox.shrink() agar alignment Card sama
                          const SizedBox(width: 100),
                          const SizedBox(width: 100),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- TOMBOL EDIT ---
                  ElevatedButton(
                    onPressed: () {
                      // Validasi form sebelum menampilkan dialog
                      if (_formKey.currentState!.validate()) {
                        _showConfirmationDialog();
                      } else {
                        _showSnackBar('❌ Mohon lengkapi data yang wajib diisi.',
                            isError: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "EDIT DATA QUALITY",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk Text Field Read-Only
  Widget _buildReadOnlyTextField(
      TextEditingController controller, String label) {
    return TextFormField(
      enabled: false,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
    );
  }

  // Widget helper untuk Input Quality Field (FFA, Moisture, Dirt, Dobi)
  Widget _buildQualityField(TextEditingController controller, String label) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        style: const TextStyle(fontSize: 16),
        controller: controller,
        // Gunakan keyboardType untuk angka desimal
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // Hanya izinkan angka dan titik (maksimal 2 desimal setelah titik)
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(fontSize: 14),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Wajib';
          }
          if (double.tryParse(value) == null) {
            return 'Angka Invalid';
          }
          return null;
        },
      ),
    );
  }

  // Dialog Konfirmasi
  void _showConfirmationDialog() {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Konfirmasi Edit'),
        content: const Text(
          "Apakah anda yakin mengedit data quality?",
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi
              EditDataQualityTKFunc(); // Panggil fungsi async
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }
}
