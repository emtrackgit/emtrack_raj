import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:get/get.dart';
import '../utils/secure_storage.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var showPassword = false.obs;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1)); // simulate API

    try {
      final hashedPass = _hash(password);

      // Fake token (replace with real API JWT)
      String token = base64Url.encode(utf8.encode("$username:$hashedPass"));

      await SecureStorage.saveToken(token);
      Get.offAllNamed(AppPages.HOME); // 🔥 go to home page
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearToken();
    Get.offAllNamed(AppPages.LOGIN); // 🔥 back to login
  }

  String _hash(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }
}
