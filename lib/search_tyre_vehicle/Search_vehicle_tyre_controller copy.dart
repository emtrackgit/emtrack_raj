import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/search_tyre_vehicle/tire_item_model.dart';
import 'package:emtrack/search_tyre_vehicle/vehicle_item_model.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:get/get.dart';
import '../search_tyre_vehicle/search_api_service.dart';

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

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// ================= LOAD DATA =================
  Future<void> loadData() async {
    try {
      final String? accountIdStr = await SecureStorage.getParentAccountId();
      print("Account ID: $accountIdStr");

      if (accountIdStr == null || accountIdStr.isEmpty) {
        Get.snackbar("Error", "Parent account ID not found");
        return;
      }

      final int? accountId = int.tryParse(accountIdStr);
      if (accountId == null) {
        Get.snackbar("Error", "Parent account ID invalid");
        return;
      }

      vehicles.value = await api.fetchVehicles(accountId);
      tyres.value = await api.fetchTyres(accountId);

      updateVisibleList();
    } catch (e) {
      print("❌ loadData Error: $e");
      Get.snackbar("Error", "Unable to load vehicles & tyres");
    }
  }

  /// ================= TAB SWITCH =================
  void switchTab(int index) {
    selectedTab.value = index;
    searchText.value = '';
    updateVisibleList();
    update();
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
                  (v) => (v.vehicleId.toString()).toLowerCase().contains(
                    searchText.value.toLowerCase(),
                  ),
                )
                .toList();
    } else {
      visibleList.value = searchText.value.isEmpty
          ? tyres
          : tyres
                .where(
                  (t) => (t.tireId.toString()).toLowerCase().contains(
                    searchText.value.toLowerCase(),
                  ),
                )
                .toList();
    }
  }

  /// ================= SELECT ITEM =================
  void selectItem(dynamic item) {
    if (selectedTab.value == 0) {
      final vehicle = item as VehicleItem;

      if (!recentVehicles.any((e) => e.vehicleId == vehicle.vehicleId)) {
        recentVehicles.add(vehicle);
        Get.to(() => VehicleInspeView(), arguments: vehicle.vehicleId);
      }
    } else {
      final tyre = item as TireItem;

      if (!recentTyres.any((e) => e.tireId == tyre.tireId)) {
        recentTyres.add(tyre);
        Get.to(() => InspectTyreView(), arguments: tyre);
      }
    }
  }

  /// ================= REMOVE RECENT =================
  void removeRecentVehicle(VehicleItem item) {
    recentVehicles.removeWhere((e) => e.vehicleId == item.vehicleId);
  }

  void removeRecentTyre(TireItem item) {
    recentTyres.removeWhere((e) => e.tireId == item.tireId);
  }

  /// ================= CLEAR =================
  void clearSearch() {
    searchText.value = '';
    updateVisibleList();
  }
}
