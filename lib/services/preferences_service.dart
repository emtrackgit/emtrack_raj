import 'dart:convert';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:emtrack/models/preferences_model.dart';
import 'package:emtrack/models/country/country_response.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';

class PreferencesService {
  static const String _updatePrefUrl =
      ApiConstants.baseUrl + ApiConstants.updatePreferences;

  static const String _getCountriesUrl =
      ApiConstants.baseUrl + ApiConstants.getAllCountryName;
  // 🔹 example: "/api/Country/GetAll"

  /// 🔹 UPDATE PREFERENCES
  Future<bool> updatePreferences(PreferencesModel model) async {
    final cookie = await SecureStorage.getCookie();
    final username = await SecureStorage.getUserName();

    if (cookie == null || cookie.isEmpty) {
      throw Exception("Auth cookie missing. Please login again.");
    }

    if (username == null || username.isEmpty) {
      throw Exception("UpdatedBy missing. Please login again.");
    }

    final body = {
      "UserId": username,
      "UpdatedBy": username,
      "UserLanguage": model.language,
      "UserMeasurementSystemValue": model.measurementSystem,
      "UserPressureUnit": model.pressureUnit,
    };

    print("📤 REQUEST BODY => $body");

    final response = await http.put(
      Uri.parse(_updatePrefUrl),
      headers: {'Content-Type': 'application/json', 'Cookie': cookie},
      body: jsonEncode(body),
    );

    print("📡 STATUS => ${response.statusCode}");
    print("📡 BODY => ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        "Preferences API failed (${response.statusCode}) => ${response.body}",
      );
    }
  }

  /// 🔹 GET COUNTRIES
  Future<CountryResponse> getCountries() async {
    final cookie = await SecureStorage.getCookie();

    if (cookie == null || cookie.isEmpty) {
      throw Exception("Auth cookie missing");
    }

    final response = await http.get(
      Uri.parse(_getCountriesUrl),
      headers: {'Content-Type': 'application/json', 'Cookie': cookie},
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      print("🔐 SESSION EXPIRED");
      Get.find<GlobalLogoutHandler>().forceLogout();
      return getCountries();
    }
    print("🌍 COUNTRY STATUS => ${response.statusCode}");
    print("🌍 COUNTRY BODY => ${response.body}");

    if (response.statusCode == 200) {
      return CountryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        "Country API failed (${response.statusCode}) => ${response.body}",
      );
    }
  }
}
