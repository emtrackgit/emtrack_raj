import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/all_tyre_controller.dart';
import 'create_tyre_controller.dart';

class Step1View extends StatefulWidget {
  const Step1View({super.key});

  @override
  State<Step1View> createState() => _Step1ViewState();
}

class _Step1ViewState extends State<Step1View> {
  late final CreateTyreController c;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    c = Get.find<CreateTyreController>();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _month(int m) => const [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ][m - 1];

  String _weekday(int d) =>
      const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][d - 1];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Column(
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
              const SizedBox(height: 10),

              // ── Tire Serial Number ──
              Row(children: [
                const Text("Tire Serial Number "),
                const Text("*", style: TextStyle(color: Colors.red)),
              ]),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    controller: c.tireSerialNo,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Enter Tire Serial Number",
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      errorText: c.tireSerialNoError.value.isNotEmpty
                          ? c.tireSerialNoError.value
                          : null,
                      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "TIRE Serial Number is required.";
                      }
                      return null;
                    },
                    onChanged: (v) {
                      c.tireSerialNoError.value = '';
                      if (v.trim().isNotEmpty && Get.isRegistered<AllTyreController>()) {
                        final allTyres = Get.find<AllTyreController>().allTyres;
                        final isDuplicate = allTyres.any(
                          (t) => t.tireSerialNo?.toLowerCase() == v.trim().toLowerCase(),
                        );
                        if (isDuplicate) {
                          c.tireSerialNoError.value = "This serial number already exists";
                        }
                      }
                    },
                  ),
                ),
              ),

              // ── Brand Number ──
              const Row(children: [Text("Enter Brand Number ")]),
              _tf(label: "Enter Brand No.", controller: c.brandNo),

              // ── Register Date ──
              Row(children: [
                const Text("Register Date "),
                const Text("*", style: TextStyle(color: Colors.red)),
              ]),
              _tf(
                label: "Registered Date",
                controller: c.registeredDate,
                onTap: () => pickDate(context),
              ),

              // ── Evaluation Number ──
              const Row(children: [Text("Evaluation Number ")]),
              _tf(label: "Enter Evaluation Number", controller: c.evaluationNo),

              // ── Lot Number ──
              const Row(children: [Text("Lot Number ")]),
              _tf(label: "Enter Lot Number", controller: c.lotNo),

              // ── PO Number ──
              const Row(children: [Text("Purchase Order Number")]),
              _tf(label: "Enter Purchase Order Number", controller: c.poNo),

              // ── Disposition ──
              Row(children: [
                const Text("Disposition "),
                const Text("*", style: TextStyle(color: Colors.red)),
              ]),
              _tf(
                label: "Enter Disposition",
                value: c.dispositionText.value,
                enabled: false,
              ),

              // ── Status ──
              const Row(children: [Text("Status ")]),
              _dropdownTFStatus(
                label: "Status",
                value: c.selectedstatus.value,
                items: c.statusList,
              ),

              // ── Tracking Method ──
              const Row(children: [Text("Tracking Method ")]),
              _dropdownTF(
                label: "Tracking Method",
                value: c.trackingMethodText.value,
                items: ["Hours", "Distance", "Both"],
              ),

              // ── Current Hours ──
              Row(children: [
                const Text("Current Hours "),
                const Text("*", style: TextStyle(color: Colors.red)),
              ]),

              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: c.currentHours,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,

                  inputFormatters: [
                    CurrentHoursInputFormatter(decimalRange: 2),
                  ],

                  // ✅ Validator
                  validator: (_) {
                    final text = c.currentHours.text.trim();

                    // Empty check
                    if (text.isEmpty) {
                      return "ENTER valid current hours.";
                    }

                    // Numeric check
                    final parsed = double.tryParse(text);
                    if (parsed == null) {
                      return "ENTER a valid whole number.";
                    }

                    // Negative check
                    if (parsed < 0) {
                      return "CURRENT hours cannot be negative.";
                    }

                    if (text.contains('.')) {
                      return "Enter valid details.";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Enter Current Hours",
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: c.currentHours,
                      builder: (context, value, _) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            c.currentHours.clear();
                            _focusNode.requestFocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _primaryBtn("Next", () => c.nextStep()),
              const SizedBox(height: 12),
              _outlineBtn("Cancel", c.cancelDialog),
            ],
          ),

          if (c.isPageLoading.value)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────
  // COMMON WIDGETS
  // ─────────────────────────────────────────────

  Widget _tf({
    required String label,
    TextEditingController? controller,
    dynamic value,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool showClear = false,
    VoidCallback? onClear,
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
        focusNode: focusNode,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: label,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          suffixIcon: showClear
              ? ValueListenableBuilder<TextEditingValue>(
            valueListenable: effectiveController,
            builder: (context, val, _) {
              if (val.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (onClear != null) {
                    onClear();
                  } else {
                    effectiveController.clear();
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

  // ─────────────────────────────────────────────
  // DATE PICKER
  // ─────────────────────────────────────────────

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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                          setState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              c.registeredDate.text = '';
                              c.registeredDateApi = null;
                              Get.back();
                            },
                            child: const Text("CLEAR",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("CANCEL",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () {
                                  c.registeredDate.text =
                                  "${selectedDate.day.toString().padLeft(2, '0')}/"
                                      "${selectedDate.month.toString().padLeft(2, '0')}/"
                                      "${selectedDate.year}";
                                  c.registeredDateApi =
                                      selectedDate.toUtc().toIso8601String();
                                  Get.back();
                                },
                                child: const Text("SET",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
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

  // ─────────────────────────────────────────────
  // DROPDOWNS
  // ─────────────────────────────────────────────

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
          final selected = await _showSelectionDialog(
            selectedValue: c.selectedTrackingMethod,
            label: label,
            items: items,
          );
          if (selected != null) {
            effectiveController.text = selected;
            c.selectedTrackingMethod.value = selected;
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

  Widget _dropdownTFStatus({
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
          final selected = await _showSelectionDialog(
            selectedValue: c.selectedstatus,
            label: label,
            items: items,
          );
          if (selected != null) {
            c.selectedstatus.value = selected;
            effectiveController.text = selected;
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

  Future<String?> _showSelectionDialog({
    required String label,
    required List<String> items,
    required RxString selectedValue,
    Color selectedColor = Colors.red,
  }) async {
    String tempSelected = selectedValue.value;

    return await Get.dialog<String>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: double.maxFinite,
              height: 260,
              child: Column(
                children: [
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final e = items[index];
                        final isSelected = e == tempSelected;
                        return InkWell(
                          onTap: () => setState(() => tempSelected = e),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(e,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? selectedColor
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      )),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      color: selectedColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 16)),
                          ),
                        ),
                      ),
                      Container(width: 0.5, height: 48, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedValue.value = tempSelected;
                            Get.back(result: tempSelected);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text('OK',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red)),
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

  // ─────────────────────────────────────────────
  // BUTTONS
  // ─────────────────────────────────────────────

  Widget _primaryBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
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
              borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.grey),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class CurrentHoursInputFormatter extends TextInputFormatter {
  final int decimalRange;

  CurrentHoursInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (text.startsWith('.')) return oldValue;

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      if (!isDigit && ch != '.') return oldValue;
    }

    final dotIndex = text.indexOf('.');
    if (dotIndex != -1) {
      if (text.indexOf('.', dotIndex + 1) != -1) return oldValue;
      final decimals = text.length - dotIndex - 1;
      if (decimals > decimalRange) return oldValue;
    }

    return newValue;
  }
}
