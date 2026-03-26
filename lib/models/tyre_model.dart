class TyreModel {
  // 🔹 Existing fields
  final int? tireId;
  final String? tireSerialNo;

  final int? vehicleId;
  final String? vehicleNumber;

  final int? locationId;
  final String? locationName;

  final int? parentAccountId;

  final String? brandNo;

  final int? typeId;
  final int? sizeId;
  final String? sizeName;
  final String? typeName;

  final int? manufacturerId;
  final String? manufacturerName;

  final double? currentHours;
  final double? currentMiles;
  final double? currentTreadDepth;
  final double? averageTreadDepth;
  final double? percentageWorn;
  final double? originalTread;
  final double? purchasedTread;
  final double? removeAt;

  final String? mileageType;

  final int? dispositionId;
  final String? dispositionName;
  final String? tireStatusName;
  final int? dispositionGroupId;

  final bool? isMountToRim;

  final int? compoundId;
  final String? compoundName;

  final double? recommendedPressure;
  final double? currentPressure;

  final String? wheelPosition;

  final String? lotNo;
  final String? evaluationNo;
  final String? ratingName;

  final int? plyId;
  final int? loadRatingId;
  final int? speedRatingId;
  final int? starRatingId;

  final double? costAdjustment;
  final double? purchaseCost;
  final double? casingValue;
  final double? fillCost;
  final double? repairCost;
  final double? retreadCost;

  final int? repairCount;
  final int? retreadCount;

  final int? fillTypeId;
  final int? typeOfTire;
  final String? compoundCode;

  // 🔹 Inspection fields
  final double? outsideTread;
  final double? insideTread;
  final String? comments;
  final int? casingConditionId;
  final int? wearConditionId;

  TyreModel({
    this.tireId,
    this.tireSerialNo,
    this.vehicleId,
    this.vehicleNumber,
    this.locationId,
    this.locationName,
    this.parentAccountId,
    this.brandNo,
    this.typeId,
    this.sizeId,
    this.sizeName,
    this.typeName,
    this.manufacturerId,
    this.manufacturerName,
    this.currentHours,
    this.currentMiles,
    this.currentTreadDepth,
    this.averageTreadDepth,
    this.percentageWorn,
    this.originalTread,
    this.purchasedTread,
    this.removeAt,
    this.mileageType,
    this.dispositionId,
    this.dispositionName,
    this.tireStatusName,
    this.dispositionGroupId,
    this.isMountToRim,
    this.compoundId,
    this.compoundName,
    this.recommendedPressure,
    this.currentPressure,
    this.wheelPosition,
    this.lotNo,
    this.evaluationNo,
    this.ratingName,
    this.plyId,
    this.loadRatingId,
    this.speedRatingId,
    this.starRatingId,
    this.costAdjustment,
    this.purchaseCost,
    this.casingValue,
    this.fillCost,
    this.repairCost,
    this.retreadCost,
    this.repairCount,
    this.retreadCount,
    this.fillTypeId,
    this.typeOfTire,
    this.compoundCode,
    this.outsideTread,
    this.insideTread,
    this.comments,
    this.casingConditionId,
    this.wearConditionId,
  });

  factory TyreModel.fromJson(Map<String, dynamic> json) {
    return TyreModel(
      tireId: _toInt(json['tireId']),
      tireSerialNo: json['tireSerialNo']?.toString(),

      vehicleId: _toInt(json['vehicleId']),
      vehicleNumber: json['vehicleNumber']?.toString(),

      locationId: _toInt(json['locationId']),
      locationName: json['locationName']?.toString(),

      parentAccountId: _toInt(json['parentAccountId']),

      brandNo: json['brandNo']?.toString(),

      typeId: _toInt(json['typeId']),
      sizeId: _toInt(json['sizeId']),
      sizeName: json['sizeName']?.toString(),
      typeName: json['typeName']?.toString(),

      manufacturerId: _toInt(json['manufacturerId']),
      manufacturerName: json['manufacturerName']?.toString(),

      currentHours: _toDouble(json['currentHours']),
      currentMiles: _toDouble(json['currentMiles']),
      currentTreadDepth: _toDouble(json['currentTreadDepth']),
      averageTreadDepth: _toDouble(json['averageTreadDepth']),
      percentageWorn: _toDouble(json['percentageWorn']),
      originalTread: _toDouble(json['originalTread']),
      purchasedTread: _toDouble(json['purchasedTread']),
      removeAt: _toDouble(json['removeAt']),

      mileageType: json['mileageType']?.toString(),

      dispositionId: _toInt(json['dispositionId']),
      dispositionName: json['dispositionName']?.toString(),
      tireStatusName: json['tireStatusName']?.toString(),
      dispositionGroupId: _toInt(json['dispositionGroupId']),

      isMountToRim: json['isMountToRim'] as bool?,

      compoundId: _toInt(json['compoundId']),
      compoundName: json['compoundName']?.toString(),
      compoundCode: json['compoundCode']?.toString(),

      recommendedPressure: _toDouble(json['recommendedPressure']),
      currentPressure: _toDouble(json['currentPressure']),

      wheelPosition: json['wheelPosition']?.toString(),
      lotNo: json['lotNo']?.toString(),
      evaluationNo: json['evaluationNo']?.toString(),
      ratingName: json['ratingName']?.toString(),

      plyId: _toInt(json['plyId']),
      loadRatingId: _toInt(json['loadRatingId']),
      speedRatingId: _toInt(json['speedRatingId']),
      starRatingId: _toInt(json['starRatingId']),

      costAdjustment: _toDouble(json['costAdjustment']),
      purchaseCost: _toDouble(json['purchaseCost']),
      casingValue: _toDouble(json['casingValue']),
      fillCost: _toDouble(json['fillCost']),
      repairCost: _toDouble(json['repairCost']),
      retreadCost: _toDouble(json['retreadCost']),

      repairCount: _toInt(json['repairCount']),
      retreadCount: _toInt(json['retreadCount']),

      fillTypeId: _toInt(json['fillTypeId']),
      typeOfTire: _toInt(json['typeOfTire']),

      // 🔹 Inspection fields
      outsideTread: _toDouble(json['outsideTread']),
      insideTread: _toDouble(json['insideTread']),
      comments: json['comments']?.toString(),
      casingConditionId: _toInt(json['casingConditionId']),
      wearConditionId: _toInt(json['wearConditionId']),
    );
  }
}

// int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
// double? _toDouble(dynamic v) =>
//     v == null ? null : double.tryParse(v.toString());


int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}