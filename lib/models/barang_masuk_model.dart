import 'barang_model.dart';

class BarangMasukModel {
  final int id;
  final int idBarang;
  final String tanggalMasuk;
  final int jumlahMasuk;
  final BarangModel? barang;

  BarangMasukModel({
    required this.id,
    required this.idBarang,
    required this.tanggalMasuk,
    required this.jumlahMasuk,
    this.barang,
  });

  factory BarangMasukModel.fromJson(Map<String, dynamic> json) {
    return BarangMasukModel(
      id: json['id'],
      idBarang: json['id_barang'],
      tanggalMasuk: json['tanggal_masuk'] ?? '',
      jumlahMasuk: int.tryParse(json['jumlah_masuk'].toString()) ?? 0,
      barang:
          json['barang'] != null ? BarangModel.fromJson(json['barang']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_barang': idBarang,
      'tanggal_masuk': tanggalMasuk,
      'jumlah_masuk': jumlahMasuk,
    };
  }
}
