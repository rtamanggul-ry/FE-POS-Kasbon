import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kasbon_provider.dart';
import 'kasbon_detail_screen.dart';

class KasbonListScreen extends StatefulWidget {
  const KasbonListScreen({super.key});

  @override
  State<KasbonListScreen> createState() => _KasbonListScreenState();
}

class _KasbonListScreenState extends State<KasbonListScreen> {
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context
          .read<KasbonProvider>()
          .fetchKasbon(token, status: _filterStatus);
    }
  }

  Color _statusColor(String status) {
    return status == 'Lunas' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KasbonProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kasbon'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (val) {
              setState(() => _filterStatus = val);
              _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Semua')),
              const PopupMenuItem(
                  value: 'Belum Lunas', child: Text('Belum Lunas')),
              const PopupMenuItem(value: 'Lunas', child: Text('Lunas')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.list.isEmpty
                  ? const Center(child: Text('Tidak ada data kasbon'))
                  : RefreshIndicator(
                      onRefresh: () async => _load(),
                      child: ListView.builder(
                        itemCount: provider.list.length,
                        itemBuilder: (_, i) {
                          final k = provider.list[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statusColor(k.status),
                                child: const Icon(Icons.receipt_long,
                                    color: Colors.white),
                              ),
                              title: Text(k.pelanggan?.namaPelanggan ??
                                  'Pelanggan #${k.idPelanggan}'),
                              subtitle: Text(
                                  'Utang: Rp${k.totalUtang}  |  Sisa: Rp${k.sisaTagihan}'),
                              trailing: Chip(
                                label: Text(k.status,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11)),
                                backgroundColor: _statusColor(k.status),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          KasbonDetailScreen(kasbonId: k.id)),
                                ).then((_) => _load());
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
