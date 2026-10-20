import 'pelanggan_model.dart';
import 'pembayaran_kasbon_model.dart';

class KasbonModel {
  final int id;
  final int idPelanggan;
  final int idTransaksi;
  final int totalUtang;
  final int sisaTagihan;
  final String status; // 'Belum Lunas' atau 'Lunas'
  final PelangganModel? pelanggan;
  final List<PembayaranKasbonModel> pembayaranKasbons;

  KasbonModel({
    required this.id,
    required this.idPelanggan,
    required this.idTransaksi,
    required this.totalUtang,
    required this.sisaTagihan,
    required this.status,
    this.pelanggan,
    this.pembayaranKasbons = const [],
  });

  factory KasbonModel.fromJson(Map<String, dynamic> json) {
    return KasbonModel(
      id: json['id'],
      idPelanggan: json['id_pelanggan'],
      idTransaksi: json['id_transaksi'],
      totalUtang: int.tryParse(json['total_utang'].toString()) ?? 0,
      sisaTagihan: int.tryParse(json['sisa_tagihan'].toString()) ?? 0,
      status: json['status'] ?? 'Belum Lunas',
      pelanggan: json['pelanggan'] != null
          ? PelangganModel.fromJson(json['pelanggan'])
          : null,
      pembayaranKasbons: json['pembayaran_kasbons'] != null
          ? (json['pembayaran_kasbons'] as List)
              .map((p) => PembayaranKasbonModel.fromJson(p))
              .toList()
          : [],
    );
  }
}
