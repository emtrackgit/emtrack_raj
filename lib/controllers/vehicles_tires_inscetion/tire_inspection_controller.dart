import 'package:emtrack/models/vehicles_tires_inscetion/tires_inspection_model.dart';
import 'package:emtrack/services/vehicles_tires_inscetion/tire_inspection_service.dart';
import 'package:get/get.dart';

class TireInspectionController extends GetxController {
  final RxList<TyreInspectionModel> tyreList = <TyreInspectionModel>[].obs;
  final RxList<TyreInspectionModel> filteredList = <TyreInspectionModel>[].obs;
  final RxBool loading = true.obs;
  final RxBool isHot = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTyres();
  }

  Future<void> loadTyres() async {
    loading.value = true;
    final data = await TyreInspectionService.fetchTyres();
    tyreList.assignAll(data);
    filteredList.assignAll(data);
    loading.value = false;
  }

  void searchTyre(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(tyreList);
    } else {
      filteredList.assignAll(
        tyreList.where(
          (e) => e.serialNo.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void updateStatus(TyreInspectionModel tyre, String status) {
    tyre.status = status;
    filteredList.refresh();
  }
}
