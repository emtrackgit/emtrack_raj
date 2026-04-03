import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/views/all_vehicles_list_view.dart';
import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/views/home/home_view.dart';
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
  /* ---------------- TEXT CONTROLLERS (✅ ADDED) ---------------- */
  final manufacturerCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final tyreSizeCtrl = TextEditingController();

  TextEditingController currentHoursCtrl = TextEditingController(text: "0");

  /* ---------------- BASIC ---------------- */
  RxString vehicleNumber = ''.obs;
  RxString trackingMethodText = 'Hours'.obs;
  RxString removalTread = ''.obs;
  RxString currentHours = '0'.obs;
  RxString comments = ''.obs;
  //===========selected value===============/
  RxString selectedManufecturer = "".obs;
  RxString selectedType = "".obs;
  RxString selectedModel = "".obs;
  RxString selectedTyreSize = "".obs;

  /// ---------------- DYNAMIC AXLE ----------------
  RxList<int> pressureList = <int>[].obs;
  RxString axleConfig = ''.obs;
  RxInt axleConfigId = 0.obs;
  RxBool isModelTire = false.obs;
  RxInt installedTireCount = 0.obs;

  /* ---------------- IDS ---------------- */
  RxInt manufacturerId = 0.obs;
  RxInt typeId = 0.obs;
  RxInt modelId = 0.obs;
  RxInt tireSizeId = 0.obs;
  RxInt locationId =
      11711.obs; // ✅ Default location ID (same as in create_tyre_model)

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
  bool get showPressureSection => isModelTire.value;

  @override
  void onInit() {
    super.onInit();
    loadMasterData();

    /* -------- Rx ↔ Controller SYNC (✅ ADDED) -------- */
    ever(manufacturer, (v) => manufacturerCtrl.text = v);
    ever(type, (v) => typeCtrl.text = v);
    ever(model, (v) => modelCtrl.text = v);
    ever(tyreSize, (v) => tyreSizeCtrl.text = v);
  }

  /* ---------------- LOAD DATA ---------------- */
  Future<void> loadMasterData() async {
    final data = await _masterService.fetchMasterData();

    /*manufacturers = (data['vehicleManufacturers'] as List)
        .map((e) => Manufacturer.fromJson(e))
        .toList();*/

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

    /*tireSizes = (data['tireSizes'] as List)
        .map((e) => TireSize.fromJson(e))
        .toList();*/

    tireSizes = (data['tireSizes'] as List)
        .map((e) => TireSize.fromJson(e))
        .where((t) => t.tireSizeName.trim().isNotEmpty)
        .toList();

    manufacturerList.value = manufacturers
        .map((e) => e.manufacturerName)
        .toList();

    // ✅ Independent dropdowns (duplicate safe)
    modelList.value = models.map((e) => e.modelName).toSet().toList();

    tyreSizeList.value = tireSizes.map((e) => e.tireSizeName).toSet().toList();
  }

  /* ---------------- MANUFACTURER (DEPENDENT) ---------------- */
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

    type.value = '';
    typeId.value = 0;

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
  }

  /* ---------------- MODEL (INDEPENDENT) ---------------- */
  void selectModel(String value) async {
    model.value = value;

    final matched = models.where((e) => e.modelName == value).toList();

    if (matched.isEmpty) {
      modelId.value = 0;
      Get.snackbar('Error', 'Selected model not found');
      return;
    }

    modelId.value = matched.first.modelId;

    /// 🔥 CALL CONFIG API LIKE IONIC
    await loadVehicleConfiguration(modelId.value);
  }

  Future<void> loadVehicleConfiguration(int modelId) async {
    final config = await _masterService.fetchMasterData();

    axleConfig.value = config['configurationName']; // e.g. "1122"
    axleConfigId.value = config['axleConfigId'];

    /// 🔥 Convert to axle count
    final axles = axleConfig.value.split("");

    pressureList.value = List.generate(axles.length, (index) => 0);

    /// Installed tire count
    installedTireCount.value = axles.length * 2;

    isModelTire.value = true;
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

  /* ---------------- SUBMIT ---------------- */
  Future<void> submitForm() async {
    // 🔍 VALIDATE ALL FIELDS
    if (!_validateForm()) {
      return;
    }

    /// ✅ GET parentAccountId FROM SECURE STORAGE
    final String? parentAccountId = await SecureStorage.getParentAccountId();

    print("📦 ParentAccountId BODY: ${int.parse(parentAccountId.toString())}");

    final vehicle = VehicleModel(
      locationId: locationId.value,
      manufacturerId: manufacturerId.value,
      modelId: modelId.value,
      parentAccountId: int.parse(parentAccountId.toString()),
      registeredDate: DateTime.now(),
      tireSizeId: tireSizeId.value,
      typeId: typeId.value,
      vehicleNumber: vehicleNumber.value,
      mileageType: trackingMethodValue, // ✅ INT
      removalTread: double.parse(removalTread.value),
      manufacturer: manufacturer.value,
      typeName: type.value,
      modelName: model.value,
      hoursDate: DateTime.now(),
      vehjsonFootprint: '{}',
      tireSize: tyreSize.value,
      axleConfig: axleConfig.value,
      areaOfOperation: '',
      modifications: '',
      imagesLocation: '',
      installedTireCount: installedTireCount.value,
      axleConfigId: axleConfigId.value,
      currentMiles: 0,
      currentHours: 0.0,
      averageLoadingReqId: 0,
      averageLoadingReq: '',
      speedId: 0,
      speed: '',
      cutting: '',
      cuttingId: 0,
      trackingMethod: trackingMethodValue,
      severityComments: comments.value,
      recommendedPressure: double.tryParse(pressureList.join(",")),
      createdBy: parentAccountId,
      createdDate: DateTime.now(),
      updatedBy: parentAccountId,
      updatedDate: DateTime.now(),
      lastUpdatedDate: DateTime.now(),
    );

    /// 🔥 CREATE VEHICLE
    // await _vehicleService.createVehicle(vehicle);
    int? vehicleId = await _vehicleService.createVehicle(vehicle);

    /// 🔄 REFRESH VEHICLE LIST (if controller exists)
    if (Get.isRegistered<AllVehicleController>()) {
      Get.find<AllVehicleController>().refreshVehicles();
    }
    if (vehicleId == null) {
      Get.snackbar('Error', 'Vehicle creation failed');
      return; // ✅ Stop here, don't navigate
    }

    print("Vehicle created with ID: $vehicleId");
    final String vehicleNoToSend = vehicleNumber.value; // ✅ store first

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
  }

  /* ✅ VALIDATION METHOD */
  bool _validateForm() {
    _clearErrors();
    bool isValid = true;

    /// VEHICLE NUMBER
    /// VEHICLE NUMBER
    if (vehicleNumber.value.trim().isEmpty) {
      vehicleNumberError.value = "Vehicle ID is required";
      isValid = false;
    } else {
      if (Get.isRegistered<AllVehicleController>()) {
        final vehicleList =
            Get.find<AllVehicleController>().vehicleList; // your vehicle list

        final isDuplicate = vehicleList.any(
          (v) =>
              v.vehicleNumber!.toLowerCase() ==
              vehicleNumber.value.trim().toLowerCase(),
        );

        if (isDuplicate) {
          vehicleNumberError.value = "Vehicle Number is already taken";
          isValid = false;
        }
      }
    }

    /// TRACKING METHOD
    if (trackingMethodText.value.trim().isEmpty) {
      trackingMethodError.value = "Please select tracking method";
      isValid = false;
    }

    /// CURRENT HOURS (Custom Validation)
    if (currentHours.value.trim().isEmpty) {
      currentHoursError.value = "Current hours is required";
      isValid = false;
    } else if (double.tryParse(currentHours.value) == null) {
      currentHoursError.value = "Only numeric value allowed";
      isValid = false;
    } else if (double.parse(currentHours.value) < 0) {
      currentHoursError.value = "Current hours cannot be negative";
      isValid = false;
    }

    /// MANUFACTURER
    if (manufacturerId.value == 0) {
      manufacturerError.value = "This is a required field.";
      isValid = false;
    }

    /// TYPE
    if (typeId.value == 0) {
      typeError.value = "vehicle type is required.";
      isValid = false;
    }

    /// MODEL
    if (modelId.value == 0) {
      modelError.value = "vehicle model is required.";
      isValid = false;
    }

    /// TYRE SIZE
    if (tireSizeId.value == 0) {
      tyreSizeError.value = "vehicle tire size is required.";
      isValid = false;
    }

    /// REMOVAL TREAD
    if (removalTread.value.trim().isEmpty) {
      removalTreadError.value = "this is a required field.";
      isValid = false;
    } else if (double.tryParse(removalTread.value) == null) {
      removalTreadError.value = "Removal tread must be numeric";
      isValid = false;
    }

    /// COMMENTS
    if (comments.value.trim().isEmpty) {
      commentsError.value = "Please enter vehicle comments";
      isValid = false;
    } else if (comments.value.length > 200) {
      commentsError.value = "Maximum 200 characters allowed";
      isValid = false;
    }

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

    // axel1Pressure.value = 32;
    // axel2Pressure.value = 32;
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

  /* Future<Map<String, dynamic>?> fetchVehicleConfiguration(int modelId) async {
  try {
    final String? cookies = await SecureStorage.getCookie();

    final url = Uri.parse(
      "$baseUrl/vehicle/getVehicleConfigurationByModelId/$modelId",
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (cookies != null) "Cookie": cookies,  // 🔥 IMPORTANT
      },
    );

    print("CONFIG STATUS: ${response.statusCode}");
    print("CONFIG RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      /// 🔥 Adjust if wrapped in data
      return {
        "configurationName": data["configurationName"],
        "axleConfigId": data["axleConfigId"],
      };
    } else {
      print("❌ Config API failed");
      return null;
    }
  } catch (e) {
    print("❌ Config API error: $e");
    return null;
  }
}
*/
}
