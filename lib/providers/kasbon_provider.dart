import 'package:flutter/material.dart';
import '../models/kasbon_model.dart';
import '../models/pembayaran_kasbon_model.dart';
import '../services/api_service.dart';

class KasbonProvider with ChangeNotifier {
  List<KasbonModel> _list = [];
  bool _isLoading = false;
  String? _error;

  List<KasbonModel> get list => _list;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchKasbon(String token, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _list = await ApiService(token: token).fetchKasbon(status: status);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<KasbonModel?> showKasbon(String token, int id) async {
    try {
      return await ApiService(token: token).showKasbon(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<List<PembayaranKasbonModel>> fetchPembayaran(
      String token, int kasbonId) async {
    try {
      return await ApiService(token: token)
          .fetchPembayaranKasbon(kasbonId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return [];
    }
  }

  Future<bool> bayarKasbon(
      String token, int kasbonId, int nominalBayar) async {
    try {
      await ApiService(token: token)
          .createPembayaranKasbon(kasbonId, nominalBayar);
      // Refresh list setelah bayar
      await fetchKasbon(token);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
