import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/controllers/create_vehicle_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/widgets/vehicle_daigram_Rotate_tyres.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateVehicleView extends StatelessWidget {
  final vc = Get.put(VehicleController());
  final allVehicleController = Get.isRegistered<AllVehicleController>()
      ? Get.find<AllVehicleController>()
      : Get.put(AllVehicleController());

  final selectedCtrl = Get.put(SelectedAccountController());

  CreateVehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Vehicle',
          style: TextStyle(color: AppColors.textWhite, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selected parent account & Location"),
            Obx(
              () => Text(
                "${selectedCtrl.parentAccountName.value} - ${selectedCtrl.locationName.value}",
                style: TextStyle(
                  color: AppColors.buttonDanger,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// VEHICLE ID
            label("Vehicle ID"),
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Vehicle ID',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: vc.vehicleNumberError.value.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  errorText: vc.vehicleNumberError.value.isNotEmpty
                      ? vc.vehicleNumberError.value
                      : null,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                onChanged: (v) {
                  vc.vehicleNumber.value = v;
                  vc.clearVehicleNumberError();
                },
              ),
            ),

            const SizedBox(height: 12),

            /// TRACKING METHOD
            label("Tracking Method"),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: vc.trackingMethodError.value.isNotEmpty
                            ? Colors.red
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      title: Text(vc.trackingMethodText.value),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        Get.defaultDialog(
                          title: "Tracking Method",
                          titleStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          titlePadding: const EdgeInsets.only(
                            top: 16,
                            bottom: 8,
                          ),
                          contentPadding: EdgeInsets.zero,
                          radius: 12,
                          backgroundColor: Colors.white,

                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Divider(height: 1),

                              /// HOURS
                              Obx(
                                () => _iosOptionTile(
                                  text: "Hours",
                                  selected:
                                      vc.trackingMethodText.value == "Hours",
                                  onTap: () =>
                                      vc.trackingMethodText.value = "Hours",
                                ),
                              ),

                              /// DISTANCE
                              Obx(
                                () => _iosOptionTile(
                                  text: "Distance",
                                  selected:
                                      vc.trackingMethodText.value == "Distance",
                                  onTap: () =>
                                      vc.trackingMethodText.value = "Distance",
                                ),
                              ),

                              /// BOTH
                              Obx(
                                () => _iosOptionTile(
                                  text: "Both",
                                  selected:
                                      vc.trackingMethodText.value == "Both",
                                  onTap: () =>
                                      vc.trackingMethodText.value = "Both",
                                ),
                              ),

                              const Divider(height: 1),

                              /// ACTION BUTTONS
                              SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Get.back(),
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

                                    Container(
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),

                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          vc.clearTrackingMethodError();
                                          Get.back();
                                        },
                                        child: const Center(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
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
                    ),
                  ),
                  if (vc.trackingMethodError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        vc.trackingMethodError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// CURRENT HOURS
            label("Current Hours"),

            Obx(
              () => TextField(
                controller: vc.currentHoursCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: vc.currentHoursError.value.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),

                  /// 🔴 CUSTOM ERROR TEXT
                  errorText: vc.currentHoursError.value.isNotEmpty
                      ? vc.currentHoursError.value
                      : null,

                  /// ❌ SUFFIX ICON
                  suffixIcon: vc.currentHoursCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            vc.currentHoursCtrl.clear();
                            vc.currentHours.value = "";
                          },
                        )
                      : null,
                ),
                onChanged: (v) {
                  vc.currentHours.value = v;
                  vc.clearCurrentHoursError();
                },
              ),
            ),

            /// MANUFACTURER
            label("Manufacturer"),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchableDialogField(
                    context: context,
                    title: 'Select Manufacturer',
                    controller: vc.manufacturerCtrl,
                    items: vc.manufacturerList,
                    enabled: true,
                    onTap: () {
                      _openFullScreenDialog(
                        selectedValue: vc.selectedManufecturer,
                        context: context,
                        title: 'Select Manufacturer',
                        items: vc.manufacturerList,
                        onSelect: (item) {
                          vc.selectManufacturer(item);
                          vc.clearManufacturerError();
                        },
                      );
                    },
                  ),
                  if (vc.manufacturerError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        vc.manufacturerError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// TYPE (DEPENDENT)
            const Text("Type *"),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchableDialogField(
                    context: context,
                    title: 'Select Type',
                    controller: vc.typeCtrl,
                    items: vc.typeList,
                    enabled: vc.manufacturerId.value != 0,
                    onTap: vc.manufacturerId.value != 0
                        ? () {
                            _openFullScreenDialog(
                              selectedValue: vc.selectedType,
                              context: context,
                              title: 'Select Type',
                              items: vc.typeList,
                              onSelect: (item) {
                                vc.selectType(item);
                                vc.clearTypeError();
                              },
                            );
                          }
                        : null,
                  ),
                  if (vc.typeError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        vc.typeError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /// MODEL
            label("Model"),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchableDialogField(
                    context: context,
                    title: 'Select Model',
                    controller: vc.modelCtrl,
                    items: vc.modelList,
                    enabled: true,
                    onTap: () {
                      _openFullScreenDialog(
                        selectedValue: vc.selectedModel,
                        context: context,
                        title: 'Select Model',
                        items: vc.modelList,
                        onSelect: (item) {
                          vc.selectModel(item);
                          vc.clearModelError();
                        },
                      );
                    },
                  ),
                  if (vc.modelError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        vc.modelError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// TYRE SIZE
            label("Tyre Size"),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchableDialogField(
                    context: context,
                    title: 'Select Tyre Size',
                    controller: vc.tyreSizeCtrl,
                    items: vc.tyreSizeList,
                    enabled: true,
                    onTap: () {
                      _openFullScreenDialog(
                        selectedValue: vc.selectedTyreSize,
                        context: context,
                        title: 'Select Tyre Size',
                        items: vc.tyreSizeList,
                        onSelect: (item) {
                          vc.selectTyreSize(item);
                          vc.clearTyreSizeError();
                        },
                      );
                    },
                  ),
                  if (vc.tyreSizeError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        vc.tyreSizeError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// REMOVAL TREAD
            label("Removal Tread"),
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  hintText: 'Removal Tread',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: vc.removalTreadError.value.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  errorText: vc.removalTreadError.value.isNotEmpty
                      ? vc.removalTreadError.value
                      : null,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  vc.removalTread.value = v;
                  vc.clearRemovalTreadError();
                },
              ),
            ),

            const SizedBox(height: 12),

            /// COMMENTS
            const Text("Vehicle Comments"),
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  hintText: ' Comments go here. (Max 200 characters)',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: vc.commentsError.value.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  errorText: vc.commentsError.value.isNotEmpty
                      ? vc.commentsError.value
                      : null,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                maxLines: null,
                onChanged: (v) {
                  vc.comments.value = v;
                  vc.clearCommentsError();
                },
              ),
            ),

            /// PRESSURE SECTION
            Obx(() {
              if (!vc.showPressureSection) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Vehicle Diagram",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  AxleTyreLayout(),
                  const SizedBox(height: 8),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Axel 1
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Recommended Pressure for Axel 1"),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: Colors.red),
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (vc.axel1Pressure.value > 0) {
                                      vc.axel1Pressure.value--;
                                    }
                                  },
                                ),
                              ),
                              Obx(
                                () => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),

                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "${vc.axel1Pressure.value} PSI",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(color: Colors.red),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    vc.axel1Pressure.value++;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Axel 2
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          const Text("Recommended Pressure for Axel 2"),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(color: Colors.red),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (vc.axel2Pressure.value > 0) {
                                      vc.axel2Pressure.value--;
                                    }
                                  },
                                ),
                              ),
                              Obx(
                                () => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "${vc.axel2Pressure.value} PSI",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(color: Colors.red),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    vc.axel2Pressure.value++;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            /// SUBMIT
            InkWell(
              onTap: vc.submitForm,
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.buttonDanger,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.buttonDanger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iosOptionTile({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: selected ? Colors.red : Colors.black,
              ),
            ),
            const Spacer(),
            if (selected) const Icon(Icons.check, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  /// ---------- HELPERS ----------

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Row(
      children: [
        Text(text),
        const Text(" *", style: TextStyle(color: Colors.red)),
      ],
    ),
  );

  Widget searchableDialogField({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required List<String> items,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: controller,
      decoration: InputDecoration(
        hintText: title,
        border: const OutlineInputBorder(),
        suffixIcon: enabled
            ? IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: onTap,
              )
            : null,
      ),
    );
  }

  void _openFullScreenDialog({
    required BuildContext context,
    required String title,
    required RxString selectedValue,
    required List<String> items,
    required Function(String) onSelect,
  }) {
    final RxList<String> filteredList = items.obs;
    final TextEditingController searchCtrl = TextEditingController();

    Get.dialog(
      Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  filteredList.value = items
                      .where((e) => e.toLowerCase().contains(v.toLowerCase()))
                      .toList();
                },
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (_, index) {
                    final item = filteredList[index];
                    final isSelected = item == selectedValue.value;
                    return ListTile(
                      title: Row(
                        children: [
                          Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.red : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Colors.red,
                              size: 20,
                            ),
                        ],
                      ),

                      onTap: () {
                        selectedValue.value = item;
                        onSelect(item);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: ButtonStyle(
                    side: WidgetStateProperty.all(
                      const BorderSide(
                        color: Colors.red, // Border color
                        width: 2, // Border width
                      ),
                    ),

                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Border radius
                      ),
                    ),
                  ),

                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}

////=====================================
class AxleTyreLayout extends StatelessWidget {
  const AxleTyreLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: w * 0.6,
        height: 420, // ✅ FIXED HEIGHT (VERY IMPORTANT)
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// L R HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "L",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  "R",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// AXLE BODY
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// CENTER SHAFT
                  Column(
                    children: [
                      _connectorCircle("1"),
                      _verticalLine(),
                      _connectorCircle("2"),
                    ],
                  ),

                  /// TYRES
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [_AxleRow(), _AxleRow()],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _connectorCircle(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _verticalLine() {
    return Expanded(
      child: Container(
        width: 6,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// AXLE ROW
class _AxleRow extends StatelessWidget {
  const _AxleRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [_TyreBox(), _TyreBox()],
    );
  }
}

/// TYRE
class _TyreBox extends StatelessWidget {
  const _TyreBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      alignment: Alignment.center,
      child: const Text(
        "No\nTire\nInstalled",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
