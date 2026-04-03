import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/masterDataMobileModel/tire_size_model.dart';
import '../models/masterDataMobileModel/manufacturer_model.dart';
import '../models/masterDataMobileModel/vehicle_model_item_model.dart';
import '../models/masterDataMobileModel/vehicle_type_model.dart';
import '../models/vehicle_model.dart';
import '../services/master_data_service.dart';
import '../services/create_vehicle_service.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();
  final MasterDataService _masterService = MasterDataService();

  /* ---------------- TEXT CONTROLLERS  ---------------- */
  final manufacturerCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final tyreSizeCtrl = TextEditingController();
  TextEditingController currentHoursCtrl = TextEditingController(text: "0");

  /* ---------------- LOADING STATE ---------------- */
  RxBool isLoadingMasterData = true.obs;
  RxBool isSubmitting = false.obs;

  /* ---------------- BASIC ---------------- */
  RxString vehicleNumber = ''.obs;
  RxString trackingMethodText = 'Hours'.obs;
  RxString removalTread = ''.obs;
  RxString currentHours = '0'.obs;
  RxString comments = ''.obs;

  RxString selectedManufecturer = "".obs;
  RxString selectedType = "".obs;
  RxString selectedModel = "".obs;
  RxString selectedTyreSize = "".obs;

  /* ---------------- PRESSURE ---------------- */
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

  /* ---------------- ERROR MESSAGES ---------------- */
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
  bool get showPressureSection => tireSizeId.value != 0;

  @override
  void onInit() {
    super.onInit();
    loadMasterData();

    ever(manufacturer, (v) => manufacturerCtrl.text = v);
    ever(type, (v) => typeCtrl.text = v);
    ever(model, (v) => modelCtrl.text = v);
    ever(tyreSize, (v) => tyreSizeCtrl.text = v);
  }

  /* ---------------- LOAD DATA ---------------- */
  Future<void> loadMasterData() async {
    try {
      isLoadingMasterData.value = true; // ✅ Loading shuru

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

      manufacturerList.value =
          manufacturers.map((e) => e.manufacturerName).toList();

      tyreSizeList.value =
          tireSizes.map((e) => e.tireSizeName).toSet().toList();

      modelList.value =
          models.map((e) => e.modelName).toSet().toList();

      print("✅ Manufacturers: ${manufacturerList.length}");
      print("✅ TyreSizes: ${tyreSizeList.length}");
      print("✅ Models: ${modelList.length}");

    } catch (e) {
      print("❌ Master data load error: $e");
      Get.snackbar(
        'Error',
        'Failed to load master data. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMasterData.value = false; // ✅ Loading khatam — success ya error dono pe
    }
  }

  /* ---------------- MANUFACTURER ---------------- */
  void selectManufacturer(String value) {
    manufacturer.value = value;

    final m = manufacturers.firstWhere(
          (e) => e.manufacturerName == value,
      orElse: () => manufacturers.first,
    );

    manufacturerId.value = m.manufacturerId;

    typeList.value = types
        .where((t) => t.manufacturerId == manufacturerId.value)
        .map((e) => e.typeName)
        .toSet()
        .toList();

    // RESET downstream
    type.value = '';
    typeId.value = 0;
    model.value = '';
    modelId.value = 0;
    modelList.clear();

    print("🏭 Manufacturer: $value (ID: ${manufacturerId.value})");
    print("📋 Types found: ${typeList.length}");

    if (typeList.isEmpty) _showDialog('Type');
  }

  /* ---------------- TYPE ---------------- */
  void selectType(String value) {
    type.value = value;

    final t = types.firstWhere(
          (e) => e.typeName == value,
      orElse: () => types.first,
    );

    typeId.value = t.typeId;

    modelList.value = models
        .where((m) => m.vehicleTypeId == t.typeId)
        .map((e) => e.modelName)
        .toSet()
        .toList();

    // RESET downstream
    model.value = '';
    modelId.value = 0;

    print("🔧 Type: $value (ID: ${t.typeId})");
    print("📋 Models found: ${modelList.length}");

    if (modelList.isEmpty) _showDialog('Model');
  }

  /* ---------------- MODEL ---------------- */
  void selectModel(String value) {
    model.value = value;

    final matched = models.where((e) => e.modelName == value).toList();

    if (matched.isEmpty) {
      modelId.value = 0;
      Get.snackbar('Error', 'SELECTED model not found');
      return;
    }

    modelId.value = matched.first.modelId;
  }

  /* ---------------- TYRE SIZE ---------------- */
  void selectTyreSize(String value) {
    tyreSize.value = value;

    final matched = tireSizes.where((e) => e.tireSizeName == value).toList();

    if (matched.isEmpty) {
      tireSizeId.value = 0;
      Get.snackbar('Error', 'SELECTED tyre size not found');
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
        return 1;
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
  Future<void> submitForm() async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true; // ✅ Submit loading shuru

      final String? parentAccountId = await SecureStorage.getParentAccountId();
      final String? locationId = await SecureStorage.getLocationId();

      final vehicle = VehicleModel(
        locationId: int.parse(locationId.toString()),
        manufacturerId: manufacturerId.value,
        modelId: modelId.value,
        parentAccountId: int.parse(parentAccountId.toString()),
        registeredDate: DateTime.now(),
        tireSizeId: tireSizeId.value,
        typeId: typeId.value,
        vehicleNumber: vehicleNumber.value,
        mileageType: trackingMethodValue,
        removalTread: double.parse(removalTread.value),
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
        installedTires: [],
        axleConfigId: axleConfigIdValue,
        currentMiles: 0,
        currentHours: double.parse(currentHours.value),
        averageLoadingReqId: 0,
        averageLoadingReq: '',
        speedId: 0,
        speed: '',
        cutting: '',
        cuttingId: 0,
        trackingMethod: trackingMethodValue,
        severityComments: comments.value,
        recommendedPressure:
        ((axel1Pressure.value + axel2Pressure.value) / 2).toDouble(),
        createdBy: parentAccountId,
        createdDate: DateTime.now(),
        updatedBy: parentAccountId,
        updatedDate: DateTime.now(),
        lastUpdatedDate: DateTime.now(),
      );

      int? vehicleId = await _vehicleService.createVehicle(vehicle);

      if (Get.isRegistered<AllVehicleController>()) {
        Get.find<AllVehicleController>().refreshVehicles();
      }

      if (vehicleId == null) {
        Get.snackbar('Error', 'VEHICLE creation failed');
        return;
      }

      final String vehicleNoToSend = vehicleNumber.value;
      resetForm();

      Get.offAllNamed(
        AppPages.HOME,
        arguments: {
          "showSuccess": true,
          "type": "submit",
          "module": "vehicle",
          "vehicleNo": vehicleNoToSend,
          "vehicleId": vehicleId,
        },
      );
    } catch (e) {
      print("❌ Submit error: $e");
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isSubmitting.value = false; // ✅ Submit loading khatam
    }
  }

  /* ---------------- VALIDATION ---------------- */
  bool _validateForm() {
    _clearErrors();
    bool isValid = true;

    if (vehicleNumber.value.trim().isEmpty) {
      vehicleNumberError.value = "VEHICLE ID is required";
      isValid = false;
    } else {
      if (Get.isRegistered<AllVehicleController>()) {
        final vehicleList = Get.find<AllVehicleController>().vehicleList;
        final isDuplicate = vehicleList.any(
              (v) =>
          v.vehicleNumber!.toLowerCase() ==
              vehicleNumber.value.trim().toLowerCase(),
        );
        if (isDuplicate) {
          vehicleNumberError.value = "VEHICLE Number is already taken";
          isValid = false;
        }
      }
    }

    if (trackingMethodText.value.trim().isEmpty) {
      trackingMethodError.value = "PLEASE select tracking method";
      isValid = false;
    }

    if (currentHours.value.trim().isEmpty) {
      currentHoursError.value = "CURRENT hours is required";
      isValid = false;
    } else if (double.tryParse(currentHours.value) == null) {
      currentHoursError.value = "ONLY numeric value allowed";
      isValid = false;
    } else if (double.parse(currentHours.value) < 0) {
      currentHoursError.value = "CURRENT hours cannot be negative";
      isValid = false;
    }

    if (manufacturerId.value == 0) {
      manufacturerError.value = "THIS is a required field.";
      isValid = false;
    }

    if (typeId.value == 0) {
      typeError.value = "VEHICLE type is required.";
      isValid = false;
    }

    if (modelId.value == 0) {
      modelError.value = "VEHICLE model is required.";
      isValid = false;
    }

    if (tireSizeId.value == 0) {
      tyreSizeError.value = "VEHICLE tire size is required.";
      isValid = false;
    }

    if (removalTread.value.trim().isEmpty) {
      removalTreadError.value = "This field is required.";
      isValid = false;
    } else if (double.tryParse(removalTread.value) == null) {
      removalTreadError.value = "Only numeric values are allowed.";
      isValid = false;
    } else if (removalTread.value.contains('.')) {
      final parts = removalTread.value.split('.');
      if (parts[1].length > 1) {
        removalTreadError.value = "Only 1 digit allowed after decimal point.";
        isValid = false;
      }
    }

    return isValid;
  }

  void _clearErrors() {
    vehicleNumberError.value = '';
    trackingMethodError.value = '';
    manufacturerError.value = '';
    typeError.value = '';
    modelError.value = '';
    tyreSizeError.value = '';
    removalTreadError.value = '';
    commentsError.value = '';
  }

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

  void _showDialog(String name) {
    Get.defaultDialog(
      title: 'Data Not Available',
      middleText: '$name data not available',
      textConfirm: 'OK',
      onConfirm: Get.back,
    );
  }
}