import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:http/http.dart' as http;
import '../utils/local_db.dart';
import '../utils/secure_storage.dart';

class InstallTyreService {

  Future<bool> submitInspection(Map<String, dynamic> data) async {
    await _updateLocalDb(data);

    final isOnline = await _isOnline();

    if (!isOnline) {
      await _savePendingInstall(data);
      print("📴 Offline — queued locally for tireId=${data['tireId']}");
      return true;
    }

    try {
      final success = await _callApi(data);
      if (success) {
        print("✅ API install success for tireId=${data['tireId']}");
        return true;
      }
    } catch (e) {
      print("⚠️ API failed — saving locally: $e");
    }

    await _savePendingInstall(data);
    print("📦 Saved locally (will sync later) — tireId=${data['tireId']}");
    return true;
  }

  // ══════════════════════════════════════════════
  // 🗄️ Local DB Update
  // ══════════════════════════════════════════════
  Future<void> _updateLocalDb(Map<String, dynamic> data) async {
    try {
      final tireId        = data['tireId'] as int?;
      final wheelPos      = data['wheelPosition'] as String?;
      final dispositionId = data['dispositionId'] as int? ?? 7;

      if (tireId == null || tireId <= 0) return;

      await LocalDatabaseService.updateTireDisposition(
        tireId:          tireId,
        dispositionId:   dispositionId,
        dispositionName: 'installed',
        wheelPosition:   wheelPos,
      );
      print("✅ Local DB updated: tireId=$tireId marked as installed");
    } catch (e) {
      print("⚠️ Local DB update failed: $e");
    }
  }


  Future<void> _savePendingInstall(Map<String, dynamic> data) async {
    try {
      final db = await LocalDatabaseService.database;
      await db.insert('pending_installs', {
        'payload':       jsonEncode(data),
        'tireId':        data['tireId'],
        'vehicleId':     data['vehicleId'],
        'wheelPosition': data['wheelPosition'],
        'tireSerialNo':  data['tireSerialNo'],
        'createdAt':     DateTime.now().toIso8601String(),
        'syncStatus':    'pending',
      });
      print("✅ Pending install saved: tireId=${data['tireId']} wheelPos=${data['wheelPosition']}");
    } catch (e) {
      print("❌ Pending save error: $e");
    }
  }

  // ══════════════════════════════════════════════
  // 🌐 API Call
  // ══════════════════════════════════════════════
  Future<bool> _callApi(Map<String, dynamic> data) async {
    final cookie = await SecureStorage.getCookie();
    if (cookie == null || cookie.isEmpty) {
      throw Exception("Session expired.");
    }

    final payload = Map<String, dynamic>.from(data);
    payload.remove("inspectionId");
    payload.remove("removalReasonId");
    payload.remove("rimDispositionId");
    payload.remove("mountedRimId");
    payload.remove("middleTread");
    payload.remove("imagesLocation");

    if (payload.containsKey("inspectionDate") && payload["inspectionDate"] is DateTime) {
      payload["inspectionDate"] =
          '${(payload["inspectionDate"] as DateTime).toUtc().toIso8601String().split('.').first}Z';
    }

    final url = Uri.parse("${ApiConstants.baseUrl}/api/Inspection/InstallTire");
    final headers = {
      "Content-Type": "application/json",
      "Accept":       "application/json",
      "Cookie":       cookie,
    };

    print("📤 FINAL PAYLOAD => ${jsonEncode(payload)}");

    final response = await http.put(url, headers: headers, body: jsonEncode(payload));

    print("📡 STATUS: ${response.statusCode}");
    print("📥 BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded["didError"] == false) return true;
      throw Exception(decoded["errorMessage"] ?? "Backend error");
    }

    if (response.statusCode == 401) {
      await SecureStorage.clearCookie();
      throw Exception("Session expired.");
    }

    // 500 ya koi bhi error — exception throw karo taaki caller queue mein daale
    throw Exception("Failed with status ${response.statusCode}: ${response.body}");
  }

  // ══════════════════════════════════════════════
  // 🔄 Pending Sync (baad mein call karo)
  // ══════════════════════════════════════════════
  Future<Map<String, int>> syncPendingInstalls() async {
    int successCount = 0;
    int failCount    = 0;

    final isOnline = await _isOnline();
    if (!isOnline) {
      return {
        'success': 0,
        'failed':  0,
        'pending': await LocalDatabaseService.getPendingInstallsCount(),
      };
    }

    final pending = await LocalDatabaseService.getPendingInstalls();
    print("🔄 Syncing ${pending.length} pending installs...");

    for (final item in pending) {
      try {
        final payload = jsonDecode(item['payload'] as String) as Map<String, dynamic>;
        final success = await _callApi(payload);
        if (success) {
          await LocalDatabaseService.markInstallSynced(item['id'] as int);
          successCount++;
          print("✅ Synced id=${item['id']}");
        }
      } catch (e) {
        failCount++;
        print("❌ Sync failed id=${item['id']}: $e");
      }
    }

    return {
      'success': successCount,
      'failed':  failCount,
      'pending': await LocalDatabaseService.getPendingInstallsCount(),
    };
  }

  Future<bool> _isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }
}
