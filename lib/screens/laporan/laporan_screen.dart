import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHariIni());
  }

  void _loadHariIni() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<LaporanProvider>().fetchLaporanHariIni(token);
    }
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null && mounted) {
      final token = context.read<AuthProvider>().token!;
      final mulai =
          '${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}';
      final selesai =
          '${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}';
      context
          .read<LaporanProvider>()
          .fetchLaporan(token, tanggalMulai: mulai, tanggalSelesai: selesai);
    }
  }

  String _formatRp(int value) => 'Rp$value';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _pickRange,
              tooltip: 'Filter Rentang Tanggal'),
          IconButton(
              icon: const Icon(Icons.today),
              onPressed: _loadHariIni,
              tooltip: 'Laporan Hari Ini'),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Laporan Hari Ini
                    if (provider.hariIni != null) ...[
                      const Text('Laporan Hari Ini',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _laporanCard(
                        tanggal: provider.hariIni!.tanggalLaporan,
                        tunai: provider.hariIni!.totalPendapatanTunai,
                        kasbonBaru: provider.hariIni!.totalKasbonBaru,
                        bayarKasbon:
                            provider.hariIni!.totalPembayaranKasbon,
                        restok:
                            provider.hariIni!.totalPengeluaranRestok,
                      ),
                    ],
                    // Laporan Rentang
                    if (provider.list.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Laporan Rentang Tanggal',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...provider.list.map((l) => _laporanCard(
                            tanggal: l.tanggalLaporan,
                            tunai: l.totalPendapatanTunai,
                            kasbonBaru: l.totalKasbonBaru,
                            bayarKasbon: l.totalPembayaranKasbon,
                            restok: l.totalPengeluaranRestok,
                          )),
                    ],
                    if (provider.hariIni == null && provider.list.isEmpty)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Belum ada data laporan'),
                      )),
                  ],
                ),
    );
  }

  Widget _laporanCard({
    required String tanggal,
    required int tunai,
    required int kasbonBaru,
    required int bayarKasbon,
    required int restok,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tanggal,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            _row('Pendapatan Tunai', _formatRp(tunai), Colors.green),
            _row('Kasbon Baru', _formatRp(kasbonBaru), Colors.orange),
            _row(
                'Pembayaran Kasbon', _formatRp(bayarKasbon), Colors.blue),
            _row('Pengeluaran Restok', _formatRp(restok), Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
