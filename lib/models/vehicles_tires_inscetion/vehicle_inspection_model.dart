class VehicleInspectionModel {
  final int vehicleId;
  final String asset;
  final String location;
  final String type;
  final String make;
  final String model;
  final String axleConfig;
  final double hours;
  final double kilometers;
  final String lastRecord;
  String status; // Pending / Approved / Rejected

  VehicleInspectionModel({
    required this.vehicleId,
    required this.asset,
    required this.location,
    required this.type,
    required this.make,
    required this.model,
    required this.axleConfig,
    required this.hours,
    required this.kilometers,
    required this.lastRecord,
    this.status = "Pending",
  });

  factory VehicleInspectionModel.fromJson(Map<String, dynamic> json) {
    return VehicleInspectionModel(
      vehicleId: json['vehicleId'],
      asset: json['asset'],
      location: json['location'],
      type: json['type'],
      make: json['make'],
      model: json['model'],
      axleConfig: json['axleConfig'],
      hours: (json['hours'] ?? 0).toDouble(),
      kilometers: (json['kilometers'] ?? 0).toDouble(),
      lastRecord: json['lastRecord'],
      status: json['status'] ?? "Pending",
    );
  }
}
