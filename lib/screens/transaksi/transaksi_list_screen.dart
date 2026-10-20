import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaksi_provider.dart';

class TransaksiListScreen extends StatefulWidget {
  const TransaksiListScreen({super.key});

  @override
  State<TransaksiListScreen> createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<TransaksiProvider>().fetchTransaksi(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.list.isEmpty
                  ? const Center(child: Text('Belum ada transaksi'))
                  : ListView.builder(
                      itemCount: provider.list.length,
                      itemBuilder: (_, i) {
                        final t = provider.list[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  t.metodePembayaran == 'Tunai'
                                      ? Colors.green
                                      : Colors.orange,
                              child: Icon(
                                t.metodePembayaran == 'Tunai'
                                    ? Icons.payments
                                    : Icons.credit_card,
                                color: Colors.white,
                              ),
                            ),
                            title: Text('Rp${t.totalHarga}'),
                            subtitle: Text(
                                '${t.tanggal}  •  ${t.metodePembayaran}'
                                '${t.pelanggan != null ? '  •  ${t.pelanggan!.namaPelanggan}' : ''}'),
                            trailing: Text(
                                '${t.detailTransaksis.length} item',
                                style: const TextStyle(color: Colors.grey)),
                            onTap: () => _showDetail(context, t),
                          ),
                        );
                      },
                    ),
    );
  }

  void _showDetail(BuildContext context, dynamic t) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Transaksi #${t.id}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tanggal: ${t.tanggal}'),
            Text('Metode: ${t.metodePembayaran}'),
            if (t.pelanggan != null)
              Text('Pelanggan: ${t.pelanggan!.namaPelanggan}'),
            const Divider(),
            ...t.detailTransaksis.map<Widget>((d) => ListTile(
                  dense: true,
                  title: Text(d.barang?.namaBarang ?? 'Barang #${d.idBarang}'),
                  subtitle: Text(
                      '${d.kuantitas} x Rp${d.hargaSatuan} = Rp${d.subTotal}'),
                )),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: Rp${t.totalHarga}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
