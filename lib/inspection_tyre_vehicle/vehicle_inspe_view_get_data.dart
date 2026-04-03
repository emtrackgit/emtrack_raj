import 'dart:io';
import 'package:emtrack/inspection_tyre_vehicle/inspection_vehicle_tyre_controller.dart';
import 'package:emtrack/inspection_tyre_vehicle/vehicle_inspe_controller2.dart';
import 'package:emtrack/widgets/vehicle_daigram.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../inspection/vehicle_inspe_controller.dart';
import 'package:image_picker/image_picker.dart';

class VehicleInspeViewGetData extends StatelessWidget {
  final InspectionStatus status;
  const VehicleInspeViewGetData({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final VehicleInspeController2 c = Get.put(VehicleInspeController2());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Get Vehicle Inspection Data',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const Text(
              'Vehicle Id',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _inputField(
                onChanged: (val) => c.hours.value = val,
                initialValue: c.hours.value,
              ),
            ),
            const SizedBox(height: 15),

            /// VEHICLE ID
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Hours',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => _inputField(
                          onChanged: (val) => c.vehicleId.value = val,
                          initialValue: c.vehicleId.value,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12), // 👈 spacing

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Old Hours',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => _inputField(
                          onChanged: (val) => c.vehicleId.value = val,
                          initialValue: c.vehicleId.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 21),
            const Text('Vehicle Comments'),
            const SizedBox(height: 8),
            TextField(
              controller: c.commentsCtrl,
              maxLength: 200,
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Comments go here (Max 200 characters)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Old Vehicle Diagram',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            /*Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: VehicleDiagram(),
            ),*/
            SizedBox(height: 20),
            const Text(
              'New Vehicle Diagram',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            /* Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: VehicleDiagram(),
            ),*/
            const SizedBox(height: 20),

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
                  const Text(
                    'Vehicle Diagram',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

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
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// UPLOAD IMAGES
            Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: c.uploadedImages.isEmpty
                          ? const Text(
                              'No Uploaded Images Available Here',
                              style: TextStyle(fontSize: 16),
                            )
                          : SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: c.uploadedImages.length,
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.file(c.uploadedImages[i]),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Approve action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Approve",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ❌ Reject action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Reject",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// SUBMIT
            // Obx(
            //   () => Container(
            //     width: double.infinity,
            //     height: 50,
            //     decoration: BoxDecoration(
            //       color: Colors.red,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: InkWell(
            //       onTap: c.isSubmitting.value ? null : c.submit,
            //       child: c.isSubmitting.value
            //           ? const CircularProgressIndicator(color: Colors.white)
            //           : Center(
            //               child: const Text(
            //                 'Submit',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 10),

            // Center(
            //   child: TextButton(
            //     onPressed: () => Get.back(),
            //     child: const Text(
            //       'Cancel',
            //       style: TextStyle(color: Colors.red),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required Function(String) onChanged,
    String initialValue = '',
  }) {
    return TextField(
      onChanged: onChanged,
      //controller: TextEditingController(text: initialValue),
      controller: TextEditingController(text: "202"),
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
}
