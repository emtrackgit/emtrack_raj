import 'dart:convert';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/all_vehicle_account_model.dart';

import '../utils/secure_storage.dart';
import 'api_constants.dart';

class AllVehicleService {
  // Future<List<AllVehicleModel>> getVehiclesByUser({
  //   required int parentAccountId,
  //   int pageNumber = 0,
  //   int timeStamp = 0,
  // }) async {
  //   try {
  //     // ================= PARENT ID CHECK =================
  //     if (parentAccountId == 0) {
  //       throw Exception("Invalid parentAccountId");
  //     }

  //     print("🔥 DEBUG PARENT ID => $parentAccountId");

  //     // ================= COOKIE =================
  //     final cookie = await SecureStorage.getCookie();
  //     if (cookie == null || cookie.isEmpty) {
  //       throw Exception("Session expired. Please login again.");
  //     }

  //     print("🍪 COOKIE => $cookie");

  //     // ================= URL =================
  //     final url = Uri.parse(
  //       ApiConstants.baseUrl +
  //           ApiConstants.getVehicleByUser(
  //             parentAccountId,
  //             pageNumber: pageNumber,
  //             timeStamp: timeStamp,
  //           ),
  //     );

  //     print("🌐 FINAL URL => $url");

  //     // ================= API CALL =================
  //     final response = await http.get(
  //       url,
  //       headers: {"Accept": "application/json", "Cookie": cookie},
  //     );

  //     print("📡 STATUS CODE => ${response.statusCode}");
  //     print("📦 RESPONSE BODY => ${response.body}");

  //     // ================= SUCCESS =================
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);

  //       if (decoded == null) {
  //         throw Exception("Empty response from server");
  //       }

  //       if (decoded['didError'] == true) {
  //         throw Exception(decoded['errorMessage'] ?? "Server error");
  //       }

  //       if (decoded['model'] == null) {
  //         return [];
  //       }

  //       final List list = decoded['model'];

  //       final vehicles = list.map((e) => AllVehicleModel.fromJson(e)).toList();

  //       print("✅ VEHICLES COUNT => ${vehicles.length}");

  //       return vehicles;
  //     }

  //     // ================= SESSION EXPIRED =================
  //     if (response.statusCode == 401 || response.statusCode == 403) {
  //       print("🔐 SESSION EXPIRED");
  //       Get.find<GlobalLogoutHandler>().forceLogout();
  //       return [];
  //     }

  //     // ================= BACKEND ERROR MESSAGE =================
  //     try {
  //       final errorJson = jsonDecode(response.body);
  //       final backendMsg = errorJson['errorMessage'] ?? errorJson['message'];
  //       if (backendMsg != null) {
  //         throw Exception(backendMsg.toString());
  //       }
  //     } catch (_) {}

  //     // ================= OTHER ERRORS =================
  //     throw Exception("Failed to load vehicles (${response.statusCode})");
  //   } catch (e, s) {
  //     print("🔥 AllVehicleService Error => $e");
  //     print("STACK TRACE => $s");
  //     rethrow;
  //   }
  // }

  Future<List<AccountVehicleModel>> getVehiclesByAccount({
    required int parentAccountId,
    int pageNumber = 0,
    int timeStamp = 0,
  }) async {
    try {
      // ================= PARENT ID CHECK =================
      if (parentAccountId == 0) {
        throw Exception("Invalid parentAccountId");
      }

      print("🔥 DEBUG PARENT ID => $parentAccountId");

      // ================= COOKIE =================
      final cookie = await SecureStorage.getCookie();
      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      print("🍪 COOKIE => $cookie");

      // ================= URL =================
      final url = Uri.parse(
        ApiConstants.baseUrl +
            ApiConstants.getVehicleByAccount(parentAccountId),
      );

      print("🌐 FINAL URL => $url");

      // ================= API CALL =================
      final response = await http.get(
        url,
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      print("📡 STATUS CODE => ${response.statusCode}");
      print("📦 RESPONSE BODY => ${response.body}");

      // ================= SUCCESS =================
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded == null) {
          throw Exception("Empty response from server");
        }

        if (decoded['didError'] == true) {
          throw Exception(decoded['errorMessage'] ?? "Server error");
        }

        if (decoded['model'] == null) {
          return [];
        }

        // final List list = decoded['model'];

        // final vehicles = list.map((e) => AllVehicleModel.fromJson(e)).toList();

        // print("✅ VEHICLES COUNT => ${vehicles.length}");

        // return vehicles;

        final Map<String, dynamic> model = decoded['model'];

        final List locations = model['locationList'];

        List<AccountVehicleModel> vehicles = [];

        for (var loc in locations) {
          final List vehicleList = loc['vehicleList'] ?? [];

          vehicles.addAll(
            vehicleList.map((e) => AccountVehicleModel.fromJson(e)).toList(),
          );
        }

        print("✅ VEHICLES COUNT => ${vehicles.length}");

        return vehicles;
      }

      // ================= SESSION EXPIRED =================
      if (response.statusCode == 401 || response.statusCode == 403) {
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      // ================= BACKEND ERROR MESSAGE =================
      try {
        final errorJson = jsonDecode(response.body);
        final backendMsg = errorJson['errorMessage'] ?? errorJson['message'];
        if (backendMsg != null) {
          throw Exception(backendMsg.toString());
        }
      } catch (_) {}

      // ================= OTHER ERRORS =================
      throw Exception("Failed to load vehicles (${response.statusCode})");
    } catch (e, s) {
      print("🔥 AllVehicleService Error => $e");
      print("STACK TRACE => $s");
      rethrow;
    }
  }
}
