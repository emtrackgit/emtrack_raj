import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'edit_tyre_controller.dart';

class Step1View extends StatelessWidget {
  Step1View({super.key});

  final EditTyreController c = Get.find<EditTyreController>();
  String _month(int m) => const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ][m - 1];

  String _weekday(int d) =>
      const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][d - 1];

  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Text(
            "Identification Details",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text("Tire Serial Number "),
              Text("*", style: TextStyle(color: Colors.red)),
            ],
          ),
          _tf(
            label: "Enter Tire Serial Number",
            controller: c.tireSerialNo,
            //validator: (v) => validateField(v, numeric: true),
          ),
          Row(children: [Text("Enter Brand Number ")]),
          _tf(
            label: "Enter Brand No.",
            controller: c.brandNo,
            // validator: (v) => validateField(v),
          ),

          Row(
            children: [
              Text("Register Date "),
              Text("*", style: TextStyle(color: Colors.red)),
            ],
          ),
          _tf(
            label: "Registered Date",
            controller: c.registeredDate,
            //validator: (v) => validateField(v),
            onTap: () => pickDate(context),
          ),

          Row(children: [Text("Evaluation Number ")]),
          _tf(
            label: "Enter Evaluation Number",
            controller: c.evaluationNo,
            // validator: (v) => validateField(v),
          ),
          Row(children: [Text("Lot Number ")]),
          _tf(
            label: "Enter Lot Number",
            controller: c.lotNo,
            //validator: (v) => validateField(v),
          ),
          Row(children: [Text("Purchase Order Number")]),
          _tf(
            label: "Enter Purchase Order Number",
            controller: c.poNo,
            // validator: (v) => validateField(v),
          ),
          Row(
            children: [
              Text("Disposition "),
              Text("*", style: TextStyle(color: Colors.red)),
            ],
          ),
          _tf(
            label: "Enter Disposition",
            value: c.dispositionText.value,
            enabled: false,
            //validator: (v) => validateField(v),
          ),
          Row(
            children: const [
              Text("Status ", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          /*  _dropdownTFStatus(
            label: "Status",
            items: c.statusList.toList(), // list of names
            ids: c.statusIdList.toList(), // list of IDs
            controller: c.tireStatusId, // optional, TextEditingController
          ),*/
          _dropdownTFStatus(
            label: "Tire Status",
            controller: c.tireStatusId, // TextEditingController for UI
            items: c.statusList, // Display names
            ids: c.statusIdList.toList(), // Corresponding IDs
          ),

          Row(children: [Text("Tracking Method ")]),
          _dropdownTF(
            label: "Tracking Method",
            value: c.trackingMethodText.value,
            items: ["Hours", "Distance", "Both"],
          ),
          Row(
            children: [
              Text("Current Hours "),
              Text("*", style: TextStyle(color: Colors.red)),
            ],
          ),
          _tf(
            label: "Enter Current Hours",
            controller: c.currentHours,
            keyboard: TextInputType.number,
            focusNode: _focusNode,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,1}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter Valid Details";
              }

              if (!RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(value)) {
                return "Enter valid number";
              }

              return null;
            },
            showClear: true,
          ),

          //validator: (v) => validateField(v),
          const SizedBox(height: 24),

          _primaryBtn("Next", () => c.nextStep()),
          const SizedBox(height: 12),
          _outlineBtn("Cancel", c.cancelDialog),
        ],
      ),
    );
  }

  // ================= COMMON WIDGETS =================

  Widget _tf({
    required String label,
    TextEditingController? controller,
    dynamic value,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    // String? Function(String?)? validator,
    FocusNode? focusNode,
    VoidCallback? onTap,

    bool showClear = false, // ✅ NEW (optional)
    VoidCallback? onClear, // ✅ optional custom clear action
  }) {
    final TextEditingController effectiveController =
        controller ?? TextEditingController(text: value?.toString() ?? "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: effectiveController,
        enabled: enabled,
        readOnly: onTap != null,
        onTap: onTap,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboard,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          hintText: label,

          /// ❌ OPTIONAL CLOSE ICON
          suffixIcon: showClear
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: effectiveController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (onClear != null) {
                          onClear(); // custom clear
                        } else {
                          effectiveController.clear(); // default clear
                        }
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                    );
                  },
                )
              : null,
        ),
      ),
    );
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔴 TOP HEADER (NOW REACTIVE)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${selectedDate.year}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${_weekday(selectedDate.weekday)}, "
                            "${selectedDate.day} "
                            "${_month(selectedDate.month)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 📅 CALENDAR
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    /// 🔘 ACTION BUTTONS
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// CLEAR
                          TextButton(
                            onPressed: () {
                              c.registeredDate.text = '';
                              c.registeredDateApi = null;
                              Get.back();
                            },
                            child: const Text(
                              "CLEAR",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              /// CANCEL
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  "CANCEL",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              /// SET
                              TextButton(
                                onPressed: () {
                                  /// UI VALUE
                                  c.registeredDate.text =
                                      "${selectedDate.day.toString().padLeft(2, '0')}/"
                                      "${selectedDate.month.toString().padLeft(2, '0')}/"
                                      "${selectedDate.year}";

                                  /// API VALUE (IMPORTANT 🔥)
                                  c.registeredDateApi = selectedDate
                                      .toUtc()
                                      .toIso8601String();

                                  Get.back();
                                },
                                child: const Text(
                                  "SET",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdownTF({
    required String label,
    TextEditingController? controller,
    dynamic value,
    required List<String> items,
  }) {
    final TextEditingController effectiveController =
        controller ?? TextEditingController(text: value?.toString() ?? "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () async {
          final selected = await _showTrackingSelectionDialog(
            selectedValue: c.selectedTrackingMethod,
            label: label,
            items: items,
          );
          if (selected != null) {
            effectiveController.text = selected;
            c.selectedTrackingMethod.value = selected.toString();
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: effectiveController,
            readOnly: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: label,
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showTrackingSelectionDialog({
    required String label,
    required List<String> items,
    required RxString selectedValue, // use RxString for reactive selection
    Color selectedColor = Colors.red, // existing design color
  }) async {
    // Local tempSelected to show check immediately in dialog
    String tempSelected = selectedValue.value;

    return await Get.dialog<String>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ), // design same
            title: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: double.maxFinite,
              height: 260,
              child: Column(
                children: [
                  const Divider(height: 1),

                  /// LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final e = items[index];
                        final isSelected = e == tempSelected;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              tempSelected =
                                  e; // selected item show immediately
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? selectedColor
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: selectedColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 0.5, height: 48, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedValue.value =
                                tempSelected; // persist selection in controller
                            Get.back(result: tempSelected); // return value
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _dropdownTF({
  //   required String label,
  //   TextEditingController? controller,
  //   dynamic value,
  //   required List<String> items,
  // }) {
  //   final TextEditingController effectiveController =
  //       controller ?? TextEditingController(text: value?.toString() ?? "");

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 14),
  //     child: GestureDetector(
  //       onTap: () async {
  //         final selected = await _showSelectionDialog(
  //           textController: effectiveController,
  //           selectedValue: c.selectedTrackingMethod,
  //           label: label,
  //           items: items,
  //         );
  //         if (selected != null) {
  //           effectiveController.text = selected;
  //         }
  //       },
  //       child: AbsorbPointer(
  //         child: TextFormField(
  //           controller: effectiveController,
  //           readOnly: true,
  //           decoration: InputDecoration(
  //             border: const OutlineInputBorder(),
  //             hintText: label,
  //             suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.red),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /*
  Widget _dropdownTFStatus({
    required String label,
    TextEditingController? controller,
    required List<String> items,
    required List<int> ids,
  }) {
    return GetBuilder<EditTyreController>(
      builder: (c) {
        final effectiveController = controller ?? TextEditingController();

        // Initialize TextField from DB
        if (c.selectedstatus.value != 0 && effectiveController.text.isEmpty) {
          final index = ids.indexOf(c.selectedstatus.value);
          if (index != -1) {
            effectiveController.text = items[index];
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () async {
              await _showSelectionDialog(
                label: label,
                items: items,
                ids: ids,
                selectedId: c.selectedstatus,
                textController: effectiveController,
              );
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: effectiveController,
                readOnly: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: label,
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }*/
  Widget _dropdownTFStatus({
    required String label,
    TextEditingController? controller,
    required List<String> items,
    required List<int> ids,
  }) {
    return GetBuilder<EditTyreController>(
      builder: (c) {
        final effectiveController = controller ?? TextEditingController();

        // Initialize TextField from DB if not empty
        if (c.selectedstatus.value != 0 && effectiveController.text.isEmpty) {
          final index = ids.indexOf(c.selectedstatus.value);
          if (index != -1) {
            effectiveController.text = items[index];
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () async {
              await _showSelectionDialog(
                label: label,
                items: items,
                ids: ids,
                selectedId: c.selectedstatus,
                textController: effectiveController,
              );

              // 🔥 On selection, automatically update TextField text and RxInt ID
              final selectedIndex = ids.indexOf(c.selectedstatus.value);
              if (selectedIndex != -1) {
                effectiveController.text = items[selectedIndex];
              } else {
                effectiveController.clear();
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: effectiveController,
                readOnly: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: label,
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSelectionDialog({
    required String label,
    required List<String> items, // names
    required List<int> ids, // IDs
    required RxInt selectedId, // reactive selected status ID
    required TextEditingController textController, // TextField controller
    Color selectedColor = Colors.red,
  }) async {
    int tempSelected = selectedId.value; // DB value initialize

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: double.maxFinite,
              height: 260,
              child: Column(
                children: [
                  const Divider(height: 1),

                  // List of items
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final isSelected = ids[index] == tempSelected;

                        return InkWell(
                          onTap: () => setState(() {
                            tempSelected = ids[index]; // update selected
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    items[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? selectedColor
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: selectedColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 0.5, height: 48, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedId.value = tempSelected; // save selected ID
                            textController.text =
                                items[ids.indexOf(tempSelected)]; // show name
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _primaryBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _outlineBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Colors.grey),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String? validateField(
    String? value, {
    bool required = true,
    bool numeric = false,
    double? min,
    double? max,
  }) {
    /// REQUIRED CHECK
    if (required && (value == null || value.trim().isEmpty)) {
      return "This field is required";
    }

    if (value == null || value.trim().isEmpty) {
      return null; // not required
    }

    /// NUMERIC CHECK
    if (numeric) {
      final num? number = num.tryParse(value);
      if (number == null) {
        return "Enter a numeric number";
      }
    }

    return null;
  }

  String getStatusNameFromId(int? id) {
    if (id == null) return "";

    if (c.statusIdList.isEmpty || c.statusList.isEmpty) return "";

    final index = c.statusIdList.indexOf(id);

    if (index == -1 || index >= c.statusList.length) return "";

    return c.statusList[index];
  }
}
