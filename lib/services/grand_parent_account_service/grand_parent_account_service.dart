import 'package:emtrack/models/grand_parent_account_model/assign_grand_parent_model.dart';
import 'package:emtrack/models/grand_parent_account_model/grand_parent_account_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:get/get.dart';

class GrandparentAccountService {
  Future<bool> createGrandparent(GrandparentAccountModel model) async {
    try {
      final response = await ApiService.postApi(
        endpoint: ApiConstants.createGrandParentAccount,
        body: model.toJson(),
      );

      if (response['httpStatusCode'] == 200) {
        Get.snackbar("Success", "Grandparent account created successfully");
      }
      return true;
    } catch (e) {
      print(" Failed to create grandparent: $e");
      Get.snackbar("Error", "Failed to create grandparent: $e");

      return false;
    }
  }

  Future<bool> assignGrandparent(AssignGrandparentModel model) async {
    try {
      final response = await ApiService.postApi(
        endpoint: ApiConstants.updateGrandParentAccount,
        body: model.toJson(),
      );

      if (response['httpStatusCode'] == 200) {
        // Get.snackbar("Success", "Grandparent Assigned Successfully");
      }
      return true;
    } catch (e) {
      print(" Failed to create grandparent: $e");
      //   Get.snackbar("Error", "Failed to create grandparent: $e");

      return false;
    }
  }
}
