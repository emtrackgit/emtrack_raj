import 'dart:convert';
import 'dart:developer';
import 'package:emtrack/create_tyre/create_tyre_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CreateTyreService {
  // 🔹 BASE API
  static const String _url = ApiConstants.baseUrl + ApiConstants.createTyre;

  static int? _extractInsertedId(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is int) return decoded;
      if (decoded is Map) {
        dynamic pick(dynamic v) {
          if (v is int) return v;
          if (v is num) return v.toInt();
          if (v is String) return int.tryParse(v);
          return null;
        }

        final direct = pick(decoded['insertedId']) ??
            pick(decoded['tireId']) ??
            pick(decoded['id']);
        if (direct is int) return direct;

        final model = decoded['model'];
        if (model is int) return model;
        if (model is Map) {
          final m = pick(model['insertedId']) ??
              pick(model['tireId']) ??
              pick(model['id']);
          if (m is int) return m;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> saveTyre(CreateTyreModel model) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      final body = _sanitizeTyreJson(model.toJson());
      body.remove("tireId");
      body.remove("vehicleId");
      body.remove("mountedRimId");
      log(jsonEncode(body));

      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      if (isOffline) {
        final localId = -DateTime.now().millisecondsSinceEpoch;
        final clientRequestId = sha256
            .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:${jsonEncode(body)}"))
            .toString();

        final payload = Map<String, dynamic>.from(body);
        payload['tireId'] = localId;
        payload['syncStatus'] = 'pending';
        payload['_localOnly'] = true;
        payload['dispositionName'] = payload['dispositionName'] ?? 'Inventory';
        payload['dispositionId'] = payload['dispositionId'] ?? 8;

        await LocalDatabaseService.enqueueRequest(
          method: 'POST',
          endpoint: ApiConstants.createTyre,
          payload: body,
          entityType: 'tyre_create',
          localEntityId: localId,
          clientRequestId: clientRequestId,
        );

        final existing = await LocalStorageService.getTyres();
        existing.insert(0, payload);
        await LocalStorageService.saveTyres(existing);
        await LocalDatabaseService.saveTires([payload]);

        print("✅ Offline tyre saved locally: tireId=$localId");
        return true;
      }

      print("COOKIE => $cookie");
      print("REQUEST => ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie,
        },
        body: jsonEncode(body),
      );

      print("STATUS => ${response.statusCode}");
      print("BODY => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final insertedId = _extractInsertedId(response.body);
        if (insertedId != null && insertedId > 0) {
          final payload = Map<String, dynamic>.from(body);
          payload['tireId'] = insertedId;
          payload['syncStatus'] = 'synced';
          payload['_localOnly'] = false;
          payload['dispositionName'] = payload['dispositionName'] ?? 'Inventory';
          payload['dispositionId'] = payload['dispositionId'] ?? 8;

          final existing = await LocalStorageService.getTyres();
          existing.insert(0, payload);
          await LocalStorageService.saveTyres(existing);
          await LocalDatabaseService.saveTires([payload]);

          print("✅ Tyre saved locally (online): tireId=$insertedId");
        }
        return true;
      }

      if (response.statusCode == 401) {
        await SecureStorage.clearCookie();
        throw Exception("Session expired. Please login again.");
      }

      if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        // Safely extract first error message if possible
        if (decoded is Map && decoded.isNotEmpty) {
          final firstValue = decoded.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            throw Exception(firstValue.first.toString());
          }
        }
        throw Exception("Bad request: ${response.body}");
      }

      throw Exception("API failed: ${response.statusCode}");
    } catch (e) {
      print("❌ ERROR => $e");
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
            key.contains("Id") ||
                key.contains("Miles") ||
                key.contains("Tread") ||
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
