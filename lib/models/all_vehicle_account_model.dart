class AccountAccountVehicleModel {
  int? parentAccountId;
  String? accountName;
  List<LocationModel>? locationList;

  AccountAccountVehicleModel({
    this.parentAccountId,
    this.accountName,
    this.locationList,
  });

  factory AccountAccountVehicleModel.fromJson(Map<String, dynamic> json) {
    return AccountAccountVehicleModel(
      parentAccountId: json['parentAccountId'],
      accountName: json['accountName'],
      locationList: json['locationList'] != null
          ? (json['locationList'] as List)
              .map((e) => LocationModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

class LocationModel {
  int? locationId;
  String? locationName;
  int? tireCount;
  List<AccountVehicleModel>? vehicleList;

  LocationModel({
    this.locationId,
    this.locationName,
    this.tireCount,
    this.vehicleList,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationId: json['locationId'],
      locationName: json['locationName'],
      tireCount: json['tireCount'],
      vehicleList: json['vehicleList'] != null
          ? (json['vehicleList'] as List)
              .map((e) => AccountVehicleModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

class AccountVehicleModel {
  int? vehicleId;
  String? vehicleNumber;
  String? typeName;
  String? modelName;
  String? axleConfig;
  String? manufacturerName;
  double? currentHours;
  double? currentMiles;
  String? lastRead;
  String? assetNumber;

  AccountVehicleModel({
    this.vehicleId,
    this.vehicleNumber,
    this.typeName,
    this.modelName,
    this.axleConfig,
    this.manufacturerName,
    this.currentHours,
    this.currentMiles,
    this.lastRead,
    this.assetNumber,
  });

  factory AccountVehicleModel.fromJson(Map<String, dynamic> json) {
    return AccountVehicleModel(
      vehicleId: json['vehicleId'],
      vehicleNumber: json['vehicleNumber'],
      typeName: json['typeName'],
      modelName: json['modelName'],
      axleConfig: json['axleConfig'],
      manufacturerName: json['manufacturerName'],
      currentHours: (json['currentHours'] ?? 0).toDouble(),
      currentMiles: (json['currentMiles'] ?? 0).toDouble(),
      lastRead: json['lastRead'],
      assetNumber: json['assetNumber'],
    );
  }
}