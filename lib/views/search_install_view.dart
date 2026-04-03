import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/install_tyre_controller.dart';
import 'package:emtrack/controllers/search_install_tire_controller.dart';
import 'package:emtrack/create_tyre/create_tyre_screen.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/views/install_tyre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchInstallView extends StatelessWidget {
  final int vehicleId;
  final String vehicleNumber;
  final String wheelPosition;

  SearchInstallView({super.key})
      : vehicleId     = Get.arguments["vehicleId"],
        vehicleNumber = Get.arguments['vehicleNumber'],
        wheelPosition = Get.arguments["wheelPosition"];

  final SearchInstallTireController controller = Get.put(
    SearchInstallTireController(),
  );

  // ✅ Helper — InstallTyreController ko arguments ke saath navigate karo
  void _goToInstallView({
    required int tireId,
    required String serialNo,
  }) {
    // Purana controller delete karo taaki fresh onInit() chale
    if (Get.isRegistered<InstallTyreController>()) {
      Get.delete<InstallTyreController>(force: true);
    }

    // ✅ Arguments Set KARO — Get.toNamed ke saath
    Get.toNamed(
      AppPages.INSTALL_TYRE_VIEW,
      arguments: {
        "vehicleId":     vehicleId,
        "vehicleNumber": vehicleNumber,
        "wheelPosition": wheelPosition,
        "tireId":        tireId,
        "serialNo":      serialNo,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Search, Install",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          // ─── INFO CARD ───
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Vehicle ID:"),
                Text(
                  vehicleNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const Text("Wheel Position:", style: TextStyle(fontSize: 12)),
                Text(
                  wheelPosition,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // ─── SEARCH FIELD ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search Tyre from Inventory",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ─── TYRE LIST ───
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allTyres.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.visibleTyres.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: AppColors.primary),
                      SizedBox(height: 10),
                      Text(
                        'No Inventory Tyres Found',
                        style: TextStyle(fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.visibleTyres.length,
                itemBuilder: (_, i) {
                  final tyre = controller.visibleTyres[i];

                  return GestureDetector(
                    onTap: () {
                      // ✅ FIX: tireId aur serialNo tyre se lo
                      _goToInstallView(
                        tireId:   tyre.tireId ?? 0,
                        serialNo: tyre.tireSerialNo ?? '',
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          tyre.tireSerialNo ?? "-",
                          style: const TextStyle(
                            color: AppColors.buttonDanger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Size: ${tyre.sizeName ?? '-'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Status: ${tyre.tireStatusName ?? '-'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Tread Depth: ${tyre.averageTreadDepth ?? '-'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.settings,
                          color: AppColors.buttonDanger,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ─── FAB ───
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow.shade800,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => Get.to(() => CreateTyreScreen()),
          child: const Text(
            'Create New Tyre',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          backgroundColor: Colors.red.shade900,
          // FAB se manually kholne pe tireId=0 — search se select karna hoga
          onPressed: () => _goToInstallView(tireId: 0, serialNo: ''),
          child: const Icon(Icons.settings, color: Colors.yellow),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}