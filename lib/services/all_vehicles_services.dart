import '../models/all_vehicle_account_model.dart';
import '../utils/local_storage_service.dart';

class AllVehicleService {
  AccountVehicleModel _toVehicleModel(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return AccountVehicleModel(
      vehicleId: toInt(json['vehicleId'] ?? json['vehicleID'] ?? json['id']) ?? 0,
      vehicleNumber: (json['vehicleNumber'] ?? json['vehicleNo'] ?? json['assetNumber'] ?? '').toString(),
      typeName: (json['typeName'] ?? json['vehicleType'] ?? json['type'] ?? '').toString(),
      modelName: (json['modelName'] ?? json['model'] ?? '').toString(),
      axleConfig: (json['axleConfig'] ?? json['axelConfig'] ?? '').toString(),
      manufacturerName: (json['manufacturerName'] ?? json['manufacturer'] ?? json['make'] ?? '').toString(),
      currentHours: toDouble(json['currentHours']) ?? 0.0,
      currentMiles: toDouble(json['currentMiles']) ?? 0.0,
      lastRead: (json['lastRead'] ?? json['lastRecordedDate'] ?? '').toString(),
      assetNumber: (json['assetNumber'] ?? '').toString(),
    );
  }

  Future<List<AccountVehicleModel>> _loadVehiclesFromCache() async {
    final cached = await LocalStorageService.getVehicles();
    if (cached.isEmpty) return [];
    final vehicles = cached.map(_toVehicleModel).toList();
    print("✅ Vehicles loaded from local cache: ${vehicles.length}");
    return vehicles;
  }

  // Future<List<AllVehicleModel>> getVehiclesByUser({
  //   required int parentAccountId,
  //   int pageNumber = 0,
  //   int timeStamp = 0,
  // }) async {
  //   try {
  //     // ================= PARENT ID CHECK =================
  //     if (parentAccountId == 0) {
  //       throw Exception("Invalid parentAccountId");
  //     }

  //     print("🔥 DEBUG PARENT ID => $parentAccountId");

  //     // ================= COOKIE =================
  //     final cookie = await SecureStorage.getCookie();
  //     if (cookie == null || cookie.isEmpty) {
  //       throw Exception("Session expired. Please login again.");
  //     }

  //     print("🍪 COOKIE => $cookie");

  //     // ================= URL =================
  //     final url = Uri.parse(
  //       ApiConstants.baseUrl +
  //           ApiConstants.getVehicleByUser(
  //             parentAccountId,
  //             pageNumber: pageNumber,
  //             timeStamp: timeStamp,
  //           ),
  //     );

  //     print("🌐 FINAL URL => $url");

  //     // ================= API CALL =================
  //     final response = await http.get(
  //       url,
  //       headers: {"Accept": "application/json", "Cookie": cookie},
  //     );

  //     print("📡 STATUS CODE => ${response.statusCode}");
  //     print("📦 RESPONSE BODY => ${response.body}");

  //     // ================= SUCCESS =================
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);

  //       if (decoded == null) {
  //         throw Exception("Empty response from server");
  //       }

  //       if (decoded['didError'] == true) {
  //         throw Exception(decoded['errorMessage'] ?? "Server error");
  //       }

  //       if (decoded['model'] == null) {
  //         return [];
  //       }

  //       final List list = decoded['model'];

  //       final vehicles = list.map((e) => AllVehicleModel.fromJson(e)).toList();

  //       print("✅ VEHICLES COUNT => ${vehicles.length}");

  //       return vehicles;
  //     }

  //     // ================= SESSION EXPIRED =================
  //     if (response.statusCode == 401 || response.statusCode == 403) {
  //       print("🔐 SESSION EXPIRED");
  //       Get.find<GlobalLogoutHandler>().forceLogout();
  //       return [];
  //     }

  //     // ================= BACKEND ERROR MESSAGE =================
  //     try {
  //       final errorJson = jsonDecode(response.body);
  //       final backendMsg = errorJson['errorMessage'] ?? errorJson['message'];
  //       if (backendMsg != null) {
  //         throw Exception(backendMsg.toString());
  //       }
  //     } catch (_) {}

  //     // ================= OTHER ERRORS =================
  //     throw Exception("Failed to load vehicles (${response.statusCode})");
  //   } catch (e, s) {
  //     print("🔥 AllVehicleService Error => $e");
  //     print("STACK TRACE => $s");
  //     rethrow;
  //   }
  // }

  Future<List<AccountVehicleModel>> getVehiclesByAccount({
    required int parentAccountId,
    int pageNumber = 0,
    int timeStamp = 0,
  }) async {
    return await _loadVehiclesFromCache();
  }
}
