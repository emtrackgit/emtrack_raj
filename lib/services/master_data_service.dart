import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MasterDataService {
  Future<Map<String, dynamic>> fetchMasterData() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/MasterData/GetMasterDataMobile',
      );

      print('📡 MASTER DATA URL: $url');

      final cookie = await SecureStorage.getCookie();
      print('🍪 COOKIE: $cookie');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (cookie != null) 'Cookie': cookie,
        },
      );

      print('📡 STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['didError'] == true) {
          throw Exception(json['errorMessage'] ?? 'Unknown server error');
        }

        final model = (json['model'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        await LocalStorageService.saveMasterData(model);
        return model;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        print("❌ SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        throw Exception("Session expired");
      }

      throw Exception('Master data failed (${response.statusCode})');
    } catch (e) {
      final cachedPrefs = await LocalStorageService.getMasterData();
      if (cachedPrefs != null) {
        print("✅ MasterData loaded from SharedPreferences cache");
        return cachedPrefs;
      }

      print("❌ MasterData not available offline: $e");
      rethrow;
    }
  }
}
