import 'package:emtrack/models/masterDataMobileModel/master_model.dart';
import 'package:emtrack/models/masterDataMobileModel/star_rating_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_compound_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_fill_type_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_ind_code_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_load_rating_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_manufacturer_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_size_model.dart';
import 'package:emtrack/models/masterDataMobileModel/tire_type_model.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tyre_view_model.dart';
import '../services/tyre_view_service.dart';
import '../utils/secure_storage.dart';

class TyreViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TyreViewService service = TyreViewService();

  Rx<TyreViewModel?> tyre = Rx<TyreViewModel?>(null);
  RxBool isLoading = true.obs;

  late TabController tabController;

  // Master Data
  MasterModel? masterData;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    loadMasterData(); // load master data first
  }

  Future<void> loadMasterData() async {
    // Example: fetch MasterDataService (you already have)
    final data = await MasterDataService().fetchMasterData();
    masterData = MasterModel.fromJson(data);
  }

  Future<void> loadTyre(int tyreId) async {
    isLoading.value = true;
    try {
      final t = await service.fetchTyreDetailsById(tyreId);
      tyre.value = t;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ GET NAME FROM MASTER
  String getManufacturerName(int id) {
    if (masterData == null) return id.toString();
    final m = masterData!.tireManufacturers.firstWhere(
      (e) => e.manufacturerId == id,
      orElse: () => TireManufacturer(
        manufacturerId: id,
        manufacturerName: "N/A",
        activeFlag: true,
      ),
    );
    return m.manufacturerName;
  }

  String getTireSizeName(int id) {
    if (masterData == null) return id.toString();
    final t = masterData!.tireSizes.firstWhere(
      (e) => e.tireSizeId == id,
      orElse: () => TireSize(
        tireSizeId: id,
        tireSizeName: "N/A",
        activeFlag: true,
        tireManufacturerId: id,
      ),
    );
    return t.tireSizeName;
  }

  String getStarRatingName(int? id) {
    if (masterData == null || id == null) return "-";
    final s = masterData!.starRating.firstWhere(
      (e) => e.ratingId == id,
      orElse: () => StarRating(ratingId: id, ratingName: "-"),
    );
    return s.ratingName;
  }

  String getTypeName(int id) {
    if (masterData == null) return id.toString();
    final t = masterData!.tireTypes.firstWhere(
      (e) => e.typeId == id,
      orElse: () => TireType(
        typeId: id,
        typeName: "N/A",
        tireManufacturerId: id,
        tireSizeId: id,
        activeFlag: true,
      ),
    );
    return t.typeName;
  }

  String getIndCodeName(int id) {
    if (masterData == null) return id.toString();
    final t = masterData!.tireIndCodes.firstWhere(
      (e) => e.codeId == id,
      orElse: () => TireIndCode(codeId: id, codeName: "N/A"),
    );
    return t.codeName;
  }

  String getCompoundName(int? id) {
    if (masterData == null || id == null) return "-";
    final t = masterData!.tireCompounds.firstWhere(
      (e) => e.compoundId == id,
      orElse: () =>
          TireCompound(compoundId: id, compoundName: "-", activeFlag: true),
    );
    return t.compoundName;
  }

  String getLoadRatingName(int? id) {
    if (masterData == null || id == null) return "-";
    final t = masterData!.tireLoadRatings.firstWhere(
      (e) => e.ratingId == id,
      orElse: () => TireLoadRating(ratingId: id, ratingName: "-"),
    );
    return t.ratingName;
  }

  String getFillTypeName(int? id) {
    if (masterData == null || id == null) return "-";
    final t = masterData!.tireFillTypes.firstWhere(
      (e) => e.fillTypeId == id,
      orElse: () => TireFillType(fillTypeId: id, fillTypeName: "-"),
    );
    return t.fillTypeName;
  }
}
