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
                hintText: 'Comments go here (Max 200 characters)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Diagram',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tire Serial Number',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      SizedBox(width: 4),
                      Text('Inspected Tire'),
                      SizedBox(width: 12),
                      Icon(Icons.circle, color: Colors.blue, size: 12),
                      SizedBox(width: 4),
                      Text('Not Inspected Tire'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'L',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'R',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final response = c.inspectionResponse.value;
                    if (response == null) {
                      return const SizedBox.shrink();
                    }
                    return VehicleDiagram(
                      tires: c.tires,
                      vehicleId: int.tryParse(c.vehicleId.value) ?? 0,
                      vehicleNumber: c.vehicleNumberCtrl.text,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Get.to(
                      () => RotateTyresView(),
                      arguments: {
                        "vehicleId": int.tryParse(c.vehicleId.value) ?? 0,
                        "vehicleNumber": c.vehicleNumberCtrl.text,
                        "tires": c.tires.toList(),
                      },
                    );
                  },
                  icon: const Icon(Icons.sync, color: Colors.red),
                  label: const Text(
                    'Rotate Tires',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// UPLOAD IMAGES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Upload Images',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    onPressed: () {
                      openImagePicker(c);
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    label: const Text(
                      'Upload',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Text('Uploaded Images', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),

            const SizedBox(height: 12),

            Obx(() {
              if (c.uploadedImages.isEmpty) {
                return const SizedBox(); // 🔥 No height when no image
              }

              return SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.uploadedImages.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 230,
                          height: 170,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              c.uploadedImages[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(
                          top: -8,
                          right: -8,
                          child: InkWell(
                            onTap: () {
                              c.uploadedImages.removeAt(i);
                              c.update();
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete, color: Colors.white, size: 18),
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
                  color: Colors.blue,
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
                        "Are you sure you want to cancel? You will lose unsaved data.",

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
                  style: TextStyle(color: Colors.blue),
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
