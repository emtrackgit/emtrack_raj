import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:emtrack/views/login_view.dart';
import 'package:emtrack/utils/secure_storage.dart';

class GlobalLogoutHandler extends GetxService {
  bool _isRedirecting = false;

  void forceLogout() {
    if (_isRedirecting) return;
    _isRedirecting = true;
    Get.offAll(() => LoginView());
  }
}
