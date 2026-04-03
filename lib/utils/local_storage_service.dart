import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _masterDataKey   = 'local_master_data';
  static const String _vehiclesKey     = 'local_vehicles';
  static const String _accountsKey     = 'local_accounts';
  static const String _locationsKey    = 'local_locations';
  static const String _tyresKey        = 'local_tyres';
  static const String _lastSyncedAtKey = 'local_last_synced_at';

  // ── Master Data ───────────────────────────────
  static Future<void> saveMasterData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_masterDataKey, jsonEncode(data));
    await _updateSyncTime();
  }

  static Future<Map<String, dynamic>?> getMasterData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_masterDataKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── Vehicles ──────────────────────────────────
  static Future<void> saveVehicles(List<Map<String, dynamic>> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehiclesKey, jsonEncode(vehicles));
    await _updateSyncTime();
  }

  static Future<List<Map<String, dynamic>>> getVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehiclesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Accounts ──────────────────────────────────
  static Future<void> saveAccounts(List<Map<String, dynamic>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
    await _updateSyncTime();
  }

  static Future<List<Map<String, dynamic>>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Locations ─────────────────────────────────
  static Future<void> saveLocations(List<Map<String, dynamic>> locations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationsKey, jsonEncode(locations));
    await _updateSyncTime();
  }

  static Future<List<Map<String, dynamic>>> getLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_locationsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Tyres ─────────────────────────────────────
  static Future<void> saveTyres(List<Map<String, dynamic>> tyres) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tyresKey, jsonEncode(tyres));
    await _updateSyncTime();
  }

  static Future<List<Map<String, dynamic>>> getTyres() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tyresKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Last Synced At ────────────────────────────
  static Future<String?> getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncedAtKey);
  }

  static Future<void> _updateSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncedAtKey, DateTime.now().toIso8601String());
  }


  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_masterDataKey);
    await prefs.remove(_vehiclesKey);
    await prefs.remove(_accountsKey);
    await prefs.remove(_locationsKey);
    await prefs.remove(_tyresKey);
    await prefs.remove(_lastSyncedAtKey);
  }
}