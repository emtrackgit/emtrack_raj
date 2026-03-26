import 'dart:convert';
import 'package:emtrack/models/masterDataMobileModel/master_model.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:emtrack/models/tyre_view_model.dart';
import '../utils/secure_storage.dart';

class TyreViewService {
  final String tyreBaseUrl =
      "https://emtrackotrapi-staging.azurewebsites.net/api/Tire";
  final String masterBaseUrl =
      "https://emtrackotrapi-staging.azurewebsites.net/api/MasterData";

  /// Fetch tyre details by ID
  Future<TyreViewModel> fetchTyreDetailsById(int tireId) async {
    final url = Uri.parse('$tyreBaseUrl/GetById/$tireId');
    final cookie = await SecureStorage.getCookie();

    if (cookie == null || cookie.isEmpty) {
      throw Exception("Auth cookie not found. Please login again.");
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return TyreViewModel.fromJson(jsonMap['model']);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      Get.find<GlobalLogoutHandler>().forceLogout();
      return fetchTyreDetailsById(tireId);
    } else {
      throw Exception(
        "Failed to load tyre details. Status: ${response.statusCode}",
      );
    }
  }

  /// Fetch master data for mobile
  Future<MasterModel> fetchMasterData() async {
    final url = Uri.parse('$masterBaseUrl/GetMasterDataMobile');
    final cookie = await SecureStorage.getCookie();

    if (cookie == null || cookie.isEmpty) {
      throw Exception("Auth cookie not found. Please login again.");
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      // 🔹 Master data response usually in 'model'
      return MasterModel.fromJson(jsonMap['model']);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      Get.find<GlobalLogoutHandler>().forceLogout();
      return fetchMasterData();
    } else {
      throw Exception(
        "Failed to load master data. Status: ${response.statusCode}",
      );
    }
  }
}
