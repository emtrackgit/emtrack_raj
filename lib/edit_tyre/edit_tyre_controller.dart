import 'package:emtrack/create_tyre/app_loader.dart';
import 'package:emtrack/edit_tyre/edit_tyre_model.dart';
import 'package:emtrack/edit_tyre/edit_tyre_service.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_dialog.dart';

class EditTyreController extends GetxController {
  // ================= STEPPER =================
  final RxInt currentStep = 0.obs;
  int? tireId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final MasterDataService _masterService = MasterDataService();
  //========selected value=========//

  var tireStatusName = "".obs; // selected name

  RxString selectedTrackingMethod = "Hours".obs;
  // STEP 1
  RxList<String> statusList = <String>[].obs;
  RxList<int> statusIdList = <int>[].obs;
  RxInt selectedstatus = 0.obs;
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

  void setStatusList(List<String> list, List<int> idList) {
    statusList.assignAll(list);
    statusIdList.assignAll(idList);

    if (statusList.isNotEmpty) {
      selectedstatus.value = statusIdList.last;
    }
  }

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
  // Controller me text sirf UI ke liye rakho
  final RxInt selectedManufacturerId = 0.obs;
  final RxInt selectedSizeId = 0.obs;
  final RxInt selectedTypeId = 0.obs;
  final RxInt selectedLoadRatingId = 0.obs;
  final RxInt selectedSpeedRatingId = 0.obs;
  final RxInt selectedIndCodeId = 0.obs;
  final RxInt selectedCompoundId = 0.obs;
  final RxInt selectedFillTypeId = 0.obs;

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
    print("🔎 selectedManufacturerId => ${selectedManufacturerId.value}");
    print("🔎 selectedSizeId => ${selectedSizeId.value}");
    print("🔎 selectedTypeId => ${selectedTypeId.value}");

    model.tireStatusId = selectedstatus.value;
    // vehicleId & vehicleNumber are set from API in loadTyreDetails(), not from UI
    model.tireSerialNo = tireSerialNo.text.trim();
    model.brandNo = int.tryParse(brandNo.text) ?? 0;
    model.registeredDate = registeredDateApi.toString();
    model.evaluationNo = evaluationNo.text.trim();
    model.lotNo = lotNo.text.trim();
    model.poNo = poNo.text.trim();
    model.currentHours = double.tryParse(currentHours.text) ?? 0;

    // STEP 2// STEP 2 (ONLY THIS)
    model.manufacturerId = selectedManufacturerId.value;
    model.sizeId = selectedSizeId.value;
    model.starRatingId = starRating.value;
    model.typeId = selectedTypeId.value;
    model.indCodeId = selectedIndCodeId.value;
    model.compoundId = selectedCompoundId.value;
    model.loadRatingId = selectedLoadRatingId.value;
    model.speedRatingId = selectedSpeedRatingId.value;
    model.fillTypeId = selectedFillTypeId.value;

    // STEP 3
    model.originalTread = double.tryParse(originalTread.text) ?? 0;
    model.removeAt = double.tryParse(removeAt.text) ?? 0;
    model.purchasedTread = double.tryParse(purchasedTread.text) ?? 0;
    model.outsideTread = double.tryParse(outsideTread.text) ?? 0;
    model.insideTread = double.tryParse(insideTread.text) ?? 0;

    // STEP 4
    model.purchaseCost = double.tryParse(purchaseCost.text) ?? 0;
    model.casingValue = double.tryParse(casingValue.text) ?? 0;
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

      // 🔹 SecureStorage से IDs लो
      final String? parentAccountId = await SecureStorage.getParentAccountId();
      final String? locationId = await SecureStorage.getLocationId();

      if (parentAccountId == null || parentAccountId.isEmpty) {
        AppLoader.hide();
        Get.snackbar(
          "Error",
          "Parent Account not selected",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (locationId == null || locationId.isEmpty) {
        AppLoader.hide();
        Get.snackbar(
          "Error",
          "Location not selected",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 🔹 Model में form data bind करो
      bindToModel();

      // 🔹 IDs और isEditable set करो
      model.parentAccountId = int.parse(parentAccountId);
      model.locationId = int.parse(locationId);
      model.isEditable = true;
      model.tireId = tireId;

      print("tire id $tireId"); // ✅ update ke liye tireId zaruri
      print("DEBUG: Model after binding => ${model.toJson()}");
      // 🔹 Service को call करो
      await EditTyreService.updateTyre(model);

      AppLoader.hide();

      // ✅ Success Dialog

      Get.offAll(
        () => HomeView(),
        arguments: {
          "showSuccess": true,
          "serialNo": tireSerialNo.text,
          "module": "tyre",
          "type": "update", // ya "create"
        },
      );
    } catch (e) {
      AppLoader.hide();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Update Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  void cancelDialog() {
    AppDialog.showConfirmDialog(
      title: "Cancel Request",

      message: "Are you sure you want to cancel? You will\n lose unsaved data.",
      okText: "Yes",
      onOk: () {
        Get.back(closeOverlays: true);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppPages.HOME);
        });
      },
    );
  }

  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();

      /// 🔹 STATUS (name+id same length to avoid RangeError)
      final statusRaw = (data['tireStatus'] as List);
      // statusList.assignAll(statusRaw.map((e) => e['statusName'].toString()));
      // statusIdList.assignAll(
      //   statusRaw.map((e) => (e['statusId'] as num).toInt()),
      // );
      // setStatusList(statusList);

      statusList.clear();
      statusIdList.clear();

      List<String> names = [];
      List<int> ids = [];

      for (var e in statusRaw) {
        names.add(e['statusName']?.toString() ?? '');
        ids.add(int.tryParse(e['statusId'].toString()) ?? 0);
      }

      setStatusList(names, ids);

      /// 🔹 MANUFACTURER (name+id same length to avoid RangeError in setDropdownById)
      final manufRaw = (data['tireManufacturers'] as List);
      manufacturerList.assignAll(
        manufRaw.map((e) => e['manufacturerName'].toString().toUpperCase()),
      );
      manufacturerIdList.assignAll(
        manufRaw.map((e) => (e['manufacturerId'] as num).toInt()),
      );

      /// 🔹 SIZE
      final sizeRaw = (data['tireSizes'] as List);
      tireSizeList.assignAll(sizeRaw.map((e) => e['tireSizeName'].toString()));
      tireSizeIdList.assignAll(
        sizeRaw.map((e) => (e['tireSizeId'] as num).toInt()),
      );

      /// 🔹 TYPE
      final typeRaw = (data['tireTypes'] as List);
      typeList.assignAll(typeRaw.map((e) => e['typeName'].toString()));
      typeIdList.assignAll(typeRaw.map((e) => (e['typeId'] as num).toInt()));

      /// 🔹 INDUSTRY CODE
      final indRaw = (data['tireIndCodes'] as List);
      indCodeList.assignAll(indRaw.map((e) => e['codeName'].toString()));
      indCodeIdList.assignAll(indRaw.map((e) => (e['codeId'] as num).toInt()));

      /// 🔹 COMPOUND
      final compRaw = (data['tireCompounds'] as List);
      compoundList.assignAll(compRaw.map((e) => e['compoundName'].toString()));
      compoundIdList.assignAll(
        compRaw.map((e) => (e['compoundId'] as num).toInt()),
      );

      /// 🔹 LOAD RATING
      final loadRaw = (data['tireLoadRatings'] as List);
      loadRatingList.assignAll(loadRaw.map((e) => e['ratingName'].toString()));
      loadRatingIdList.assignAll(
        loadRaw.map((e) => (e['ratingId'] as num).toInt()),
      );

      /// 🔹 SPEED RATING
      final speedRaw = (data['tireSpeedRatings'] as List);
      speedRatingList.assignAll(
        speedRaw.map((e) => e['speedRatingName'].toString()),
      );
      speedRatingIdList.assignAll(
        speedRaw.map((e) => (e['speedRatingId'] as num).toInt()),
      );

      /// 🔹 FILL TYPE
      final fillRaw = (data['tireFillTypes'] as List);
      fillTypeList.assignAll(fillRaw.map((e) => e['fillTypeName'].toString()));
      fillTypeIdList.assignAll(
        fillRaw.map((e) => (e['fillTypeId'] as num).toInt()),
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
      print("✅ Tyre fetched successfully");

      // ✅ Save vehicleId & vehicleNumber from API so they are sent back on update
      model.vehicleId = tyre.vehicleId;
      model.vehicleNumber = tyre.vehicleNumber;

      print("ManufacturerId => ${tyre.manufacturerId}");
      print("TypeId => ${tyre.typeId}");
      print("CompoundId => ${tyre.compoundId}");
      selectedManufacturerId.value = tyre.manufacturerId ?? 0;
      selectedSizeId.value = tyre.sizeId ?? 0;
      selectedTypeId.value = tyre.typeId ?? 0;
      selectedCompoundId.value = tyre.compoundId ?? 0;
      selectedFillTypeId.value = tyre.fillTypeId ?? 0;

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
        selectedId: selectedManufacturerId,
      );
      //...........
      //sizeId.text = tyre.sizeId.toString();
      setDropdownById(
        id: tyre.sizeId,
        idList: tireSizeIdList.toList(),
        nameList: tireSizeList.toList(),
        controller: sizeId,
        selectedId: selectedSizeId,
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
        selectedId: selectedIndCodeId,
      );
      // compoundId.text = tyre.compoundId.toString();
      setDropdownById(
        id: tyre.compoundId,
        idList: compoundIdList.toList(),
        nameList: compoundList.toList(),
        controller: compoundId,
        selectedId: selectedCompoundId,
      );
      // loadRatingId.text = tyre.loadRatingId.toString();
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
        selectedId: selectedFillTypeId,
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

  /// Sets dropdown controller text based on an ID.
  /// Optionally updates a selectedId Rx variable for backend binding.
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

  @override
  void onClose() {
    manufacturerId.dispose();
    sizeId.dispose();
    starRatingId.dispose();
    super.onClose();
  }
}
