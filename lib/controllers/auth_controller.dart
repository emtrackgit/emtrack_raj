import 'package:emtrack/models/role/profile_model.dart';
import 'package:emtrack/models/user_models.dart';
import 'package:emtrack/services/home_service.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emtrack/routes/app_pages.dart';
import '../services/auth_service.dart';
import '../services/change_account_service.dart';
import '../utils/secure_storage.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final showPassword = false.obs;
  final user = Rxn<UserModel>();
  final errorMessage = ''.obs;

  RxString userRole = "".obs;
  RxString userName = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalUser();
  }

  Future<void> loadLocalUser() async {
    userRole.value = await SecureStorage.getUserProfileRole() ?? "";
    userName.value = await SecureStorage.getUserProfileName() ?? "";
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserModel? user = await AuthService.login(username, password);

      if (user == null) {
        errorMessage.value = "Invalid username or password";
        return null;
      }

      await SecureStorage.saveUserName(username);
      await SecureStorage.saveToken("logged_in");

      // ✅ Step 1: Profile save karo
      await getUserProfile();

      // ✅ Step 2: Default account + location save karo (HOME pe data dikhne ke liye)
      await _saveDefaultAccountAndLocation();

      await _downloadBootstrapDataWithDialog();

      Get.offAllNamed(AppPages.HOME);
      return user;
    } catch (e) {
      errorMessage.value = "Something went wrong";
      print("Login error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _downloadBootstrapDataWithDialog() async {
    final RxInt progress = 0.obs;
    final RxString status = "Downloading 0%".obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Downloading"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status.value),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.value / 100.0,
                color: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final parentAccountId = await SecureStorage.getParentAccountId();
      final parentAccountIdInt = int.tryParse(parentAccountId ?? '');

      Future<void> step({
        required int pct,
        required String label,
        required Future<void> Function() run,
      }) async {
        status.value = "$label ($pct%)";
        progress.value = pct;
        try {
          await run();
          print("✅ Download step ok: $label");
        } catch (e) {
          print("❌ Download step failed: $label => $e");
        }
      }

      await step(
        pct: 0,
        label: "Downloading masterData",
        run: () async {
          final master = await MasterDataService().fetchMasterData();
          await LocalStorageService.saveMasterData(master);
        },
      );

      await step(
        pct: 20,
        label: "Downloading vehicles",
        run: () async {
          if (parentAccountId == null || parentAccountId.isEmpty) return;
          final raw = await HomeService.fetchVehicleRawListFromApi(parentAccountId);
          if (raw == null) return;
          await LocalStorageService.saveVehicles(raw);
        },
      );

      await step(
        pct: 40,
        label: "Downloading accounts",
        run: () async {
          final accountService = ChangeAccountService();
          final accounts = await accountService.fetchParentAccounts();
          final accountMaps = accounts
              .map((a) => {
                    'parentAccountId': a.parentAccountId,
                    'accountName': a.accountName,
                    'createdBy': a.createdBy,
                  })
              .toList();
          await LocalStorageService.saveAccounts(accountMaps);
          await LocalDatabaseService.saveJsonCache('accounts', accountMaps);
        },
      );

      await step(
        pct: 60,
        label: "Downloading locations",
        run: () async {
          if (parentAccountIdInt == null) return;
          final accountService = ChangeAccountService();
          final locations = await accountService.fetchLocations(parentAccountIdInt);
          final locationMaps = locations
              .map((l) => {
                    'locationId': l.locationId,
                    'locationName': l.locationName,
                    'parentAccountId': parentAccountIdInt,
                  })
              .toList();
          await LocalStorageService.saveLocations(locationMaps);
          await LocalDatabaseService.saveJsonCache('locations:$parentAccountIdInt', locationMaps);
        },
      );

      await step(
        pct: 80,
        label: "Downloading tires",
        run: () async {
          if (parentAccountId == null || parentAccountId.isEmpty) return;
          final raw = await HomeService.fetchTyreRawListFromApi(parentAccountId);
          if (raw == null) return;
          await LocalStorageService.saveTyres(raw);
          await LocalDatabaseService.saveTires(raw);
        },
      );

      progress.value = 100;
      status.value = "Downloading 100%";
      print("✅ Download complete");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ─── Login ke baad pehla account aur pehli location SecureStorage mein save karo ───
  Future<void> _saveDefaultAccountAndLocation() async {
    try {
      final accountService = ChangeAccountService();

      // Accounts fetch karo
      final accounts = await accountService.fetchParentAccounts();
      if (accounts.isEmpty) {
        print("⚠️ No accounts found");
        return;
      }

      final firstAccount = accounts.first;
      final accountId   = firstAccount.parentAccountId.toString();
      final accountName = firstAccount.accountName;

      await SecureStorage.saveParentAccount(id: accountId, name: accountName);
      print("✅ Default account saved: $accountName ($accountId)");

      // Locations fetch karo
      final locations = await accountService.fetchLocations(firstAccount.parentAccountId);
      if (locations.isEmpty) {
        print("⚠️ No locations found — using placeholder");
        await SecureStorage.saveLocation(id: '0', name: 'All Locations');
        return;
      }

      final firstLocation = locations.first;
      await SecureStorage.saveLocation(
        id:   firstLocation.locationId.toString(),
        name: firstLocation.locationName,
      );
      print("✅ Default location saved: ${firstLocation.locationName} (${firstLocation.locationId})");

    } catch (e) {
      print("❌ _saveDefaultAccountAndLocation error: $e");
      // Error pe bhi crash mat karo — login continue hoga
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      isLoading.value = true;

      final UserProfile? userData = await AuthService.getUserprofile();
      if (userData == null) return null;

      await SecureStorage.saveUserProfileRole(userData.userRole ?? "");
      await SecureStorage.saveUserProfileName(
        "${userData.firstName ?? ""} ${userData.lastName ?? ""}".trim(),
      );

      userRole.value = userData.userRole ?? "";
      userName.value = "${userData.firstName ?? ""} ${userData.lastName ?? ""}".trim();

      return userData;
    } catch (e) {
      errorMessage.value = "Failed to load profile";
      print("getUserProfile error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearToken();
    await SecureStorage.clearCookie();
    await SecureStorage.saveUserProfileRole("");
    await SecureStorage.saveUserProfileName("");
    // ✅ Account + Location bhi clear karo logout pe
    await SecureStorage.saveParentAccount(id: '', name: '');
    await SecureStorage.saveLocation(id: '', name: '');

    user.value = null;
    Get.offAllNamed(AppPages.LOGIN);
  }
}
