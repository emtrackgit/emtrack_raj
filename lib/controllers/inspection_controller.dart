import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/inspection_model.dart';
import '../services/inspection_service.dart';

class InspectionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final InspectionService service = InspectionService();

  late TabController tabController;
  var unsyncedList = <InspectionModel>[].obs;
  var syncedList = <InspectionModel>[].obs;
  RxInt currentIndex = 0.obs;
  @override
  void onInit() {
    super.onInit();

    int initialIndex = Get.arguments ?? 0;

    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    fetchData();
  }

  void fetchData() async {
    final data = await service.getInspections();

    unsyncedList.value = data.where((e) => !e.isSynced).toList();

    syncedList.value = data.where((e) => e.isSynced).toList();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
