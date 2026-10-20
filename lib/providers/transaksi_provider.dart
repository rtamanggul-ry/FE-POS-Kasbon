import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';

class TransaksiProvider with ChangeNotifier {
  List<TransaksiModel> _list = [];
  bool _isLoading = false;
  String? _error;

  List<TransaksiModel> get list => _list;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTransaksi(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _list = await ApiService(token: token).fetchTransaksi();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTransaksi(
      String token, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final item = await ApiService(token: token).createTransaksi(data);
      _list.insert(0, item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
