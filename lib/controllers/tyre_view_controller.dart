import 'package:emtrack/models/masterDataMobileModel/master_model.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tyre_view_model.dart';
import '../services/tyre_view_service.dart';

class TyreViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TyreViewService _service = TyreViewService();

  RxBool isLoading = true.obs;
  Rx<TyreViewModel?> tyre = Rx<TyreViewModel?>(null);
  Rx<MasterModel?> masterData = Rx<MasterModel?>(null);

  late final TabController tabController;
  final int? tireId;

  // Constructor
  TyreViewController({this.tireId}); // 🔹 received id

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    final id = tireId ?? Get.arguments as int?;
    if (id != null) {
      fetchData(id);
    } else {
      Get.snackbar('Error', 'Tire ID not provided');
    }
  }

  /// 🔹 Fetch both tyre details and master data
  Future<void> fetchData(int tireId) async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchTyreDetailsById(tireId),
        _service.fetchMasterData(),
      ]);

      tyre.value = results[0] as TyreViewModel;
      masterData.value = results[1] as MasterModel;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------- MAPPING METHODS -----------------------

  String getManufacturerName(int id) {
    if (masterData.value == null) return "";

    try {
      final m = masterData.value!.tireManufacturers.firstWhere(
        (e) => e.manufacturerId == id,
      );
      return m.manufacturerName; // ✅ REAL NAME
    } catch (e) {
      return ""; // ❌ fake "N/A" nahi
    }
  }

  String getTireSizeName(int id) {
    if (masterData.value == null) return "";

    try {
      final t = masterData.value!.tireSizes.firstWhere(
        (e) => e.tireSizeId == id,
      );
      return t.tireSizeName; // ✅ REAL NAME
    } catch (e) {
      return ""; // ya "-"
    }
  }

  String getStarRatingName(int? id) {
    if (id == null || masterData.value == null) return "";

    final list = masterData.value!.starRating;

    final match = list.where((e) => e.ratingId == id);

    if (match.isEmpty) {
      print("❌ Star rating not found for id: $id");
      return "";
    }

    return match.first.ratingName;
  }

  String getTypeName(int id) {
    if (masterData.value == null) return "";

    final list = masterData.value!.tireTypes;

    final match = list.where((e) => e.typeId == id);

    if (match.isEmpty) {
      print("❌ TireType not found for id: $id");
      return "";
    }

    return match.first.typeName;
  }

  String getIndCodeName(int id) {
    if (masterData.value == null) return "";

    final list = masterData.value!.tireIndCodes;

    final match = list.where((e) => e.codeId == id);

    if (match.isEmpty) {
      print("❌ TireIndCode not found for id: $id");
      return "";
    }

    return match.first.codeName;
  }

  String getCompoundName(int? id) {
    if (masterData.value == null || id == null) return "";

    final list = masterData.value!.tireCompounds;

    final match = list.where((e) => e.compoundId == id);

    if (match.isEmpty) {
      print("❌ TireCompound not found for id: $id");
      return "";
    }

    return match.first.compoundName;
  }

  String getLoadRatingName(int? id) {
    if (masterData.value == null || id == null) return "";

    final list = masterData.value!.tireLoadRatings;

    final match = list.where((e) => e.ratingId == id);

    if (match.isEmpty) {
      print("❌ TireLoadRating not found for id: $id");
      return "";
    }

    return match.first.ratingName;
  }

  String getFillTypeName(int? id) {
    if (masterData.value == null || id == null) return "";

    final list = masterData.value!.tireFillTypes;

    final match = list.where((e) => e.fillTypeId == id);

    if (match.isEmpty) {
      print("❌ TireFillType not found for id: $id");
      return "";
    }

    return match.first.fillTypeName;
  }

  String getTireStatusName(int? id) {
    if (masterData.value == null || id == null) return "";

    final list = masterData.value!.tireStatus;

    final match = list.where((e) => e.statusId == id);

    if (match.isEmpty) {
      print("❌ TireFillType not found for id: $id");
      return "";
    }

    return match.first.statusName.toString();
  }

  String getDispositionName(int? id) {
    if (masterData.value == null || id == null) return "";

    final list = masterData.value!.tireDispositions;

    final match = list.where((e) => e.dispositionId == id);

    if (match.isEmpty) {
      print("❌ TireFillType not found for id: $id");
      return "";
    }

    return match.first.dispositionName.toString();
  }

  String getTrackingMethod(String? mileageType) {
    switch (mileageType) {
      case "1":
        return "Hours";
      case "2":
        return "Distance";
      case "3":
        return "Both";
      default:
        return "";
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
