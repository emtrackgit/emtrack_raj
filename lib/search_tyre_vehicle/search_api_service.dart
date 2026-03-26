import 'dart:convert';
import 'package:emtrack/search_tyre_vehicle/tire_item_model.dart';
import 'package:emtrack/search_tyre_vehicle/vehicle_item_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:emtrack/utils/secure_storage.dart';

class SearchApi {
  final String baseUrl = ApiConstants.baseUrl;

  /// ================= VEHICLES =================
  Future<List<VehicleItem>> fetchVehicles(int accountId) async {
    try {
      final cookie = await SecureStorage.getCookie();
      if (cookie == null || cookie.isEmpty)
        throw Exception("Auth cookie missing");

      final timeStamp = 0;
      final url = Uri.parse(
        "$baseUrl/api/Vehicle/GetVehicleByUser/$accountId/$timeStamp?timeStamp=$timeStamp",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie,
        },
      );

      print("📡 VEHICLE STATUS: ${response.statusCode}");
      print("📥 VEHICLE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['model'] == null) return [];

        final List list = data['model'] as List;

        return list.map<VehicleItem>((e) => VehicleItem.fromJson(e)).toList();
      }

      if (response.statusCode == 401 || response.statusCode == 403)
        throw Exception("Session expired");

      throw Exception("Vehicle API failed");
    } catch (e) {
      print("❌ fetchVehicles Error: $e");
      rethrow;
    }
  }

  /// ================= TYRES =================
  Future<List<TireItem>> fetchTyres(int accountId) async {
    try {
      final cookie = await SecureStorage.getCookie();
      if (cookie == null || cookie.isEmpty)
        throw Exception("Auth cookie missing");

      final url = Uri.parse("$baseUrl/api/Tire/GetTiresByAccount/$accountId");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie,
        },
      );

      print("📡 TYRE STATUS: ${response.statusCode}");
      print("📥 TYRE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['model'] == null) return [];

        final List list = data['model'] as List;

        return list.map<TireItem>((e) => TireItem.fromJson(e)).toList();
      }

      if (response.statusCode == 401 || response.statusCode == 403)
        throw Exception("Session expired");

      throw Exception("Tyre API failed");
    } catch (e) {
      print("❌ fetchTyres Error: $e");
      rethrow;
    }
  }
}
