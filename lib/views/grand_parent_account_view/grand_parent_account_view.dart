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
    return Form(
      key: c.createFormKey,
      child: Padding(
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
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Account Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: "Grandparent Account Name",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Grandparent Account Name is required";
                }
                return null;
              },
              onChanged: (v) => c.grandparentName.value = v,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Obx(
                        () => _bottomButtons(
                      onNext: c.grandparentName.value.trim().isEmpty
                          ? null
                          : () {
                        if (c.createFormKey.currentState!.validate()) {
                          c.createGrandparent();
                        }
                      },
                      nextText: "Save",
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _bottomButtons(
                    onNext: c.next,
                    nextText: "Next",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignAccount() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Parent Account",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _openParentAccountDialog,
              child: _fakeDropdown(c.selectedParentName.value),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Grandparent Account",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _openGrandparentAccountDialog,
              child: _fakeDropdown(c.selectedGrandparentName.value),
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

  Widget _fakeDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  void _openParentAccountDialog() {
    final searchCtrl = TextEditingController();
    // ✅ Use RxList properly
    final RxList<Map<String, dynamic>> filtered = RxList<Map<String, dynamic>>(
      [],
    );
    filtered.assignAll(c.parentAccounts);

    Get.dialog(
      Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            "Select Parent Account",
            style: TextStyle(color: Colors.white, fontSize: 16),
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
                  hintText: "Filter Parent Account",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  filtered.assignAll(
                    c.parentAccounts
                        .where(
                          (e) => e['name'].toString().toLowerCase().contains(
                            v.toLowerCase(),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            Expanded(
              child: Obx(
                () => filtered.isEmpty
                    ? const Center(child: Text("No accounts found"))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          return ListTile(
                            title: Text(
                              "${item['id']} : ${item['name'].toString().toUpperCase()}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            onTap: () {
                              c.selectedParentId.value = item['id'];
                              c.selectedParentName.value = item['name'];
                              Get.back();
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _openGrandparentAccountDialog() {
    final searchCtrl = TextEditingController();
    // ✅ Use RxList properly
    final RxList<Map<String, dynamic>> filtered = RxList<Map<String, dynamic>>(
      [],
    );
    filtered.assignAll(c.grandparentAccounts);

    Get.dialog(
      Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            "Select Grandparent Account",
            style: TextStyle(color: Colors.white, fontSize: 16),
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
                  hintText: "Filter Grandparent Account",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  filtered.assignAll(
                    c.grandparentAccounts
                        .where(
                          (e) => e['name'].toString().toLowerCase().contains(
                            v.toLowerCase(),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            Expanded(
              child: Obx(
                () => filtered.isEmpty
                    ? const Center(child: Text("No accounts found"))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          return ListTile(
                            title: Text(
                              "${item['id']} : ${item['name'].toString().toUpperCase()}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            onTap: () {
                              c.selectedGrandparentId.value = item['id'];
                              c.selectedGrandparentName.value = item['name'];
                              Get.back();
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
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
