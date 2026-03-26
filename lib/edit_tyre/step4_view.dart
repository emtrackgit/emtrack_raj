import 'package:emtrack/edit_tyre/edit_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step4View extends StatelessWidget {
  Step4View({super.key});

  final EditTyreController c = Get.find<EditTyreController>();
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Tire Costs", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 11),

        /// A
        Row(children: [Text("Purchase Cost (a)")]),
        _tf(
          hintText: "0",
          controller: c.purchaseCost,
          focusNode: _focusNode,
          clearIcon: true,
          onChanged: (_) => c.calculateNetCost(),
          // validator: _required,
        ),
        Row(children: [Text("Casing Value (B)")]),

        /// B
        _tf(
          hintText: "0",
          controller: c.casingValue,
          onChanged: (_) => c.calculateNetCost(),
          // validator: _required,
        ),
        Row(children: [Text("Fill Type")]),

        /// Fill Type → DIALOG
        _dropdownTF(
          hintText: "Fill Type",
          controller: c.fillTypeId,
          onTap: () {
            _fillTypeDialog(
              context: context,
              title: "Fill Type",
              list: c.fillTypeList.toList(),
              controller: c.fillTypeId,
              selectedId: c.selectedFillTypeId, // RxInt update
              idList: c.fillTypeIdList.toList(), // corresponding IDs
            );
          },
        ),
        Row(children: [Text("Fill Cost (C)")]),

        /// C
        _tf(
          hintText: "0",
          controller: c.fillCost,
          onChanged: (_) => c.calculateNetCost(),
          //validator: _required,
        ),

        /// Disabled defaults
        Row(children: [Text("Repair Cost")]),
        _tf(
          hintText: "Repair Cost",
          controller: c.repairCost,
          enabled: false,
          //  validator: _required,
        ),
        Row(children: [Text("Repairs Cost (D)")]),
        _tf(
          hintText: "Repairs Cost (D)",
          controller: c.repairCost,
          enabled: false,
          // validator: _required,
        ),
        Row(children: [Text("Number of Retreads")]),
        _tf(
          hintText: "Number of Retreads",
          value: c.numberOfRetreadsVal.value,
          enabled: false,
          // validator: _required,
        ),
        Row(children: [Text("Retread Cost (E)")]),
        _tf(
          hintText: "Retread Cost (E)",
          controller: c.retreadCost,
          enabled: false,
          // validator: _required,
        ),

        /// F
        Row(children: [Text("Warranty Adjustment (F)")]),
        _tf(
          hintText: "Warranty Adjustment (F)",
          controller: c.warrantyAdjustment,
          onChanged: (_) => c.calculateNetCost(),
          //validator: _required,
        ),
        Row(children: [Text("Cost Adjustment (G)")]),

        /// G
        _tf(
          hintText: "Cost Adjustment (G)",
          controller: c.costAdjustment,
          onChanged: (_) => c.calculateNetCost(),
          // validator: _required,
        ),

        /// H
        Row(children: [Text("Sold Amount (H)")]),
        _tf(
          hintText: "Sold Amount (H)",
          controller: c.soldAmount,
          onChanged: (_) => c.calculateNetCost(),
          // validator: _required,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Net Cost"),
            Text(
              "Net Cost = a - b + c + d + e + f - g - h",
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ],
        ),

        /// Net Cost
        _tf(
          hintText: "Net Cost",
          controller: c.netCost,
          enabled: false,
          //validator: _required,
        ),

        const SizedBox(height: 24),

        _primaryBtn("Submit", () async {
          if (c.formKey.currentState!.validate()) {
            await c.updateTyre();
          }
        }),
        const SizedBox(height: 12),

        /*    _outlineBtn("Save & Clone", () {
          Get.snackbar("Saved", "Data saved & ready to clone");
        }),*/
        const SizedBox(height: 12),

        _outlineBtn("Previous", c.previousStep),

        const SizedBox(height: 12),

        _outlineBtn("Cancel", c.cancelDialog),
      ],
    );
  }

  // ================= COMMON TEXTFIELD =================

  Widget _tf({
    required String hintText,

    /// For editable fields
    TextEditingController? controller,

    /// For read-only / backend / calculated values
    dynamic value,

    bool enabled = true,
    bool clearIcon = false,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    // String? Function(String?)? validator,
    Function(String value)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null
            ? value?.toString()
            : null, // 🔥 KEY LINE
        enabled: enabled,
        keyboardType: TextInputType.number,
        //validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          hintText: hintText,
          suffixIcon:
              clearIcon && controller != null && controller.text.isNotEmpty
              ? IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (context, value, _) {
                          if (value.text.trim().isEmpty) {
                            return const SizedBox.shrink(); // 🔥 nothing when empty
                          }

                          return IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              controller.clear();
                              onChanged?.call('');
                              focusNode?.requestFocus();
                            },
                          );
                        },
                      ),

                      Padding(
                        padding: EdgeInsetsGeometry.only(right: 25, left: 10),
                        child: Text(
                          "INR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "INR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: enabled == true && clearIcon == false
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),

          // IconButton(
          //     icon: const Icon(Icons.close),
          //     onPressed: () {
          //       controller.clear();
          //       onChanged?.call('');
          //     },
          //   )
          // : null,
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget _dropdownTF({
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  // ================= FILL TYPE DIALOG =================
  /*
  void _fillTypeDialog({
    required BuildContext context,
    required String title,
    required List<String> list,
    required TextEditingController controller,
  }) {
    String? selectedValue = controller.text.isEmpty ? null : controller.text;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              titlePadding: const EdgeInsets.only(top: 12),
              contentPadding: EdgeInsets.zero,

              /// 🔹 TITLE
              title: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 21),

                  /// 🔹 LIST WITH CHECK
                  SizedBox(
                    height: 220,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final e = list[index];
                        final isSelected = selectedValue == e;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedValue = e;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, color: Colors.red),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  /// 🍏 iOS STYLE ACTIONS
                  SizedBox(
                    height: 48,
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
                                controller.text = selectedValue!;
                              }
                              Navigator.pop(context);
                            },
                            child: const Center(
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
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
  }
*/
  void _fillTypeDialog({
    required BuildContext context,
    required String title,
    required List<String> list,
    required TextEditingController controller,
    RxInt? selectedId, // 🔥 selected ID
    List<int>? idList, // 🔥 corresponding IDs
  }) {
    String? selectedValue = controller.text.isEmpty ? null : controller.text;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              titlePadding: const EdgeInsets.only(top: 12),
              contentPadding: EdgeInsets.zero,

              /// 🔹 TITLE
              title: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 21),

                  /// 🔹 LIST WITH CHECK
                  SizedBox(
                    height: 220,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final e = list[index];
                        final isSelected = selectedValue == e;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedValue = e;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, color: Colors.red),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  /// 🍏 iOS STYLE ACTIONS
                  SizedBox(
                    height: 48,
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
                                controller.text = selectedValue!;

                                // 🔥 Update selectedId for backend/model
                                if (selectedId != null &&
                                    idList != null &&
                                    list.contains(selectedValue)) {
                                  final idx = list.indexOf(selectedValue ?? '');
                                  selectedId.value = idList[idx];
                                  print(
                                    "✅ Selected ID updated => ${selectedId.value}",
                                  );
                                }
                              }
                              Navigator.pop(context);
                            },
                            child: const Center(
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
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
  }

  // ================= BUTTONS =================

  Widget _primaryBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey, // border color
              width: 0, // border width
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "This field is required";
    }

    if (num.tryParse(v) == null) {
      return "Only numeric values are allowed";
    }

    return null;
  }
}
