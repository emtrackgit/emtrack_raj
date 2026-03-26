import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tyre_model.dart';
import '../services/tyre_service.dart';
import '../views/tyre_view.dart';

class AllTyreController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TyreService service = TyreService();

  TabController? tabController;

  /// 🔄 Loader
  final RxBool isLoading = false.obs;

  /// 📦 API data
  final RxList<TyreModel> allTyres = <TyreModel>[].obs;

  /// 👁 Filtered + searched data
  final RxList<TyreModel> visibleTyres = <TyreModel>[].obs;

  /// 🔍 Search text
  final RxString searchText = ''.obs;

  /// 🧭 Tabs (MATCH dispositionName from API)
  final List<String> tabs = [
    'All',
    'Installed',
    'Inventory',
    'On Hold',
    'Scrap',
    'Repair',
    'Retread',
  ];

  /// ✅ ACCOUNT ID (JSON me parentAccountId = 11855)
  final Future<String> parentAccountId = SecureStorage.getParentAccountId()
      .then((value) => value!);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);

    /// 🚀 FIRST LOAD

    fetchData(tabs[0]);

    /// 🔁 Tab change
    tabController!.addListener(() {
      if (!tabController!.indexIsChanging) {
        searchText.value = '';
        _applyTabFilter(tabs[tabController!.index]);
      }
    });
  }

  // ==================================================
  // 📡 FETCH DATA FROM API
  // ==================================================
  Future<void> fetchData(String tab) async {
    try {
      isLoading.value = true;

      // 🔹 Always read from SecureStorage (source of truth)
      final String? parentAccountId = await SecureStorage.getParentAccountId();

      print("🔵 FETCH DATA | TAB => $tab");
      print("🔵 ACCOUNT ID => $parentAccountId");

      // ❗ Safety check
      if (parentAccountId == null || parentAccountId.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar("Error", "Parent account not selected");
        });
        isLoading.value = false;
        return;
      }

      /// 🔥 API CALL
      final tyres = await service.getTyresByAccount(int.parse(parentAccountId));

      print("🟢 API RETURNED => ${tyres.length} tyres");

      /// Save original data
      allTyres.assignAll(tyres);

      /// Apply tab filter
      _applyTabFilter(tab);
    } catch (e, s) {
      print("🔴 ERROR in fetchData => $e");
      print(s);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", e.toString());
      });
    } finally {
      isLoading.value = false;
    }
  }

  // ==================================================
  // 🗂 TAB FILTER (dispositionName)
  // ==================================================
  void _applyTabFilter(String tab) {
    print("🟣 APPLY TAB FILTER => $tab");

    if (tab.toLowerCase() == 'all') {
      visibleTyres.assignAll(allTyres);
    } else {
      visibleTyres.assignAll(
        allTyres.where((t) {
          final apiValue = (t.dispositionName ?? '').toLowerCase().trim();
          final tabValue = tab.toLowerCase().trim();
          return apiValue == tabValue;
        }).toList(),
      );
    }

    print("🟡 VISIBLE TYRES => ${visibleTyres.length}");
  }

  // ==================================================
  // 🔍 SEARCH (SAFE NULL HANDLING)
  // ==================================================
  void onSearch(String value) {
    searchText.value = value;

    if (value.trim().isEmpty) {
      _applyTabFilter(tabs[tabController!.index]);
      return;
    }

    final query = value.toLowerCase();

    visibleTyres.assignAll(
      allTyres.where((t) {
        return (t.tireSerialNo ?? '').toLowerCase().contains(query) ||
            (t.sizeName ?? '').toLowerCase().contains(query) ||
            (t.vehicleNumber ?? '').toLowerCase().contains(query) ||
            (t.manufacturerName ?? '').toLowerCase().contains(query);
      }).toList(),
    );

    print("🔎 SEARCH RESULT => ${visibleTyres.length}");
  }

  // ==================================================
  // 📌 BOTTOM SHEET
  // ==================================================
  void openBottomSheet(TyreModel tyre) {
    //   final String currentTab = tabs[tabController!.index];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ ONLY FOR INSTALLED TAB
            //     if (currentTab.toLowerCase() == 'installed')
            if ((tyre.vehicleNumber ?? "").isNotEmpty)
              ListTile(
                title: const Center(child: Text('Inspect')),
                onTap: () {
                  Get.back();
                  Get.to(() => VehicleInspeView(), arguments: tyre.vehicleId);
                },
              ),

            /// ✅ ALWAYS SHOW
            ListTile(
              title: const Center(child: Text('View')),
              onTap: () {
                print("🚀 NAVIGATE TO VIEW | tireId => ${tyre.tireId}");
                Get.back();
                Get.to(() => TyreView(), arguments: tyre.tireId);
              },
            ),

            ListTile(
              title: const Center(child: Text('Edit')),
              onTap: () {
                print("🚀 NAVIGATE TO EDIT | tireId => ${tyre.tireId}");
                Get.back();
                Get.toNamed(AppPages.EDIT_TIRE_SCREEN, arguments: tyre.tireId);
              },
            ),

            ListTile(
              title: const Center(child: Text('Clone')),
              onTap: () {
                Get.back();
                Get.toNamed(AppPages.CREATE_TYRE, arguments: tyre.tireId);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    tabController!.dispose();
    super.onClose();
  }
}
