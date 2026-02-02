class QualityItem {
  final String kodeQuality;
  final String namaQuality;
  final String isActive; // 'T' atau 'F'

  QualityItem({
    required this.kodeQuality,
    required this.namaQuality,
    required this.isActive,
  });

  // Factory constructor untuk membuat objek dari JSON
  factory QualityItem.fromJson(Map<String, dynamic> json) {
    return QualityItem(
      kodeQuality: json['kode_quality'] as String,
      namaQuality: json['nama_quality'] as String,
      isActive: json['is_active'] as String,
    );
  }
}
