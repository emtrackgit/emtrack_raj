import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:emtrack/models/masterDataMobileModel/Tire_remove_reason_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_desposition_model.dart';
import 'package:emtrack/models/masterDataMobileModel/master_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class RemoveTyreService {
  // ==========================================================
  // ✅ SUBMIT REMOVE TYRE (Cookie-based auth)
  // ==========================================================
  Future<bool> submitRemoveTyre(Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/api/Inspection/RemoveTire");
    final cookies = await SecureStorage.getCookie(); // ✅ get cookie

    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);
    if (isOffline) {
      final tireId = data['tireId'] as int?;
      final clientRequestId = sha256
          .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:${jsonEncode(data)}"))
          .toString();

      await LocalDatabaseService.enqueueRequest(
        method: 'PUT',
        endpoint: '/api/Inspection/RemoveTire',
        payload: [data],
        entityType: 'remove_tyre',
        localEntityId: tireId,
        clientRequestId: clientRequestId,
      );

      if (tireId != null && tireId != 0) {
        await LocalDatabaseService.updateTireDisposition(
          tireId: tireId,
          dispositionId: (data['dispositionId'] as int?) ?? 0,
          dispositionName: 'Removed',
          wheelPosition: '',
        );
      }

      final tyres = await LocalStorageService.getTyres();
      final idx = tyres.indexWhere((e) => (e['tireId'] as int?) == tireId);
      if (idx >= 0) {
        tyres[idx] = {
          ...tyres[idx],
          'dispositionId': data['dispositionId'],
          'dispositionName': 'Removed',
          'syncStatus': 'pending',
          '_localOnly': true,
        };
        await LocalStorageService.saveTyres(tyres);
      }

      print("✅ Offline remove queued for tireId=$tireId");
      return true;
    }

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        if (cookies != null && cookies.isNotEmpty) "Cookie": cookies,
      },
      body: jsonEncode([data]),
    );

    print("📦 REMOVE TYRE PAYLOAD => $data");
    print("📡 RESPONSE => ${response.body}");

    if (response.statusCode == 200) return true;

    throw Exception(
      "Failed to remove tyre. StatusCode: ${response.statusCode}",
    );
  }

  // ==========================================================
  // ✅ GET MASTER DATA (Cookie-based auth)
  // ==========================================================
  Future<MasterModel?> getMasterData() async {
    try {
      final url = Uri.parse(
        "${ApiConstants.baseUrl}/api/MasterData/GetMasterDataMobile",
      );

      // ✅ Get cookie from secure storage
      final cookies = await SecureStorage.getCookie();
      if (cookies == null || cookies.isEmpty) {
        final cached = await LocalStorageService.getMasterData();
        if (cached != null) {
          print("✅ MasterData loaded from cache (no cookie)");
          return MasterModel.fromJson(cached);
        }
        print("❌ No cookie found. Please login first!");
        return null;
      }
      print("🌍 MASTER API URL => $url");
      print("🍪 COOKIE => $cookies");

      // ✅ Set headers with cookie
      final headers = {"Content-Type": "application/json", "Cookie": cookies};

      // 🔹 Make GET request
      final response = await http.get(url, headers: headers);
      print("📡 STATUS CODE => ${response.statusCode}");
      print("📦 BODY => ${response.body}");

      // 🔹 Check status code first
      if (response.statusCode != 200) {
        print("Failed to load master data: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }

      // 🔹 Parse JSON safely
      final data = json.decode(response.body);

      if (data is Map<String, dynamic> && data["model"] != null) {
        await LocalStorageService.saveMasterData(data["model"] as Map<String, dynamic>);
        return MasterModel.fromJson(data["model"]);
      } else {
        print("Unexpected data structure");
        return null;
      }
    } catch (e) {
      print("Failed to load master data: $e");
      final cached = await LocalStorageService.getMasterData();
      if (cached != null) {
        print("✅ MasterData loaded from cache (fallback)");
        return MasterModel.fromJson(cached);
      }
      return null;
    }
  }

  // ==========================================================
  // ✅ GET REMOVAL REASONS
  // ==========================================================
  Future<List<TireRemovalReason>> getRemovalReason() async {
    final master = await getMasterData();
    if (master == null) return [];
    return master.tireRemovalReasons;
  }

  // ==========================================================
  // ✅ GET DISPOSITIONS
  // ==========================================================
  Future<List<TireDisposition>> getDispositions() async {
    final master = await getMasterData();
    if (master == null) return [];
    return master.tireDispositions;
  }
}
