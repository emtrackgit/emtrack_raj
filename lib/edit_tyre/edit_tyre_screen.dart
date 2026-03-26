import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/edit_tyre/edit_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_custom_stepper_header.dart';
import 'step1_view.dart';
import 'step2_view.dart';
import 'step3_view.dart';
import 'step4_view.dart';

class EditTyreScreen extends StatelessWidget {
  EditTyreScreen({super.key});
  final c = Get.put(EditTyreController());
  final selectedCtrl = Get.put(SelectedAccountController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit New Tire",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: c.formKey,
            child: Obx(
              () => SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 11),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: const Text("Select parent account & Location"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "${selectedCtrl.parentAccountName.value} - ${selectedCtrl.locationName.value}",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    EditCustomStepperHeader(),
                    Obx(() {
                      switch (c.currentStep.value) {
                        case 0:
                          return Step1View(key: const ValueKey(0));
                        case 1:
                          return Step2View(key: const ValueKey(1));
                        case 2:
                          return Step3View(key: const ValueKey(2));
                        case 3:
                          return Step4View(key: const ValueKey(3));
                        default:
                          return const SizedBox();
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
