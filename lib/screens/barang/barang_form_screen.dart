import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../models/barang_model.dart';

class BarangFormScreen extends StatefulWidget {
  final BarangModel? barang; // null = tambah, ada = edit

  const BarangFormScreen({super.key, this.barang});

  @override
  State<BarangFormScreen> createState() => _BarangFormScreenState();
}

class _BarangFormScreenState extends State<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _modalCtrl;
  late final TextEditingController _jualCtrl;
  late final TextEditingController _stokCtrl;
  bool _loading = false;

  bool get isEdit => widget.barang != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl =
        TextEditingController(text: widget.barang?.namaBarang ?? '');
    _modalCtrl = TextEditingController(
        text: widget.barang != null ? widget.barang!.hargaModal.toString() : '');
    _jualCtrl = TextEditingController(
        text: widget.barang != null ? widget.barang!.hargaJual.toString() : '');
    _stokCtrl = TextEditingController(
        text: widget.barang != null ? widget.barang!.stok.toString() : '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final token = context.read<AuthProvider>().token!;
    final data = {
      'nama_barang': _namaCtrl.text,
      'harga_modal': int.tryParse(_modalCtrl.text) ?? 0,
      'harga_jual': int.tryParse(_jualCtrl.text) ?? 0,
      'stok': int.tryParse(_stokCtrl.text) ?? 0,
    };

    final provider = context.read<BarangProvider>();
    final navigator = Navigator.of(context);
    bool ok;

    if (isEdit) {
      ok = await provider.updateBarang(token, widget.barang!.id, data);
    } else {
      ok = await provider.createBarang(token, data);
    }

    setState(() => _loading = false);

    if (ok) {
      navigator.pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEdit ? 'Barang diperbarui' : 'Barang ditambahkan')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? 'Gagal menyimpan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nama Barang'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modalCtrl,
                decoration:
                    const InputDecoration(labelText: 'Harga Modal'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jualCtrl,
                decoration:
                    const InputDecoration(labelText: 'Harga Jual'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stokCtrl,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEdit ? 'Update' : 'Simpan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
