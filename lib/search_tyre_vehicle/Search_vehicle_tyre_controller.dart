import 'dart:convert';
import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:emtrack/search_tyre_vehicle/vehicle_item_model.dart';
import 'package:emtrack/search_tyre_vehicle/tire_item_model.dart';
import 'package:emtrack/search_tyre_vehicle/search_api_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';

import '../inspection/vehicle_inspe_model.dart';

class SearchVehicleTyreController extends GetxController {
  final SearchApi api = SearchApi();

  /// 0 = Vehicle, 1 = Tyre
  RxInt selectedTab = 0.obs;
  RxString searchText = ''.obs;

  RxList<VehicleItem> vehicles = <VehicleItem>[].obs;
  RxList<TireItem> tyres = <TireItem>[].obs;

  RxList<VehicleItem> recentVehicles = <VehicleItem>[].obs;
  RxList<TireItem> recentTyres = <TireItem>[].obs;

  RxList<dynamic> visibleList = <dynamic>[].obs;

  bool _isNavigating = false; // Prevent double navigation

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadRecentFromStorage();
  }

  /// ================= LOAD DATA =================
  Future<void> loadData() async {
    try {
      final String? accountIdStr = await SecureStorage.getParentAccountId();
      if (accountIdStr == null || accountIdStr.isEmpty) return;

      final int? accountId = int.tryParse(accountIdStr);
      if (accountId == null) return;

      vehicles.value = await api.fetchVehicles(accountId);
      tyres.value = await api.fetchTyres(accountId);

      updateVisibleList();
    } catch (e) {
      print("❌ loadData Error: $e");
    }
  }

  /// ================= RECENT STORAGE =================
  Future<void> loadRecentFromStorage() async {
    // Vehicles
    final savedVehiclesStr = await SecureStorage.getVehicle();
    if (savedVehiclesStr != null && savedVehiclesStr.isNotEmpty) {
      final List decoded = jsonDecode(savedVehiclesStr);
      recentVehicles.value = decoded
          .map((e) => VehicleItem.fromJson(e))
          .toList();
    }

    // Tyres
    final savedTyresStr = await SecureStorage.getTyre();
    if (savedTyresStr != null && savedTyresStr.isNotEmpty) {
      final List decoded = jsonDecode(savedTyresStr);
      recentTyres.value = decoded.map((e) => TireItem.fromJson(e)).toList();
    }
  }

  Future<void> _saveRecentVehicles() async {
    final List<Map<String, dynamic>> list = recentVehicles
        .map((e) => e.toJson())
        .toList();
    await SecureStorage.saveVehicle(jsonEncode(list));
  }

  Future<void> _saveRecentTyres() async {
    final List<Map<String, dynamic>> list = recentTyres
        .map((e) => e.toJson())
        .toList();
    await SecureStorage.saveTyre(jsonEncode(list));
  }

  /// ================= TAB SWITCH =================
  void switchTab(int index) {
    selectedTab.value = index;
    searchText.value = '';
    updateVisibleList();
  }

  /// ================= SEARCH =================
  void onSearch(String value) {
    searchText.value = value;
    updateVisibleList();
  }

  /// ================= FILTER =================
  void updateVisibleList() {
    if (selectedTab.value == 0) {
      visibleList.value = searchText.value.isEmpty
          ? vehicles
          : vehicles
                .where(
                  (v) =>
                      v.vehicleNumber?.toString().contains(searchText.value) ??
                      false,
                )
                .toList();
    } else {
      visibleList.value = searchText.value.isEmpty
          ? tyres
          : tyres
                .where((t) => t.tireSerialNo.toString().contains(searchText.value))
                .toList();
    }
  }

  /// ================= SELECT ITEM =================
  // void selectItem(dynamic item) {
  //   if (selectedTab.value == 0) {
  //     final vehicle = item as VehicleItem;
  //
  //     if (!recentVehicles.any((e) => e.vehicleId == vehicle.vehicleId)) {
  //       recentVehicles.add(vehicle);
  //       _saveRecentVehicles();
  //     }
  //
  //     if (!_isNavigating) {
  //       _isNavigating = true;
  //       Get.to(
  //         () => VehicleInspeView(),
  //         arguments: vehicle.vehicleId,
  //       )?.then((_) => _isNavigating = false);
  //     }
  //   } else {
  //     final tyre = item as TireItem;
  //
  //     if (!recentTyres.any((e) => e.tireId == tyre.tireId)) {
  //       recentTyres.add(tyre);
  //       _saveRecentTyres();
  //     }
  //
  //     if (!_isNavigating) {
  //       _isNavigating = true;
  //       Get.to(
  //         () => InspectTyreView(),
  //         arguments: tyre.tireId,
  //       )?.then((_) => _isNavigating = false);
  //     }
  //   }
  // }



  void selectItem(dynamic item) {
    if (selectedTab.value == 0) {
    } else {
      final tyre = item;

      if (!_isNavigating) {
        _isNavigating = true;

        final passingData = InstalledTire(
          tireId: tyre.tireId,
          tireSerialNo: tyre.tireSerialNo,

          vehicleId: 0,
        );

        Get.to(() => InspectTyreView(), arguments: passingData)
            ?.then((_) => _isNavigating = false);
      }
    }
  }

  /// ================= REMOVE RECENT =================
  void removeRecentVehicle(VehicleItem item) {
    recentVehicles.removeWhere((e) => e.vehicleId == item.vehicleId);
    _saveRecentVehicles();
  }

  void removeRecentTyre(TireItem item) {
    recentTyres.removeWhere((e) => e.tireId == item.tireId);
    _saveRecentTyres();
  }

  /// ================= CLEAR =================
  void clearSearch() {
    searchText.value = '';
    updateVisibleList();
  }
}
