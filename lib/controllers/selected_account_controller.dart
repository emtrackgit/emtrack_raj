import 'package:get/get.dart';
import '../utils/secure_storage.dart';

class SelectedAccountController extends GetxController {
  RxString parentAccountName = ''.obs;
  RxString locationName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    parentAccountName.value = await SecureStorage.getParentAccountName() ?? '';

    locationName.value = await SecureStorage.getLocationName() ?? '';
  }

  /// call this after Change Account select
  @override
  Future<void> refresh() async {
    await loadFromStorage();
  }
}
