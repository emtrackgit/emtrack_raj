class TyreViewModel {
  int? tireId;
  String? tireSerialNo;
  int? vehicleId;
  int? locationId;
  int? parentAccountId;
  String? brandNo;
  DateTime? registeredDate;
  String? mileageType;
  double? currentMiles;
  double? currentHours;
  int? dispositionId;
  int? tireStatusId;
  String? wheelPosition;
  bool? isMountToRim;
  int? mountedRimId;
  String? mountedRimSerialNo;
  double? originalTread;
  double? purchasedTread;
  double? removeAt;
  double? outsideTread;
  double? middleTread;
  double? insideTread;
  double? averageTreadDepth;
  double? recommendedPressure;
  double? currentTreadDepth;
  double? currentPressure;
  double? percentageWorn;
  int? manufacturerId;
  int? sizeId;
  int? starRatingId;
  int? plyId;
  int? typeId;
  int? indCodeId;
  int? compoundId;
  int? loadRatingId;
  int? speedRatingId;
  double? purchaseCost;
  double? casingValue;
  int? fillTypeId;
  double? fillCost;
  double? repairCost;
  double? retreadCost;
  int? repairCount;
  int? retreadCount;
  double? costAdjustment;
  double? warrantyAdjustment;
  double? soldAmount;
  double? netCost;
  TireGraphData? tireGraphData;
  String? vehicleNumber;
  dynamic tireHistory;
  List<dynamic>? tireHistory1;
  String? createdBy;
  bool? isEditable;
  String? evaluationNo;
  String? lotNo;
  String? poNo;
  String? imagesLocation;

  TyreViewModel({
    this.tireId,
    this.tireSerialNo,
    this.vehicleId,
    this.locationId,
    this.parentAccountId,
    this.brandNo,
    this.registeredDate,
    this.mileageType,
    this.currentMiles,
    this.currentHours,
    this.dispositionId,
    this.tireStatusId,
    this.wheelPosition,
    this.isMountToRim,
    this.mountedRimId,
    this.mountedRimSerialNo,
    this.originalTread,
    this.purchasedTread,
    this.removeAt,
    this.outsideTread,
    this.middleTread,
    this.insideTread,
    this.averageTreadDepth,
    this.recommendedPressure,
    this.currentTreadDepth,
    this.currentPressure,
    this.percentageWorn,
    this.manufacturerId,
    this.sizeId,
    this.starRatingId,
    this.plyId,
    this.typeId,
    this.indCodeId,
    this.compoundId,
    this.loadRatingId,
    this.speedRatingId,
    this.purchaseCost,
    this.casingValue,
    this.fillTypeId,
    this.fillCost,
    this.repairCost,
    this.retreadCost,
    this.repairCount,
    this.retreadCount,
    this.costAdjustment,
    this.warrantyAdjustment,
    this.soldAmount,
    this.netCost,
    this.tireGraphData,
    this.vehicleNumber,
    this.tireHistory,
    this.tireHistory1,
    this.createdBy,
    this.isEditable,
    this.evaluationNo,
    this.lotNo,
    this.poNo,
    this.imagesLocation,
  });

  factory TyreViewModel.fromJson(Map<String, dynamic> json) {
    return TyreViewModel(
      tireId: json['tireId'],
      tireSerialNo: json['tireSerialNo'],
      vehicleId: json['vehicleId'],
      locationId: json['locationId'],
      parentAccountId: json['parentAccountId'],
      brandNo: json['brandNo'],
      registeredDate: DateTime.parse(json['registeredDate']),
      mileageType: json['mileageType'],
      currentMiles: (json['currentMiles'] as num).toDouble(),
      currentHours: (json['currentHours'] as num).toDouble(),
      dispositionId: json['dispositionId'],
      tireStatusId: json['tireStatusId'],
      wheelPosition: json['wheelPosition'],
      isMountToRim: json['isMountToRim'],
      mountedRimId: json['mountedRimId'],
      mountedRimSerialNo: json['mountedRimSerialNo'],
      originalTread: (json['originalTread'] as num).toDouble(),
      purchasedTread: (json['purchasedTread'] as num).toDouble(),
      removeAt: (json['removeAt'] as num).toDouble(),
      outsideTread: (json['outsideTread'] as num).toDouble(),
      middleTread: (json['middleTread'] as num).toDouble(),
      insideTread: (json['insideTread'] as num).toDouble(),
      averageTreadDepth: json['averageTreadDepth'] != null
          ? (json['averageTreadDepth'] as num).toDouble()
          : null,
      recommendedPressure: json['recommendedPressure'] != null
          ? (json['recommendedPressure'] as num).toDouble()
          : null,
      currentTreadDepth: (json['currentTreadDepth'] as num).toDouble(),
      currentPressure: json['currentPressure'] != null
          ? (json['currentPressure'] as num).toDouble()
          : null,
      percentageWorn: (json['percentageWorn'] as num).toDouble(),
      manufacturerId: json['manufacturerId'],
      sizeId: json['sizeId'],
      starRatingId: json['starRatingId'],
      plyId: json['plyId'],
      typeId: json['typeId'],
      indCodeId: json['indCodeId'],
      compoundId: json['compoundId'],
      loadRatingId: json['loadRatingId'],
      speedRatingId: json['speedRatingId'],
      purchaseCost: (json['purchaseCost'] as num).toDouble(),
      casingValue: (json['casingValue'] as num).toDouble(),
      fillTypeId: json['fillTypeId'],
      fillCost: (json['fillCost'] as num).toDouble(),
      repairCost: (json['repairCost'] as num).toDouble(),
      retreadCost: (json['retreadCost'] as num).toDouble(),
      repairCount: json['repairCount'],
      retreadCount: json['retreadCount'],
      costAdjustment: (json['costAdjustment'] as num).toDouble(),
      warrantyAdjustment: json['warrantyAdjustment'] != null
          ? (json['warrantyAdjustment'] as num).toDouble()
          : null,
      soldAmount: (json['soldAmount'] as num).toDouble(),
      netCost: (json['netCost'] as num).toDouble(),
      tireGraphData: TireGraphData.fromJson(json['tireGraphData']),
      vehicleNumber: json['vehicleNumber'],
      tireHistory: json['tireHistory'],
      tireHistory1: List<dynamic>.from(json['tireHistory1'] ?? []),
      createdBy: json['createdBy'],
      isEditable: json['isEditable'],
      evaluationNo: json['evaluationNo'],
      lotNo: json['lotNo'],
      poNo: json['poNo'],
      imagesLocation: json['imagesLocation'],
    );
  }
}

class TireGraphData {
  List<dynamic>? treadDepthList;
  List<dynamic>? pressureList;
  List<dynamic>? costPerHourList;
  List<dynamic>? hoursPerTreadDepthList;
  List<dynamic>? milesPerTreadDepthList;

  TireGraphData({
    this.treadDepthList,
    this.pressureList,
    this.costPerHourList,
    this.hoursPerTreadDepthList,
    this.milesPerTreadDepthList,
  });

  factory TireGraphData.fromJson(Map<String, dynamic>? json) {
    return TireGraphData(
      treadDepthList: List<dynamic>.from(json?['treadDepthList'] ?? []),
      pressureList: List<dynamic>.from(json?['pressureList'] ?? []),
      costPerHourList: List<dynamic>.from(json?['costPerHourList'] ?? []),
      hoursPerTreadDepthList: List<dynamic>.from(
        json?['hoursPerTreadDepthList'] ?? [],
      ),
      milesPerTreadDepthList: List<dynamic>.from(
        json?['milesPerTreadDepthList'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "treadDepthList": treadDepthList,
      "pressureList": pressureList,
      "costPerHourList": costPerHourList,
      "hoursPerTreadDepthList": hoursPerTreadDepthList,
      "milesPerTreadDepthList": milesPerTreadDepthList,
    };
  }
}
