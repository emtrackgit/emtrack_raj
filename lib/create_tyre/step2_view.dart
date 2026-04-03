import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step2View extends StatefulWidget {
  const Step2View({super.key});

  @override
  State<Step2View> createState() => _Step2ViewState();
}

class _Step2ViewState extends State<Step2View> {
  final CreateTyreController c = Get.find<CreateTyreController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────
        const Text(
          "Description",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // ── Manufacturer ─────────────────────────────────────────────
        _label("Manufacture", required: true),
        Obx(() => _searchDropdown(
          hintText: "Search Tire Manufacturer",
          controller: c.manufacturerId,
          nameList: c.manufacturerList.toList(),
          idList: c.manufacturerIdList.toList(),
          selectedId: c.selectedManufacturerId,
          validator: _required,
          context: context,
          onChanged: (id, name) {
            c.filterTireSizesByManufacturer(id);
            c.sizeId.clear();
            c.selectedSizeId.value = 0;
            c.typeId.clear();
            c.selectedTypeId.value = 0;
          },
        )),

        // ── Tire Size ────────────────────────────────────────────────
        _label("Tire Size", required: true),
        Obx(() => _searchDropdown(
          hintText: "Choose Manufacturer first",
          controller: c.sizeId,
          nameList: c.tireSizeList.toList(),
          idList: c.tireSizeIdList.toList(),
          selectedId: c.selectedSizeId,
          validator: _required,
          context: context,
          toUpperCase: true, // ✅ FIX 1 — CAPITAL LETTERS
          onChanged: (id, name) {
            c.getTireTypes(id);
            c.typeId.clear();
            c.selectedTypeId.value = 0;
          },
        )),

        // ── Star Rating (only when size is selected) ─────────────────
        Obx(() {
          if (c.selectedSizeId.value == 0) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Star Rating"),
              _starRatingField(context),
              const SizedBox(height: 14),
            ],
          );
        }),

        // ── Type ─────────────────────────────────────────────────────
        _label("Type", required: true),
        Obx(() => _searchDropdown(
          hintText: "Choose size first",
          controller: c.typeId,
          nameList: c.typeList.toList(),
          idList: c.typeIdList.toList(),
          selectedId: c.selectedTypeId,
          validator: _required,
          context: context,
          toUpperCase: true, // ✅ FIX 1 — CAPITAL LETTERS
        )),

        // ── Ind. Code ────────────────────────────────────────────────
        _label("Ind. Code"),
        Obx(() => _searchDropdown(
          hintText: "Search Ind. Code",
          controller: c.indCodeId,
          nameList: c.indCodeList.toList(),
          idList: c.indCodeIdList.toList(),
          selectedId: c.selectedIndCodeId,
          context: context,
        )),

        // ── Compound ─────────────────────────────────────────────────
        _label("Compound"),
        Obx(() => _searchDropdown(
          hintText: "Search Compound",
          controller: c.compoundId,
          nameList: c.compoundList.toList(),
          idList: c.compoundIdList.toList(),
          selectedId: c.selectedCompoundId,
          context: context,
        )),

        // ── Load Rating ──────────────────────────────────────────────
        _label("Load Rating"),
        Obx(() => _searchDropdown(
          hintText: "Search Load Rating",
          controller: c.loadRatingId,
          nameList: c.loadRatingList.toList(),
          idList: c.loadRatingIdList.toList(),
          selectedId: c.selectedLoadRatingId,
          context: context,
        )),

        // ── Speed Rating ─────────────────────────────────────────────
        _label("Speed Rating"),
        Obx(() => _searchDropdown(
          hintText: "Search Speed Rating",
          controller: c.speedRatingId,
          nameList: c.speedRatingList.toList(),
          idList: c.speedRatingIdList.toList(),
          selectedId: c.selectedSpeedRatingId,
          context: context,
        )),

        const SizedBox(height: 24),

        // ── Buttons ──────────────────────────────────────────────────
        _primaryBtn("Next", () {
          // FIX 3: validate() triggers all error messages at once
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
  // Reusable search-dropdown
  // ═══════════════════════════════════════════════════════════════════
  Widget _searchDropdown({
    required String hintText,
    required TextEditingController controller,
    required List<String> nameList,
    required List<int> idList,
    required RxInt selectedId,
    required BuildContext context,
    String? Function(String?)? validator,
    Function(int id, String name)? onChanged,
    bool toUpperCase = false,
  }) {
    // Build display list — uppercase only for Tire Size & Type
    final List<String> displayList =
    toUpperCase ? nameList.map((e) => e.toUpperCase()).toList() : nameList;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
        ),
        onTap: () => _showPickerDialog(
          context: context,
          hintText: hintText,
          displayList: displayList,
          idList: idList,
          controller: controller,
          selectedId: selectedId,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Full-screen picker dialog ──────────────────────────────────────
  void _showPickerDialog({
    required BuildContext context,
    required String hintText,
    required List<String> displayList,
    required List<int> idList,
    required TextEditingController controller,
    required RxInt selectedId,
    Function(int id, String name)? onChanged,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        List<String> filtered = List.from(displayList);
        final searchCtrl = TextEditingController();

        // Pre-select already chosen item
        String? tempName =
        controller.text.trim().isEmpty ? null : controller.text.trim();
        int? tempId = selectedId.value == 0 ? null : selectedId.value;

        return StatefulBuilder(builder: (ctx, ss) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Select $hintText"),
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                // 🔍 Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => ss(() {
                      filtered = displayList
                          .where((e) =>
                          e.toLowerCase().contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                ),

                // 📜 List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text("No data found"))
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      // map back to original index to get correct id
                      final origIdx = displayList.indexOf(item);
                      final isSelected = tempName == item;

                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.red
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check,
                            color: Colors.red)
                            : null,
                        onTap: () => ss(() {
                          tempName = item;
                          if (origIdx != -1 &&
                              origIdx < idList.length) {
                            tempId = idList[origIdx];
                          }
                        }),
                      );
                    },
                  ),
                ),

                // 🔘 Cancel / OK
                Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(ctx),
                          child: const Center(
                            child: Text("Cancel",
                                style: TextStyle(
                                    color: Colors.red, fontSize: 16)),
                          ),
                        ),
                      ),
                      Container(width: 0.5, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (tempName != null && tempId != null) {
                              controller.text = tempName!;
                              selectedId.value = tempId!;
                              onChanged?.call(tempId!, tempName!);
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Center(
                            child: Text("OK",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Star rating widget + dialog
  // ═══════════════════════════════════════════════════════════════════
  Widget _starRatingField(BuildContext context) {
    return GetBuilder<CreateTyreController>(builder: (c) {
      final enabled = c.isStarEnabled.value;
      final selectedText = c.starRatingId.text.trim();
      return InkWell(
        onTap: enabled ? () => _starDialog(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            suffixIcon: Icon(Icons.arrow_drop_down,
                color: enabled ? Colors.black : Colors.grey),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: selectedText.isEmpty
              ? const Text("Select", style: TextStyle(color: Colors.grey))
              : Text(selectedText),
        ),
      );
    });
  }

  void _starDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => GetBuilder<CreateTyreController>(builder: (c) {
        final ids = c.starRatingIdList.toList();
        final names = c.starRatingNameList.toList();
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          titlePadding: const EdgeInsets.only(top: 12),
          contentPadding: EdgeInsets.zero,
          title: const Center(
              child: Text("Star Rating",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 11),
              SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (_, i) {
                    final id = i < ids.length ? ids[i] : 0;
                    final name = names[i];
                    final sel = c.starRating.value == id;
                    return InkWell(
                      onTap: () => c.setStarRating(id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Row(children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: sel ? Colors.blue : Colors.black,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (sel)
                            const Icon(Icons.check, color: Colors.blue),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 48,
                child: Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 16))),
                    ),
                  ),
                  Container(width: 0.5, color: Colors.grey),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                          child: Text("OK",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════
  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text(text),
        if (required)
          const Text(" *", style: TextStyle(color: Colors.red)),
      ]),
    );
  }

  // FIX 5: First word capital
  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return "⚠️ Enter valid details.";
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold))),
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
                      color: Colors.red,
                      fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}
