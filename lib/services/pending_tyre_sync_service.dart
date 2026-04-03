import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../create_tyre/create_tyre_model.dart';
import '../create_tyre/create_tyre_service.dart';
import '../edit_tyre/edit_tyre_model.dart';
import '../edit_tyre/edit_tyre_service.dart';
import '../utils/secure_storage.dart';

class PendingTyreSyncService {
  static bool _isNetworkError(Object e) {
    if (e is SocketException) return true;
    if (e.toString().contains('Failed host lookup')) return true;
    if (e.toString().contains('Connection refused')) return true;
    if (e.toString().contains('Network is unreachable')) return true;
    return false;
  }

  static Future<int> syncPendingCreates({bool showSnack = false}) async {
    final queue = await SecureStorage.getPendingCreateTyreQueue();
    if (queue.isEmpty) return 0;

    var synced = 0;

    for (var i = 0; i < queue.length; i++) {
      final raw = queue[i];
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          await SecureStorage.removePendingCreateTyreAt(i);
          i--;
          continue;
        }
        final m = CreateTyreModel.fromJson(decoded);
        await CreateTyreService.saveTyre(m);
        await SecureStorage.removePendingCreateTyreAt(i);
        i--;
        synced++;
      } catch (e) {
        if (_isNetworkError(e) ||
            (e is Exception &&
                e.toString().contains('Session expired') == false &&
                e.toString().contains('Please login') == false &&
                e.toString().contains('HTTP 400') == false)) {
          break;
        }
        await SecureStorage.removePendingCreateTyreAt(i);
        i--;
      }
    }

    if (showSnack && synced > 0) {
      Get.snackbar(
        "Sync",
        "$synced tire(s) synced",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return synced;
  }

  static Future<int> syncPendingEdits({bool showSnack = false}) async {
    final queue = await SecureStorage.getPendingEditTyreQueue();
    if (queue.isEmpty) return 0;

    var synced = 0;

    for (var i = 0; i < queue.length; i++) {
      final raw = queue[i];
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          await SecureStorage.removePendingEditTyreAt(i);
          i--;
          continue;
        }
        final m = EditTyreModel.fromJson(decoded);
        await EditTyreService.updateTyre(m);
        await SecureStorage.removePendingEditTyreAt(i);
        i--;
        synced++;
      } catch (e) {
        if (_isNetworkError(e) ||
            (e is Exception &&
                e.toString().contains('Session expired') == false &&
                e.toString().contains('Please login') == false &&
                e.toString().contains('HTTP 400') == false)) {
          break;
        }
        await SecureStorage.removePendingEditTyreAt(i);
        i--;
      }
    }

    if (showSnack && synced > 0) {
      Get.snackbar(
        "Sync",
        "$synced tire edit(s) synced",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return synced;
  }

  static Future<void> syncAll({bool showSnack = false}) async {
    await syncPendingCreates(showSnack: showSnack);
    await syncPendingEdits(showSnack: showSnack);
  }
}

