import 'dart:io';
import 'package:emtrack/inspection/update_hours_view.dart';
import 'package:emtrack/views/rotate_tyres_view.dart';
import 'package:emtrack/widgets/vehicle_daigram.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vehicle_inspe_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditVehicleInspectionView extends StatelessWidget {
  const EditVehicleInspectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final VehicleInspeController c = Get.put(VehicleInspeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'spection',
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
                          // onPressed: c.onUpdateHours,
                          onPressed: () {
                            Get.to(() => UpdateHoursView());
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
            const Text(
              'Vehicle ID',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _inputField(
                onChanged: (val) => c.vehicleId.value = val,
                initialValue: c.vehicleId.value,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Hours',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _inputField(
                onChanged: (val) => c.hours.value = val,
                initialValue: c.hours.value,
              ),
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
                Get.to(() => UpdateHoursView());
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
              decoration: InputDecoration(
                hintText: 'Comments go here (Max 200 characters)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // VehicleDiagram(),
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
                              'Upload Images',
                              style: TextStyle(fontSize: 16),
                            )
                          : SizedBox(
                              height: 80,
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

                      onPressed: () => openImagePicker(c),
                      icon: const Icon(Icons.camera_alt, color: Colors.red),
                      label: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                  child: c.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Center(
                          child: const Text(
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
                onPressed: () => Get.back(),
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
    String initialValue = '',
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
}
