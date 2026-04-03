class RemoveTyreModel {
  String action;
  String inspectionDate;
  int locationId;
  int parentAccountId;
  int vehicleId;
  int inspectionId;
  int tireId;

  double currentHours;
  double currentMiles;

  String imagesLocation;
  String tireSerialNo;
  String brandNumber;

  double originalTread;
  double removeAt;
  double outsideTread;
  double middleTread;
  double insideTread;
  double currentTreadDepth;
  double currentPressure;

  int pressureUnitId;
  int casingConditionId;
  int wearConditionId;

  String comments;
  int removalReasonId;
  int dispositionId;
  int rimDispositionId;

  String wheelPosition;
  int mountedRimId;

  String createdBy;
  String pressureType;

  double hoursAdjustToTire;
  double milesAdjustToTire;

  bool isMobInstall;

  RemoveTyreModel({
    required this.action,
    required this.inspectionDate,
    required this.locationId,
    required this.parentAccountId,
    required this.vehicleId,
    required this.inspectionId,
    required this.tireId,
    this.currentHours = 0.0,
    this.currentMiles = 0.0,
    this.imagesLocation = "",
    this.tireSerialNo = "",
    this.brandNumber = "",
    this.originalTread = 0.0,
    this.removeAt = 0.0,
    this.outsideTread = 0.0,
    this.middleTread = 0.0,
    this.insideTread = 0.0,
    this.currentTreadDepth = 0.0,
    this.currentPressure = 0.0,
    this.pressureUnitId = 1,
    this.casingConditionId = 0,
    this.wearConditionId = 0,
    this.comments = "",
    required this.removalReasonId,
    required this.dispositionId,
    this.rimDispositionId = 0,
    required this.wheelPosition,
    this.mountedRimId = 0,
    this.createdBy = "mobile",
    this.pressureType = "PSI",
    this.hoursAdjustToTire = 0.0,
    this.milesAdjustToTire = 0.0,
    this.isMobInstall = false,
  });

  Map<String, dynamic> toJson() => {
    "action": action,
    "inspectionDate": inspectionDate,
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

class RemovalReason {
  final int id;
  final String name;

  RemovalReason({required this.id, required this.name});
}
