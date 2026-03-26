import 'dart:convert';
import 'package:emtrack/models/update_hours_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class UpdateHoursService {
  Future<bool> submitUpdate(UpdateHoursModel model) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        print("❌ COOKIE IS NULL OR EMPTY");
        return false;
      }

      final url =
          "${ApiConstants.baseUrl}/api/Inspection/UpdateHoursForVehicle";

      final bodyData = jsonEncode(model.toJson());

      print("🟢 PUT URL => $url");
      print("🟢 COOKIE SENT => $cookie");
      print("🟢 BODY => $bodyData");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookie, // ✅ Only main cookie
        },
        body: bodyData,
      );

      print("🟡 STATUS CODE => ${response.statusCode}");
      print("🟡 RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Update Success");
        return true;
      }

      if (response.statusCode == 401) {
        print("❌ Unauthorized - Session Expired or Invalid Cookie");
      }

      return false;
    } catch (e, stackTrace) {
      print("❌ Exception in submitUpdate: $e");
      print(stackTrace);
      return false;
    }
  }
}
