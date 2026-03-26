import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/secure_storage.dart';
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
      final response = await http.post(
        url, // ✅ POST (backend expects POST on Update)
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
      print("🚨 VEHICLE UPDATE EXCEPTION: $e");
      return false;
    }
  }
}
