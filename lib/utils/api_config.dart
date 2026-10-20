import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  // Auth
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';

  // Barang
  static const String barang = '/barang';

  // Pelanggan
  static const String pelanggan = '/pelanggan';

  // Barang Masuk / Restok
  static const String barangMasuk = '/barang-masuk';

  // Transaksi
  static const String transaksi = '/transaksi';

  // Kasbon
  static const String kasbon = '/kasbon';

  // Laporan
  static const String laporan = '/laporan';
  static const String laporanHariIni = '/laporan/hari-ini';

  static Map<String, String> get headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static Map<String, String> authHeaders(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
