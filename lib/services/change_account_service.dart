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
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/change_account_model.dart';

class ChangeAccountService {
  /// 🔹 GET PARENT ACCOUNTS
  Future<List<ParentAccountModel>> fetchParentAccounts() async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        final cached = await LocalStorageService.getAccounts();
        if (cached.isNotEmpty) {
          print("✅ Accounts loaded from cache: ${cached.length}");
          return cached.map((e) => ParentAccountModel.fromJson(e)).toList();
        }
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
        final models = list.map((e) => ParentAccountModel.fromJson(e)).toList();
        final accountMaps = models
            .map((a) => {
                  'parentAccountId': a.parentAccountId,
                  'accountName': a.accountName,
                  'createdBy': a.createdBy,
                })
            .toList();
        await LocalStorageService.saveAccounts(accountMaps);
        await LocalDatabaseService.saveJsonCache('accounts', accountMaps);
        return models;
      }

      /// 🔐 UNAUTHORIZED
      if (res.statusCode == 401 || res.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      return [];
    } catch (e) {
      print("❌ fetchParentAccounts error => $e");
      final cachedDb = await LocalDatabaseService.getJsonCache('accounts');
      if (cachedDb is List) {
        final accounts = cachedDb
            .map((e) => ParentAccountModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        print("✅ Accounts loaded from SQLite cache: ${accounts.length}");
        return accounts;
      }
      final cachedPrefs = await LocalStorageService.getAccounts();
      if (cachedPrefs.isNotEmpty) {
        final accounts = cachedPrefs.map((e) => ParentAccountModel.fromJson(e)).toList();
        print("✅ Accounts loaded from SharedPreferences cache: ${accounts.length}");
        return accounts;
      }
      return [];
    }
  }

  /// 🔹 GET LOCATIONS (DEPENDENT)
  Future<List<LocationModel>> fetchLocations(int parentAccountId) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        final cached = await LocalStorageService.getLocations();
        if (cached.isNotEmpty) {
          final filtered = cached.where((e) => (e['parentAccountId'] as int?) == parentAccountId);
          final list = filtered.map((e) => LocationModel.fromJson(e)).toList();
          print("✅ Locations loaded from cache: ${list.length}");
          return list;
        }
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
        final models = list.map((e) => LocationModel.fromJson(e)).toList();
        final locationMaps = models
            .map((l) => {
                  'locationId': l.locationId,
                  'locationName': l.locationName,
                  'parentAccountId': parentAccountId,
                })
            .toList();
        await LocalStorageService.saveLocations(locationMaps);
        await LocalDatabaseService.saveJsonCache('locations:$parentAccountId', locationMaps);
        return models;
      }

      /// 🔐 UNAUTHORIZED
      if (res.statusCode == 401 || res.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      return [];
    } catch (e) {
      print("❌ fetchLocations error => $e");
      final cachedDb = await LocalDatabaseService.getJsonCache('locations:$parentAccountId');
      if (cachedDb is List) {
        final locations = cachedDb
            .map((e) => LocationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        print("✅ Locations loaded from SQLite cache: ${locations.length}");
        return locations;
      }
      final cachedPrefs = await LocalStorageService.getLocations();
      if (cachedPrefs.isNotEmpty) {
        final filtered = cachedPrefs.where((e) => (e['parentAccountId'] as int?) == parentAccountId);
        final locations = filtered.map((e) => LocationModel.fromJson(e)).toList();
        print("✅ Locations loaded from SharedPreferences cache: ${locations.length}");
        return locations;
      }
      return [];
    }
  }
}
