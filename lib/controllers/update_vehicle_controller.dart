import 'package:emtrack/services/update_vehicle_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../inspection/vehicle_inspe_controller.dart';
import '../models/masterDataMobileModel/tire_size_model.dart';
import '../models/masterDataMobileModel/manufacturer_model.dart';
import '../models/masterDataMobileModel/vehicle_model_item_model.dart';
import '../models/masterDataMobileModel/vehicle_type_model.dart';
import '../models/vehicle_model.dart';
import '../services/master_data_service.dart';
import '../utils/app_snackbar.dart';

class UpdateVehicleController extends GetxController {
  final UpdateVehicleService _vehicleService = UpdateVehicleService();
  final MasterDataService _masterService = MasterDataService();
  /* ---------------- TEXT CONTROLLERS (✅ ADDED) ---------------- */
  final manufacturerCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final tyreSizeCtrl = TextEditingController();
  final TextEditingController vehicleIdCtrl = TextEditingController();
  final TextEditingController vehicleNumberCtrl = TextEditingController();
  final TextEditingController removalTreadCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();
  final TextEditingController currentHoursCtrl = TextEditingController();

  /* ---------------- BASIC ---------------- */
  RxString vehicleNumber = ''.obs;
  RxString trackingMethodText = 'Hours'.obs;
  RxString removalTread = ''.obs;
  RxString currentHours = ''.obs;
  RxString comments = ''.obs;

  //===========selected value===============/
  RxString selectedManufecturer = "".obs;
  RxString selectedType = "".obs;
  RxString selectedModel = "".obs;
  RxString selectedTyreSize = "".obs;
  /* ---------------- PRESSURE ---------------- */
  RxInt vehicleId = 0.obs;
  RxInt axel1Pressure = 0.obs;
  RxInt axel2Pressure = 0.obs;

  /* ---------------- IDS ---------------- */
  RxInt manufacturerId = 0.obs;
  RxInt typeId = 0.obs;
  RxInt modelId = 0.obs;
  RxInt tireSizeId = 0.obs;
  RxInt locationId = 11711.obs;

  /* ---------------- DISPLAY ---------------- */
  RxString manufacturer = ''.obs;
  RxString type = ''.obs;
  RxString model = ''.obs;
  RxString tyreSize = ''.obs;

  /* ✅ ERROR MESSAGES */
  RxString vehicleNumberError = ''.obs;
  RxString trackingMethodError = ''.obs;
  RxString manufacturerError = ''.obs;
  RxString typeError = ''.obs;
  RxString modelError = ''.obs;
  RxString tyreSizeError = ''.obs;
  RxString removalTreadError = ''.obs;
  RxString currentHoursError = ''.obs;
  RxString commentsError = ''.obs;

  /* ---------------- MASTER DATA ---------------- */
  List<Manufacturer> manufacturers = [];
  List<VehicleType> types = [];
  List<VehicleModelItem> models = [];
  List<TireSize> tireSizes = [];

  /* ---------------- DROPDOWN LIST ---------------- */
  RxList<String> manufacturerList = <String>[].obs;
  RxList<String> typeList = <String>[].obs;
  RxList<String> modelList = <String>[].obs;
  RxList<String> tyreSizeList = <String>[].obs;

  /* ---------------- PRESSURE VISIBILITY ---------------- */
  /// 🔥 ONLY TYRE SIZE REQUIRED
  bool get showPressureSection => tireSizeId.value != 0;

  @override
  void onInit() {
    final int argVehicleId = Get.arguments as int;
    vehicleId.value = argVehicleId; // ✅ VERY IMPORTANT
    vehicleIdCtrl.text = argVehicleId.toString();

    removalTreadCtrl.text = removalTread.value;
    ever(removalTread, (v) => removalTreadCtrl.text = v);

    commentsCtrl.text = comments.value;
    ever(comments, (v) => commentsCtrl.text = v);

    currentHoursCtrl.text = currentHours.value;
    ever(currentHours, (v) => currentHoursCtrl.text = v);

    // Master data pehle, phir vehicle — taaki Type list (manufacturer pe depend) bhar sake
    loadMasterData().then((_) => loadVehicleForEdit(argVehicleId));

    ever(manufacturer, (v) => manufacturerCtrl.text = v);
    ever(type, (v) => typeCtrl.text = v);
    ever(model, (v) => modelCtrl.text = v);
    ever(tyreSize, (v) => tyreSizeCtrl.text = v);
  }

  String _formatDoubleForDisplay(double? value) {
    if (value == null) return '';
    final d = value;
    if (d.isNaN || d.isInfinite) return '';
    if (d % 1 == 0) return d.toInt().toString();
    return d.toString();
  }

  Future<void> loadVehicleForEdit(int vehicleIdParam) async {
    final vehicle = await _vehicleService.getVehicleById(vehicleIdParam);

    if (vehicle == null) return;

    final resolvedVehicleId = vehicle.vehicleId ?? 0;
    vehicleId.value = resolvedVehicleId;
    vehicleIdCtrl.text = resolvedVehicleId.toString();

    /// 🔥 BASIC
    vehicleNumber.value = vehicle.vehicleNumber ?? '';
    vehicleNumberCtrl.text = vehicleNumber.value;
    trackingMethodText.value = _trackingTextFromValue(vehicle.mileageType);

    final formattedRemovalTread = _formatDoubleForDisplay(vehicle.removalTread);
    removalTread.value = formattedRemovalTread;
    removalTreadCtrl.text = formattedRemovalTread;

    comments.value = vehicle.severityComments ?? '';
    commentsCtrl.text = comments.value;

    final formattedCurrentHours = _formatDoubleForDisplay(vehicle.currentHours);
    currentHours.value = formattedCurrentHours;
    currentHoursCtrl.text = formattedCurrentHours;

    /// 🔥 IDS
    manufacturerId.value = vehicle.manufacturerId ?? 0;
    typeId.value = vehicle.typeId ?? 0;
    modelId.value = vehicle.modelId ?? 0;
    tireSizeId.value = vehicle.tireSizeId ?? 0;

    /// 🔥 DISPLAY TEXT (dropdown binding)
    manufacturer.value = (vehicle.manufacturer ?? '').toUpperCase();
    type.value = vehicle.typeName ?? '';
    model.value = vehicle.modelName ?? '';
    tyreSize.value = vehicle.tireSize ?? '';

    /// 🔥 SELECTED VALUES (for dialog: show selected + keep at top)
    selectedManufecturer.value = manufacturer.value;
    selectedType.value = type.value;
    selectedModel.value = model.value;
    selectedTyreSize.value = tyreSize.value;

    /// 🔥 TYPE LIST — Edit pe Type dialog me data dikhane ke liye (manufacturer ke hisaab se)
    typeList.value = types
        .where((t) => t.manufacturerId == manufacturerId.value)
        .map((e) => e.typeName)
        .toList();

    modelList.value = models
        .where(
          (m) =>
              m.vehicleManufacturerId == manufacturerId.value &&
              m.vehicleTypeId == typeId.value,
        )
        .map((e) => e.modelName)
        .toSet()
        .toList();

    /// 🔥 PRESSURE
    axel1Pressure.value = vehicle.recommendedPressure?.toInt() ?? 0;
    axel2Pressure.value = vehicle.recommendedPressure?.toInt() ?? 0;

    update();
  }

  String _trackingTextFromValue(int? value) {
    switch (value) {
      case 1:
        return 'Hours';
      case 2:
        return 'Distance';
      case 3:
        return 'Both';
      default:
        return 'Hours';
    }
  }

  /* ---------------- LOAD DATA ---------------- */
  Future<void> loadMasterData() async {
    final data = await _masterService.fetchMasterData();

    manufacturers = (data['vehicleManufacturers'] as List).map((e) {
      final m = Manufacturer.fromJson(e);
      return Manufacturer(
        manufacturerId: m.manufacturerId,
        manufacturerName: m.manufacturerName.toUpperCase(),
        activeFlag: false,
      );
    }).toList();

    types = (data['vehicleTypes'] as List)
        .map((e) => VehicleType.fromJson(e))
        .toList();

    models = (data['vehicleModels'] as List)
        .map((e) => VehicleModelItem.fromJson(e))
        .toList();

    tireSizes = (data['tireSizes'] as List)
        .map((e) => TireSize.fromJson(e))
        .where((t) => t.tireSizeName.trim().isNotEmpty)
        .toList();

    manufacturerList.value = manufacturers
        .map((e) => e.manufacturerName.toUpperCase())
        .toList();

    modelList.clear();

    tyreSizeList.value = tireSizes.map((e) => e.tireSizeName).toSet().toList();
  }

  /* ---------------- MANUFACTURER (DEPENDENT) ---------------- */
  void selectManufacturer(String value) {
    manufacturer.value = value;

    final m = manufacturers.firstWhere(
      (e) => e.manufacturerName.toUpperCase() == value,
      orElse: () => manufacturers.first,
    );

    manufacturerId.value = m.manufacturerId;

    typeList.value = types
        .where((t) => t.manufacturerId == manufacturerId.value)
        .map((e) => e.typeName)
        .toList();

    type.value = '';
    typeId.value = 0;

    model.value = '';
    modelId.value = 0;
    modelList.clear();

    if (typeList.isEmpty) _showDialog('Type');
  }

  /* ---------------- TYPE (DEPENDENT) ---------------- */
  void selectType(String value) {
    type.value = value;

    final t = types.firstWhere(
      (e) => e.typeName == value,
      orElse: () => types.first,
    );

    typeId.value = t.typeId;

    modelList.value = models
        .where(
          (m) =>
              m.vehicleManufacturerId == manufacturerId.value &&
              m.vehicleTypeId == typeId.value,
        )
        .map((e) => e.modelName)
        .toSet()
        .toList();

    model.value = '';
    modelId.value = 0;
  }

  /* ---------------- MODEL (INDEPENDENT) ---------------- */
  void selectModel(String value) {
    model.value = value;

    final matched = models.where((e) => e.modelName == value).toList();

    if (matched.isEmpty) {
      modelId.value = 0;
      Get.snackbar('Error', 'Selected model not found');
      return;
    }

    modelId.value = matched.first.modelId;
  }

  /* ---------------- TYRE SIZE (INDEPENDENT) ---------------- */
  void selectTyreSize(String value) {
    tyreSize.value = value;

    final matched = tireSizes.where((e) => e.tireSizeName == value).toList();

    if (matched.isEmpty) {
      tireSizeId.value = 0;
      Get.snackbar('Error', 'Selected tyre size not found');
      return;
    }

    tireSizeId.value = matched.first.tireSizeId;
  }

  int get trackingMethodValue {
    switch (trackingMethodText.value) {
      case 'Hours':
        return 1;
      case 'Distance':
        return 2;
      case 'Both':
        return 3;
      default:
        return 1; // fallback
    }
  }

  int get axleCount {
    int count = 0;

    if (axel1Pressure.value >= 0) count++;
    if (axel2Pressure.value >= 0) count++;

    return count;
  }

  int get installedTyreCount => axleCount * 2;

  String get axleConfigValue => "$axleCount Axel";

  int get axleConfigIdValue {
    switch (axleCount) {
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 1;
    }
  }

  /* ---------------- SUBMIT ---------------- */
  Future<void> updateForm() async {
    // 🔍 VALIDATE ALL FIELDS
    if (vehicleId.value == 0) {
      Get.snackbar('Error', 'Vehicle ID missing, cannot update');
      return;
    }

    if (!_validateForm()) {
      return;
    }

    final parentAccountIdStr = await SecureStorage.getParentAccountId();
    final parentAccountId = int.tryParse(parentAccountIdStr ?? '');
    if (parentAccountId == null) {
      Get.snackbar('Error', 'Parent Account not selected');
      return;
    }

    final parsedRemovalTread = double.tryParse(removalTreadCtrl.text.isNotEmpty
            ? removalTreadCtrl.text
            : removalTread.value) ??
        0.0;
    final parsedCurrentHours = double.tryParse(
            currentHoursCtrl.text.isNotEmpty
                ? currentHoursCtrl.text
                : currentHours.value) ??
        0.0;

    final vehicle = VehicleModel(
      vehicleId: vehicleId.value,
      locationId: locationId.value,
      manufacturerId: manufacturerId.value,
      modelId: modelId.value,
      parentAccountId: parentAccountId,
      registeredDate: DateTime.now(),
      tireSizeId: tireSizeId.value,
      typeId: typeId.value,
      vehicleNumber: vehicleNumber.value,
      mileageType: trackingMethodValue, // ✅ INT
      removalTread: parsedRemovalTread,
      manufacturer: manufacturer.value,
      typeName: type.value,
      modelName: model.value,
      hoursDate: DateTime.now(),
      vehjsonFootprint: '{}',
      tireSize: tyreSize.value,
      axleConfig: axleConfigValue,
      areaOfOperation: '',
      modifications: '',
      imagesLocation: '',
      installedTireCount: installedTyreCount,
      axleConfigId: axleConfigIdValue,
      currentMiles: 0,
      currentHours: parsedCurrentHours,
      averageLoadingReqId: 0,
      averageLoadingReq: '',
      speedId: 0,
      speed: '',
      cutting: '',
      cuttingId: 0,
      trackingMethod: trackingMethodValue,
      severityComments: comments.value,
      recommendedPressure: ((axel1Pressure.value + axel2Pressure.value) / 2)
          .toDouble(),
      createdBy: parentAccountIdStr,
      createdDate: DateTime.now(),
      updatedBy: parentAccountIdStr,
      updatedDate: DateTime.now(),
      lastUpdatedDate: DateTime.now(),
    );

    /// 🔥 CREATE VEHICLE
    await _vehicleService.updateVehicle(vehicle);

    /// 🔄 REFRESH VEHICLE LIST (if controller exists)
    if (Get.isRegistered<AllVehicleController>()) {
      Get.find<AllVehicleController>().refreshVehicles();
    }

    if (Get.isRegistered<VehicleInspeController>()) {
      await Get.find<VehicleInspeController>().fetchInspectionData();
    }

    Get.offAll(() => HomeView());
    AppSnackbar.success(
      'Vehicle Updated Successfully',
      title: 'Vehicle Updated Successfully',
    );
    // Get.snackbar('Success', 'Vehicle Updated Successfully');
    resetForm();
  }

  /* ✅ VALIDATION METHOD */
  bool _validateForm() {
    // Clear all errors first
    _clearErrors();
    // Common required-field validator
    String? required(String? v) {
      if (v == null || v.trim().isEmpty) return 'This field is required';
      return null;
    }

    bool isValid = true;

    // Vehicle Number
    final vErr = required(vehicleNumber.value);
    if (vErr != null) {
      vehicleNumberError.value = vErr;
      isValid = false;
    }

    // Tracking Method
    final tErr = required(trackingMethodText.value);
    if (tErr != null) {
      trackingMethodError.value = tErr;
      isValid = false;
    }
    // Tracking Method
    final chErr = required(currentHours.value);
    if (chErr != null) {
      currentHoursError.value = chErr;
      isValid = false;
    }

    // Manufacturer
    final mErr = required(manufacturer.value);
    if (mErr != null || manufacturerId.value == 0) {
      manufacturerError.value = mErr ?? 'This field is required';
      isValid = false;
    }

    // Type
    final typeErr = required(type.value);
    if (typeErr != null || typeId.value == 0) {
      typeError.value = typeErr ?? 'This field is required';
      isValid = false;
    }

    // Model
    final modelErr = required(model.value);
    if (modelErr != null || modelId.value == 0) {
      modelError.value = modelErr ?? 'This field is required';
      isValid = false;
    }

    // Tyre Size
    final tyreErr = required(tyreSize.value);
    if (tyreErr != null || tireSizeId.value == 0) {
      tyreSizeError.value = tyreErr ?? 'This field is required';
      isValid = false;
    }

    // Removal Tread (required + numeric)
    final remErr = required(removalTread.value);
    if (remErr != null) {
      removalTreadError.value = remErr;
      isValid = false;
    } else {
      if (double.tryParse(removalTread.value) == null) {
        removalTreadError.value = 'Must be a valid number';
        isValid = false;
      }
    }

    // Vehicle Comments
    // final cErr = required(comments.value);
    // if (cErr != null) {
    //   commentsError.value = cErr;
    //   isValid = false;
    // }

    return isValid;
  }

  /* ✅ CLEAR ALL ERRORS */
  void _clearErrors() {
    vehicleNumberError.value = '';
    trackingMethodError.value = '';
    manufacturerError.value = '';
    typeError.value = '';
    modelError.value = '';
    tyreSizeError.value = '';
    removalTreadError.value = '';
    currentHoursError.value = '';
    commentsError.value = '';
  }

  /* ✅ CLEAR INDIVIDUAL FIELD ERRORS ON CHANGE */
  void clearVehicleNumberError() => vehicleNumberError.value = '';
  void clearTrackingMethodError() => trackingMethodError.value = '';
  void clearManufacturerError() => manufacturerError.value = '';
  void clearTypeError() => typeError.value = '';
  void clearModelError() => modelError.value = '';
  void clearTyreSizeError() => tyreSizeError.value = '';
  void clearRemovalTreadError() => removalTreadError.value = '';
  void clearCommentsError() => commentsError.value = '';
  void clearCurrentHoursError() => currentHoursError.value = '';
  /* ---------------- RESET ---------------- */
  void resetForm() {
    vehicleNumber.value = '';
    manufacturer.value = '';
    type.value = '';
    model.value = '';
    tyreSize.value = '';
    removalTread.value = '';
    comments.value = '';
    manufacturerId.value = 0;
    typeId.value = 0;
    modelId.value = 0;
    tireSizeId.value = 0;
    axel1Pressure.value = 32;
    axel2Pressure.value = 32;
  }

  /* ---------------- DIALOG ---------------- */
  void _showDialog(String name) {
    Get.defaultDialog(
      title: 'Data Not Available',
      middleText: '$name data not available',
      textConfirm: 'OK',
      onConfirm: Get.back,
    );
  }

  @override
  void onClose() {
    vehicleIdCtrl.dispose();
    super.onClose();
  }
}
