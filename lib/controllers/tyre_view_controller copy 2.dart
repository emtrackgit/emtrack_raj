import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tyre_view_model.dart';
import '../services/tyre_view_service.dart';
import '../utils/secure_storage.dart';

class TyreViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TyreViewService _service = TyreViewService();

  RxBool isLoading = true.obs;
  Rx<TyreViewModel?> tyre = Rx<TyreViewModel?>(null);

  late final TabController tabController;
  static late final int tireId; // 🔹 received id

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tireId = Get.arguments as int;
    fetchTyre(tireId); // 🔹 Example tyreId, pass dynamically if needed
  }

  Future<void> fetchTyre(int tireId) async {
    isLoading.value = true;

    try {
      final t = await _service.fetchTyreDetailsById(tireId);
      tyre.value = t;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getParentAccountName() async {
    final name = await SecureStorage.getParentAccountName();
    final id = await SecureStorage.getParentAccountId();
    if (name != null && id != null) {
      return "$name - $id";
    }
    return "NA";
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
