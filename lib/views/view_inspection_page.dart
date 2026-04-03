import 'package:emtrack/color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inspection_controller.dart';

class ViewInspectionPage extends StatelessWidget {
  const ViewInspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InspectionController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'View Inspection',
          style: TextStyle(color: AppColors.textWhite),
        ),
        centerTitle: true,
        bottom: TabBar(
          padding: EdgeInsets.all(16),
          labelPadding: EdgeInsets.zero,
          controller: controller.tabController,

          tabs: [
            _tabUI(title: 'Unsynced', index: 0, controller: controller),
            _tabUI(title: 'Synced', index: 1, controller: controller),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          inspectionList(controller.unsyncedList),
          inspectionList(controller.syncedList),
        ],
      ),
    );
  }

  Widget inspectionList(List list) {
    return Obx(() {
      if (list.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder_open, size: 100, color: Colors.black),
            SizedBox(height: 12),
            Text('No Data To Display', style: TextStyle(fontSize: 18)),
          ],
        );
      }

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final item = list[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(item.vehicleNo),
              subtitle: Text('ID: ${item.id}'),
            ),
          );
        },
      );
    });
  }

  Widget _tabUI({
    required String title,
    required int index,
    required InspectionController controller,
  }) {
    return AnimatedBuilder(
      animation: controller.tabController,
      builder: (_, __) {
        final isSelected = controller.tabController.index == index;

        return Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors
                      .buttonDanger // 🔴 selected
                : Colors.white, // ⚪ unselected
            borderRadius: BorderRadius.circular(0),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
