import 'package:emtrack/create_tyre/app_loader.dart';
import 'package:emtrack/create_tyre/create_tyre_model.dart';
import 'package:emtrack/create_tyre/create_tyre_service.dart';
import 'package:emtrack/models/view_tyre_response.dart' as viewtyre;
import 'package:emtrack/models/masterDataMobileModel/star_rating_model.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/all_tyre_controller.dart';
import '../routes/app_pages.dart';
import '../services/tyre_service.dart';
import '../utils/app_dialog.dart';
import '../services/pending_tyre_sync_service.dart';
import 'dart:convert';
import 'dart:io';

class CreateTyreController extends GetxController {
  // ================= STEPPER =================
  final RxInt currentStep = 0.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final MasterDataService _masterService = MasterDataService();
  //===========

  final ScrollController pageScrollController = ScrollController();
  // ===== Manufacturer Mapping =====
  final Map<String, int> manufacturerMap = {};
  final Map<String, int> tireStatusMap = {};

  //===========
  final statusIdList = <int>[].obs;
  final manufacturerIdList = <int>[].obs;
  final tireSizeIdList = <int>[].obs;
  final typeIdList = <int>[].obs;
  final indCodeIdList = <int>[].obs;
  final compoundIdList = <int>[].obs;
  final loadRatingIdList = <int>[].obs;
  final speedRatingIdList = <int>[].obs;
  final fillTypeIdList = <int>[].obs;
  final plyRatingIdList = <int>[].obs;

  final RxInt selectedStatusId = 0.obs;
  final RxInt selectedManufacturerId = 0.obs;
  final RxInt selectedSizeId = 0.obs;
  final RxInt selectedTypeId = 0.obs;
  final RxInt selectedIndCodeId = 0.obs;
  final RxInt selectedCompoundId = 0.obs;
  final RxInt selectedLoadRatingId = 0.obs;
  final RxInt selectedSpeedRatingId = 0.obs;
  final RxInt selectedPlyRatingId = 0.obs;
  //final RxInt selectedFillTypeId = 0.obs;
  int? selectedFillTypeId;
  final tireStatusId = TextEditingController();

  //==============

  // STEP 1
  final statusList = <String>[].obs;
  // UI
  String? registeredDateApi; // Backend
  //========selected value=========//
  RxString selectedstatus = "".obs;
  RxString selectedTrackingMethod = "Hours".obs;

  // STEP 2
  final manufacturerList = <String>[].obs;
  final tireSizeList = <String>[].obs;
  final typeList = <String>[].obs;
  final indCodeList = <String>[].obs;
  final compoundList = <String>[].obs;
  final loadRatingList = <String>[].obs;
  final speedRatingList = <String>[].obs;
  final plyRatingList = <String>[].obs;

  List allTireSizes = [];
  final isPageLoading = true.obs;

  // STEP 4
  final fillTypeList = <String>[].obs;
  List allTypeList = [];

  void _assignPairs({
    required List source,
    required String nameKey,
    required String idKey,
    required RxList<String> names,
    required RxList<int> ids,
    bool upper = false,
  }) {
    names.clear();
    ids.clear();

    final seenId = <int>{};
    final seenName = <String>{};
    final entries = <MapEntry<int, String>>[];

    for (final row in source) {
      if (row is! Map) continue;
      final idRaw = row[idKey];
      final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
      if (id == null || id <= 0) continue;
      if (seenId.contains(id)) continue;

      final nameRaw = row[nameKey]?.toString() ?? '';
      final name = upper ? nameRaw.toUpperCase().trim() : nameRaw.trim();
      if (name.isEmpty) continue;
      if (seenName.contains(name)) continue;

      seenId.add(id);
      seenName.add(name);
      entries.add(MapEntry(id, name));
    }

    entries.sort((a, b) => a.value.compareTo(b.value));
    ids.addAll(entries.map((e) => e.key));
    names.addAll(entries.map((e) => e.value));
  }

  void setStatusList(List<String> list) {
    statusList.assignAll(list);

    if (statusList.isNotEmpty) {
      selectedstatus.value = statusList.last;
    }
  }

  void nextStep() {
    if (!formKey.currentState!.validate()) return;

    if (currentStep.value < 3) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ================= MODEL =================
  final CreateTyreModel model = CreateTyreModel();

  // ================= STEP 1 =================
  final tireSerialNo = TextEditingController();
 final brandNo = TextEditingController();
  final registeredDate = TextEditingController();
  final evaluationNo = TextEditingController();
  final lotNo = TextEditingController();
  final poNo = TextEditingController();
  final dispositionText = "Inventory".obs;
  //  final statusText = "New".obs;

  final trackingMethodText = "Hours".obs;
  final currentHours = TextEditingController(text: "0");

  // ================= STEP 2 (IDs) =================
  final RxInt starRating = 0.obs;
  final RxInt starRatingCount = 0.obs;
  final RxList<StarRating> starRatings = <StarRating>[].obs;
  final RxString selectedStarRatingName = ''.obs;
  final manufacturerId = TextEditingController();
  final sizeId = TextEditingController();
  final starRatingId = TextEditingController();
  final typeId = TextEditingController();
  final indCodeId = TextEditingController();
  final compoundId = TextEditingController();
  final loadRatingId = TextEditingController();
  final speedRatingId = TextEditingController();

  // ================= STEP 3 =================
  final originalTread = TextEditingController();
  final removeAt = TextEditingController();
  final purchasedTread = TextEditingController();
  final outsideTread = TextEditingController(text: "0");
final insideTread = TextEditingController(text: "0");

  // ================= STEP 4 =================
  final purchaseCost = TextEditingController(text: "0");
  final casingValue = TextEditingController(text: "0");
  final fillTypeId = TextEditingController();
  final fillCost = TextEditingController(text: "0");
  final repairCost = TextEditingController(text: "0");
  final retreadCost = TextEditingController(text: "0");
  final numberOfRetreadsVal = 0.obs;
  final warrantyAdjustment = TextEditingController(text: "0");
  final costAdjustment = TextEditingController(text: "0");
  final soldAmount = TextEditingController(text: "0");
  final netCost = TextEditingController(text: "0");
  int? tireId;

  // ⭐ STAR ENABLE FLAG
  final RxBool isStarEnabled = false.obs;

  void checkStarEnable() {
    isStarEnabled.value =
        manufacturerId.text.trim().isNotEmpty && sizeId.text.trim().isNotEmpty;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _initScreen();
  }

  Future<void> _initScreen() async {
    try {
      isPageLoading.value = true;

      /// 🔥 Load Masters First
      await loadMasterData();

      final arg = Get.arguments;

      /// ⭐ CLONE FLOW
      if (arg is int && arg > 0) {
        tireId = arg;
        await loadTyreForClone(tireId!);
      }

      /// ⭐ DEFAULT CREATE VALUES (works for both)
      _setDefaultValues();
    } catch (e) {
      print("❌ Init Screen Error $e");
    } finally {
      isPageLoading.value = false;
    }
  }

  void _setDefaultValues() {
    manufacturerId.addListener(checkStarEnable);
    sizeId.addListener(checkStarEnable);

    final now = DateTime.now();

    registeredDate.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    registeredDateApi = now.toUtc().toIso8601String();

    model.dispositionId = 8;
    dispositionText.value = "Inventory";

    model.tireStatusId = 7;

    model.trackingMethod = "Hours";
    trackingMethodText.value = "Hours";

    model.mountStatus = "Not Mounted";
    model.isMountToRim = false;

    model.numberOfRetreads = 0;
    numberOfRetreadsVal.value = 0;
  }

  // ================= NET COST =================
  void calculateNetCost() {
    double a = double.tryParse(purchaseCost.text) ?? 0;
    double b = double.tryParse(casingValue.text) ?? 0;
    double c = double.tryParse(fillCost.text) ?? 0;
    double d = double.tryParse(repairCost.text) ?? 0;
    double e = double.tryParse(retreadCost.text) ?? 0;
    double f = double.tryParse(warrantyAdjustment.text) ?? 0;
    double g = double.tryParse(costAdjustment.text) ?? 0;
    double h = double.tryParse(soldAmount.text) ?? 0;

    netCost.text = (a - b + c + d + e + f - g - h).toStringAsFixed(2);
  }

  // ================= MAP CONTROLLERS → MODEL =================

  // void bindToModel() async {
  //   // ================= STEP 1 =================
  //   model.tireStatusId = int.tryParse(selectedstatus.toString());
  //   model.tireSerialNo = tireSerialNo.text.trim();
  //   model.brandNo = brandNo.text.trim().isEmpty ? null : brandNo.text.trim();

  //   model.registeredDate = registeredDateApi != null
  //       ? DateTime.parse(registeredDateApi!).toUtc()
  //       : DateTime.now().toUtc();

  //   model.evaluationNo = evaluationNo.text.trim().isEmpty
  //       ? null
  //       : evaluationNo.text.trim();

  //   model.lotNo = lotNo.text.trim().isEmpty ? null : lotNo.text.trim();
  //   model.poNo = poNo.text.trim().isEmpty ? null : poNo.text.trim();

  //   model.currentHours = double.tryParse(currentHours.text) ?? 0;
  //   model.currentMiles = 0;

  //   // ================= STEP 2 =================
  //   model.manufacturerId = selectedManufacturerId.value;
  //   model.sizeId = selectedSizeId.value;
  //   model.starRatingId = starRating.value;
  //   model.plyId = 1123;
  //   model.typeId = selectedTypeId.value;

  //   model.indCodeId = selectedIndCodeId.value;
  //   model.compoundId = selectedCompoundId.value;
  //   model.loadRatingId = selectedLoadRatingId.value;
  //   model.speedRatingId = selectedSpeedRatingId.value;
  //   model.fillTypeId = selectedFillTypeId;

  //   // ================= STEP 3 =================
  //   model.originalTread = double.tryParse(originalTread.text) ?? 0;
  //   model.removeAt = double.tryParse(removeAt.text) ?? 0;
  //   model.purchasedTread = double.tryParse(purchasedTread.text) ?? 0;

  //   model.outsideTread = double.tryParse(outsideTread.text) ?? 0;
  //   model.middleTread = 0.0;
  //   model.insideTread = double.tryParse(insideTread.text) ?? 0;

  //   // ================= STEP 4 =================
  //   model.purchaseCost = double.tryParse(purchaseCost.text) ?? 0;
  //   model.casingValue = double.tryParse(casingValue.text) ?? 0;
  //   model.fillCost = double.tryParse(fillCost.text) ?? 0;

  //   model.repairCount = 0;
  //   model.repairCost = double.tryParse(repairCost.text) ?? 0;

  //   model.retreadCount = 0;
  //   model.retreadCost = double.tryParse(retreadCost.text) ?? 0;

  //   model.warrantyAdjustment = double.tryParse(warrantyAdjustment.text) ?? 0;

  //   model.costAdjustment = double.tryParse(costAdjustment.text) ?? 0;

  //   model.soldAmount = double.tryParse(soldAmount.text) ?? 0;

  //   model.netCost = double.tryParse(netCost.text) ?? 0;

  //   // ================= REQUIRED FIX FIELDS =================

  //   model.mileageType = "1";
  //   model.dispositionId = 8;
  //   // model.tireStatusId = 7;
  //   model.mountedRimId = null;
  //   model.isMountToRim = false;
  //   model.isEditable = false;
  //   model.tireId = null;
  //   model.vehicleId = null;
  //   model.recommendedPressure = 0;
  //   model.currentPressure = 0;
  //   model.averageTreadDepth = 0;
  //   model.currentTreadDepth = 0;
  //   model.percentageWorn = 0;

  //   model.mountStatus = "Not Mounted";
  //   model.wheelPosition = "N/A";
  //   model.mountedRimSerialNo = "N/A";

  //   model.tireGraphData = null;
  //   model.vehicleNumber = null;

  //   // ================= PARENT & LOCATION =================
  //   final parentId = SecureStorage.getParentAccountId();

  //   model.parentAccountId = int.tryParse(parentId.toString() );

  //   final storedLocation = await SecureStorage.getLocationId();

  //   print("Stored LocationId => $storedLocation");

  //   model.locationId = storedLocation != null && storedLocation.isNotEmpty
  //       ? int.parse(storedLocation)
  //       : null;
  // }

  Future<void> bindToModel() async {
    // ================= STEP 1: Basic info =================
    model.tireStatusId = tireStatusMap[selectedstatus.value] ?? 7;
    model.tireSerialNo = tireSerialNo.text.trim();
    model.brandNo = brandNo.text.trim().isEmpty ? null : brandNo.text.trim();
    model.registeredDate = registeredDateApi != null
        ? DateTime.parse(registeredDateApi!).toUtc()
        : DateTime.now().toUtc();
    model.evaluationNo = evaluationNo.text.trim().isEmpty
        ? null
        : evaluationNo.text.trim();
    model.lotNo = lotNo.text.trim().isEmpty ? null : lotNo.text.trim();
    model.poNo = poNo.text.trim().isEmpty ? null : poNo.text.trim();
    model.currentHours = double.tryParse(currentHours.text) ?? 0;
    model.currentMiles = 0;

    // ================= STEP 2: Tire specs =================
    model.manufacturerId = selectedManufacturerId.value;
    model.sizeId = selectedSizeId.value;
    model.typeId = selectedTypeId.value;
    model.starRatingId = starRating.value;
    model.plyId = selectedPlyRatingId.value;
    model.indCodeId = selectedIndCodeId.value;
    model.compoundId = selectedCompoundId.value;
    model.loadRatingId = selectedLoadRatingId.value;
    model.speedRatingId = selectedSpeedRatingId.value;
    model.fillTypeId = selectedFillTypeId;

    // ================= STEP 3: Tread measurements =================
    final orig = double.tryParse(originalTread.text) ?? 0;
    final rem = double.tryParse(removeAt.text) ?? 0;
    final out = double.tryParse(outsideTread.text) ?? 0;
    final inT = double.tryParse(insideTread.text) ?? 0;

    model.originalTread = orig;
    model.removeAt = rem;
    model.purchasedTread = double.tryParse(purchasedTread.text) ?? 0;
    model.outsideTread = out;
    model.middleTread = 0.0;
    model.insideTread = inT;

    // CALCULATE DERIVED VALUES
    model.averageTreadDepth = _calcAverageTreadDepth();
    model.percentageWorn = _calcPercentageWorn();

    // ================= STEP 4: Cost & financials =================
    model.purchaseCost = double.tryParse(purchaseCost.text) ?? 0;
    model.casingValue = double.tryParse(casingValue.text) ?? 0;
    model.fillCost = double.tryParse(fillCost.text) ?? 0;
    model.repairCount = 0;
    model.repairCost = double.tryParse(repairCost.text) ?? 0;
    model.retreadCount = 0;
    model.retreadCost = double.tryParse(retreadCost.text) ?? 0;
    model.warrantyAdjustment = double.tryParse(warrantyAdjustment.text) ?? 0;
    model.costAdjustment = double.tryParse(costAdjustment.text) ?? 0;
    model.soldAmount = double.tryParse(soldAmount.text) ?? 0;
    model.netCost = double.tryParse(netCost.text) ?? 0;

    // ================= STEP 5: Fixed / default fields =================
    model.mileageType = selectedTrackingMethod.value;
    model.dispositionId = 8;
    model.mountedRimId = 0;
    model.isMountToRim = false;
    model.isEditable = false;
    model.tireId = 0;
    model.vehicleId = 0;
    model.recommendedPressure = 0;
    model.currentPressure = 0;
    model.currentTreadDepth = model.averageTreadDepth;
    model.mountStatus = "Not Mounted";
    model.wheelPosition = "";
    model.mountedRimSerialNo = "";
    final createdBy =
        (await SecureStorage.getUserName()) ??
        (await SecureStorage.getUserProfileName());
    model.createdBy = createdBy ?? "mobile";

    // ================= STEP 6: Nested / complex fields =================
    model.tireGraphData = TireGraphData(
      treadDepthList: [],
      pressureList: [],
      costPerHourList: [],
      hoursPerTreadDepthList: [],
      milesPerTreadDepthList: [],
    );

    model.vehicleNumber = ""; // populate if available
    model.tireHistory = [];
    model.tireHistory1 = [];
    model.imagesLocation = ""; // store images path if needed

    // ================= STEP 7: Parent & Location =================
    final parentId = await SecureStorage.getParentAccountId();
    model.parentAccountId = int.tryParse(parentId ?? "0") ?? 0;

    final storedLocation = await SecureStorage.getLocationId();

    print("Stored LocationId => $storedLocation");

    model.locationId = int.tryParse(storedLocation ?? '') ?? 0;
  }

  // ================= SUBMIT =================
  Future<void> submitTyre() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "⚠️ Invalid Form",
        "Please fix errors",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      AppLoader.show();

      final String? parentAccountId = await SecureStorage.getParentAccountId();
      if (parentAccountId == null || parentAccountId.isEmpty) {
        AppLoader.hide();
        Get.snackbar(
          "⚠️ Error",
          "Parent Account not selected",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final serial = tireSerialNo.text.trim();
      if (serial.isNotEmpty && Get.isRegistered<AllTyreController>()) {
        final tyreCtrl = Get.find<AllTyreController>();
        final exists = tyreCtrl.allTyres.any(
          (t) => (t.tireSerialNo ?? '').toLowerCase() == serial.toLowerCase(),
        );
        if (exists) {
          AppLoader.hide();
          Get.snackbar(
            "⚠️ Error",
            "Tire Serial Number already exists",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      await bindToModel();
      model.parentAccountId = int.parse(parentAccountId);

      if (selectedFillTypeId == null && fillTypeIdList.isNotEmpty) {
        selectedFillTypeId = fillTypeIdList.first;
        if (fillTypeList.isNotEmpty) {
          fillTypeId.text = fillTypeList.first;
        }
      }

      if ((model.locationId ?? 0) <= 0) {
        AppLoader.hide();
        Get.snackbar(
          "⚠️ Error",
          "Location not selected",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.manufacturerId ?? 0) <= 0 ||
          (model.sizeId ?? 0) <= 0 ||
          (model.typeId ?? 0) <= 0 ||
          (model.fillTypeId ?? 0) <= 0 ||
          (model.plyId ?? 0) <= 0) {
        AppLoader.hide();
        Get.snackbar(
          "⚠️ Error",
          "Please select Manufacturer, Tire Size, Type, Fill Type and Ply",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.originalTread ?? 0) <= (model.removeAt ?? 0)) {
        AppLoader.hide();
        Get.snackbar(
          "⚠️ Error",
          "Original Tread must be greater than Remove At",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.removeAt ?? 0) <= 0) {
        AppLoader.hide();
        currentStep.value = 2;
        Get.snackbar(
          "⚠️ Error",
          "Remove At value is required",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.originalTread ?? 0) > 99 ||
          (model.removeAt ?? 0) > 99 ||
          (model.purchasedTread ?? 0) > 99 ||
          (model.outsideTread ?? 0) > 99 ||
          (model.insideTread ?? 0) > 99) {
        AppLoader.hide();
        Get.snackbar(
          "⚠️ Error",
          "Tread depth must be between 0 and 99",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.outsideTread ?? 0) < (model.removeAt ?? 0) ||
          (model.insideTread ?? 0) < (model.removeAt ?? 0)) {
        AppLoader.hide();
        Get.snackbar(
          "⚠️ Error",
          "Outside/Inside tread must be greater than or equal to Remove At",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.outsideTread ?? 0) > (model.originalTread ?? 0)) {
        AppLoader.hide();
        currentStep.value = 2;
        Get.snackbar(
          "⚠️ Error",
          "Outside tread cannot be greater than Original tread",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if ((model.insideTread ?? 0) > (model.originalTread ?? 0)) {
        AppLoader.hide();
        currentStep.value = 2;
        Get.snackbar(
          "⚠️ Error",
          "Inside tread cannot be greater than Original tread",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        await CreateTyreService.saveTyre(model);
      } on SocketException catch (_) {
        final body = model.toJson();
        body["tireId"] = body["tireId"] ?? 0;
        body["vehicleId"] = body["vehicleId"] ?? 0;
        body["mountedRimId"] = body["mountedRimId"] ?? 0;
        await SecureStorage.enqueuePendingCreateTyre(jsonEncode(body));
        AppLoader.hide();
        Get.snackbar(
          "Offline",
          "Saved locally. Will sync when online.",
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(AppPages.HOME);
        return;
      } catch (e) {
        if (e.toString().contains('Failed host lookup') ||
            e.toString().contains('Network is unreachable') ||
            e.toString().contains('Connection refused')) {
          final body = model.toJson();
          body["tireId"] = body["tireId"] ?? 0;
          body["vehicleId"] = body["vehicleId"] ?? 0;
          body["mountedRimId"] = body["mountedRimId"] ?? 0;
          await SecureStorage.enqueuePendingCreateTyre(jsonEncode(body));
          AppLoader.hide();
          Get.snackbar(
            "Offline",
            "Saved locally. Will sync when online.",
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offAllNamed(AppPages.HOME);
          return;
        }
        rethrow;
      }

      AppLoader.hide();

      if (Get.isRegistered<AllTyreController>()) {
        final tyreCtrl = Get.find<AllTyreController>();
        final idx = tyreCtrl.tabController?.index ?? 0;
        await tyreCtrl.fetchData(tyreCtrl.tabs[idx]);
      }

      await PendingTyreSyncService.syncPendingCreates();

      Get.offAll(
        () => HomeView(),
        arguments: {
          "showSuccess": true,
          "serialNo": tireSerialNo.text,
          "module": "tyre",
          "type": "Create",
        },
      );
    } catch (e) {
      AppLoader.hide();
      if (e is ApiException) {
        if (e.statusCode == 400) {
          String message = e.message;
          final err = e.errors;
          if (err is Map) {
            final first = err.values.cast<dynamic>().firstWhere(
                  (_) => true,
                  orElse: () => null,
                );
            if (first is List && first.isNotEmpty) {
              message = first.first.toString();
            } else if (first is String && first.trim().isNotEmpty) {
              message = first;
            }
          }
          Get.snackbar(
            "⚠️ Validation Error",
            message,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
          return;
        }

        if (e.statusCode >= 500) {
          if (e.requestBodyJson != null && e.requestBodyJson!.trim().isNotEmpty) {
            await SecureStorage.enqueuePendingCreateTyre(e.requestBodyJson!);
          }
          Get.snackbar(
            "❌ Server Error",
            "Server is failing (500). Saved locally and will retry later.",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
          print("❌ CreateTyre submit error => ${e.toString()}");
          return;
        }

        Get.snackbar(
          "❌ Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      final msg = e.toString().replaceFirst('Exception: ', '');
      print("❌ CreateTyre submit error => $msg");
      Get.snackbar(
        "❌ Server Error",
        "Something went wrong. Please check your inputs and try again.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  double _calcAverageTreadDepth() {
    final out = double.tryParse(outsideTread.text) ?? 0;
    final inT = double.tryParse(insideTread.text) ?? 0;
    final v = (out + inT) / 2;
    return double.parse(v.toStringAsFixed(2));
  }

  double _calcPercentageWorn() {
    final orig = double.tryParse(originalTread.text) ?? 0;
    final rem = double.tryParse(removeAt.text) ?? 0;
    final avg = _calcAverageTreadDepth();
    if (orig <= rem) return 0;
    final raw = ((orig - avg) / (orig - rem)) * 100;
    if (raw.isNaN || raw.isInfinite) return 0;
    if (raw < 0) return 0;
    if (raw >= 100) return 99.99;
    return double.parse(raw.toStringAsFixed(2));
  }

  void cancelDialog() {
    AppDialog.showConfirmDialog(
      title: 'Cancel Request',
      message:
          'Are you sure you want to cancel? You will \n lose unsaved data.',
      onOk: () {
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppPages.HOME);
        });
      },
    );
    // Get.defaultDialog(
    //   title: "Cancel Request",
    //   middleText: "Are you sure you want to cancel?",
    //   textCancel: "No",
    //   textConfirm: "Yes",
    //   onConfirm: () {
    //     Get.back();
    //     Get.back();
    //   },
    //   onCancel: () {},
    // );
  }

  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();

      /// SIZE
      allTireSizes = data['tireSizes'];
      allTypeList = data['tireTypes'];

      print('allTypeList$typeList');

      // /// STATUS
      // statusList.assignAll(
      //   (data['tireStatus'] as List)
      //       .map((e) => e['statusName'].toString())
      //       .toList()
      //       .toSet(),
      // );
      //🔹 STATUS
      tireStatusMap.clear();
      statusList.clear();
      statusIdList.clear();

      final rawStatuses = (data['tireStatus'] as List? ?? []);
      for (final s in rawStatuses) {
        if (s is! Map) continue;
        final name = (s['statusName'] ?? '').toString();
        final id = (s['statusId'] ?? 0) as int;
        if (name.isEmpty) continue;
        if (tireStatusMap.containsKey(name)) continue;
        tireStatusMap[name] = id;
        statusList.add(name);
        statusIdList.add(id);
      }

      if (statusList.isNotEmpty && selectedstatus.value.isEmpty) {
        selectedstatus.value = statusList.last;
      }

      /// MANUFACTURER
      manufacturerMap.clear();
      _assignPairs(
        source: (data['tireManufacturers'] as List? ?? []),
        nameKey: 'manufacturerName',
        idKey: 'manufacturerId',
        names: manufacturerList,
        ids: manufacturerIdList,
        upper: true,
      );
      for (var i = 0; i < manufacturerList.length; i++) {
        manufacturerMap[manufacturerList[i]] = manufacturerIdList[i];
      }
      final manufacturerIds = manufacturerIdList
          .toSet(); // Set of valid manufacturer IDs
      /// SIZE
      // tireSizeList.assignAll(
      //   (data['tireSizes'] as List)
      //       .where((e) => manufacturerIds.contains(e['tireManufacturerId']))
      //       .map((e) => e['tireSizeName'].toString())
      //       .toList()
      //       .toSet(),
      // );

      // tireSizeIdList.assignAll(
      //   (data['tireSizes'] as List)
      //       .where((e) => manufacturerIds.contains(e['tireManufacturerId']))
      //       .map((e) => e['tireSizeId'] as int)
      //       .toList()
      //       .toSet(),
      // );

      /// TYPE
      // typeList.assignAll(
      //   (data['tireTypes'] as List)
      //       .where((e) => manufacturerIds.contains(e['tireManufacturerId']))
      //       .map((e) => e['typeName'].toString())
      //       .toList()
      //       .toSet(),
      // );

      // typeIdList.assignAll(
      //   (data['tireTypes'] as List)
      //       .where((e) => manufacturerIds.contains(e['tireManufacturerId']))
      //       .map((e) => e['typeId'] as int)
      //       .toList()
      //       .toSet(),
      // );

      /// INDUSTRY CODE
      _assignPairs(
        source: (data['tireIndCodes'] as List? ?? []),
        nameKey: 'codeName',
        idKey: 'codeId',
        names: indCodeList,
        ids: indCodeIdList,
      );

      /// COMPOUND
      _assignPairs(
        source: (data['tireCompounds'] as List? ?? []),
        nameKey: 'compoundName',
        idKey: 'compoundId',
        names: compoundList,
        ids: compoundIdList,
      );

      /// LOAD RATING
      _assignPairs(
        source: (data['tireLoadRatings'] as List? ?? []),
        nameKey: 'ratingName',
        idKey: 'ratingId',
        names: loadRatingList,
        ids: loadRatingIdList,
      );

      /// SPEED RATING
      _assignPairs(
        source: (data['tireSpeedRatings'] as List? ?? []),
        nameKey: 'speedRatingName',
        idKey: 'speedRatingId',
        names: speedRatingList,
        ids: speedRatingIdList,
      );

      /// FILL TYPE
      _assignPairs(
        source: (data['tireFillTypes'] as List? ?? []),
        nameKey: 'fillTypeName',
        idKey: 'fillTypeId',
        names: fillTypeList,
        ids: fillTypeIdList,
      );

      final rawStar = (data['starRating'] ??
              data['starRatings'] ??
              data['tireStarRatings'] ??
              []) as List?;
      starRatings.assignAll(
        (rawStar ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => StarRating.fromJson(e))
            .toList(),
      );

      plyRatingList.assignAll(
        const [],
      );
      plyRatingIdList.assignAll(
        const [],
      );
      _assignPairs(
        source: (data['plyRating'] as List? ?? []),
        nameKey: 'ratingName',
        idKey: 'ratingId',
        names: plyRatingList,
        ids: plyRatingIdList,
      );
      if (selectedPlyRatingId.value == 0 && plyRatingIdList.isNotEmpty) {
        selectedPlyRatingId.value = plyRatingIdList.first;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void filterTireSizesByManufacturer(int manufacturerId) {
    final filtered = allTireSizes
        .where((e) => e['tireManufacturerId'] == manufacturerId)
        .toList();

    tireSizeList.assignAll(
      filtered
          .map((e) => (e['tireSizeName'] ?? '').toString().toUpperCase().trim())
          .toList(),
    );

    tireSizeIdList.assignAll(
      filtered.map((e) => e['tireSizeId'] as int).toList(),
    );
  }

  Future<void> getTireTypes(int tireSizeId) async {
    final filtered = allTypeList
        .where((e) => e["tireSizeId"] == tireSizeId)
        .toList();

    typeList.assignAll(
      filtered
          .map((e) => (e['typeName'] ?? '').toString().toUpperCase().trim())
          .toList(),
    );

    typeIdList.assignAll(filtered.map((e) => e['typeId'] as int).toList());

    // );
  }

  int _starCountFromName(String name) {
    final trimmed = name.trim();
    final digitMatch = RegExp(r'\d+').firstMatch(trimmed);
    final digitCount =
        digitMatch == null ? null : int.tryParse(digitMatch.group(0) ?? '');
    if (digitCount != null && digitCount >= 0) return digitCount;

    final parts = trimmed.split('/');
    var maxStars = 0;
    for (final p in parts) {
      final count = '*'.allMatches(p).length;
      if (count > maxStars) maxStars = count;
    }
    return maxStars;
  }

  int _starCountFromId(int id) {
    StarRating? found;
    for (final r in starRatings) {
      if (r.ratingId == id) {
        found = r;
        break;
      }
    }
    if (found == null) {
      if (id >= 0 && id <= 5) return id;
      return 0;
    }
    final count = _starCountFromName(found.ratingName);
    if (count > 0) return count;
    if (found.ratingId >= 0 && found.ratingId <= 5) return found.ratingId;
    return 0;
  }

  void setStarRating(StarRating rating) {
    starRating.value = rating.ratingId;
    starRatingId.text = rating.ratingId.toString();
    starRatingCount.value = _starCountFromName(rating.ratingName);
    selectedStarRatingName.value = rating.ratingName;
    update();
  }

  @override
  void onClose() {
    manufacturerId.dispose();
    sizeId.dispose();
    starRatingId.dispose();
    super.onClose();
  }

  //========================== save and clone ==========================
  Future<void> saveAndClone() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Invalid Form",
        "Please fix errors",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      AppLoader.show();

      final String? parentAccountId = await SecureStorage.getParentAccountId();
      if (parentAccountId == null || parentAccountId.isEmpty) {
        AppLoader.hide();
        Get.snackbar(
          "Error",
          "Parent Account not selected",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await bindToModel();
      model.parentAccountId = int.parse(parentAccountId);

      await CreateTyreService.saveTyre(model);

      AppLoader.hide();

      Get.snackbar(
        "Success",
        "Tire cloned successfully.\nTire with serial no: ${tireSerialNo.text} created successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      // RESET ONLY NECESSARY FIELDS
      tireSerialNo.clear();
      brandNo.clear();

      currentStep.value = 0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        pageScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });
      // Get.snackbar(
      //   "Success",
      //   "Tyre saved. Ready to clone.",
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } catch (e) {
      AppLoader.hide();
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void bindModelToControllers(CreateTyreModel m) {
    tireSerialNo.text = m.tireSerialNo!;
    brandNo.text = m.brandNo!;
    evaluationNo.text = m.evaluationNo!;
    lotNo.text = m.lotNo!;
    poNo.text = m.poNo!;
    currentHours.text = (m.currentHours ?? 0).toString();

    manufacturerId.text = (m.manufacturerId ?? 0).toString();
    sizeId.text = (m.sizeId ?? 0).toString();
    starRatingId.text = (m.starRatingId ?? 0).toString();
    starRating.value = m.starRatingId ?? 0;
    starRatingCount.value = _starCountFromId(starRating.value);
    if (starRating.value == 0) {
      selectedStarRatingName.value = '';
    } else {
      String? name;
      for (final r in starRatings) {
        if (r.ratingId == starRating.value) {
          name = r.ratingName;
          break;
        }
      }
      selectedStarRatingName.value = name ?? '';
    }
    typeId.text = (m.typeId ?? 0).toString();
    indCodeId.text = (m.indCodeId ?? 0).toString();
    compoundId.text = (m.compoundId ?? 0).toString();
    loadRatingId.text = (m.loadRatingId ?? 0).toString();
    speedRatingId.text = (m.speedRatingId ?? 0).toString();

    originalTread.text = (m.originalTread ?? 0).toString();
    removeAt.text = (m.removeAt ?? 0).toString();
    purchasedTread.text = (m.purchasedTread ?? 0).toString();
    outsideTread.text = (m.outsideTread ?? 0).toString();
    insideTread.text = (m.insideTread ?? 0).toString();

    purchaseCost.text = (m.purchaseCost ?? 0).toString();
    casingValue.text = (m.casingValue ?? 0).toString();
    fillTypeId.text = (m.fillTypeId ?? 0).toString();
    fillCost.text = (m.fillCost ?? 0).toString();
    repairCost.text = (m.repairCost ?? 0).toString();
    retreadCost.text = (m.retreadCost ?? 0).toString();
    warrantyAdjustment.text = (m.warrantyAdjustment ?? 0).toString();
    costAdjustment.text = (m.costAdjustment ?? 0).toString();
    soldAmount.text = (m.soldAmount ?? 0).toString();
    netCost.text = (m.netCost ?? 0).toString();

    update();
  }

  Future<void> loadTyreForClone(int tyreId) async {
    try {
      final tyre = await TyreService().cloneTyresById(tyreId);

      _assignCloneData(tyre);
    } catch (e) {
      print("❌ Clone Load Error $e");
    }
  }

  void _assignCloneData(viewtyre.ViewModel tyre) {
    filterTireSizesByManufacturer(tyre.manufacturerId!);
    getTireTypes(tyre.sizeId!);
    // ✅ Save vehicleId & vehicleNumber from API so they are sent back on update
    model.vehicleId = tyre.vehicleId;
    model.vehicleNumber = tyre.vehicleNumber;

    selectedManufacturerId.value = tyre.manufacturerId ?? 0;
    selectedSizeId.value = tyre.sizeId ?? 0;
    selectedTypeId.value = tyre.typeId ?? 0;
    selectedCompoundId.value = tyre.compoundId ?? 0;
    selectedStatusId.value = tyre.tireStatusId ?? 0;
    //   selectedFillTypeId = tyre.fillTypeId as RxInt?;

    // tireSerialNo.text = tyre.tireSerialNo ?? '';
    brandNo.text = tyre.brandNo ?? '';
    evaluationNo.text = tyre.evaluationNo ?? '';
    lotNo.text = tyre.lotNo ?? '';
    poNo.text = tyre.poNo ?? '';
    currentHours.text = tyre.currentHours.toString();

    // 🔹 DATE
    final dt = DateTime.parse(tyre.registeredDate.toString());

    registeredDate.text =
        "${dt.day.toString().padLeft(2, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.year}";

    registeredDateApi = dt.toUtc().toIso8601String();

    /// ✅ Manufecterer ID
    manufacturerId.text = tyre.manufacturerId.toString();
    // MANUFACTURER
    // 🔹 STATUS

    setDropdownById(
      id: tyre.tireStatusId,
      idList: statusIdList,
      nameList: statusList,
      controller: tireStatusId,
      selectedId: selectedStatusId,
    );

    setDropdownById(
      id: tyre.manufacturerId,
      idList: manufacturerIdList.toList(),
      nameList: manufacturerList.toList(),
      controller: manufacturerId,
      selectedId: selectedManufacturerId,
    );

    //...........
    sizeId.text = tyre.sizeId.toString();
    setDropdownById(
      id: tyre.sizeId,
      idList: tireSizeIdList.toList(),
      nameList: tireSizeList.toList(),
      controller: sizeId,
      selectedId: selectedSizeId,
    );
    starRatingId.text = tyre.starRatingId.toString();
    starRating.value = tyre.starRatingId ?? 0;
    starRatingCount.value = _starCountFromId(starRating.value);
    model.typeId = int.tryParse(typeId.text) ?? 0;

    indCodeId.text = tyre.indCodeId.toString();
    setDropdownById(
      id: tyre.indCodeId,
      idList: indCodeIdList.toList(),
      nameList: indCodeList.toList(),
      controller: indCodeId,
      selectedId: selectedIndCodeId,
    );
    compoundId.text = tyre.compoundId.toString();
    setDropdownById(
      id: tyre.compoundId,
      idList: compoundIdList.toList(),
      nameList: compoundList.toList(),
      controller: compoundId,
      selectedId: selectedCompoundId,
    );
    loadRatingId.text = tyre.loadRatingId.toString();
    setDropdownById(
      id: tyre.loadRatingId,
      idList: loadRatingIdList.toList(),
      nameList: loadRatingList.toList(),
      controller: loadRatingId,
      selectedId: selectedLoadRatingId,
    );
    // speedrating
    setDropdownById(
      id: tyre.speedRatingId,
      idList: speedRatingIdList.toList(),
      nameList: speedRatingList.toList(),
      controller: speedRatingId,
      selectedId: selectedSpeedRatingId,
    );
    // ✅ TYPE ID
    setDropdownById(
      id: tyre.typeId,
      idList: typeIdList.toList(),
      nameList: typeList.toList(),
      controller: typeId,
      selectedId: selectedTypeId,
    );

    // 🔹 STEP 3
    originalTread.text = tyre.originalTread.toString();
    purchasedTread.text = tyre.purchasedTread.toString();
    removeAt.text = tyre.removeAt.toString();
    outsideTread.text = tyre.outsideTread.toString();
    insideTread.text = tyre.insideTread.toString();

    // 🔹 STEP 4
    purchaseCost.text = tyre.purchaseCost.toString();
    casingValue.text = tyre.casingValue.toString();
    // fillTypeId.text = tyre.fillTypeId.toString();
    setDropdownById(
      id: tyre.fillTypeId,
      idList: fillTypeIdList.toList(),
      nameList: fillTypeList.toList(),
      controller: fillTypeId,
      selectedId: (selectedFillTypeId ?? 0).obs,
    );
    fillCost.text = tyre.fillCost.toString();
    repairCost.text = tyre.repairCost.toString();
    retreadCost.text = tyre.retreadCost.toString();
    warrantyAdjustment.text = tyre.warrantyAdjustment.toString();
    costAdjustment.text = tyre.costAdjustment.toString();
    soldAmount.text = tyre.soldAmount.toString();
    netCost.text = tyre.netCost.toString();

    update(); // if GetBuilder
  }

  void setDropdownById({
    required int? id,
    required List<int> idList,
    required List<String> nameList,
    required TextEditingController controller,
    RxInt? selectedId,
  }) {
    if (id == null || id == 0) {
      controller.clear();
      if (selectedId != null) {
        selectedId.value = 0;
      }
      return;
    }

    final index = idList.indexOf(id);

    if (index == -1) {
      controller.clear();
      print("⚠️ setDropdownById: ID $id not found in idList");
      return;
    }

    // 🔒 Bounds check: avoid RangeError when idList and nameList length differ
    if (index >= nameList.length) {
      controller.clear();
      if (selectedId != null) selectedId.value = 0;
      print(
        "⚠️ setDropdownById: index $index out of range for nameList (length ${nameList.length}). idList.length=${idList.length}, id=$id",
      );
      return;
    }

    controller.text = nameList[index];

    if (selectedId != null) {
      selectedId.value = idList[index];
    }
  }
}
