import 'dart:convert';
import 'package:emtrack/models/grand_parent_account_model/grandparent_account_list_model.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
class GrandparentAccountListService {
  static const String _endpoint = "/api/GrandParentAccount/GetAll";

  Future<PaginatedResponse<GrandparentAccountList>> fetchAccounts({
    required int page,
    required int pageSize,
    required String search,
  }) async {
    try {
      final cookie = await SecureStorage.getCookie();
      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      // 🔹 API (agar backend pagination support karta ho)
      final url = Uri.parse(
        "${ApiConstants.baseUrl}$_endpoint?page=$page&pageSize=$pageSize&search=$search",
      );

      final response = await http.get(
        url,
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      if (response.statusCode != 200) {
        throw Exception("API failed: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);

      /// 🔹 API response handling
      List<dynamic> list = [];
      int totalCount = 0;

      if (decoded is Map) {
        list = decoded['model'] ?? decoded['data'] ?? [];
        totalCount = decoded['totalCount'] ?? list.length;
      } else if (decoded is List) {
        list = decoded;
        totalCount = decoded.length;
      }

      final items = list
          .map(
            (e) => GrandparentAccountList.fromJson(e as Map<String, dynamic>),
          )
          .where(
            (e) =>
                e.name.toLowerCase().contains(search.toLowerCase()) ||
                e.ownedBy.toLowerCase().contains(search.toLowerCase()),
          )
          .toList();

      return PaginatedResponse(items: items, totalCount: totalCount);
    } catch (e) {
      throw Exception("Error fetching accounts: $e");
    }
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;

  PaginatedResponse({required this.items, required this.totalCount});
}
