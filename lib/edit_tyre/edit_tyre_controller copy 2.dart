import 'dart:ffi';

import 'package:emtrack/create_tyre/app_loader.dart';
import 'package:emtrack/edit_tyre/edit_tyre_model.dart';
import 'package:emtrack/edit_tyre/edit_tyre_service.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditTyreController extends GetxController {
  // ================= STEPPER =================
  final RxInt currentStep = 0.obs;
  int? tireId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final MasterDataService _masterService = MasterDataService();
  //========selected value=========//
  var selectedstatus = 0.obs; // selected ID
  var tireStatusName = "".obs; // selected name

  RxString selectedTrackingMethod = "".obs;
  // STEP 1
  final statusList = <String>[].obs;
  final statusIdList = <int>[].obs;
  // UI
  String? registeredDateApi; // Backend

  // STEP 2
  final manufacturerList = <String>[].obs;
  final manufacturerIdList = <int>[].obs;

  final tireSizeList = <String>[].obs;
  final tireSizeIdList = <int>[].obs;

  final typeList = <String>[].obs;
  final typeIdList = <int>[].obs; // ✅ NEW

  final indCodeList = <String>[].obs;
  final indCodeIdList = <int>[].obs;

  final compoundList = <String>[].obs;
  final compoundIdList = <int>[].obs;

  final loadRatingList = <String>[].obs;
  final loadRatingIdList = <int>[].obs;

  final speedRatingList = <String>[].obs;
  final speedRatingIdList = <int>[].obs;

  // STEP 4
  final fillTypeList = <String>[].obs;
  final fillTypeIdList = <int>[].obs;

  void nextStep() {
    // 🔴 VALIDATION BEFORE NEXT STEP
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Invalid Step",
        "Please fill required fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // ================= MODEL =================
  final EditTyreModel model = EditTyreModel();

  // ================= STEP 1 =================
  final tireSerialNo = TextEditingController();
  final brandNo = TextEditingController();
  final registeredDate = TextEditingController();
  final evaluationNo = TextEditingController();
  final lotNo = TextEditingController();
  final poNo = TextEditingController();
  final dispositionText = "Inventory".obs;
  // final statusText = "New".obs;
  final tireStatusId = TextEditingController();
  final trackingMethodText = "Hours".obs;
  final currentHours = TextEditingController(text: "0");

  // ================= STEP 2 (IDs) =================
  final RxInt starRating = 0.obs;
  final manufacturerId = TextEditingController(text: '');
  final sizeId = TextEditingController(text: '');
  final starRatingId = TextEditingController(text: '');
  final typeId = TextEditingController(text: '');
  final indCodeId = TextEditingController(text: '');
  final compoundId = TextEditingController(text: '');
  final loadRatingId = TextEditingController(text: '');
  final speedRatingId = TextEditingController(text: '');

  // ================= STEP 3 =================
  final originalTread = TextEditingController();
  final removeAt = TextEditingController(text: "0");
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
  //===========

  // ⭐ STAR ENABLE FLAG
  final RxBool isStarEnabled = false.obs;
  // call this whenever manufacturer / size changes
  void checkStarEnable() {
    isStarEnabled.value =
        manufacturerId.text.trim().isNotEmpty && sizeId.text.trim().isNotEmpty;
    update();
  }

  @override
  void onInit() async {
    super.onInit();

    final arg = Get.arguments as int?;
    print("🔵 EditTyreController | ARGUMENTS => $arg");
    tireId = arg;
    print("🔵 EditTyreController | tireId => $tireId");

    await loadMasterData(); // wait until master loaded
    await loadTyreDetails(); // then load tyre
    manufacturerId.addListener(checkStarEnable);
    sizeId.addListener(checkStarEnable);
    final now = DateTime.now();

    // 👁 UI (dd-MM-yyyy)
    registeredDate.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    // 🔥 Backend (ISO 8601)
    registeredDateApi = now.toUtc().toIso8601String();

    /// default backend values
    model.dispositionId = 8;
    dispositionText.value = "Inventory";

    // model.tireStatusId = 7;
    // statusText.value = "New";

    model.trackingMethod = 1;
    trackingMethodText.value = "Hours";

    model.mountStatus = "Not Mounted";
    model.isMountToRim = false;

    model.numberOfRetreads = 0;
    numberOfRetreadsVal.value = 0;
    update();
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
  void bindToModel() {
    // STEP 1
    model.tireStatusId = int.tryParse(tireStatusId.text) ?? 0;
    model.tireSerialNo = tireSerialNo.text.trim();
    model.brandNo = int.tryParse(brandNo.text) ?? 0;
    model.registeredDate = registeredDateApi.toString();
    model.evaluationNo = evaluationNo.text.trim();
    model.lotNo = lotNo.text.trim();
    model.poNo = poNo.text.trim();
    model.currentHours = double.tryParse(currentHours.text) ?? 0;

    // STEP 2
    model.manufacturerId = int.tryParse(manufacturerId.text) ?? 0;
    model.sizeId = int.tryParse(sizeId.text) ?? 0;
    model.starRatingId = int.tryParse(starRatingId.text) ?? 0;
    model.typeId = int.tryParse(typeId.text) ?? 0;
    model.indCodeId = int.tryParse(indCodeId.text) ?? 0;
    model.compoundId = int.tryParse(compoundId.text) ?? 0;
    model.loadRatingId = int.tryParse(loadRatingId.text) ?? 0;
    model.speedRatingId = int.tryParse(speedRatingId.text) ?? 0;

    // STEP 3
    model.originalTread = double.tryParse(originalTread.text) ?? 0;
    model.removeAt = double.tryParse(removeAt.text) ?? 0;
    model.purchasedTread = double.tryParse(purchasedTread.text) ?? 0;
    model.outsideTread = double.tryParse(outsideTread.text) ?? 0;
    model.insideTread = double.tryParse(insideTread.text) ?? 0;

    // STEP 4
    model.purchaseCost = double.tryParse(purchaseCost.text) ?? 0;
    model.casingValue = double.tryParse(casingValue.text) ?? 0;
    model.fillTypeId = int.tryParse(fillTypeId.text) ?? 0;
    model.fillCost = double.tryParse(fillCost.text) ?? 0;
    model.repairCost = double.tryParse(repairCost.text) ?? 0;
    model.retreadCost = double.tryParse(retreadCost.text) ?? 0;
    model.warrantyAdjustment = double.tryParse(warrantyAdjustment.text) ?? 0;
    model.costAdjustment = double.tryParse(costAdjustment.text) ?? 0;
    model.soldAmount = double.tryParse(soldAmount.text) ?? 0;
    model.netCost = double.tryParse(netCost.text) ?? 0;
  }

  // ================= update =================
  Future<void> updateTyre() async {
    if (!formKey.currentState!.validate()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Invalid Form",
          "Please fix errors",
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLoader.show();
      });

      final String? parentAccountId = await SecureStorage.getParentAccountId();

      if (parentAccountId == null || parentAccountId.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppLoader.hide();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Error",
            "Parent Account not selected",
            snackPosition: SnackPosition.BOTTOM,
          );
        });
        return;
      }

      /// 1️⃣ Bind form → model
      bindToModel();

      /// 2️⃣ set parentAccountId
      model.parentAccountId = int.parse(parentAccountId);

      /// 3️⃣ API CALL
      await EditTyreService.getTyreById(tireId!);

      AppLoader.hide();

      /// ✅ SHOW SUCCESS DIALOG
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Success",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tyre submitted successfully 🎉"),
                const SizedBox(height: 12),
                Text(
                  "Tire Serial No: ${tireSerialNo.text}", // ✅ FIX
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.offAll(() => HomeView()); // ✅ navigate AFTER OK
                },
                child: const Text("OK"),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      });
    } catch (e) {
      AppLoader.hide();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  void cancelDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.defaultDialog(
        title: "Cancel Request",
        middleText: "Are you sure you want to cancel?",
        textCancel: "No",
        textConfirm: "Yes",
        onConfirm: () {
          // Close dialog
          Get.back();
          Get.back();
        },
        onCancel: () {
          Get.back();
          Get.back(); // Nothing, just close dialog
        },
      );
    });
  }

  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();

      /// 🔹 STATUS
      statusList.assignAll(
        (data['tireStatus'] as List).map((e) => e['statusName'].toString()),
      );
      statusIdList.assignAll(
        (data['tireStatus'] as List).map((e) => e['statusId']),
      );

      /// 🔹 MANUFACTURER
      manufacturerList.assignAll(
        (data['tireManufacturers'] as List).map(
          (e) => e['manufacturerName'].toString(),
        ),
      );
      manufacturerIdList.assignAll(
        (data['tireManufacturers'] as List).map((e) => e['manufacturerId']),
      );

      /// 🔹 SIZE
      tireSizeList.assignAll(
        (data['tireSizes'] as List).map((e) => e['tireSizeName'].toString()),
      );
      tireSizeIdList.assignAll(
        (data['tireSizes'] as List).map((e) => e['tireSizeId']),
      );

      /// 🔹 TYPE (NAME + ID)
      typeList.assignAll(
        (data['tireTypes'] as List).map((e) => e['typeName'].toString()),
      );

      typeIdList.assignAll(
        (data['tireTypes'] as List).map((e) => e['typeId'] as int),
      );

      /// 🔹 INDUSTRY CODE
      indCodeList.assignAll(
        (data['tireIndCodes'] as List).map((e) => e['codeName'].toString()),
      );
      indCodeIdList.assignAll(
        (data['tireIndCodes'] as List).map((e) => e['codeId']),
      );

      /// 🔹 COMPOUND
      compoundList.assignAll(
        (data['tireCompounds'] as List).map(
          (e) => e['compoundName'].toString(),
        ),
      );
      compoundIdList.assignAll(
        (data['tireCompounds'] as List).map((e) => e['compoundId']),
      );

      /// 🔹 LOAD RATING
      loadRatingList.assignAll(
        (data['tireLoadRatings'] as List).map(
          (e) => e['ratingName'].toString(),
        ),
      );
      loadRatingIdList.assignAll(
        (data['tireLoadRatings'] as List).map((e) => e['ratingId']),
      );

      /// 🔹 SPEED RATING
      speedRatingList.assignAll(
        (data['tireSpeedRatings'] as List).map(
          (e) => e['speedRatingName'].toString(),
        ),
      );
      speedRatingIdList.assignAll(
        (data['tireSpeedRatings'] as List).map((e) => e['speedRatingId']),
      );

      /// 🔹 FILL TYPE
      fillTypeList.assignAll(
        (data['tireFillTypes'] as List).map(
          (e) => e['fillTypeName'].toString(),
        ),
      );
      fillTypeIdList.assignAll(
        (data['tireFillTypes'] as List).map((e) => e['fillTypeId']),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void setStarRating(int value) {
    starRating.value = value; // data
    starRatingId.text = value.toString();
    update(); // 🔥 UI rebuild
  }

  Future<void> loadTyreDetails() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLoader.show();
      });
      final tyre = await EditTyreService.getTyreById(tireId!);
      // 🔹 STEP 1

      tireSerialNo.text = tyre.tireSerialNo.toString();
      brandNo.text = tyre.brandNo.toString();
      evaluationNo.text = tyre.evaluationNo.toString();
      lotNo.text = tyre.lotNo.toString();
      poNo.text = tyre.poNo.toString();
      currentHours.text = tyre.currentHours.toString();

      // 🔹 DATE
      final dt = DateTime.parse(tyre.registeredDate.toString());

      registeredDate.text =
          "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";

      registeredDateApi = dt.toUtc().toIso8601String();

      /// ✅ Manufecterer ID
      // manufacturerId.text = tyre.manufacturerId.toString();
      // MANUFACTURER
      // 🔹 STATUS
      if (statusIdList.isNotEmpty) {
        selectedstatus.value = tyre.tireStatusId ?? 0;

        setDropdownById(
          id: tyre.tireStatusId,
          idList: statusIdList,
          nameList: statusList,
          controller: tireStatusId,
        );
      }

      setDropdownById(
        id: tyre.manufacturerId,
        idList: manufacturerIdList.toList(),
        nameList: manufacturerList.toList(),
        controller: manufacturerId,
      );
      //...........
      //sizeId.text = tyre.sizeId.toString();
      setDropdownById(
        id: tyre.sizeId,
        idList: tireSizeIdList.toList(),
        nameList: tireSizeList.toList(),
        controller: sizeId,
      );
      starRatingId.text = tyre.starRatingId.toString();
      starRating.value = tyre.starRatingId ?? 0;
      // model.typeId = int.tryParse(typeId.text) ?? 0;

      // indCodeId.text = tyre.indCodeId.toString();
      setDropdownById(
        id: tyre.indCodeId,
        idList: indCodeIdList.toList(),
        nameList: indCodeList.toList(),
        controller: indCodeId,
      );
      // compoundId.text = tyre.compoundId.toString();
      setDropdownById(
        id: tyre.compoundId,
        idList: compoundIdList.toList(),
        nameList: compoundList.toList(),
        controller: compoundId,
      );
      // loadRatingId.text = tyre.loadRatingId.toString();
      setDropdownById(
        id: tyre.loadRatingId,
        idList: loadRatingIdList.toList(),
        nameList: loadRatingList.toList(),
        controller: loadRatingId,
      );
      // speedrating
      setDropdownById(
        id: tyre.speedRatingId,
        idList: speedRatingIdList.toList(),
        nameList: speedRatingList.toList(),
        controller: speedRatingId,
      );
      // ✅ TYPE ID
      setDropdownById(
        id: tyre.typeId,
        idList: typeIdList.toList(),
        nameList: typeList.toList(),
        controller: typeId,
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
      );
      fillCost.text = tyre.fillCost.toString();
      repairCost.text = tyre.repairCost.toString();
      retreadCost.text = tyre.retreadCost.toString();
      warrantyAdjustment.text = tyre.warrantyAdjustment.toString();
      costAdjustment.text = tyre.costAdjustment.toString();
      soldAmount.text = tyre.soldAmount.toString();
      netCost.text = tyre.netCost.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLoader.hide();
      });
      update(); // 🔥 UI refresh
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLoader.hide();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", e.toString());
      });
    }
  }

  // int _getIdFromName({
  //   required String name,
  //   required List<String> nameList,
  //   required List<int> idList,
  // }) {
  //   final index = nameList.indexOf(name);
  //   if (index == -1) return 0;
  //   return idList[index];
  // }

  void setDropdownById({
    required int? id,
    required List<int> idList,
    required List<String> nameList,
    required TextEditingController controller,
  }) {
    if (id == null) return;

    final index = idList.indexOf(id);

    if (index != -1 && index < nameList.length) {
      controller.text = nameList[index]; // ✅ NAME in UI
    }
  }

  @override
  void onClose() {
    manufacturerId.dispose();
    sizeId.dispose();
    starRatingId.dispose();
    super.onClose();
  }
}
