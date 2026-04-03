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

  // Dedicated FocusNode for Remove At so X button can re-focus it
  final FocusNode _removeAtFocusNode = FocusNode();

  // Local state value for Remove At so we can rebuild suffix icon reactively
  // without nesting TextFormField inside ValueListenableBuilder
  // (which caused a rebuild loop in the previous version).
  String _removeAtText = "";

  @override
  void initState() {
    super.initState();

    if (c.removeAt.text.isEmpty) {
      c.removeAt.text = "0";
    }
    _removeAtText = c.removeAt.text;

    // Listen to controller changes to update local state
    c.removeAt.addListener(_onRemoveAtChanged);

    _calculate();
  }

  void _onRemoveAtChanged() {
    if (_removeAtText != c.removeAt.text) {
      setState(() => _removeAtText = c.removeAt.text);
    }
  }

  @override
  void dispose() {
    c.removeAt.removeListener(_onRemoveAtChanged);
    _removeAtFocusNode.dispose();
    super.dispose();
  }

  // ── % Worn calculation ────────────────────────────────────────────
  void _calculate() {
    final original = double.tryParse(c.originalTread.text);
    final removeAt = double.tryParse(c.removeAt.text);
    final outside = double.tryParse(c.outsideTread.text);
    final inside = double.tryParse(c.insideTread.text);

    if (original == null || removeAt == null) return;
    final denominator = original - removeAt;
    if (denominator == 0) return;

    setState(() {
      if (outside != null) {
        outsidePercen =
            ((1 - (outside - removeAt) / denominator) * 100).roundToDouble();
        outsideWarn = outsidePercen! > 100 || outsidePercen! < 0;
      } else {
        outsidePercen = 0;
        outsideWarn = false;
      }

      if (inside != null) {
        insidePercent =
            ((1 - (inside - removeAt) / denominator) * 100).roundToDouble();
        insideWarn = insidePercent! > 100 || insidePercent! < 0;
      } else {
        insidePercent = 0;
        insideWarn = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────
        const Text(
          "Tread Depth(/32)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 11),

        // ── Original Tread ───────────────────────────────────────────
        _label("Original Tread", required: true),
        _tf(
          hint: "Enter Original Tread",
          controller: c.originalTread,
          validator: _required,
          onChanged: (_) => _calculate(),
        ),

        // ── Remove At ────────────────────────────────────────────────
        _label("Remove At", required: true),
        // FIX 2: suffix X icon correctly shows/hides using listener-based
        // local state (_removeAtText) instead of ValueListenableBuilder
        // wrapping the TextFormField (which caused rebuild loops).
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: c.removeAt,
            focusNode: _removeAtFocusNode,
            keyboardType: TextInputType.number,
            validator: _required,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [_decimalOnlyFormatter()], // FIX 4
            onChanged: (_) => _calculate(),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2),
              ),
              hintText: "Remove At",
              // ✅ FIX 2: X icon visible & value visible — driven by
              // _removeAtText which is kept in sync via addListener
              suffixIcon: _removeAtText.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  c.removeAt.clear();
                  _removeAtFocusNode.requestFocus();
                  _calculate();
                },
              )
                  : null,
            ),
          ),
        ),

        // ── Purchase Tread ───────────────────────────────────────────
        _label("Purchase Tread"),
        _tf(
          hint: "Enter Purchase Tread",
          controller: c.purchasedTread,
          onChanged: (_) => _calculate(),
        ),

        // ── Outside (a) ──────────────────────────────────────────────
        _label("Outside(a)", required: true),
        _suffixTF(
          controller: c.outsideTread,
          percent: outsidePercen ?? 0,
          warn: outsideWarn,
          validator: _required,
          onChanged: (_) => _calculate(),
        ),

        // ── Inside (c) ───────────────────────────────────────────────
        _label("Inside(c)", required: true),
        _suffixTF(
          controller: c.insideTread,
          percent: insidePercent ?? 0,
          warn: insideWarn,
          validator: _required,
          onChanged: (_) => _calculate(),
        ),

        const SizedBox(height: 24),

        // ── Buttons ──────────────────────────────────────────────────
        _primaryBtn("Next", () {
          // FIX 3: validate() first → all error messages appear
          final valid = c.formKey.currentState?.validate() ?? false;
          if (valid) c.nextStep();
        }),
        const SizedBox(height: 12),
        _outlineBtn("Previous", c.previousStep),
        const SizedBox(height: 12),
        _outlineBtn("Cancel", c.cancelDialog),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Plain numeric text field
  // ═══════════════════════════════════════════════════════════════════
  Widget _tf({
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: validator,
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: [_decimalOnlyFormatter()], // FIX 4
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          hintText: hint,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Text field with "% worn" suffix + warning message
  // ═══════════════════════════════════════════════════════════════════
  Widget _suffixTF({
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
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            validator: validator,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [_decimalOnlyFormatter()], // FIX 4
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide:
                BorderSide(color: warn ? Colors.red : Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: warn ? Colors.red : Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: warn ? Colors.red : Colors.grey),
              ),
              // Show "% worn" only when NOT in warning state
              suffixText:
              (warn && controller.text.trim().isNotEmpty)
                  ? null
                  : "${percent.toStringAsFixed(0)}% worn",
              suffixStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🔴 Warning text
          if (warn && controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${percent.toInt()}% worn - Warning, you are decreasing "
                    "tread on a tire past it's set pull point.",
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

  // ═══════════════════════════════════════════════════════════════════
  // FIX 4: Custom formatter
  //   • Allows digits and AT MOST ONE decimal point
  //   • Blocks comma (,) completely
  //   • Blocks any other non-numeric character
  // ═══════════════════════════════════════════════════════════════════
  TextInputFormatter _decimalOnlyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;

      // Block comma
      if (text.contains(',')) return oldValue;

      // Allow empty string (user cleared the field)
      if (text.isEmpty) return newValue;

      // Allow only digits + at most one dot
      if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;

      // Extra guard: block if somehow more than one dot slipped through
      if ('.'.allMatches(text).length > 1) return oldValue;

      return newValue;
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════
  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text(text),
        if (required) const Text(" *", style: TextStyle(color: Colors.red)),
      ]),
    );
  }

  // FIX 5: First word capital in all validation messages
  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return "⚠️ Enter valid details.";
    if (num.tryParse(v) == null) return "Only numeric values are allowed.";
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
              borderRadius: BorderRadius.circular(10), color: Colors.red),
          child: Center(
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
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
              border: Border.all(color: Colors.grey, width: 1)),
          child: Center(
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}