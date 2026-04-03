import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/change_account_controller.dart';
import 'package:emtrack/models/change_account_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeAccountView extends StatelessWidget {
  ChangeAccountView({super.key});

  final ctrl = Get.put(ChangeAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Change Account/Location",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change your parent account and location",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              /// 🔘 CHECKBOX ROW
              Row(
                children: [
                  _roundCheckbox("Own", ctrl.ownSelected),
                  const SizedBox(width: 50),
                  _roundCheckbox("Shared", ctrl.sharedSelected),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔽 PARENT ACCOUNT
              const Text("Parent Account"),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _openParentAccountDialog(),
                child: _fakeDropdown(
                  ctrl.selectedAccount.value?.accountName ??
                      "Select Parent Account",
                ),
              ),

              const SizedBox(height: 16),

              /// 📍 LOCATION
              const Text("Location"),
              const SizedBox(height: 6),
              InkWell(
                onTap: ctrl.selectedAccount.value == null
                    ? null
                    : () => _openLocationDialog(),
                child: _fakeDropdown(
                  ctrl.selectedLocation.value?.locationName ??
                      "Select Location",
                ),
              ),

              const SizedBox(height: 30),

              /// ✅ SELECT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonDanger,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: ctrl.submit,
                  child: const Text(
                    "Select",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: Get.back,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ===================== UI HELPERS =====================

  Widget _fakeDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _roundCheckbox(String label, RxBool value) {
    return Obx(() {
      return InkWell(
        onTap: () => value.value = !value.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value.value,
              shape: const CircleBorder(),
              activeColor: Colors.black,
              onChanged: (v) => value.value = v!,
            ),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    });
  }

  // ===================== DIALOGS =====================

  /// 🔽 PARENT ACCOUNT DIALOG
  void _openParentAccountDialog() {
    final searchCtrl = TextEditingController();
    List<ParentAccountModel> filtered = [...ctrl.accounts];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text(
                "Select Parent Account",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search account",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        filtered = ctrl.accounts
                            .where(
                              (e) => e.accountName.toLowerCase().contains(
                                v.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(item.accountName), Divider()],
                        ),
                        onTap: () async {
                          ctrl.onAccountChanged(item);
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  /// 📍 LOCATION DIALOG
  void _openLocationDialog() {
    final searchCtrl = TextEditingController();
    List<LocationModel> filtered = [...ctrl.locations];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text(
                "Select Location",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search location",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        filtered = ctrl.locations
                            .where(
                              (e) => e.locationName.toLowerCase().contains(
                                v.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(item.locationName), Divider()],
                        ),
                        onTap: () {
                          ctrl.selectedLocation.value = item;
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}
