import 'package:emtrack/inspection_tyre_vehicle/inspect_tyre_view_get.dart';
import 'package:emtrack/inspection_tyre_vehicle/inspection_vehicle_tyre_controller.dart';
import 'package:emtrack/inspection_tyre_vehicle/vehicle_inspe_view_get_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InspectionVehicleTyreView extends StatelessWidget {
  const InspectionVehicleTyreView({super.key});

  @override
  Widget build(BuildContext context) {
    final InspectionVehicleTyreController controller = Get.put(
      InspectionVehicleTyreController(),
    );
    final List<InspectionStatus> dummyStatuses = [
      InspectionStatus.approved,
      InspectionStatus.rejected,
      InspectionStatus.pending,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Vehicle / Tire')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// MAIN SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => _openSearchDialog(controller),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Inspection Vehicle / Tire',
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
                    'Inspection Vehicles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  /// 🚗 VEHICLES
                  controller.recentVehicles.isEmpty &&
                          controller.lastSelectedVehicle.isEmpty
                      ? const Text('No vehicle selected')
                      : Column(
                          children:
                              (controller.recentVehicles.isNotEmpty
                                      ? controller.recentVehicles
                                      : [controller.lastSelectedVehicle.value])
                                  .map(
                                    (e) => _recentTile(
                                      title: e,
                                      onTap: () {
                                        Get.to(
                                          () => VehicleInspeViewGetData(
                                            status:
                                                controller.statusMap[e] ??
                                                InspectionStatus.pending,
                                          ),
                                        );
                                      },
                                      onRemove:
                                          controller.recentVehicles.contains(e)
                                          ? () => controller
                                                .removeRecentVehicle(e)
                                          : null, // ❌ remove hidden for last selected
                                    ),
                                  )
                                  .toList(),
                        ),

                  const SizedBox(height: 12),

                  const Text(
                    'Inspection Tires',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  /// 🛞 TYRES
                  controller.recentTyres.isEmpty &&
                          controller.lastSelectedTyre.isEmpty
                      ? const Text('No tyre selected')
                      : Column(
                          children:
                              (controller.recentTyres.isNotEmpty
                                      ? controller.recentTyres
                                      : [controller.lastSelectedTyre.value])
                                  .map(
                                    (e) => _recentTile(
                                      title: e,
                                      onTap: () {
                                        Get.to(
                                          () => InspectTyreViewGetData(
                                            status:
                                                controller.statusMap[e] ??
                                                InspectionStatus.pending,
                                          ),
                                        );
                                      },
                                      onRemove:
                                          controller.recentTyres.contains(e)
                                          ? () => controller.removeRecentTyre(e)
                                          : null,
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
    );
  }

  /// SEARCH DIALOG
  void _openSearchDialog(InspectionVehicleTyreController c) {
    c.clearSearch();
    c.switchTab(0);

    Get.dialog(
      Scaffold(
        appBar: AppBar(
          title: const Text('Search Inspection Vehicle / Tire'),
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
                    hintText: 'Search Inspection Vehicle / Tire',
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
                          final status =
                              c.statusMap[item] ?? InspectionStatus.pending;

                          Color color;
                          String label;

                          switch (status) {
                            case InspectionStatus.approved:
                              label = "Approved";
                              color = Colors.green;
                              break;
                            case InspectionStatus.rejected:
                              label = "Rejected";
                              color = Colors.red;
                              break;
                            default:
                              label = "Pending";
                              color = Colors.orange;
                          }

                          return InkWell(
                            onTap: () {
                              c.setCurrentItem(item);
                              c.selectItem(item);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ListTile(
                                title: Text(item),
                                trailing: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              /// ✅ TEXT + BUTTON (NOW GUARANTEED TO CHANGE)
            ],
          );
        }),
      ),
    );
  }

  /// TAB
  static Widget _tab(
    InspectionVehicleTyreController c,
    String title,
    int index,
  ) {
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

  /// BUTTON
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

  static Widget _recentTile({
    required String title,
    required VoidCallback? onRemove,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
