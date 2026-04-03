import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:emtrack/edit_tyre/edit_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step2View extends StatefulWidget {
  const Step2View({super.key});

  @override
  State<Step2View> createState() => _Step2ViewState();
}

class _Step2ViewState extends State<Step2View> {
  final EditTyreController c = Get.find<EditTyreController>();

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
        _searchDropdownDialog(
          hintText: "Manufacturer",
          controller: c.manufacturerId,
          list: c.manufacturerList,
          context: context,
          selectedId: c.selectedManufacturerId, // 🔥 pass RxInt here
          idList: c.manufacturerIdList
              .toList(), // 🔥 pass corresponding ID list
        ),

        Row(
          children: [
            Text("Tire Size"),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        _searchDropdownDialog(
          hintText: "Tyre Size",
          controller: c.sizeId,
          list: c.tireSizeList,
          context: context,
          selectedId: c.selectedSizeId, // 🔥 RxInt update
          idList: c.tireSizeIdList.toList(),
        ),
        Row(children: [Text("Star Rating")]),
        // _dropdownTF(
        //   hintText: "Star Rating",
        //   controller: c.starRatingId,
        //   onTap: () => _starDialog(context),
        //   validator: _required,
        // ),
        starRatingField(context),

        Row(
          children: [
            Text("Type "),
            Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),

        _searchDropdownDialog(
          hintText: "Type",
          controller: c.typeId,
          list: c.typeList,
          context: context,
          selectedId: c.selectedTypeId, // 🔥 RxInt update
          idList: c.typeIdList.toList(),

          // validator: _required,
        ),

        Row(children: [Text("Ind. Code")]),
        _searchDropdownDialog(
          hintText: "Ind. Code",
          controller: c.indCodeId,
          list: c.indCodeList,
          context: context,

          // validator: _required,
          selectedId: c.selectedIndCodeId, // 🔥 RxInt update
          idList: c.indCodeIdList.toList(),
        ),
        Row(children: [Text("Compound")]),
        _searchDropdownDialog(
          hintText: "Compound",
          controller: c.compoundId,
          list: c.compoundList,
          context: context,
          //validator: _required,
          selectedId: c.selectedCompoundId, // 🔥 RxInt update
          idList: c.compoundIdList.toList(),
        ),
        Row(children: [Text("Load Rating")]),
        _searchDropdownDialog(
          hintText: "Load Rating",
          controller: c.loadRatingId,
          list: c.loadRatingList,
          context: context,
          //validator: _required,
          selectedId: c.selectedLoadRatingId, // 🔥 RxInt update
          idList: c.loadRatingIdList.toList(),
        ),
        Row(children: [Text("Speed Rating")]),
        _searchDropdownDialog(
          hintText: "Speed Rating",
          controller: c.speedRatingId,
          list: c.speedRatingList,
          context: context,
          //validator: _required,
          selectedId: c.selectedSpeedRatingId, // 🔥 RxInt update
          idList: c.speedRatingIdList.toList(),
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

  // SEARCHABLE DROPDOWN → DIALOG BOX
  /*
  Widget _searchDropdownDialog({
    required String hintText,
    required TextEditingController controller,
    required List<String> list,
    required BuildContext context,
    //String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GetBuilder<EditTyreController>(
        builder: (c) {
          return TextFormField(
            controller: controller,
            readOnly: true,
            //validator: validator,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
            ),
            onTap: () {
              c.checkStarEnable();
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

                            /// 📜 LIST (SCROLLABLE)
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

                            /// 🔹 BOTTOM ACTIONS (iOS STYLE)
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
                                          // controller.text = selectedValue!;
                                          final index = list.indexOf(
                                            selectedValue!,
                                          );
                                          controller.text = selectedValue!;
                                          c.typeId.text = c.typeIdList[index]
                                              .toString(); // ✅ ID SAFE
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
*/
  Widget _searchDropdownDialog({
    required String hintText,
    required TextEditingController controller,
    required List<String> list,
    required BuildContext context,
    RxInt? selectedId, // 🔥 Pass RxInt to update
    List<int>? idList, // 🔥 Corresponding IDs for each item
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GetBuilder<EditTyreController>(
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
              c.checkStarEnable();
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

  Widget starRatingField(BuildContext context) {
    return GetBuilder<EditTyreController>(
      builder: (c) {
        final enabled = c.isStarEnabled.value;
        final starCount = c.starRating.value;

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
            child: starCount == 0
                ? Text("Select", style: TextStyle(color: Colors.grey))
                : Row(
                    children: List.generate(
                      starCount,
                      (_) => const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 14,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _starDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return GetBuilder<EditTyreController>(
          builder: (c) {
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
                    height: 200,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (_, index) {
                        final starValue = index + 1;
                        final isSelected = c.starRating.value == starValue;
                        return InkWell(
                          onTap: () {
                            c.setStarRating(starValue); // 🔥
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                /// ⭐ STARS
                                Row(
                                  children: List.generate(
                                    starValue,
                                    (_) => Icon(
                                      Icons.star,
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.black,
                                      size: 14,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                /// ✅ CHECK (RED)
                                if (isSelected)
                                  const Icon(Icons.check, color: Colors.orange),
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
                                  color: Colors.black,
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
    //String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        //validator: validator,
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
    if (v == null || v.trim().isEmpty) return "This field is required";
    return null;
  }
}
