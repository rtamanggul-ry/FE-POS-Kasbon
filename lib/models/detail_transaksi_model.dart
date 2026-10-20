import 'barang_model.dart';

class DetailTransaksiModel {
  final int? id;
  final int idBarang;
  final int kuantitas;
  final int hargaSatuan;
  final int subTotal;
  final BarangModel? barang;

  DetailTransaksiModel({
    this.id,
    required this.idBarang,
    required this.kuantitas,
    required this.hargaSatuan,
    required this.subTotal,
    this.barang,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      id: json['id'],
      idBarang: json['id_barang'],
      kuantitas: int.tryParse(json['kuantitas'].toString()) ?? 0,
      hargaSatuan: int.tryParse(json['harga_satuan'].toString()) ?? 0,
      subTotal: int.tryParse(json['sub_total'].toString()) ?? 0,
      barang:
          json['barang'] != null ? BarangModel.fromJson(json['barang']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_barang': idBarang,
      'kuantitas': kuantitas,
    };
  }
}
