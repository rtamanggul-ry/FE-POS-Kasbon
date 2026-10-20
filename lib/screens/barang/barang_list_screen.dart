import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../models/barang_model.dart';
import 'barang_form_screen.dart';

class BarangListScreen extends StatefulWidget {
  const BarangListScreen({super.key});

  @override
  State<BarangListScreen> createState() => _BarangListScreenState();
}

class _BarangListScreenState extends State<BarangListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = context.read<AuthProvider>().token;
    if (token != null) context.read<BarangProvider>().fetchBarang(token);
  }

  void _confirmDelete(BarangModel barang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin hapus "${barang.namaBarang}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token!;
              final ok = await context
                  .read<BarangProvider>()
                  .deleteBarang(token, barang.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(ok ? 'Barang dihapus' : 'Gagal menghapus')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarangProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.list.isEmpty
                  ? const Center(child: Text('Belum ada barang'))
                  : ListView.builder(
                      itemCount: provider.list.length,
                      itemBuilder: (_, i) {
                        final b = provider.list[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            title: Text(b.namaBarang),
                            subtitle: Text(
                                'Modal: Rp${b.hargaModal}  |  Jual: Rp${b.hargaJual}  |  Stok: ${b.stok}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            BarangFormScreen(barang: b)),
                                  ).then((_) => _load());
                                } else if (val == 'hapus') {
                                  _confirmDelete(b);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                    value: 'hapus', child: Text('Hapus')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BarangFormScreen()),
          ).then((_) => _load());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
