// import 'package:emtrack/create_tyre/app_loader.dart';
// import 'package:emtrack/create_tyre/create_tyre_model.dart';
// import 'package:emtrack/create_tyre/create_tyre_service.dart';
// import 'package:emtrack/services/master_data_service.dart';
// import 'package:emtrack/utils/secure_storage.dart';
// import 'package:emtrack/views/home/home_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CreateTyreController extends GetxController {
//   // ================= STEPPER =================
//   final RxInt currentStep = 0.obs;
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final MasterDataService _masterService = MasterDataService();
//   // STEP 1
//   final statusList = <String>[].obs;
//   // UI
//   String? registeredDateApi; // Backend
//   //========selected value=========//
//   RxString selectedstatus = "".obs;
//   RxString selectedTrackingMethod = "".obs;
//   // STEP 2
//   final manufacturerList = <String>[].obs;
//   final tireSizeList = <String>[].obs;
//   final typeList = <String>[].obs;
//   final indCodeList = <String>[].obs;
//   final compoundList = <String>[].obs;
//   final loadRatingList = <String>[].obs;
//   final speedRatingList = <String>[].obs;

//   // STEP 4
//   final fillTypeList = <String>[].obs;

//   void nextStep() {
//     // 🔴 VALIDATION BEFORE NEXT STEP
//     if (!formKey.currentState!.validate()) {
//       // Get.snackbar(
//       //   "Invalid Step",
//       //   "Please fill required fields",
//       //   snackPosition: SnackPosition.BOTTOM,
//       // );
//       return;
//     }

//     if (currentStep.value < 3) {
//       currentStep.value++;
//     }
//   }

//   void previousStep() {
//     if (currentStep.value > 0) {
//       currentStep.value--;
//     }
//   }

//   // ================= MODEL =================
//   final CreateTyreModel model = CreateTyreModel();

//   // ================= STEP 1 =================
//   final tireSerialNo = TextEditingController();
//   final brandNo = TextEditingController();
//   final registeredDate = TextEditingController();
//   final evaluationNo = TextEditingController();
//   final lotNo = TextEditingController();
//   final poNo = TextEditingController();
//   final dispositionText = "Inventory".obs;
//   final statusText = "New".obs;
//   final trackingMethodText = "Hours".obs;
//   final currentHours = TextEditingController(text: "0");

//   // ================= STEP 2 (IDs) =================
//   final RxInt starRating = 0.obs;
//   final manufacturerId = TextEditingController();
//   final sizeId = TextEditingController();
//   final starRatingId = TextEditingController();
//   final typeId = TextEditingController();
//   final indCodeId = TextEditingController();
//   final compoundId = TextEditingController();
//   final loadRatingId = TextEditingController();
//   final speedRatingId = TextEditingController();

//   // ================= STEP 3 =================
//   final originalTread = TextEditingController();
//   final removeAt = TextEditingController(text: "0");
//   final purchasedTread = TextEditingController();
//   final outsideTread = TextEditingController(text: "0");
//   final insideTread = TextEditingController(text: "0");

//   // ================= STEP 4 =================
//   final purchaseCost = TextEditingController(text: "0");
//   final casingValue = TextEditingController(text: "0");
//   final fillTypeId = TextEditingController();
//   final fillCost = TextEditingController(text: "0");
//   final repairCost = TextEditingController(text: "0");
//   final retreadCost = TextEditingController(text: "0");
//   final numberOfRetreadsVal = 0.obs;
//   final warrantyAdjustment = TextEditingController(text: "0");
//   final costAdjustment = TextEditingController(text: "0");
//   final soldAmount = TextEditingController(text: "0");
//   final netCost = TextEditingController(text: "0");
//   //===========

//   // ⭐ STAR ENABLE FLAG
//   final RxBool isStarEnabled = false.obs;
//   // call this whenever manufacturer / size changes
//   void checkStarEnable() {
//     isStarEnabled.value =
//         manufacturerId.text.trim().isNotEmpty && sizeId.text.trim().isNotEmpty;
//     update();
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     loadMasterData();
//     manufacturerId.addListener(checkStarEnable);
//     sizeId.addListener(checkStarEnable);
//     final now = DateTime.now();

//     // 👁 UI (dd-MM-yyyy)
//     registeredDate.text =
//         "${now.day.toString().padLeft(2, '0')}/"
//         "${now.month.toString().padLeft(2, '0')}/"
//         "${now.year}";

//     // 🔥 Backend (ISO 8601)
//     registeredDateApi = now.toUtc().toIso8601String();

//     /// default backend values
//     model.dispositionId = 8;
//     dispositionText.value = "Inventory";

//     model.tireStatusId = 7;
//     statusText.value = "New";

//     model.trackingMethod = 1;
//     trackingMethodText.value = "Hours";

//     model.mountStatus = "Not Mounted";
//     model.isMountToRim = false;

//     model.numberOfRetreads = 0;
//     numberOfRetreadsVal.value = 0;
//   }

//   // ================= NET COST =================
//   void calculateNetCost() {
//     double a = double.tryParse(purchaseCost.text) ?? 0;
//     double b = double.tryParse(casingValue.text) ?? 0;
//     double c = double.tryParse(fillCost.text) ?? 0;
//     double d = double.tryParse(repairCost.text) ?? 0;
//     double e = double.tryParse(retreadCost.text) ?? 0;
//     double f = double.tryParse(warrantyAdjustment.text) ?? 0;
//     double g = double.tryParse(costAdjustment.text) ?? 0;
//     double h = double.tryParse(soldAmount.text) ?? 0;

//     netCost.text = (a - b + c + d + e + f - g - h).toStringAsFixed(2);
//   }

//   // ================= MAP CONTROLLERS → MODEL =================
//   void bindToModel() {
//     // STEP 1
//     model.tireSerialNo = tireSerialNo.text.trim();
//     model.brandNo = brandNo.text ?? 0;
//     model.registeredDate = registeredDateApi;
//     model.evaluationNo = evaluationNo.text.trim();
//     model.lotNo = lotNo.text.trim();
//     model.poNo = poNo.text.trim();
//     model.currentHours = int.tryParse(currentHours.text) ?? 0;

//     // STEP 2
//     model.manufacturerId = int.tryParse(manufacturerId.text) ?? 0;
//     model.sizeId = int.tryParse(sizeId.text) ?? 0;
//     model.starRatingId = int.tryParse(starRatingId.text) ?? 0;
//     model.typeId = int.tryParse(typeId.text) ?? 0;
//     model.indCodeId = int.tryParse(indCodeId.text) ?? 0;
//     model.compoundId = int.tryParse(compoundId.text) ?? 0;
//     model.loadRatingId = int.tryParse(loadRatingId.text) ?? 0;
//     model.speedRatingId = int.tryParse(speedRatingId.text) ?? 0;

//     // STEP 3
//     model.originalTread = int.tryParse(originalTread.text) ?? 0;
//     model.removeAt = int.tryParse(removeAt.text) ?? 0;
//     model.purchasedTread = int.tryParse(purchasedTread.text) ?? 0;
//     model.outsideTread = int.tryParse(outsideTread.text) ?? 0;
//     model.insideTread = int.tryParse(insideTread.text) ?? 0;

//     // STEP 4
//     model.purchaseCost = double.tryParse(purchaseCost.text) ?? 0;
//     model.casingValue = double.tryParse(casingValue.text) ?? 0;
//     model.fillTypeId = int.tryParse(fillTypeId.text) ?? 0;
//     model.fillCost = double.tryParse(fillCost.text) ?? 0;
//     model.repairCost = double.tryParse(repairCost.text) ?? 0;
//     model.retreadCost = double.tryParse(retreadCost.text) ?? 0;
//     model.warrantyAdjustment = double.tryParse(warrantyAdjustment.text) ?? 0;
//     model.costAdjustment = double.tryParse(costAdjustment.text) ?? 0;
//     model.soldAmount = double.tryParse(soldAmount.text) ?? 0;
//     model.netCost = double.tryParse(netCost.text) ?? 0;
//   }

//   // ================= SUBMIT =================
//   Future<void> submitTyre() async {
//     if (!formKey.currentState!.validate()) {
//       Get.snackbar(
//         "Invalid Form",
//         "Please fix errors",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     try {
//       AppLoader.show();

//       final String? parentAccountId = await SecureStorage.getParentAccountId();

//       if (parentAccountId == null || parentAccountId.isEmpty) {
//         AppLoader.hide();
//         Get.snackbar(
//           "Error",
//           "Parent Account not selected",
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return;
//       }

//       /// 1️⃣ Bind form → model
//       bindToModel();

//       /// 2️⃣ set parentAccountId
//       model.parentAccountId = int.parse(parentAccountId);

//       /// 3️⃣ API CALL
//       await TyreService.saveTyre(model);

//       AppLoader.hide();

//       /// ✅ SHOW SUCCESS DIALOG
//       Get.offAll(
//         () => HomeView(),
//         arguments: {
//           "showSuccess": true,
//           "serialNo": tireSerialNo.text,
//           "type": "Create", // ya "create"
//         },
//       );
//     } catch (e) {
//       AppLoader.hide();
//       Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   void cancelDialog() {
//     Get.defaultDialog(
//       title: "Cancel Request",
//       middleText: "Are you sure you want to cancel?",
//       textCancel: "No",
//       textConfirm: "Yes",
//       onConfirm: () {
//         // Close dialog
//         Get.back();
//         Get.back();
//       },
//       onCancel: () {
//         Get.back();
//         Get.back(); // Nothing, just close dialog
//       },
//     );
//   }

//   Future<void> loadMasterData() async {
//     try {
//       final data = await _masterService.fetchMasterData();

//       // 🔹 STEP 1
//       statusList.assignAll(
//         (data['tireStatus'] as List)
//             .map((e) => e['statusName'].toString())
//             .toSet()
//             .toList(),
//       );

//       // 🔹 STEP 2
//       manufacturerList.assignAll(
//         (data['tireManufacturers'] as List)
//             .map((e) => e['manufacturerName'].toString().toUpperCase())
//             .toSet()
//             .toList(),
//       );

//       tireSizeList.assignAll(
//         (data['tireSizes'] as List)
//             .map((e) => e['tireSizeName'].toString())
//             .toSet()
//             .toList(),
//       );

//       typeList.assignAll(
//         (data['tireTypes'] as List)
//             .map((e) => e['typeName'].toString())
//             .toSet()
//             .toList(),
//       );

//       indCodeList.assignAll(
//         (data['tireIndCodes'] as List)
//             .map((e) => e['codeName'].toString())
//             .toSet()
//             .toList(),
//       );

//       compoundList.assignAll(
//         (data['tireCompounds'] as List)
//             .map((e) => e['compoundName'].toString())
//             .toSet()
//             .toList(),
//       );

//       loadRatingList.assignAll(
//         (data['tireLoadRatings'] as List)
//             .map((e) => e['ratingName'].toString())
//             .toSet()
//             .toList(),
//       );

//       speedRatingList.assignAll(
//         (data['tireSpeedRatings'] as List)
//             .map((e) => e['speedRatingName'].toString())
//             .toSet()
//             .toList(),
//       );

//       // 🔹 STEP 4
//       fillTypeList.assignAll(
//         (data['tireFillTypes'] as List)
//             .map((e) => e['fillTypeName'].toString())
//             .toSet()
//             .toList(),
//       );
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     }
//   }

//   void setStarRating(int value) {
//     starRating.value = value; // data
//     starRatingId.text = value.toString();
//     update(); // 🔥 UI rebuild
//   }

//   @override
//   void onClose() {
//     manufacturerId.dispose();
//     sizeId.dispose();
//     starRatingId.dispose();
//     super.onClose();
//   }
//   //==========================save and clone code ==========================

//   Future<void> saveAndClone() async {
//     if (!formKey.currentState!.validate()) {
//       Get.snackbar(
//         "Invalid Form",
//         "Please fix errors",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     try {
//       AppLoader.show();

//       final String? parentAccountId = await SecureStorage.getParentAccountId();

//       if (parentAccountId == null || parentAccountId.isEmpty) {
//         AppLoader.hide();
//         Get.snackbar(
//           "Error",
//           "Parent Account not selected",
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return;
//       }

//       /// 1️⃣ Bind form → model
//       bindToModel();

//       /// 2️⃣ set parentAccountId
//       model.parentAccountId = int.parse(parentAccountId);

//       /// 3️⃣ API CALL
//       await TyreService.saveTyre(model);

//       AppLoader.hide();

//       /// 4️⃣ RESET ONLY NECESSARY FIELDS
//       tireSerialNo.clear(); // 🔥 new serial for clone
//       brandNo.clear();

//       /// Step reset
//       currentStep.value = 0;

//       Get.snackbar(
//         "Success",
//         "Tyre saved. Ready to clone.",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } catch (e) {
//       AppLoader.hide();
//       Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   void bindModelToControllers(CreateTyreModel m) {
//     tireSerialNo.text = m.tireSerialNo.toString();
//     brandNo.text = m.brandNo.toString();
//     evaluationNo.text = m.evaluationNo ?? "";
//     lotNo.text = m.lotNo ?? "";
//     poNo.text = m.poNo ?? "";
//     currentHours.text = m.currentHours.toString();

//     manufacturerId.text = m.manufacturerId.toString();
//     sizeId.text = m.sizeId.toString();
//     starRatingId.text = m.starRatingId.toString();
//     typeId.text = m.typeId.toString();
//     indCodeId.text = m.indCodeId.toString();
//     compoundId.text = m.compoundId.toString();
//     loadRatingId.text = m.loadRatingId.toString();
//     speedRatingId.text = m.speedRatingId.toString();

//     originalTread.text = m.originalTread.toString();
//     removeAt.text = m.removeAt.toString();
//     purchasedTread.text = m.purchasedTread.toString();
//     outsideTread.text = m.outsideTread.toString();
//     insideTread.text = m.insideTread.toString();

//     purchaseCost.text = m.purchaseCost.toString();
//     casingValue.text = m.casingValue.toString();
//     fillTypeId.text = m.fillTypeId.toString();
//     fillCost.text = m.fillCost.toString();
//     repairCost.text = m.repairCost.toString();
//     retreadCost.text = m.retreadCost.toString();
//     warrantyAdjustment.text = m.warrantyAdjustment.toString();
//     costAdjustment.text = m.costAdjustment.toString();
//     soldAmount.text = m.soldAmount.toString();
//     netCost.text = m.netCost.toString();

//     update();
//   }
// }
