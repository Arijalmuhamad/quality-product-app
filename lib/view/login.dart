import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // Untuk TimeoutException
import 'dart:io'; // Untuk SocketException
// Import file service dan dialog
import 'package:wb_quality/services/api_config_service.dart';
import 'package:wb_quality/view/widgets/api_setup_dialog.dart';
// Import halaman Home untuk aplikasi Quality
import 'package:wb_quality/view/home.dart';

var datauser;

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String message1 = '';
  String message2 = '';
  bool isHidden = true;

  final String appVersion = 'Versi: 1.2.10';
  final _formKey = GlobalKey<FormState>();

  // ===========================================
  // === LOGIKA DETEKSI 5 KETUKAN (API SETUP) ===
  // ===========================================
  int _tapCount = 0;
  DateTime? _lastTap;
  static const int _tapRequired = 5;
  static const int _resetTimeMs = 1500; // 1.5 detik

  @override
  void initState() {
    super.initState();
    _checkInitialApiSetup();
  }

  // Cek apakah URL API sudah tersimpan. Jika belum, tampilkan dialog
  void _checkInitialApiSetup() async {
    String currentUrl = await ApiConfigService.getBaseUrl();
    if (currentUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiSetupDialog();
      });
    }
  }

  // Handler untuk ketukan pada logo/teks
  void _handleTap() {
    DateTime now = DateTime.now();

    if (_lastTap == null ||
        now.difference(_lastTap!).inMilliseconds > _resetTimeMs) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTap = now;

    if (_tapCount == _tapRequired) {
      _tapCount = 0; // Reset setelah sukses
      _showApiSetupDialog();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mode Setup API diaktifkan!')),
      );
    }

    setState(() {});
  }

  // Fungsi untuk menampilkan dialog setup API
  void _showApiSetupDialog() {
    showDialog(context: context, builder: (ctx) => const ApiSetupDialog());
  }
  // ===========================================

  _login() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Ambil BASE URL yang sudah lengkap dari penyimpanan lokal
    final baseUrl = await ApiConfigService.getBaseUrl();

    // Cek jika API URL belum dikonfigurasi
    if (baseUrl.isEmpty) {
      setState(() {
        message1 = 'Konfigurasi API Belum Diatur!';
        message2 = 'Mohon atur IP/URL server melalui mode setup tersembunyi.';
      });
      _showApiSetupDialog();
      return;
    }

    setState(() {
      message1 = 'Proses Login...';
      message2 = 'Menghubungkan ke Server';
    });

    try {
      // 2. Gunakan BASE URL lengkap dan tambahkan nama file API
      final url = Uri.parse('${baseUrl}login.php');

      final response = await http.post(
        url,
        body: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      ).timeout(const Duration(seconds: 10)); // Tambahkan timeout

      if (response.statusCode != 200) {
        setState(() {
          message1 = 'Login gagal!';
          message2 =
              'Server tidak dapat diakses (Status: ${response.statusCode}).';
        });
        return;
      }

      datauser = jsonDecode(response.body);

      // Asumsi datauser adalah list/array yang harus tidak kosong
      if (datauser == null || datauser.isEmpty) {
        setState(() {
          message1 = 'Login gagal!';
          message2 = 'Pastikan username & password sudah benar.';
        });
      } else {
        // PERUBAHAN DI SINI: Navigasi kini hanya meneruskan Username
        // HomeWB akan membaca data tambahan (site_id, dll) dari variabel global datauser.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeWB(datauser[0]['Username'] ?? usernameController.text),
          ),
        );
      }
    } on TimeoutException {
      setState(() {
        message1 = 'Koneksi Timeout!';
        message2 = 'Waktu tunggu koneksi habis (10 detik).';
      });
    } on SocketException {
      setState(() {
        message1 = 'Koneksi ke server gagal!';
        message2 = 'Silahkan cek IP server atau jaringan Anda.';
      });
    } on FormatException {
      setState(() {
        message1 = 'Terjadi kesalahan format data!';
        message2 = 'Server mengembalikan respons yang tidak valid (JSON).';
      });
    } catch (e) {
      setState(() {
        message1 = 'Error tidak dikenal!';
        message2 = 'Detail: $e';
      });
      debugPrint('Error login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(270),
                ),
                // Background Image
                child: Image.asset(
                  'assets/images/lab-4.jpg',
                  width: double.infinity,
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // === WRAPPING LOGO DENGAN TAP DETECTOR ===
                      GestureDetector(
                        onTap: _handleTap, // Panggil handler ketukan rahasia
                        child: Image.asset(
                          'assets/images/logo-kpn-1.png',
                          width: 70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'AUTONOMOUS WEIGHBRIDGE SYSTEM',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Judul Aplikasi Diubah menjadi Quality
                      const Text(
                        'QUALITY',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20),
                          hintText: 'Masukan username anda',
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: isHidden,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20),
                          hintText: 'Masukan password anda',
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.key),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                            icon: const Icon(Icons.remove_red_eye),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: const WidgetStatePropertyAll<Color>(
                            Colors.blue,
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (message1.isNotEmpty && message2.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                message1,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                message2,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Footer
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.copyright_sharp, color: Colors.black),
                              Text(
                                'KPN Corp 2025',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            appVersion,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
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
    );
  }
}
