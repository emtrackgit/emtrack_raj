import 'dart:io';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/inspection/vehicle_inspe_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';

class VehicleInspeController2 extends GetxController {
  final VehicleInspeService service = VehicleInspeService();
  final VehicleInspectionModel model = VehicleInspectionModel();

  final TextEditingController commentsCtrl = TextEditingController();
  final TextEditingController vehicleIdCtrl = TextEditingController();
  final TextEditingController hoursCtrl = TextEditingController();
  // Form fields
  RxString vehicleId = ''.obs;
  RxString hours = ''.obs;
  RxBool isSubmitting = false.obs;
  // Show warning card
  RxBool showHourWarning = true.obs;

  /// MODEL
  Rx<VehicleInspectionModel> inspection = VehicleInspectionModel(
    vehicleId: 2160,
    lastRecordedHours: 11551,
  ).obs;

  Future<void> submit() async {
    isSubmitting.value = true;
    await service.submitInspection(vehicleData: {});
    isSubmitting.value = false;
    Get.snackbar('Success', 'Inspection Submitted');
  }

  /// Update button clicked
  void onUpdateHours() {
    if (hours.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter hours before updating',
        backgroundColor: const Color(0xFFEFF4FA),
        colorText: const Color(0xFF0A5DB5),
      );
      return;
    }

    // Call API
    service.updateHours(vehicleId.value, hours.value).then((success) {
      if (success) {
        showHourWarning.value = false;
        Get.snackbar(
          'Success',
          'Hours updated successfully!',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        Get.snackbar(
          'Error',
          'Update failed!',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    });
  }

  void closeWarning() {
    showHourWarning.value = false;
  }

  // Images pick
  RxList<File> uploadedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  /// 📱 Android / iOS only
  Future<void> pickImageMobile(ImageSource source) async {
    print("pickImageMobile called");

    try {
      // ❗ SAFETY CHECK
      if (!Platform.isAndroid && !Platform.isIOS) {
        debugPrint("Not a mobile platform");
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        uploadedImages.add(File(image.path));
        debugPrint("Image picked: ${image.path}");
      } else {
        debugPrint("Image picker cancelled");
      }
    } catch (e) {
      debugPrint('Mobile pick error: $e');
    }
  }
}
