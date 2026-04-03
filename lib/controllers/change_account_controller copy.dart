import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/controllers/home_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/controllers/all_tyre_controller.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import '../models/change_account_model.dart';
import '../services/change_account_service.dart';

class ChangeAccountController extends GetxController {
  final service = ChangeAccountService();

  RxBool ownSelected = false.obs;
  RxBool sharedSelected = false.obs;

  RxBool isLoading = false.obs;
  RxnString accountType = RxnString(); // nullable Rx

  RxList<ParentAccountModel> accounts = <ParentAccountModel>[].obs;
  RxList<LocationModel> locations = <LocationModel>[].obs;

  Rx<ParentAccountModel?> selectedAccount = Rx<ParentAccountModel?>(null);
  Rx<LocationModel?> selectedLocation = Rx<LocationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _restoreSelections();
    _restore();
    await loadParentAccounts();
  }

  Future<void> _restore() async {
    final own = await SecureStorage.getBool('own_selected');
    final shared = await SecureStorage.getBool('shared_selected');

    ownSelected.value = own ?? false; // first install → false
    sharedSelected.value = shared ?? false; // first install → false
  }

  /// 🔹 LOAD PARENT ACCOUNTS
  Future<void> loadParentAccounts() async {
    try {
      isLoading.value = true;
      accounts.value = await service.fetchParentAccounts();

      // restore parent AFTER list loaded
      final savedParentId = await SecureStorage.getParentAccountId();
      if (savedParentId != null) {
        selectedAccount.value = accounts.firstWhereOrNull(
          (e) => e.parentAccountId.toString() == savedParentId,
        );

        if (selectedAccount.value != null) {
          await loadLocations(selectedAccount.value!.parentAccountId);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _restoreSelections() async {
    // 🔘 RADIO RESTORE
    final savedType = await SecureStorage.getAccountType();

    if (savedType.isNotEmpty) {
      accountType.value = savedType; // own / shared
    } else {
      accountType.value = null; // 🟢 FIRST INSTALL → none selected
    }
    final own = await SecureStorage.getBool('own_selected');
    final shared = await SecureStorage.getBool('shared_selected');

    ownSelected.value = own ?? false; // first install → false
    sharedSelected.value = shared ?? false; //
    // 🔽 Parent restore
    final savedParentId = await SecureStorage.getParentAccountId();
    if (savedParentId != null) {
      selectedAccount.value = accounts.firstWhereOrNull(
        (e) => e.parentAccountId.toString() == savedParentId,
      );

      if (selectedAccount.value != null) {
        await loadLocations(selectedAccount.value!.parentAccountId);
      }
    }

    // 📍 Location restore
    final savedLocationId = await SecureStorage.getLocationId();
    if (savedLocationId != null) {
      selectedLocation.value = locations.firstWhereOrNull(
        (e) => e.locationId.toString() == savedLocationId,
      );
    }
  }

  /// 🔹 LOAD LOCATIONS (DEPENDENT)
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

  /// 🔹 ON ACCOUNT CHANGE
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

  void submit() async {
    if (selectedAccount.value == null || selectedLocation.value == null) return;

    /// 1️⃣ SAVE IN STORAGE
    await SecureStorage.saveParentAccount(
      id: selectedAccount.value!.parentAccountId.toString(),
      name: selectedAccount.value!.accountName,
    );

    await SecureStorage.saveLocation(
      id: selectedLocation.value!.locationId.toString(),
      name: selectedLocation.value!.locationName,
    );

    /// 2️⃣ UPDATE GLOBAL CONTROLLER
    final homeCtrl = Get.find<HomeController>();
    homeCtrl.updateSelectedAccount(
      parentAccountName: selectedAccount.value!.accountName,
      locationName: selectedLocation.value!.locationName,
    );
    homeCtrl.loadTyreCountByAccount();
    homeCtrl.loadVehicleCountByAccount();

    /// 3️⃣ GO BACK
    Get.back();
    final AllVehicleCtrl = Get.find<AllVehicleController>();
    await AllVehicleCtrl.loadVehicles();
    final tyreCtrl = Get.find<AllTyreController>();
    await tyreCtrl.fetchData(tyreCtrl.tabs[tyreCtrl.tabController!.index]);
    final selectedCtrl = Get.find<SelectedAccountController>();
    await selectedCtrl.refresh();

    /// 4️⃣ OPTIONAL CONFIRMATION
    Get.snackbar("Success", "Account & Location updated");
  }
}
