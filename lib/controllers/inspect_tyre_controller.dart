import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/models/inspect_tyre_model.dart';
import 'package:emtrack/models/tyre_model.dart';
import 'package:emtrack/services/inspect_tyre_service.dart';
import 'package:emtrack/services/master_data_service.dart';
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

    final arg = Get.arguments;
    if (arg is InstalledTire) {
      tire = arg;
    } else if (arg is Map) {
      tire = InstalledTire(
        tireId: arg['tireId'] as int?,
        tireSerialNo: arg['tireSerialNo']?.toString(),
        wheelPosition: arg['wheelPosition']?.toString(),
        vehicleId: arg['vehicleId'] as int?,
        currentHours: (arg['currentHours'] as num?)?.toDouble(),
        currentMiles: (arg['currentMiles'] as num?)?.toDouble(),
        outsideTread: (arg['outsideTread'] as num?)?.toDouble(),
        insideTread: (arg['insideTread'] as num?)?.toDouble(),
        currentTreadDepth: (arg['currentTreadDepth'] as num?)?.toDouble(),
        currentPressure: (arg['currentPressure'] as num?)?.toDouble(),
        originalTread: (arg['originalTread'] as num?)?.toDouble(),
        removeAt: (arg['removeAt'] as num?)?.toDouble(),
        brandNo: arg['brandNo']?.toString(),
        inspectionDate: arg['inspectionDate']?.toString(),
      );
    } else {
      tire = InstalledTire();
    }

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
    model.update((m) {
      m!.vehicleId ??= tire.vehicleId;
      m.tireId ??= tire.tireId;
      m.tireSerialNo ??= tire.tireSerialNo;
      m.wheelPosition ??= tire.wheelPosition;
      m.currentHours ??= tire.currentHours;
      m.currentMiles ??= tire.currentMiles;
      m.brandNumber ??= tire.brandNo;
      m.originalTread ??= tire.originalTread;
      m.removeAt ??= tire.removeAt;
      m.outsideTread = (tire.outsideTread ?? m.outsideTread).toDouble();
      m.insideTread = (tire.insideTread ?? m.insideTread).toDouble();
      m.currentTreadDepth ??= tire.currentTreadDepth;
      m.currentPressure = (tire.currentPressure ?? m.currentPressure).toDouble();
      m.airPressure = m.currentPressure;
      m.comments = tire.comments ?? m.comments;
      final avg = ((m.outsideTread + m.insideTread) / 2);
      m.averageTread = avg.toStringAsFixed(2);
      m.currentTreadDepth ??= avg;
      if (m.inspectionDate == null && (tire.inspectionDate ?? '').isNotEmpty) {
        final raw = tire.inspectionDate!;
        final dt = DateTime.tryParse(raw);
        m.inspectionDate = dt;
      }
    });

    if (tire.tireId != null && tire.tireId! > 0) {
      try {
        final data = await service.getTireById(tire.tireId!);
        final t = TyreModel.fromJson(data);
        tyre.value = t;

        model.update((m) {
          m!.vehicleId ??= t.vehicleId ?? tire.vehicleId;
          m.tireId ??= t.tireId ?? tire.tireId;
          m.tireSerialNo ??= t.tireSerialNo ?? tire.tireSerialNo;
          m.wheelPosition ??= t.wheelPosition ?? tire.wheelPosition;
          m.brandNumber ??= t.brandNo ?? tire.brandNo;
          m.originalTread ??= t.originalTread ?? tire.originalTread;
          m.removeAt ??= t.removeAt ?? tire.removeAt;
          m.currentHours ??= t.currentHours ?? tire.currentHours;
          m.currentMiles ??= t.currentMiles ?? tire.currentMiles;
          m.currentTreadDepth ??= t.currentTreadDepth ?? t.averageTreadDepth;
          m.currentPressure = (t.currentPressure ?? m.currentPressure).toDouble();
          m.airPressure = m.currentPressure;
          if (t.outsideTread != null) m.outsideTread = t.outsideTread!;
          if (t.insideTread != null) m.insideTread = t.insideTread!;
          final avg = ((m.outsideTread + m.insideTread) / 2);
          m.averageTread = avg.toStringAsFixed(2);
          m.currentTreadDepth ??= avg;

          selectedCasingConditionId.value = t.casingConditionId ?? 0;
          selectedWearConditionsId.value = t.wearConditionId ?? 0;
        });

        final wearIndex = wearConditionsIdList.indexOf(
          selectedWearConditionsId.value,
        );
        if (wearIndex >= 0 && wearIndex < wearConditionsList.length) {
          wearConditionsId.text = wearConditionsList[wearIndex];
        }

        final casingIndex = casingConditionIdList.indexOf(
          selectedCasingConditionId.value,
        );
        if (casingIndex >= 0 && casingIndex < casingConditionList.length) {
          casingConditionsId.text = casingConditionList[casingIndex];
        }
      } catch (e) {
        print("❌ Get Tire fallback: $e");
      }
    }

    // Fallback defaults: if user hasn't selected and API didn't return ids
    if (selectedWearConditionsId.value == 0 &&
        wearConditionsIdList.isNotEmpty) {
      selectedWearConditionsId.value = wearConditionsIdList.first;
      wearConditionsId.text = wearConditionsList.isNotEmpty
          ? wearConditionsList.first
          : '';
    }
    if (selectedCasingConditionId.value == 0 &&
        casingConditionIdList.isNotEmpty) {
      selectedCasingConditionId.value = casingConditionIdList.first;
      casingConditionsId.text = casingConditionList.isNotEmpty
          ? casingConditionList.first
          : '';
    }
  }

  // =========================================================
  // COUNTERS
  // =========================================================
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

  void incAir() => model.update((m) {
    m!.airPressure = (m.airPressure ?? 0) + 1;
  });

  void decAir() => model.update((m) {
    final current = m!.airPressure ?? 0;
    if (current > 0) {
      m.airPressure = current - 1;
    }
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
        Get.snackbar(
          "Error",
          "Please select Casing Condition and Wear Condition",
        );
        return;
      }

      final outside = model.value.outsideTread ?? 0;
      final inside = model.value.insideTread ?? 0;

      final payload = {
        "action": "Inspect",
        "inspectionDate": DateTime.now().toIso8601String(),

        "locationId": locationId,
        "parentAccountId": parentAccountId,
        "vehicleId": tire.vehicleId ?? 0,

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
      Get.snackbar("Success", "Inspection Submitted!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
