import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/models/inspect_tyre_model.dart';
import 'package:emtrack/models/tyre_model.dart';
import 'package:emtrack/services/inspect_tyre_service.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/app_snackbar.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/remove_tyre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class InspectTyreController extends GetxController {
  final InspectTyreService service = InspectTyreService();
  final MasterDataService _masterService = MasterDataService();

  final RxList<InstalledTire> tires = <InstalledTire>[].obs;
  final picker = ImagePicker();

  late InstalledTire tire;

  /// Dropdown Data
  final wearConditionsId = TextEditingController();
  final wearConditionsList = <String>[].obs;
  final wearConditionsIdList = <int>[].obs;
  final selectedWearConditionsId = 0.obs;

  final casingConditionsId = TextEditingController();
  final casingConditionList = <String>[].obs;
  final casingConditionIdList = <int>[].obs;
  final selectedCasingConditionId = 0.obs;

  Rx<InspectTyreModel> model = InspectTyreModel().obs;
  Rx<TyreModel?> tyre = Rx<TyreModel?>(null);

  // =========================================================
  // INIT
  // =========================================================
  @override
  void onInit() async {
    super.onInit();

    tire = Get.arguments as InstalledTire;

    await loadMasterData();
    await loadTireData();
  }

  // =========================================================
  // LOAD MASTER DATA
  // =========================================================
  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();

      wearConditionsList.assignAll(
        (data['wearConditions'] as List)
            .map((e) => e['wearConditionName'].toString())
            .toList(),
      );

      wearConditionsIdList.assignAll(
        (data['wearConditions'] as List)
            .map((e) => e['wearConditionId'] as int)
            .toList(),
      );

      casingConditionList.assignAll(
        (data['casingCondition'] as List)
            .map((e) => e['casingConditionName'].toString())
            .toList(),
      );

      casingConditionIdList.assignAll(
        (data['casingCondition'] as List)
            .map((e) => e['casingConditionId'] as int)
            .toList(),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // =========================================================
  // LOAD TIRE DATA
  // =========================================================
  Future<void> loadTireData() async {
    if (tire.tireId != null && tire.tireId! > 0) {
      try {
        final data = await service.getTireById(tire.tireId!);
        model.value = InspectTyreModel.fromJson(data);

        // Update dropdowns from the fetched model
        selectedCasingConditionId.value = model.value.casingConditionId ?? 0;
        selectedWearConditionsId.value = model.value.wearConditionId ?? 0;
      } catch (e) {
        print("❌ API fallback: $e");
      }
    }

    model.update((m) {
      m!.outsideTread = m.outsideTread ?? 0.0;
      m.insideTread = m.insideTread ?? 0.0;
      m.airPressure = m.airPressure ?? tire.currentPressure?.toDouble() ?? 0.0;
      m.vehicleId = tire.vehicleId;
      m.comments = tire.comments ?? "";
    });
  }
  // =========================================================
  // COUNTERS
  // =========================================================

  void incAir() => model.update((m) {
    m!.airPressure = (m.airPressure ?? 0) + 1;
  });

  void decAir() => model.update((m) {
    if ((m!.airPressure ?? 0) > 0) {
      m.airPressure = m.airPressure! - 1;
    }
  });
  void incOutside() => model.update((m) {
    m!.outsideTread++;
    _calcAverage(m);
  });

  void decOutside() => model.update((m) {
    if (m!.outsideTread > 0) m.outsideTread--;
    _calcAverage(m);
  });

  void incInside() => model.update((m) {
    m!.insideTread++;
    _calcAverage(m);
  });

  void decInside() => model.update((m) {
    if (m!.insideTread > 0) m.insideTread--;
    _calcAverage(m);
  });



  void _calcAverage(InspectTyreModel m) {
    m.averageTread = ((m.outsideTread + m.insideTread) / 2).toStringAsFixed(2);
  }

  // =========================================================
  // IMAGE PICK
  // =========================================================
  Future<void> pickImage(ImageSource source) async {
    final img = await picker.pickImage(source: source);
    if (img != null) {
      model.update((m) => m!.images.add(img.path));
    }
  }

  // =========================================================
  // REMOVE
  // =========================================================
  void removeTyre(int tireId) {
    model.value = InspectTyreModel(tireId: tireId);
    Get.to(() => RemoveTyreView());
  }

  // =========================================================
  // SUBMIT
  // =========================================================
  Future<void> submit() async {
    try {
      final parentAccountIdStr = await SecureStorage.getParentAccountId();
      final locationIdStr = await SecureStorage.getLocationId();

      final parentAccountId = int.tryParse(parentAccountIdStr ?? '') ?? 0;
      final locationId = int.tryParse(locationIdStr ?? '') ?? 0;

      if (selectedCasingConditionId.value == 0 ||
          selectedWearConditionsId.value == 0) {
        Get.snackbar("Error", "Please select casing & wear condition");
        return;
      }

      final outside = model.value.outsideTread ?? 0;
      final inside = model.value.insideTread ?? 0;

      final payload = {
        "action": "Inspect",
        "inspectionDate": DateTime.now().toIso8601String(),

        "locationId": locationId,
        "parentAccountId": parentAccountId,
        "vehicleId": tire.vehicleId ?? model.value.vehicleId ?? 0,
        "inspectionId": 0,

        "currentHours": tire.currentHours?.toInt() ?? 0,
        "currentMiles": tire.currentMiles?.toInt() ?? 0,

        "imagesLocation": "",

        "tireSerialNo": tire.tireSerialNo ?? "",
        "brandNumber": tire.brandNo ?? "",

        "originalTread": (tire.originalTread ?? 0).toDouble(),
        "removeAt": (tire.removeAt ?? 0).toDouble(),

        "outsideTread": outside,
        "middleTread": 0,
        "insideTread": inside,

        "currentTreadDepth": ((outside + inside) / 2).toDouble(),

        "currentPressure": model.value.airPressure?.toDouble() ?? 0,

        "pressureUnitId": 1,

        "casingConditionId": selectedCasingConditionId.value,
        "wearConditionId": selectedWearConditionsId.value,

        "comments": model.value.comments ?? "",

        "removalReasonId": 0,
        "dispositionId": 0,
        "rimDispositionId": 0,

        "wheelPosition": tire.wheelPosition ?? "",
        "mountedRimId": tire.mountedRimId ?? 0,

        "createdBy": "mobile",
        "pressureType": "Hot",

        "hoursAdjustToTire": 0,
        "milesAdjustToTire": 0,

        "isMobInstall": false,
      };

      if (tire.tireId != null && tire.tireId! > 0) {
        payload["tireId"] = tire.tireId;
      }

      print("📤 PAYLOAD => $payload");

      await service.submitInspection(payload);

      Get.back();
      AppSnackbar.success("Inspection Submitted!");
    } catch (e) {
      AppSnackbar.error(e.toString());
    }
  }
}
