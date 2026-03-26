import 'dart:convert';
import 'dart:developer';
import 'package:emtrack/create_tyre/create_tyre_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? detail;
  final dynamic errors;
  final Map<String, String> headers;
  final String rawBody;
  final String? requestBodyJson;
  final String? endpoint;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.rawBody,
    required this.headers,
    this.detail,
    this.errors,
    this.requestBodyJson,
    this.endpoint,
  });

  @override
  String toString() {
    final parts = <String>[];
    parts.add('HTTP $statusCode');
    if (message.trim().isNotEmpty) parts.add(message.trim());
    if (detail != null && detail.toString().trim().isNotEmpty) {
      parts.add(detail.toString().trim());
    }
    if (errors != null && errors.toString().trim().isNotEmpty) {
      parts.add(errors.toString().trim());
    }
    final trace = headers['trace-id'] ??
        headers['request-id'] ??
        headers['x-correlation-id'] ??
        headers['traceparent'];
    if (trace != null && trace.trim().isNotEmpty) {
      parts.add('Trace: $trace');
    }
    return parts.join(' | ');
  }
}

class CreateTyreService {
  // 🔹 BASE API
  static const String _url = ApiConstants.baseUrl + ApiConstants.createTyre;

  static Map<String, String> _lowerHeaders(Map<String, String> h) {
    final out = <String, String>{};
    h.forEach((k, v) => out[k.toLowerCase()] = v);
    return out;
  }

  static ApiException _buildApiException(
    http.Response response, {
    String? requestBodyJson,
    String? endpoint,
  }) {
    final headers = _lowerHeaders(response.headers);
    String msg = 'Server error, please try again later.';
    String? detail;
    dynamic errors;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final m = decoded['message'];
        if (m != null && m.toString().trim().isNotEmpty) {
          msg = m.toString();
        }
        detail = decoded['detail']?.toString();
        errors = decoded['errors'];
        final traceId = decoded['traceId']?.toString();
        if (traceId != null && traceId.trim().isNotEmpty) {
          headers.putIfAbsent('trace-id', () => traceId);
        }
      }
    } catch (_) {}

    return ApiException(
      statusCode: response.statusCode,
      message: msg,
      detail: detail,
      errors: errors,
      rawBody: response.body,
      headers: headers,
      requestBodyJson: requestBodyJson,
      endpoint: endpoint,
    );
  }

  static Future<bool> saveTyre(CreateTyreModel model) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      final body = _sanitizeTyreJson(model.toJson());
      body["tireId"] = body["tireId"] ?? 0;
      body["vehicleId"] = body["vehicleId"] ?? 0;
      body["mountedRimId"] = body["mountedRimId"] ?? 0;
      final requestJson = jsonEncode(body);
      log(requestJson);

      print("🍪 COOKIE => $cookie");
      print("📤 CREATE TYRE REQUEST => $requestJson");

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie,
        },
        body: jsonEncode(body),
      );

      print("📥 STATUS => ${response.statusCode}");
      print("📥 BODY => ${response.body}");
      final responseHeaders = _lowerHeaders(response.headers);
      final trace = responseHeaders['trace-id'] ??
          responseHeaders['request-id'] ??
          responseHeaders['x-correlation-id'] ??
          responseHeaders['traceparent'];
      if (trace != null && trace.trim().isNotEmpty) {
        print("🧾 TRACE => $trace");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      if (response.statusCode == 401) {
        await SecureStorage.clearCookie();
        throw Exception("Session expired. Please login again.");
      }

      if (response.statusCode == 400) {
        throw _buildApiException(
          response,
          requestBodyJson: requestJson,
          endpoint: ApiConstants.createTyre,
        );
      }

      if (response.statusCode >= 500) {
        throw _buildApiException(
          response,
          requestBodyJson: requestJson,
          endpoint: ApiConstants.createTyre,
        );
      }

      throw Exception("API failed: ${response.statusCode}");
    } catch (e) {
      print("❌ CreateTyreService ERROR => $e");
      rethrow;
    }
  }

  // 🔹 Replace null numeric fields with 0
  static Map<String, dynamic> _sanitizeTyreJson(Map<String, dynamic> json) {
    final sanitized = <String, dynamic>{};

    json.forEach((key, value) {
      if (value == null) {
        // Default numeric fields to 0
        sanitized[key] =
            key.contains("Miles") ||
                key.contains("Hours") ||
                key.contains("Tread") ||
                key.contains("Pressure") ||
                key.contains("Cost") ||
                key.contains("Adjustment")
            ? 0
            : null; // keep others as null
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }
}
