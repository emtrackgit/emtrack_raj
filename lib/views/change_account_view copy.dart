import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/models/change_account_model.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/change_account_controller.dart';

class ChangeAccountView extends StatelessWidget {
  final ctrl = Get.put(ChangeAccountController());

  ChangeAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          "Change Account/Location",
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Change your parent account and locations here and click on select or click cancel",
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),

                /// RADIO BUTTONS
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _roundCheckBox(
                          label: "Own",
                          value: ctrl.ownSelected,
                          onChanged: (v) async {
                            ctrl.ownSelected.value = v;
                            await SecureStorage.saveBool('own_selected', v);
                          },
                        ),
                        const SizedBox(width: 80),
                        _roundCheckBox(
                          label: "Shared",
                          value: ctrl.sharedSelected,
                          onChanged: (v) async {
                            ctrl.sharedSelected.value = v;
                            await SecureStorage.saveBool('shared_selected', v);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// PARENT ACCOUNT DROPDOWN
                const Text("Parent Account:"),
                DropdownButtonFormField<ParentAccountModel>(
                  initialValue: ctrl.selectedAccount.value,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconEnabledColor: AppColors.buttonDanger,
                  hint: const Text("Select Parent Account"),
                  items: ctrl.accounts
                      .map(
                        (e) => DropdownMenuItem<ParentAccountModel>(
                          value: e,
                          child: Text(
                            e.accountName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: ctrl.onAccountChanged,
                  decoration: _dropdownDecoration(),
                ),

                const SizedBox(height: 16),

                /// LOCATION DROPDOWN (FIXED ❗)
                const Text("Location:"),
                DropdownButtonFormField<LocationModel>(
                  initialValue: ctrl.selectedLocation.value,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconEnabledColor: AppColors.buttonDanger,
                  hint: const Text("Select Location"),
                  items: ctrl.locations
                      .map(
                        (e) => DropdownMenuItem<LocationModel>(
                          value: e,
                          child: Text(
                            e.locationName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => ctrl.selectedLocation.value = v,
                  decoration: _dropdownDecoration(),
                ),

                const SizedBox(height: 24),

                /// SELECT BUTTON
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.buttonDanger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: ctrl.submit,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          "Select",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _roundCheckBox({
    required String label,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(!value.value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value.value,
              onChanged: (v) => onChanged(v!),
              shape: const CircleBorder(), // 🔥 ROUND CHECKBOX
              activeColor: Colors.black,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// COMMON DROPDOWN BORDER
  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    );
  }
}
