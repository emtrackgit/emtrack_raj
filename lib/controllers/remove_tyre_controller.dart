import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/models/masterDataMobileModel/Tire_remove_reason_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_desposition_model.dart';
import 'package:emtrack/models/remove_tyre_model.dart';
import 'package:emtrack/services/remove_tyre_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemoveTyreController extends GetxController {
  final service = RemoveTyreService();

  // 🔹 Model
  Rx<RemoveTyreModel> model = RemoveTyreModel(
    action: "Remove",
    inspectionDate: DateTime.now().toIso8601String(),
    locationId: 0,
    parentAccountId: 0,
    vehicleId: 0,
    inspectionId: 0,
    tireId: 0,
    currentHours: 0.0,
    currentMiles: 0.0,
    tireSerialNo: "",
    outsideTread: 0.0,
    middleTread: 0.0,
    insideTread: 0.0,
    currentTreadDepth: 0.0,
    currentPressure: 0.0,
    pressureUnitId: 1,
    casingConditionId: 1,
    wearConditionId: 1,
    comments: "",
    removalReasonId: 0,
    dispositionId: 0,
    rimDispositionId: 0,
    wheelPosition: "",
    mountedRimId: 0,
    createdBy: "mobile",
    pressureType: "PSI",
    hoursAdjustToTire: 0.0,
    milesAdjustToTire: 0.0,
    isMobInstall: false,
  ).obs;

  // 🔹 Dropdown data
  RxList<TireRemovalReason> reasons = <TireRemovalReason>[].obs;
  RxList<TireRemovalReason> filteredReasons = <TireRemovalReason>[].obs;
  RxList<TireDisposition> dispositions = <TireDisposition>[].obs;

  RxBool showReasonDropdown = false.obs;

  // 🔹 Controllers
  final TextEditingController reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // 🔹 Load master data
    _loadMasterData();

    // 🔹 Get arguments from previous screen
    final args = Get.arguments ?? {};
    model.update((m) {
      m!.vehicleId = args["vehicleId"] ?? 0;
      m.tireId = args["tireId"] ?? 0;
      m.wheelPosition = args["wheelPosition"] ?? "";
      m.tireSerialNo = args["tireSerialNo"] ?? "";
      m.currentHours = args["currentHours"] ?? 0.0;
      m.currentMiles = args["currentMiles"] ?? 0.0;
      m.outsideTread = args["outsideTread"] ?? 0.0;
      m.insideTread = args["insideTread"] ?? 0.0;
      m.currentTreadDepth = args["currentTreadDepth"] ?? 0.0;
      m.currentPressure = args["currentPressure"] ?? 0.0;
    });
    print("FINAL PAYLOAD => ${model.value.toJson()}");
  }

  // ==================================================
  // 🔹 Load master data (dispositions + removal reasons)
  // ==================================================
  Future<void> _loadMasterData() async {
    try {
      final master = await service.getMasterData();
      if (master != null) {
        // 🔹 Populate reasons
        reasons.assignAll(master.tireRemovalReasons);
        filteredReasons.assignAll(master.tireRemovalReasons);

        // 🔹 Populate dispositions
        dispositions.assignAll(master.tireDispositions);
        // ✅ DEBUG PRINTS YAHAN LAGAO
        print("Reasons count: ${reasons.length}");
        print("Dispositions count: ${dispositions.length}");
      } else {
        print("Master data is null");
        Get.snackbar("Error", "Failed to load master data");
      }
    } catch (e) {
      print("Failed to load master data: $e");
      Get.snackbar("Error", "Failed to load master data");
    }
  }

  // ==================================================
  // 🔹 Select removal reason
  // ==================================================
  void selectReason(TireRemovalReason reason) {
    reasonController.text = reason.reasonName;
    model.update((m) => m!.removalReasonId = reason.reasonId);
    showReasonDropdown.value = false;
  }

  // ==================================================
  // 🔹 Search removal reasons
  // ==================================================
  void searchReason(String value) {
    filteredReasons.assignAll(
      reasons.where(
        (r) => r.reasonName.toLowerCase().contains(value.toLowerCase()),
      ),
    );
  }

  // ==================================================
  // 🔹 Select disposition
  // ==================================================
  void selectDisposition(TireDisposition disposition) {
    model.update((m) => m!.dispositionId = disposition.dispositionId);
  }

  // ==================================================
  // 🔹 Submit remove tyre
  // ==================================================
  Future<void> submit() async {
    try {
      // 🔹 Get parentAccountId & locationId from secure storage
      final parentAccountIdStr = await SecureStorage.getParentAccountId();
      final locationIdStr = await SecureStorage.getLocationId();

      model.update((m) {
        m!.parentAccountId = int.tryParse(parentAccountIdStr ?? '') ?? 0;
        m.locationId = int.tryParse(locationIdStr ?? '') ?? 0;
        m.action = "Remove";
        m.inspectionDate = DateTime.now().toIso8601String();
        m.isMobInstall = false;
        m.createdBy = "mobile";
      });

      // 🔹 Submit to API
      final success = await service.submitRemoveTyre(model.value.toJson());

      if (success) {
        final vehicleCtrl = Get.find<VehicleInspeController>();
        // 🔥 Removed tyre ko list se hata do
        vehicleCtrl.inspectionResponse.update((val) {
          val?.model?.installedTires?.removeWhere(
            (t) => t.tireId == model.value.tireId,
          );
        });

        Get.back(); // 👈 IMPORTANT (Get.to nahi)
        Get.back();
        Get.snackbar("Success", "Tyre Removed Successfully");
      }
    } catch (e) {
      print("Failed to remove tyre: $e");
      Get.snackbar("Error", "Failed to remove tyre");
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
