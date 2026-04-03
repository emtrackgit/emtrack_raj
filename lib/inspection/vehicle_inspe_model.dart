class VehicleInspectionResponse {
  String? message;
  bool? didError;
  String? errorMessage;
  int? httpStatusCode;
  VehicleInspectionModel? model;

  VehicleInspectionResponse({
    this.message,
    this.didError,
    this.errorMessage,
    this.httpStatusCode,
    this.model,
  });

  factory VehicleInspectionResponse.fromJson(Map<String, dynamic> json) {
    return VehicleInspectionResponse(
      message: json['message'],
      didError: json['didError'],
      errorMessage: json['errorMessage'],
      httpStatusCode: json['httpStatusCode'],
      model: json['model'] != null
          ? VehicleInspectionModel.fromJson(json['model'])
          : null,
    );
  }
}

class VehicleInspectionModel {
  int? vehicleId;
  int? locationId;
  String? vehicleNumber;
  String? vehicleManufacturer;
  String? vehicleType;
  String? vehicleModel;
  String? vehicleMileageType;
  String? axleConfig;
  String? tireSize;
  int? tireSizeId;
  double? lastRecordedHours;
  double? lastRecordedMiles;
  String? lastRecordedDate;
  String? comments;

  List<InstalledTire>? installedTires;
  List<dynamic>? installedRims;

  String? lastUpdatedDate;
  bool? hasMultipleTireSizes;
  dynamic multipleTireSizeIds;
  String? multipleTireSizeNames;

  VehicleInspectionModel({
    this.vehicleId,
    this.locationId,
    this.vehicleNumber,
    this.vehicleManufacturer,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleMileageType,
    this.axleConfig,
    this.tireSize,
    this.tireSizeId,
    this.lastRecordedHours,
    this.lastRecordedMiles,
    this.lastRecordedDate,
    this.comments,
    this.installedTires,
    this.installedRims,
    this.lastUpdatedDate,
    this.hasMultipleTireSizes,
    this.multipleTireSizeIds,
    this.multipleTireSizeNames,
  });

  factory VehicleInspectionModel.fromJson(Map<String, dynamic> json) {
    return VehicleInspectionModel(
      vehicleId: json['vehicleId'],
      locationId: json['locationId'],
      vehicleNumber: json['vehicleNumber'],
      vehicleManufacturer: json['vehicleManufacturer'],
      vehicleType: json['vehicleType'],
      vehicleModel: json['vehicleModel'],
      vehicleMileageType: json['vehicleMileageType'],
      axleConfig: json['axleConfig'],
      tireSize: json['tireSize'],
      tireSizeId: json['tireSizeId'],
      lastRecordedHours: (json['lastRecordedHours'] as num?)?.toDouble(),
      lastRecordedMiles: (json['lastRecordedMiles'] as num?)?.toDouble(),
      lastRecordedDate: json['lastRecordedDate'],
      comments: json['comments'],
      installedTires: json['installedTires'] != null
          ? List<InstalledTire>.from(
              json['installedTires'].map((x) => InstalledTire.fromJson(x)),
            )
          : [],
      installedRims: json['installedRims'],
      lastUpdatedDate: json['lastUpdatedDate'],
      hasMultipleTireSizes: json['hasMultipleTireSizes'],
      multipleTireSizeIds: json['multipleTireSizeIds'],
      multipleTireSizeNames: json['multipleTireSizeNames'],
    );
  }
}

class InstalledTire {
  int? tireId;
  int? locationId;
  int? parentAccountId;
  String? tireSerialNo;
  String? registeredDate;
  int? manufacturerId;
  int? typeId;
  int? sizeId;
  String? sizeName;
  String? typeName;
  double? currentHours;
  double? currentMiles;
  String? wheelPosition;
  double? percentageWorn;
  dynamic wearNonSkid;
  double? currentTreadDepth;
  double? currentPressure;
  dynamic wearConditionId;
  dynamic casingConditionId;
  dynamic mountedRimId;
  double? outsideTread;
  double? middleTread;
  double? insideTread;
  double? originalTread;
  double? removeAt;
  String? comments;
  String? inspectionDate;
  String? mileageType;
  dynamic imagesLocation;
  String? brandNo;
  int? dispositionId;
  String? createdBy;
  String? manufacturerName;
  dynamic pressureType;
  int? vehicleId;
  dynamic removalReasonId;

  InstalledTire({
    this.tireId,
    this.locationId,
    this.parentAccountId,
    this.tireSerialNo,
    this.registeredDate,
    this.manufacturerId,
    this.typeId,
    this.sizeId,
    this.sizeName,
    this.typeName,
    this.currentHours,
    this.currentMiles,
    this.wheelPosition,
    this.percentageWorn,
    this.wearNonSkid,
    this.currentTreadDepth,
    this.currentPressure,
    this.wearConditionId,
    this.casingConditionId,
    this.mountedRimId,
    this.outsideTread,
    this.middleTread,
    this.insideTread,
    this.originalTread,
    this.removeAt,
    this.comments,
    this.inspectionDate,
    this.mileageType,
    this.imagesLocation,
    this.brandNo,
    this.dispositionId,
    this.createdBy,
    this.manufacturerName,
    this.pressureType,
    this.vehicleId,
    this.removalReasonId,
  });

  factory InstalledTire.fromJson(Map<String, dynamic> json) {
    return InstalledTire(
      tireId: json['tireId'],
      locationId: json['locationId'],
      parentAccountId: json['parentAccountId'],
      tireSerialNo: json['tireSerialNo'],
      registeredDate: json['registeredDate'],
      manufacturerId: json['manufacturerId'],
      typeId: json['typeId'],
      sizeId: json['sizeId'],
      sizeName: json['sizeName'],
      typeName: json['typeName'],
      currentHours: (json['currentHours'] as num?)?.toDouble(),
      currentMiles: (json['currentMiles'] as num?)?.toDouble(),
      wheelPosition: json['wheelPosition'],
      percentageWorn: (json['percentageWorn'] as num?)?.toDouble(),
      wearNonSkid: json['wearNonSkid'],
      currentTreadDepth: (json['currentTreadDepth'] as num?)?.toDouble(),
      currentPressure: (json['currentPressure'] as num?)?.toDouble(),
      wearConditionId: json['wearConditionId'],
      casingConditionId: json['casingConditionId'],
      mountedRimId: json['mountedRimId'],
      outsideTread: (json['outsideTread'] as num?)?.toDouble(),
      middleTread: (json['middleTread'] as num?)?.toDouble(),
      insideTread: (json['insideTread'] as num?)?.toDouble(),
      originalTread: (json['originalTread'] as num?)?.toDouble(),
      removeAt: (json['removeAt'] as num?)?.toDouble(),
      comments: json['comments'],
      inspectionDate: json['inspectionDate'],
      mileageType: json['mileageType'],
      imagesLocation: json['imagesLocation'],
      brandNo: json['brandNo'],
      dispositionId: json['dispositionId'],
      createdBy: json['createdBy'],
      manufacturerName: json['manufacturerName'],
      pressureType: json['pressureType'],
      vehicleId: json['vehicleId'],
      removalReasonId: json['removalReasonId'],
    );
  }
}
