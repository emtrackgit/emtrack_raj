// import 'package:emtrack/color/app_color.dart';
// import 'package:emtrack/controllers/update_hours_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class UpdateHoursView extends StatelessWidget {
//   UpdateHoursView({super.key});
//   final updatectrl = Get.put(UpdateHoursController());
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: const Text(
//           "Update Hours",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             _label("Selected parent account"),
//             Text(
//               updatectrl.model!.parentAccount,
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 20),
//             _label("Vehicle ID"),
//             Text(
//               updatectrl.model!.vehicleId,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 24),

//             _label("Last Recorded Date"),
//             SizedBox(height: 10),
//             _disabledField(),

//             const SizedBox(height: 20),

//             _requiredLabel("Survey Date"),
//             SizedBox(height: 10),
//             GestureDetector(
//               onTap: () => updatectrl.pickSurveyDate(context),
//               child: AbsorbPointer(
//                 child: TextField(
//                   controller: updatectrl.surveyDateController,
//                   decoration: InputDecoration(
//                     hintText: "Select Date",
//                     suffixIcon: Icon(Icons.calendar_month, color: Colors.red),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(
//                         color: Colors.grey.shade50,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             _label("Last Recorded Hours"),
//             SizedBox(height: 10),
//             _disabledField(),

//             const SizedBox(height: 20),

//             _requiredLabel("Update hours"),
//             SizedBox(height: 10),
//             TextField(
//               controller: updatectrl.updateHoursController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Enter Hours",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: Colors.grey.shade50, width: 1),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             Obx(
//               () => Container(
//                 width: double.infinity,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.buttonDanger,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: InkWell(
//                   onTap: updatectrl.loading.value ? null : updatectrl.submit,
//                   child: updatectrl.loading.value
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Center(
//                           child: const Text(
//                             "Update",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             Center(
//               child: GestureDetector(
//                 onTap: () => Get.back(),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) =>
//       Text(text, style: const TextStyle(color: Colors.black54));

//   Widget _requiredLabel(String text) => RichText(
//     text: TextSpan(
//       text: text,
//       style: const TextStyle(color: Colors.black),
//       children: const [
//         TextSpan(
//           text: " *",
//           style: TextStyle(color: Colors.red),
//         ),
//       ],
//     ),
//   );

//   Widget _disabledField() => Container(
//     height: 48,
//     decoration: BoxDecoration(
//       color: Colors.grey.shade200,
//       borderRadius: BorderRadius.circular(6),
//     ),
//   );
// }
