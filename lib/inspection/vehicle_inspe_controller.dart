import 'dart:io';
import 'package:emtrack/inspection/update_hours_view.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/inspection/vehicle_inspe_service.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';

class VehicleInspeController extends GetxController {
  final VehicleInspeService service = VehicleInspeService();
  RxList<InstalledTire> tires = <InstalledTire>[].obs;
  VehicleInspectionModel? model;

  final TextEditingController commentsCtrl = TextEditingController();
  final TextEditingController vehicleNumberCtrl = TextEditingController();
  final TextEditingController vehicleIdCtrl = TextEditingController();
  final TextEditingController hoursCtrl = TextEditingController();

  RxString vehicleId = ''.obs;
  RxString hours = ''.obs;
  RxBool isSubmitting = false.obs;
  RxBool showHourWarning = true.obs;

  /// 🔥 ADD THIS (API RESPONSE HOLDER)
  Rxn<VehicleInspectionResponse> inspectionResponse =
      Rxn<VehicleInspectionResponse>();

  @override
  void onInit() {
    super.onInit();

    var argVehicleId = Get.arguments;
    // print("🆔 vehicle VEHICLE ID => $argVehicleId");

    vehicleId.value = argVehicleId.toString();
    vehicleIdCtrl.text = argVehicleId.toString();

    // vehicleId.value = argVehicleId.toString();
    // vehicleIdCtrl.text = argVehicleId.toString();

    /// 🔥 CALL GET API HERE
    fetchInspectionData();
  }

  /// 🔥 NEW FUNCTION (GET DATA FROM API)
  Future<void> fetchInspectionData() async {
    final response = await service.getInspectionRecord(vehicleId.value);

    if (response != null && response.didError == false) {
      inspectionResponse.value = response;

      model = response.model; // 🔥 IMPORTANT LINE

      tires.assignAll(model?.installedTires ?? []);
      final vehicleIdInt = model?.vehicleId;
      final lastHours = model?.lastRecordedHours;
      final lastMiles = model?.lastRecordedMiles;
      for (final t in tires) {
        t.vehicleId ??= vehicleIdInt;
        t.currentHours ??= lastHours;
        t.currentMiles ??= lastMiles;
      }

      /// 🔥🔥 ADD THIS LINE
      print("Installed Tires Count: ${tires.length}");

      for (var t in tires) {
        print("Serial => ${t.tireSerialNo}");
      }
      vehicleNumberCtrl.text = model!.vehicleNumber.toString();
      hours.value = model?.lastRecordedHours?.toString() ?? "";
      hoursCtrl.text = hours.value;
      commentsCtrl.text = model?.comments ?? "";
      print("🔄 Refreshed Hours: ${hours.value}");
      print("✅ Inspection data loaded");
      print("VehicleId: ${model?.vehicleId}");
      print("Hours: ${model?.lastRecordedHours}");
      print("Date: ${model?.lastRecordedDate}");
    } else {
      if (response != null && response.didError == false) {
        inspectionResponse.value = response;
        model = response.model;
      } else {
        // Get.snackbar(
        // "Error",
        //  response?.errorMessage ?? "Failed to load inspection data",
        // );
      }
    }
  }

  Future<void> submit() async {
    try {
      isSubmitting.value = true;

      final parentAccountId = await SecureStorage.getParentAccountId();
      final parentAccountName = await SecureStorage.getParentAccountName();
      final locationId = await SecureStorage.getLocationId();

      if (model == null) {
        Get.snackbar("Error", "Vehicle data not loaded");
        isSubmitting.value = false;
        return;
      }

      // final isHoursBased =
      //     (model!.installedTires!.first.mileageType ?? "").toLowerCase() ==
      //     "hours";

      for (var tire in tires) {
        final vehicleData = {
          "action":
              "Remove", // ya "Remove" / "Install" backend enum ke according

          "inspectionDate": DateTime.now().toIso8601String(),

          "locationId": int.tryParse(locationId ?? "0") ?? 0,
          "parentAccountId": int.tryParse(parentAccountId ?? "0") ?? 0,

          "vehicleId": model!.vehicleId ?? 0,
          "inspectionId": 0,

          "tireId": tire.tireId ?? 0,

          "currentHours": double.tryParse(hoursCtrl.text) ?? 0.0,
          "currentMiles": tire.currentMiles ?? 0.0,

          "imagesLocation": "",

          "tireSerialNo": tire.tireSerialNo ?? "",
          "brandNumber": tire.brandNo ?? "",

          "originalTread": tire.originalTread ?? 0.0,
          "removeAt": tire.removeAt ?? 0.0,

          "outsideTread": tire.outsideTread ?? 0.0,
          "middleTread": tire.middleTread ?? 0.0,
          "insideTread": tire.insideTread ?? 0.0,

          "currentTreadDepth": tire.currentTreadDepth ?? 0.0,

          "currentPressure": tire.currentPressure ?? 0.0,

          "pressureUnitId": tire.pressureType ?? 0, // ⚠ int hona chahiye
          "casingConditionId": tire.casingConditionId ?? 0,
          "wearConditionId": tire.wearConditionId ?? 0,

          "comments": commentsCtrl.text.trim(),

          "removalReasonId": tire.removalReasonId ?? 0,
          "dispositionId": tire.dispositionId ?? 0,
          "rimDispositionId": tire.dispositionId ?? 0,

          "wheelPosition": tire.wheelPosition ?? "",

          "mountedRimId": tire.mountedRimId ?? 0,

          "createdBy": parentAccountName ?? "",

          "pressureType": tire.pressureType ?? "",

          "hoursAdjustToTire": 0.0,
          "milesAdjustToTire": 0.0,

          "isMobInstall": false,
        };

        print("📤 SUBMIT BODY => $vehicleData");

        bool result = await service.submitInspection(vehicleData: vehicleData);

        if (!result) {
          Get.snackbar("Error", "Failed to submit tire ${tire.tireSerialNo}");
        }
      }
      commentsCtrl.clear();
      Get.toNamed(AppPages.HOME);
      Get.snackbar(
        backgroundColor: Colors.green,
        colorText: Colors.white,
        "Success",
        "Vehicle Inspection Submitted ${tires.first.tireSerialNo} Successfully",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print("❌ Submit Exception: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> goToUpdateHours() async {
    final result = await Get.to(
      () => UpdateHoursView(),
      arguments: int.parse(vehicleId.value),
    );

    /// 🔥 Agar update hua hai to value yaha milegi
    if (result != null) {
      hours.value = result.toString();
      hoursCtrl.text = result.toString();

      /// model bhi update kar do
      model?.lastRecordedHours = result;

      print("✅ UI updated with new hours: $result");
    }
  }

  void closeWarning() {
    showHourWarning.value = false;
  }

  /// ------------------ IMAGE PICKER CODE (UNCHANGED) ------------------

  RxList<File> uploadedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageMobile(ImageSource source) async {
    print("pickImageMobile called");

    try {
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
