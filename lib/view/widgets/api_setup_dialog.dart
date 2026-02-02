import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

// Sesuaikan path jika berbeda
import '/services/api_config_service.dart';

// Pindahkan deklarasi warna ke luar class State
const Color primaryBlue = Color(0xFF1565C0); // Contoh: Biru agak gelap/sedang

// Fungsi baru yang akan dipanggil untuk menampilkan dialog
void showApiSetupDialogAsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return const ApiSetupDialog();
    },
  );
}

class ApiSetupDialog extends StatefulWidget {
  const ApiSetupDialog({super.key});

  @override
  State<ApiSetupDialog> createState() => _ApiSetupDialogState();
}

class _ApiSetupDialogState extends State<ApiSetupDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUrl() async {
    final currentFullUrl = await ApiConfigService.getBaseUrl();

    if (currentFullUrl.isNotEmpty) {
      String displayUrl = currentFullUrl
          .replaceFirst('http://', '')
          .replaceFirst('https://', '')
          .replaceFirst(ApiConfigService.staticPath, '');
      _controller.text = displayUrl;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _saveUrl() async {
    String newIpPort = _controller.text.trim();
    if (newIpPort.isEmpty) {
      // SnackBar di sini akan berfungsi karena sudah dibungkus Material
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IP/Port tidak boleh kosong!')),
      );
      return;
    }

    await ApiConfigService.setBaseUrl(newIpPort);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfigurasi API Tersimpan.')),
      );
      Navigator.of(context).pop();
    }
  }

  // FUNGSI UNTUK TES KONEKSI
  void _testConnection() async {
    String ipPort = _controller.text.trim();
    if (ipPort.isEmpty) {
      // SnackBar di sini akan berfungsi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Masukkan IP/Port terlebih dahulu untuk menguji koneksi.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    String testUrl =
        ApiConfigService.generateFullUrl(ipPort, 'getdataCompanyName.php');

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('⏳ Menguji koneksi...'), duration: Duration(seconds: 2)));

    String message = '';
    Color color = Colors.red;

    try {
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        message = '✅ Koneksi Sukses! Server merespons (Code: 200).';
        color = Colors.green;
      } else {
        message =
            '⚠️ Gagal merespons! (Code: ${response.statusCode}). Cek path API.';
        color = Colors.orange;
      }
    } on SocketException {
      message = '❌ Gagal Terhubung. Cek IP/Port atau Jaringan Server.';
      color = Colors.red;
    } on TimeoutException {
      message =
          '❌ Koneksi Timeout (5s). Server terlalu lambat merespons atau Firewall memblokir.';
      color = Colors.red;
    } catch (e) {
      message = '❌ Error tidak dikenal saat tes koneksi: ${e.toString()}';
      color = Colors.red;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final viewInsets = MediaQuery.of(context).viewInsets;

    // 🎯 PERBAIKAN AKHIR: Bungkus dengan Material untuk mengatasi "No Material widget found"
    return Material(
      type: MaterialType
          .transparency, // Penting agar Material tidak mengganggu tampilan bottom sheet
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.90,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // JUDUL DIALOG
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 16, 8),
                  child: Text(
                    'Konfigurasi Server API',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const Divider(height: 1),

                // KONTEN UTAMA
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Akses Setup (5 Ketukan)',
                          style: TextStyle(
                              fontSize: 14,
                              color: primaryBlue,
                              fontWeight: FontWeight.w500),
                        ),
                        const Divider(),

                        // ------------------------------------------
                        // DESAIN INPUT
                        // ------------------------------------------
                        const Text(
                          'Masukkan IP Server dan Port:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            hintText: 'Misal: 192.168.1.10:46',
                            labelText: 'IP Server & Port',
                            prefixIcon: const Icon(Icons.dns_rounded,
                                color: primaryBlue),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: primaryBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Contoh: 172.16.29.11:46 (Pastikan tidak ada "http://" atau path di belakang).',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        // ------------------------------------------
                      ],
                    ),
                  ),
                ),

                // ACTIONS
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: <Widget>[
                      // Tombol Test Koneksi
                      OutlinedButton.icon(
                        onPressed: _testConnection,
                        icon: const Icon(Icons.flash_on, size: 18),
                        label: const Text('Test Koneksi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side:
                              const BorderSide(color: primaryBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        child: const Text('BATAL',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FilledButton(
                        onPressed: _saveUrl,
                        style: FilledButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10)),
                        child: const Text('SIMPAN'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
