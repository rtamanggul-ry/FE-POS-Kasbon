class BarangModel {
  final int id;
  final String namaBarang;
  final int hargaModal;
  final int hargaJual;
  final int stok;

  BarangModel({
    required this.id,
    required this.namaBarang,
    required this.hargaModal,
    required this.hargaJual,
    required this.stok,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'],
      namaBarang: json['nama_barang'] ?? '',
      hargaModal: int.tryParse(json['harga_modal'].toString()) ?? 0,
      hargaJual: int.tryParse(json['harga_jual'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_barang': namaBarang,
      'harga_modal': hargaModal,
      'harga_jual': hargaJual,
      'stok': stok,
    };
  }
}
