class LocationVehicleModel {
  final int vehicleId;
  final String vehicleNumber;
  final String typeName;
  final String modelName;
  final String axleConfig;
  final String manufacturerName;
  final double currentHours;
  final double currentMiles;
  final String? lastRead;
  final String? assetNumber;

  LocationVehicleModel({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.typeName,
    required this.modelName,
    required this.axleConfig,
    required this.manufacturerName,
    required this.currentHours,
    required this.currentMiles,
    this.lastRead,
    this.assetNumber,
  });

  factory LocationVehicleModel.fromJson(Map<String, dynamic> json) {
    return LocationVehicleModel(
      vehicleId: json['vehicleId'] ?? 0,
      vehicleNumber: json['vehicleNumber'] ?? '',
      typeName: json['typeName'] ?? '',
      modelName: json['modelName'] ?? '',
      axleConfig: json['axleConfig'] ?? '',
      manufacturerName: json['manufacturerName'] ?? '',
      currentHours: (json['currentHours'] ?? 0).toDouble(),
      currentMiles: (json['currentMiles'] ?? 0).toDouble(),
      lastRead: json['lastRead'],
      assetNumber: json['assetNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'typeName': typeName,
      'modelName': modelName,
      'axleConfig': axleConfig,
      'manufacturerName': manufacturerName,
      'currentHours': currentHours,
      'currentMiles': currentMiles,
      'lastRead': lastRead,
      'assetNumber': assetNumber,
    };
  }
}