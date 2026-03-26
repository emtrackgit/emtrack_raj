import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step3View extends StatelessWidget {
  Step3View({super.key});

  final CreateTyreController c = Get.find<CreateTyreController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Tread Depth(/32)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 11),
        Row(
          children: [
            Text("Original Tread"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _tf(
          label: "Enter Original Tread",
          controller: c.originalTread,
          validator: _required,
        ),
        Row(
          children: [
            Text("Remove At"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _tf(
          label: "Remove At",
          controller: c.removeAt,
          clearIcon: true,
          validator: _required,
        ),
        Row(children: [Text("Purchase Tread")]),
        _tf(label: "Enter Purchase Tread", controller: c.purchasedTread),
        Row(
          children: [
            Text("Outside(a)"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _suffixTextTF(
          label: "0",
          controller: c.outsideTread,
          suffixText: "100% worn",
          validator: _required,
        ),
        // Row(
        //   children: [
        //     Text("Middle(b)"),
        //     Text("*", style: TextStyle(color: Colors.red)),
        //   ],
        // ),
        // _suffixTextTF(
        //   label: "0",
        //   controller: c.insideTread,
        //   suffixText: "100% worn",
        // ),
        Row(
          children: [
            Text("Inside(c)"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _suffixTextTF(
          label: "0",
          controller: c.insideTread,

          suffixText: "100% worn",
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

  // ================= TEXTFIELDS =================

  Widget _tf({
    required String label,
    TextEditingController? controller,
    dynamic value,
    bool enabled = true,
    bool clearIcon = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final TextEditingController effectiveController =
        controller ?? TextEditingController(text: value?.toString() ?? "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: effectiveController,
        enabled: enabled,
        keyboardType: TextInputType.number,
        validator: validator,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: label,
          suffixIcon: clearIcon && effectiveController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => effectiveController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _suffixTextTF({
    required String label,
    required TextEditingController controller,
    required String suffixText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        enabled: true,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: label,
          suffixText: suffixText,
          hintStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
      return "⚠️ Enter valid details.";
    }

    if (num.tryParse(v) == null) {
      return "Only numeric values are allowed";
    }

    return null;
  }
}
