import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Step3View extends StatefulWidget {
  const Step3View({super.key});

  @override
  State<Step3View> createState() => _Step3ViewState();
}

class _Step3ViewState extends State<Step3View> {
  final CreateTyreController c = Get.find<CreateTyreController>();

  double? outsidePercen;
  double? insidePercent;

  bool outsideWarn = false;
  bool insideWarn = false;

  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _calculate();
  }

  // ================= CALCULATION =================

  void _calculate() {
    final original = double.tryParse(c.originalTread.text);
    final removeAt = double.tryParse(c.removeAt.text);
    final outside = double.tryParse(c.outsideTread.text);
    final inside = double.tryParse(c.insideTread.text);

    if (original == null || removeAt == null) return;
    if (removeAt <= 0) return;
    if (original <= removeAt) return;

    double denominator = (original - removeAt);
    if (denominator == 0) return;

    setState(() {
      if (c.outsideTread.text.trim().isEmpty) {
        outsidePercen = null;
        outsideWarn = false;
      } else if (outside != null) {
        final raw = (1 - (outside - removeAt) / denominator) * 100;
        outsideWarn = raw > 100 || raw < 0;
        final clamped = raw.clamp(0, 100);
        outsidePercen = (clamped as num).roundToDouble();
      } else {
        outsidePercen = null;
        outsideWarn = false;
      }

      if (c.insideTread.text.trim().isEmpty) {
        insidePercent = null;
        insideWarn = false;
      } else if (inside != null) {
        final raw = (1 - (inside - removeAt) / denominator) * 100;
        insideWarn = raw > 100 || raw < 0;
        final clamped = raw.clamp(0, 100);
        insidePercent = (clamped as num).roundToDouble();
      } else {
        insidePercent = null;
        insideWarn = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              "Tread Depth(/32)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 11),

        Row(
          children: const [
            Text("Original Tread"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _tf(
          label: "Enter Original Tread",
          controller: c.originalTread,
          validator: (v) => _treadValidator(v, "Original Tread"),
          onChanged: (_) {
            setState(() {});
            _calculate();
          },
        ),

        Row(
          children: const [
            Text("Remove At"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _tf(
          label: "Remove At",
          controller: c.removeAt,
          validator: (v) => _treadValidator(v, "Remove At"),
          focusNode: _focusNode,
          clearIcon: true,
          onChanged: (_) {
            setState(() {});
            _calculate();
          },
        ),

        const Row(children: [Text("Purchase Tread")]),
        _tf(
          label: "Enter Purchase Tread",
          controller: c.purchasedTread,
          validator: (v) => _treadValidator(v, "Purchase Tread"),
          onChanged: (_) {
            setState(() {});
            _calculate();
          },
        ),

        Row(
          children: const [
            Text("Outside(a)"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _suffixTextTF(
          controller: c.outsideTread,
          percent: outsidePercen,
          warn: outsideWarn,
          onChanged: (_) {
            setState(() {});
            _calculate();
          },
          validator: (v) {
            final base = _required(v);
            if (base != null) return base;
            final outside = double.tryParse(v ?? '');
            final original = double.tryParse(c.originalTread.text);
            if (outside != null && original != null && outside > original) {
              return 'Outside tread cannot be greater than Original tread';
            }
            return null;
          },
          showRequiredWhenEmpty: true,
        ),

        Row(
          children: const [
            Text("Inside(c)"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _suffixTextTF(
          controller: c.insideTread,
          percent: insidePercent,
          warn: insideWarn,
          onChanged: (_) {
            setState(() {});
            _calculate();
          },
          validator: (v) {
            final base = _required(v);
            if (base != null) return base;
            final inside = double.tryParse(v ?? '');
            final original = double.tryParse(c.originalTread.text);
            if (inside != null && original != null && inside > original) {
              return 'Inside tread cannot be greater than Original tread';
            }
            return null;
          },
          showRequiredWhenEmpty: true,
        ),

        const SizedBox(height: 24),

        _primaryBtn("Next", () {
          if (c.formKey.currentState!.validate()) {
            c.nextStep();
          }
        }),

        const SizedBox(height: 12),
        _outlineBtn("Previous", c.previousStep),
        const SizedBox(height: 12),
        _outlineBtn("Cancel", c.cancelDialog),
      ],
    );
  }

  String? _treadValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    final v = double.tryParse(value);
    if (v == null) {
      return 'Enter a valid number';
    }
    if (field == 'Remove At') {
      if (v <= 0) {
        return 'Remove At value is required';
      }
      if (v < 0.01 || v > 99) {
        return 'Remove At must be between 0.01 and 99';
      }
      return null;
    }
    if (v < 0 || v > 99) {
      return 'Must be between 0 and 99';
    }
    return null;
  }

  Widget _tf({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    bool clearIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: validator,
        onChanged: onChanged,
        focusNode: focusNode,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          hintText: label,
          suffixIcon: clearIcon
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        onChanged?.call('');
                        focusNode?.requestFocus();
                        setState(() {});
                        _calculate();
                      },
                    );
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _suffixTextTF({
    required TextEditingController controller,
    required bool warn,
    required double? percent,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required bool showRequiredWhenEmpty,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            validator: validator,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: warn ? Colors.red : Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: warn ? Colors.red : Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: warn ? Colors.red : Colors.grey),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              suffixText: percent == null
                  ? null
                  : "${percent.clamp(0, 100).toStringAsFixed(0)}% worn",
              suffixStyle: const TextStyle(
                color: Colors.black, // ALWAYS BLACK
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// 🔴 WARNING MESSAGE
          if (warn && controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Warning, you are decreasing tread on a tire past its set pull point.",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "This field is required";
    }
    if (num.tryParse(v) == null) {
      return "Enter a valid number";
    }

    final regex = RegExp(r'^\d+(\.\d+)?$');
    if (!regex.hasMatch(v)) {
      return "Enter a valid number";
    }

    return null;
  }

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
              style: const TextStyle(
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
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
