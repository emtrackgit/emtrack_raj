import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/controllers/home_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/controllers/all_tyre_controller.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection_tyre_vehicle/inspection_vehicle_tyre_controller.dart';
import '../models/change_account_model.dart';
import '../services/change_account_service.dart';

class ChangeAccountController extends GetxController {
  final service = ChangeAccountService();

  RxBool ownSelected = false.obs;
  RxBool sharedSelected = false.obs;

  RxBool isLoading = false.obs;
  RxnString accountType = RxnString(); // own / shared / null

  RxList<ParentAccountModel> accounts = <ParentAccountModel>[].obs;
  RxList<LocationModel> locations = <LocationModel>[].obs;

  Rx<ParentAccountModel?> selectedAccount = Rx<ParentAccountModel?>(null);
  Rx<LocationModel?> selectedLocation = Rx<LocationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  /* ---------------- INIT ---------------- */
  Future<void> _init() async {
    await _restoreRadio(); // ✅ radio first
    await loadParentAccounts(); // ✅ load accounts
    await _restoreParentAndLocation(); // ✅ restore after data ready
  }

  /* ---------------- RADIO RESTORE ---------------- */
  Future<void> _restoreRadio() async {
    final own = await SecureStorage.getBool('own_selected');
    final shared = await SecureStorage.getBool('shared_selected');

    ownSelected.value = own ?? false; // 🟢 first install → false
    sharedSelected.value = shared ?? false; // 🟢 first install → false

    final savedType = await SecureStorage.getAccountType();
    if (savedType == 'own' || savedType == 'shared') {
      accountType.value = savedType;
    } else {
      accountType.value = null; // 🟢 first install
    }
  }

  /* ---------------- LOAD PARENT ACCOUNTS ---------------- */
  Future<void> loadParentAccounts() async {
    try {
      isLoading.value = true;
      accounts.value = await service.fetchParentAccounts();
    } finally {
      isLoading.value = false;
    }
  }

  /* ---------------- RESTORE PARENT + LOCATION ---------------- */
  Future<void> _restoreParentAndLocation() async {
    // 🔽 Parent restore
    final savedParentId = await SecureStorage.getParentAccountId();
    if (savedParentId != null && accounts.isNotEmpty) {
      final parent = accounts.firstWhereOrNull(
        (e) => e.parentAccountId.toString() == savedParentId,
      );

      if (parent != null) {
        selectedAccount.value = parent;
        await loadLocations(parent.parentAccountId);
      }
    }

    // 📍 Location restore
    final savedLocationId = await SecureStorage.getLocationId();
    if (savedLocationId != null && locations.isNotEmpty) {
      selectedLocation.value = locations.firstWhereOrNull(
        (e) => e.locationId.toString() == savedLocationId,
      );
    }
  }

  /* ---------------- LOAD LOCATIONS ---------------- */
  Future<void> loadLocations(int parentAccountId) async {
    locations.clear();
    selectedLocation.value = null;

    locations.value = await service.fetchLocations(parentAccountId);

    final savedLocationId = await SecureStorage.getLocationId();
    if (savedLocationId != null) {
      selectedLocation.value = locations.firstWhereOrNull(
        (e) => e.locationId.toString() == savedLocationId,
      );
    }
  }

  /* ---------------- ON ACCOUNT CHANGE ---------------- */
  void onAccountChanged(ParentAccountModel? account) async {
    selectedAccount.value = account;

    if (account != null) {
      await SecureStorage.saveParentAccount(
        id: account.parentAccountId.toString(),
        name: account.accountName,
      );

      selectedLocation.value = null;
      locations.clear();

      await loadLocations(account.parentAccountId);
    }
  }

  /* ---------------- SUBMIT ---------------- */
  void submit() async {
    if (selectedAccount.value == null || selectedLocation.value == null) return;

    /// SAVE STORAGE
    await SecureStorage.saveParentAccount(
      id: selectedAccount.value!.parentAccountId.toString(),
      name: selectedAccount.value!.accountName,
    );

    await SecureStorage.saveLocation(
      id: selectedLocation.value!.locationId.toString(),
      name: selectedLocation.value!.locationName,
    );

    final userId = (await SecureStorage.getUserName()) ??
        (await SecureStorage.getUserProfileName()) ??
        '';
    if (userId.isNotEmpty) {
      await service.updateLastAccessed(
        userId: userId,
        lastAccessedAccountId: selectedAccount.value!.parentAccountId,
        lastAccessedLocationId: selectedLocation.value!.locationId,
      );
    }

    /// UPDATE HOME
    final homeCtrl = Get.find<HomeController>();
    homeCtrl.updateSelectedAccount(
      parentAccountName: selectedAccount.value!.accountName,
      locationName: selectedLocation.value!.locationName,
    );
    homeCtrl.loadTyreCountByAccount();
    homeCtrl.loadVehicleCountByAccount();

    /// REFRESH OTHER SCREENS
    Get.offNamed(AppPages.HOME);

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshHome();
    }
    if (Get.isRegistered<AllVehicleController>()) {
      await Get.find<AllVehicleController>().loadVehicles();
    }

    if (Get.isRegistered<AllTyreController>()) {
      final tyreCtrl = Get.find<AllTyreController>();
      await tyreCtrl.fetchData(tyreCtrl.tabs[tyreCtrl.tabController!.index]);
    }

    if (Get.isRegistered<SelectedAccountController>()) {
      await Get.find<SelectedAccountController>().refresh();
    }

    // 🔁 Clear old search/inspection controllers so they re-init with new account
    try {
      if (Get.isRegistered<InspectionVehicleTyreController>()) {
        Get.delete<InspectionVehicleTyreController>(force: true);
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<VehicleInspeController>()) {
        Get.delete<VehicleInspeController>(force: true);
      }
    } catch (_) {}

    Get.snackbar("Success", "Account & Location updated");
  }
}