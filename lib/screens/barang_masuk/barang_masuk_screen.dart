import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../models/barang_model.dart';
import '../../services/api_service.dart';

class BarangMasukScreen extends StatefulWidget {
  const BarangMasukScreen({super.key});

  @override
  State<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends State<BarangMasukScreen> {
  List<dynamic> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      // Fetch barang untuk dropdown
      final token = context.read<AuthProvider>().token;
      if (token != null) context.read<BarangProvider>().fetchBarang(token);
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = context.read<AuthProvider>().token!;
    try {
      _list = await ApiService(token: token).fetchBarangMasuk();
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showAddDialog() {
    final barangList = context.read<BarangProvider>().list;
    BarangModel? selectedBarang;
    final jumlahCtrl = TextEditingController();
    final tanggalCtrl = TextEditingController(
        text:
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tambah Restok'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<BarangModel>(
                initialValue: selectedBarang,
                decoration:
                    const InputDecoration(labelText: 'Pilih Barang'),
                items: barangList
                    .map((b) => DropdownMenuItem(
                        value: b, child: Text(b.namaBarang)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedBarang = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tanggalCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tanggal (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: jumlahCtrl,
                decoration:
                    const InputDecoration(labelText: 'Jumlah Masuk'),
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
                if (selectedBarang == null) return;
                Navigator.pop(ctx);

                final token = context.read<AuthProvider>().token!;
                try {
                  await ApiService(token: token).createBarangMasuk({
                    'id_barang': selectedBarang!.id,
                    'tanggal_masuk': tanggalCtrl.text,
                    'jumlah_masuk':
                        int.tryParse(jumlahCtrl.text) ?? 0,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Restok berhasil dicatat')));
                    _load();
                    // Refresh barang agar stok terupdate
                    context.read<BarangProvider>().fetchBarang(token);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e
                            .toString()
                            .replaceAll('Exception: ', ''))));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Masuk / Restok'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('Belum ada data restok'))
              : ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, i) {
                    final bm = _list[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.inventory)),
                        title:
                            Text(bm.barang?.namaBarang ?? 'Barang #${bm.idBarang}'),
                        subtitle: Text(
                            'Jumlah: +${bm.jumlahMasuk}  |  Tanggal: ${bm.tanggalMasuk}'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
