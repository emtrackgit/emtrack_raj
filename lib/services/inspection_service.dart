import '../models/inspection_model.dart';
import 'api_service.dart';

class InspectionService {
  Future<List<InspectionModel>> getInspections() async {
    final resp = await ApiService.getApi(
      endpoint: "/api/InspMobRequests/GetUserInspDataRequests",
    );

    if (resp is! Map<String, dynamic>) return [];
    if (resp['didError'] == true) return [];

    final model = resp['model'];
    if (model is! List) return [];

    return model
        .whereType<Map<String, dynamic>>()
        .map((e) => InspectionModel.fromJson(e))
        .toList();
  }
}
