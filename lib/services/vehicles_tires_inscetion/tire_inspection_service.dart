import 'package:emtrack/models/vehicles_tires_inscetion/tires_inspection_model.dart';

class TyreInspectionService {
  static Future<List<TyreInspectionModel>> fetchTyres() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      TyreInspectionModel(
        serialNo: "TR-001",
        brand: "Bridgestone",
        rimSerial: "RIM-88",
        vehicleId: "VH-102",
        wheelPosition: "2L",
        location: "Delhi",
        disposition: "Inventory",
        manufacturer: "Bridgestone",
        type: "Radial",
      ),
      TyreInspectionModel(
        serialNo: "TR-002",
        brand: "MRF",
        rimSerial: "RIM-99",
        vehicleId: "VH-103",
        wheelPosition: "1R",
        location: "Pune",
        disposition: "Mounted",
        manufacturer: "MRF",
        type: "Tubeless",
      ),
    ];
  }
}
