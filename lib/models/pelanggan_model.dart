class PelangganModel {
  final int id;
  final String namaPelanggan;
  final String? noHp;

  PelangganModel({
    required this.id,
    required this.namaPelanggan,
    this.noHp,
  });

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    return PelangganModel(
      id: json['id'],
      namaPelanggan: json['nama_pelanggan'] ?? '',
      noHp: json['no_hp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_pelanggan': namaPelanggan,
      'no_hp': noHp,
    };
  }
}
