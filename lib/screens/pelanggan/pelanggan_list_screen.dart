import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pelanggan_provider.dart';
import '../../models/pelanggan_model.dart';
import 'pelanggan_form_screen.dart';

class PelangganListScreen extends StatefulWidget {
  const PelangganListScreen({super.key});

  @override
  State<PelangganListScreen> createState() => _PelangganListScreenState();
}

class _PelangganListScreenState extends State<PelangganListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = context.read<AuthProvider>().token;
    if (token != null) context.read<PelangganProvider>().fetchPelanggan(token);
  }

  void _confirmDelete(PelangganModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Yakin hapus "${p.namaPelanggan}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token!;
              final ok = await context
                  .read<PelangganProvider>()
                  .deletePelanggan(token, p.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        ok ? 'Pelanggan dihapus' : 'Gagal menghapus')));
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
    final provider = context.watch<PelangganProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.list.isEmpty
                  ? const Center(child: Text('Belum ada pelanggan'))
                  : ListView.builder(
                      itemCount: provider.list.length,
                      itemBuilder: (_, i) {
                        final p = provider.list[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                                child: Icon(Icons.person)),
                            title: Text(p.namaPelanggan),
                            subtitle: Text(p.noHp ?? '-'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PelangganFormScreen(
                                            pelanggan: p)),
                                  ).then((_) => _load());
                                } else if (val == 'hapus') {
                                  _confirmDelete(p);
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
            MaterialPageRoute(
                builder: (_) => const PelangganFormScreen()),
          ).then((_) => _load());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
