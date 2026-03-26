class AllVehicleModel {
  final int? vehicleId;
  final String? vehicleNumber;

  final int? locationId;
  final String? locationName;

  final int? parentAccountId;
  final String? parentAccountName;

  final String? mileageType;

  final int? manufacturerId;
  final String? manufacturer;

  final int? typeId;
  final String? typeName;

  final int? modelId;
  final String? modelName;

  final String? registeredDate;

  final int? tireSizeId;
  final String? tireSize;

  final String? axleConfig;
  final int? axleConfigId;

  final double? currentMiles;
  final double? currentHours;

  final double? removalTread;

  final double? recommendedPressure; // ⚠️ string se convert karenge

  final String? severityComments;

  final String? vehicleIcon;

  AllVehicleModel({
    this.vehicleId,
    this.vehicleNumber,
    this.locationId,
    this.locationName,
    this.parentAccountId,
    this.parentAccountName,
    this.mileageType,
    this.manufacturerId,
    this.manufacturer,
    this.typeId,
    this.typeName,
    this.modelId,
    this.modelName,
    this.registeredDate,
    this.tireSizeId,
    this.tireSize,
    this.axleConfig,
    this.axleConfigId,
    this.currentMiles,
    this.currentHours,
    this.removalTread,
    this.recommendedPressure,
    this.severityComments,
    this.vehicleIcon,
  });

  factory AllVehicleModel.fromJson(Map<String, dynamic> json) {
    return AllVehicleModel(
      vehicleId: json['vehicleId'],
      vehicleNumber: json['vehicleNumber'],

      locationId: json['locationId'],
      locationName: json['locationName'],

      parentAccountId: json['parentAccountId'],
      parentAccountName: json['parentAccountName'],

      mileageType: json['mileageType'],

      manufacturerId: json['manufacturerId'],
      manufacturer: json['manufacturer'],

      typeId: json['typeId'],
      typeName: json['typeName'],

      modelId: json['modelId'],
      modelName: json['modelName'],

      registeredDate: json['registeredDate'],

      tireSizeId: json['tireSizeId'],
      tireSize: json['tireSize'],

      axleConfig: json['axleConfig'],
      axleConfigId: json['axleConfigId'],

      currentMiles: (json['currentMiles'] as num?)?.toDouble(),
      currentHours: (json['currentHours'] as num?)?.toDouble(),

      removalTread: (json['removalTread'] as num?)?.toDouble(),

      // 🔥 IMPORTANT FIX (String -> double safe conversion)
      recommendedPressure: json['recommendedPressure'] == null
          ? null
          : double.tryParse(json['recommendedPressure'].toString()),

      severityComments: json['severityComments'],
      vehicleIcon: json['vehicleIcon'],
    );
  }
}
