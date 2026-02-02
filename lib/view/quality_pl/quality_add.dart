// quality_add.dart (FINAL FIXED - Perbaikan Context Dialog)
import 'package:wb_quality/services/api_config_service.dart';

import '../login.dart'; // Asumsi file ini mendefinisikan `datauser`
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
// import 'package:wb_quality/services/site_info_service.dart';
import 'dart:async'; // Diperlukan untuk TimeoutException

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
// ===================================================================

class AddDataQualityPL extends StatefulWidget {
  final String username;
  const AddDataQualityPL(this.username, {super.key});

  @override
  State<AddDataQualityPL> createState() => _AddDataQualityPLState();
}

class _AddDataQualityPLState extends State<AddDataQualityPL> {
  final _formKey = GlobalKey<FormState>();

  // Deklarasi controller (Menggunakan nama yang sudah dirapikan)
  final TextEditingController _controllerWBSID = TextEditingController();
  final TextEditingController _controllerVehicleNo = TextEditingController();
  final TextEditingController _controllerDriver = TextEditingController();
  final TextEditingController _controllerPartId = TextEditingController();
  final TextEditingController _controllerPartName = TextEditingController();
  final TextEditingController _controllerCustomerId = TextEditingController();
  final TextEditingController _controllerCustomerName = TextEditingController();

  // Item Quality
  final TextEditingController _controllerFFA = TextEditingController();
  final TextEditingController _controllerMoisture = TextEditingController();
  final TextEditingController _controllerKotoran = TextEditingController();
  final TextEditingController _controllerDobi = TextEditingController();

  // Item Segel
  final TextEditingController _controllerSegelQty = TextEditingController();
  final TextEditingController _controllerSegel = TextEditingController();

  // Item Storage
  Storage? _selectedStorage;
  String _selectedStorageCode = '';
  List<Storage> _storageList = [];
  bool _isLoadingStorage = true; // Status loading

  // Status Kontrol Alur (Sequential Flow)
  bool _isTruckDataSelected = false;
  bool _isCheckedQuality = false;
  bool _isCheckedSegel = false;
  bool _isCheckedStorage = false;
  bool _isCheckedCamera = false;

  // Deklarasi nilai quality (untuk konfirmasi dialog)
  double _ffaValue = 0;
  double _moistureValue = 0;
  double _kotoranValue = 0;
  double _dobiValue = 0;

  // Deklarasi segel (untuk konfirmasi dialog)
  String _segelQtyValue = '';
  String _segelValue = '';

  // Status Checkbox (T/F string)
  String _isQuality = 'F';
  String _isSegel = 'F';
  String _isCamera = 'F';
  String _isStorage = 'F';

  // State Camera
  File? _image1;
  File? _image2;
  File? _image3;

  @override
  void initState() {
    super.initState();
    _fetchStorageData(); // Panggil di awal untuk mengisi data Storage
  }

  @override
  void dispose() {
    // Pastikan semua controller di-dispose
    _controllerWBSID.dispose();
    _controllerVehicleNo.dispose();
    _controllerDriver.dispose();
    _controllerPartId.dispose();
    _controllerPartName.dispose();
    _controllerCustomerId.dispose();
    _controllerCustomerName.dispose();
    _controllerFFA.dispose();
    _controllerMoisture.dispose();
    _controllerKotoran.dispose();
    _controllerDobi.dispose();
    _controllerSegelQty.dispose();
    _controllerSegel.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI FETCH DATA STORAGE
  // =========================================================================
  Future<void> _fetchStorageData() async {
    setState(() {
      _isLoadingStorage = true;
    });

    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      debugPrint('Error: Base URL not configured.');
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
    } catch (e) {
      debugPrint('Error fetching Storage data: $e');
      setState(() {
        _isLoadingStorage = false;
      });
      if (mounted) {
        _showSnackBar(
            'Gagal memuat data storage. Periksa koneksi atau URL API.');
      }
    }
  }

  // =========================================================================
  // FUNGSI SIMPAN DATA QUALITY (FIXED: TIMEOUT & LOGIC RESPONSE)
  // =========================================================================
  Future<bool> _addDataQualityPLFunc() async {
    // Mengembalikan status boolean
    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('❌ Konfigurasi API belum diatur.'),
          backgroundColor: Colors.red,
        ));
      }
      return false; // Gagal
    }

    var url = Uri.parse("${baseUrl}pl_adddata.php");

    final DateTime now = DateTime.now();
    final String inputDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    try {
      final Map<String, String> body = {
        "wbsid": _controllerWBSID.text,
        "vehicleno": _controllerVehicleNo.text,
        "driver": _controllerDriver.text,
        "partcode": _controllerPartId.text,
        "partname": _controllerPartName.text,
        "csid": _controllerCustomerId.text,
        "csname": _controllerCustomerName.text,
        "ffa": _controllerFFA.text,
        "moisture": _controllerMoisture.text,
        "kotoran": _controllerKotoran.text,
        "dobi": _controllerDobi.text,
        "segelqty": _controllerSegelQty.text,
        "nosegel": _controllerSegel.text,
        "storagecode": _selectedStorageCode,
        "created_by": (datauser.isNotEmpty && datauser[0].containsKey('name'))
            ? datauser[0]['name']
            : 'UNKNOWN',
        "created_at": inputDate,
      };

      // Kirim request DENGAN TIMEOUT 15 DETIK
      final response = await http.post(url, body: body).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // Jika terjadi timeout, lempar exception
          throw TimeoutException('Request to server timed out (15 seconds).');
        },
      );

      debugPrint('RESPONSE BODY:\n${response.body}');

      if (mounted) {
        if (response.statusCode == 200) {
          // Tangani Response Body yang kosong (kompatibilitas PHP API lama)
          if (response.body.isEmpty || response.body.trim().isEmpty) {
            debugPrint('✅ Data berhasil disimpan (Response Body Kosong)');
            return true;
          }

          // Lanjutkan parsing jika ada body (untuk PHP API yang sudah di-fix)
          try {
            final data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              debugPrint('✅ Data berhasil disimpan (Response JSON)');
              return true; // Sukses
            } else {
              debugPrint("❌ Gagal simpan: ${data['message']}");
              _showSnackBar("❌ Gagal simpan: ${data['message']}");
              return false; // Gagal (JSON status: fail)
            }
          } catch (e) {
            // Error Parsing
            debugPrint('❌ Gagal parsing JSON: $e');
            debugPrint('💡 Response mentah dari server: ${response.body}');
            _showSnackBar(
                "❌ Gagal parsing respons server. (Periksa log PHP: $e)");
            return false; // Gagal (Parsing error)
          }
        } else {
          debugPrint('❌ HTTP error: ${response.statusCode}');
          _showSnackBar("❌ HTTP error: ${response.statusCode}");
          return false; // Gagal (HTTP error)
        }
      }
    } catch (e) {
      debugPrint('❌ Terjadi error koneksi/timeout: $e');
      if (mounted) {
        String userMessage;
        if (e is TimeoutException) {
          userMessage =
              'Gagal menyimpan. Koneksi ke server habis waktu (Timeout 15 detik).';
        } else if (e is SocketException) {
          userMessage = 'Gagal menyimpan. Periksa koneksi internet/URL API.';
        } else {
          userMessage = 'Terjadi error: $e';
        }
        _showSnackBar("❌ $userMessage");
      }
      return false; // Gagal (Connection error or Timeout)
    }
    return false;
  }

  // =========================================================================
  // FUNGSI UTAMA UNTUK SIMPAN DATA QUALITY (TAMBAHAN HELPER)
  // =========================================================================

  // Helper untuk Dialog Sukses dan Navigasi
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
                Navigator.pushReplacementNamed(context, '/QualityDashboardPL');
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

  // =========================================================================
  // FUNGSI RESET DATA TRUK
  // =========================================================================
  void _resetTruckData() {
    setState(() {
      _controllerVehicleNo.clear();
      _controllerWBSID.clear();
      _controllerDriver.clear();
      _controllerPartId.clear();
      _controllerPartName.clear();
      _controllerCustomerId.clear();
      _controllerCustomerName.clear();

      // RESET STATUS ALUR
      _isTruckDataSelected = false;
      _selectedStorage = null;
      _selectedStorageCode = '';
      _isCheckedQuality = false;
      _isCheckedSegel = false;
      _isCheckedStorage = false;
      _isCheckedCamera = false;

      // RESET DATA GAMBAR
      _image1 = null;
      _image2 = null;
      _image3 = null;
    });
    _clearQuality();
    _clearSegel();
  }

  // =========================================================================
  // FUNGSI CLEAR (DIPANGGIL OLEH CHECKBOX)
  // =========================================================================
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
  // FUNGSI AMBIL GAMBAR
  // =========================================================================
  Future<void> _getImage(int index) async {
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

    // Validasi WBSID
    if (_controllerWBSID.text.isEmpty) {
      _showSnackBar('Pilih Plat Kendaraan terlebih dahulu untuk WBSID.');
      return;
    }

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
    request.send();
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
                  "Tambah Data Quality PL",
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

                      var url = Uri.parse("${baseUrl}pl_getdataTruckDesc.php");

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

                    // Ambil list plat kendaraan dan driver
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

                      var url = Uri.parse("${baseUrl}pl_getdataTruck.php");

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

                  // Tampilkan field deskripsi truk HANYA JIKA Plat Kendaraan sudah dipilih
                  _controllerVehicleNo.text.isEmpty
                      ? Container()
                      : Column(
                          children: [
                            // Field Tiket Timbang (WBSID)
                            _buildDisabledTextFormField(
                              _controllerWBSID,
                              "Tiket Timbang",
                              Icons.confirmation_number,
                            ),
                            const SizedBox(height: 15),

                            // Field Supir (Driver)
                            _buildDisabledTextFormField(
                              _controllerDriver,
                              "Supir",
                              Icons.person,
                            ),
                            const SizedBox(height: 15),

                            // Field Kode Komoditi
                            _buildDisabledTextFormField(
                              _controllerPartId,
                              "Kode Komoditi",
                              Icons.inventory,
                            ),
                            const SizedBox(height: 15),

                            // Field Nama Komoditi
                            _buildDisabledTextFormField(
                              _controllerPartName,
                              "Nama Komoditi",
                              Icons.oil_barrel,
                            ),
                            const SizedBox(height: 15),

                            // Field Kode Customer
                            _buildDisabledTextFormField(
                              _controllerCustomerId,
                              "Kode Customer",
                              Icons.people,
                            ),
                            const SizedBox(height: 15),

                            // Field Nama Customer
                            _buildDisabledTextFormField(
                              _controllerCustomerName,
                              "Nama Customer",
                              Icons.assignment_ind,
                            ),

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
                                            _isQuality = value ? 'T' : 'F';
                                            _clearQuality();
                                          });
                                        }
                                      : null,
                                ),
                                const Text("Input Quality"),
                              ],
                            ),

                            // Field Input Quality
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
                                            _isSegel = value ? 'T' : 'F';
                                            _clearSegel();
                                          });
                                        }
                                      : null,
                                ),
                                const Text("Input Segel"),
                              ],
                            ),

                            // Field Input Segel
                            Visibility(
                              visible: _isCheckedSegel,
                              child: _buildSegelInputCard(),
                            ),

                            const SizedBox(height: 5),

                            // ========================================================
                            // Checkbox Pilih Storage (LOGIKA UTAMA)
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
                                            _isStorage = value ? 'T' : 'F';
                                            // Reset storage terpilih jika checkbox dimatikan
                                            if (!value) {
                                              _selectedStorage = null;
                                              _selectedStorageCode = '';
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
                                            _isCamera = value ? 'T' : 'F';
                                            // Reset gambar jika checkbox dimatikan
                                            if (!value!) {
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

                            // Tombol Camera
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
  // HELPER WIDGETS
  // =========================================================================

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
            const SizedBox(height: 15),
            if (_isLoadingStorage)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<Storage>(
                // KONTROL ENABLED/DISABLED
                onChanged: _isTruckDataSelected
                    ? (Storage? data) {
                        setState(() {
                          _selectedStorage = data;
                          _selectedStorageCode = data?.storagecode ?? '';
                        });
                      }
                    : null,

                // FEEDBACK KETIKA DI-TAP SAAT DISABLED
                onTap: _isTruckDataSelected
                    ? null
                    : () {
                        _showSnackBar(
                            'Pilih Plat Kendaraan/WBSID terlebih dahulu.');
                      },

                value: _selectedStorage,

                // List items untuk dropdown (menggunakan toString() yang telah diperbaiki)
                items: _storageList
                    .map<DropdownMenuItem<Storage>>((Storage storage) {
                  return DropdownMenuItem<Storage>(
                    value: storage,
                    // Cukup panggil toString() yang kini hanya menampilkan storagecode
                    child: Text(storage.toString()),
                  );
                }).toList(),

                decoration: InputDecoration(
                  labelText: "Storage",
                  hintText: _storageList.isEmpty
                      ? "Tidak ada data Storage ditemukan"
                      : "Silahkan pilih Storage",
                  floatingLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    // PERBAIKAN: Mengganti warna biru dengan hitam
                    color: _isTruckDataSelected ? Colors.black : Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                ),

                validator: (Storage? data) {
                  if (_isCheckedStorage && data == null) {
                    return "Mohon pilih Storage";
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraCaptureCard() {
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
            _buildCameraColumn(1, _image1),
            _buildCameraColumn(2, _image2),
            _buildCameraColumn(3, _image3),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraColumn(int index, File? image) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: image != null
              ? Image.file(image, fit: BoxFit.cover)
              : Image.asset('assets/images/noimage.png', width: 100),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_controllerWBSID.text.isEmpty) {
              _showSnackBar(
                  'Pilih Plat Kendaraan terlebih dahulu untuk WBSID.');
            } else {
              await _getImage(index);
            }
          },
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll<Color>(Colors.grey),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            elevation: WidgetStateProperty.all(0),
          ),
          child: Image.asset('assets/images/camera.png', width: 50),
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

  // =========================================================================
  // LOGIKA TOMBOL SIMPAN
  // =========================================================================
  void _onSaveButtonPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Validasi Quality
    if (_isQuality == 'F') {
      _showErrorDialog("Silahkan checklist Input Quality!");
      return;
    }
    // if (_isQuality == 'T' &&
    //     (_ffaValue == 0 || _moistureValue == 0 || _kotoranValue == 0)) {
    //   _showErrorDialog(
    //       "Silahkan isi semua item quality dengan nilai yang valid!");
    //   return;
    // }

    // 2. Validasi Segel
    if (_isSegel == 'F') {
      _showErrorDialog("Silahkan checklist Input Segel!");
      return;
    }
    if (_isSegel == 'T' && (_segelValue.isEmpty || _segelQtyValue.isEmpty)) {
      _showErrorDialog("Silahkan isi nomor segel & segel qty dahulu!");
      return;
    }

    // 3. Validasi Storage (jika di-check)
    if (_isStorage == 'F') {
      _showErrorDialog("Silahkan checklist Pilih Storage!");
      return;
    }
    if (_isCheckedStorage && _selectedStorage == null) {
      _showErrorDialog("Silahkan pilih Storage dahulu!");
      return;
    }

    // 4. Validasi Camera
    if (_isCamera == 'F') {
      _showErrorDialog("Silahkan checklist Input Camera!");
      return;
    }
    if (_isCamera == 'T' &&
        (_image1 == null || _image2 == null || _image3 == null)) {
      _showErrorDialog("Silahkan ambil semua gambar!");
      return;
    }

    // Jika semua validasi lolos, tampilkan konfirmasi
    _showConfirmationDialog();
  }

  // Helper untuk Dialog Error
  void _showErrorDialog(String message) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Simpan'),
        content: SizedBox(
          height: 80,
          child: Column(
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
      ),
    );
  }

  // Helper untuk Dialog Konfirmasi Simpan (FIXED: Penutupan Context Dialog)
  void _showConfirmationDialog() {
    // Simpan context utama sebelum dialog ini muncul. Context ini aman untuk pop.
    BuildContext mainContext = context;

    showDialog<String>(
      context: mainContext,
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
                      const Text("Storage"),
                      const Text(":"),
                      Text(_selectedStorageCode)
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
              // 1. Tutup dialog konfirmasi (gunakan context dari builder)
              Navigator.pop(context);

              // 2. Tampilkan indikator loading.
              // Gunakan context utama (mainContext) yang sudah disimpan dan stabil.
              // Kita perlu menyimpan context yang *baru* dibuat oleh showDialog
              // untuk menutupnya secara spesifik.
              BuildContext? loadingDialogContext;

              showDialog(
                context: mainContext,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  // Simpan context dialog loading yang valid
                  loadingDialogContext = dialogContext;
                  return const Center(child: CircularProgressIndicator());
                },
              );

              // 3. Panggil fungsi simpan dan tunggu hasilnya
              final isSuccess = await _addDataQualityPLFunc();

              // 4. Tutup indikator loading.
              if (mounted && loadingDialogContext != null) {
                // Gunakan context dialog loading yang sudah disimpan
                Navigator.pop(loadingDialogContext!);
              }

              // 5. Tampilkan dialog sukses & Navigasi jika berhasil
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
