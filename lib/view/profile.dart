import 'package:flutter/material.dart';
import 'package:wb_quality/view/widgets/custom_dialog.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  // const Profile({super.key});
  final String Username;
  final String Level;
  const Profile(this.Username, this.Level);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "Akun Saya",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hai, ${datauser[0]['name']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${datauser[0]['level']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset('assets/images/user.png', width: 100),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        showCustomConfirmationDialog(
                          context: context,
                          title: 'Konfirmasi Logout',
                          content: 'Apakah anda ingin keluar?',
                          onConfirm: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/LoginForm',
                            );
                          },
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll<Color>(
                          Colors.red,
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'LOGOUT',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
