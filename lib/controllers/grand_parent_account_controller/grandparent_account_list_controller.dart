import 'package:emtrack/services/grand_parent_account_service/grandparent_account_list_service.dart';
import 'package:get/get.dart';
import 'package:emtrack/models/grand_parent_account_model/grandparent_account_list_model.dart';

class GrandparentAccountListController extends GetxController {
  final GrandparentAccountListService service = GrandparentAccountListService();

  /// UI DATA
  RxList<GrandparentAccountList> accounts = <GrandparentAccountList>[].obs;

  RxBool loading = false.obs;

  /// SEARCH & PAGINATION
  RxString searchText = ''.obs;
  RxInt currentPage = 1.obs;
  final int pageSize = 10;

  RxInt totalRecords = 0.obs;

  int get totalPages => (totalRecords.value / pageSize).ceil();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  /// 🔹 FETCH DATA
  Future<void> fetchData() async {
    loading.value = true;
    try {
      print(
        "🔥 fetchData | page=${currentPage.value} | search='${searchText.value}'",
      );

      final response = await service.fetchAccounts(
        page: currentPage.value,
        pageSize: pageSize,
        search: searchText.value,
      );

      accounts.value = response.items;
      totalRecords.value = response.totalCount;

      print("✅ Loaded ${accounts.length} / ${totalRecords.value}");
    } catch (e) {
      print("❌ Controller Error: $e");
      accounts.clear();
      totalRecords.value = 0;
    } finally {
      loading.value = false;
    }
  }

  /// 🔍 SEARCH
  void onSearch(String value) {
    searchText.value = value;
    currentPage.value = 1; // 🔥 reset page on search
    fetchData();
  }

  /// ➡️ NEXT PAGE
  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
      fetchData();
    }
  }

  /// ⬅️ PREVIOUS PAGE
  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchData();
    }
  }

  /// 🔄 PULL TO REFRESH (future ready)
  Future<void> refreshList() async {
    currentPage.value = 1;
    await fetchData();
  }
}
