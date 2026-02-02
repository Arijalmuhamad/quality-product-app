// File: widgets/main_drawer.dart (VERSI DENGAN DATA DARI LUAR)

import 'package:flutter/material.dart';
import '../../models/menu_model.dart'; // Hanya import model

// Import halaman dashboard (sesuaikan path)
import '../quality_pl/quality_dashboard.dart';
import '../quality_tk/quality_dashboard.dart';
// import '../quality_pb/quality_dashboard.dart';
import '../quality_tt/quality_dashboard.dart';

// MainDrawer diubah menjadi StatelessWidget (atau Stateful hanya untuk UI)
class MainDrawer extends StatelessWidget {
  final String username;
  final List<MenuModel> menuList; // Data menu dari HomeWB
  final bool isLoading; // Status loading dari HomeWB
  final String? error; // Status error dari HomeWB
  final VoidCallback onRetry; // Fungsi retry dari HomeWB

  const MainDrawer({
    super.key,
    required this.username,
    required this.menuList,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final Color primaryColor = const Color.fromRGBO(183, 28, 28, 1);
  final Color accentColor = Colors.white;

  // ... (Helper untuk Icon dan Navigasi tetap sama) ...
  IconData _getIconForMenu(String kode) {
    switch (kode) {
      case 'sales':
        return Icons.sell_rounded;
      case 't_kirim':
        return Icons.move_down_rounded;
      case 't_terima':
        return Icons.move_to_inbox_rounded;
      case 'purchase':
        return Icons.payment_rounded;
      default:
        return Icons.menu_rounded;
    }
  }

  void _navigateTo(BuildContext context, MenuModel menu) {
    Navigator.of(context).pop();

    Widget destinationPage;

    switch (menu.kode) {
      case 'sales':
        destinationPage = const QualityDashboardPL();
        break;
      case 't_kirim':
        destinationPage = const QualityDashboardTK();
        break;
      case 't_terima':
        destinationPage = const QualityDashboardTT();
        break;
      case 'purchase':
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => destinationPage),
    );
  }

  Widget _buildMenuTile(BuildContext context, MenuModel menu) {
    return ListTile(
      leading: Icon(_getIconForMenu(menu.kode), color: accentColor),
      title: Text(menu.nama, style: TextStyle(color: accentColor)),
      hoverColor: primaryColor.withOpacity(0.5),
      onTap: () => _navigateTo(context, menu),
    );
  }
  // ... (Akhir Helper) ...

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // HEADER (tetap sama)
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo-kpn-1.png', width: 45),
                const SizedBox(height: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'AWS Quality App',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // LIST MENU DINAMIS (Menggunakan parameter dari HomeWB)
          if (isLoading)
            ListTile(
              leading: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              title:
                  Text('Memuat Menu...', style: TextStyle(color: accentColor)),
            )
          else if (error != null)
            ListTile(
              leading:
                  const Icon(Icons.warning_amber_rounded, color: Colors.yellow),
              title: Text('Gagal Memuat: $error',
                  style: TextStyle(color: Colors.yellow)),
              onTap: onRetry, // Panggil fungsi retry dari HomeWB
            )
          else if (menuList.isEmpty)
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: Text('Tidak ada menu ditemukan.',
                  style: TextStyle(color: accentColor)),
            )
          else
            // Render menu dari data yang sudah dimuat
            ...menuList.map((menu) => _buildMenuTile(context, menu)).toList(),

          // Menu Statis di bawah (tetap sama)
          Divider(color: accentColor.withOpacity(0.5)),

          // ... (Menu Pengaturan API dan Logout tetap sama) ...
        ],
      ),
    );
  }
}
