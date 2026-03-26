class TyreInspectionModel {
  final String serialNo;
  final String brand;
  final String rimSerial;
  final String vehicleId;
  final String wheelPosition;
  final String location;
  final String disposition;
  final String manufacturer;
  final String type;
  String status; // pending / approved / rejected

  TyreInspectionModel({
    required this.serialNo,
    required this.brand,
    required this.rimSerial,
    required this.vehicleId,
    required this.wheelPosition,
    required this.location,
    required this.disposition,
    required this.manufacturer,
    required this.type,
    this.status = "Pending",
  });
}
