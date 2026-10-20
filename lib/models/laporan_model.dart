class LaporanModel {
  final int id;
  final String tanggalLaporan;
  final int totalPendapatanTunai;
  final int totalKasbonBaru;
  final int totalPembayaranKasbon;
  final int totalPengeluaranRestok;

  LaporanModel({
    required this.id,
    required this.tanggalLaporan,
    required this.totalPendapatanTunai,
    required this.totalKasbonBaru,
    required this.totalPembayaranKasbon,
    required this.totalPengeluaranRestok,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'],
      tanggalLaporan: json['tanggal_laporan'] ?? '',
      totalPendapatanTunai:
          int.tryParse(json['total_pendapatan_tunai'].toString()) ?? 0,
      totalKasbonBaru:
          int.tryParse(json['total_kasbon_baru'].toString()) ?? 0,
      totalPembayaranKasbon:
          int.tryParse(json['total_pembayaran_kasbon'].toString()) ?? 0,
      totalPengeluaranRestok:
          int.tryParse(json['total_pengeluaran_restok'].toString()) ?? 0,
    );
  }
}
