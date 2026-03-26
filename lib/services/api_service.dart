import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static dynamic _tryDecodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return body;
    }
  }

  static Future<dynamic> postApi({
    required String endpoint,
    required dynamic body,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    final headers = await SecureStorage.authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Unauthorized. Please login again.");
    }
    return _tryDecodeBody(response.body);
  }

  static Future<dynamic> getApi({
    required String endpoint,
    Map<String, String>? queryParams,
  }) async {
    // Build the URL with optional query parameters
    final uri = Uri.parse(
      ApiConstants.baseUrl + endpoint,
    ).replace(queryParameters: queryParams);

    final headers = await SecureStorage.authHeaders();

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Unauthorized. Please login again.");
    }

    return _tryDecodeBody(response.body);
  }

  static Future<dynamic> putApi({
    required String endpoint,
    required dynamic body,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    final headers = await SecureStorage.authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Unauthorized. Please login again.");
    }

    return _tryDecodeBody(response.body);
  }
}
