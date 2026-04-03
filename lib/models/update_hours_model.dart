class UpdateHoursModel {
  String? action;
  DateTime? inspectionDate;
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
  double? outsideTread;
  double? middleTread;
  double? insideTread;
  double? currentTreadDepth;
  double? currentPressure;
  int? pressureUnitId;
  int? casingConditionId;
  int? wearConditionId;
  String? comments;
  int? removalReasonId;
  int? dispositionId;
  int? rimDispositionId;
  String? wheelPosition;
  int? mountedRimId;
  String? createdBy;
  String? pressureType;
  double? hoursAdjustToTire;
  double? milesAdjustToTire;
  bool? isMobInstall;

  UpdateHoursModel({
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
    this.outsideTread,
    this.middleTread,
    this.insideTread,
    this.currentTreadDepth,
    this.currentPressure,
    this.pressureUnitId,
    this.casingConditionId,
    this.wearConditionId,
    this.comments,
    this.removalReasonId,
    this.dispositionId,
    this.rimDispositionId,
    this.wheelPosition,
    this.mountedRimId,
    this.createdBy,
    this.pressureType,
    this.hoursAdjustToTire,
    this.milesAdjustToTire,
    this.isMobInstall,
  });

  factory UpdateHoursModel.fromJson(Map<String, dynamic> json) =>
      UpdateHoursModel(
        action: json["action"],
        inspectionDate: json["inspectionDate"] != null
            ? DateTime.parse(json["inspectionDate"])
            : null,
        locationId: json["locationId"],
        parentAccountId: json["parentAccountId"],
        vehicleId: json["vehicleId"],
        inspectionId: json["inspectionId"],
        tireId: json["tireId"],
        currentHours: json["currentHours"]?.toDouble(),
        currentMiles: json["currentMiles"]?.toDouble(),
        imagesLocation: json["imagesLocation"],
        tireSerialNo: json["tireSerialNo"],
        brandNumber: json["brandNumber"],
        originalTread: json["originalTread"]?.toDouble(),
        removeAt: json["removeAt"]?.toDouble(),
        outsideTread: json["outsideTread"]?.toDouble(),
        middleTread: json["middleTread"]?.toDouble(),
        insideTread: json["insideTread"]?.toDouble(),
        currentTreadDepth: json["currentTreadDepth"]?.toDouble(),
        currentPressure: json["currentPressure"]?.toDouble(),
        pressureUnitId: json["pressureUnitId"],
        casingConditionId: json["casingConditionId"],
        wearConditionId: json["wearConditionId"],
        comments: json["comments"],
        removalReasonId: json["removalReasonId"],
        dispositionId: json["dispositionId"],
        rimDispositionId: json["rimDispositionId"],
        wheelPosition: json["wheelPosition"],
        mountedRimId: json["mountedRimId"],
        createdBy: json["createdBy"],
        pressureType: json["pressureType"],
        hoursAdjustToTire: json["hoursAdjustToTire"]?.toDouble(),
        milesAdjustToTire: json["milesAdjustToTire"]?.toDouble(),
        isMobInstall: json["isMobInstall"],
      );

  Map<String, dynamic> toJson() {
    final data = {
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

    // 🔥 REMOVE ALL NULL VALUES
    data.removeWhere((key, value) => value == null);

    return data;
  }
}
