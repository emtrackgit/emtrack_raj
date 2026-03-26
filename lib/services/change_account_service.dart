// import 'dart:convert';
// import 'package:emtrack/services/api_constants.dart';
// import 'package:emtrack/services/global_logout_handler.dart';
// import 'package:emtrack/utils/secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../models/change_account_model.dart';

// class ChangeAccountService {
//   /// 🔹 GET PARENT ACCOUNTS
//   Future<List<ParentAccountModel>> fetchParentAccounts() async {
//     final cookie = await SecureStorage.getCookie();

//     final res = await http.get(
//       Uri.parse(
//         '${ApiConstants.baseUrl}/api/ParentAccount/GetAccountList/0?timeStamp=0',
//       ),
//       headers: {"Accept": "application/json", "Cookie": cookie ?? ''},
//     );

//     if (res.statusCode == 200) {
//       final decoded = jsonDecode(res.body);
//       final List list = decoded['model'] ?? [];
//       return list.map((e) => ParentAccountModel.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to load parent accounts");
//     }
//   }

//   /// 🔹 GET LOCATIONS (DEPENDENT)
//   Future<List<LocationModel>> fetchLocations(int parentAccountId) async {
//     final cookie = await SecureStorage.getCookie();

//     final res = await http.get(
//       Uri.parse(
//         '${ApiConstants.baseUrl}/api/Location/GetLocationList/$parentAccountId',
//       ),
//       headers: {"Accept": "application/json", "Cookie": cookie ?? ''},
//     );

//     if (res.statusCode == 200) {
//       final decoded = jsonDecode(res.body);
//       final List list = decoded['model'] ?? [];
//       return list.map((e) => LocationModel.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to load locations");
//     }
//   }
// }

import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/change_account_model.dart';
import 'api_service.dart';

class ChangeAccountService {
  /// 🔹 GET PARENT ACCOUNTS
  Future<List<ParentAccountModel>> fetchParentAccounts() async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        //  Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/ParentAccount/GetAccountList/0?timeStamp=0',
        ),
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['model'] ?? [];
        return list.map((e) => ParentAccountModel.fromJson(e)).toList();
      }

      /// 🔐 UNAUTHORIZED
      if (res.statusCode == 401 || res.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      return [];
    } catch (e) {
      print("❌ fetchParentAccounts error => $e");
      return [];
    }
  }

  /// 🔹 GET LOCATIONS (DEPENDENT)
  Future<List<LocationModel>> fetchLocations(int parentAccountId) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/Location/GetLocationList/$parentAccountId',
        ),
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['model'] ?? [];
        return list.map((e) => LocationModel.fromJson(e)).toList();
      }

      /// 🔐 UNAUTHORIZED
      if (res.statusCode == 401 || res.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      return [];
    } catch (e) {
      print("❌ fetchLocations error => $e");
      return [];
    }
  }

  Future<bool> updateLastAccessed({
    required String userId,
    required int lastAccessedAccountId,
    required int lastAccessedLocationId,
  }) async {
    try {
      final resp = await ApiService.putApi(
        endpoint: ApiConstants.updateLastAccessed,
        body: {
          "userId": userId,
          "lastAccessedAccountId": lastAccessedAccountId,
          "lastAccessedLocationId": lastAccessedLocationId,
          "updatedBy": userId,
          "updatedDate": DateTime.now().toIso8601String(),
        },
      );

      if (resp is Map<String, dynamic> && resp['didError'] == true) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
