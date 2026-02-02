import '../login.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class AddDataQualityTT extends StatefulWidget {
  // const AddDataQualityTK({super.key});
  final String Username;
  const AddDataQualityTT(this.Username);

  @override
  State<AddDataQualityTT> createState() => _AddDataQualityTTState();
}

class _AddDataQualityTTState extends State<AddDataQualityTT> {
  // List _images = []; // ignore: unused_field
  final _formKey = GlobalKey<FormState>();

  // Deklarasi controller
  TextEditingController controllerWBSID = TextEditingController();
  TextEditingController controllerVehicleNo = TextEditingController();
  TextEditingController controllerDriver = TextEditingController();
  TextEditingController controllerPartId = TextEditingController();
  TextEditingController controllerPartName = TextEditingController();
  TextEditingController controllerCustomerId = TextEditingController();
  TextEditingController controllerCustomerName = TextEditingController();
  // add by arijal
  TextEditingController controllerTransactionType = TextEditingController();

  // Item Quality
  TextEditingController controllerFFA = TextEditingController();
  TextEditingController controllerMoisture = TextEditingController();
  TextEditingController controllerKotoran = TextEditingController();
  TextEditingController controllerDobi = TextEditingController();

  // Item Segel
  TextEditingController controllerSegel = TextEditingController();

  // Insert data Quality
  void AddDataQualityTTFunc() {
    var url = Uri.parse("http://172.16.29.11:46/wb_quality/tt_adddata.php");

    // Datetime input Quality
    DateTime now = DateTime.now();
    String inputDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    http.post(
      url,
      body: {
        "wbsid": controllerWBSID.text,
        "vehicleno": controllerVehicleNo.text,
        "driver": controllerDriver.text,
        "partcode": controllerPartId.text,
        "partname": controllerPartName.text,
        "csid": controllerCustomerId.text,
        "csname": controllerCustomerName.text,

        // add by arijal
        //"TransactionType" : controllerTransactionType,
        "ffa": controllerFFA.text,
        "moisture": controllerMoisture.text,
        "kotoran": controllerKotoran.text,
        "dobi": controllerDobi.text,

        "nosegel": controllerSegel.text,

        "created_by": datauser[0]['name'],
        "created_at": inputDate,
      },
    );
  }

  // Deklarasi nilai quality
  double ffaValue = 0;
  double moistureValue = 0;
  double kotoranValue = 0;
  double dobiValue = 0;

  // Deklarasi segel
  String segelValue = '';

  // Hide is quality
  bool isCheckedQuality = false;
  String isQuality = 'F';

  // Hide is segel
  bool isCheckedSegel = false;
  String isSegel = 'F';

  // Hide is camera
  bool isCheckedCamera = false;
  String isCamera = 'F';

  // Reset value text field Quality
  void clearQuality() {
    if (isCheckedQuality == false) {
      controllerFFA.clear();
      controllerMoisture.clear();
      controllerKotoran.clear();
      controllerDobi.clear();
      setState(() {
        ffaValue = 0;
        moistureValue = 0;
        kotoranValue = 0;
        dobiValue = 0;
      });
    }
  }

  // Reset value text field Segel
  void clearSegel() {
    if (isCheckedSegel == false) {
      controllerSegel.clear();

      setState(() {
        segelValue = '';
      });
    }
  }

  // --------------------------------------------------------------------------------------------

  // Ambil kamera 1
  File? image1;
  XFile? imagePicked1;
  Future getImage1() async {
    final ImagePicker _picker = ImagePicker();
    final imagePicked1 = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    image1 = File(imagePicked1!.path);
    setState(() {});

    var uri = "http://172.16.29.11:46/wb_quality/uploadimage.php";

    var request = http.MultipartRequest('POST', Uri.parse(uri));
    var pic1 = await http.MultipartFile.fromPath(
      'image',
      // image1.toString(),
      // '/data/user/0/com.example.wb_automation/cache/',
      imagePicked1.path,
      filename: "${controllerWBSID.text}-1.jpg",
    );

    request.files.add(pic1);
    request.send();
  }

  // Ambil kamera 2
  File? image2;
  XFile? imagePicked2;
  Future getImage2() async {
    final ImagePicker _picker = ImagePicker();
    final imagePicked2 = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    image2 = File(imagePicked2!.path);
    setState(() {});

    var uri = "http://172.16.29.11:46/wb_quality/uploadimage.php";

    var request = http.MultipartRequest('POST', Uri.parse(uri));
    var pic2 = await http.MultipartFile.fromPath(
      'image',
      // image1.toString(),
      // '/data/user/0/com.example.wb_automation/cache/',
      imagePicked2.path,
      filename: "${controllerWBSID.text}-2.jpg",
    );

    request.files.add(pic2);
    request.send();
  }

  // Ambil kamera 3
  File? image3;
  XFile? imagePicked3;
  Future getImage3() async {
    final ImagePicker _picker = ImagePicker();
    final imagePicked3 = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    image3 = File(imagePicked3!.path);
    setState(() {});

    var uri = "http://172.16.29.11:46/wb_quality/uploadimage.php";

    var request = http.MultipartRequest('POST', Uri.parse(uri));
    var pic3 = await http.MultipartFile.fromPath(
      'image',
      // image1.toString(),
      // '/data/user/0/com.example.wb_automation/cache/',
      imagePicked3.path,
      filename: "${controllerWBSID.text}-3.jpg",
    );

    request.files.add(pic3);
    request.send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/logo-kpn-1.png', width: 30),
            SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tambah Data Quality Transfer Terima",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        leading: BackButton(color: Colors.black),
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: ListView(
            children: [
              Column(
                children: [
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: false,
                      showSearchBox: true,
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        floatingLabelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        labelText: "Plat Kendaraan",
                        hintText: "Silahkan pilih plat kendaraan",
                      ),
                    ),
                    clearButtonProps: ClearButtonProps(
                      icon: Icon(Icons.clear),
                      isVisible: false,
                      iconSize: 25,
                    ),
                    onChanged: (value) async {
                      var url = Uri.parse(
                        "http://172.16.29.11:46/wb_quality/tt_getdataTruckDesc.php",
                      );

                      final response = await http.post(
                        url,
                        body: {"vehicleno": value.toString()},
                      );

                      List tandan = jsonDecode(response.body);
                      print(response);
                      print(tandan);

                      List<String> wbsid = [];
                      // List<String> vehicleno = [];
                      List<String> driver = [];
                      List<String> partid = [];
                      List<String> partname = [];
                      List<String> csid = [];
                      List<String> csname = [];
                      //add by arijal
                      List<String> t_type = [];

                      setState(() {
                        tandan.forEach((element) {
                          wbsid.add(element["wbsid"]);
                          // vehicleno.add(element["vehicleno"]);
                          driver.add(element["driver"]);
                          partid.add(element["partid"]);
                          partname.add(element["partname"]);
                          csid.add(element["csid"]);
                          csname.add(element["csname"]);
                          // add by arijal
                          t_type.add(element["TransactionType"]);

                          var wbsidConv = wbsid
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');
                          // var vehiclenoConv = vehicleno.toString().replaceAll('[', '').replaceAll(']','');
                          var driverConv = driver
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');
                          var partidConv = partid
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');
                          var partnameConv = partname
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');
                          var csidConv = csid
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');
                          var csnameConv = csname
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');
                          // add by arijal
                          var t_typeConv = t_type
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '');

                          controllerVehicleNo.value =
                              controllerVehicleNo.value.copyWith(text: value);
                          // controllerWBSID.value = controllerWBSID.value.copyWith(text: value);
                          controllerWBSID.value =
                              controllerWBSID.value.copyWith(text: wbsidConv);
                          // controllerVehicleNo.value = controllerVehicleNo.value.copyWith(text: vehiclenoConv);
                          controllerDriver.value =
                              controllerDriver.value.copyWith(text: driverConv);
                          controllerPartId.value =
                              controllerPartId.value.copyWith(text: partidConv);
                          controllerPartName.value = controllerPartName.value
                              .copyWith(text: partnameConv);
                          controllerCustomerId.value = controllerCustomerId
                              .value
                              .copyWith(text: csidConv);
                          controllerCustomerName.value = controllerCustomerName
                              .value
                              .copyWith(text: csnameConv);
                          // add by arijal
                          controllerTransactionType.value =
                              controllerTransactionType.value.copyWith(
                            text: t_typeConv,
                          );
                        });
                      });
                    },
                    asyncItems: (text) async {
                      DateTime now1 = DateTime.now();
                      String inputDate1 = DateFormat('yyyy-MM-dd').format(now1);

                      var url = Uri.parse(
                        "http://172.16.29.11:46/wb_quality/tt_getdataTruck.php",
                      );

                      final response = await http.post(
                        url,
                        body: {"inputDate": inputDate1.toString()},
                      );

                      List quality = jsonDecode(response.body);
                      List<String> vehicleno = [];

                      quality.forEach((element) {
                        vehicleno.add(
                          element["vehicleno"],
                        ); //bisa diubah ke vehicleno/wbsid
                      });
                      return vehicleno;
                    },
                  ),

                  SizedBox(height: 25),

                  controllerVehicleNo.text == ''
                      ? Container()
                      : Column(
                          children: [
                            TextFormField(
                              enabled: false,
                              controller: controllerWBSID,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.confirmation_number,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Tiket Timbang",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Tiket Timbang",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            TextFormField(
                              enabled: false,
                              controller: controllerDriver,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Supir",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Supir",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            TextFormField(
                              enabled: false,
                              controller: controllerPartId,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.inventory,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Kode Komoditi",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Kode Komoditi",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            TextFormField(
                              enabled: false,
                              controller: controllerPartName,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.oil_barrel,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Nama Komoditi",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Nama Komoditi",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            TextFormField(
                              enabled: false,
                              controller: controllerCustomerId,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.people,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Kode Customer",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Kode Customer",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            TextFormField(
                              enabled: false,
                              controller: controllerCustomerName,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.assignment_ind,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Nama Customer",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Nama Customer",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            TextFormField(
                              enabled: false,
                              controller: controllerTransactionType,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.local_shipping,
                                  color: Colors.red[900],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                labelText: "Tipe Transaksi",
                                labelStyle: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Tipe Transaksi",
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
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: isCheckedQuality,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isCheckedQuality = value!;
                                      print(isCheckedQuality);

                                      if (isCheckedQuality == true) {
                                        setState(() {
                                          isQuality = 'T';
                                        });
                                      } else {
                                        setState(() {
                                          isQuality = 'F';
                                        });
                                      }
                                      print(isQuality);
                                      clearQuality();
                                    });
                                  },
                                ),
                                Text("Input Quality"),
                              ],
                            ),

                            Visibility(
                              visible: isCheckedQuality,
                              child: Card(
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ), // Tambah padding horizontal
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Kurangi spacing horizontal dari total width agar perhitungan akurat
                                      double fieldWidth =
                                          (constraints.maxWidth - 30) / 4;

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: fieldWidth,
                                            height: 50,
                                            child: TextFormField(
                                              style: TextStyle(fontSize: 16),
                                              onChanged: (value) {
                                                setState(
                                                  () => ffaValue = value.isEmpty
                                                      ? 0
                                                      : double.parse(
                                                          value,
                                                        ),
                                                );
                                              },
                                              controller: controllerFFA,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp(r'^\d*\.?\d*'),
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "FFA",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                labelText: "FFA",
                                                labelStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            height: 50,
                                            child: TextFormField(
                                              style: TextStyle(fontSize: 16),
                                              onChanged: (value) {
                                                setState(
                                                  () => moistureValue =
                                                      value.isEmpty
                                                          ? 0
                                                          : double.parse(
                                                              value,
                                                            ),
                                                );
                                              },
                                              controller: controllerMoisture,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp(r'^\d*\.?\d*'),
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "Moisture",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                labelText: "Moisture",
                                                labelStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            height: 50,
                                            child: TextFormField(
                                              style: TextStyle(fontSize: 16),
                                              onChanged: (value) {
                                                setState(
                                                  () => kotoranValue =
                                                      value.isEmpty
                                                          ? 0
                                                          : double.parse(
                                                              value,
                                                            ),
                                                );
                                              },
                                              controller: controllerKotoran,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp(r'^\d*\.?\d*'),
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "Dirt",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                labelText: "Dirt",
                                                labelStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            height: 50,
                                            child: TextFormField(
                                              style: TextStyle(fontSize: 16),
                                              onChanged: (value) {
                                                setState(
                                                  () =>
                                                      dobiValue = value.isEmpty
                                                          ? 0
                                                          : double.parse(
                                                              value,
                                                            ),
                                                );
                                              },
                                              controller: controllerDobi,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp(r'^\d*\.?\d*'),
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: "Dobi",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                labelText: "Dobi",
                                                labelStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            //<<==================== Input Segel==========================>>
                            SizedBox(height: 5),

                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: isCheckedSegel,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isCheckedSegel = value!;
                                      print(isCheckedSegel);

                                      if (isCheckedSegel == true) {
                                        setState(() {
                                          isSegel = 'T';
                                        });
                                      } else {
                                        setState(() {
                                          isSegel = 'F';
                                        });
                                      }
                                      print(isSegel);
                                      clearSegel();
                                    });
                                  },
                                ),
                                Text("Input Segel"),
                              ],
                            ),

                            Visibility(
                              visible: isCheckedSegel,
                              child: Card(
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ),
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 16),
                                    onChanged: (value) {
                                      setState(() {
                                        segelValue = value.isEmpty ? '' : value;
                                      });
                                    },
                                    controller: controllerSegel,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      hintText: "No Segel",
                                      hintStyle: TextStyle(fontSize: 14),
                                      labelText: "No Segel",
                                      labelStyle: TextStyle(fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 5),

                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: isCheckedCamera,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isCheckedCamera = value!;
                                      print(isCheckedCamera);

                                      if (isCheckedCamera == true) {
                                        setState(() {
                                          isCamera = 'T';
                                        });
                                      } else {
                                        setState(() {
                                          isCamera = 'F';
                                        });
                                      }
                                    });
                                  },
                                ),
                                Text("Input Camera"),
                              ],
                            ),

                            Visibility(
                              // visible: _isVisible,
                              visible: isCheckedCamera,
                              child: Card(
                                color: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Column(
                                  children: [
                                    // Capture camera
                                    Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                image1 != null
                                                    ? Container(
                                                        width: 100,
                                                        child: Image.file(
                                                          image1!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Container(
                                                        child: Image.asset(
                                                          'assets/images/noimage.png',
                                                          width: 100,
                                                        ),
                                                      ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await getImage1();
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/camera.png',
                                                    width: 50,
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll<
                                                            Color>(Colors.grey),
                                                    shape: WidgetStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          18.0,
                                                        ),
                                                        side: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    elevation:
                                                        WidgetStateProperty.all(
                                                      0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                image2 != null
                                                    ? Container(
                                                        width: 100,
                                                        child: Image.file(
                                                          image2!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Container(
                                                        child: Image.asset(
                                                          'assets/images/noimage.png',
                                                          width: 100,
                                                        ),
                                                      ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await getImage2();
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/camera.png',
                                                    width: 50,
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll<
                                                            Color>(Colors.grey),
                                                    shape: WidgetStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          18.0,
                                                        ),
                                                        side: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    elevation:
                                                        WidgetStateProperty.all(
                                                      0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                image3 != null
                                                    ? Container(
                                                        width: 100,
                                                        child: Image.file(
                                                          image3!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Container(
                                                        child: Image.asset(
                                                          'assets/images/noimage.png',
                                                          width: 100,
                                                        ),
                                                      ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await getImage3();
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/camera.png',
                                                    width: 50,
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll<
                                                            Color>(Colors.grey),
                                                    shape: WidgetStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          18.0,
                                                        ),
                                                        side: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    elevation:
                                                        WidgetStateProperty.all(
                                                      0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            ElevatedButton(
                              onPressed: () {
                                print(isQuality);
                                if (isQuality == 'T' &&
                                    (ffaValue == 0 &&
                                        moistureValue == 0 &&
                                        kotoranValue == 0 &&
                                        dobiValue == 0)) {
                                  showDialog<String>(
                                    useSafeArea: true,
                                    barrierDismissible: false,
                                    useRootNavigator: true,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      title: Text('Konfirmasi Simpan'),
                                      content: Container(
                                        height: 80,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Silahkan isi semua item quality dahulu!",
                                            ),
                                            SizedBox(height: 10),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  'Cancel',
                                                ),
                                                child: Text('Ok'),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                    Colors.red,
                                                  ),
                                                  shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        18.0,
                                                      ),
                                                      side: BorderSide(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (isCamera == 'F') {
                                  showDialog<String>(
                                    useSafeArea: true,
                                    barrierDismissible: false,
                                    useRootNavigator: true,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      title: Text('Konfirmasi Simpan'),
                                      content: Container(
                                        height: 80,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Silahkan checklist Is Camera!",
                                            ),
                                            SizedBox(height: 10),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  'Cancel',
                                                ),
                                                child: Text('Ok'),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                    Colors.red,
                                                  ),
                                                  shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        18.0,
                                                      ),
                                                      side: BorderSide(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (isCamera == 'T' &&
                                        (image1 == null) ||
                                    image2 == null ||
                                    image3 == null) {
                                  showDialog<String>(
                                    useSafeArea: true,
                                    barrierDismissible: false,
                                    useRootNavigator: true,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      title: Text('Konfirmasi Simpan'),
                                      content: Container(
                                        height: 80,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Silahkan ambil semua gambar!",
                                            ),
                                            SizedBox(height: 10),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  'Cancel',
                                                ),
                                                child: Text('Ok'),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                    Colors.red,
                                                  ),
                                                  shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        18.0,
                                                      ),
                                                      side: BorderSide(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (isSegel == 'T' &&
                                    segelValue.isEmpty) {
                                  showDialog<String>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      title: Text('Konfirmasi Simpan'),
                                      content: SizedBox(
                                        height: 80,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Silahkan isi nomor segel dahulu!",
                                            ),
                                            SizedBox(height: 10),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  'Cancel',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      18.0,
                                                    ),
                                                    side: BorderSide(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                child: Text('Ok'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else
                                  showDialog<String>(
                                    useSafeArea: true,
                                    barrierDismissible: false,
                                    useRootNavigator: true,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      title: Text('Konfirmasi Simpan'),
                                      content: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Apakah anda yakin menyimpan data quality?",
                                              ),
                                              SizedBox(height: 10),
                                              Table(
                                                columnWidths: const <int,
                                                    TableColumnWidth>{
                                                  0: FixedColumnWidth(130),
                                                  1: FixedColumnWidth(15),
                                                  2: FlexColumnWidth(),
                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      Text("FFA"),
                                                      Text(":"),
                                                      Text("$ffaValue"),
                                                    ],
                                                  ),
                                                  TableRow(
                                                    children: [
                                                      Text("Moisture"),
                                                      Text(":"),
                                                      Text("$moistureValue"),
                                                    ],
                                                  ),
                                                  TableRow(
                                                    children: [
                                                      Text("Dirt"),
                                                      Text(":"),
                                                      Text("$kotoranValue"),
                                                    ],
                                                  ),
                                                  TableRow(
                                                    children: [
                                                      Text("Dobi"),
                                                      Text(":"),
                                                      Text("$dobiValue"),
                                                    ],
                                                  ),
                                                  TableRow(
                                                    children: [
                                                      Text("No Segel"),
                                                      Text(":"),
                                                      Text("$segelValue"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            'Cancel',
                                          ),
                                          child: Text(
                                            'Tidak',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                              Colors.red,
                                            ),
                                            shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  18.0,
                                                ),
                                                side: BorderSide(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            AddDataQualityTTFunc();

                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (
                                                BuildContext context,
                                              ) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                  title: Text("Sukses"),
                                                  content: Text(
                                                    "Data berhasil disimpan.",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                        );
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          '/QualityDashboardTT',
                                                        );
                                                      },
                                                      child: Text(
                                                        "OK",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            'Ya',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                              Colors.green,
                                            ),
                                            shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  18.0,
                                                ),
                                                side: BorderSide(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                              },
                              child: Text("SIMPAN"),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.green,
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.green),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                  SizedBox(
                    height: 15,
                  ), // -------------------------------------------------------------------------------------------------------------
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
