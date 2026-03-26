import 'package:emtrack/edit_tyre/edit_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step3View extends StatefulWidget {
  const Step3View({super.key});

  @override
  State<Step3View> createState() => _Step3ViewState();
}

class _Step3ViewState extends State<Step3View> {
  final EditTyreController c = Get.find<EditTyreController>();
  final _formKey = GlobalKey<FormState>();
  double outsidePercent = 0;
  double insidePercent = 0;

  bool outsideWarn = false;
  bool insideWarn = false;

  @override
  void initState() {
    super.initState();
    if (c.removeAt.text.isEmpty) {
      c.removeAt.text = "0"; // default value
    }
    // 👇 IMPORTANT
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCloneData();

      //   _calculate();
    });
  }

  void loadCloneData() {
    c.outsideTread.addListener(_calculate);
    c.insideTread.addListener(_calculate);
    _calculate();
    _formKey.currentState?.validate();
  }
  // ================= CALCULATION =================

  void _calculate() {
    final original = double.tryParse(c.originalTread.text);
    final removeAt = double.tryParse(c.removeAt.text);
    final outside = double.tryParse(c.outsideTread.text);
    final inside = double.tryParse(c.insideTread.text);

    if (original == null || removeAt == null) return;

    double denominator = (original - removeAt);
    if (denominator == 0) return;

    setState(() {
      if (outside != null) {
        outsidePercent = (1 - (outside - removeAt) / denominator) * 100;
        outsidePercent = outsidePercent.roundToDouble();
        outsideWarn = outsidePercent > 100 || outsidePercent < 0;
      }

      if (inside != null) {
        insidePercent = (1 - (inside - removeAt) / denominator) * 100;
        insidePercent = insidePercent.roundToDouble();
        insideWarn = insidePercent > 100 || insidePercent < 0;
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
          validator: _required,
          // onChanged: (_) => _calculate(),
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
          validator: _required,
          clearIcon: true,
          onChanged: (_) {
            setState(() {});
            _calculate();
          },
        ),

        const Row(children: [Text("Purchase Tread")]),
        _tf(label: "Enter Purchase Tread", controller: c.purchasedTread),

        Row(
          children: const [
            Text("Outside(a)"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _suffixTextTF(
          controller: c.outsideTread,
          percent: outsidePercent,
          warn: outsideWarn,
          onChanged: (_) => _calculate(),
          validator: _required,
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
          onChanged: (_) => _calculate(),
          validator: _required,
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          hintText: label,
          suffixIcon: clearIcon && controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    focusNode?.requestFocus();
                    setState(() {});
                    _calculate();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _suffixTextTF({
    required TextEditingController controller,
    required double percent,
    required bool warn,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              return TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                validator: validator,
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: warn ? Colors.red : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: warn ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: warn ? Colors.red : Colors.grey,
                    ),
                  ),
                  suffixText: controller.text.isEmpty
                      ? "100% worn"
                      : "${percent.toInt()}% worn",
                  suffixStyle: const TextStyle(
                    color: Colors.black, // ALWAYS BLACK
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          // 🔴 WARNING MESSAGE
          if (warn && controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${percent.toInt()}% worn - Warning, you are decreasing tread on a tire past it's set pull point.",
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
      return "⚠️ Enter valid details.";
    }
    if (num.tryParse(v) == null) {
      return "Only numeric values are allowed";
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
