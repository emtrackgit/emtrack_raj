import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/preferences_controller.dart';
import 'package:emtrack/models/country/country_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreferencesView extends GetView<PreferencesController> {
  PreferencesView({super.key});

  @override
  final PreferencesController controller = Get.put(PreferencesController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text("Preferences", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _selector(
              title: "Language",
              value: controller.selectedLanguage,
              items: controller.languages,
              onSelect: controller.updateLanguage,
            ),
            SizedBox(height: 11),
            _selector(
              title: "Measurement",
              value: controller.selectedMeasurement,
              items: controller.measurementSystems,
              onSelect: controller.updateMeasurement,
            ),
            SizedBox(height: 11),
            _selector(
              title: "Pressure",
              value: controller.selectedPressure,
              items: controller.pressureUnits,
              onSelect: controller.updatePressure,
            ),
            const SizedBox(height: 30),
            _primaryButton(text: "Update", onTap: controller.updatePre),
            const SizedBox(height: 12),
            _secondaryButton(
              text: "Cancel",
              onTap: controller.cancelPreferences,
            ),
          ],
        ),
      ),
    );
  }

  Widget _countrySelector({
    required String title,
    required Rx<CountryModel?> value,
    required RxList<CountryModel> items,
  }) {
    final RxString searchText = ''.obs;
    final TextEditingController searchController = TextEditingController();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(value.value?.countryName ?? 'Select Country'),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: items.isEmpty
              ? null
              : () {
                  searchText.value = '';
                  searchController.clear();

                  Get.dialog(
                    Dialog(
                      insetPadding: EdgeInsets.zero,
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(title),
                          leading: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: Get.back,
                          ),
                        ),
                        body: Column(
                          children: [
                            // 🔍 SEARCH
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: TextFormField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Search country',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (v) =>
                                    searchText.value = v.toLowerCase(),
                              ),
                            ),

                            // 📜 LIST
                            Expanded(
                              child: Obx(() {
                                final filteredList = items.where((c) {
                                  final name =
                                      c.countryName?.toLowerCase() ?? '';
                                  return name.contains(searchText.value);
                                }).toList();

                                return ListView.builder(
                                  itemCount: filteredList.length,
                                  itemBuilder: (_, index) {
                                    final country = filteredList[index];

                                    return ListTile(
                                      title: Text(country.countryName ?? ''),
                                      trailing:
                                          value.value?.countryId ==
                                              country.countryId
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : null,
                                      onTap: () {
                                        value.value = country; // ✅ SAVE
                                        Get.back(); // ✅ CLOSE
                                      },
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
        ),
      ),
    );
  }

  Widget _selector({
    required String title,
    required RxString value,
    required List<String> items,
    required Function(String) onSelect,
  }) {
    final RxString tempValue = ''.obs;

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(value.value.isEmpty ? 'Select' : value.value),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () {
            tempValue.value = value.value;

            Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ), // ✅ border below title
                  ],
                ),

                /// ⭐ FIXED HEIGHT + SCROLL
                content: SizedBox(
                  height: 250, // ⭐ you can adjust
                  width: Get.width * .8,
                  child: ListView.builder(
                    itemCount: items.length,
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      final e = items[i];
                      return Obx(
                        () => ListTile(
                          dense: true,
                          title: Text(e),
                          trailing: tempValue.value == e
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            tempValue.value = e;
                          },
                        ),
                      );
                    },
                  ),
                ),

                // content: Obx(
                //   () => Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: items.map((e) {
                //       return ListTile(
                //         minTileHeight: 25,
                //         title: Text(e),
                //         trailing: tempValue.value == e
                //             ? const Icon(Icons.check, color: Colors.green)
                //             : null,
                //         onTap: () {
                //           tempValue.value = e;
                //         },
                //       );
                //     }).toList(),
                //   ),
                // ),
                actionsPadding: EdgeInsets.zero,
                actions: [
                  const Divider(
                    height: 1,
                    thickness: 1,
                  ), // ✅ top border above buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back(); // ❌ Cancel → no change
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      Container(width: 1, height: 48, color: Colors.grey),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            onSelect(tempValue.value); // ✅ OK → apply
                            Get.back();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                          child: const Text('OK'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          },
        ),
      ),
    );
  }

  Widget _primaryButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // 🔴 Button color
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ), // ⚪ Text color
        ),
        child: Text(text),
      ),
    );
  }

  Widget _secondaryButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Colors.red, // 🔴 border color
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}
