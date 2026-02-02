// File: services/menu_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Untuk debugPrint
// Pastikan path import ini benar:
import '../models/menu_model.dart';
import './api_config_service.dart';

class MenuService {
  final String _endpoint = "getdataMasterMenu.php";
  final String _targetGroup = "mobile_quality";

  Future<List<MenuModel>> fetchDynamicMenu() async {
    try {
      final baseUrl = await ApiConfigService.getBaseUrl();
      if (baseUrl.isEmpty) {
        // Melemparkan Exception jika Base URL tidak ada
        throw Exception("Konfigurasi API belum diatur. Base URL kosong.");
      }

      final url = Uri.parse("$baseUrl$_endpoint");

      // Kirim request dan batasi waktu (timeout)
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          debugPrint("API mengembalikan data menu kosong.");
          return [];
        }

        List<dynamic> data = jsonDecode(response.body);

        // Mapping dan Filtering: Hanya menu dengan Group_Menu: "mobile_quality"
        List<MenuModel> fetchedList = data
            .map((json) => MenuModel.fromJson(json))
            .where((menu) => menu.groupMenu == _targetGroup)
            .toList();

        return fetchedList;
      } else {
        // Melemparkan Exception jika status code tidak 200
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("Koneksi habis waktu (timeout 15s). Server lambat.");
    } catch (e) {
      debugPrint("Error fetching menu: $e");
      // Memberikan pesan error yang lebih user-friendly
      if (e.toString().contains('SocketException')) {
        throw Exception("Gagal koneksi ke server. Periksa jaringan atau URL.");
      }
      // Melemparkan error lainnya agar dapat ditangkap oleh widget
      rethrow;
    }
  }
}
