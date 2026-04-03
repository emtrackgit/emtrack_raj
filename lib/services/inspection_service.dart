import '../models/inspection_model.dart';

class InspectionService {
  Future<List<InspectionModel>> getInspections() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      InspectionModel(id: '1', vehicleNo: 'MH12AB1234', isSynced: false),
      InspectionModel(id: '2', vehicleNo: 'MH14XY5678', isSynced: false),
      InspectionModel(id: '3', vehicleNo: 'MH01AA0001', isSynced: true),
    ];
  }
}
