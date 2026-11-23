import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const baseUrl = 'http://localhost:8080';
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<http.Response> get(String endpoint) =>
      http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers);

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) =>
      http.post(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body));

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) =>
      http.put(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body));

  static Future<http.Response> patch(String endpoint) =>
      http.patch(Uri.parse('$baseUrl$endpoint'), headers: _headers);

  static Future<http.Response> delete(String endpoint) =>
      http.delete(Uri.parse('$baseUrl$endpoint'), headers: _headers);
}