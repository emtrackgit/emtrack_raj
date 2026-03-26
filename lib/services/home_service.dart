import 'dart:convert';
import 'package:emtrack/models/statical_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/home_model.dart';

class HomeService {
  /// Fetch dashboard / home data. Send auth token as Bearer.
  static Future<HomeModel?> fetchHomeData() async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      final uri = Uri.parse("${ApiConstants.baseUrl}/dashboard");

      final resp = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie, // ✅ COOKIE AUTH
        },
      );

      print("DASHBOARD STATUS => ${resp.statusCode}");
      print("DASHBOARD BODY => ${resp.body}");

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        final payload = data['data'] ?? data;
        return HomeModel.fromJson(payload as Map<String, dynamic>);
      }

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await SecureStorage.clearCookie();
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return null;
      }

      return null;
    } catch (e) {
      print('HomeService.fetchHomeData error: $e');
      return null;
    }
  }

  /// optional sync endpoint
  static Future<bool> syncInspections() async {
    try {
      final resp = await ApiService.getApi(
        endpoint: "/api/InspMobRequests/GetUserInspDataRequests",
      );

      if (resp is Map<String, dynamic>) {
        if (resp['didError'] == true) return false;
        return true;
      }

      return resp != null;
    } catch (e) {
      print('HomeService.syncInspections error: $e');
      return false;
    }
  }

  static Future<int?> fetchTyreCountByAccount(String parentAccountId) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) return null;

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/api/Tire/GetTiresByAccount/$parentAccountId",
      );

      final resp = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie,
        },
      );
      print("🧮 TYRE COUNT URL => $uri");
      print("🧮 TYRE COUNT STATUS => ${resp.statusCode}");
      print("🧮 TYRE COUNT BODY => ${resp.body}");
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await SecureStorage.clearCookie();
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return null;
      }
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        if (json is Map && json['didError'] == true) return null;
        final model = (json is Map) ? json['model'] : null;
        if (model is List) return model.length;
        if (model is Map) {
          final list = model['items'] ?? model['list'] ?? model['data'];
          if (list is List) return list.length;
          final total = model['totalRecords'] ?? model['totalCount'] ?? model['count'];
          final t = total is int ? total : int.tryParse(total?.toString() ?? '');
          return t;
        }
        return null;
      } else {
        print("Tyre API error ${resp.statusCode}");
        return null;
      }
    } catch (e) {
      print("Tyre API exception $e");
      return null;
    }
  }

  static Future<int?> fetchVehicleCountByAccount(String parentAccountId) async {
    try {
      final cookie = await SecureStorage.getCookie();
      if (cookie == null || cookie.isEmpty) return null;

      final accountId = int.tryParse(parentAccountId);
      if (accountId == null) return null;

      final endpoint = ApiConstants.getVehicleByAccount(accountId);
      final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");

      final resp = await http.get(
        uri,
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      print("🧮 VEH COUNT URL => $uri");
      print("🧮 VEH COUNT STATUS => ${resp.statusCode}");
      print("🧮 VEH COUNT BODY => ${resp.body}");

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await SecureStorage.clearCookie();
        Get.find<GlobalLogoutHandler>().forceLogout();
        return null;
      }

      if (resp.statusCode != 200) return null;

      final json = jsonDecode(resp.body);
      if (json is Map && json['didError'] == true) return null;

      final model = (json is Map) ? json['model'] : null;
      if (model is Map) {
        final locations = model['locationList'];
        if (locations is List) {
          var count = 0;
          for (final loc in locations) {
            if (loc is! Map) continue;
            final vehicles = loc['vehicleList'];
            if (vehicles is List) count += vehicles.length;
          }
          return count;
        }
      }

      return null;
    } catch (e) {
      print("🔥 Vehicle API exception => $e");
      return null;
    }
  }

  static Future<DashboardModel?> fetchReportDashboardHomeData() async {
    final parentAccountId = await SecureStorage.getParentAccountId();
    final getLocationId = await SecureStorage.getLocationId();

    try {
      final resp = await ApiService.postApi(
        endpoint: "/api/Report/GetReportDashboardData",
        body: {"accountIds": parentAccountId, "locationIds": getLocationId},
      );

      if (resp is Map<String, dynamic> && resp['model'] != null) {
        final model = resp["model"];
        return DashboardModel.fromJson(model);
      }

      return null;
    } catch (e) {
      print('HomeService.fetchHomeData error: $e');
      return null;
    }
  }
}
