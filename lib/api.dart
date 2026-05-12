import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../product.dart';
import '../user.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();

  // ── Token ──────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // ── Header dengan Bearer Token ─────────────────────────────
  static Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Login ──────────────────────────────────────────────────
  static Future<User> login(String nim) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': nim,
        'password': nim,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final user = User.fromJson(data);
      await saveToken(user.token);
      return user;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  // ── Get Produk ─────────────────────────────────────────────
  static Future<List<Product>> getProducts() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: _authHeaders(token),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List products = data['data']['products'];
      return products.map((p) => Product.fromJson(p)).toList();
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil produk');
    }
  }

  // ── Tambah Produk ──────────────────────────────────────────
  static Future<void> createProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal menyimpan produk');
    }
  }

  // ── Hapus Produk ───────────────────────────────────────────
  static Future<void> deleteProduct(int id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus produk');
    }
  }
}