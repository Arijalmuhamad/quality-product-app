// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ⭐ Import API Config Service
import 'package:wb_quality/services/api_config_service.dart';

import '../home.dart';
import '../login.dart';
import 'quality_detail.dart';
import 'quality_add.dart';

var dataquality;

class QualityDashboardTT extends StatefulWidget {
  const QualityDashboardTT({super.key});

  @override
  State<QualityDashboardTT> createState() => _QualityDashboardTTState();
}

class _QualityDashboardTTState extends State<QualityDashboardTT> {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<List> getData() async {
    // 1. Ambil Base URL secara dinamis
    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      debugPrint('Error: Base URL not configured.');
      if (mounted) {
        _showSnackBar(
            'Gagal memuat data dashboard. Konfigurasi API belum diatur.');
      }
      return []; // Mengembalikan list kosong jika URL tidak ada
    }

    // 2. Gabungkan Base URL dengan Endpoint spesifik
    var url = Uri.parse(
      "${baseUrl}tt_getdataDashboard.php",
    );

    try {
      final response = await http.post(
        url,
        body: {"inputDate": dateStamp.toString()},
      );

      if (response.statusCode == 200) {
        // Cek jika respons kosong
        if (response.body.isEmpty || response.body.trim() == '[]') {
          return [];
        }

        dataquality = jsonDecode(response.body);
        return dataquality;
      } else {
        debugPrint('Failed to load data. Status: ${response.statusCode}');
        if (mounted) {
          _showSnackBar(
              'Gagal memuat data. Server error: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (mounted) {
        _showSnackBar('Gagal memuat data. Periksa koneksi atau URL API.');
      }
      return [];
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/logo-kpn-1.png', width: 30),
              SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dashboard Transfer Terima",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        HomeWB(datauser[0]['name']),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                    const WidgetStatePropertyAll<Color>(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
              ),
              child: const Icon(Icons.home, color: Colors.blue, size: 40),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const QualityDashboardTT(),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                    const WidgetStatePropertyAll<Color>(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.white),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
              ),
              child: const Icon(Icons.refresh, color: Colors.green, size: 40),
            ),
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: "Tambah Data Quality",
          backgroundColor: Colors.blueAccent,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  AddDataQualityTT(datauser[0]['name']),
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: FutureBuilder<List>(
          future: getData(), // Memanggil fungsi getData yang sudah direfactor
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint("Error: ${snapshot.error}");
              return Center(
                child: Text(
                  "Gagal memuat data. Error: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ItemList(list: snapshot.data!);
            } else {
              return const Center(
                child: Text("Tidak ada data Quality TT untuk hari ini."),
              );
            }
          },
        ),
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;
  ItemList({required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text("Tidak ada data."));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        return Container(
            padding: EdgeInsets.only(right: 4, left: 4, top: 4, bottom: 0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQualityTT(list: list, index: i),
                ),
              ),
              child: Card(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${list[i]['wbsid'] ?? '-'}", // Tambahkan null check
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          "${list[i]['vehicleno'] ?? '-'}"), // Tambahkan null check
                    ],
                  ),
                  subtitle: Text(
                      "Part: ${list[i]['partname'] ?? '-'}"), // Tambahkan subtitle
                  tileColor: Color.fromARGB(255, 139, 186, 209),
                  isThreeLine: false,
                ),
              ),
            ));
      },
    );
  }
}
