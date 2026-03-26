import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/controllers/update_hours_controller.dart';
import 'package:emtrack/utils/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateHoursView extends StatelessWidget {
  UpdateHoursView({super.key});
  final updatectrl = Get.put(UpdateHoursController());
  final UpdateHoursController updatectrl1 = Get.find<UpdateHoursController>();

  final selectedCtrl = Get.put(SelectedAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Update Hours",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _label("Selected parent account"),
              Text(
                "${selectedCtrl.parentAccountName.value} - ${selectedCtrl.locationName.value}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _label("Vehicle ID"),
              Obx(
                () => Text(
                  //    updatectrl.vehicleId.toString(),
                  updatectrl.vehicleNumber.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              _label("Last Recorded Date"),
              const SizedBox(height: 10),
              Obx(() => _disabledField(updatectrl.lastRecordedDate.toString())),
              const SizedBox(height: 20),
              _requiredLabel("Survey Date"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => updatectrl.pickSurveyDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: updatectrl.surveyDateController,

                    decoration: InputDecoration(
                      hintText: "Select Date",
                      suffixIcon: const Icon(
                        Icons.calendar_month,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade50,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label("Last Recorded Hours"),
              const SizedBox(height: 10),
              _disabledField(
                updatectrl.lastRecordedHours.value.toStringAsFixed(2),
              ),
              const SizedBox(height: 20),
              _requiredLabel("Update hours"),
              const SizedBox(height: 10),
              Obx(
                () => TextField(
                  controller: updatectrl1.updateHoursController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    (v) {
                      updatectrl.updateHoursError.value = updatectrl
                          .validateHours();
                    };
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Hours",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade50,
                        width: 1,
                      ),
                    ),
                    errorText: updatectrl.updateHoursError.value,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.buttonDanger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: updatectrl.loading.value
                        ? null
                        : () {
                            final err = updatectrl.validateHours();
                            updatectrl.updateHoursError.value = err;

                            if (err != null) return;
                            FocusManager.instance.primaryFocus?.unfocus();

                            AppDialog.showConfirmDialog(
                              title: 'Change Tire Details',
                              message:
                                  'These changes will impact tire hours. \n Do you wish to proceed?',
                              okText: 'Proceed',
                              cancelText: 'Cancel',

                              onOk: () {
                                updatectrl.submitUpdateHours();
                              },
                            );
                            //  _showConfirmDialog(context);
                          },
                    child: Center(
                      child: updatectrl.loading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Center(
            child: Text(
              "Change Tire Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: const Text(
            "These changes will impact tire hours.\nDo you wish to proceed?",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                /// 🔥 Call your API here
                updatectrl.submitUpdateHours();
              },
              child: const Text(
                "Proceed",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _label(String text) =>
      Text(text, style: const TextStyle(color: Colors.black54));

  Widget _requiredLabel(String text) => RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(color: Colors.black),
      children: const [
        TextSpan(
          text: " *",
          style: TextStyle(color: Colors.red),
        ),
      ],
    ),
  );

  //   bool validateHours() {
  //   double lastHours = updatectrl.lastRecordedHours.value;

  //   double enteredHours =
  //       double.tryParse(updatectrl1.updateHoursController.text) ?? 0;

  //   if (enteredHours <= lastHours) {
  //     Get.snackbar(
  //       "Validation",
  //       "Please enter a value greater than last recorded hours",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     return false;
  //   }

  //   return true;
  // }

  Widget _disabledField([String? value]) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Text(value ?? "", style: const TextStyle(color: Colors.black54)),
      ],
    ),
  );
}
