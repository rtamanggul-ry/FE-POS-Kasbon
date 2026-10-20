import 'package:flutter/material.dart';
import '../models/barang_model.dart';
import '../services/api_service.dart';

class BarangProvider with ChangeNotifier {
  List<BarangModel> _list = [];
  bool _isLoading = false;
  String? _error;

  List<BarangModel> get list => _list;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBarang(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _list = await ApiService(token: token).fetchBarang();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBarang(String token, Map<String, dynamic> data) async {
    try {
      final item = await ApiService(token: token).createBarang(data);
      _list.insert(0, item);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBarang(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await ApiService(token: token).updateBarang(id, data);
      final idx = _list.indexWhere((b) => b.id == id);
      if (idx != -1) _list[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBarang(String token, int id) async {
    try {
      await ApiService(token: token).deleteBarang(id);
      _list.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
