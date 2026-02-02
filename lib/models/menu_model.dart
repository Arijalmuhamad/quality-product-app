// File: models/menu_model.dart

class MenuModel {
  final String kode;
  final String nama;
  final String groupMenu;

  MenuModel({
    required this.kode,
    required this.nama,
    required this.groupMenu,
  });

  // Factory constructor untuk membuat objek dari data JSON
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      kode: (json['Kode'] ?? '').toString(),
      nama: (json['Nama'] ?? '').toString(),
      groupMenu: (json['Group_Menu'] ?? '').toString(),
    );
  }
}
