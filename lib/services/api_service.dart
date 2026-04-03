import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> postApi({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    final cookie = await SecureStorage.getCookie();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
      },
      body: jsonEncode(body),
    );

    // ✅ Handle unauthorized explicitly
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Unauthorized. Please login again.");
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    return jsonDecode(response.body);
  }

  static Future<dynamic> getApi({
    required String endpoint,
    Map<String, String>? queryParams,
  }) async {
    // Build the URL with optional query parameters
    final uri = Uri.parse(
      ApiConstants.baseUrl + endpoint,
    ).replace(queryParameters: queryParams);

    final cookie = await SecureStorage.getCookie();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
      },
    );

    // ✅ Handle unauthorized explicitly
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Unauthorized. Please login again.");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    return jsonDecode(response.body);
  }
}
