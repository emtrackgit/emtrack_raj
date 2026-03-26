import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:emtrack/models/masterDataMobileModel/star_rating_model.dart';
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
      children: [
        Row(
          children: [
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Text("Manufacture "),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        // _searchDropdownDialog(
        //   hintText: "Search Manufacturer",
        //   controller: c.manufacturerId,
        //   list: c.manufacturerList,
        //   context: context,
        //   validator: _required,
        // ),
        searchDropdownDialog(
          hintText: "Manufacturer",
          controller: c.manufacturerId,
          nameList: c.manufacturerList,
          idList: c.manufacturerIdList,
          selectedId: c.selectedManufacturerId,
          validator: _required,
          context: context,
          onChanged: (id, name) {
            // load tire sizes based on manufacturer
            c.filterTireSizesByManufacturer(id);

            // clear tire size
            c.sizeId.clear();
            c.selectedSizeId.value = 0;
          },
        ),
        Row(
          children: [
            Text("Tire Size"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        searchDropdownDialog(
          hintText: "Choose Tire Size",
          controller: c.sizeId,
          nameList: c.tireSizeList,
          idList: c.tireSizeIdList,
          selectedId: c.selectedSizeId,
          context: context,
          validator: _required,
          onChanged: (id, name) {
            c.getTireTypes(id);
            c.typeId.clear();
            c.selectedTypeId.value = 0;
          },
        ),

        Obx(() {
          if (c.selectedSizeId.value == 0) {
            return SizedBox(); // hidden
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Text("Star Rating")]),
              starRatingField(context),
            ],
          );
        }),

        Row(
          children: [
            Text("Type "),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        searchDropdownDialog(
          hintText: "Choose Type ",
          controller: c.typeId,
          nameList: c.typeList,
          idList: c.typeIdList,
          context: context,
          selectedId: c.selectedTypeId,
          validator: _required,
        ),
        Row(children: [Text("Ind. Code")]),
        searchDropdownDialog(
          hintText: "Search Ind. Code",
          controller: c.indCodeId,
          nameList: c.indCodeList,
          idList: c.indCodeIdList,
          selectedId: c.selectedIndCodeId,
          context: context,
        ),
        Row(children: [Text("Compound")]),
        searchDropdownDialog(
          hintText: "Search Compound",
          controller: c.compoundId,
          nameList: c.compoundList,
          idList: c.compoundIdList,
          selectedId: c.selectedCompoundId,
          context: context,
        ),
        Row(children: [Text("Load Rating")]),
        searchDropdownDialog(
          hintText: "Search Load Rating",
          controller: c.loadRatingId,
          nameList: c.loadRatingList,
          idList: c.loadRatingIdList,
          selectedId: c.selectedLoadRatingId,
          context: context,
        ),
        Row(children: [Text("Speed Rating")]),
        searchDropdownDialog(
          hintText: " Search Speed Rating",
          controller: c.speedRatingId,
          nameList: c.speedRatingList,
          idList: c.speedRatingIdList,
          selectedId: c.selectedSpeedRatingId,
          context: context,
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

  Widget searchDropdownDialog({
    required String hintText,
    required TextEditingController controller,
    required List<String> nameList,
    required List<int> idList,
    String? Function(String?)? validator,
    required RxInt selectedId,
    required BuildContext context,
    Function(int id, String name)? onChanged,
  }) {
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
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              List<String> filteredList = List.from(nameList);
              TextEditingController searchController = TextEditingController();

              String? tempSelectedName = controller.text.isEmpty
                  ? null
                  : controller.text;

              int? tempSelectedId = selectedId.value == 0
                  ? null
                  : selectedId.value;

              return StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Select $hintText"),
                      automaticallyImplyLeading: false,
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
                                filteredList = nameList
                                    .where(
                                      (item) => item.toLowerCase().contains(
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
                              : ListView.builder(
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredList[index];
                                    final originalIndex = nameList.indexOf(
                                      item,
                                    );

                                    final isSelected = tempSelectedName == item;

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
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.red,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          tempSelectedName = item;
                                          tempSelectedId =
                                              idList[originalIndex];
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),

                        /// 🔘 BOTTOM BUTTONS
                        Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey)),
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
                                    if (tempSelectedName != null &&
                                        tempSelectedId != null) {
                                      controller.text = tempSelectedName!;
                                      selectedId.value = tempSelectedId!;
                                    }
                                    if (onChanged != null) {
                                      onChanged(
                                        tempSelectedId!,
                                        tempSelectedName!,
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Center(
                                    child: Text(
                                      "OK",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 16,
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
      ),
    );
  }

  Widget starRatingField(BuildContext context) {
    return GetBuilder<CreateTyreController>(
      builder: (c) {
        final enabled = c.isStarEnabled.value;
        final label = c.selectedStarRatingName.value.trim();

        return InkWell(
          onTap: enabled ? () => _starDialog(context) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade50,
              hintText: "Select",
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.black : Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: label.isEmpty
                ? Text("Select", style: TextStyle(color: Colors.grey))
                : Text(label),
          ),
        );
      },
    );
  }

  void _starDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return GetBuilder<CreateTyreController>(
          builder: (c) {
            final desiredNames = <String>[
              '*',
              '**',
              '***',
              '****',
              '*/**',
              '***/****',
            ];

            StarRating? findByName(String name) {
              for (final r in c.starRatings) {
                if (r.ratingName.trim() == name) return r;
              }
              return null;
            }

            final items = List.generate(
              desiredNames.length,
              (i) =>
                  findByName(desiredNames[i]) ??
                  StarRating(
                    ratingId: i + 1,
                    ratingName: desiredNames[i],
                  ),
            );

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              titlePadding: const EdgeInsets.only(top: 12),
              contentPadding: EdgeInsets.zero,

              title: const Center(
                child: Text(
                  "Star Rating",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 11),

                  /// ⭐ STAR LIST
                  SizedBox(
                    height: 260,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final rating = items[index];
                        final isSelected = c.starRating.value == rating.ratingId;

                        return InkWell(
                          onTap: () {
                            c.setStarRating(rating);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  rating.ratingName,
                                  style: const TextStyle(fontSize: 16),
                                ),

                                const Spacer(),

                                /// ✅ CHECK (RED)
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

                  /// 🍏 ACTIONS
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
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
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
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
  }

  // ===================================================================
  Widget _dropdownTF({
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  // ===================================================================
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
    if (v == null || v.trim().isEmpty) return "⚠️ Enter valid details.";
    return null;
  }
}
