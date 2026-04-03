import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/controllers/home_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/controllers/all_tyre_controller.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/change_account_model.dart';
import '../services/change_account_service.dart';

class ChangeAccountController extends GetxController {
  final service = ChangeAccountService();

  RxBool ownSelected = false.obs;
  RxBool sharedSelected = false.obs;

  RxBool isLoading = false.obs;
  RxnString accountType = RxnString();

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
    await _restoreRadio();
    await loadParentAccounts();
    await _restoreParentAndLocation();
  }

  Future<void> _restoreRadio() async {
    final own = await SecureStorage.getBool('own_selected');
    final shared = await SecureStorage.getBool('shared_selected');
    ownSelected.value = own ?? false;
    sharedSelected.value = shared ?? false;

    final savedType = await SecureStorage.getAccountType();
    if (savedType == 'own' || savedType == 'shared') {
      accountType.value = savedType;
    } else {
      accountType.value = null;
    }
  }

  Future<void> loadParentAccounts() async {
    try {
      isLoading.value = true;
      accounts.value = await service.fetchParentAccounts();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _restoreParentAndLocation() async {
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

    final savedLocationId = await SecureStorage.getLocationId();
    if (savedLocationId != null && locations.isNotEmpty) {
      selectedLocation.value = locations.firstWhereOrNull(
            (e) => e.locationId.toString() == savedLocationId,
      );
    }
  }

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

  //   submit()
  void submit() async {
    if (selectedAccount.value == null || selectedLocation.value == null) {
      Get.snackbar(
        "Error",
        "Please select both account and location",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      await SecureStorage.saveParentAccount(
        id: selectedAccount.value!.parentAccountId.toString(),
        name: selectedAccount.value!.accountName,
      );
      await SecureStorage.saveLocation(
        id: selectedLocation.value!.locationId.toString(),
        name: selectedLocation.value!.locationName,
      );

      // 2. HomeController in-memory update
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.updateSelectedAccount(
          parentAccountName: selectedAccount.value!.accountName,
          locationName: selectedLocation.value!.locationName,
        );
        homeCtrl.loadTyreCountByAccount();
        homeCtrl.loadVehicleCountByAccount();
      }

      if (Get.isRegistered<AllVehicleController>()) {
        await Get.find<AllVehicleController>().loadVehicles();
      }
      if (Get.isRegistered<AllTyreController>()) {
        final tyreCtrl = Get.find<AllTyreController>();
        await tyreCtrl.fetchData(
          tyreCtrl.tabs[tyreCtrl.tabController!.index],
        );
      }
      if (Get.isRegistered<SelectedAccountController>()) {
        await Get.find<SelectedAccountController>().refresh();
      }

      // 4.  Get.back(result: true)
      Get.back(result: true);

      Get.snackbar(
        "Success",
        "Account & Location updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}