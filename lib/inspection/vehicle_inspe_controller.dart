import 'dart:io';
import 'package:emtrack/inspection/update_hours_view.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/inspection/vehicle_inspe_service.dart';
import 'package:emtrack/models/tyre_model.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VehicleInspeController extends GetxController {
  final VehicleInspeService service = VehicleInspeService();
  RxList<InstalledTire> tires = <InstalledTire>[].obs;
  VehicleInspectionModel? model;

  final TextEditingController commentsCtrl       = TextEditingController();
  final TextEditingController vehicleNumberCtrl  = TextEditingController();
  final TextEditingController vehicleIdCtrl      = TextEditingController();
  final TextEditingController hoursCtrl          = TextEditingController();

  RxString vehicleId       = ''.obs;
  RxString hours           = ''.obs;
  RxBool isSubmitting      = false.obs;
  RxBool showHourWarning   = true.obs;

  Rxn<VehicleInspectionResponse> inspectionResponse = Rxn<VehicleInspectionResponse>();

  @override
  void onInit() {
    super.onInit();
    var argVehicleId = Get.arguments;
    vehicleId.value = argVehicleId.toString();
    vehicleIdCtrl.text = argVehicleId.toString();
    fetchInspectionData();
  }

  Future<void> fetchInspectionData() async {
    final response = await service.getInspectionRecord(vehicleId.value);

    if (response != null && response.didError == false) {
      inspectionResponse.value = response;
      model = response.model;

      tires.assignAll(model?.installedTires ?? []);

      print("Installed Tires Count: ${tires.length}");
      for (var t in tires) {
        print("Serial => ${t.tireSerialNo}  WheelPosition => ${t.wheelPosition}");
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
      print("❌ Failed to load inspection data or didError = true");
    }
  }

  void addInstalledTyreLocally(TyreModel tyreModel) {
    try {
      tires.removeWhere(
            (t) => t.wheelPosition?.trim() == tyreModel.wheelPosition?.trim(),
      );

      final installedTire = InstalledTire(
        tireId:           tyreModel.tireId,
        tireSerialNo:     tyreModel.tireSerialNo,
        wheelPosition:    tyreModel.wheelPosition,
        currentTreadDepth: tyreModel.currentTreadDepth,
        currentPressure:  tyreModel.currentPressure,
        currentHours:     tyreModel.currentHours,
        outsideTread:     tyreModel.outsideTread,
        insideTread:      tyreModel.insideTread,
        dispositionId:    tyreModel.dispositionId,
        casingConditionId: tyreModel.casingConditionId,
        wearConditionId:  tyreModel.wearConditionId,
        percentageWorn:   tyreModel.percentageWorn,
        originalTread:    tyreModel.originalTread,
        sizeName:         tyreModel.sizeName,
        typeName:         tyreModel.typeName,
        manufacturerName: tyreModel.manufacturerName,
      );

      tires.add(installedTire);

      print("✅ Locally added tire to diagram: ${tyreModel.tireSerialNo} @ ${tyreModel.wheelPosition}");
      print("📊 Total installed tires now: ${tires.length}");
    } catch (e) {
      print("⚠️ addInstalledTyreLocally error: $e");
    }
  }

  String _getTireAction(InstalledTire tire) {
    if (tire.tireId == null || tire.tireId == 0) return "Install";
    return "Inspect";
  }

  Future<void> submit() async {
    try {
      isSubmitting.value = true;

      final parentAccountId   = await SecureStorage.getParentAccountId();
      final parentAccountName = await SecureStorage.getParentAccountName();
      final locationId        = await SecureStorage.getLocationId();

      if (model == null) {
        Get.snackbar("Error", "Vehicle data not loaded");
        isSubmitting.value = false;
        return;
      }

      if (tires.isEmpty) {
        Get.snackbar("Error", "No tires found for this vehicle");
        isSubmitting.value = false;
        return;
      }

      bool allSuccess    = true;
      List<String> failedTires = [];

      for (var tire in tires) {
        final String action = _getTireAction(tire);

        final vehicleData = {
          "action":           action,
          "inspectionDate":   DateTime.now().toIso8601String(),
          "locationId":       int.tryParse(locationId ?? "0") ?? 0,
          "parentAccountId":  int.tryParse(parentAccountId ?? "0") ?? 0,
          "vehicleId":        model!.vehicleId ?? 0,
          "inspectionId":     0,
          "tireId":           tire.tireId ?? 0,
          "currentHours":     double.tryParse(hoursCtrl.text) ?? 0.0,
          "currentMiles":     tire.currentMiles ?? 0.0,
          "imagesLocation":   "",
          "tireSerialNo":     tire.tireSerialNo ?? "",
          "brandNumber":      tire.brandNo ?? "",
          "originalTread":    tire.originalTread ?? 0.0,
          "removeAt":         tire.removeAt ?? 0.0,
          "outsideTread":     tire.outsideTread ?? 0.0,
          "middleTread":      tire.middleTread ?? 0.0,
          "insideTread":      tire.insideTread ?? 0.0,
          "currentTreadDepth": tire.currentTreadDepth ?? 0.0,
          "currentPressure":  tire.currentPressure ?? 0.0,
          "pressureUnitId":   tire.pressureType ?? 0,
          "casingConditionId": tire.casingConditionId ?? 0,
          "wearConditionId":  tire.wearConditionId ?? 0,
          "comments":         commentsCtrl.text.trim(),
          "removalReasonId":  tire.removalReasonId ?? 0,
          "dispositionId":    tire.dispositionId ?? 0,
          "rimDispositionId": tire.dispositionId ?? 0,
          "wheelPosition":    tire.wheelPosition ?? "",
          "mountedRimId":     tire.mountedRimId ?? 0,
          "createdBy":        parentAccountName ?? "",
          "pressureType":     tire.pressureType ?? "",
          "hoursAdjustToTire": 0.0,
          "milesAdjustToTire": 0.0,
          "isMobInstall":     false,
        };

        bool result = await service.submitInspection(vehicleData: vehicleData);

        if (!result) {
          allSuccess = false;
          failedTires.add(tire.tireSerialNo ?? "Unknown");
        }
      }

      if (allSuccess) {
        Get.toNamed(AppPages.HOME);
        Get.snackbar(
          "Success", "Vehicle Inspection Submitted Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          "Partial Failure", "Failed tires: ${failedTires.join(', ')}",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> goToUpdateHours() async {
    final result = await Get.to(
          () => UpdateHoursView(),
      arguments: int.parse(vehicleId.value),
    );

    if (result != null) {
      hours.value = result.toString();
      hoursCtrl.text = result.toString();
      model?.lastRecordedHours = result;
    }
  }

  void closeWarning() => showHourWarning.value = false;

  RxList<File> uploadedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageMobile(ImageSource source) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) uploadedImages.add(File(image.path));
    } catch (e) {
      debugPrint('Mobile pick error: $e');
    }
  }

  @override
  void onClose() {
    commentsCtrl.dispose();
    vehicleNumberCtrl.dispose();
    vehicleIdCtrl.dispose();
    hoursCtrl.dispose();
    super.onClose();
  }
}
