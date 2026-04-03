import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/user_management/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==================== user_management_view.dart ====================

import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/user_management/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UserManagementController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("User", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Obx(
            () => Column(
          children: [
            _stepHeader(c),
            Expanded(child: _stepBody(c)),
          ],
        ),
      ),
    );
  }

  // ================= STEP BODY =================

  Widget _stepBody(UserManagementController c) {
    switch (c.currentStep.value) {
      case 0:
        return _loginInfo(c);
      case 1:
        return _personalDetail(c);
      default:
        return _preferences(c);
    }
  }

  // ================= STEP 1: LOGIN INFO =================

  Widget _loginInfo(UserManagementController c) {
    return Form(
      key: c.loginFormKey,
      child: _form(c, [
        _text(
          "Username",
          c.usernameC,
          validator: (v) {
            final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{3,19}$');
            if (v == null || v.isEmpty) return "Username required";
            if (!regex.hasMatch(v)) return "Invalid username";
            return null;
          },
        ),
        _text(
          "Password",
          c.passwordC,
          obscure: true,
          validator: (v) {
            if (v == null || v.isEmpty) return "Password required";
            if (v.length < 6) return "Min 6 characters";
            return null;
          },
        ),
        _dropdown(c, "User Role", c.roles, c.role),
      ]),
    );
  }

  // ================= STEP 2: PERSONAL DETAIL =================

  Widget _personalDetail(UserManagementController c) {
    final nameRegex = RegExp(r'^[A-Za-z ]{2,}$');

    return Form(
      key: c.personalFormKey,
      child: _form(c, [
        _text(
          "First Name",
          c.firstNameC,
          focusNode: c.firstNameFocus,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "First name required";
            if (!nameRegex.hasMatch(v)) return "Invalid first name";
            return null;
          },
        ),
        _text(
          "Middle Name",
          c.middleNameC,
          focusNode: c.middleNameFocus,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Middle name required";
            if (!nameRegex.hasMatch(v)) return "Invalid middle name";
            return null;
          },
        ),
        _text(
          "Last Name",
          c.lastNameC,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Last name required";
            if (!nameRegex.hasMatch(v)) return "Invalid last name";
            return null;
          },
        ),
        _text(
          "Email",
          c.emailC,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Email required";
            final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
            if (!regex.hasMatch(v)) return "Invalid email";
            return null;
          },
        ),
        _text(
          "Phone",
          c.phoneC,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Phone required";
            final regex = RegExp(r'^[6-9]\d{9}$');
            if (!regex.hasMatch(v)) return "Invalid phone";
            return null;
          },
        ),
        _dropdown(c, "Country", c.countries, c.country),
      ]),
    );
  }

  // ================= STEP 3: PREFERENCES =================

  Widget _preferences(UserManagementController c) {
    return Form(
      key: c.preferenceFormKey,
      child: _form(c, [
        _dropdown(c, "Language", c.languages, c.language),
        _dropdown(c, "Measurement", c.measurements, c.measurement),
        _dropdown(c, "Pressure Unit", c.pressureUnits, c.pressureUnit),
      ]),
    );
  }

  // ================= COMMON FORM WRAPPER =================

  Widget _form(UserManagementController c, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [...children, const SizedBox(height: 20), _buttons(c)],
      ),
    );
  }

  // ================= BUTTONS =================

  Widget _buttons(UserManagementController c) {
    return Row(
      children: [
        if (c.currentStep.value > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: c.previous,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5), // ✅ change color here
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text("PREVIOUS", style: TextStyle(color: AppColors.primary)), // ✅ match text color
            ),
          ),
        if (c.currentStep.value > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.focusScope?.unfocus();

              if (c.currentStep.value == 0) {
                if (c.loginFormKey.currentState!.validate()) {
                  c.next();
                }
              } else if (c.currentStep.value == 1) {
                if (c.personalFormKey.currentState!.validate()) {
                  c.next();
                }
              } else {
                if (c.preferenceFormKey.currentState!.validate()) {
                  c.submit();
                }
              }
            },
            child: Text(
              c.currentStep.value == 2 ? "CREATE" : "NEXT",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ================= TEXT FIELD =================

// ================= TEXT FIELD =================

  Widget _text(
      String label,
      TextEditingController controller, {
        bool obscure = false,
        FocusNode? focusNode,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
  // ================= DROPDOWN =================

  // Widget _dropdown(String label, List<String> items, RxString value) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12),
  //     child: Obx(
  //       () => DropdownButtonFormField<String>(
  //         value: value.value.isEmpty ? null : value.value,
  //         autovalidateMode: AutovalidateMode.onUserInteraction,
  //         decoration: InputDecoration(
  //           labelText: label,
  //           border: const OutlineInputBorder(),
  //         ),
  //         validator: (v) =>
  //             (v == null || v.isEmpty) ? "Please select $label" : null,
  //         items: items
  //             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //             .toList(),
  //         onChanged: (v) => value.value = v ?? "",
  //       ),
  //     ),
  //   );
  // }

  // ================= DROPDOWN =================

  Widget _dropdown(
      UserManagementController c,
      String label,
      List<String> items,
      RxString value,
      ) {
    final RxBool touched = false.obs;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(
            () => InkWell(
          onTap: () {
            touched.value = true;
            _openSelectionDialog(title: label, items: items, value: value);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: (touched.value && value.value.isEmpty)
                  ? "Please select $label"
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.value.isEmpty ? "Select $label" : value.value,
                  style: TextStyle(
                    color: value.value.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SELECTION DIALOG =================

  void _openSelectionDialog({
    required String title,
    required List<String> items,
    required RxString value,
  }) {
    final RxList<String> filteredList = items.obs;
    final RxString tempSelected = RxString(value.value);
    final TextEditingController searchCtrl = TextEditingController();

    Get.dialog(
      Scaffold(
        appBar: AppBar(
          title: Text("Select $title"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: Get.back,
          ),
          elevation: 1,
        ),
        body: Column(
          children: [
            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: "Search...",
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

            /// 📜 LIST
            Expanded(
              child: Obx(() {
                if (filteredList.isEmpty) {
                  return const Center(child: Text("No data found"));
                }
                return ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = filteredList[index];
                    return Obx(() {
                      final isSelected = tempSelected.value == item;
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            color: isSelected ? Colors.red : Colors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.red)
                            : null,
                        onTap: () => tempSelected.value = item,
                      );
                    });
                  },
                );
              }),
            ),

            /// 🔻 ACTION BAR
            Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: Get.back,
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 0.5, color: Colors.grey),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        value.value = tempSelected.value;
                        Get.back();
                      },
                      child: const Center(
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      ),
      barrierDismissible: false,
    );
  }

  // ================= STEP HEADER =================

  Widget _stepHeader(UserManagementController c) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _circle(c, 0, "Login"),
          _circle(c, 1, "Personal"),
          _circle(c, 2, "Preference"),
        ],
      ),
    );
  }

  Widget _circle(UserManagementController c, int step, String title) {
    final isDone = step < c.currentStep.value;
    final isCurrent = step == c.currentStep.value;

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isDone
              ? Colors.green
              : isCurrent
              ? Colors.red
              : Colors.grey,
          child: isDone
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
            "${step + 1}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }
}
// import 'package:emtrack/color/app_color.dart';
// import 'package:emtrack/user_management/user_management_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class UserManagementView extends StatelessWidget {
//   final c = Get.put(UserManagementController());
//   UserManagementView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         title: const Text("User", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         leading: BackButton(color: Colors.white),
//       ),
//       body: Stack(
//         children: [
//           Obx(
//             () => Column(
//               children: [
//                 _stepHeader(),
//                 Expanded(child: _stepBody()),
//               ],
//             ),
//           ),

//           Obx(() {
//             if (!c.isLoading.value) return const SizedBox();

//             return const Center(
//               child: CircularProgressIndicator(color: AppColors.secondary),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _stepHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _stepCircle(0, "login info"),
//           _stepCircle(1, "personal detail"),
//           _stepCircle(2, "user preference"),
//         ],
//       ),
//     );
//   }

//   Widget _stepCircle(int step, String title) {
//     final bool isCompleted = step < c.currentStep.value;
//     final bool isCurrent = step == c.currentStep.value;

//     Color circleColor;
//     Widget child;

//     if (isCompleted) {
//       circleColor = Colors.green;
//       child = const Icon(Icons.check, color: Colors.white, size: 18);
//     } else if (isCurrent) {
//       circleColor = Colors.yellow.shade900;
//       child = Text("${step + 1}", style: const TextStyle(color: Colors.white));
//     } else {
//       circleColor = Colors.grey;
//       child = Text("${step + 1}", style: const TextStyle(color: Colors.white));
//     }

//     return Row(
//       children: [
//         Column(
//           children: [
//             CircleAvatar(
//               radius: 18,
//               backgroundColor: circleColor,
//               child: child,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//                 color: isCompleted
//                     ? Colors.green
//                     : isCurrent
//                     ? Colors.yellow.shade900
//                     : Colors.grey,
//               ),
//             ),
//           ],
//         ),
//         _arrow(step),
//       ],
//     );
//   }

//   Widget _stepBody() {
//     switch (c.currentStep.value) {
//       case 0:
//         return _loginInfo();
//       case 1:
//         return _personalDetail();
//       default:
//         return _preferences();
//     }
//   }

//   Widget _loginInfo() {
//     return Form(
//       key: c.loginFormKey,
//       child: _form([
//         _text(
//           "Username",
//           c.usernameC,
//           validator: (v) {
//             final usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{3,19}$');

//             if (v == null || v.isEmpty) {
//               return "Username required";
//             }
//             if (!usernameRegex.hasMatch(v)) {
//               return "Invalid username";
//             }
//             return null;
//           },
//         ),

//         _text(
//           "Password",
//           c.passwordC,
//           obscure: true,
//           validator: (v) {
//             if (v == null || v.isEmpty) {
//               return "Password required";
//             }
//             if (v.length < 6) {
//               return "Min 6 characters";
//             }
//             return null;
//           },
//         ),

//         _dropdown("User Role", c.roles, c.role),
//       ]),
//     );
//   }

//   Widget _personalDetail() {
//     final nameRegex = RegExp(r'^[A-Za-z ]{2,}$');

//     return Form(
//       key: c.personalFormKey,
//       child: _form([
//         _text(
//           "First Name",
//           c.firstNameC,
//           focusNode: c.firstNameFocus,
//           validator: (v) {
//             if (v == null || v.trim().isEmpty) {
//               return "First name is required";
//             }
//             if (!nameRegex.hasMatch(v)) {
//               return "Invalid first name";
//             }

//             return null;
//           },
//         ),

//         _text(
//           "Middle Name",
//           c.middleNameC,
//           focusNode: c.middleNameFocus,
//           validator: (v) {
//             if (v == null || v.trim().isEmpty) {
//               return "Middle Name is required";
//             }
//             if (v.isNotEmpty && !nameRegex.hasMatch(v)) {
//               return "Invalid middle name";
//             }

//             return null;
//           },
//         ),

//         _text(
//           "Last Name",
//           c.lastNameC,
//           validator: (v) {
//             if (!nameRegex.hasMatch(v ?? "")) {
//               return "Invalid last name";
//             }
//             if (v == null || v.trim().isEmpty) {
//               return "LastName is required";
//             }
//             return null;
//           },
//         ),

//         _text(
//           "Email",
//           c.emailC,
//           validator: (v) {
//             if (v == null || v.trim().isEmpty) {
//               return "Email is required";
//             }
//             final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
//             if (!emailRegex.hasMatch(v)) {
//               return "Invalid email";
//             }

//             return null;
//           },
//         ),

//         _text(
//           "Phone",
//           c.phoneC,
//           validator: (v) {
//             if (v == null || v.trim().isEmpty) {
//               return "Phone number is required";
//             }
//             final phoneRegex = RegExp(r'^[6-9]\d{9}$');
//             if (!phoneRegex.hasMatch(v)) {
//               return "Invalid phone number";
//             }

//             return null;
//           },
//         ),

//         _dropdown("Country", c.countries, c.country),
//       ]),
//     );
//   }

//   Widget _preferences() {
//     return Form(
//       key: c.preferenceFormKey,
//       child: _form([
//         _dropdown("Language", c.languages, c.language),
//         _dropdown("Measurement", c.measurements, c.measurement),
//         _dropdown("Pressure Unit", c.pressureUnits, c.pressureUnit),
//       ]),
//     );
//   }

//   Widget _buttons() {
//     return Padding(
//       padding: const EdgeInsets.all(0),
//       child: Row(
//         children: [
//           /// 🔹 PREVIOUS
//           if (c.currentStep.value > 0)
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: c.previous,
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 48),
//                   side: const BorderSide(
//                     color: Colors.red, // 🔴 border color
//                     width: 1, // optional
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     // ✅ border radius 10
//                   ),
//                 ),
//                 child: const Text(
//                   "PREVIOUS",
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ),

//           if (c.currentStep.value > 0) const SizedBox(width: 12),

//           /// 🔹 NEXT / CREATE
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 if (c.formKey.currentState!.validate()) {
//                   c.currentStep.value == 2 ? c.submit() : c.next();
//                 }
//               },

//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 48),
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10), // ✅ border radius 10
//                 ),
//               ),
//               child: Text(
//                 c.currentStep.value == 2 ? "CREATE" : "NEXT",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _form(List<Widget> children) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: c.formKey,
//         child: ListView(
//           children: [...children, const SizedBox(height: 10), _buttons()],
//         ),
//       ),
//     );
//   }

//   Widget _text(
//     String label,
//     TextEditingController controller, {
//     bool obscure = false,
//     FocusNode? focusNode,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscure,
//         validator: validator,
//         focusNode: focusNode,
//         autofocus: false,
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Widget _dropdown(String label, List<String> items, RxString value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Obx(
//         () => DropdownButtonFormField<String>(
//           initialValue: value.value.isEmpty ? null : value.value,
//           decoration: InputDecoration(
//             labelText: label,
//             border: const OutlineInputBorder(),
//           ),

//           // ✅ VALIDATION
//           validator: (v) {
//             if (v == null || v.isEmpty) {
//               return 'Please select one';
//             }
//             return null;
//           },

//           items: items
//               .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
//               .toList(),

//           onChanged: (v) => value.value = v ?? '',
//         ),
//       ),
//     );
//   }

//   Widget _arrow(int step) {
//     if (step == c.totalSteps - 1) return const SizedBox();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Icon(
//         Icons.arrow_forward_ios,
//         size: 14,
//         color: step < c.currentStep.value ? Colors.green : Colors.grey,
//       ),
//     );
//   }
// }
