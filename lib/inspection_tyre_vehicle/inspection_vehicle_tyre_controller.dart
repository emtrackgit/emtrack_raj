import 'package:emtrack/inspection/edit_vehicle_inspection_view.dart';
import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/inspection_tyre_vehicle/vehicle_inspe_view_get_data.dart';
import 'package:emtrack/inspection_tyre_vehicle/inspection_tire_vehicle_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:emtrack/inspection_tyre_vehicle/inspect_tyre_view_get.dart';
import 'package:get/get.dart';

class InspectionVehicleTyreController extends GetxController {
  final InspectionTireVehicleService api = InspectionTireVehicleService();

  /// 0 = Vehicle, 1 = Tyre
  RxInt selectedTab = 0.obs;
  RxString searchText = ''.obs;

  RxList<String> vehicles = <String>[].obs;
  RxList<String> tyres = <String>[].obs;

  RxList<String> recentVehicles = <String>[].obs;
  RxList<String> recentTyres = <String>[].obs;

  RxList<String> visibleList = <String>[].obs;

  /// 🔥 STATUS STORE
  Map<String, InspectionStatus> statusMap = {};
  RxString lastSelectedVehicle = ''.obs;
  RxString lastSelectedTyre = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    restoreLastSelection();
  }

  /////// temparay
  RxString currentItem = ''.obs;

  void setCurrentItem(String item) {
    currentItem.value = item;
  }

  void updateStatusForCurrentItem(InspectionStatus newStatus) {
    if (currentItem.value.isEmpty) return;

    statusMap[currentItem.value] = newStatus;
    update(); // refresh ListView page
  }
  // code bad me hta na h

  Future<void> loadData() async {
    vehicles.value = await api.fetchVehicles();
    tyres.value = await api.fetchTyres();

    /// default sab Pending
    for (final v in vehicles) {
      statusMap[v] = InspectionStatus.pending;
    }
    for (final t in tyres) {
      statusMap[t] = InspectionStatus.pending;
    }

    updateVisibleList();
  }

  /// TAB SWITCH
  void switchTab(int index) {
    selectedTab.value = index;
    searchText.value = '';
    updateVisibleList();
    update(); // 🔴 VERY IMPORTANT for dialog (GetBuilder)
  }

  /// SEARCH
  void onSearch(String value) {
    searchText.value = value;
    updateVisibleList();
  }

  void updateVisibleList() {
    final source = selectedTab.value == 0 ? vehicles : tyres;

    if (searchText.isEmpty) {
      visibleList.value = source;
    } else {
      visibleList.value = source
          .where(
            (e) => e.toLowerCase().contains(searchText.value.toLowerCase()),
          )
          .toList();
    }
  }

  Future<void> restoreLastSelection() async {
    final lastVehicle = await SecureStorage.getLastVehicle();
    final lastTyre = await SecureStorage.getLastTyre();

    if (lastVehicle != null && lastVehicle.isNotEmpty) {
      lastSelectedVehicle.value = lastVehicle;

      if (!recentVehicles.contains(lastVehicle)) {
        recentVehicles.add(lastVehicle);
      }
    }

    if (lastTyre != null && lastTyre.isNotEmpty) {
      lastSelectedTyre.value = lastTyre;

      if (!recentTyres.contains(lastTyre)) {
        recentTyres.add(lastTyre);
      }
    }
  }

  Future<void> selectItem(String value) async {
    if (selectedTab.value == 0) {
      lastSelectedVehicle.value = value;

      // ✅ yaha direct write nahi
      await SecureStorage.saveLastVehicle(value);

      if (!recentVehicles.contains(value)) {
        recentVehicles.add(value);
      }

      Get.to(
        () => VehicleInspeViewGetData(
          status: statusMap[value] ?? InspectionStatus.pending,
        ),
      );
    } else {
      lastSelectedTyre.value = value;

      await SecureStorage.saveLastTyre(value);

      if (!recentTyres.contains(value)) {
        recentTyres.add(value);
      }

      Get.to(
        () => InspectTyreViewGetData(
          status: statusMap[value] ?? InspectionStatus.pending,
        ),
      );
    }
  }

  void removeRecentVehicle(String value) async {
    recentVehicles.remove(value);

    if (lastSelectedVehicle.value == value) {
      lastSelectedVehicle.value = '';
      await SecureStorage.clearLastVehicle(); // 🔥 PERMANENT DELETE
    }
  }

  void removeRecentTyre(String value) async {
    recentTyres.remove(value);

    if (lastSelectedTyre.value == value) {
      lastSelectedTyre.value = '';
      await SecureStorage.clearLastTyre();
    }
  }

  void clearSearch() {
    searchText.value = '';
    visibleList.value = selectedTab.value == 0 ? vehicles : tyres;
  }
}

enum InspectionStatus { pending, approved, rejected }
