import 'dart:convert';
import 'package:emtrack/models/update_hours_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
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

      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      if (isOffline) {
        final clientRequestId = sha256
            .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:$bodyData"))
            .toString();

        await LocalDatabaseService.enqueueRequest(
          method: 'PUT',
          endpoint: '/api/Inspection/UpdateHoursForVehicle',
          payload: model.toJson(),
          entityType: 'update_hours',
          localEntityId: model.vehicleId,
          clientRequestId: clientRequestId,
        );

        final vehicles = await LocalStorageService.getVehicles();
        final idx = vehicles.indexWhere((e) => (e['vehicleId'] as int?) == model.vehicleId);
        if (idx >= 0) {
          vehicles[idx] = {
            ...vehicles[idx],
            'currentHours': model.currentHours,
            'lastRead': DateTime.now().toIso8601String(),
            'syncStatus': 'pending',
            '_localOnly': true,
          };
          await LocalStorageService.saveVehicles(vehicles);
        }

        print("✅ Offline update hours queued for vehicleId=${model.vehicleId}");
        return true;
      }

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
