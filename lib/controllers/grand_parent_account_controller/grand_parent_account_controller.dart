import 'dart:convert';

import 'package:emtrack/models/grand_parent_account_model/assign_grand_parent_model.dart';
import 'package:emtrack/models/grand_parent_account_model/grand_parent_account_model.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:emtrack/services/grand_parent_account_service/grand_parent_account_service.dart';

import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';

import '../../views/grand_parent_account_view/grandparent_account_list_view.dart';

class GrandparentAccountController extends GetxController {
  final service = GrandparentAccountService();

  /// Stepper
  RxInt currentStep = 0.obs;
  final int totalSteps = 2;

  final isloading = false.obs;

  /// Step-1 fields
  RxString accountType = 'OWNED'.obs;
  RxString grandparentName = ''.obs;

  /// Step-2 dropdown selections
  RxInt selectedParentId = 0.obs;
  RxInt selectedGrandparentId = 0.obs;

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
    try {
      if (selectedParentId.value <= 0) {
        Get.snackbar("Error", "Please select Parent Account",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (selectedGrandparentId.value <= 0) {
        Get.snackbar("Error", "Please select Grandparent Account",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      isloading.value = true;
      final model = AssignGrandparentModel(
        userId: selectedParentId.value,
        parentAccountId: selectedParentId.value,
        grandparentAccountId: selectedGrandparentId.value,
      );

      final ok = await service.assignGrandparent(model);
      if (ok) {
        Get.off(() => GrandparentAccountListView(), arguments: {
          "showSuccess": true,
          "msg": "Grandparent assigned successfully"
        });
        return;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isloading.value = false;
    }
  }

  Future<void> fetchParentAccounts() async {
    try {
      final response = await ApiService.getApi(
        endpoint: ApiConstants.getParentAccountList,
      );

      if (response['model'] != null && response['model'].length > 0) {
        final List data = response['model'];

        parentAccounts.value = data.map<Map<String, dynamic>>((item) {
          return {"id": item["parentAccountId"], "name": item["accountName"]};
        }).toList();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> fetchGrandParentAccounts() async {
    try {
      final response = await ApiService.getApi(
        endpoint: ApiConstants.getGrandparentAccountList,
      );

      if (response['model'] != null && response['model'].length > 0) {
        final List data = response['model'];

        grandparentAccounts.value = data.map<Map<String, dynamic>>((item) {
          return {
            "id": item["grandParentAccountId"],
            "name": item["grandParentAccountName"],
          };
        }).toList();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
}
