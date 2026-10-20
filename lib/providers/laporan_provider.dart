import 'package:flutter/material.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';

class LaporanProvider with ChangeNotifier {
  List<LaporanModel> _list = [];
  LaporanModel? _hariIni;
  bool _isLoading = false;
  String? _error;

  List<LaporanModel> get list => _list;
  LaporanModel? get hariIni => _hariIni;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLaporanHariIni(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hariIni = await ApiService(token: token).fetchLaporanHariIni();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLaporan(String token,
      {String? tanggalMulai, String? tanggalSelesai}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _list = await ApiService(token: token).fetchLaporan(
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
