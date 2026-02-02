// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io'; // Tambahkan untuk SocketException
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// ⚠️ Pastikan path import ini benar dan konsisten dengan project Anda
import 'package:wb_quality/services/api_config_service.dart';
import '../home.dart';
import '../login.dart';
import 'quality_detail.dart';
import 'quality_add.dart';

var dataquality;

class QualityDashboardPB extends StatefulWidget {
  const QualityDashboardPB({super.key});

  @override
  State<QualityDashboardPB> createState() => _QualityDashboardPBState();
}

class _QualityDashboardPBState extends State<QualityDashboardPB> {
  String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<List> getData() async {
    // 1. Ambil BASE URL secara dinamis
    final baseUrl = await ApiConfigService.getBaseUrl();
    if (baseUrl.isEmpty) {
      // Throw error jika konfigurasi belum diatur
      throw Exception(
          'Konfigurasi API Belum Diatur. Mohon atur IP/Port server.');
    }

    // 2. Susun URL lengkap
    var url = Uri.parse(
      "${baseUrl}wb_quality/pb_getdataDashboard.php",
    );

    try {
      final response = await http.post(
        url,
        body: {"inputDate": dateStamp.toString()},
      ).timeout(const Duration(seconds: 15)); // Tambahkan timeout

      if (response.statusCode == 200) {
        // Cek jika body kosong atau hanya array kosong
        if (response.body.isEmpty || response.body.trim() == '[]') {
          return [];
        }

        dataquality = jsonDecode(response.body);
        return dataquality;
      } else {
        throw Exception(
            'Gagal memuat data dashboard. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
          'Koneksi ke server gagal. Cek jaringan atau konfigurasi IP.');
    } on TimeoutException {
      throw Exception('Permintaan data timeout. Server tidak merespon.');
    } catch (e) {
      // Menangani error JSON decode atau error umum lainnya
      throw Exception('Terjadi kesalahan saat memproses data: ${e.toString()}');
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
              SizedBox(width: 15),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dashboard Pembelian",
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
                // Periksa datauser sebelum navigasi, untuk menghindari error jika session hilang
                if (datauser != null && datauser.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          HomeWB(datauser[0]['name']),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Sesi pengguna tidak valid. Silakan login kembali.')),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginForm()),
                  );
                }
              },
              child: Icon(Icons.home, color: Colors.blue, size: 40),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.white),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Refresh data dengan navigasi (otomatis panggil FutureBuilder ulang)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => QualityDashboardPB(),
                  ),
                );
              },
              child: Icon(Icons.refresh, color: Colors.green, size: 40),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.white),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
              ),
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
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            // Periksa datauser sebelum navigasi
            if (datauser != null && datauser.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      AddDataQualityPB(datauser[0]['name']),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Sesi pengguna tidak valid. Silakan login kembali.')),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginForm()),
              );
            }
          },
        ),
        body: FutureBuilder<List>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Tampilkan error yang lebih informatif
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Gagal memuat data: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }

            // Jika data ada, tampilkan ItemList, jika tidak ada, tampilkan pesan
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ItemList(list: snapshot.data!);
            } else {
              return Center(
                child: Text("Tidak ada data Quality hari ini."),
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
    return ListView.builder(
      // Atur itemCount ke 0 jika list kosong, meskipun FutureBuilder sudah menangani ini
      itemCount: list.isEmpty ? 0 : list.length,
      itemBuilder: (context, i) {
        return Container(
          padding: EdgeInsets.only(right: 4, left: 4, top: 4, bottom: 0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    DetailQualityPB(list: list, index: i),
              ),
            ),
            child: Card(
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${list[i]['wbsid']}"),
                    Text("${list[i]['vehicleno']}"),
                  ],
                ),
                subtitle: Text(
                    "Waktu: ${list[i]['created_at'] ?? 'N/A'}"), // Tampilkan created_at jika ada
                tileColor: Color.fromARGB(255, 139, 186, 209),
                isThreeLine: false,
              ),
            ),
          ),
        );
      },
    );
  }
}
