import 'package:emtrack/controllers/install_tyre_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstallTyreView extends StatelessWidget {
  InstallTyreView({super.key});

  final controller = Get.find<InstallTyreController>();

  final selectedCtrl = Get.put(SelectedAccountController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "Install Tyre",
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final m = controller.model.value;
            final tyreData = controller.tyreList.isNotEmpty
                ? controller.tyreList.first
                : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 INFO CARD (Screenshot 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 253),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected Parent Account and Location:",
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${selectedCtrl.parentAccountName.value} - ${selectedCtrl.locationName.value}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Divider(),
                      Text("Vehicle ID:"),
                      Text(
                        "${controller.vehicleNumber}",
                        //  "#${m.vehicleId}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      Text(
                        "Tire Serial Number",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${tyreData?.tireSerialNo}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      Text("Wheel Position:", style: TextStyle(fontSize: 12)),
                      Text(
                        "${m.wheelPosition}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      Text("Last Inspection:", style: TextStyle(fontSize: 12)),
                      Text(
                        "18/12/2025",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Outside Tread Depth
                _counter32(
                  title: "Outside Tread Depth",
                  value: "${m.outsideTread} /32nds",
                  onMinus: controller.decOutside,
                  onPlus: controller.incOutside,
                ),

                const SizedBox(height: 16),

                // 🔹 Inside Tread Depth
                _counter32(
                  title: "Inside Tread Depth",
                  value: "${m.insideTread} /32nds",
                  onMinus: controller.decInside,
                  onPlus: controller.incInside,
                ),

                const SizedBox(height: 16),

                // 🔹 Average Tread (Readonly)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Average Tread"),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        m.currentTreadDepth.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 11),
                _counter(
                  "Air Pressure",
                  "${m.currentPressure} PSI",
                  controller.decAir,
                  controller.incAir,
                ),

                const SizedBox(height: 16),
                searchDropdownDialog(
                  hintText: "Wear Condition",
                  controller: controller.wearConditionsId,
                  nameList: controller.wearConditionsList,
                  idList: controller.wearConditionsIdList,
                  selectedId: controller.selectedWearConditionsId,
                  context: context,
                ),
                searchDropdownDialog(
                  hintText: "Casing Candition",
                  controller: controller.casingConditionsId,
                  nameList: controller.casingConditionList,
                  idList: controller.casingConditionIdList,
                  selectedId: controller.selectedCasingConditionId,
                  context: context,
                ),

                // _dropdown("Wear Condition", m.wearConditionId.toString()),

                // const SizedBox(height: 12),

                //_dropdown("Casing Condition", m.casingConditionId.toString()),
                const SizedBox(height: 12),

                _textBox(
                  "List Of Previous Comments",
                  controller.previousCommentController,
                  enabled: false,
                ),

                const SizedBox(height: 12),

                Row(
                  children: const [
                    Radio(value: true, groupValue: true, onChanged: null),
                    Text("Still Relevant"),
                  ],
                ),

                const SizedBox(height: 12),

                _textBox(
                  "Comments",
                  controller.commentsController,
                  onChanged: (v) =>
                      controller.model.update((m) => m!.comments = v),
                ),

                const SizedBox(height: 16),

                // Wrap(
                //   spacing: 8,
                //   children: m.images
                //       .map(
                //         (e) => Image.file(
                //           File(e),
                //           width: 70,
                //           height: 70,
                //           fit: BoxFit.cover,
                //         ),
                //       )
                //       .toList(),
                // ),
                const SizedBox(height: 12),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ⭐ MOST IMPORTANT
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: controller.submit,
                          child: const Text(
                            "Install",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          AppDialog.showConfirmDialog(
                            title: "Cancel Request",

                            message:
                                "Are you sure you want to cancel? You will\n lose unsaved data.",
                            okText: "Yes",
                            onOk: () {
                              Get.back(closeOverlays: true);

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Get.offAllNamed(AppPages.HOME);
                              });
                            },
                          );
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget searchDropdownDialog({
    required String hintText,
    required TextEditingController controller,
    required List<String> nameList,
    required List<int> idList,
    required RxInt selectedId,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
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

  // 🔹 Widgets
  Widget _counter(
    String title,
    String value,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 6),
        Row(
          children: [
            _redBtn("-", minus),
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(value),
              ),
            ),
            _redBtn("+", plus),
          ],
        ),
      ],
    );
  }

  Widget _counter32({
    required String title,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 6),
        Row(
          children: [
            _redBtn("-", onMinus),
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(value),
              ),
            ),
            _redBtn("+", onPlus),
          ],
        ),
      ],
    );
  }

  Widget _redBtn(String t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 44,
        color: Colors.red,
        alignment: Alignment.center,
        child: Text(
          t,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, size: 18),
              SizedBox(width: 8),
              Text("CLEAN"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _textBox(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: controller,
          maxLines: 3,
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}

//   Widget _textBox(
//     String label,
//     String value, {
//     bool enabled = true,
//     Function(String)? onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 6),
//         TextField(
//           enabled: enabled,
//           controller: TextEditingController(text: value),
//           maxLines: 3,
//           onChanged: onChanged,
//           decoration: const InputDecoration(border: OutlineInputBorder()),
//         ),
//       ],
//     );
//   }
// }
