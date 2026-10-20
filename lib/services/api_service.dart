import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/barang_model.dart';
import '../models/pelanggan_model.dart';
import '../models/transaksi_model.dart';
import '../models/kasbon_model.dart';
import '../models/pembayaran_kasbon_model.dart';
import '../models/laporan_model.dart';
import '../models/barang_masuk_model.dart';

/// Service umum untuk semua endpoint API (selain Auth).
/// Semua request membutuhkan token Authorization.
class ApiService {
  final String token;

  ApiService({required this.token});

  Map<String, String> get _headers => ApiConfig.authHeaders(token);

  /// Helper: parse response body dan ambil data dari key 'data'
  dynamic _parseResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Terjadi kesalahan');
    }
  }

  // ===================== BARANG =====================

  Future<List<BarangModel>> fetchBarang() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barang}'),
      headers: _headers,
    );
    final data = _parseResponse(response) as List;
    return data.map((j) => BarangModel.fromJson(j)).toList();
  }

  Future<BarangModel> createBarang(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barang}'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return BarangModel.fromJson(_parseResponse(response));
  }

  Future<BarangModel> updateBarang(int id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barang}/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return BarangModel.fromJson(_parseResponse(response));
  }

  Future<void> deleteBarang(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barang}/$id'),
      headers: _headers,
    );
    _parseResponse(response);
  }

  // ===================== PELANGGAN =====================

  Future<List<PelangganModel>> fetchPelanggan() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pelanggan}'),
      headers: _headers,
    );
    final data = _parseResponse(response) as List;
    return data.map((j) => PelangganModel.fromJson(j)).toList();
  }

  Future<PelangganModel> createPelanggan(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pelanggan}'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return PelangganModel.fromJson(_parseResponse(response));
  }

  Future<PelangganModel> updatePelanggan(
      int id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pelanggan}/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return PelangganModel.fromJson(_parseResponse(response));
  }

  Future<void> deletePelanggan(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pelanggan}/$id'),
      headers: _headers,
    );
    _parseResponse(response);
  }

  // ===================== BARANG MASUK / RESTOK =====================

  Future<List<BarangMasukModel>> fetchBarangMasuk() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barangMasuk}'),
      headers: _headers,
    );
    final data = _parseResponse(response) as List;
    return data.map((j) => BarangMasukModel.fromJson(j)).toList();
  }

  Future<BarangMasukModel> createBarangMasuk(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barangMasuk}'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return BarangMasukModel.fromJson(_parseResponse(response));
  }

  Future<void> deleteBarangMasuk(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barangMasuk}/$id'),
      headers: _headers,
    );
    _parseResponse(response);
  }

  // ===================== TRANSAKSI =====================

  Future<List<TransaksiModel>> fetchTransaksi() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transaksi}'),
      headers: _headers,
    );
    final data = _parseResponse(response) as List;
    return data.map((j) => TransaksiModel.fromJson(j)).toList();
  }

  Future<TransaksiModel> createTransaksi(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transaksi}'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return TransaksiModel.fromJson(_parseResponse(response));
  }

  Future<TransaksiModel> showTransaksi(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transaksi}/$id'),
      headers: _headers,
    );
    return TransaksiModel.fromJson(_parseResponse(response));
  }

  // ===================== KASBON =====================

  Future<List<KasbonModel>> fetchKasbon({String? status}) async {
    var url = '${ApiConfig.baseUrl}${ApiConfig.kasbon}';
    if (status != null) url += '?status=$status';

    final response = await http.get(Uri.parse(url), headers: _headers);
    final data = _parseResponse(response) as List;
    return data.map((j) => KasbonModel.fromJson(j)).toList();
  }

  Future<KasbonModel> showKasbon(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.kasbon}/$id'),
      headers: _headers,
    );
    return KasbonModel.fromJson(_parseResponse(response));
  }

  // ===================== PEMBAYARAN KASBON =====================

  Future<List<PembayaranKasbonModel>> fetchPembayaranKasbon(
      int kasbonId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.kasbon}/$kasbonId/pembayaran'),
      headers: _headers,
    );
    final data = _parseResponse(response) as List;
    return data.map((j) => PembayaranKasbonModel.fromJson(j)).toList();
  }

  Future<PembayaranKasbonModel> createPembayaranKasbon(
      int kasbonId, int nominalBayar) async {
    final response = await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.kasbon}/$kasbonId/pembayaran'),
      headers: _headers,
      body: jsonEncode({'nominal_bayar': nominalBayar}),
    );
    return PembayaranKasbonModel.fromJson(_parseResponse(response));
  }

  // ===================== LAPORAN =====================

  Future<List<LaporanModel>> fetchLaporan(
      {String? tanggalMulai, String? tanggalSelesai}) async {
    var url = '${ApiConfig.baseUrl}${ApiConfig.laporan}';
    if (tanggalMulai != null && tanggalSelesai != null) {
      url += '?tanggal_mulai=$tanggalMulai&tanggal_selesai=$tanggalSelesai';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);
    final data = _parseResponse(response) as List;
    return data.map((j) => LaporanModel.fromJson(j)).toList();
  }

  Future<LaporanModel> fetchLaporanHariIni() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.laporanHariIni}'),
      headers: _headers,
    );
    return LaporanModel.fromJson(_parseResponse(response));
  }
}
