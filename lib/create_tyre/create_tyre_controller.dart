import 'package:emtrack/create_tyre/app_loader.dart';
import 'package:emtrack/create_tyre/create_tyre_model.dart';
import 'package:emtrack/create_tyre/create_tyre_service.dart';
import 'package:emtrack/models/view_tyre_response.dart' as viewtyre;
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/all_tyre_controller.dart';
import '../routes/app_pages.dart';
import '../services/tyre_service.dart';
import '../utils/app_dialog.dart';

class CreateTyreController extends GetxController {
  // ================= STEPPER =================
  final RxInt currentStep = 0.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final MasterDataService _masterService = MasterDataService();

  final ScrollController pageScrollController = ScrollController();

  RxString tireSerialNoError = ''.obs;

  // ===== Manufacturer Mapping =====
  final Map<String, int> manufacturerMap = {};

  final statusIdList = <int>[].obs;
  final manufacturerIdList = <int>[].obs;
  final tireSizeIdList = <int>[].obs;
  final typeIdList = <int>[].obs;
  final indCodeIdList = <int>[].obs;
  final compoundIdList = <int>[].obs;
  final loadRatingIdList = <int>[].obs;
  final speedRatingIdList = <int>[].obs;
  final fillTypeIdList = <int>[].obs;

  final RxInt selectedStatusId = 0.obs;
  final RxInt selectedManufacturerId = 0.obs;
  final RxInt selectedSizeId = 0.obs;
  final RxInt selectedTypeId = 0.obs;
  final RxInt selectedIndCodeId = 0.obs;
  final RxInt selectedCompoundId = 0.obs;
  final RxInt selectedLoadRatingId = 0.obs;
  final RxInt selectedSpeedRatingId = 0.obs;
  int? selectedFillTypeId;
  final tireStatusId = TextEditingController();

  // STEP 1
  final statusList = <String>[].obs;
  String? registeredDateApi;
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
  final starRatingNameList = <String>[].obs;
  final starRatingIdList = <int>[].obs;

  List allTireSizes = [];
  final isPageLoading = true.obs;

  // STEP 4
  final fillTypeList = <String>[].obs;
  List allTypeList = [];

  void setStatusList(List<String> list) {
    statusList.assignAll(list);
    if (statusList.isNotEmpty) {
      selectedstatus.value = statusList.last;
    }
  }

  void nextStep() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (currentStep.value < 3) currentStep.value++;
  }  void previousStep() {
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

  final trackingMethodText = "Hours".obs;
  final currentHours = TextEditingController(text: "0");

  // ================= STEP 2 (IDs) =================
  final RxInt starRating = 0.obs;
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
      await loadMasterData();

      final arg = Get.arguments;

      if (arg is int && arg > 0) {
        tireId = arg;
        await loadTyreForClone(tireId!);
      }

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

    if (currentHours.text.trim().isEmpty || currentHours.text.trim().contains('.')) {
      currentHours.text = "0";
    }

    model.mountStatus = "Not Mounted";
    model.isMountToRim = false;

    model.numberOfRetreads = 0;
    numberOfRetreadsVal.value = 0;
  }

  String _formatWholeNumber(dynamic value) {
    final d = double.tryParse(value?.toString() ?? '');
    if (d == null) return '0';
    return d % 1 == 0 ? d.toInt().toString() : d.toString();
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

  Future<void> bindToModel() async {
    // ================= STEP 1 =================
    model.tireStatusId = 7;
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

    // ================= STEP 2 =================
    model.manufacturerId = selectedManufacturerId.value;
    model.sizeId = selectedSizeId.value;
    model.starRatingId = starRating.value;
    model.plyId = 1123;
    model.typeId = selectedTypeId.value;
    model.indCodeId = selectedIndCodeId.value;
    model.compoundId = selectedCompoundId.value;
    model.loadRatingId = selectedLoadRatingId.value;
    model.speedRatingId = selectedSpeedRatingId.value;
    model.fillTypeId = int.tryParse(selectedFillTypeId.toString()) ?? 0;

    // ================= STEP 3 =================
    model.originalTread = double.tryParse(originalTread.text) ?? 0;
    model.removeAt = double.tryParse(removeAt.text) ?? 0;
    model.purchasedTread = double.tryParse(purchasedTread.text) ?? 0;
    model.outsideTread = double.tryParse(outsideTread.text) ?? 0;
    model.middleTread = 0.0;
    model.insideTread = double.tryParse(insideTread.text) ?? 0;

    // ================= STEP 4 =================
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

    // ================= FIXED FIELDS =================
    model.mileageType = selectedTrackingMethod.value;
    model.dispositionId = 8;
    model.mountedRimId = 0;
    model.isMountToRim = false;
    model.isEditable = false;
    model.tireId = 0;
    model.vehicleId = 0;
    model.recommendedPressure = 0;
    model.currentPressure = 0;
    model.averageTreadDepth = 0;
    model.currentTreadDepth = 0;
    model.percentageWorn = 0;
    model.mountStatus = "Not Mounted";
    model.wheelPosition = "N/A";
    model.mountedRimSerialNo = "N/A";
    model.createdBy = "Sachin";

    model.tireGraphData = TireGraphData(
      treadDepthList: [],
      pressureList: [],
      costPerHourList: [],
      hoursPerTreadDepthList: [],
      milesPerTreadDepthList: [],
    );

    model.vehicleNumber = "";
    model.tireHistory = [];
    model.tireHistory1 = [];
    model.imagesLocation = "";

    // ================= PARENT & LOCATION =================
    final parentId = await SecureStorage.getParentAccountId();
    model.parentAccountId = int.tryParse(parentId ?? "0") ?? 0;

    final storedLocation = await SecureStorage.getLocationId();
    print("Stored LocationId => $storedLocation");
    model.locationId = int.tryParse(storedLocation!) ?? 0;
  }

  // ================= SUBMIT =================
  Future<void> submitTyre() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Invalid Form",
        "PLEASE fix the errors before submitting.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (Get.isRegistered<AllTyreController>()) {
      final allTyres = Get.find<AllTyreController>().allTyres;
      final isDuplicate = allTyres.any(
            (t) => t.tireSerialNo?.toLowerCase() ==
            tireSerialNo.text.trim().toLowerCase(),
      );
      if (isDuplicate) {
        tireSerialNoError.value = "This serial number already exists";
        Get.snackbar(
          "Error",
          "This serial number already exists",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    try {
      AppLoader.show();

      final String? parentAccountId = await SecureStorage.getParentAccountId();
      if (parentAccountId == null || parentAccountId.isEmpty) {
        AppLoader.hide();
        Get.snackbar(
          "Error",
          "PARENT Account not selected.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await bindToModel();
      model.parentAccountId = int.parse(parentAccountId);

      await CreateTyreService.saveTyre(model);

      AppLoader.hide();

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
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void cancelDialog() {
    AppDialog.showConfirmDialog(
      title: 'Cancel Request',
      message: 'Are you sure you want to cancel? You will \n lose unsaved data.',
      onOk: () {
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppPages.HOME);
        });
      },
    );
  }

  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();

      allTireSizes = data['tireSizes'];
      allTypeList = data['tireTypes'];

      print('allTypeList$typeList');

      statusList.assignAll(
        (data['tireStatus'] as List)
            .map((e) => e['statusName'].toString())
            .toSet()
            .toList(),
      );

      if (statusList.isNotEmpty && selectedstatus.value.isEmpty) {
        selectedstatus.value = statusList.last;
      }
      statusIdList.assignAll(
        (data['tireStatus'] as List).map((e) => e['statusId']),
      );

      manufacturerList.assignAll(
        (data['tireManufacturers'] as List)
            .map((e) => e['manufacturerName'].toString().toUpperCase())
            .toList()
            .toSet(),
      );

      manufacturerIdList.assignAll(
        (data['tireManufacturers'] as List)
            .map((e) => e['manufacturerId'] as int)
            .toList()
            .toSet(),
      );

      indCodeList.assignAll(
        (data['tireIndCodes'] as List)
            .map((e) => e['codeName'].toString())
            .toList()
            .toSet(),
      );

      indCodeIdList.assignAll(
        (data['tireIndCodes'] as List)
            .map((e) => e['codeId'] as int)
            .toList()
            .toSet(),
      );

      compoundList.assignAll(
        (data['tireCompounds'] as List)
            .map((e) => e['compoundName'].toString())
            .toList()
            .toSet(),
      );

      compoundIdList.assignAll(
        (data['tireCompounds'] as List)
            .map((e) => e['compoundId'] as int)
            .toList()
            .toSet(),
      );

      loadRatingList.assignAll(
        (data['tireLoadRatings'] as List)
            .map((e) => e['ratingName'].toString())
            .toList()
            .toSet(),
      );

      loadRatingIdList.assignAll(
        (data['tireLoadRatings'] as List)
            .map((e) => e['ratingId'] as int)
            .toList()
            .toSet(),
      );

      speedRatingList.assignAll(
        (data['tireSpeedRatings'] as List)
            .map((e) => e['speedRatingName'].toString())
            .toList()
            .toSet(),
      );

      speedRatingIdList.assignAll(
        (data['tireSpeedRatings'] as List)
            .map((e) => e['speedRatingId'] as int)
            .toList()
            .toSet(),
      );

      try {
        final raw = (data['starRating'] ?? data['tireStarRatings']) as List?;
        if (raw != null) {
          starRatingNameList.assignAll(
            raw.map((e) => (e['ratingName'] ?? e['starRatingName'] ?? '').toString()).toList(),
          );
          starRatingIdList.assignAll(
            raw.map((e) => e['ratingId'] as int).toList(),
          );
        }
      } catch (_) {}

      fillTypeList.assignAll(
        (data['tireFillTypes'] as List)
            .map((e) => e['fillTypeName'].toString())
            .toList()
            .toSet(),
      );

      fillTypeIdList.assignAll(
        (data['tireFillTypes'] as List)
            .map((e) => e['fillTypeId'] as int)
            .toList()
            .toSet(),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void filterTireSizesByManufacturer(int manufacturerId) {
    final filtered = allTireSizes
        .where((e) => e['tireManufacturerId'] == manufacturerId)
        .toList();

    tireSizeList.assignAll(
      filtered.map((e) => e['tireSizeName'].toString()).toList(),
    );

    tireSizeIdList.assignAll(
      filtered.map((e) => e['tireSizeId'] as int).toList(),
    );
  }

  Future<void> getTireTypes(int tireSizeId) async {
    final filtered =
    allTypeList.where((e) => e["tireSizeId"] == tireSizeId).toList();

    typeList.assignAll(filtered.map((e) => e['typeName'].toString()).toList());
    typeIdList.assignAll(filtered.map((e) => e['typeId'] as int).toList());
  }

  void setStarRating(int value) {
    starRating.value = value;
    final idx = starRatingIdList.indexOf(value);
    if (idx >= 0 && idx < starRatingNameList.length) {
      starRatingId.text = starRatingNameList[idx];
    } else {
      starRatingId.text = value.toString();
    }
    update();
  }

  @override
  void onClose() {
    manufacturerId.dispose();
    sizeId.dispose();
    starRatingId.dispose();
    super.onClose();
  }

  // ========================== SAVE AND CLONE ==========================
  Future<void> saveAndClone() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Invalid Form",
        "PLEASE fix the errors before saving.",
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
          "PARENT Account not selected.",
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
        "TIRE cloned successfully.\nTire with serial no: ${tireSerialNo.text} created successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );

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
    currentHours.text = _formatWholeNumber(m.currentHours ?? 0);

    manufacturerId.text = (m.manufacturerId ?? 0).toString();
    sizeId.text = (m.sizeId ?? 0).toString();
    if ((m.starRatingId ?? 0) > 0) {
      setStarRating(m.starRatingId ?? 0);
    } else {
      starRating.value = 0;
      starRatingId.text = '';
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

    model.vehicleId = tyre.vehicleId;
    model.vehicleNumber = tyre.vehicleNumber;

    selectedManufacturerId.value = tyre.manufacturerId ?? 0;
    selectedSizeId.value = tyre.sizeId ?? 0;
    selectedTypeId.value = tyre.typeId ?? 0;
    selectedCompoundId.value = tyre.compoundId ?? 0;
    selectedStatusId.value = tyre.tireStatusId ?? 0;

    brandNo.text = tyre.brandNo ?? '';
    evaluationNo.text = tyre.evaluationNo ?? '';
    lotNo.text = tyre.lotNo ?? '';
    poNo.text = tyre.poNo ?? '';
    currentHours.text = _formatWholeNumber(tyre.currentHours);

    final dt = DateTime.parse(tyre.registeredDate.toString());
    registeredDate.text =
    "${dt.day.toString().padLeft(2, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.year}";
    registeredDateApi = dt.toUtc().toIso8601String();

    manufacturerId.text = tyre.manufacturerId.toString();

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

    sizeId.text = tyre.sizeId.toString();
    setDropdownById(
      id: tyre.sizeId,
      idList: tireSizeIdList.toList(),
      nameList: tireSizeList.toList(),
      controller: sizeId,
      selectedId: selectedSizeId,
    );

    if ((tyre.starRatingId ?? 0) > 0) {
      setStarRating(tyre.starRatingId ?? 0);
    } else {
      starRating.value = 0;
      starRatingId.text = '';
    }
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

    setDropdownById(
      id: tyre.speedRatingId,
      idList: speedRatingIdList.toList(),
      nameList: speedRatingList.toList(),
      controller: speedRatingId,
      selectedId: selectedSpeedRatingId,
    );

    setDropdownById(
      id: tyre.typeId,
      idList: typeIdList.toList(),
      nameList: typeList.toList(),
      controller: typeId,
      selectedId: selectedTypeId,
    );

    originalTread.text = tyre.originalTread.toString();
    purchasedTread.text = tyre.purchasedTread.toString();
    removeAt.text = tyre.removeAt.toString();
    outsideTread.text = tyre.outsideTread.toString();
    insideTread.text = tyre.insideTread.toString();

    purchaseCost.text = tyre.purchaseCost.toString();
    casingValue.text = tyre.casingValue.toString();
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

    update();
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
      if (selectedId != null) selectedId.value = 0;
      return;
    }

    final index = idList.indexOf(id);

    if (index == -1) {
      controller.clear();
      print("⚠️ setDropdownById: ID $id not found in idList");
      return;
    }

    if (index >= nameList.length) {
      controller.clear();
      if (selectedId != null) selectedId.value = 0;
      print(
        "⚠️ setDropdownById: index $index out of range for nameList "
            "(length ${nameList.length}). idList.length=${idList.length}, id=$id",
      );
      return;
    }

    controller.text = nameList[index];
    if (selectedId != null) selectedId.value = idList[index];
  }
}
