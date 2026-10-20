import 'pelanggan_model.dart';
import 'detail_transaksi_model.dart';

class TransaksiModel {
  final int id;
  final String tanggal;
  final int totalHarga;
  final String metodePembayaran;
  final int? idPelanggan;
  final PelangganModel? pelanggan;
  final List<DetailTransaksiModel> detailTransaksis;

  TransaksiModel({
    required this.id,
    required this.tanggal,
    required this.totalHarga,
    required this.metodePembayaran,
    this.idPelanggan,
    this.pelanggan,
    this.detailTransaksis = const [],
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'],
      tanggal: json['tanggal'] ?? '',
      totalHarga: int.tryParse(json['total_harga'].toString()) ?? 0,
      metodePembayaran: json['metode_pembayaran'] ?? '',
      idPelanggan: json['id_pelanggan'],
      pelanggan: json['pelanggan'] != null
          ? PelangganModel.fromJson(json['pelanggan'])
          : null,
      detailTransaksis: json['detail_transaksis'] != null
          ? (json['detail_transaksis'] as List)
              .map((d) => DetailTransaksiModel.fromJson(d))
              .toList()
          : [],
    );
  }
}
