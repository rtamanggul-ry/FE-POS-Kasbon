import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../providers/pelanggan_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../models/barang_model.dart';
import '../../models/pelanggan_model.dart';

/// Item di keranjang belanja (sebelum dikirim ke API)
class CartItem {
  final BarangModel barang;
  int kuantitas;

  CartItem({required this.barang, this.kuantitas = 1});

  int get subTotal => barang.hargaJual * kuantitas;
}

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final List<CartItem> _cart = [];
  String _metode = 'Tunai';
  PelangganModel? _selectedPelanggan;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<BarangProvider>().fetchBarang(token);
        context.read<PelangganProvider>().fetchPelanggan(token);
      }
    });
  }

  int get totalHarga => _cart.fold(0, (sum, item) => sum + item.subTotal);

  void _addToCart(BarangModel barang) {
    final existing = _cart.indexWhere((c) => c.barang.id == barang.id);
    setState(() {
      if (existing != -1) {
        _cart[existing].kuantitas++;
      } else {
        _cart.add(CartItem(barang: barang));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  Future<void> _submitTransaksi() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keranjang masih kosong')));
      return;
    }

    if (_metode == 'Kredit' && _selectedPelanggan == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih pelanggan untuk pembayaran Kredit')));
      return;
    }

    setState(() => _submitting = true);

    final token = context.read<AuthProvider>().token!;
    final data = {
      'metode_pembayaran': _metode,
      'id_pelanggan': _metode == 'Kredit' ? _selectedPelanggan!.id : null,
      'items': _cart
          .map((c) =>
              {'id_barang': c.barang.id, 'kuantitas': c.kuantitas})
          .toList(),
    };

    final navigator = Navigator.of(context);
    final ok =
        await context.read<TransaksiProvider>().createTransaksi(token, data);

    setState(() => _submitting = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil!')));
      navigator.pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              context.read<TransaksiProvider>().error ?? 'Gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final barangList = context.watch<BarangProvider>().list;
    final pelangganList = context.watch<PelangganProvider>().list;

    return Scaffold(
      appBar: AppBar(title: const Text('Kasir / POS')),
      body: Column(
        children: [
          // Pilih barang
          Expanded(
            flex: 3,
            child: barangList.isEmpty
                ? const Center(child: Text('Tidak ada barang'))
                : ListView.builder(
                    itemCount: barangList.length,
                    itemBuilder: (_, i) {
                      final b = barangList[i];
                      return ListTile(
                        title: Text(b.namaBarang),
                        subtitle: Text(
                            'Rp${b.hargaJual}  |  Stok: ${b.stok}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: b.stok > 0
                              ? () => _addToCart(b)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          const Divider(thickness: 2),
          // Keranjang
          Expanded(
            flex: 2,
            child: _cart.isEmpty
                ? const Center(
                    child: Text('Keranjang kosong',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (_, i) {
                      final c = _cart[i];
                      return ListTile(
                        dense: true,
                        title: Text(c.barang.namaBarang),
                        subtitle: Text(
                            '${c.kuantitas} x Rp${c.barang.hargaJual} = Rp${c.subTotal}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              onPressed: () {
                                setState(() {
                                  if (c.kuantitas > 1) {
                                    c.kuantitas--;
                                  } else {
                                    _cart.removeAt(i);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 20),
                              onPressed: () =>
                                  setState(() => c.kuantitas++),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                              onPressed: () => _removeFromCart(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Footer: Total + Metode + Submit
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Rp$totalHarga',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Metode: '),
                    ChoiceChip(
                      label: const Text('Tunai'),
                      selected: _metode == 'Tunai',
                      onSelected: (_) =>
                          setState(() => _metode = 'Tunai'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Kredit'),
                      selected: _metode == 'Kredit',
                      onSelected: (_) =>
                          setState(() => _metode = 'Kredit'),
                    ),
                  ],
                ),
                if (_metode == 'Kredit') ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PelangganModel>(
                    initialValue: _selectedPelanggan,
                    decoration:
                        const InputDecoration(labelText: 'Pilih Pelanggan'),
                    items: pelangganList
                        .map((p) => DropdownMenuItem(
                            value: p, child: Text(p.namaPelanggan)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedPelanggan = v),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _submitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _submitTransaksi,
                          icon: const Icon(Icons.check),
                          label: const Text('Proses Transaksi'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
