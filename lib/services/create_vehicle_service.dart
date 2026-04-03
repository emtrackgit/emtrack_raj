import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/vehicle_model.dart';

class VehicleService {
  int? _extractInsertedId(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is int) return decoded;
      if (decoded is Map) {
        dynamic pick(dynamic v) {
          if (v is int) return v;
          if (v is num) return v.toInt();
          if (v is String) return int.tryParse(v);
          return null;
        }

        final direct = pick(decoded['insertedId']) ??
            pick(decoded['vehicleId']) ??
            pick(decoded['id']);
        if (direct is int) return direct;

        final model = decoded['model'];
        if (model is int) return model;
        if (model is Map) {
          final m = pick(model['insertedId']) ??
              pick(model['vehicleId']) ??
              pick(model['id']);
          if (m is int) return m;
        }
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> _toLocalVehicleView({
    required VehicleModel vehicle,
    required int vehicleId,
    required bool isPending,
  }) {
    return {
      'vehicleId': vehicleId,
      'vehicleNumber': vehicle.vehicleNumber,
      'typeName': vehicle.typeName,
      'modelName': vehicle.modelName,
      'axleConfig': vehicle.axleConfig,
      'manufacturerName': vehicle.manufacturer,
      'currentHours': vehicle.currentHours,
      'currentMiles': vehicle.currentMiles,
      'lastRead': DateTime.now().toIso8601String(),
      'assetNumber': vehicle.assetNumber,
      'parentAccountId': vehicle.parentAccountId,
      'locationId': vehicle.locationId,
      'syncStatus': isPending ? 'pending' : 'synced',
      '_localOnly': isPending,
    };
  }

  /// CREATE VEHICLE (with Cookie)
  Future<int?> createVehicle(VehicleModel vehicle) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/Vehicle/Create');

    final cookie = await SecureStorage.getCookie();
    if (cookie == null || cookie.isEmpty) {
      throw Exception('Unauthorized: No cookie found.');
    }

    print(jsonEncode(vehicle.toJson()));

    final body = jsonEncode(vehicle.toJson());
    print("📤 REQUEST BODY: $body");

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      if (isOffline) {
        final localId = -DateTime.now().millisecondsSinceEpoch;
        final clientRequestId = sha256
            .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:$body"))
            .toString();

        final payload = _toLocalVehicleView(
          vehicle: vehicle,
          vehicleId: localId,
          isPending: true,
        );

        await LocalDatabaseService.enqueueRequest(
          method: 'POST',
          endpoint: ApiConstants.createVehicle,
          payload: vehicle.toJson(),
          entityType: 'vehicle_create',
          localEntityId: localId,
          clientRequestId: clientRequestId,
        );

        final existing = await LocalStorageService.getVehicles();
        existing.insert(0, payload);
        await LocalStorageService.saveVehicles(existing);

        print("✅ Offline vehicle saved locally: vehicleId=$localId");
        return localId;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
        body: body,
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return null;
      }
      print("📡 RESPONSE STATUS: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResp = jsonDecode(response.body);

        if (jsonResp['didError'] == false) {
          final insertedId =
              (jsonResp['insertedId'] as int?) ?? _extractInsertedId(response.body);
          if (insertedId != null && insertedId > 0) {
            final payload = _toLocalVehicleView(
              vehicle: vehicle,
              vehicleId: insertedId,
              isPending: false,
            );
            final existing = await LocalStorageService.getVehicles();
            existing.insert(0, payload);
            await LocalStorageService.saveVehicles(existing);
            print("✅ Vehicle saved locally (online): vehicleId=$insertedId");
            return insertedId;
          }
          throw Exception("Vehicle created but server id not returned.");
        }

        throw Exception(jsonResp['errorMessage'] ?? 'Unknown error');
      }

      throw Exception('Server error ${response.statusCode}');
    } catch (e) {
      print("❌ VEHICLE CREATE EXCEPTION: $e");
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      if (isOffline) {
        final localId = -DateTime.now().millisecondsSinceEpoch;
        final clientRequestId = sha256
            .convert(utf8.encode("${DateTime.now().microsecondsSinceEpoch}:$body"))
            .toString();

        final payload = _toLocalVehicleView(
          vehicle: vehicle,
          vehicleId: localId,
          isPending: true,
        );

        await LocalDatabaseService.enqueueRequest(
          method: 'POST',
          endpoint: ApiConstants.createVehicle,
          payload: vehicle.toJson(),
          entityType: 'vehicle_create',
          localEntityId: localId,
          clientRequestId: clientRequestId,
        );

        final existing = await LocalStorageService.getVehicles();
        existing.insert(0, payload);
        await LocalStorageService.saveVehicles(existing);

        print("✅ Offline vehicle saved locally (fallback): vehicleId=$localId");
        return localId;
      }
      return null;
    }
  }
}
