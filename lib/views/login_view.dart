import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/models/user_models.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/validators.dart';

class LoginView extends StatelessWidget {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final auth = Get.put(AuthController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // TOP logos
            Positioned(
              top: h * 0.07,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png"),
                  SizedBox(height: 15),
                  Image.asset("assets/images/logo-emtrack.png", width: 140),
                  SizedBox(height: 5),
                  Text(
                    "Mobile",
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // CENTER login card
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // USERNAME
                      TextFormField(
                        controller: _userCtrl,
                        validator: Validators.validateUsername,
                        decoration: InputDecoration(
                          hintText: "Username",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),

                      // PASSWORD
                      Obx(
                        () => TextFormField(
                          controller: _passCtrl,
                          obscureText: !auth.showPassword.value,
                          validator: Validators.validatePassword,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: UnderlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                auth.showPassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                auth.showPassword.toggle();
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // Password reset text
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppPages.PASSWORD_RESET);
                        },
                        child: Text(
                          "Password\nReset",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textBlack),
                        ),
                      ),

                      SizedBox(height: 20),

                      // LOGIN BUTTON (UPDATED)
                      Obx(
                        () => InkWell(
                          onTap: auth.isLoading.value
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate())
                                    return;

                                  // 1️⃣ Call login → returns UserModel?
                                  final UserModel? user = await auth.login(
                                    _userCtrl.text.trim(),
                                    _passCtrl.text.trim(),
                                  );

                                  // 2️⃣ Convert to bool for snackbar
                                  final bool success = user != null;

                                  // 3️⃣ Show snackbar
                                  Get.snackbar(
                                    success ? "Login Success" : "Login Failed",
                                    success
                                        ? "You are logged in successfully"
                                        : auth.errorMessage.value,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.black,
                                    colorText: Colors.white,
                                  );
                                },
                          child: auth.isLoading.value
                              ? const CircularProgressIndicator()
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red, // 🔴 UI COLOR SAME
                                  ),
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FOOTER TEXTS
            Positioned(
              bottom: h * 0.12,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    "Tire inspections made easy",
                    style: TextStyle(color: AppColors.textWhite),
                  ),
                  SizedBox(height: 12),
                  const AnimatedFooterTexts(),
                ],
              ),
            ),

            // COPYRIGHT
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "@2025 The Yokohama Rubber Co.Ltd.",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedFooterTexts extends StatefulWidget {
  const AnimatedFooterTexts({super.key});

  @override
  State<AnimatedFooterTexts> createState() => _AnimatedFooterTextsState();
}

class _AnimatedFooterTextsState extends State<AnimatedFooterTexts> {
  double op1 = 0;
  double op2 = 0;
  double op3 = 0;

  @override
  void initState() {
    super.initState();

    // One-by-one fade-in animation
    Future.delayed(Duration(milliseconds: 300), () => setState(() => op1 = 1));
    Future.delayed(Duration(milliseconds: 900), () => setState(() => op2 = 1));
    Future.delayed(Duration(milliseconds: 1500), () => setState(() => op3 = 1));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: op1,
          child: _BottomText("Inspect."),
        ),
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: op2,
          child: _BottomText("Update."),
        ),
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: op3,
          child: _BottomText("Done."),
        ),
      ],
    );
  }
}

class _BottomText extends StatelessWidget {
  final String text;
  const _BottomText(this.text);

  @override
  Widget build(BuildContext context) {
    // Split text into word + dot
    final word = text.replaceAll(".", "");
    final dot = ".";

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: word,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          TextSpan(
            text: dot,
            style: TextStyle(
              color: Colors.yellow, // DOT becomes yellow
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}
