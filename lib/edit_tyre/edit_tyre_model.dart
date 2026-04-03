class EditTyreModel {
  double? averageTreadDepth;

  int? brandNo;

  double? casingValue;

  int? compoundId;

  double? costAdjustment;

  double? currentHours;

  double? currentMiles;

  double? currentPressure;

  double? currentTreadDepth;

  int? dispositionId;

  String? evaluationNo;

  int? fillTypeId;

  double? fillCost;

  int? indCodeId;

  double? insideTread;

  bool? isEditable;

  bool? isMountToRim;

  String? imagesLocation;

  String? lotNo;

  int? loadRatingId;

  String? mileageType;

  double? middleTread;

  int? manufacturerId;

  String? mountStatus;

  int? mountedRimId;

  String? mountedRimSerialNo;

  double? netCost;

  int? numberOfRetreads;

  double? originalTread;

  double? outsideTread;

  int? parentAccountId;

  double? percentageWorn;

  int? plyId;

  String? poNo;

  double? purchaseCost;

  double? purchasedTread;

  int? repairCount;

  double? repairCost;

  String? registeredDate;

  double? removeAt;

  int? retreadCount;

  double? retreadCost;

  double? recommendedPressure;

  int? sizeId;

  double? soldAmount;

  int? speedRatingId;

  int? starRatingId;

  int? tireId;

  String? tireSerialNo;

  int? tireStatusId;

  int? trackingMethod;

  int? typeId;

  int? vehicleId;

  String? vehicleNumber;

  int? locationId;

  double? warrantyAdjustment;

  String? wheelPosition;

  // ---------------- CONSTRUCTOR ----------------

  EditTyreModel({
    this.averageTreadDepth,
    this.brandNo,
    this.casingValue,
    this.compoundId,
    this.costAdjustment,
    this.currentHours,
    this.currentMiles,
    this.currentPressure,
    this.currentTreadDepth,
    this.dispositionId,
    this.evaluationNo,
    this.fillTypeId,
    this.fillCost,
    this.indCodeId,
    this.insideTread,
    this.isEditable,
    this.isMountToRim,
    this.imagesLocation,
    this.lotNo,
    this.loadRatingId,
    this.mileageType = '1',
    this.middleTread,
    this.manufacturerId,
    this.mountStatus = 'Not Mounted',
    this.mountedRimId,
    this.mountedRimSerialNo,
    this.netCost,
    this.numberOfRetreads = 0,
    this.originalTread,
    this.outsideTread,
    this.parentAccountId,
    this.percentageWorn,
    this.plyId,
    this.poNo,
    this.purchaseCost,
    this.purchasedTread,
    this.repairCount,
    this.repairCost,
    this.registeredDate,
    this.removeAt,
    this.retreadCount,
    this.retreadCost,
    this.recommendedPressure,
    this.sizeId,
    this.soldAmount,
    this.speedRatingId,
    this.starRatingId,
    this.tireId,
    this.tireSerialNo,
    this.tireStatusId,
    this.trackingMethod = 0,
    this.typeId,
    this.vehicleId,
    this.vehicleNumber,
    this.locationId,
    this.warrantyAdjustment,
    this.wheelPosition,
  });

  // ---------------- FROM JSON ----------------

  factory EditTyreModel.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return EditTyreModel(
      averageTreadDepth: safeDouble(json['averageTreadDepth']),
      brandNo: safeInt(json['brandNo']),
      casingValue: safeDouble(json['casingValue']),
      compoundId: safeInt(json['compoundId']),
      costAdjustment: safeDouble(json['costAdjustment']),
      currentHours: safeDouble(json['currentHours']),
      currentMiles: safeDouble(json['currentMiles']),
      currentPressure: safeDouble(json['currentPressure']),
      currentTreadDepth: safeDouble(json['currentTreadDepth']),
      dispositionId: safeInt(json['dispositionId']),
      evaluationNo: json['evaluationNo']?.toString() ?? '',
      fillTypeId: safeInt(json['fillTypeId']),
      fillCost: safeDouble(json['fillCost']),
      indCodeId: safeInt(json['indCodeId']),
      insideTread: safeDouble(json['insideTread']),
      isEditable: json['isEditable'] ?? false,
      isMountToRim: json['isMountToRim'] ?? false,
      imagesLocation: json['imagesLocation']?.toString(),
      lotNo: json['lotNo']?.toString() ?? '',
      loadRatingId: safeInt(json['loadRatingId']),
      mileageType: json['mileageType']?.toString() ?? '1',
      middleTread: safeDouble(json['middleTread']),
      manufacturerId: safeInt(json['manufacturerId']),
      mountStatus: json['mountStatus']?.toString() ?? 'Not Mounted',
      mountedRimId: safeInt(json['mountedRimId']),
      mountedRimSerialNo: json['mountedRimSerialNo']?.toString(),
      netCost: safeDouble(json['netCost']),
      numberOfRetreads: safeInt(json['numberOfRetreads']),
      originalTread: safeDouble(json['originalTread']),
      outsideTread: safeDouble(json['outsideTread']),
      parentAccountId: safeInt(json['parentAccountId']),
      percentageWorn: safeDouble(json['percentageWorn']),
      plyId: safeInt(json['plyId']),
      poNo: json['poNo']?.toString() ?? '',
      purchaseCost: safeDouble(json['purchaseCost']),
      purchasedTread: safeDouble(json['purchasedTread']),
      repairCount: safeInt(json['repairCount']),
      repairCost: safeDouble(json['repairCost']),
      registeredDate: json['registeredDate']?.toString() ?? '',
      removeAt: safeDouble(json['removeAt']),
      retreadCount: safeInt(json['retreadCount']),
      retreadCost: safeDouble(json['retreadCost']),
      recommendedPressure: safeDouble(json['recommendedPressure']),
      sizeId: safeInt(json['sizeId']),
      soldAmount: safeDouble(json['soldAmount']),
      speedRatingId: safeInt(json['speedRatingId']),
      starRatingId: safeInt(json['starRatingId']),
      tireId: safeInt(json['tireId']),
      tireSerialNo: json['tireSerialNo']?.toString() ?? '',
      tireStatusId: safeInt(json['tireStatusId']),
      trackingMethod: safeInt(json['trackingMethod']),
      typeId: safeInt(json['typeId']),
      vehicleId: safeInt(json['vehicleId']),
      vehicleNumber: json['vehicleNumber']?.toString(),
      locationId: safeInt(json['locationId']),
      warrantyAdjustment: safeDouble(json['warrantyAdjustment']),
      wheelPosition: json['wheelPosition']?.toString(),
    );
  }

  // ---------------- TO JSON ----------------

  Map<String, dynamic> toJson() {
    final data = {
      "averageTreadDepth": averageTreadDepth,
      "brandNo": brandNo,
      "casingValue": casingValue,
      "compoundId": compoundId,
      "costAdjustment": costAdjustment,
      "currentHours": currentHours,
      "currentMiles": currentMiles,
      "currentPressure": currentPressure,
      "currentTreadDepth": currentTreadDepth,
      "dispositionId": dispositionId,
      "evaluationNo": evaluationNo?.isEmpty == true ? null : evaluationNo,
      "fillTypeId": fillTypeId,
      "fillCost": fillCost,
      "indCodeId": indCodeId,
      "insideTread": insideTread,
      "isEditable": isEditable,
      "isMountToRim": isMountToRim,
      "imagesLocation": imagesLocation,
      "lotNo": lotNo?.isEmpty == true ? null : lotNo,
      "loadRatingId": loadRatingId,
      "mileageType": mileageType,
      "middleTread": middleTread,
      "manufacturerId": manufacturerId,
      "mountStatus": mountStatus,
      "mountedRimId": mountedRimId,
      "mountedRimSerialNo": mountedRimSerialNo,
      "netCost": netCost,
      "numberOfRetreads": numberOfRetreads,
      "originalTread": originalTread,
      "outsideTread": outsideTread,
      "parentAccountId": parentAccountId,
      "percentageWorn": percentageWorn,
      "plyId": plyId,
      "poNo": poNo?.isEmpty == true ? null : poNo,
      "purchaseCost": purchaseCost,
      "purchasedTread": purchasedTread,
      "repairCount": repairCount,
      "repairCost": repairCost,
      "registeredDate": registeredDate,
      "removeAt": removeAt,
      "retreadCount": retreadCount,
      "retreadCost": retreadCost,
      "recommendedPressure": recommendedPressure,
      "sizeId": sizeId,
      "soldAmount": soldAmount,
      "speedRatingId": speedRatingId,
      "starRatingId": starRatingId,
      "tireId": tireId,
      "tireSerialNo": tireSerialNo,
      "tireStatusId": tireStatusId,
      "trackingMethod": trackingMethod,
      "typeId": typeId,
      if (vehicleId != null && vehicleId != 0) "vehicleId": vehicleId,
      if (vehicleNumber != null && vehicleNumber!.isNotEmpty) "vehicleNumber": vehicleNumber,
      "locationId": locationId,
      "warrantyAdjustment": warrantyAdjustment,
      "wheelPosition": wheelPosition,
    };

    return _removeNulls(data);
  }
}

Map<String, dynamic> _removeNulls(Map<String, dynamic> data) {
  data.removeWhere((key, value) => value == null);
  return data;
}
