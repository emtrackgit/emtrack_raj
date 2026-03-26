import 'package:emtrack/services/all_vehicles_services.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/all_vehicle_account_model.dart';

class AllVehicleController extends GetxController {
  final AllVehicleService _service = AllVehicleService();

  // ==================================================
  // 📦 DATA LISTS
  // ==================================================
  final RxList<AccountVehicleModel> vehicleList = <AccountVehicleModel>[].obs;
  final RxList<AccountVehicleModel> filteredList = <AccountVehicleModel>[].obs;

  // ==================================================
  // 🔍 SEARCH
  // ==================================================
  final RxString searchText = ''.obs;
  final RxBool isFilterApplied = false.obs;

  // ==================================================
  // 🎯 FILTER VALUES
  // ==================================================
  final RxString selectedType = ''.obs;
  final RxString selectedMake = ''.obs;
  final RxString selectedModel = ''.obs;

  final RxString tempValue = ''.obs;

  // ==================================================
  // 🚀 INIT
  // ==================================================
  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  // ==================================================
  // 📡 LOAD VEHICLES (SAFE VERSION)
  // ==================================================
  Future<void> loadVehicles() async {
    try {
      final String? storedParentId = await SecureStorage.getParentAccountId();

      print("🔥 STORED PARENT ID => $storedParentId");

      if (storedParentId == null || storedParentId.isEmpty) {
        Get.snackbar('Error', 'Parent Account not selected');
        return;
      }

      final int? parentId = int.tryParse(storedParentId);

      if (parentId == null) {
        Get.snackbar('Error', 'Invalid Parent Account ID');
        return;
      }

      final data = await _service.getVehiclesByAccount(
        parentAccountId: parentId,
      );

      vehicleList.assignAll(data);
      filteredList.assignAll(data);

      print("✅ VEHICLES LOADED => ${data.length}");
    } catch (e, s) {
      print("🔥 Controller Error => $e");
      print(s);
      Get.snackbar('Error', e.toString());
    }
  }

  // ==================================================
  // 🔄 REFRESH
  // ==================================================
  Future<void> refreshVehicles() async {
    await loadVehicles();
  }

  // ==================================================
  // 🔍 SEARCH LOGIC
  // ==================================================
  void onSearch(String value) {
    searchText.value = value.toLowerCase();
    isFilterApplied.value = value.isNotEmpty;

    filteredList.assignAll(
      vehicleList.where((v) {
        return v.vehicleId.toString().contains(searchText.value) ||
            (v.vehicleNumber ?? '').toLowerCase().contains(searchText.value) ||
            (v.manufacturerName ?? '').toLowerCase().contains(
              searchText.value,
            ) ||
            (v.modelName ?? '').toLowerCase().contains(searchText.value) ||
            (v.axleConfig ?? '').toLowerCase().contains(searchText.value) ||
            (v.typeName ?? '').toLowerCase().contains(searchText.value);
      }).toList(),
    );
  }

  // ==================================================
  // 🎯 APPLY FILTER
  // ==================================================
  void applyFilter() {
    isFilterApplied.value = true;

    filteredList.assignAll(
      vehicleList.where((v) {
        final typeMatch =
            selectedType.value.isEmpty ||
            (v.typeName ?? '') == selectedType.value;

        final makeMatch =
            selectedMake.value.isEmpty ||
            (v.manufacturerName ?? '') == selectedMake.value;

        final modelMatch =
            selectedModel.value.isEmpty ||
            (v.modelName ?? '') == selectedModel.value;

        return typeMatch && makeMatch && modelMatch;
      }).toList(),
    );
  }

  // ==================================================
  // ❌ CLEAR FILTER
  // ==================================================
  void clearFilter() {
    selectedType.value = '';
    selectedMake.value = '';
    selectedModel.value = '';
    isFilterApplied.value = false;
    filteredList.assignAll(vehicleList);
  }

  // ==================================================
  // 📌 OPEN SELECTION DIALOG
  // ==================================================
  void openSelectionDialog({
    required String title,
    required List<String> items,
    required RxString selectedValue,
  }) {
    tempValue.value = selectedValue.value;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            height: 250,
            child: Obx(
              () => ListView(
                children: items.map((e) {
                  return RadioListTile<String>(
                    title: Text(e),
                    value: e,
                    groupValue: tempValue.value,
                    onChanged: (val) => tempValue.value = val ?? '',
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                selectedValue.value = tempValue.value;
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // 📋 GET UNIQUE FILTER LISTS
  // ==================================================
  List<String> get typeList =>
      vehicleList.map((e) => e.typeName ?? '').toSet().toList();

  List<String> get makeList =>
      vehicleList.map((e) => e.manufacturerName ?? '').toSet().toList();

  List<String> get modelList =>
      vehicleList.map((e) => e.modelName ?? '').toSet().toList();
}
