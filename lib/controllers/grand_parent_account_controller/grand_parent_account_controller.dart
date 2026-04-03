import 'dart:convert';

import 'package:emtrack/models/grand_parent_account_model/assign_grand_parent_model.dart';
import 'package:emtrack/models/grand_parent_account_model/grand_parent_account_model.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:emtrack/services/grand_parent_account_service/grand_parent_account_service.dart';

import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../views/grand_parent_account_view/grandparent_account_list_view.dart';

class GrandparentAccountController extends GetxController {
  final service = GrandparentAccountService();

  /// Stepper
  RxInt currentStep = 0.obs;
  final int totalSteps = 2;

  final isloading = false.obs;

  /// Validation
  final createFormKey = GlobalKey<FormState>();


  /// Step-1 fields
  RxString accountType = 'OWNED'.obs;
  RxString grandparentName = ''.obs;

  /// Step-2 dropdown selections
  RxInt selectedParentId = 0.obs;
  RxInt selectedGrandparentId = 0.obs;
  RxString selectedParentName = 'Select Parent Account'.obs;
  RxString selectedGrandparentName = 'Select Grandparent Account'.obs;

  /// Dummy dropdown data (API se ayega)
  RxList<Map<String, dynamic>> parentAccounts = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>> grandparentAccounts =
      <Map<String, dynamic>>[].obs;
  // [
  //   {"id": 4, "name": "EMTTST_ADMIN Accounts"},
  // ].obs;

  /// Navigation
  void next() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  @override
  void onInit() {
    super.onInit();

    fetchParentAccounts();
    fetchGrandParentAccounts();
  }

  void previous() {
    if (currentStep.value > 0) {
      currentStep.value--;
      grandparentName.value = '';
    }
  }

  /// Submit Step-1
  Future<void> createGrandparent() async {
    final userName = await SecureStorage.getUserName();

    final model = GrandparentAccountModel(
      createdBy: userName.toString(),
      createdDate: DateTime.now().toIso8601String(),
      grandParentAccountName: grandparentName.value,
      isActive: true,
      ownedBy: accountType.value,
      updatedBy: userName.toString(),
      updatedDate: DateTime.now().toIso8601String(),
    );

    final isCreated = await service.createGrandparent(model);
    if (isCreated) {
      next();
    }
  }

  /// Submit Step-2
  Future<void> assignGrandparent() async {
    isloading.value = true;

    final model = AssignGrandparentModel(
      userId: selectedParentId.value,
      parentAccountId: selectedParentId.value,
      grandparentAccountId: selectedGrandparentId.value,
    );

    final data = await service.assignGrandparent(model);
    isloading.value = false;

    if (data) {
      Get.snackbar(
        "Success ",
        "Grandparent assigned successfully!\nUser ID: ${selectedParentId.value}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      await Future.delayed(Duration(seconds: 1));
      Get.to(() => GrandparentAccountListView());
    }
  }
  Future<void> fetchParentAccounts() async {
    try {
      // ✅ Added /0?timeStamp=0 as required by this endpoint
      final response = await ApiService.getApi(
        endpoint: "${ApiConstants.getParentAccountList}/0?timeStamp=0",
      );

      if (response != null && response['model'] != null) {
        final List data = response['model'];
        parentAccounts.value = data.map<Map<String, dynamic>>((item) {
          return {"id": item["parentAccountId"], "name": item["accountName"]};
        }).toList();
        print("✅ Parent Accounts fetched: ${parentAccounts.length}");
      } else {
        print("⚠️ No Parent Account data found in response");
      }
    } catch (e) {
      print("❌ fetchParentAccounts error: $e");
    }
  }

  Future<void> fetchGrandParentAccounts() async {
    try {
      final response = await ApiService.getApi(
        endpoint: ApiConstants.getGrandparentAccountList,
      );

      if (response != null && response['model'] != null) {
        final List data = response['model'];
        grandparentAccounts.value = data.map<Map<String, dynamic>>((item) {
          return {
            "id": item["grandParentAccountId"],
            "name": item["grandParentAccountName"],
          };
        }).toList();
        print("✅ Grandparent Accounts fetched: ${grandparentAccounts.length}");
      } else {
        print("⚠️ No Grandparent Account data found in response");
      }
    } catch (e) {
      print("❌ fetchGrandParentAccounts error: $e");
    }
  }
}
