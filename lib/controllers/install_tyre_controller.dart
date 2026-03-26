import 'dart:convert';
import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/inspection/vehicle_inspe_service.dart';
import 'package:emtrack/models/install_tyre_model.dart';
import 'package:emtrack/services/install_tyre_service.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/tyre_model.dart';
import '../services/tyre_service.dart';

class InstallTyreController extends GetxController {
  final RxBool isSubmitting = false.obs;
  final RxBool isInitialLoading = false.obs;

  final service = InstallTyreService();
  final vehicleInspeService = VehicleInspeService();
  final tyreService = TyreService();
  final picker = ImagePicker();
  final MasterDataService _masterService = MasterDataService();
  Rx<InstallTireModel> model = InstallTireModel().obs;
  //==========
  final wearConditionsList = <String>[].obs;
  final wearConditionsIdList = <int>[].obs;
  final RxInt selectedWearConditionsId = 0.obs;
  final wearConditionsId = TextEditingController();

  final casingConditionList = <String>[].obs;
  final casingConditionIdList = <int>[].obs;
  final RxInt selectedCasingConditionId = 0.obs;
  final casingConditionsId = TextEditingController();

  final dispositionList = <String>[].obs;
  final dispositionIdList = <int>[].obs;
  final RxInt installedDispositionId = 0.obs;
  final RxString vehicleNumber = "".obs;

  RxList<TyreModel> tyreList = <TyreModel>[].obs;
  RxDouble avgTread = 0.0.obs;

  final commentsController = TextEditingController();
  final previousCommentController = TextEditingController(
    text: "List Of Previous Comments",
  );

  @override
  void onInit() {
    super.onInit();

    commentsController.text = model.value.comments ?? "";

    final args = Get.arguments ?? {};
    final int vehicleId = args["vehicleId"] ?? 0;
    vehicleNumber.value = args["vehicleNumber"] ?? "";
    final String wheelPosition = args["wheelPosition"] ?? "";
    final int tireId = args["tireId"] ?? 0;
    final String serialNo = args["serialNo"] ?? "";
    final String lastInspection = args["lastInspection"] ?? "";
    //    final double avgTread = args["avgTread"] ?? 0.0;

    // /// 🔥 MODEL PREFILL
    model.update((m) {
      m!.vehicleId = vehicleId;
      m.wheelPosition = wheelPosition;
      m.tireId = tireId;
      m.tireSerialNo = serialNo;
      m.currentTreadDepth = avgTread.value;
    });

    loadMasterData();
    if (tireId > 0) {
      loadTyres(tireId);
    } else {
      _prefillFromInspectionRecord(
        vehicleId: vehicleId,
        wheelPosition: wheelPosition,
      ).then((_) {
        final resolvedTireId = model.value.tireId ?? 0;
        if (resolvedTireId > 0) {
          loadTyres(resolvedTireId);
        }
      });
    }
  }

  Future<void> _prefillFromInspectionRecord({
    required int vehicleId,
    required String wheelPosition,
  }) async {
    if (vehicleId <= 0) return;
    if (wheelPosition.trim().isEmpty) return;

    final current = model.value;
    final needsPrefill = (current.tireId == null || current.tireId == 0) &&
        (current.tireSerialNo == null || current.tireSerialNo!.isEmpty);
    if (!needsPrefill) return;

    final resp = await vehicleInspeService.getInspectionRecord(
      vehicleId.toString(),
    );

    final tires = resp?.model?.installedTires ?? <InstalledTire>[];
    InstalledTire? match;
    for (final t in tires) {
      if ((t.wheelPosition ?? '').toString() == wheelPosition) {
        match = t;
        break;
      }
    }
    if (match == null) return;

    model.update((m) {
      if (m == null) return;
      m.vehicleId = vehicleId;
      m.wheelPosition = wheelPosition;
      m.tireId = match!.tireId ?? 0;
      m.tireSerialNo = match.tireSerialNo ?? '';
      m.brandNumber = match.brandNo ?? '';
      m.outsideTread = (match.outsideTread ?? 0).toDouble();
      m.insideTread = (match.insideTread ?? 0).toDouble();
      m.currentPressure = (match.currentPressure ?? 0).toDouble();
      _calcAverage(m);
    });
  }

  // 🔹 Counters
  void incAir() => model.update((m) => m!.currentPressure++);
  void decAir() => model.update((m) => m!.currentPressure--);

  // 🔹 Outside Tread
  void incOutside() => model.update((m) {
    m!.outsideTread++;
    _calcAverage(m);
  });

  void decOutside() => model.update((m) {
    if (m!.outsideTread > 0) m.outsideTread--;
    _calcAverage(m);
  });

  // 🔹 Inside Tread
  void incInside() => model.update((m) {
    m!.insideTread++;
    _calcAverage(m);
  });

  void decInside() => model.update((m) {
    if (m!.insideTread > 0) m.insideTread--;
    _calcAverage(m);
  });
  // 🧮 Average Calculation
  void _calcAverage(InstallTireModel m) {
    final outside = m.outsideTread;
    final inside = m.insideTread;

    final avg = (outside + inside) / 2;

    // round to 2 decimal and keep as double
    m.currentTreadDepth = double.parse(avg.toStringAsFixed(2));
  }

  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();
      print("Master api data $data");

      /// wearConditions
      wearConditionsList.assignAll(
        (data['wearConditions'] as List)
            .map((e) => e['wearConditionName'].toString().toUpperCase())
            .toList()
            .toSet(),
      );

      wearConditionsIdList.assignAll(
        (data['wearConditions'] as List)
            .map((e) => e['wearConditionId'] as int)
            .toList()
            .toSet(),
      );

      /// CasingConditions
      casingConditionList.assignAll(
        (data['casingCondition'] as List)
            .map((e) => e['casingConditionName'].toString().toUpperCase())
            .toList()
            .toSet(),
      );

      casingConditionIdList.assignAll(
        (data['casingCondition'] as List)
            .map((e) => e['casingConditionId'] as int)
            .toList()
            .toSet(),
      );

      if (wearConditionsIdList.isNotEmpty) {
        selectedWearConditionsId.value = wearConditionsIdList.first;
      }

      if (casingConditionIdList.isNotEmpty) {
        selectedCasingConditionId.value = casingConditionIdList.first;
      }

      /// Dispositions
      dispositionList.assignAll(
        (data['tireDispositions'] as List)
            .map((e) => e['dispositionName'].toString().toUpperCase())
            .toList(),
      );

      dispositionIdList.assignAll(
        (data['tireDispositions'] as List)
            .map((e) => e['dispositionId'] as int)
            .toList(),
      );

      // 🔥 Find Installed ID
      for (var d in data['tireDispositions']) {
        if (d['dispositionName'].toString().toLowerCase() == "installed") {
          installedDispositionId.value = d['dispositionId'];
          break;
        }
      }

      print("✅ Installed Disposition ID => ${installedDispositionId.value}");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> loadTyres(int tireId) async {
    isInitialLoading.value = true;
    try {
      final tyres = await tyreService.getTyresById(tireId);

      print("SERVICE RESULT => $tyres");
      print("SERVICE LENGTH => ${tyres.length}");

      tyreList.clear();
      tyreList.addAll(tyres);

      print("TYRE LIST LENGTH => ${tyreList.length}");

      if (tyreList.isNotEmpty) {
        final outside = tyreList.first.outsideTread ?? 0;
        final inside = tyreList.first.insideTread ?? 0;

        double avg;

        if (outside != 0 && inside != 0) {
          avg = (outside + inside) / 2;
        } else {
          avg = outside != 0 ? outside : inside;
        }

        avgTread.value = double.parse(avg.toStringAsFixed(2));

        model.value.currentTreadDepth = avgTread.value;
        model.value.outsideTread = outside;
        model.value.insideTread = inside;
      }
    } catch (e) {
      print("Error loading tyres: $e");
    } finally {
      isInitialLoading.value = false;
    }
  }

  // ✅ Submit
  Future<void> submit() async {
    // 🔒 Prevent double click
    if (isSubmitting.value) return;

    isSubmitting.value = true;

    try {
      final parentAccountIdStr = await SecureStorage.getParentAccountId();
      final locationIdStr = await SecureStorage.getLocationId();
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        Get.snackbar("Error", "Session expired. Please login again.");
        return;
      }

      final parentAccountId = int.tryParse(parentAccountIdStr ?? '') ?? 0;
      final locationId = int.tryParse(locationIdStr ?? '') ?? 0;

      final m = model.value;

      // ✅ Validation
      if (parentAccountId == 0 || locationId == 0) {
        Get.snackbar("Error", "Invalid Account or Location");
        return;
      }

      if (m.tireId == null || m.tireId == 0) {
        Get.snackbar("Error", "Tire ID is missing");
        return;
      }

      if (m.vehicleId == null || m.vehicleId == 0) {
        Get.snackbar("Error", "Vehicle ID is missing");
        return;
      }

      if (installedDispositionId.value == 0) {
        Get.snackbar("Error", "Installed Disposition not found");
        return;
      }

      final outsideTread = tyreList.first.outsideTread ?? 0.0;
      final insideTread = tyreList.first.insideTread ?? 0.0;
      final currentPressure = tyreList.first.currentPressure ?? 28.0;

      /* Map<String, dynamic> payload = {
        "action": "Install",
        "inspectionDate": "2026-02-13T08:11:30Z",
        "locationId": 10268,
        "parentAccountId": parentAccountId,
        "vehicleId": m.vehicleId,
        "inspectionId": 0,
        "tireId": m.tireId,
        "currentHours": 1050.0,
        "currentMiles": 0.0,
        "imagesLocation": "",
        "tireSerialNo": "223435545",
        "brandNumber": "BR-001",
        "originalTread": 140.0,
        "removeAt": 30.0,
        "outsideTread": 6.0,
        "middleTread": 0.0,
        "insideTread": 4.0,
        "currentTreadDepth": 5.0, // (6 + 4) / 2
        "currentPressure": 4.0,
        "pressureUnitId": 1,
        "casingConditionId": 1,
        "wearConditionId": 1,
        "comments": "Test from Postman",
        "removalReasonId": 0,
        "dispositionId": 7,
        "rimDispositionId": 0,
        "wheelPosition": "2L",
        "mountedRimId": 0,
        "createdBy": "Sachin",
        "pressureType": "Hot",
        "hoursAdjustToTire": 0.0,
        "milesAdjustToTire": 0.0,
        "isMobInstall": false,
      };*/

      Map<String, dynamic> payload = {
        "action": "Install",
        // "inspectionDate": DateTime.now().toUtc().toIso8601String(),
        "inspectionDate": "2026-02-13T08:11:30Z",
        "locationId": locationId,
        "parentAccountId": parentAccountId,
        "vehicleId": m.vehicleId,
        // "inspectionId": 0,
        "tireId": tyreList.first.tireId,
        // "tireId": 537217,
        // "currentHours": m.currentHours ?? 1050.0,
        //"currentMiles": m.currentMiles ?? 0.0,
        //  "imagesLocation": m.imagesLocation ?? "",
        "tireSerialNo": tyreList.first.tireSerialNo ?? "",
        //  "brandNumber": m.brandNumber ?? "BR-001",
        "originalTread": tyreList.first.originalTread ?? 140.0,
        //  "removeAt": m.removeAt ?? 30.0,
        "outsideTread": tyreList.first.outsideTread,
        // "middleTread": m.middleTread ?? 0.0,
        "insideTread": tyreList.first.insideTread,
        "currentTreadDepth": ((outsideTread + insideTread) / 2),
        "currentPressure": currentPressure,
        //  "pressureUnitId": 1,
        "casingConditionId": selectedCasingConditionId.value,
        "wearConditionId": selectedWearConditionsId.value,
        "comments": m.comments.isNotEmpty ? m.comments : "No comments",
        //"removalReasonId": 0,
        "dispositionId": installedDispositionId.value,
        // "dispositionId": 7,
        // "rimDispositionId": m.rimDispositionId ?? 0,
        "wheelPosition": m.wheelPosition?.trim() ?? " ",
        //"wheelPosition": "1L",
        // "mountedRimId": 0,
        //  "createdBy": "Sachin",
        // "pressureType": "Hot",
        // "hoursAdjustToTire": 0.0,
        // "milesAdjustToTire": 0.0,
        // "isMobInstall": false,
      };
      //  payload.remove("inspectionId");
      // payload.remove("mountedRimId");
      // payload.remove("rimDispositionId");
      //payload.remove("removalReasonId");
      //payload.remove("imagesLocation");
      //payload.remove("middleTread");

      print("TireId => ${m.tireId}");
      print("VehicleId => ${m.vehicleId}");
      print("WheelPosition => ${m.wheelPosition}");

      print("🚨 FINAL PAYLOAD: jsonInCode($payload");

      print(jsonEncode(payload));
      //============================

      //==============================

      final success = await service.submitInspection(payload);

      if (success) {
        // 🔄 Refresh vehicle inspection properly
        final vehicleCtrl = Get.find<VehicleInspeController>();
        await vehicleCtrl.fetchInspectionData();

        Get.back(); // 👈 instead of Get.off
        Get.back();
        Get.snackbar("Success", "Tyre Installed Successfully");
      }
    } catch (e) {
      print("❌ Install Tire API Error: $e");
      Get.snackbar("Error", "Failed to install tire. Please try again.");
    } finally {
      isSubmitting.value = false;
    }
  }
}
