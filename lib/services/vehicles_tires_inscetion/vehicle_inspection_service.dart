import 'package:emtrack/models/vehicles_tires_inscetion/vehicle_inspection_model.dart';

class VehicleInspectionService {
  Future<List<VehicleInspectionModel>> fetchVehicles() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      VehicleInspectionModel(
        vehicleId: 101,
        asset: "Truck-01",
        location: "Delhi",
        type: "Truck",
        make: "Tata",
        model: "Prima",
        axleConfig: "6x4",
        hours: 2450,
        kilometers: 78000,
        lastRecord: "12-Jan-2026",
      ),
      VehicleInspectionModel(
        vehicleId: 102,
        asset: "Truck-02",
        location: "Mumbai",
        type: "Trailer",
        make: "Ashok Leyland",
        model: "AVTR",
        axleConfig: "4x2",
        hours: 1890,
        kilometers: 62000,
        lastRecord: "10-Jan-2026",
      ),
    ];
  }
}
