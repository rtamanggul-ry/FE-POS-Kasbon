import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../auth/login_screen.dart';
import '../barang/barang_list_screen.dart';
import '../barang_masuk/barang_masuk_screen.dart';
import '../kasbon/kasbon_list_screen.dart';
import '../laporan/laporan_screen.dart';
import '../pelanggan/pelanggan_list_screen.dart';
import '../transaksi/transaksi_list_screen.dart';
import '../transaksi/transaksi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _blue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSummary());
  }

  Future<void> _loadSummary() async {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      await context.read<LaporanProvider>().fetchLaporanHariIni(token);
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthProvider>().user?.username;
    final laporan = context.watch<LaporanProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onDestinationSelected: _selectNavigation,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/warung_mami_tou.jpg',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7EFFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: _blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Warung Mami Tou',
                              style: TextStyle(
                                color: Color(0xFF17243A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              username == null || username.isEmpty
                                  ? 'Selamat datang'
                                  : 'Halo, $username',
                              style: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Keluar',
                        onPressed: _logout,
                        style: IconButton.styleFrom(
                          foregroundColor: const Color(0xFF40516B),
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ringkasan hari ini',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF17243A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Muat ulang',
                        onPressed: laporan.isLoading ? null : _loadSummary,
                        icon: const Icon(Icons.refresh_rounded),
                        color: _blue,
                      ),
                    ],
                  ),
                  if (laporan.isLoading && laporan.hariIni == null)
                    const _SummaryLoadingCard()
                  else if (laporan.error != null && laporan.hariIni == null)
                    _SummaryMessage(
                      message: 'Ringkasan belum dapat dimuat. ${laporan.error}',
                      onRetry: _loadSummary,
                    )
                  else if (laporan.hariIni == null)
                    _SummaryMessage(
                      message: 'Belum ada data ringkasan hari ini.',
                      onRetry: _loadSummary,
                      showRetry: false,
                    )
                  else ...[
                    Text(
                      'Tanggal ${laporan.hariIni!.tanggalLaporan}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (laporan.isLoading)
                      const LinearProgressIndicator(minHeight: 2),
                    if (laporan.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Gagal memperbarui ringkasan: ${laporan.error}',
                          style: const TextStyle(
                            color: Color(0xFFB93832),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 600 ? 4 : 2;
                        const spacing = 12.0;
                        final width =
                            (constraints.maxWidth - (columns - 1) * spacing) /
                            columns;
                        final report = laporan.hariIni!;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            _SummaryCard(
                              width: width,
                              label: 'Pendapatan tunai',
                              value: report.totalPendapatanTunai,
                              icon: Icons.payments_outlined,
                            ),
                            _SummaryCard(
                              width: width,
                              label: 'Kasbon baru',
                              value: report.totalKasbonBaru,
                              icon: Icons.credit_card_outlined,
                            ),
                            _SummaryCard(
                              width: width,
                              label: 'Pembayaran kasbon',
                              value: report.totalPembayaranKasbon,
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                            _SummaryCard(
                              width: width,
                              label: 'Pengeluaran restok',
                              value: report.totalPengeluaranRestok,
                              icon: Icons.inventory_2_outlined,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                  Text(
                    'Menu operasional',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF17243A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 680 ? 4 : 2;
                      const spacing = 12.0;
                      final width =
                          (constraints.maxWidth - (columns - 1) * spacing) /
                          columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _MenuCard(
                            width: width,
                            icon: Icons.point_of_sale_rounded,
                            label: 'Kasir / POS',
                            description: 'Buat transaksi penjualan',
                            primary: true,
                            onTap: () => _open(const TransaksiScreen()),
                          ),
                          _MenuCard(
                            width: width,
                            icon: Icons.inventory_2_outlined,
                            label: 'Barang',
                            description: 'Kelola daftar barang',
                            onTap: () => _open(const BarangListScreen()),
                          ),
                          _MenuCard(
                            width: width,
                            icon: Icons.people_outline_rounded,
                            label: 'Pelanggan',
                            description: 'Kelola data pelanggan',
                            onTap: () => _open(const PelangganListScreen()),
                          ),
                          _MenuCard(
                            width: width,
                            icon: Icons.local_shipping_outlined,
                            label: 'Barang masuk',
                            description: 'Catat restok barang',
                            onTap: () => _open(const BarangMasukScreen()),
                          ),
                          _MenuCard(
                            width: width,
                            icon: Icons.receipt_long_outlined,
                            label: 'Riwayat transaksi',
                            description: 'Lihat transaksi tersimpan',
                            onTap: () => _open(const TransaksiListScreen()),
                          ),
                          _MenuCard(
                            width: width,
                            icon: Icons.credit_score_outlined,
                            label: 'Kasbon',
                            description: 'Lihat dan kelola pembayaran',
                            onTap: () => _open(const KasbonListScreen()),
                          ),
                          _MenuCard(
                            width: width,
                            icon: Icons.bar_chart_rounded,
                            label: 'Laporan',
                            description: 'Ringkasan dan rentang tanggal',
                            onTap: () => _open(const LaporanScreen()),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _selectNavigation(int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        _open(const TransaksiScreen());
        break;
      case 2:
        _open(const BarangListScreen());
        break;
      case 3:
        _open(const KasbonListScreen());
        break;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: const Color(0xFF2563EB)),
              ),
              const Spacer(),
              const Icon(
                Icons.north_east_rounded,
                size: 16,
                color: Color(0xFF9AA7B8),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatRupiah(value),
              style: const TextStyle(
                color: Color(0xFF17243A),
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.primary = false,
  });

  final double width;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final background = primary ? const Color(0xFF2563EB) : Colors.white;
    final foreground = primary ? Colors.white : const Color(0xFF17243A);
    final secondary = primary ? Colors.white70 : const Color(0xFF718096);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 144),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primary
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE7ECF3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: primary ? Colors.white : const Color(0xFF2563EB),
                size: 24,
              ),
              const SizedBox(height: 18),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: secondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLoadingCard extends StatelessWidget {
  const _SummaryLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _SummaryMessage extends StatelessWidget {
  const _SummaryMessage({
    required this.message,
    required this.onRetry,
    this.showRetry = true,
  });

  final String message;
  final Future<void> Function() onRetry;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          if (showRetry)
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

String _formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${amount < 0 ? '-' : ''}Rp $grouped';
}
