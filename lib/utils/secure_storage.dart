import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = "auth_token";
  static const _cookieKey = 'auth_cookie';
  // 🔁 ACCOUNT TYPE (OWN / SHARED)
  static const _accountTypeKey = 'account_type';
  static final _storage_preferences = <String, String>{};
  // 🔐 TOKEN
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  // set cookies
  static Future<void> saveCookie(String cookie) async {
    await _storage.write(key: _cookieKey, value: cookie);
  }

  static Future<String?> getCookie() async {
    return await _storage.read(key: _cookieKey);
  }

  static Future<void> clearCookie() async {
    await _storage.delete(key: _cookieKey);
  }

  // xsrf_token
  static Future<void> saveXsrfToken(String token) async {
    await _storage.write(key: 'xsrf_token', value: token);
  }

  static Future<String?> getXsrfToken() async {
    return await _storage.read(key: 'xsrf_token');
  }

  static Future<void> clearXsrfToken() async {
    await _storage.delete(key: 'xsrf_token');
  }

  // 👤 USERNAME  ✅ ADD THIS
  static Future<void> saveUserName(String username) async {
    await _storage.write(key: 'username', value: username);
  }

  static Future<void> saveUserProfileName(String username) async {
    await _storage.write(key: 'userprofilename', value: username);
  }

  static Future<String?> getUserProfileName() async {
    return await _storage.read(key: 'userprofilename');
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'username');
  }

  static Future<void> saveUserProfileRole(String userRole) async {
    return await _storage.write(key: 'userprofilerole', value: userRole);
  }

  static Future<String?> getUserProfileRole() async {
    return await _storage.read(key: 'userprofilerole');
  }

  static Future<void> clearUserName() async {
    await _storage.delete(key: 'username');
  }

  // 🧹 CLEAR ALL
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // preferences
  static Future<void> savePreference(String key, String value) async {
    _storage_preferences[key] = value;
  }

  static Future<String?> getPreference(String key) async {
    return _storage_preferences[key];
  }

  /// Save account type (own / shared)
  static Future<void> saveAccountType(String type) async {
    await _storage.write(key: _accountTypeKey, value: type);
  }

  /// Get account type (default: own)
  static Future<String> getAccountType() async {
    return await _storage.read(key: _accountTypeKey) ?? 'own';
  }

  /// Clear account type
  static Future<void> clearAccountType() async {
    await _storage.delete(key: _accountTypeKey);
  }

  // 🏢 PARENT ACCOUNT
  static Future<void> saveParentAccount({
    required String id,
    required String name,
  }) async {
    await _storage.write(key: 'parent_account_id', value: id);
    await _storage.write(key: 'parent_account_name', value: name);
  }

  static Future<String?> getParentAccountName() async {
    return await _storage.read(key: 'parent_account_name');
  }

  static Future<String?> getParentAccountId() async {
    return await _storage.read(key: 'parent_account_id');
  }

  // 📍 LOCATION
  static Future<void> saveLocation({
    required String id,
    required String name,
  }) async {
    await _storage.write(key: 'location_id', value: id);
    await _storage.write(key: 'location_name', value: name);
  }

  static Future<String?> getLocationName() async {
    return await _storage.read(key: 'location_name');
  }

  static Future<String?> getLocationId() async {
    return await _storage.read(key: 'location_id');
  }

  /* ---------------- BOOL SAVE ---------------- */
  static Future<void> saveBool(String key, bool value) async {
    await _storage.write(
      key: key,
      value: value.toString(), // "true" / "false"
    );
  }

  /* ---------------- BOOL GET ---------------- */
  static Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /* ---------------- BOOL DELETE (optional) ---------------- */
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// ✅ AUTH HEADERS (YAHI TUMNE PUCHA THA)
  static Future<Map<String, String>> authHeaders() async {
    final cookie = await getCookie();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cookie != null && cookie.isNotEmpty)
        'Cookie': cookie, // 🔥 session cookie
    };
  }
  /* ================= search vehicle and tires ================= */

  // VEHICLES
  static Future<void> saveVehicle(String value) async {
    await _storage.write(key: 'recent_vehicles', value: value);
  }

  static Future<String?> getVehicle() async {
    return await _storage.read(key: 'recent_vehicles');
  }

  static Future<void> clearVehicle() async {
    await _storage.delete(key: 'recent_vehicles');
  }

  // TYRES
  static Future<void> saveTyre(String value) async {
    await _storage.write(key: 'recent_tyres', value: value);
  }

  static Future<String?> getTyre() async {
    return await _storage.read(key: 'recent_tyres');
  }

  static Future<void> clearTyre() async {
    await _storage.delete(key: 'recent_tyres');
  }

  //================Inscpection search Vehicle tire ===============
  static Future<void> saveLastVehicle(String vehicle) async {
    await _storage.write(key: 'last_vehicle', value: vehicle);
  }

  /// ✅ Read last selected vehicle
  static Future<String?> getLastVehicle() async {
    return await _storage.read(key: 'last_vehicle');
  }

  /// ✅ Save last selected tyre
  static Future<void> saveLastTyre(String tyre) async {
    await _storage.write(key: 'last_tyre', value: tyre);
  }

  /// ✅ Read last selected tyre
  static Future<String?> getLastTyre() async {
    return await _storage.read(key: 'last_tyre');
  }

  /// ❌ Remove last selected vehicle
  static Future<void> clearLastVehicle() async {
    await _storage.delete(key: 'last_vehicle');
  }

  /// ❌ Remove last selected tyre
  static Future<void> clearLastTyre() async {
    await _storage.delete(key: 'last_tyre');
  }
}
