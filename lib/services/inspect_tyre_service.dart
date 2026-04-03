import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/local_db.dart';
import '../utils/local_storage_service.dart';
import '../utils/secure_storage.dart';
import 'global_logout_handler.dart';

class InspectTyreService {
  final String baseUrl = ApiConstants.baseUrl;

  // =========================================================
  // 🔹 PUT : Inspect Tire
  // =========================================================
  Future<bool> submitInspection(Map<String, dynamic> data) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Authentication cookie missing");
      }

      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      if (isOffline) {
        final body = Map<String, dynamic>.from(data);
        final tireId = body['tireId'] as int?;
        final clientRequestId = sha256
            .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:${jsonEncode(body)}"))
            .toString();

        await LocalDatabaseService.enqueueRequest(
          method: 'PUT',
          endpoint: '/api/Inspection/InspectTire',
          payload: body,
          entityType: 'inspect_tyre',
          localEntityId: tireId,
          clientRequestId: clientRequestId,
        );

        if (tireId != null && tireId != 0) {
          await LocalDatabaseService.updateTireMetrics(
            tireId: tireId,
            currentPressure: (body['currentPressure'] as num?)?.toDouble(),
            outsideTread: (body['outsideTread'] as num?)?.toDouble(),
            insideTread: (body['insideTread'] as num?)?.toDouble(),
            currentTreadDepth: (body['currentTreadDepth'] as num?)?.toDouble(),
          );
        }

        final tyres = await LocalStorageService.getTyres();
        final idx = tyres.indexWhere((e) => (e['tireId'] as int?) == tireId);
        if (idx >= 0) {
          tyres[idx] = {
            ...tyres[idx],
            'currentPressure': body['currentPressure'],
            'outsideTread': body['outsideTread'],
            'insideTread': body['insideTread'],
            'currentTreadDepth': body['currentTreadDepth'],
            'syncStatus': 'pending',
            '_localOnly': true,
          };
          await LocalStorageService.saveTyres(tyres);
        }

        print("✅ Offline inspection queued for tireId=$tireId");
        return true;
      }

      final url = Uri.parse('$baseUrl/api/Inspection/InspectTire');

      // 🔍 Debug request body
      print("📤 REQUEST BODY: ${jsonEncode(data)}");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie,
        },
        body: jsonEncode(data),
      );

      print("📡 STATUS CODE: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      // ✅ SUCCESS
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          if (decoded["didError"] == false) {
            return true;
          } else {
            throw Exception(decoded["errorMessage"] ?? "Inspection failed");
          }
        }
        return true;
      }

      // 🔐 AUTH ERROR
      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        throw Exception("Session expired. Please login again.");
      }

      // ⚠️ VALIDATION ERROR
      if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded["errorMessage"] ?? "Validation failed");
      }

      // 🔥 SERVER ERROR
      if (response.statusCode >= 500) {
        throw Exception(
          "Server error (${response.statusCode}). Try again later.",
        );
      }

      throw Exception("Failed to submit inspection (${response.statusCode})");
    } catch (e) {
      print("❌ Inspect API Error: $e");
      rethrow;
    }
  }

  // =========================================================
  // 🔹 GET : Tire Details by TireId
  // =========================================================
  Future<Map<String, dynamic>> getTireById(int tireId) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Authentication cookie missing");
      }

      final url = Uri.parse('$baseUrl/api/Tire/GetById/$tireId');

      final response = await http.get(
        url,
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      print("📡 GET STATUS: ${response.statusCode}");
      print("📥 GET BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded["didError"] == false) {
          return decoded["model"] ?? {};
        }

        throw Exception(decoded["errorMessage"] ?? "Failed to load tire");
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        throw Exception("Session expired. Please login again.");
      }

      throw Exception("Failed to fetch tire (${response.statusCode})");
    } catch (e) {
      print("❌ Get Tire API Error: $e");
      final cached = await LocalDatabaseService.getTireById(tireId);
      if (cached != null) {
        print("✅ Tire loaded from SQLite cache: tireId=$tireId");
        return cached;
      }
      final tyres = await LocalStorageService.getTyres();
      for (final t in tyres) {
        if ((t['tireId'] as int?) == tireId) {
          print("✅ Tire loaded from SharedPreferences cache: tireId=$tireId");
          return t;
        }
      }
      rethrow;
    }
  }
}
