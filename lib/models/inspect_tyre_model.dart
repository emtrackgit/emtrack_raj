class InspectTyreModel {
  /// ---------- API FIELDS ----------
  String? action;
  DateTime? inspectionDate;

  double? airPressure;

  int? locationId;
  int? parentAccountId;
  int? vehicleId;
  int? inspectionId;
  int? tireId;

  double? currentHours;
  double? currentMiles;

  String? imagesLocation;
  String? tireSerialNo;
  String? brandNumber;

  double? originalTread;
  double? removeAt;

  double outsideTread;
  double middleTread;
  double insideTread;

  double? currentTreadDepth;

  double currentPressure;
  int? pressureUnitId;

  int? casingConditionId;
  int? wearConditionId;

  String comments;

  int? removalReasonId;
  int? dispositionId;
  int? rimDispositionId;

  String? wheelPosition;
  int? mountedRimId;

  String? createdBy;
  String? pressureType;

  double? hoursAdjustToTire;
  double? milesAdjustToTire;

  bool isMobInstall;

  /// ---------- CONTROLLER / UI EXTRA ----------
  List<String> images;
  String averageTread;

  InspectTyreModel({
    this.airPressure,
    this.action,
    this.inspectionDate,
    this.locationId,
    this.parentAccountId,
    this.vehicleId,
    this.inspectionId,
    this.tireId,
    this.currentHours,
    this.currentMiles,
    this.imagesLocation,
    this.tireSerialNo,
    this.brandNumber,
    this.originalTread,
    this.removeAt,
    this.currentTreadDepth,
    this.pressureUnitId,
    this.casingConditionId,
    this.wearConditionId,
    this.removalReasonId,
    this.dispositionId,
    this.rimDispositionId,
    this.wheelPosition,
    this.mountedRimId,
    this.createdBy,
    this.pressureType,
    this.hoursAdjustToTire,
    this.milesAdjustToTire,
    this.isMobInstall = true,

    /// UI defaults
    this.outsideTread = 0,
    this.middleTread = 0,
    this.insideTread = 0,
    this.currentPressure = 0,
    this.comments = '',
    this.averageTread = "0.00",
    List<String>? images,
  }) : images = images ?? [];

  /// ---------- FROM JSON ----------
  factory InspectTyreModel.fromJson(Map<String, dynamic> json) {
    return InspectTyreModel(
      action: json['action'],
      inspectionDate: json['inspectionDate'] != null
          ? DateTime.parse(json['inspectionDate'])
          : null,
      locationId: json['locationId'],
      parentAccountId: json['parentAccountId'],
      vehicleId: json['vehicleId'],
      inspectionId: json['inspectionId'],
      tireId: json['tireId'],
      currentHours: (json['currentHours'] as num?)?.toDouble(),
      currentMiles: (json['currentMiles'] as num?)?.toDouble(),
      imagesLocation: json['imagesLocation'],
      tireSerialNo: json['tireSerialNo'],
      brandNumber: json['brandNumber'],
      originalTread: (json['originalTread'] as num?)?.toDouble(),
      removeAt: (json['removeAt'] as num?)?.toDouble(),
      outsideTread: (json['outsideTread'] as num?)?.toDouble() ?? 0,
      middleTread: (json['middleTread'] as num?)?.toDouble() ?? 0,
      insideTread: (json['insideTread'] as num?)?.toDouble() ?? 0,
      currentTreadDepth: (json['currentTreadDepth'] as num?)?.toDouble(),
      currentPressure: (json['currentPressure'] as num?)?.toDouble() ?? 0,
      pressureUnitId: json['pressureUnitId'],
      casingConditionId: json['casingConditionId'],
      wearConditionId: json['wearConditionId'],
      comments: json['comments'] ?? '',
      removalReasonId: json['removalReasonId'],
      dispositionId: json['dispositionId'],
      rimDispositionId: json['rimDispositionId'],
      wheelPosition: json['wheelPosition'],
      mountedRimId: json['mountedRimId'],
      createdBy: json['createdBy'],
      pressureType: json['pressureType'],
      hoursAdjustToTire: (json['hoursAdjustToTire'] as num?)?.toDouble(),
      milesAdjustToTire: (json['milesAdjustToTire'] as num?)?.toDouble(),
      isMobInstall: json['isMobInstall'] ?? true,
    );
  }

  /// ---------- TO JSON (PUT API) ----------
  Map<String, dynamic> toJson() {
    return {
      "action": action,
      "inspectionDate": inspectionDate?.toIso8601String(),
      "locationId": locationId,
      "parentAccountId": parentAccountId,
      "vehicleId": vehicleId,
      "inspectionId": inspectionId,
      "tireId": tireId,
      "currentHours": currentHours,
      "currentMiles": currentMiles,
      "imagesLocation": imagesLocation,
      "tireSerialNo": tireSerialNo,
      "brandNumber": brandNumber,
      "originalTread": originalTread,
      "removeAt": removeAt,
      "outsideTread": outsideTread,
      "middleTread": middleTread,
      "insideTread": insideTread,
      "currentTreadDepth": currentTreadDepth,
      "currentPressure": currentPressure,
      "pressureUnitId": pressureUnitId,
      "casingConditionId": casingConditionId,
      "wearConditionId": wearConditionId,
      "comments": comments,
      "removalReasonId": removalReasonId,
      "dispositionId": dispositionId,
      "rimDispositionId": rimDispositionId,
      "wheelPosition": wheelPosition,
      "mountedRimId": mountedRimId,
      "createdBy": createdBy,
      "pressureType": pressureType,
      "hoursAdjustToTire": hoursAdjustToTire,
      "milesAdjustToTire": milesAdjustToTire,
      "isMobInstall": isMobInstall,
    };
  }
}
