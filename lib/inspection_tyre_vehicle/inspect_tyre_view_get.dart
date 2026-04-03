import 'dart:io';
import 'package:emtrack/inspection_tyre_vehicle/inspect_tyre_controller2.dart';
import 'package:emtrack/inspection_tyre_vehicle/inspection_vehicle_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class InspectTyreViewGetData extends StatelessWidget {
  final InspectionStatus status;
  InspectTyreViewGetData({super.key, required this.status});

  final InspectTyreController2 controller = Get.put(InspectTyreController2());
  final InspectionVehicleTyreController c = Get.put(
    InspectionVehicleTyreController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "Get Inspect Tire Data",
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final m = controller.model.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 INFO CARD (Screenshot 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 253),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Selected Parent Account and Location:",
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Daves Test-Daves Test",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Divider(),
                      Text(
                        "Vehicle ID:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("58069"),
                      Divider(),
                      Text(
                        "Tire Serial Number:",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "0316NJ3475",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      Text("Wheel Position:", style: TextStyle(fontSize: 12)),
                      Text("2R", style: TextStyle(fontWeight: FontWeight.bold)),
                      Divider(),
                      Text("Last Inspection:", style: TextStyle(fontSize: 12)),
                      Text(
                        "18/12/2025",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Outside Tread Depth
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Old Data of Outside & Inside Tread Depth",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      _counter32(
                        title: "Outside Tread Depth",
                        value: "${m.outsideTread} /32nds",
                        onMinus: controller.decOutside,
                        onPlus: controller.incOutside,
                      ),
                      const SizedBox(height: 16),
                      // 🔹 Inside Tread Depth
                      _counter32(
                        title: "Inside Tread Depth",
                        value: "${m.insideTread} /32nds",
                        onMinus: controller.decInside,
                        onPlus: controller.incInside,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // 🔹 Outside Tread Depth
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New Data of Outside & Inside Tread Depth",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      _counter32(
                        title: "Outside Tread Depth",
                        value: "${m.outsideTread} /32nds",
                        onMinus: controller.decOutside,
                        onPlus: controller.incOutside,
                      ),
                      const SizedBox(height: 16),
                      // 🔹 Inside Tread Depth
                      _counter32(
                        title: "Inside Tread Depth",
                        value: "${m.insideTread} /32nds",
                        onMinus: controller.decInside,
                        onPlus: controller.incInside,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // 🔹 Average Tread (Readonly)
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Text("Average Tread"),
                //     const SizedBox(height: 6),
                //     Container(
                //       height: 48,
                //       width: double.infinity,
                //       padding: const EdgeInsets.symmetric(horizontal: 12),
                //       alignment: Alignment.centerLeft,
                //       decoration: BoxDecoration(
                //         color: const Color(0xffF5F5F5),
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Text(
                //         m.averageTread,
                //         style: const TextStyle(fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 11),
                Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      Row(children: [Text("Air Pressure Type: ")]),
                      Row(
                        children: [
                          Switch(
                            value: controller.isHot.value,
                            onChanged: (val) {
                              controller.isHot.value = val;
                            },
                          ),
                          const SizedBox(width: 38),
                          Text(
                            controller.isHot.value ? "Hot 🔥" : "Cold ❄️",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: controller.isHot.value
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _counter(
                  "Old Air Pressure",
                  "${m.airPressure} PSI",
                  controller.decAir,
                  controller.incAir,
                ),
                const SizedBox(height: 12),
                _counter(
                  "New Air Pressure",
                  "${m.airPressure} PSI",
                  controller.decAir,
                  controller.incAir,
                ),

                const SizedBox(height: 16),

                _dropdown("Old Wear Condition", m.wearConditionId.toString()),
                const SizedBox(height: 12),
                _dropdown(" New Wear Condition", m.wearConditionId.toString()),
                const SizedBox(height: 12),

                _dropdown(
                  "Old Casing Condition",
                  m.casingConditionId.toString(),
                ),

                const SizedBox(height: 12),
                _dropdown(
                  "New Casing Condition",
                  m.casingConditionId.toString(),
                ),

                const SizedBox(height: 12),

                _textBox(
                  "Old List Of Previous Comments",
                  "test21",
                  enabled: false,
                ),
                const SizedBox(height: 12),
                _textBox(
                  "New List Of Previous Comments",
                  "test21",
                  enabled: false,
                ),

                const SizedBox(height: 12),

                Row(
                  children: const [
                    Radio(value: true, groupValue: true, onChanged: null),
                    Text("Still Relevant"),
                  ],
                ),

                const SizedBox(height: 12),

                _textBox(
                  " Comments",
                  "test31",
                  onChanged: (v) =>
                      controller.model.update((m) => m!.comments = v),
                ),

                const SizedBox(height: 16),

                _actionCard(
                  "Upload Images",
                  "Upload",
                  Icons.camera_alt,
                  () => controller.pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: m.images
                      .map(
                        (e) => Image.file(
                          File(e),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 12),
                _actionCard(
                  "Remove Tire",
                  "Remove",
                  Icons.delete,
                  controller.removeTyre,
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    /// ✅ APPROVE BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: status == InspectionStatus.approved
                            ? null // ❌ disable
                            : () {
                                // ❌ Approved action
                                // call reject API
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == InspectionStatus.approved
                              ? Colors
                                    .grey // disabled color
                              : Colors.green,
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

                    /// ❌ REJECT BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: status == InspectionStatus.rejected
                            ? null // ❌ disable
                            : () {
                                // ❌ Reject action
                                // call reject API
                              },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == InspectionStatus.rejected
                              ? Colors
                                    .grey // disabled color
                              : Colors.red,
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

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ⭐ MOST IMPORTANT
                    children: [
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width - 32,
                      //   height: 54,
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.red,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(14),
                      //       ),
                      //     ),
                      //     onPressed: controller.submit,
                      //     child: const Text(
                      //       "Submit",
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                      //const SizedBox(height: 10),
                      // TextButton(
                      //   onPressed: () {
                      //     Get.back(); // cancel action
                      //   },
                      //   child: const Text(
                      //     "Cancel",
                      //     style: TextStyle(color: Colors.red),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 🔹 Widgets
  Widget _counter(
    String title,
    String value,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 6),
        Row(
          children: [
            _redBtn("-", minus),
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(value),
              ),
            ),
            _redBtn("+", plus),
          ],
        ),
      ],
    );
  }

  Widget _counter32({
    required String title,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 6),
        Row(
          children: [
            _redBtn("-", onMinus),
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(value),
              ),
            ),
            _redBtn("+", onPlus),
          ],
        ),
      ],
    );
  }

  Widget _redBtn(String t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 44,
        color: Colors.red,
        alignment: Alignment.center,
        child: Text(
          t,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, size: 18),
              SizedBox(width: 8),
              Text("CLEAN"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _textBox(
    String label,
    String value, {
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          maxLines: 3,
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _actionCard(
    String title,
    String btn,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.red),
            label: Text(btn),
          ),
        ],
      ),
    );
  }
}
