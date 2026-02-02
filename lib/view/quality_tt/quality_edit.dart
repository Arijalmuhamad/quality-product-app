import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../login.dart';
import 'quality_dashboard.dart';
import 'package:http/http.dart' as http;

class EditDataQualityTT extends StatefulWidget {
  final List list;
  final int index;

  final String Username;

  EditDataQualityTT({
    required this.list,
    required this.index,
    required this.Username,
  });

  @override
  State<EditDataQualityTT> createState() => _EditDataQualityTTState();
}

class _EditDataQualityTTState extends State<EditDataQualityTT> {
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

  void EditDataQualityTKFunc() {
    var url = Uri.parse("http://172.16.29.11:46/wb_quality/tt_editdata.php");

    // Datetime edit sortase
    DateTime now = DateTime.now();
    String editDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    http.post(
      url,
      body: {
        "wbsid": controllerWBSID!.text,

        "ffa": controllerFFA!.text,
        "moisture": controllerMoisture!.text,
        "kotoran": controllerKotoran!.text,
        "dobi": controllerDobi!.text,

        "updated_at": editDate,
        "updated_by": datauser[0]['name'],
      },
    );
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Data Quality TK"),
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Column(
                children: [
                  TextFormField(
                    enabled: false,
                    controller: controllerWBSID,
                    decoration: new InputDecoration(
                      hintText: "Tiket Timbang",
                      labelText: "Tiket Timbang",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerVehicleNo,
                    decoration: new InputDecoration(
                      hintText: "Plat Kendaraan",
                      labelText: "Plat Kendaraan",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerDriver,
                    decoration: new InputDecoration(
                      hintText: "Supir",
                      labelText: "Supir",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerPartId,
                    decoration: new InputDecoration(
                      hintText: "Kode Komoditi",
                      labelText: "Kode Komoditi",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerPartName,
                    decoration: new InputDecoration(
                      hintText: "Nama Komoditi",
                      labelText: "Nama Komoditi",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerCustomerId,
                    decoration: new InputDecoration(
                      hintText: "Kode Customer",
                      labelText: "Kode Customer",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    enabled: false,
                    controller: controllerCustomerName,
                    decoration: new InputDecoration(
                      hintText: "Nama Customer",
                      labelText: "Nama Customer",
                      // icon: Icon(Icons.library_books_rounded),
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Card(
                    // color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              style: TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => ffaValue = 0);
                                } else {
                                  setState(
                                    () => ffaValue = double.parse(value),
                                  );
                                  // setState(() {
                                  //   abnormalValue = double.parse(value);
                                  // });
                                }
                              },
                              controller: controllerFFA,
                              keyboardType: TextInputType.number,
                              // initialValue: "",
                              decoration: InputDecoration(
                                hintText: "FFA",
                                hintStyle: TextStyle(fontSize: 14),
                                labelText: "FFA",
                                labelStyle: TextStyle(fontSize: 14),
                                // icon: Icon(Icons.library_books_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              style: TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => moistureValue = 0);
                                } else {
                                  setState(
                                    () => moistureValue = double.parse(value),
                                  );
                                }
                              },
                              controller: controllerMoisture,
                              keyboardType: TextInputType.number,
                              // initialValue: "",
                              decoration: InputDecoration(
                                hintText: "Moisture",
                                hintStyle: TextStyle(fontSize: 14),
                                labelText: "Moisture",
                                labelStyle: TextStyle(fontSize: 14),
                                // icon: Icon(Icons.library_books_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              style: TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => kotoranValue = 0);
                                } else {
                                  setState(
                                    () => kotoranValue = double.parse(value),
                                  );
                                }
                              },
                              controller: controllerKotoran,
                              keyboardType: TextInputType.number,
                              // initialValue: "",
                              decoration: InputDecoration(
                                hintText: "Dirt",
                                hintStyle: TextStyle(fontSize: 14),
                                labelText: "Dirt",
                                labelStyle: TextStyle(fontSize: 14),
                                // icon: Icon(Icons.library_books_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              style: TextStyle(fontSize: 16),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() => dobiValue = 0);
                                } else {
                                  setState(
                                    () => dobiValue = double.parse(value),
                                  );
                                }
                              },
                              controller: controllerDobi,
                              keyboardType: TextInputType.number,
                              // initialValue: "",
                              decoration: InputDecoration(
                                hintText: "Dobi",
                                hintStyle: TextStyle(fontSize: 14),
                                labelText: "Dobi",
                                labelStyle: TextStyle(fontSize: 14),
                                // icon: Icon(Icons.library_books_rounded),
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

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed:
                        () => showDialog<String>(
                          useSafeArea: true,
                          barrierDismissible: false,
                          useRootNavigator: true,
                          context: context,
                          builder:
                              (BuildContext context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text('Konfirmasi Edit'),
                                content: Text(
                                  "Apakah anda yakin mengedit data quality?",
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, 'Cancel'),
                                    child: Text('Tidak'),
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.red,
                                      ),
                                      shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.0,
                                          ),
                                          side: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      EditDataQualityTKFunc();
                                      Navigator.of(context).push(
                                        new MaterialPageRoute(
                                          builder:
                                              (BuildContext context) =>
                                                  QualityDashboardTT(),
                                        ),
                                      );
                                    },
                                    child: Text('Ya'),
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.green,
                                      ),
                                      shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.0,
                                          ),
                                          side: BorderSide(color: Colors.green),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
