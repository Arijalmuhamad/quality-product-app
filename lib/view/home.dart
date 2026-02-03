// ... (Baris-baris import)
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wb_quality/models/transfer_terima/reportPerPart.dart';
import 'package:wb_quality/models/transfer_terima/reportTransaksi.dart';
import 'package:wb_quality/view/widgets/main_drawer.dart'; // Existing import
// =========================================================================
// IMPORTS BARU UNTUK MENU DINAMIS (Tambahkan kembali)
// =========================================================================
import 'package:wb_quality/services/menu_service.dart';
import '../models/menu_model.dart';
// =========================================================================
import '../models/transfer_kirim/reportPerPart.dart';
import '../models/transfer_kirim/reportTransaksi.dart';
import './profile.dart';
import 'quality_pl/quality_dashboard.dart';
import '../models/penjualan_langsung/reportTransaksi.dart';
import '../models/penjualan_langsung/reportPerPart.dart';
import 'package:wb_quality/services/site_info_service.dart';
import 'quality_tk/quality_dashboard.dart';
import 'quality_pb/quality_dashboard.dart';

// Asumsi datauser global ada di tempat lain, dipertahankan sesuai kode asli
// late List<Map<String, dynamic>> datauser;

// ASUMSI: Fungsi-fungsi untuk mengambil data (getReportTransaksiPL, dll.)
// dan model data (ReportTransaksiPL, SiteInfo, dll.) sudah didefinisikan
// dan di-import dengan benar di file yang relevan.

class HomeWB extends StatefulWidget {
  final String Username;
  const HomeWB(this.Username);

  @override
  State<HomeWB> createState() => _HomeWBState();
}

class _HomeWBState extends State<HomeWB> {
  int pageIndex = 0;

  // NOTE: datauser[0] digunakan di sini, pastikan datauser sudah didefinisikan
  // di scope yang dapat diakses, atau ganti dengan parameter yang sesuai.
  // Untuk tujuan ini, saya biarkan datauser[0] sesuai kode asli.
  late List<Widget> pageList;

  @override
  void initState() {
    super.initState();
    // Inisialisasi pageList di initState, menggunakan Username dari widget
    pageList = <Widget>[
      HomeMenu(widget.Username),
      Profile(widget.Username, "Default Level"), // Sesuaikan level jika perlu
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: Colors.white,
        currentIndex: pageIndex,
        selectedItemColor: Colors.green[900],
        selectedIconTheme: const IconThemeData(color: Colors.green),
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
      ),
    );
  }
}

class HomeMenu extends StatefulWidget {
  final String Username;
  const HomeMenu(this.Username);

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  // =======================================================
  // BARU: DEKLARASI FUTURE TUNGGAL
  // =======================================================
  late Future<List<dynamic>> _dataFutures;
  late Future<SiteInfo> siteInfoFuture;

  String inputDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // STATE UNTUK MENU DINAMIS (Tambahkan kembali)
  List<MenuModel> _drawerMenuList = [];
  bool _isDrawerLoading = true;
  String? _drawerError;
  final MenuService _menuService = MenuService();
  // =======================================================

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // =======================================================
  // FUNGSI INIT & REFRESH DATA UTAMA
  // =======================================================
  void _fetchInitialData() {
    // INISIALISASI SiteInfoFuture
    siteInfoFuture = getCompanyName();
    _fetchDrawerMenu(); // Panggil fungsi loading menu

    // Inisialisasi Future.wait
    _dataFutures = Future.wait([
      getReportTransaksiPL(),
      getReportPerPartPL(),
      getReportTransaksiTK(),
      getReportPerPartTK(),
      getReportTransaksiTT(),
      getReportPerPartTT()
    ]);
  }

  Future<void> _fetchDrawerMenu() async {
    if (!mounted) return;

    setState(() {
      _isDrawerLoading = true;
      _drawerError = null;
    });

    try {
      final fetchedList = await _menuService.fetchDynamicMenu();

      setState(() {
        _drawerMenuList = fetchedList;
        _isDrawerLoading = false;
      });
    } catch (e) {
      setState(() {
        _drawerError = e.toString().replaceFirst('Exception: ', '');
        _isDrawerLoading = false;
      });
    }
  }

  void refreshData() {
    setState(() {
      // Panggil _fetchInitialData lagi untuk memicu Future yang baru
      _fetchInitialData();
      inputDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
    });
  }
  // =======================================================

  // ----------------------------------------------------
  // FUNGSI _buildSiteInfoWidget (Tetap sama)
  // ----------------------------------------------------
  Widget _buildSiteInfoWidget() {
    // Mengambil warna dari Bottom Navigation Bar sebagai warna aksen
    final Color accentColor = Colors.green.shade700;
    final Color errorColor = Colors.red.shade700;

    return FutureBuilder<SiteInfo>(
      future: siteInfoFuture,
      builder: (context, snapshot) {
        final info = snapshot.data;
        // Cek jika error atau data null
        final bool isError =
            snapshot.hasError || (snapshot.hasData && info == null);
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        final companyName = isLoading
            ? 'Memuat Nama Pabrik...'
            : (info?.companyName ?? 'Gagal Memuat Pabrik');
        final siteId = isLoading ? '---' : (info?.siteId ?? 'ERR');

        final color = isError ? errorColor : accentColor;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white, // Latar belakang putih
            borderRadius: BorderRadius.circular(12),
            // Shadow halus untuk efek elevasi modern
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Pabrik/Lokasi - Dibuat dalam lingkaran kecil untuk menonjol
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15), // Warna aksen transparan
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_city,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Site ID - Sebagai label ringan (Meta-data)
                    Text(
                      'Site ID: $siteId',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    // Nama Pabrik - Dibuat lebih besar dan tebal (Fokus Utama)
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isError ? errorColor : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Indikator Status (Error/Loading)
              if (isError || isLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    isError ? Icons.error_outline : Icons.loop,
                    color: color,
                    size: 20,
                  ),
                ),
              if (!isError && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check_circle_outline, // Ikon sukses saat data OK
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ========================================================================
  // WIDGET _buildPartSummaryCard (Tetap sama)
  // ========================================================================
  Widget _buildPartSummaryCard({
    required String partName,
    required String netto,
    required String rit,
  }) {
    // Format netto dengan separator ribuan (contoh: 100000 -> 100.000)
    final formattedNetto =
        NumberFormat("#,##0", "id_ID").format(double.tryParse(netto) ?? 0);

    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Part Name & Netto (Kiri)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      // REKOMENDASI WARNA: Menggunakan Teal untuk Part Name
                      color: Colors.teal[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    // Menggunakan Row untuk Ikon dan Kuantitas
                    children: [
                      // REKOMENDASI IKON: Ikon Timbangan
                      Icon(Icons.scale_outlined,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Kuantiti: $formattedNetto Kg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Divider Vertikal
            Container(height: 35, width: 1, color: Colors.grey[300]),

            const SizedBox(width: 15),

            // 3. Ritase (Kanan)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RIT',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rit,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.green[900],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // WIDGET _buildTruckStatusContainer (Tetap sama)
  // ========================================================================
  Widget _buildTruckStatusContainer({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 40,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: valueColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // FUNGSI BUILD UTAMA DENGAN LOGIKA ANTI-FLICKER
  // ========================================================================
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/logo-kpn-1.png',
                width: 30), // Pastikan gambar ada
            const SizedBox(width: 10),
            const Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Home AWS Quality",
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
            onPressed: refreshData, // Menggunakan fungsi refreshData
            child: const Icon(Icons.refresh, color: Colors.green, size: 30),
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
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.density_medium, color: Colors.blueGrey),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),

      // DRAWER DINAMIS
      drawer: MainDrawer(
        username: widget.Username,
        menuList: _drawerMenuList,
        isLoading: _isDrawerLoading,
        error: _drawerError,
        onRetry: _fetchDrawerMenu, // Meneruskan fungsi retry
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
          future: _dataFutures, // Menggunakan future tunggal
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            // --- LOGIKA ANTI-FLICKER: Tentukan status loading ---
            final bool isInitialLoading =
                snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData;
            final bool isReloading =
                snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.hasData;

            // Data Extraction (menggunakan data yang tersedia, baik lama maupun baru)
            List<ReportTransaksiPL>? data1 =
                snapshot.data?[0] as List<ReportTransaksiPL>?;
            List<ReportPerPartPL>? data2 =
                snapshot.data?[1] as List<ReportPerPartPL>?;
            List<ReportTransaksiTK>? data3 =
                snapshot.data?[2] as List<ReportTransaksiTK>?;
            List<ReportPerPartTK>? data4 =
                snapshot.data?[3] as List<ReportPerPartTK>?;
            List<ReportTransaksiTT>? data5 =
                snapshot.data?[4] as List<ReportTransaksiTT>?;
            List<ReportPerPartTT>? data6 =
                snapshot.data?[5] as List<ReportPerPartTT>?;

            // 1. TAMPILKAN LOADING PENUH (Hanya saat loading awal dan belum ada data sama sekali)
            if (isInitialLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // 2. TAMPILKAN ERROR (Hanya jika error dan tidak ada data lama)
            if (snapshot.hasError && !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Text('Gagal memuat data: ${snapshot.error}',
                      textAlign: TextAlign.center),
                ),
              );
            }

            // 3. TAMPILKAN KONTEN + OVERLAY LOADING (Saat ada data lama ATAU data baru sudah masuk)
            return Stack(
              // Digunakan untuk membuat loading overlay
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // SISIPAN 1: Nama Pabrik dan Site ID
                    Padding(
                      // Menggabungkan padding luar dan dalam
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                      child: _buildSiteInfoWidget(),
                    ),

                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Header User and Last Update (Dipertahankan)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.teal[700],
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Hai, ${widget.Username}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.update,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "Last Update: $inputDate",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // =======================================================
                          // BAGIAN PENJUALAN LANGSUNG (PL)
                          // =======================================================

                          // PENANGANAN DATA KOSONG PL (DITAMPILKAN PESAN)
                          if (data1 == null || data1.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: Text(
                                  "Data transaksi Penjualan Langsung harian kosong",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          if (data1 != null && data1.isNotEmpty)
                            Card(
                              color: Colors.white,
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.sell),
                                        SizedBox(width: 10),
                                        Text(
                                          'Penjualan Langsung',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Kontainer Truk (Dipertahankan sesuai aslinya)
                                    const SizedBox(height: 20),
                                    _buildTruckStatusContainer(
                                      icon: Icons.local_shipping,
                                      iconColor: Colors.blue[800],
                                      title: "Total Truk Masuk",
                                      value: data1[0].truck_in,
                                      valueColor: Colors.blue[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.warning_amber_outlined,
                                      iconColor: Colors.red[800],
                                      title: "Truk Belum Cek Lab",
                                      value: data1[0].siap_quality,
                                      valueColor: Colors.red[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.verified_outlined,
                                      iconColor: Colors.yellow[800],
                                      title: "Truk Sudah Cek Lab",
                                      value: data1[0].sudah_quality,
                                      valueColor: Colors.yellow[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.exit_to_app,
                                      iconColor: Colors.green[800],
                                      title: "Total Truck Keluar",
                                      value: data1[0].truck_out,
                                      valueColor: Colors.green[800],
                                    ),

                                    // =============== REDESAIN REPORT PER PART PL =================
                                    if (data2 != null && data2.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 30, 5, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Detail Part Keluar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            GridView.builder(
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: 6.5,
                                              ),
                                              itemCount: data2.length,
                                              itemBuilder: (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return _buildPartSummaryCard(
                                                  partName:
                                                      data2[index].partName,
                                                  netto: data2[index].netto,
                                                  rit: data2[index].rit,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    // =============================================================
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),

                          // =======================================================
                          // BAGIAN TRANSFER KIRIM (TK)
                          // =======================================================

                          // PENANGANAN DATA KOSONG TK (TIDAK DITAMPILKAN PESAN)
                          if (data3 != null && data3.isNotEmpty)
                            Card(
                              color: Colors.white,
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.move_down_rounded),
                                        SizedBox(width: 10),
                                        Text(
                                          'Transfer Kirim',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Kontainer Truk (Dipertahankan sesuai aslinya)
                                    const SizedBox(height: 20),
                                    _buildTruckStatusContainer(
                                      icon: Icons.local_shipping,
                                      iconColor: Colors.blue[800],
                                      title: "Total Truk Masuk",
                                      value: data3[0].truck_in,
                                      valueColor: Colors.blue[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.warning_amber_outlined,
                                      iconColor: Colors.red[800],
                                      title: "Truk Belum Cek Lab",
                                      value: data3[0].siap_quality,
                                      valueColor: Colors.red[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.verified_outlined,
                                      iconColor: Colors.yellow[800],
                                      title: "Truk Sudah Cek Lab",
                                      value: data3[0].sudah_quality,
                                      valueColor: Colors.yellow[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.exit_to_app,
                                      iconColor: Colors.green[800],
                                      title: "Total Truck Keluar",
                                      value: data3[0].truck_out,
                                      valueColor: Colors.green[800],
                                    ),

                                    // =============== REDESAIN REPORT PER PART TK =================
                                    // TIDAK MENAMPILKAN PESAN KOSONG
                                    if (data4 != null && data4.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 30, 5, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Detail Part Keluar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            GridView.builder(
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: 6.5,
                                              ),
                                              itemCount: data4.length,
                                              itemBuilder: (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return _buildPartSummaryCard(
                                                  partName:
                                                      data4[index].partName,
                                                  netto: data4[index].netto,
                                                  rit: data4[index].rit,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    // =============================================================
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 30),

                          // =======================================================
                          // BAGIAN TRANSFER TERIMA (TT)
                          // =======================================================

                          // PENANGANAN DATA KOSONG TK (TIDAK DITAMPILKAN PESAN)
                          if (data5 != null && data5.isNotEmpty)
                            Card(
                              color: Colors.white,
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.move_to_inbox_rounded),
                                        SizedBox(width: 10),
                                        Text(
                                          'Transfer Terima',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Kontainer Truk (Dipertahankan sesuai aslinya)
                                    const SizedBox(height: 20),
                                    _buildTruckStatusContainer(
                                      icon: Icons.local_shipping,
                                      iconColor: Colors.blue[800],
                                      title: "Total Truk Masuk",
                                      value: data5[0].truck_in,
                                      valueColor: Colors.blue[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.warning_amber_outlined,
                                      iconColor: Colors.red[800],
                                      title: "Truk Belum Cek Lab",
                                      value: data5[0].siap_quality,
                                      valueColor: Colors.red[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.verified_outlined,
                                      iconColor: Colors.yellow[800],
                                      title: "Truk Sudah Cek Lab",
                                      value: data5[0].sudah_quality,
                                      valueColor: Colors.yellow[800],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTruckStatusContainer(
                                      icon: Icons.exit_to_app,
                                      iconColor: Colors.green[800],
                                      title: "Total Truck Keluar",
                                      value: data5[0].truck_out,
                                      valueColor: Colors.green[800],
                                    ),

                                    // =============== REDESAIN REPORT PER PART TT =================
                                    // TIDAK MENAMPILKAN PESAN KOSONG
                                    if (data6 != null && data6.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 30, 5, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Detail Part Keluar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            GridView.builder(
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: 6.5,
                                              ),
                                              itemCount: data6.length,
                                              itemBuilder: (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return _buildPartSummaryCard(
                                                  partName:
                                                      data6[index].partName,
                                                  netto: data6[index].netto,
                                                  rit: data6[index].rit,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    // =============================================================
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),

                // --- FIX KEDIPAN: LOADING OVERLAY ---
                // Tampilkan loading indikator transparan jika sedang loading TAPI sudah ada data
                if (isReloading)
                  Positioned.fill(
                    child: Container(
                      // Warna overlay: Background abu-abu dengan sedikit transparansi
                      // ignore: deprecated_member_use
                      color: Colors.grey[300]!.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                // --- END FIX ---
              ],
            );
          },
        ),
      ),
    );
  }
}
