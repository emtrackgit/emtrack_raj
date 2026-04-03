import 'dart:io';
import 'package:emtrack/inspection/update_hours_view.dart';
import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/views/all_vehicles_list_view.dart';
import 'package:emtrack/widgets/vehicle_daigram.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../views/rotate_tyres_view.dart';

class VehicleInspeView extends StatelessWidget {
  const VehicleInspeView({super.key});
  @override
  Widget build(BuildContext context) {
    final VehicleInspeController c = Get.put(VehicleInspeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Go back to HomeView
            Get.offAllNamed(AppPages.HOME);
            // OR if you just want to pop safely: Get.back(closeOverlays: true);
          },
        ),

        title: const Text(
          'Vehicle Inspection',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HOUR WARNING
            Obx(() {
              if (!c.showHourWarning.value) return const SizedBox();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFD7F2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: c.closeWarning,
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.info, size: 30, color: Colors.red),
                          ],
                        ),

                        const SizedBox(width: 12),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "You haven't updated the Hours",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          //onPressed: c.onUpdateHours,
                          onPressed: () {
                            Get.to(() => UpdateHoursView(), arguments: c.model);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 28),

            /// VEHICLE ID
            Text("Vehicle ID:", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),
            TextField(
              controller: c.vehicleNumberCtrl,
              readOnly: true,
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 24),
            const Text(
              'Hours',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: c.hoursCtrl,
              readOnly: true,
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 32),
            const Text(
              'Update Hours',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.red, // 👉 outline color
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Get.to(
                  () => UpdateHoursView(),
                  arguments: c.model,
                  // 👈 model pass karo
                );
              },
              icon: const Icon(Icons.sync, color: Colors.red),
              label: const Text('Update', style: TextStyle(color: Colors.red)),
            ),

            const SizedBox(height: 20),
            const Text('Vehicle Comments'),
            const SizedBox(height: 8),
            TextField(
              controller: c.commentsCtrl,
              maxLength: 200,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Comments go here (Max 200 characters)',
                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Divider(thickness: 1, height: 32),
            const Text(
              'Vehicle Diagram',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Vehicle No: ${c.vehicleNumberCtrl.text}",
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            /// LEGEND
            Row(
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text('Inspected Tyre'),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Colors.blue, size: 12),
                SizedBox(width: 4),
                Text('Not Inspected Tyre'),
              ],
            ),

            Obx(() {
              final response = c.inspectionResponse.value;

              if (response == null) {
                return const Center(child: Text(""));
              }

              final tires = response.model?.installedTires ?? [];

              return Column(
                children: [
                  /// LEFT RIGHT LABEL
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "L",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "R",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  VehicleDiagram(
                    // tires: tires.obs,
                    tires: c.tires,

                    vehicleId: int.tryParse(c.vehicleId.value) ?? 0,
                    vehicleNumber: c.vehicleNumberCtrl.text,
                  ),
                ],
              );
            }),

            SizedBox(height: 11),

            /// VEHICLE DIAGRAM BOX
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  /// COLOR BAR
                  Row(
                    children: [
                      _colorBox('N/I', Colors.grey.shade300),
                      _colorBox('<25', Colors.greenAccent),
                      _colorBox('<50', Colors.yellow),
                      _colorBox('<75', Colors.orange),
                      _colorBox('>75', Colors.redAccent),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Tread Depth: (To) Outside (Ti) Inside (Tm) Middle\nPressure (P) Tyre Pressure',
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 11),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.red, // 👉 outline color
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => RotateTyresView());
                        },
                        icon: const Icon(Icons.sync, color: Colors.red),
                        label: const Text(
                          'Rotate Tyres',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 11),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// UPLOAD IMAGES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        // c.uploadedImages.isEmpty
                        //     ?
                        const Text(
                          'Upload Images',
                          style: TextStyle(fontSize: 16),
                        ),
                    // : SizedBox(
                    //     height: 80,
                    //     child: ListView.builder(
                    //       scrollDirection: Axis.horizontal,
                    //       itemCount: c.uploadedImages.length,
                    //       itemBuilder: (_, i) => Padding(
                    //         padding: const EdgeInsets.only(right: 8.0),
                    //         child: Image.file(c.uploadedImages[i]),
                    //       ),
                    //     ),
                    //   ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.red, // 👉 outline color
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    onPressed: () {
                      openImagePicker(c);
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.red),
                    label: const Text(
                      'Upload',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Uploaded Images', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            Obx(() {
              if (c.uploadedImages.isEmpty) {
                return const SizedBox(); // 🔥 No height when no image
              }

              return SizedBox(
                height: 160, // height only when images exist
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.uploadedImages.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      clipBehavior:
                          Clip.none, // ⭐ VERY IMPORTANT (allow outside)
                      children: [
                        /// IMAGE CARD
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.white, // ⭐ border color
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              c.uploadedImages[i],
                              width: 200,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        /// DELETE ICON (FLOATING OUTSIDE)
                        Positioned(
                          top: 0, // ⭐ move outside
                          right: -10, // ⭐ move outside
                          child: GestureDetector(
                            onTap: () {
                              c.uploadedImages.removeAt(i);
                              c.update(); // if using GetX ⭐ important
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    //  Stack(
                    //   children: [
                    //     /// IMAGE CARD
                    //     ClipRRect(
                    //       borderRadius: BorderRadius.circular(10),
                    //       child: Image.file(
                    //         c.uploadedImages[i],
                    //         width: 200,
                    //         height: 200,
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),

                    //     /// DELETE ICON
                    //     Positioned(
                    //       top: 5,
                    //       right: 5,
                    //       child: GestureDetector(
                    //         onTap: () {
                    //           c.uploadedImages.removeAt(i);
                    //         },
                    //         child: Container(
                    //           padding: const EdgeInsets.all(4),
                    //           decoration: const BoxDecoration(
                    //             color: Colors.black54,
                    //             shape: BoxShape.circle,
                    //           ),
                    //           child: const Icon(
                    //             Icons.delete,
                    //             size: 16,
                    //             color: Colors.red,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
              );
            }),

            /// SUBMIT
            Obx(
              () => Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: c.isSubmitting.value ? null : c.submit,
                  child: Center(
                    child: c.isSubmitting.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () {
                  showConfirmDialog(
                    title: "Cancel Request",
                    message:
                        "Are you sure you want to cancel? we wiil loose unsave data.",

                    onOk: () {
                      Get.back(closeOverlays: true);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Get.back();
                        //      Get.off(() => AllVehicleListView());
                      });
                      // Get.off(() => AllVehicleListView(), arguments: c.vehicleId);
                    },
                  );
                },

                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required Function(String) onChanged,
    String? initialValue,
  }) {
    return TextField(
      onChanged: onChanged,
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static Widget _colorBox(String text, Color color) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: color,
        child: Text(text),
      ),
    );
  }

  // IMAGE PICKER

  static void openImagePicker(VehicleInspeController c) {
    // 📱 Only Android / iOS
    if (!Platform.isAndroid && !Platform.isIOS) return;

    Get.bottomSheet(
      backgroundColor: Colors.white,
      Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              title: const Center(child: Text('Take Photo')),
              onTap: () {
                Get.back();
                c.pickImageMobile(ImageSource.camera);
              },
            ),
            ListTile(
              title: const Center(child: Text('Choose from Gallery')),
              onTap: () {
                Get.back();
                c.pickImageMobile(ImageSource.gallery);
              },
            ),
            ListTile(
              title: const Center(child: Text('Cancel')),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F3F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  void showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onOk,
  }) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "No",
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              onOk();
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
