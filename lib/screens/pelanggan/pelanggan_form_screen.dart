import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pelanggan_provider.dart';
import '../../models/pelanggan_model.dart';

class PelangganFormScreen extends StatefulWidget {
  final PelangganModel? pelanggan;

  const PelangganFormScreen({super.key, this.pelanggan});

  @override
  State<PelangganFormScreen> createState() => _PelangganFormScreenState();
}

class _PelangganFormScreenState extends State<PelangganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _hpCtrl;
  bool _loading = false;

  bool get isEdit => widget.pelanggan != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(
        text: widget.pelanggan?.namaPelanggan ?? '');
    _hpCtrl =
        TextEditingController(text: widget.pelanggan?.noHp ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final token = context.read<AuthProvider>().token!;
    final data = {
      'nama_pelanggan': _namaCtrl.text,
      'no_hp': _hpCtrl.text.isEmpty ? null : _hpCtrl.text,
    };

    final provider = context.read<PelangganProvider>();
    final navigator = Navigator.of(context);
    bool ok;

    if (isEdit) {
      ok = await provider.updatePelanggan(
          token, widget.pelanggan!.id, data);
    } else {
      ok = await provider.createPelanggan(token, data);
    }

    setState(() => _loading = false);

    if (ok) {
      navigator.pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEdit
                ? 'Pelanggan diperbarui'
                : 'Pelanggan ditambahkan')));
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
          title: Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nama Pelanggan'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hpCtrl,
                decoration:
                    const InputDecoration(labelText: 'No. HP (opsional)'),
                keyboardType: TextInputType.phone,
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
