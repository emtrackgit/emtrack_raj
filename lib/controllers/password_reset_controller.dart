import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ResetPasswordController extends GetxController {
  var currentStep = 0.obs;

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();

  void goToStep2() {
    if (formKey1.currentState!.validate()) {
      // Call send token API here
      currentStep.value = 1;
    }
  }

  void goBack() {
    currentStep.value = 0;
  }

  Future<void> sendtokenPassword() async {
    if (!formKey1.currentState!.validate()) return;

    try {
      final response = await ApiService.postApi(
        endpoint: ApiConstants.sendPasswordToken,
        body: {'username': usernameController.text.trim()},
      );

      if (response != null && response['message'] != null) {
        Get.snackbar(
          "Success",
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        goToStep2();
      } else {
        Get.snackbar(
          "Error",
          "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resetPassword() async {
    if (!formKey2.currentState!.validate()) return;

    try {
      final response = await ApiService.postApi(
        endpoint: ApiConstants.resetPassword,
        body: {
          "username": usernameController.text.trim(),
          "token": tokenController.text.trim(),
          "newPassword": newPasswordController.text.trim(),
        },
      );

      if (response != null && response['message'] != null) {
        Get.snackbar(
          "Success",
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 200));

        Get.to(AppPages.LOGIN);
      } else {
        Get.snackbar(
          "Error",
          "Password reset failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
