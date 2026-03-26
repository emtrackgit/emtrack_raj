import 'dart:convert';
import 'package:emtrack/edit_tyre/edit_tyre_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class EditTyreService {
  // 🔹 BASE API
  // static const String _url = ApiConstants.baseUrl + ApiConstants.updateTire;

  static Future<EditTyreModel> getTyreById(int tireId) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      final url = "${ApiConstants.baseUrl}/api/Tire/GetById/$tireId";
      print("🟢 API URL => $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      print("🔵 STATUS => ${response.statusCode}");
      print("🔵 BODY => ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['model'] == null) {
          throw Exception("Tire data not found");
        }

        return EditTyreModel.fromJson(decoded['model']);
      }

      if (response.statusCode == 401) {
        await SecureStorage.clearCookie();
        throw Exception("Session expired. Please login again.");
      }

      throw Exception("Failed to load tyre");
    } catch (e) {
      print("🔴 ERROR => $e");
      rethrow;
    }
  }
}
