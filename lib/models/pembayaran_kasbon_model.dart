class PembayaranKasbonModel {
  final int id;
  final int idKasbon;
  final String tanggalBayar;
  final int nominalBayar;

  PembayaranKasbonModel({
    required this.id,
    required this.idKasbon,
    required this.tanggalBayar,
    required this.nominalBayar,
  });

  factory PembayaranKasbonModel.fromJson(Map<String, dynamic> json) {
    return PembayaranKasbonModel(
      id: json['id'],
      idKasbon: json['id_kasbon'],
      tanggalBayar: json['tanggal_bayar'] ?? '',
      nominalBayar: int.tryParse(json['nominal_bayar'].toString()) ?? 0,
    );
  }
}
