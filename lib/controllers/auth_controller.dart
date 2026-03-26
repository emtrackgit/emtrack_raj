import 'package:emtrack/models/role/profile_model.dart';
import 'package:emtrack/models/user_models.dart';
import 'package:get/get.dart';
import 'package:emtrack/routes/app_pages.dart';
import '../services/auth_service.dart';
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

  /// 🔹 Load from SecureStorage
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

      await getUserProfile();
      Get.offAllNamed(AppPages.HOME);
      return user;
    } catch (e) {
      errorMessage.value = "Something went wrong";
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      isLoading.value = true;

      final UserProfile? userData = await AuthService.getUserprofile();

      if (userData == null) return null;

      /// Save locally
      await SecureStorage.saveUserProfileRole(userData.userRole ?? "");
      await SecureStorage.saveUserProfileName(
        "${userData.firstName ?? ""} ${userData.lastName ?? ""}",
      );

      /// Update reactive variables
      userRole.value = userData.userRole ?? "";
      userName.value = "${userData.firstName ?? ""} ${userData.lastName ?? ""}";

      return userData;
    } catch (e) {
      errorMessage.value = "Failed to load profile";
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    await SecureStorage.clearToken();

    await SecureStorage.saveUserProfileRole("");
    await SecureStorage.saveUserProfileName("");

    user.value = null;
    Get.offAllNamed(AppPages.LOGIN);
  }
}
