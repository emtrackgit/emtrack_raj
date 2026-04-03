import 'package:emtrack/search_tyre_vehicle/tire_item_model.dart';
import 'package:emtrack/search_tyre_vehicle/vehicle_item_model.dart';
import 'package:emtrack/utils/local_storage_service.dart';

class SearchApi {
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  /// ================= VEHICLES =================
  Future<List<VehicleItem>> fetchVehicles(int accountId) async {
    try {
      final cached = await LocalStorageService.getVehicles();
      final filtered = cached.where((e) => (_toInt(e['parentAccountId']) ?? accountId) == accountId);
      final vehicles = filtered
          .map(
            (e) => VehicleItem(
              vehicleId: _toInt(e['vehicleId']),
              vehicleNumber: (e['vehicleNumber'] ?? e['vehicleNo'] ?? e['assetNumber'] ?? '').toString(),
              parentAccountId: _toInt(e['parentAccountId']) ?? accountId,
              manufacturer: (e['manufacturer'] ?? e['manufacturerName'] ?? e['make'] ?? '').toString(),
              typeName: (e['typeName'] ?? e['vehicleType'] ?? '').toString(),
              modelName: (e['modelName'] ?? e['model'] ?? '').toString(),
              tireSize: (e['tireSize'] ?? e['sizeName'] ?? '').toString(),
              mileageType: (e['mileageType'] ?? '').toString(),
              currentHours: _toDouble(e['currentHours']),
              currentMiles: _toDouble(e['currentMiles']),
              removalTread: _toDouble(e['removalTread']),
              severityComments: (e['severityComments'] ?? '').toString(),
              vehicleIcon: (e['vehicleIcon'] ?? '').toString(),
            ),
          )
          .toList();

      print("✅ Vehicles loaded for search from local cache: ${vehicles.length}");
      return vehicles;
    } catch (e) {
      print("❌ fetchVehicles Error: $e");
      rethrow;
    }
  }

  /// ================= TYRES =================
  Future<List<TireItem>> fetchTyres(int accountId) async {
    try {
      final cached = await LocalStorageService.getTyres();
      final filtered = cached.where((e) => (_toInt(e['parentAccountId']) ?? accountId) == accountId);
      final tyres = filtered
          .map(
            (e) => TireItem(
              tireId: _toInt(e['tireId']) ?? 0,
              tireSerialNo: (e['tireSerialNo'] ?? '').toString(),
              manufacturerName: (e['manufacturerName'] ?? '').toString(),
              sizeName: (e['sizeName'] ?? '').toString(),
              typeName: (e['typeName'] ?? '').toString(),
              currentHours: _toDouble(e['currentHours']),
              currentMiles: _toDouble(e['currentMiles']),
              currentTreadDepth: _toDouble(e['currentTreadDepth']),
              percentageWorn: _toDouble(e['percentageWorn']),
              wheelPosition: (e['wheelPosition'] ?? '').toString(),
              dispositionName: (e['dispositionName'] ?? '').toString(),
              vehicleNumber: (e['vehicleNumber'] ?? '').toString(),
            ),
          )
          .toList();

      print("✅ Tyres loaded for search from local cache: ${tyres.length}");
      return tyres;
    } catch (e) {
      print("❌ fetchTyres Error: $e");
      rethrow;
    }
  }
}
