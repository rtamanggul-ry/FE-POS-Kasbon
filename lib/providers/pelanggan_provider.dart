import 'package:flutter/material.dart';
import '../models/pelanggan_model.dart';
import '../services/api_service.dart';

class PelangganProvider with ChangeNotifier {
  List<PelangganModel> _list = [];
  bool _isLoading = false;
  String? _error;

  List<PelangganModel> get list => _list;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPelanggan(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _list = await ApiService(token: token).fetchPelanggan();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPelanggan(
      String token, Map<String, dynamic> data) async {
    try {
      final item = await ApiService(token: token).createPelanggan(data);
      _list.insert(0, item);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePelanggan(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final updated =
          await ApiService(token: token).updatePelanggan(id, data);
      final idx = _list.indexWhere((p) => p.id == id);
      if (idx != -1) _list[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePelanggan(String token, int id) async {
    try {
      await ApiService(token: token).deletePelanggan(id);
      _list.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
