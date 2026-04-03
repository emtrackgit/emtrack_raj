import 'package:emtrack/create_tyre/create_tyre_screen.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/routes/app_pages.dart';

import 'package:emtrack/search_tyre_vehicle/search_vehicle_tyre_controller.dart';
import 'package:emtrack/search_tyre_vehicle/tire_item_model.dart';
import 'package:emtrack/search_tyre_vehicle/vehicle_item_model.dart';
import 'package:emtrack/views/create_vehicle_view.dart';
import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchVehicleTyreView extends StatelessWidget {
  const SearchVehicleTyreView({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchVehicleTyreController controller = Get.put(
      SearchVehicleTyreController(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Search Vehicle / Tire')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MAIN SEARCH BAR
            ///
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => _openSearchDialog(controller),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Vehicle / Tire',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Recent Search',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            /// RECENT LIST
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    controller.recentVehicles.isEmpty
                        ? const Text('No recent vehicle found')
                        : Column(
                            children: controller.recentVehicles
                                .map<Widget>(
                                  (VehicleItem e) => _recentTile(
                                    onTap: () => Get.to(
                                      () => VehicleInspeView(),
                                      arguments: e.vehicleId,
                                    ),
                                    title: e.vehicleId.toString(),
                                    onRemove: () async {
                                      final confirm = await confirmRemoveDialog(
                                        context,
                                        message:
                                            "Are you sure you want to remove this tyre Inspection?",
                                      );

                                      if (confirm == true) {
                                        controller.removeRecentVehicle(e);
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          ),

                    const SizedBox(height: 12),

                    const Text(
                      'Tires',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    controller.recentTyres.isEmpty
                        ? const Text('No recent tire found')
                        : Column(
                            children: controller.recentTyres
                                .map<Widget>(
                                  (TireItem e) => _recentTile(
                                    onTap: () {
                                      final installedTire = InstalledTire(
                                        tireId: e.tireId,
                                        tireSerialNo: e.tireSerialNo,
                                        wheelPosition: e.wheelPosition,
                                        // vehicleId: e.vehicleId,
                                        vehicleId: 0,
                                      );

                                      Get.to(() => InspectTyreView(), arguments: installedTire);
                                    },
                                    title: e.tireId.toString(),
                                    onRemove: () =>
                                        controller.removeRecentTyre(e),
                                  ),
                                )
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SEARCH DIALOG =================
  void _openSearchDialog(SearchVehicleTyreController c) {
    c.clearSearch();
    c.switchTab(0);

    Get.dialog(
      Scaffold(
        appBar: AppBar(
          title: const Text('Search Vehicle / Tire'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          return Column(
            children: [
              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: c.onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search Vehicle / Tire',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              /// TAB BAR
              Row(children: [_tab(c, 'VEHICLES', 0), _tab(c, 'TIRES', 1)]),

              /// LIST
              Expanded(
                child: c.visibleList.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.builder(
                        itemCount: c.visibleList.length,
                        itemBuilder: (_, i) {
                          final item = c.visibleList[i];
                          final title = c.selectedTab.value == 0
                              ? (item as VehicleItem).vehicleNumber.toString()
                              : (item as TireItem).tireSerialNo.toString();

                          /// ⭐ LAST ITEM → SHOW ACTION UI
                          if (i == c.visibleList.length - 1) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.selectedTab.value == 0
                                        ? "Couldn't find your Vehicles?"
                                        : "Couldn't find your Tires?",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  _actionButton(
                                    text: c.selectedTab.value == 0
                                        ? 'Create New Vehicle'
                                        : 'Create New Tire',
                                    onTap: () {
                                      if (c.selectedTab.value == 0) {
                                        Get.to(() => CreateVehicleView());
                                      } else {
                                        Get.toNamed(AppPages.CREATE_TYRE);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: ListTile(
                              title: Text(title),
                              onTap: () => c.selectItem(item),
                            ),
                          );
                        },
                      ),
              ),

              // /// ACTION BUTTON
              // Padding(
              //   padding: const EdgeInsets.all(12),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       if (c.selectedTab.value == 0) ...[
              //         const Text(
              //           "Couldn't find your Vehicles?",
              //           style: TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //         const SizedBox(height: 10),
              //         _actionButton(
              //           text: 'Create New Vehicle',
              //           onTap: () {
              //             Get.to(() => CreateVehicleView());
              //             debugPrint('Vehicle Create');
              //           },
              //         ),
              //       ],
              //       if (c.selectedTab.value == 1) ...[
              //         const Text(
              //           "Couldn't find your Tires?",
              //           style: TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //         const SizedBox(height: 10),
              //         _actionButton(
              //           text: 'Create New Tire',
              //           onTap: () {
              //             Get.to(() => CreateTyreScreen());
              //             debugPrint('Tire Create');
              //           },
              //         ),
              //       ],
              //     ],
              //   ),
              // ),
            ],
          );
        }),
      ),
    );
  }

  /// ================= TAB WIDGET =================
  static Widget _tab(SearchVehicleTyreController c, String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => c.switchTab(index),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: c.selectedTab.value == index
                    ? Colors.red
                    : Colors.grey.shade300,
                width: 4,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: c.selectedTab.value == index ? Colors.red : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= BUTTON =================
  static Widget _actionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= RECENT TILE =================
  Widget _recentTile({
    required String title,
    required VoidCallback onRemove,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 👇 ONLY this area is clickable
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(title, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),

          // 👇 remove button stays independent
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }




  Future<bool?> confirmRemoveDialog(
    BuildContext context, {
    String title = "Confirm remove",
    String message = "Are you sure you want to remove this item?",
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Text(message, style: const TextStyle(fontSize: 14)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "YES",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "NO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
