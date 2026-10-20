import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class AuthService {
  /// Login ke Laravel API menggunakan username & password
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(
            responseData['message'] ?? 'Username atau Password salah');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal menghubungi server: $e');
    }
  }

  Future<void> logout(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}');

    try {
      await http.post(
        url,
        headers: ApiConfig.authHeaders(token),
      );
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }
}
