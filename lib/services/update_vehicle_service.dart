import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/vehicle_model.dart';

class UpdateVehicleService {
  /// 🔥 GET VEHICLE DETAILS BY ID
  Future<VehicleModel?> getVehicleById(int vehicleId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/Vehicle/GetDetailsById/$vehicleId',
    );

    final cookie = await SecureStorage.getCookie();
    if (cookie == null || cookie.isEmpty) {
      final cached = await LocalStorageService.getVehicles();
      Map<String, dynamic>? found;
      for (final e in cached) {
        if ((e['vehicleId'] as int?) == vehicleId) {
          found = e;
          break;
        }
      }
      if (found != null) {
        print("✅ Vehicle loaded from cache: vehicleId=$vehicleId");
        return VehicleModel.fromJson(found);
      }
      throw Exception('Unauthorized: No cookie found.');
    }

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return null;
      }

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);

        if (jsonResp['didError'] == false) {
          return VehicleModel.fromJson(jsonResp['model']);
        }

        throw Exception(jsonResp['errorMessage'] ?? 'Unknown error');
      }

      throw Exception('Server error ${response.statusCode}');
    } catch (e) {
      print('🚨 GET VEHICLE ERROR: $e');
      return null;
    }
  }

  /// update VEHICLE (with Cookie)
  Future<bool> updateVehicle(VehicleModel vehicle) async {
    if (vehicle.vehicleId == null) {
      throw Exception("vehicleId is required for update");
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/Vehicle/Update');

    final cookie = await SecureStorage.getCookie();
    if (cookie == null || cookie.isEmpty) {
      throw Exception('Unauthorized: No cookie found.');
    }

    final body = jsonEncode(vehicle.toJson());
    print("📤 REQUEST BODY: $body");

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      if (isOffline) {
        final clientRequestId = sha256
            .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:$body"))
            .toString();

        await LocalDatabaseService.enqueueRequest(
          method: 'PUT',
          endpoint: '/api/Vehicle/Update',
          payload: vehicle.toJson(),
          entityType: 'vehicle_update',
          localEntityId: vehicle.vehicleId,
          clientRequestId: clientRequestId,
        );

        final existing = await LocalStorageService.getVehicles();
        final idx = existing.indexWhere((e) => (e['vehicleId'] as int?) == vehicle.vehicleId);
        final payload = vehicle.toJson();
        payload['syncStatus'] = 'pending';
        payload['_localOnly'] = true;
        if (idx >= 0) {
          existing[idx] = {...existing[idx], ...payload};
        } else {
          existing.insert(0, payload);
        }
        await LocalStorageService.saveVehicles(existing);
        print("✅ Offline vehicle update queued: vehicleId=${vehicle.vehicleId}");
        return true;
      }

      final response = await http.put(
        // ✅ POST (NOT PUT)
        url,
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
        body: body,
      );

      print("📡 RESPONSE STATUS: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 401 || response.statusCode == 403) {
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return false;
      }

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);

        if (jsonResp['didError'] == false) {
          return true; // ✅ UPDATE SUCCESS
        }

        throw Exception(jsonResp['errorMessage'] ?? 'Update failed');
      }

      throw Exception('Server error ${response.statusCode}');
    } catch (e) {
      print("❌ VEHICLE UPDATE EXCEPTION: $e");
      return false;
    }
  }
}
