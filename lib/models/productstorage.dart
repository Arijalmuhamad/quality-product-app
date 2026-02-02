class Storage {
  final String plant;
  final String storagecode;
  final String description;

  Storage({
    required this.plant,
    required this.storagecode,
    required this.description,
  });

  // di file productstorage.dart
  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      // Wajib: Null check untuk mencegah error jika key tidak ada
      plant: (json['PLANT'] ?? '').toString(),
      storagecode: (json['STORAGECODE'] ?? '').toString(),
      description: (json['DESCRIPTION'] ?? '').toString(),
    );
  }
}
