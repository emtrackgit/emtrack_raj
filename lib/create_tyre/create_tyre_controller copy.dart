// import 'package:emtrack/create_tyre/app_loader.dart';
// import 'package:emtrack/create_tyre/create_tyre_model.dart';
// import 'package:emtrack/create_tyre/create_tyre_service.dart';
// import 'package:emtrack/utils/secure_storage.dart';
// import 'package:emtrack/views/home/home_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CreateTyreController extends GetxController {
//   // ================= STEPPER =================
//   final RxInt currentStep = 0.obs;
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   void nextStep() {
//     // 🔴 VALIDATION BEFORE NEXT STEP
//     if (!formKey.currentState!.validate()) {
//       Get.snackbar(
//         "Invalid Step",
//         "Please fill required fields",
//         snackPosition: SnackPosition.BOTTOM,
//       );
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
//   final currentHours = TextEditingController();

//   // ================= STEP 2 (IDs) =================
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
//   final removeAt = TextEditingController();
//   final purchasedTread = TextEditingController();
//   final outsideTread = TextEditingController();
//   final insideTread = TextEditingController();

//   // ================= STEP 4 =================
//   final purchaseCost = TextEditingController();
//   final casingValue = TextEditingController();
//   final fillTypeId = TextEditingController();
//   final fillCost = TextEditingController();
//   final repairCost = TextEditingController(text: "0");
//   final retreadCost = TextEditingController(text: "0");
//   final numberOfRetreadsVal = 0.obs;
//   final warrantyAdjustment = TextEditingController(text: "0");
//   final costAdjustment = TextEditingController(text: "0");
//   final soldAmount = TextEditingController(text: "0");
//   final netCost = TextEditingController(text: "0");

//   @override
//   void onInit() {
//     super.onInit();

//     registeredDate.text =
//         "${DateTime.now().day.toString().padLeft(2, '0')}-"
//         "${DateTime.now().month.toString().padLeft(2, '0')}-"
//         "${DateTime.now().year}";

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
//     model.brandNo = int.tryParse(brandNo.text) ?? 0;
//     model.registeredDate = registeredDate.text;
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
//     // 🔴 FORM VALIDATION
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

//       /// 🔑 GET parentAccountId FROM SECURE STORAGE
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

//       /// 1️⃣ Bind form fields → model
//       bindToModel();

//       /// 2️⃣ 🔥 SET parentAccountId IN MODEL
//       model.parentAccountId = int.parse(parentAccountId);

//       /// 3️⃣ API CALL
//       await TyreService.saveTyre(model);

//       AppLoader.hide();

//       /// 4️⃣ SUCCESS
//       Get.snackbar(
//         "Success",
//         "Tyre submitted successfully",
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       /// 5️⃣ REDIRECT
//       Get.offAll(() => HomeView());
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
// }
