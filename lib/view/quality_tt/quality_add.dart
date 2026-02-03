import 'package:wb_quality/services/api_config_service.dart'; // <-- Base URL Dinamis
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../login.dart'; // Asumsi file ini mendefinisikan `datauser`

// ===================================================================
// DUMMY/HELPER CLASS STORAGE
// ===================================================================
class Storage {
  final String plant;
  final String storagecode;
  final String description;

  Storage(
      {required this.plant,
      required this.storagecode,
      required this.description});

  @override
  String toString() {
    return storagecode.isNotEmpty ? storagecode : '(Storage Kosong)';
  }
}

// KOREKSI NAMA KELAS: AddDataQualityTK
class AddDataQualityTT extends StatefulWidget {
  final String username;
  const AddDataQualityTT(this.username, {super.key});

  @override
  State<AddDataQualityTT> createState() => _AddDataQualityTTState();
}

class _AddDataQualityTTState extends State<AddDataQualityTT> {
  final _formKey = GlobalKey<FormState>();

  // =========================================================================
  // KONTROLER
  // =========================================================================
  final TextEditingController _controllerWBSID = TextEditingController();
  final TextEditingController _controllerVehicleNo = TextEditingController();
  final TextEditingController _controllerDriver = TextEditingController();
  final TextEditingController _controllerPartId = TextEditingController();
  final TextEditingController _controllerPartName = TextEditingController();
  final TextEditingController _controllerCustomerId = TextEditingController();
  final TextEditingController _controllerCustomerName = TextEditingController();
  final TextEditingController _controllerTransactionType =
      TextEditingController();

  // Item Quality
  final TextEditingController _controllerFFA = TextEditingController();
  final TextEditingController _controllerMoisture = TextEditingController();
  final TextEditingController _controllerKotoran = TextEditingController();
  final TextEditingController _controllerDobi = TextEditingController();

  // Item Segel
  final TextEditingController _controllerSegelQty = TextEditingController();
  final TextEditingController _controllerSegel = TextEditingController();

  // =========================================================================
  // STATE STORAGE
  // =========================================================================
  Storage? _selectedStorageFrom;
  String _selectedStorageFromCode = '';
  Storage? _selectedStorageTo;
  String _selectedStorageToCode = '';

  List<Storage> _storageList = [];
  bool _isLoadingStorage = true;

  // =========================================================================
  // STATE UMUM
  // =========================================================================

  bool _isTruckDataSelected = false;
  bool _isCheckedQuality = false;
  bool _isCheckedSegel = false;
  bool _isCheckedStorage = false;
  bool _isCheckedCamera = false;

  double _ffaValue = 0;
  double _moistureValue = 0;
  double _kotoranValue = 0;
  double _dobiValue = 0;

  String _segelQtyValue = '';
  String _segelValue = '';

  // Variabel tidak terpakai, bisa dihapus atau dipertahankan jika ada logika lain
  String _isQuality = 'F';
  String _isSegel = 'F';
  String _isCamera = 'F';
  String _isStorage = 'F';

  File? _image1;
  File? _image2;
  File? _image3;

  @override
  void initState() {
    super.initState();
    _fetchStorageData();
  }

  @override
  void dispose() {
    _controllerWBSID.dispose();
    _controllerVehicleNo.dispose();
    _controllerDriver.dispose();
    _controllerPartId.dispose();
    _controllerPartName.dispose();
    _controllerCustomerId.dispose();
    _controllerCustomerName.dispose();
    _controllerTransactionType.dispose();
    _controllerFFA.dispose();
    _controllerMoisture.dispose();
    _controllerKotoran.dispose();
    _controllerDobi.dispose();
    _controllerSegelQty.dispose();
    _controllerSegel.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI UTAMA UNTUK FETCH DATA STORAGE
  // =========================================================================
  Future<void> _fetchStorageData() async {
    setState(() {
      _isLoadingStorage = true;
    });

    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      if (mounted) {
        _showSnackBar(
            'Gagal memuat data storage. Konfigurasi API belum diatur.');
      }
      setState(() {
        _storageList = [];
        _isLoadingStorage = false;
      });
      return;
    }

    // Menggunakan Base URL Dinamis
    var url = Uri.parse("${baseUrl}getdataStorage.php");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim() == '[]') {
          debugPrint('Respons API Storage kosong atau tidak ada data.');
          setState(() {
            _storageList = [];
            _isLoadingStorage = false;
          });
          return;
        }

        List decodedBody = jsonDecode(response.body);
        List<Storage> tempList = [];

        for (var element in decodedBody) {
          tempList.add(Storage(
            plant: (element["PLANT"] ?? '').toString().trim(),
            storagecode: (element["STORAGECODE"] ?? '').toString().trim(),
            description: (element["DESCRIPTION"] ?? '').toString().trim(),
          ));
        }

        setState(() {
          _storageList = tempList;
          _isLoadingStorage = false;
        });
      } else {
        debugPrint('Gagal memuat data Storage. Status: ${response.statusCode}');
        setState(() {
          _isLoadingStorage = false;
        });
      }
    } on TimeoutException {
      if (mounted) _showSnackBar('Time out: Gagal memuat data storage.');
      setState(() => _isLoadingStorage = false);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat data storage. Periksa koneksi/URL.');
      }
      setState(() {
        _isLoadingStorage = false;
      });
    }
  }

  // =========================================================================
  // FUNGSI UTAMA UNTUK SIMPAN DATA QUALITY (DIPERBARUI DENGAN ASYNC & HANDLING)
  // =========================================================================
  Future<bool> _addDataQualityTTFunc() async {
    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      if (mounted) {
        _showSnackBar('❌ Konfigurasi API belum diatur.');
      }
      return false;
    }

    // KOREKSI ENDPOINT: tk_adddata.php
    var url = Uri.parse("${baseUrl}tt_adddata.php");

    DateTime now = DateTime.now();
    String inputDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    try {
      final Map<String, String> body = {
        "wbsid": _controllerWBSID.text,
        "vehicleno": _controllerVehicleNo.text,
        "driver": _controllerDriver.text,
        "partcode": _controllerPartId.text,
        "partname": _controllerPartName.text,
        "csid": _controllerCustomerId.text,
        "csname": _controllerCustomerName.text,
        "TransactionType": _controllerTransactionType.text,
        "ffa": _controllerFFA.text,
        "moisture": _controllerMoisture.text,
        "kotoran": _controllerKotoran.text,
        "dobi": _controllerDobi.text,
        "segelqty": _controllerSegelQty.text,
        "nosegel": _controllerSegel.text,
        "storagecode_from": _selectedStorageFromCode,
        "storagecode_to": _selectedStorageToCode,
        // Gunakan nilai dari checkbox untuk kepastian, meskipun tidak terpakai di PHP
        // "isQuality": _isCheckedQuality ? 'T' : 'F',
        // "isSegel": _isCheckedSegel ? 'T' : 'F',
        // "isCamera": _isCheckedCamera ? 'T' : 'F',
        // "isStorage": _isCheckedStorage ? 'T' : 'F',
        "created_by": (datauser.isNotEmpty && datauser[0].containsKey('name'))
            ? datauser[0]['name'] ?? 'UNKNOWN'
            : 'UNKNOWN',
        "created_at": inputDate,
      };

      // Kirim request DENGAN TIMEOUT 15 DETIK
      final response = await http.post(url, body: body).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request to server timed out (15 seconds).');
        },
      );

      debugPrint('RESPONSE BODY:\n${response.body}');

      if (mounted) {
        if (response.statusCode == 200) {
          // Asumsi API PHP mengembalikan "1" untuk sukses
          if (response.body.trim() == "1") {
            return true;
          }

          // Penanganan JSON jika API mengembalikan respons JSON
          try {
            final data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              return true;
            } else {
              _showSnackBar("❌ Gagal simpan: ${data['message']}");
              return false;
            }
          } catch (e) {
            // Error Parsing atau Response Body Kosong/Invalid selain "1"
            if (response.body.isEmpty || response.body.trim().isEmpty) {
              // Asumsi sukses jika body kosong
              return true;
            }
            _showSnackBar(
                "❌ Gagal parsing respons server. Pesan: ${response.body}");
            return false;
          }
        } else {
          _showSnackBar("❌ HTTP error: ${response.statusCode}");
          return false;
        }
      }
    } on TimeoutException {
      _showSnackBar(
          '❌ Gagal menyimpan. Koneksi ke server habis waktu (Timeout 15 detik).');
      return false;
    } on SocketException {
      _showSnackBar('❌ Gagal menyimpan. Periksa koneksi internet/URL API.');
      return false;
    } catch (e) {
      _showSnackBar('❌ Terjadi error: $e');
      return false;
    }
    return false;
  }

  void _showSuccessDialogAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Sukses"),
          content: const Text("Data berhasil disimpan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog sukses
                // KOREKSI RUTE: Ganti ke rute TK
                Navigator.pushReplacementNamed(context, '/QualityDashboardTT');
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

  void _resetTruckData() {
    // ... logic reset ...
    setState(() {
      _controllerVehicleNo.clear();
      _controllerWBSID.clear();
      _controllerDriver.clear();
      _controllerPartId.clear();
      _controllerPartName.clear();
      _controllerCustomerId.clear();
      _controllerCustomerName.clear();
      _controllerTransactionType.clear();

      _isTruckDataSelected = false;
      _selectedStorageFrom = null;
      _selectedStorageFromCode = '';
      _selectedStorageTo = null;
      _selectedStorageToCode = '';
      _isCheckedQuality = false;
      _isCheckedSegel = false;
      _isCheckedStorage = false;
      _isCheckedCamera = false;

      _image1 = null;
      _image2 = null;
      _image3 = null;
    });
    _clearQuality();
    _clearSegel();
  }

  void _clearQuality() {
    if (!_isCheckedQuality) {
      _controllerFFA.clear();
      _controllerMoisture.clear();
      _controllerKotoran.clear();
      _controllerDobi.clear();
      setState(() {
        _ffaValue = 0;
        _moistureValue = 0;
        _kotoranValue = 0;
        _dobiValue = 0;
      });
    }
  }

  void _clearSegel() {
    if (!_isCheckedSegel) {
      _controllerSegelQty.clear();
      _controllerSegel.clear();

      setState(() {
        _segelQtyValue = '';
        _segelValue = '';
      });
    }
  }

  // =========================================================================
  // FUNGSI UPLOAD GAMBAR
  // =========================================================================
  Future<void> _getImage(int index) async {
    // Validasi WBSID
    if (_controllerWBSID.text.isEmpty) {
      _showSnackBar('Pilih Plat Kendaraan terlebih dahulu untuk WBSID.');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );

    if (imagePicked == null) return;

    File imageFile = File(imagePicked.path);
    setState(() {
      if (index == 1) {
        _image1 = imageFile;
      } else if (index == 2) {
        _image2 = imageFile;
      } else if (index == 3) {
        _image3 = imageFile;
      }
    });

    // Ambil Base URL
    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      _showSnackBar('Konfigurasi API belum diatur. Gagal upload gambar.');
      return;
    }

    // Upload image
    var uri = "${baseUrl}uploadimage.php"; // Menggunakan dynamic Base URL
    var request = http.MultipartRequest('POST', Uri.parse(uri));
    var pic = await http.MultipartFile.fromPath(
      'image',
      imagePicked.path,
      filename: "${_controllerWBSID.text}-$index.jpg",
    );

    request.files.add(pic);

    // Penanganan Await response dan tambahkan handling
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Asumsi sukses jika status 200, atau tambahkan cek body jika perlu
        _showSnackBar("Foto $index berhasil diunggah.");
      } else {
        final respStr = await response.stream.bytesToString();
        debugPrint('Upload Error Body: $respStr');
        _showSnackBar(
            "Gagal mengunggah foto $index. Status: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Gagal mengunggah foto $index. Error: $e");
    }
  }

  // =========================================================================
  // WIDGET BUILDER
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/logo-kpn-1.png', width: 30),
            const SizedBox(width: 10),
            const Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tambah Data Quality TT",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        leading: const BackButton(color: Colors.black),
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              Column(
                children: [
                  // Dropdown Plat Kendaraan
                  DropdownSearch<Map<String, dynamic>>(
                    popupProps: const PopupProps.menu(
                      showSelectedItems: false,
                      showSearchBox: true,
                    ),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        floatingLabelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        labelText: "Plat Kendaraan",
                        hintText: "Silahkan pilih plat kendaraan",
                      ),
                    ),
                    clearButtonProps: const ClearButtonProps(
                      icon: Icon(Icons.clear),
                      isVisible: false,
                      iconSize: 25,
                    ),

                    // Teks yang ditampilkan di dropdown
                    itemAsString: (item) {
                      return "${item['vehicleno']} - ${item['driver']}";
                    },

                    onChanged: (selectedItem) async {
                      if (selectedItem == null) {
                        _resetTruckData();
                        return;
                      }

                      final String vehicleNoOnly =
                          selectedItem['vehicleno'] ?? '';
                      _controllerVehicleNo.text = vehicleNoOnly;

                      final baseUrl = await ApiConfigService.getBaseUrl();
                      if (baseUrl.isEmpty) {
                        _showSnackBar('Konfigurasi API belum diatur.');
                        _resetTruckData();
                        return;
                      }

                      // KOREKSI ENDPOINT: tk_getdataTruckDesc.php
                      var url = Uri.parse(
                        "${baseUrl}tt_getdataTruckDesc.php",
                      );

                      try {
                        final response = await http.post(
                          url,
                          body: {"vehicleno": vehicleNoOnly},
                        );

                        if (response.statusCode == 200) {
                          List tandan = jsonDecode(response.body);

                          if (tandan.isNotEmpty &&
                              tandan[0] is Map<String, dynamic>) {
                            Map<String, dynamic> data = tandan[0];

                            // Menggunakan operator null-aware ?? '' untuk keamanan
                            setState(() {
                              _controllerWBSID.text =
                                  (data["wbsid"] ?? '').toString();
                              _controllerDriver.text =
                                  (data["driver"] ?? '').toString();
                              _controllerPartId.text =
                                  (data["partid"] ?? '').toString();
                              _controllerPartName.text =
                                  (data["partname"] ?? '').toString();
                              _controllerCustomerId.text =
                                  (data["csid"] ?? '').toString();
                              _controllerCustomerName.text =
                                  (data["csname"] ?? '').toString();
                              _controllerTransactionType.text =
                                  (data["TransactionType"] ?? '').toString();
                              _isTruckDataSelected = true;
                            });
                          } else {
                            debugPrint(
                                "Error: Truck description not found or invalid data format.");
                            _resetTruckData();
                          }
                        } else {
                          debugPrint(
                              'Gagal memuat data Truck. Status: ${response.statusCode}');
                          _resetTruckData();
                        }
                      } catch (e) {
                        debugPrint(
                            "Error during JSON decoding or data update: $e");
                        _resetTruckData();
                      }
                    },
                    asyncItems: (text) async {
                      final baseUrl = await ApiConfigService.getBaseUrl();
                      if (baseUrl.isEmpty) {
                        if (mounted)
                          _showSnackBar(
                              'Konfigurasi API belum diatur. Gagal memuat daftar truk.');
                        return [];
                      }

                      DateTime now1 = DateTime.now();
                      String inputDate1 = DateFormat('yyyy-MM-dd').format(now1);

                      // KOREKSI ENDPOINT: tk_getdataTruck.php
                      var url = Uri.parse("${baseUrl}tt_getdataTruck.php");

                      final response = await http.post(
                        url,
                        body: {"inputDate": inputDate1.toString()},
                      );

                      if (response.statusCode != 200 || response.body.isEmpty) {
                        return [];
                      }

                      List data = jsonDecode(response.body);

                      // Return data yang berisi vehicleno + driver
                      return data.map<Map<String, dynamic>>((item) {
                        return {
                          "vehicleno": item["vehicleno"],
                          "driver": item["driver"],
                        };
                      }).toList();
                    },
                  ),
                  const SizedBox(height: 25),

                  // Tampilkan field deskripsi truk
                  _controllerVehicleNo.text.isEmpty
                      ? Container()
                      : Column(
                          children: [
                            _buildDisabledTextFormField(_controllerWBSID,
                                "Tiket Timbang", Icons.confirmation_number),
                            const SizedBox(height: 15),
                            _buildDisabledTextFormField(
                                _controllerDriver, "Supir", Icons.person),
                            const SizedBox(height: 15),
                            _buildDisabledTextFormField(_controllerPartId,
                                "Kode Komoditi", Icons.inventory),
                            const SizedBox(height: 15),
                            _buildDisabledTextFormField(_controllerPartName,
                                "Nama Komoditi", Icons.oil_barrel),
                            const SizedBox(height: 15),
                            _buildDisabledTextFormField(_controllerCustomerId,
                                "Kode Customer", Icons.people),
                            const SizedBox(height: 15),
                            _buildDisabledTextFormField(_controllerCustomerName,
                                "Nama Customer", Icons.assignment_ind),
                            const SizedBox(height: 15),
                            _buildDisabledTextFormField(
                                _controllerTransactionType,
                                "Tipe Transaksi",
                                Icons.local_shipping),

                            const SizedBox(height: 30),

                            // ========================================================
                            // Checkbox Input Quality
                            // ========================================================
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: _isCheckedQuality,
                                  onChanged: _isTruckDataSelected
                                      ? (bool? value) {
                                          setState(() {
                                            _isCheckedQuality = value!;
                                            _isQuality = value
                                                ? 'T'
                                                : 'F'; // Variabel tidak terpakai
                                            _clearQuality();
                                          });
                                        }
                                      : null,
                                ),
                                const Text("Input Quality"),
                              ],
                            ),
                            Visibility(
                              visible: _isCheckedQuality,
                              child: _buildQualityInputCard(),
                            ),

                            const SizedBox(height: 5),

                            // ========================================================
                            // Checkbox Input Segel
                            // ========================================================
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: _isCheckedSegel,
                                  onChanged: _isTruckDataSelected
                                      ? (bool? value) {
                                          setState(() {
                                            _isCheckedSegel = value!;
                                            _isSegel = value
                                                ? 'T'
                                                : 'F'; // Variabel tidak terpakai
                                            _clearSegel();
                                          });
                                        }
                                      : null,
                                ),
                                const Text("Input Segel"),
                              ],
                            ),
                            Visibility(
                              visible: _isCheckedSegel,
                              child: _buildSegelInputCard(),
                            ),

                            const SizedBox(height: 5),

                            // ========================================================
                            // Checkbox Pilih Storage
                            // ========================================================
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: _isCheckedStorage,
                                  onChanged: _isTruckDataSelected
                                      ? (bool? value) {
                                          setState(() {
                                            _isCheckedStorage = value!;
                                            _isStorage = value
                                                ? 'T'
                                                : 'F'; // Variabel tidak terpakai
                                            if (!value) {
                                              _selectedStorageFrom = null;
                                              _selectedStorageFromCode = '';
                                              _selectedStorageTo = null;
                                              _selectedStorageToCode = '';
                                            }
                                          });
                                        }
                                      : null,
                                ),
                                const Text("Pilih Storage"),
                              ],
                            ),

                            // Dropdown Pilih Storage
                            Visibility(
                              visible: _isCheckedStorage,
                              child: _buildStorageDropdownCard(),
                            ),

                            const SizedBox(height: 5),

                            // ========================================================
                            // Checkbox Input Camera
                            // ========================================================
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: _isCheckedCamera,
                                  onChanged: _isTruckDataSelected
                                      ? (bool? value) {
                                          setState(() {
                                            _isCheckedCamera = value!;
                                            // _isCamera = value ? 'T' : 'F'; // Variabel tidak terpakai
                                            if (!value) {
                                              _image1 = null;
                                              _image2 = null;
                                              _image3 = null;
                                            }
                                          });
                                        }
                                      : null,
                                ),
                                const Text("Input Camera"),
                              ],
                            ),
                            Visibility(
                              visible: _isCheckedCamera,
                              child: _buildCameraCaptureCard(),
                            ),

                            const SizedBox(height: 15),

                            // Tombol SIMPAN
                            ElevatedButton(
                              onPressed: _isTruckDataSelected
                                  ? _onSaveButtonPressed
                                  : null,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  _isTruckDataSelected
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: _isTruckDataSelected
                                            ? Colors.green
                                            : Colors.grey),
                                  ),
                                ),
                              ),
                              child: const Text(
                                "SIMPAN",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // LOGIKA TOMBOL SIMPAN & DIALOGS
  // =========================================================================

  // ... (fungsi _buildDisabledTextFormField) ...
  Widget _buildDisabledTextFormField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      enabled: false,
      controller: controller,
      style: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.red[900],
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.red[900],
          fontWeight: FontWeight.bold,
        ),
        hintText: labelText,
        filled: true,
        fillColor: Colors.grey[100],
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1.2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  // ... (fungsi _buildQualityInputCard) ...
  Widget _buildQualityInputCard() {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double fieldWidth = (constraints.maxWidth - 48) / 4;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQualityField(fieldWidth, _controllerFFA, "FFA",
                    (value) => _ffaValue = value),
                const SizedBox(width: 8),
                _buildQualityField(fieldWidth, _controllerMoisture, "Moisture",
                    (value) => _moistureValue = value),
                const SizedBox(width: 8),
                _buildQualityField(fieldWidth, _controllerKotoran, "Dirt",
                    (value) => _kotoranValue = value),
                const SizedBox(width: 8),
                _buildQualityField(fieldWidth, _controllerDobi, "Dobi",
                    (value) => _dobiValue = value),
              ],
            );
          },
        ),
      ),
    );
  }

  // ... (fungsi _buildQualityField) ...
  Widget _buildQualityField(double width, TextEditingController controller,
      String label, Function(double) onValueChanged) {
    return SizedBox(
      width: width,
      height: 50,
      child: TextFormField(
        style: const TextStyle(fontSize: 16),
        onChanged: (value) {
          setState(
            () =>
                onValueChanged(value.isEmpty ? 0 : double.tryParse(value) ?? 0),
          );
        },
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(fontSize: 14),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40.0)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        ),
      ),
    );
  }

  // ... (fungsi _buildSegelInputCard) ...
  Widget _buildSegelInputCard() {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            TextFormField(
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                setState(() => _segelValue = value.isEmpty ? '' : value);
              },
              controller: _controllerSegel,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "No Segel",
                labelText: "No Segel",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0)),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 150,
                child: TextFormField(
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    setState(() => _segelQtyValue = value.isEmpty ? '' : value);
                  },
                  controller: _controllerSegelQty,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "Segel Qty",
                    labelText: "Segel Qty",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (fungsi _buildStorageDropdownCard) ...
  Widget _buildStorageDropdownCard() {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            if (_isLoadingStorage)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Dropdown Storage From
                  DropdownButtonFormField<Storage>(
                    onChanged: _isTruckDataSelected
                        ? (Storage? data) {
                            setState(() {
                              _selectedStorageFrom = data;
                              _selectedStorageFromCode =
                                  data?.storagecode ?? '';
                            });
                          }
                        : null,
                    onTap: _isTruckDataSelected
                        ? null
                        : () {
                            _showSnackBar(
                                'Pilih Plat Kendaraan/WBSID terlebih dahulu.');
                          },
                    value: _selectedStorageFrom,
                    items: _storageList
                        .map<DropdownMenuItem<Storage>>((Storage storage) {
                      return DropdownMenuItem<Storage>(
                        value: storage,
                        child: Text(storage.toString()),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: "Storage From",
                      hintText: _storageList.isEmpty
                          ? "Tidak ada data Storage ditemukan"
                          : "Silahkan pilih Storage From",
                      floatingLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            _isTruckDataSelected ? Colors.black : Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (Storage? data) {
                      if (_isCheckedStorage && data == null) {
                        return "Mohon pilih Storage From";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // Dropdown Storage To
                  DropdownButtonFormField<Storage>(
                    onChanged: _isTruckDataSelected
                        ? (Storage? data) {
                            setState(() {
                              _selectedStorageTo = data;
                              _selectedStorageToCode = data?.storagecode ?? '';
                            });
                          }
                        : null,
                    onTap: _isTruckDataSelected
                        ? null
                        : () {
                            _showSnackBar(
                                'Pilih Plat Kendaraan/WBSID terlebih dahulu.');
                          },
                    value: _selectedStorageTo,
                    items: _storageList
                        .map<DropdownMenuItem<Storage>>((Storage storage) {
                      return DropdownMenuItem<Storage>(
                        value: storage,
                        child: Text(storage.toString()),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: "Storage To",
                      hintText: _storageList.isEmpty
                          ? "Tidak ada data Storage ditemukan"
                          : "Silahkan pilih Storage To",
                      floatingLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            _isTruckDataSelected ? Colors.black : Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (Storage? data) {
                      if (_isCheckedStorage && data == null) {
                        return "Mohon pilih Storage To";
                      }
                      return null;
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ... (fungsi _buildCameraCaptureCard) ...
  Widget _buildCameraCaptureCard() {
    const String noImagePath = 'assets/images/noimage.png';
    const String cameraImagePath = 'assets/images/camera.png';

    return Card(
      color: Colors.grey,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCameraColumn(1, _image1, noImagePath, cameraImagePath),
            _buildCameraColumn(2, _image2, noImagePath, cameraImagePath),
            _buildCameraColumn(3, _image3, noImagePath, cameraImagePath),
          ],
        ),
      ),
    );
  }

  // ... (fungsi _buildCameraColumn) ...
  Widget _buildCameraColumn(
      int index, File? image, String noImagePath, String cameraImagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: image != null
              ? Image.file(image, fit: BoxFit.cover)
              : Image.asset(noImagePath, width: 100),
        ),
        ElevatedButton(
          onPressed: _isTruckDataSelected
              ? () async {
                  await _getImage(index);
                }
              : null,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
                _isTruckDataSelected ? Colors.grey : Colors.grey.shade300),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            elevation: WidgetStateProperty.all(0),
          ),
          child: Image.asset(cameraImagePath, width: 50),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _onSaveButtonPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isTruckDataSelected) {
      _showErrorDialog("Pilih Plat Kendaraan terlebih dahulu.");
      return;
    }

    // 1. Validasi Quality
    if (_isQuality == 'F') {
      _showErrorDialog("Silahkan checklist Input Quality!");
      return;
    }

    // if (_isCheckedQuality &&
    //     (_ffaValue <= 0 ||
    //         _moistureValue <= 0 ||
    //         _kotoranValue <= 0 ||
    //         _dobiValue <= 0)) {
    //   _showErrorDialog(
    //       "Silahkan isi semua item quality dengan nilai yang valid (> 0)!");
    //   return;
    // }

    // 2. Validasi Segel
    if (_isSegel == 'F') {
      _showErrorDialog("Silahkan checklist Input Segel!");
      return;
    }
    if (_isCheckedSegel && (_segelValue.isEmpty || _segelQtyValue.isEmpty)) {
      _showErrorDialog("Silahkan isi nomor segel & segel qty dahulu!");
      return;
    }

    // 3. Validasi Storage
    // KOREKSI: Cek kedua storage (From dan To)
    if (_isStorage == 'F') {
      _showErrorDialog("Silahkan checklist Pilih Storage!");
      return;
    }
    if (_isCheckedStorage &&
        (_selectedStorageFrom == null || _selectedStorageTo == null)) {
      _showErrorDialog("Silahkan pilih Storage From dan Storage To dahulu!");
      return;
    }

    // 4. Validasi Camera
    if (!_isCheckedCamera) {
      _showErrorDialog("Silahkan checklist Input Camera!");
      return;
    }
    if (_isCheckedCamera &&
        (_image1 == null || _image2 == null || _image3 == null)) {
      _showErrorDialog("Silahkan ambil semua gambar (3 foto)!");
      return;
    }

    // Jika semua validasi lolos, tampilkan konfirmasi
    _showConfirmationDialog();
  }

  // KOREKSI: Mengatasi RenderFlex Overflow
  void _showErrorDialog(String message) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Peringatan'),
        content: Column(
          // FIX: Gunakan mainAxisSize.min untuk mencegah overflow
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, 'Ok'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)),
                ),
                child: const Text('Ok'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk Dialog Konfirmasi Simpan
  void _showConfirmationDialog() {
    BuildContext mainContext = context;

    showDialog<String>(
      context: mainContext,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Simpan'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Apakah anda yakin menyimpan data quality?"),
                const SizedBox(height: 10),
                Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: FixedColumnWidth(130),
                    1: FixedColumnWidth(15),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(children: [
                      const Text("FFA"),
                      const Text(":"),
                      Text("$_ffaValue")
                    ]),
                    TableRow(children: [
                      const Text("Moisture"),
                      const Text(":"),
                      Text("$_moistureValue")
                    ]),
                    TableRow(children: [
                      const Text("Dirt"),
                      const Text(":"),
                      Text("$_kotoranValue")
                    ]),
                    TableRow(children: [
                      const Text("Dobi"),
                      const Text(":"),
                      Text("$_dobiValue")
                    ]),
                    TableRow(children: [
                      const Text("No Segel"),
                      const Text(":"),
                      Text("$_segelValue")
                    ]),
                    TableRow(children: [
                      const Text("Segel Qty"),
                      const Text(":"),
                      Text("$_segelQtyValue")
                    ]),
                    TableRow(children: [
                      const Text("Storage From"),
                      const Text(":"),
                      Text(_selectedStorageFromCode)
                    ]),
                    TableRow(children: [
                      const Text("Storage To"),
                      const Text(":"),
                      Text(_selectedStorageToCode)
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'Tidak'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0)),
            ),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog konfirmasi

              BuildContext? loadingDialogContext;

              showDialog(
                context: mainContext,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  loadingDialogContext = dialogContext;
                  return const Center(child: CircularProgressIndicator());
                },
              );

              final isSuccess = await _addDataQualityTTFunc();

              if (mounted && loadingDialogContext != null) {
                Navigator.pop(loadingDialogContext!);
              }

              if (isSuccess && mounted) {
                _showSuccessDialogAndNavigate();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0)),
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }
}
