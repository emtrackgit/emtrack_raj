import 'package:get/get.dart';
import 'dart:convert';
import '../models/home_model.dart';
import '../models/statical_model.dart';
import '../services/home_service.dart';
import '../services/change_account_service.dart';
import '../services/master_data_service.dart';
import '../services/install_tyre_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/local_db.dart';
import '../utils/secure_storage.dart';
import '../utils/local_storage_service.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var username  = ''.obs;
  RxBool isCreateOpen = false.obs;

  var homeData  = Rxn<HomeModel>();
  var homeCount = Rxn<DashboardModel>();

  RxString selectedParentAccountName = ''.obs;
  RxString selectedLocationName      = ''.obs;

  RxInt tyreCount    = 0.obs;
  RxInt vehicleCount = 0.obs;

  String get role           => homeData.value?.role ?? "";
  String get parentAccount  => homeData.value?.parentAccount ?? "";
  String get location       => homeData.value?.location ?? "";
  String get imageUrl       => homeData.value?.imageUrl ?? "";
  int    get totalTyres     => homeData.value?.totalTyres ?? 0;
  int    get vehicles       => homeData.value?.vehicles ?? 0;
  int    get unsynced       => homeData.value?.unsyncedInspections ?? 0;
  int    get synced         => homeData.value?.syncedInspections ?? 0;
  String get lastInspection => homeData.value?.lastInspection ?? "—";
  String get appVersion     => homeData.value?.appVersion ?? "1.0";

  @override
  void onInit() {
    super.onInit();
    _initWithDelay();
  }

  Future<void> _initWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));

    await loadUserName();
    await loadSelectedAccountData();

    // ✅ Pehle local se load karo (instant UI — location + counts turant dikhenge)
    await _loadFromLocal();

    final cookie = await SecureStorage.getCookie();
    if (cookie == null || cookie.isEmpty) {
      print("⚠️ No cookie — using local cache only");
      return;
    }

    // ✅ Network se fetch karo
    await fetchHome();
    await fetchReportDashboardDataHome();
    await loadTyreCountByAccount();
    await loadVehicleCountByAccount();

    // ✅ Sab local mein save karo
    await _saveToLocal();
  }

  // ─── Local se load (instant UI) ──────────────
  Future<void> _loadFromLocal() async {
    // Vehicles + Tyres count
    final vehicles = await LocalStorageService.getVehicles();
    final tyres    = await LocalStorageService.getTyres();
    if (vehicles.isNotEmpty) vehicleCount.value = vehicles.length;
    if (tyres.isNotEmpty)    tyreCount.value    = tyres.length;

    // ✅ FIX 1: Account + Location bhi local se load karo
    final parentName   = await SecureStorage.getParentAccountName();
    final locationName = await SecureStorage.getLocationName();
    if (parentName   != null && parentName.isNotEmpty)   selectedParentAccountName.value = parentName;
    if (locationName != null && locationName.isNotEmpty) selectedLocationName.value      = locationName;

    print("📦 Local loaded: ${vehicles.length} vehicles, ${tyres.length} tyres");
    print("📦 Local account: $parentName - $locationName");
  }

  // ─── Sab 5 cheezein local mein save karo ─────
  Future<void> _saveToLocal() async {
    try {
      final parentAccountId = await SecureStorage.getParentAccountId();

      // ── 1. MASTER DATA ───────────────────────────
      try {
        final masterService = MasterDataService();
        final masterRaw = await masterService.fetchMasterData();
        await LocalStorageService.saveMasterData(masterRaw);
        print("✅ MasterData saved");
      } catch (e) {
        print("❌ MasterData save error: $e");
      }

      // ── 2. VEHICLES ──────────────────────────────
      if (parentAccountId != null) {
        final vehicles = await LocalStorageService.getVehicles();
        print("✅ Vehicles kept local: ${vehicles.length}");
      }

      // ── 3. TYRES ─────────────────────────────────
      if (parentAccountId != null) {
        final tyres = await LocalStorageService.getTyres();
        if (tyres.isNotEmpty) {
          await LocalDatabaseService.saveTires(tyres);
        }
        print("✅ Tyres kept local: ${tyres.length}");
      }

      // ── 4. ACCOUNTS ──────────────────────────────
      try {
        final accountService = ChangeAccountService();
        final accounts = await accountService.fetchParentAccounts();
        final accountMaps = accounts
            .map((a) => {
          'parentAccountId': a.parentAccountId,
          'accountName':     a.accountName,
          'createdBy':       a.createdBy,
        })
            .toList();
        await LocalStorageService.saveAccounts(accountMaps);
        print("✅ Accounts saved: ${accountMaps.length}");
      } catch (e) {
        print("❌ Accounts save error: $e");
      }

      // ── 5. LOCATIONS ─────────────────────────────
      try {
        final parentAccountIdInt = int.tryParse(parentAccountId ?? '');
        if (parentAccountIdInt != null) {
          final accountService = ChangeAccountService();
          final locations = await accountService.fetchLocations(parentAccountIdInt);
          final locationMaps = locations
              .map((l) => {
            'locationId':      l.locationId,
            'locationName':    l.locationName,
            'parentAccountId': parentAccountIdInt,
          })
              .toList();
          await LocalStorageService.saveLocations(locationMaps);
          print("✅ Locations saved: ${locationMaps.length}");
        }
      } catch (e) {
        print("❌ Locations save error: $e");
      }

      // ── VERIFY ───────────────────────────────────
      final v        = await LocalStorageService.getVehicles();
      final t        = await LocalStorageService.getTyres();
      final a        = await LocalStorageService.getAccounts();
      final l        = await LocalStorageService.getLocations();
      final m        = await LocalStorageService.getMasterData();
      final lastSync = await LocalStorageService.getLastSyncedAt();

      print("─────────────────────────────────");
      print("✅ LOCAL STORAGE SAVED:");
      print("   🚗 Vehicles  : ${v.length}");
      print("   🔵 Tyres     : ${t.length}");
      print("   🏢 Accounts  : ${a.length}");
      print("   📍 Locations : ${l.length}");
      print("   📋 MasterData: ${m != null ? 'Yes (${m.keys.length} keys)' : 'No'}");
      print("   🕐 Last Sync : $lastSync");
      print("─────────────────────────────────");
    } catch (e) {
      print("Save to local error: $e");
    }
  }

  // ─── LOAD USERNAME ────────────────────────────
  Future<void> loadUserName() async {
    final name = await SecureStorage.getUserProfileName();
    if (name != null && name.isNotEmpty) username.value = name;
  }

  // ─── FETCH HOME ───────────────────────────────
  Future<void> fetchHome() async {
    isLoading.value = true;
    try {
      final response = await HomeService.fetchHomeData();
      if (response != null) {
        homeData.value = response;

        // ✅ FIX 2: homeData aane ke baad selectedName bhi update karo
        if (response.parentAccount != null && response.parentAccount!.isNotEmpty) {
          selectedParentAccountName.value = response.parentAccount!;
        }
        if (response.location != null && response.location!.isNotEmpty) {
          selectedLocationName.value = response.location!;
        }
      }
    } catch (e) {
      print("Home fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReportDashboardDataHome() async {
    isLoading.value = true;
    try {
      final response = await HomeService.fetchReportDashboardHomeData();
      if (response != null) homeCount.value = response;
    } catch (e) {
      print("Dashboard fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── PULL TO REFRESH ──────────────────────────
  Future<void> refreshHome() async {
    await fetchHome();
    await fetchReportDashboardDataHome();
    await loadTyreCountByAccount();
    await loadVehicleCountByAccount();
    await _saveToLocal();
  }

  // ─── SYNC ─────────────────────────────────────
  Future<void> syncInspections() async {
    isLoading.value = true;
    try {
      final inspectionOk = await HomeService.syncInspections();
      final installRes = await InstallTyreService().syncPendingInstalls();
      final reqRes = await HomeService.syncPendingRequests();

      await fetchHome();
      await _saveToLocal();

      final msg =
          "Inspections: ${inspectionOk ? '✅' : '❌'}\n"
          "Installs: ✅${installRes['success']} ❌${installRes['failed']} 📦${installRes['pending']}\n"
          "Offline Queue: ✅${reqRes['success']} ❌${reqRes['failed']} 📦${reqRes['pending']}";

      if (inspectionOk && (reqRes['failed'] ?? 0) == 0 && (installRes['failed'] ?? 0) == 0) {
        AppSnackbar.success(msg, title: "Sync");
      } else {
        AppSnackbar.error(msg, title: "Sync");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE MENU ──────────────────────────────
  void openCreateMenu()  => isCreateOpen.value = true;
  void closeCreateMenu() => isCreateOpen.value = false;

  // ─── ACCOUNT / LOCATION ───────────────────────
  Future<void> loadSelectedAccountData() async {
    final parentName   = await SecureStorage.getParentAccountName();
    final locationName = await SecureStorage.getLocationName();
    if (parentName   != null && parentName.isNotEmpty)   selectedParentAccountName.value = parentName;
    if (locationName != null && locationName.isNotEmpty) selectedLocationName.value      = locationName;
  }

  void updateSelectedAccount({
    required String parentAccountName,
    required String locationName,
  }) {
    selectedParentAccountName.value = parentAccountName;
    selectedLocationName.value      = locationName;
  }

  // ─── TYRE COUNT (local-first) ─────────────────
  Future<void> loadTyreCountByAccount() async {
    final local = await LocalStorageService.getTyres();
    tyreCount.value = local.length;
  }

  // ─── VEHICLE COUNT (local-first) ─────────────
  Future<void> loadVehicleCountByAccount() async {
    final local = await LocalStorageService.getVehicles();
    vehicleCount.value = local.length;
  }

  // ─── LOGOUT ───────────────────────────────────
  Future<void> clearLocalStorage() async {
    await LocalStorageService.clearAll();
    print("🗑️ Local storage cleared");
  }
}
