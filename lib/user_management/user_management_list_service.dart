import 'package:emtrack/models/user_models.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';

import 'user_list_model.dart';

class UserManagementListService {
  /// GET USERS
  Future<List<UserlListModel>> getUsers() async {
    try {
      final response = await ApiService.getApi(
        endpoint: ApiConstants.getAllUserList,
      );
      if (response['model'] != null || response['model'].length > 0) {
        final result = (response['model'] as List)
            .map((e) => UserlListModel.fromJson(e))
            .toList();
        return result;
      }
      return [];
    } catch (e) {
      print("Error fetching users: $e");
      throw Exception("Failed to load users");
    }
  }

  /// DELETE USER
  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
