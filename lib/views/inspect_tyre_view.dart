import 'dart:io';
import 'package:emtrack/controllers/inspect_tyre_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class InspectTyreView extends StatelessWidget {
  InspectTyreView({super.key});

  final controller = Get.put(InspectTyreController());
  final selectedCtrl = Get.put(SelectedAccountController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "Inspect Tire",
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final m = controller.model.value;
            final t = controller.tyre.value;
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
                    children: [
                      const Text(
                        "Selected Parent Account and Location:",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${selectedCtrl.parentAccountName.value} - ${selectedCtrl.locationName.value}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Divider(),
                      const Text(
                        "Vehicle ID:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(m.vehicleId.toString() ?? '-'),
                      const Divider(),
                      const Text(
                        "Tire Serial Number:",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        m.tireSerialNo ?? '-',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const Text(
                        "Wheel Position:",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        m.wheelPosition ?? '-',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const Text(
                        "Last Inspection:",
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        "06/2/2018",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Outside Tread Depth
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
                // 🔹 Average Tread (Readonly)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Average Tread"),
                    SizedBox(height: 6),
                    Container(
                      height: 48,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        m.currentTreadDepth?.toString() ?? '0',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 11),
                _counter(
                  "Air Pressure",
                  "${m.airPressure} PSI",
                  controller.decAir,
                  controller.incAir,
                ),

                const SizedBox(height: 16),
                searchDropdownDialog(
                  hintText: "Wear Condition",
                  controller: controller.wearConditionsId,
                  list: controller.wearConditionsList,
                  context: context,
                  //validator: _required,
                  selectedId:
                      controller.selectedWearConditionsId, // 🔥 RxInt update
                  idList: controller.wearConditionsIdList.toList(),
                ),
                searchDropdownDialog(
                  hintText: "Casing Condition",
                  controller: controller.casingConditionsId,
                  list: controller.casingConditionList,
                  context: context,
                  //validator: _required,
                  selectedId:
                      controller.selectedCasingConditionId, // 🔥 RxInt update
                  idList: controller.casingConditionIdList.toList(),
                ),

                // _dropdown("Wear Condition", m.wearConditionId.toString()),

                //const SizedBox(height: 12),

                //  _dropdown("Casing Condition", m.casingConditionId.toString()),
                const SizedBox(height: 12),

                _textBox(
                  "List Of Previous Comments",
                  m.comments,
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
                  "Comments",
                  m.comments,
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

                _actionCard("Remove Tire", "Remove", Icons.delete, () {
                  Get.toNamed(
                    '/remove-tyre',
                    arguments: {
                      "vehicleId": m.vehicleId,
                      "tireId": m.tireId,
                      "wheelPosition": m.wheelPosition,
                      "tireSerialNo": m.tireSerialNo,
                      "currentHours": m.currentHours,
                      "currentMiles": m.currentMiles,
                      "outsideTread": m.outsideTread,
                      "insideTread": m.insideTread,
                      "currentTreadDepth": m.currentTreadDepth,
                      "currentPressure": m.airPressure,
                    },
                  );
                }),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ⭐ MOST IMPORTANT
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: controller.submit,
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Get.back(); // cancel action
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
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

  Widget searchDropdownDialog({
    required String hintText,
    required TextEditingController controller,
    required List<String> list,
    required BuildContext context,
    RxInt? selectedId, // 🔥 Pass RxInt to update
    List<int>? idList, // 🔥 Corresponding IDs for each item
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GetBuilder<InspectTyreController>(
        builder: (c) {
          return TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
            ),
            onTap: () {
              // c.checkStarEnable();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  List<String> filteredList = List.from(list);
                  TextEditingController searchController =
                      TextEditingController();
                  String? selectedValue = controller.text.isEmpty
                      ? null
                      : controller.text;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Scaffold(
                        appBar: AppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          title: Text("Select $hintText"),
                          elevation: 1,
                        ),
                        body: Column(
                          children: [
                            /// 🔍 SEARCH
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    filteredList = value.isEmpty
                                        ? List.from(list)
                                        : list
                                              .where(
                                                (item) =>
                                                    item.toLowerCase().contains(
                                                      value.toLowerCase(),
                                                    ),
                                              )
                                              .toList();
                                  });
                                },
                              ),
                            ),

                            /// 📜 LIST
                            Expanded(
                              child: filteredList.isEmpty
                                  ? const Center(child: Text("No data found"))
                                  : ListView.separated(
                                      itemCount: filteredList.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final item = filteredList[index];
                                        final isSelected =
                                            selectedValue == item;

                                        return ListTile(
                                          title: Text(
                                            item,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                          trailing: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.red,
                                                )
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              selectedValue = item;
                                            });
                                          },
                                        );
                                      },
                                    ),
                            ),

                            /// 🔹 BOTTOM ACTIONS
                            Container(
                              height: 56,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: Row(
                                children: [
                                  /// ❌ CANCEL
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: const Center(
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(width: 0.5, color: Colors.grey),

                                  /// ✅ OK
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (selectedValue != null) {
                                          final index = list.indexOf(
                                            selectedValue!,
                                          );
                                          controller.text = selectedValue!;

                                          // ✅ Update selectedId correctly
                                          if (selectedId != null &&
                                              idList != null &&
                                              index >= 0 &&
                                              index < idList.length) {
                                            selectedId.value = idList[index];
                                          }
                                        }
                                        Navigator.pop(context);
                                      },

                                      child: const Center(
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
