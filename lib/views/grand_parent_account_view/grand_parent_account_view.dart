import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/grand_parent_account_controller/grand_parent_account_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GrandparentAccountView extends StatelessWidget {
  final c = Get.put(GrandparentAccountController());

  GrandparentAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: BackButton(color: Colors.white),
        title: Text(
          "GRANDPARENT ACCOUNT INFORMATION",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                _stepHeader(),
                Expanded(child: _stepBody()),
              ],
            ),
            if (c.isloading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// STEP HEADER
  Widget _stepHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle(0, "create account"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.chevron_right,
              color: c.currentStep.value >= 1 ? Colors.green : Colors.grey,
              size: 32,
            ),
          ),
          _stepCircle(1, "assign account"),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String title) {
    final isCompleted = step < c.currentStep.value;
    final isCurrent = step == c.currentStep.value;

    Color color;
    Widget child;

    if (isCompleted) {
      color = Colors.green;
      child = const Icon(Icons.check, color: Colors.white);
    } else if (isCurrent) {
      color = Colors.yellow.shade700;
      child = Text("${step + 1}", style: const TextStyle(color: Colors.white));
    } else {
      color = Colors.grey;
      child = Text("${step + 1}", style: const TextStyle(color: Colors.white));
    }

    return Column(
      children: [
        CircleAvatar(radius: 18, backgroundColor: color, child: child),
        const SizedBox(height: 6),
        Text(title),
      ],
    );
  }

  /// BODY
  Widget _stepBody() {
    return c.currentStep.value == 0 ? _createAccount() : _assignAccount();
  }

  /// STEP-1 UI
  Widget _createAccount() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Create Grandparent Account",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextFormField(
            initialValue: "OWNED",
            readOnly: false,
            decoration: const InputDecoration(
              labelText: "Account Type",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            decoration: const InputDecoration(
              labelText: "Grandparent Account Name",
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => c.grandparentName.value = v,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _bottomButtons(
                  onNext: c.grandparentName.value.isEmpty
                      ? null
                      : c.createGrandparent,
                  nextText: "Save",
                ),
              ),
              SizedBox(width: 15),

              Expanded(
                child: _bottomButtons(onNext: c.next, nextText: "Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// STEP-2 UI
  Widget _assignAccount() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Parent Account",
                border: OutlineInputBorder(),
              ),
              items: c.parentAccounts
                  .map(
                    (e) => DropdownMenuItem(
                      value: e['id'],
                      child: Text("${e['id']} : ${e['name']}"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => c.selectedParentId.value = v as int? ?? 0,
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Grandparent Account",
                border: OutlineInputBorder(),
              ),
              items: c.grandparentAccounts
                  .map(
                    (e) => DropdownMenuItem(
                      value: e['id'],
                      child: Text("${e['id']} : ${e['name']}"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => c.selectedGrandparentId.value = v as int? ?? 0,
            ),

            const SizedBox(height: 20),

            _bottomButtons(
              onPrevious: c.previous,
              onNext: c.assignGrandparent,
              nextText: "ASSIGN",
            ),
          ],
        ),
      ),
    );
  }

  /// BUTTONS
  Widget _bottomButtons({
    VoidCallback? onPrevious,
    required VoidCallback? onNext,
    required String nextText,
  }) {
    return Row(
      children: [
        if (onPrevious != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "PREVIOUS",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        if (onPrevious != null) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey;
                }
                return Colors.red;
              }),
            ),
            //  ElevatedButton.styleFrom(

            //   backgroundColor: Colors.red,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            // ),
            child: Text(nextText, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
