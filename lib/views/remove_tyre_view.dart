import 'package:emtrack/controllers/remove_tyre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemoveTyreView extends StatelessWidget {
  RemoveTyreView({super.key});

  final controller = Get.put(RemoveTyreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Remove Tyre", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.submit,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final m = controller.model.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Update Disposition
                const Text("Update Disposition *"),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    hintText: "Select",
                    border: OutlineInputBorder(),
                  ),
                  items: controller.dispositions
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.dispositionId,
                          child: Text(d.dispositionName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      final selected = controller.dispositions.firstWhere(
                        (d) => d.dispositionId == v,
                      );
                      controller.selectDisposition(selected);
                    }
                  },
                  initialValue: m.dispositionId == 0 ? null : m.dispositionId,
                ),

                const SizedBox(height: 16),

                // 🔹 Removal Reason
                const Text("Removal Reason"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.reasonController,
                  readOnly: true,
                  onTap: () {
                    controller.showReasonDropdown.toggle();
                  },
                  decoration: const InputDecoration(
                    hintText: "Search Tyre Removal Reason",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),

                // 🔽 SEARCHABLE DROPDOWN
                Obx(() {
                  if (!controller.showReasonDropdown.value)
                    return const SizedBox();

                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: controller.filteredReasons.length,
                      itemBuilder: (_, i) {
                        final item = controller.filteredReasons[i];
                        return ListTile(
                          title: Text(item.reasonName),
                          onTap: () => controller.selectReason(item),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // 🔹 Comments
                const Text("Comments"),
                const SizedBox(height: 6),
                TextField(
                  maxLength: 200,
                  maxLines: 3,
                  onChanged: (v) =>
                      controller.model.update((m) => m!.comments = v),
                  decoration: const InputDecoration(
                    hintText: "Comments go here. (Max 200 characters)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 120),
              ],
            );
          }),
        ),
      ),
    );
  }
}
