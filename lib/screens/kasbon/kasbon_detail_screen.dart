import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kasbon_provider.dart';
import '../../models/kasbon_model.dart';
import '../../models/pembayaran_kasbon_model.dart';

class KasbonDetailScreen extends StatefulWidget {
  final int kasbonId;

  const KasbonDetailScreen({super.key, required this.kasbonId});

  @override
  State<KasbonDetailScreen> createState() => _KasbonDetailScreenState();
}

class _KasbonDetailScreenState extends State<KasbonDetailScreen> {
  KasbonModel? _kasbon;
  List<PembayaranKasbonModel> _pembayaran = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = context.read<AuthProvider>().token!;
    final provider = context.read<KasbonProvider>();

    _kasbon = await provider.showKasbon(token, widget.kasbonId);
    _pembayaran = await provider.fetchPembayaran(token, widget.kasbonId);

    setState(() => _loading = false);
  }

  void _showBayarDialog() {
    if (_kasbon == null || _kasbon!.status == 'Lunas') return;

    final nominalCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bayar Cicilan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sisa tagihan: Rp${_kasbon!.sisaTagihan}'),
            const SizedBox(height: 12),
            TextField(
              controller: nominalCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nominal Bayar (Rp)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final nominal = int.tryParse(nominalCtrl.text) ?? 0;
              if (nominal <= 0) return;

              Navigator.pop(ctx);

              final token = context.read<AuthProvider>().token!;
              final ok = await context
                  .read<KasbonProvider>()
                  .bayarKasbon(token, widget.kasbonId, nominal);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Pembayaran berhasil'
                        : (context.read<KasbonProvider>().error ??
                            'Gagal membayar'))));
                if (ok) _load();
              }
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kasbon')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _kasbon == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Info Kasbon
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  _kasbon!.pelanggan?.namaPelanggan ??
                                      'Pelanggan #${_kasbon!.idPelanggan}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _infoRow(
                                  'Total Utang', 'Rp${_kasbon!.totalUtang}'),
                              _infoRow('Sisa Tagihan',
                                  'Rp${_kasbon!.sisaTagihan}'),
                              _infoRow('Status', _kasbon!.status),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Riwayat Pembayaran
                      const Text('Riwayat Pembayaran',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_pembayaran.isEmpty)
                        const Card(
                            child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Belum ada pembayaran'),
                        ))
                      else
                        ..._pembayaran.map((p) => Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                    child: Icon(Icons.payment)),
                                title: Text('Rp${p.nominalBayar}'),
                                subtitle: Text(p.tanggalBayar),
                              ),
                            )),
                    ],
                  ),
                ),
      floatingActionButton:
          _kasbon != null && _kasbon!.status != 'Lunas'
              ? FloatingActionButton.extended(
                  onPressed: _showBayarDialog,
                  icon: const Icon(Icons.payment),
                  label: const Text('Bayar'),
                )
              : null,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
