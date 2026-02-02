import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const String _key = 'base_api_url';
  static const String _defaultUrl = '';

  // PERBAIKAN: Menggunakan nilai dari permintaan user: '/wb_sortase/'
  static const String staticPath = '/wb_quality/';

  // ----------------------------------------------------------------------
  // METHOD BARU UNTUK MEMBENTUK URL LENGKAP SAAT UJI KONEKSI
  // Fungsi ini dipanggil dari ApiSetupDialog.dart
  // ----------------------------------------------------------------------
  static String generateFullUrl(String ipPort, String endpoint) {
    // 1. Tambahkan protokol http:// jika belum ada
    final protocol = ipPort.startsWith('http') ? '' : 'http://';

    // 2. Pastikan IP/Port bersih dari trailing slash, karena staticPath sudah diawali slash.
    String base = ipPort;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    // 3. Gabungkan semua: http:// + IP:Port + /wb_sortase/ + endpoint
    // Hasil: http://192.168.1.10:46/wb_sortase/getdataCompanyName.php
    return '$protocol$base$staticPath$endpoint';
  }
  // ----------------------------------------------------------------------

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? _defaultUrl;
  }

  static Future<void> setBaseUrl(String input) async {
    final prefs = await SharedPreferences.getInstance();

    String trimmedInput = input.trim();
    if (trimmedInput.isEmpty) {
      await prefs.setString(_key, _defaultUrl);
      return;
    }

    // 1. Tambahkan http:// jika belum ada
    if (!trimmedInput.startsWith('http://') &&
        !trimmedInput.startsWith('https://')) {
      trimmedInput = 'http://$trimmedInput';
    }

    String finalUrl = trimmedInput;

    // 2. Pastikan IP/Port bersih dari trailing slash, sebelum menambahkan staticPath
    while (finalUrl.endsWith('/')) {
      finalUrl = finalUrl.substring(0, finalUrl.length - 1);
    }

    // 3. Gabungkan: IP/Port + staticPath
    // staticPath sudah memiliki '/' di depan: '/wb_sortase/'
    finalUrl = '$finalUrl${ApiConfigService.staticPath}';

    await prefs.setString(_key, finalUrl);
  }
}
