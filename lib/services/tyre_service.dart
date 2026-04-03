import 'dart:convert';
import 'package:emtrack/models/tyre_model.dart';
import 'package:emtrack/models/tyre_responsive_model.dart';
import 'package:emtrack/models/view_tyre_response.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/local_db.dart';
import 'package:emtrack/utils/local_storage_service.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class     TyreService {
  // 🔹 GET BY ID URL
  static String get _getByIdUrl =>
      "${ApiConstants.baseUrl + ApiConstants.getTyresByAccount}/";

  /// Fetch tyre by Account
  Future<List<TyreModel>> getTyresByAccount(int accountId) async {
    try {
      final cached = await LocalStorageService.getTyres();
      if (cached.isNotEmpty) {
        final tyres = cached.map((e) => TyreModel.fromJson(e)).toList();
        print("✅ Tyres loaded from local cache: ${tyres.length}");
        return tyres;
      }

      final fromDb = await LocalDatabaseService.getInventoryTires(
        parentAccountId: accountId,
      );
      if (fromDb.isNotEmpty) {
        final tyres = fromDb.map((e) => TyreModel.fromJson(e)).toList();
        print("✅ Tyres loaded from SQLite cache: ${tyres.length}");
        return tyres;
      }

      print("❌ Tyres not available locally (cache empty)");
      return [];
    } catch (e, stacktrace) {
      print("❌ TyreService.getTyresByAccount error: $e");
      print(stacktrace);

      final cached = await LocalStorageService.getTyres();
      if (cached.isNotEmpty) {
        final tyres = cached.map((e) => TyreModel.fromJson(e)).toList();
        print("✅ Tyres loaded from SharedPreferences cache: ${tyres.length}");
        return tyres;
      }

      final fromDb = await LocalDatabaseService.getInventoryTires(
        parentAccountId: accountId,
      );
      if (fromDb.isNotEmpty) {
        final tyres = fromDb.map((e) => TyreModel.fromJson(e)).toList();
        print("✅ Tyres loaded from SQLite cache: ${tyres.length}");
        return tyres;
      }

      return [];
    }
  }

  Future<List<TyreModel>> getTyresById(int tireId) async {
    try {
      print("🔥 TyreService.getTyreById called with ID: $tireId");

      final response = await ApiService.getApi(
        endpoint: '${ApiConstants.getTyreById}$tireId',
      );

      if (response == null) {
        throw Exception("Empty API response");
      }

      final tyreResponse = TyreResponseModel.fromJson(response);

      if (tyreResponse.didError) {
        print("❌ API Error: ${tyreResponse.errorMessage}");
        throw Exception(tyreResponse.errorMessage ?? "API returned an error");
      }

      print("✅ Tyres fetched successfully: ${tyreResponse.model.length}");

      return tyreResponse.model;
    } catch (e, stacktrace) {
      print("🔥 Exception in TyreService.getTyreById:");
      print(e);
      print(stacktrace);
      rethrow;
    }
  }

  Future<ViewModel> cloneTyresById(int tireId) async {
    try {
      final response = await ApiService.getApi(
        endpoint: '${ApiConstants.getTyreById}$tireId',
      );

      if (response == null) {
        throw Exception("Empty API response");
      }

      final tyreResponse = ViewTyreResponse.fromJson(response);

      if (tyreResponse.didError) {
        throw Exception(tyreResponse.errorMessage);
      }

      return tyreResponse.viewModel; // ⭐ SINGLE OBJECT
    } catch (e) {
      rethrow;
    }
  }
}
