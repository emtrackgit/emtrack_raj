import 'package:emtrack/color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/password_reset_controller.dart';

class ResetPasswordView extends StatelessWidget {
  ResetPasswordView({super.key});

  final c = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Reset Password", style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              stepHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => c.currentStep.value == 0 ? _stepOne() : _stepTwo(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STEP 1 =================

  Widget _stepOne() {
    return Form(
      key: c.formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "For security purposes, please input your username and password to proceed.",
            style: TextStyle(color: AppColors.textBlack),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: c.usernameController,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: InputDecoration(
              labelText: "Username",
              labelStyle: TextStyle(color: AppColors.textBlack),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            validator: (v) => v == null || v.isEmpty ? "Enter username" : null,
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: c.passwordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: InputDecoration(
              labelText: "Password (optional)",
              labelStyle: TextStyle(color: AppColors.textBlack),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: Get.back,
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: AppColors.buttonDanger),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDanger, foregroundColor: AppColors.textWhite),
                onPressed: c.sendtokenPassword,
                child: const Text("SUBMIT"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STEP 2 =================

  Widget _stepTwo() {
    return Form(
      key: c.formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "A unique token has been sent to your email. Please enter it below:",
            style: TextStyle(color: AppColors.textBlack),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: c.tokenController,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: InputDecoration(
              labelText: "Token Code",
              labelStyle: TextStyle(color: AppColors.textBlack),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            validator: (v) => v == null || v.isEmpty ? "Enter token" : null,
          ),

          const SizedBox(height: 20),

          Text(
            "Password must be at least 6 characters with uppercase, lowercase and special character.",
            style: TextStyle(fontSize: 13, color: AppColors.textBlack),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: c.newPasswordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: InputDecoration(
              labelText: "New Password",
              labelStyle: TextStyle(color: AppColors.textBlack),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            validator: (v) {
              if (v == null || v.length < 6) {
                return "Minimum 6 characters";
              }
              return null;
            },
          ),

          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: c.goBack,
                child: const Text("BACK", style: TextStyle(color: AppColors.buttonDanger)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDanger, foregroundColor: AppColors.textWhite),
                onPressed: c.resetPassword,
                child: const Text("RESET PASSWORD"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget stepHeader() {
    final c = Get.find<ResetPasswordController>();

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            _stepCircle(0, "Verify Account", c),
            _stepLine(0, c),
            _stepCircle(1, "Reset Password", c),
          ],
        ),
      ),
    );
  }

  Widget _stepCircle(int step, String title, ResetPasswordController c) {
    bool isActive = c.currentStep.value == step;
    bool isCompleted = c.currentStep.value > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.success
                  : isActive
                  ? AppColors.buttonDanger
                  : Colors.grey.shade300,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      "${step + 1}",
                      style: TextStyle(
                        color: isActive ? AppColors.textWhite : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.buttonDanger : AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(int step, ResetPasswordController c) {
    return Expanded(
      child: Container(
        height: 2,
        color: c.currentStep.value > step ? AppColors.success : Colors.grey.shade300,
      ),
    );
  }
}
