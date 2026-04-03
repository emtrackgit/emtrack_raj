import 'package:emtrack/user_management/user_management_model.dart';
import 'package:emtrack/user_management/user_management_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/country/country_model.dart';

class UserManagementController extends GetxController {
  final _service = UserManagementService();

  RxBool isLoading = false.obs;

  /// Stepper
  RxInt currentStep = 0.obs;
  final int totalSteps = 3;

  /// 🔹 Form Keys
  final formKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();
  final personalFormKey = GlobalKey<FormState>();
  final preferenceFormKey = GlobalKey<FormState>();

  final firstNameFocus = FocusNode();
  final middleNameFocus = FocusNode();

  /// 🔹 Text Controllers (DATA SAFE RAHEGA)
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  final firstNameC = TextEditingController();
  final middleNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();

  /// Login Info
  RxString username = ''.obs;
  RxString password = ''.obs;
  RxString role = ''.obs;

  /// Personal Details
  RxString firstName = ''.obs;
  RxString middleName = ''.obs;
  RxString lastName = ''.obs;
  RxString email = ''.obs;
  RxString phone = ''.obs;
  RxString country = ''.obs;

  /// Preferences
  RxString language = ''.obs;
  RxString measurement = ''.obs;
  RxString pressureUnit = ''.obs;

  /// Dropdown Data
  List<String> roles = <String>[].obs;
  RxList<String> countries = <String>[].obs;
  List<String> languages = ['English', 'Hindi'];
  List<String> measurements = ['Metric', 'Imperial'];
  List<String> pressureUnits = ['PSI', 'KPA', 'BAR'];

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await loadRoles();
    await loadCountries();
  }

  /// Navigation
  void next() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }
  void previous() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Submit
  Future<void> submit() async {
    isLoading.value = true;
    final formState = preferenceFormKey.currentState;

    if (formState == null) {
      Get.snackbar("Error", "Form not ready");
      return;
    }

    if (!formState.validate()) return;

    final model = UserManagementModel(
      username: usernameC.text,
      password: passwordC.text,
      role: role.value,
      firstName: firstNameC.text,
      middleName: middleNameC.text,
      lastName: lastNameC.text,
      email: emailC.text,
      phone: phoneC.text,
      country: country.value,
      language: language.value,
      measurement: measurement.value,
      pressureUnit: pressureUnit.value,
    );

    final result = await _service.registerUser(model);
    if (result) {
      isLoading.value = false;
    }

    // Get.snackbar("Success", "User Created Successfully");
  }

  Future<void> loadCountries() async {
    List<CountryModel> countryList = await _service.countryList();
    countries.assignAll(countryList.map((e) => e.countryName));
  }
  Future<void> loadRoles() async {
    List<String> rolelist = await _service.getUserRole();

    roles.assignAll(rolelist);
  }

  @override
  void onClose() {
    usernameC.dispose();
    passwordC.dispose();
    firstNameC.dispose();
    middleNameC.dispose();
    lastNameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    super.onClose();
  }
}
