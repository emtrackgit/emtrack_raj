import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/models/update_hours_model.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emtrack/services/update_hours_service.dart';
import 'package:intl/intl.dart';

class UpdateHoursController extends GetxController {
  // Reactive variables
  var lastRecordedHours = 0.0.obs;
  var lastRecordedMiles = 0.0.obs;
  var surveyDate = "".obs;
  var vehicleNumber = "".obs;
  var lastRecordedDate = "".obs;
  var vehicleId = 0.obs;
  var loading = false.obs;

  RxnString updateHoursError = RxnString();

  final updateHoursService = UpdateHoursService();

  // Text controllers
  TextEditingController updateHoursController = TextEditingController();
  TextEditingController surveyDateController = TextEditingController();
  TextEditingController vehicleIdCtrl = TextEditingController();

  // The vehicle model passed via arguments
  VehicleInspectionModel? vehicleModel;

  @override
  void onInit() {
    super.onInit();

    vehicleModel = Get.arguments as VehicleInspectionModel?;

    // ✅ Current date in consistent dd/MM/yyyy format
    String currentDate = DateFormat("dd/MM/yyyy").format(DateTime.now());

    if (vehicleModel != null) {
      vehicleId.value = vehicleModel!.vehicleId ?? 0;
      lastRecordedHours.value = vehicleModel!.lastRecordedHours ?? 0.0;
      lastRecordedMiles.value = vehicleModel!.lastRecordedMiles ?? 0.0;

      // ✅ FIX: formatDate handles both ISO and pre-formatted strings
      lastRecordedDate.value = formatDate(vehicleModel!.lastRecordedDate);

      surveyDate.value = currentDate;
      vehicleNumber.value = vehicleModel!.vehicleNumber ?? '';

      updateHoursController.clear();
      surveyDateController.text = currentDate; // ✅ dd/MM/yyyy
      vehicleIdCtrl.text = vehicleId.value.toString();

      print("✅ Vehicle data loaded from argument:");
      print("VehicleId: ${vehicleId.value}");
      print("Raw lastRecordedDate from API: ${vehicleModel!.lastRecordedDate}");
      print("Formatted lastRecordedDate: ${lastRecordedDate.value}");
      print("Hours: ${lastRecordedHours.value}");
    } else {
      print("❌ Vehicle model not passed in Get.arguments!");
    }
  }

  void pickSurveyDate(BuildContext context) async {
    // ✅ Parse surveyDate back to DateTime for initialDate
    DateTime? initialDate;
    try {
      initialDate = DateFormat("dd/MM/yyyy").parse(surveyDate.value);
    } catch (_) {
      initialDate = DateTime.now();
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // ✅ Consistent dd/MM/yyyy format
      final formatted = DateFormat("dd/MM/yyyy").format(picked);
      surveyDateController.text = formatted;
      surveyDate.value = formatted;
    }
  }

  Future<void> submitUpdateHours() async {
    loading.value = true;

    try {
      final updatedHours = double.tryParse(updateHoursController.text) ?? 0.0;

      final locationIdStr = await SecureStorage.getLocationId();
      final parentAccountIdStr = await SecureStorage.getParentAccountId();

      final locationId = int.tryParse(locationIdStr ?? "");
      final parentAccountId = int.tryParse(parentAccountIdStr ?? "");

      if (locationId == null || parentAccountId == null) {
        Get.snackbar("Error", "Location or ParentAccount missing");
        loading.value = false;
        return;
      }

      final model = UpdateHoursModel(
        action: "UpdateHours",
        inspectionDate: DateTime.now(),
        locationId: locationId,
        parentAccountId: parentAccountId,
        vehicleId: vehicleId.value,
        currentHours: updatedHours,
        currentMiles: lastRecordedMiles.value,
        hoursAdjustToTire: 0,
        milesAdjustToTire: 0,
        isMobInstall: true,
      );

      bool result = await updateHoursService.submitUpdate(model);

      if (result) {
        Get.snackbar(
          "Success",
          "Hours updated successfully on Vehicle",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );

        // Refresh previous screen
        try {
          final vehicleController = Get.find<VehicleInspeController>();
          await vehicleController.fetchInspectionData();
        } catch (e) {
          print("VehicleInspeController not found: $e");
        }

        Get.back(result: updatedHours); // ✅ Single back call
      } else {
        Get.snackbar("Error", "Update Failed");
      }
    } catch (e) {
      print("❌ Exception: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      loading.value = false;
    }
  }

  String? validateHours() {
    if (updateHoursController.text.trim().isEmpty) {
      return "Please enter hours";
    }

    double lastHours = lastRecordedHours.value;
    double enteredHours =
        double.tryParse(updateHoursController.text.trim()) ?? 0;

    if (enteredHours <= lastHours) {
      return "Value must be greater than last recorded hours (${lastHours.toStringAsFixed(2)})";
    }

    return null; // ✅ valid
  }

  /// ✅ FIX: Handles both ISO format (2026-03-25T00:00:00) and
  /// pre-formatted (03/25/2026 or 25/03/2026) from API
  String formatDate(String? apiDate) {
    if (apiDate == null || apiDate.isEmpty) return "";

    // Try ISO 8601 first (most common from APIs)
    try {
      DateTime parsedDate = DateTime.parse(apiDate);
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (_) {}

    // Try MM/dd/yyyy (US format sometimes returned by APIs)
    try {
      DateTime parsedDate = DateFormat("MM/dd/yyyy").parse(apiDate);
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (_) {}

    // Try dd/MM/yyyy (already correct format)
    try {
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(apiDate);
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (_) {}

    print("⚠️ Could not parse date: $apiDate");
    return apiDate; // last resort fallback
  }

  @override
  void onClose() {
    updateHoursController.dispose();
    surveyDateController.dispose();
    vehicleIdCtrl.dispose();
    super.onClose();
  }
}