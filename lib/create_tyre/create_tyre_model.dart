import 'dart:convert';

class CreateTyreModel {
  String trackingMethod = '0';
  String mountStatus = '0';
  int numberOfRetreads = 0;
  int? dispositionId;
  int? manufacturerId;
  String? mileageType;
  DateTime? registeredDate;
  int? sizeId;
  String? tireSerialNo;
  int? typeId;
  int? tireId;
  int? vehicleId;
  int? locationId;
  int? parentAccountId;
  String? brandNo;
  double? currentMiles;
  double? currentHours;
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
  int? starRatingId;
  int? plyId;
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
  List<TireHistory>? tireHistory;
  List<TireHistory1>? tireHistory1;
  String? createdBy;
  bool? isEditable;
  String? evaluationNo;
  String? lotNo;
  String? poNo;
  String? imagesLocation;

  CreateTyreModel({
    this.dispositionId,
    this.manufacturerId,
    this.mileageType,
    this.registeredDate,
    this.sizeId,
    this.tireSerialNo,
    this.typeId,
    this.tireId,
    this.vehicleId,
    this.locationId,
    this.parentAccountId,
    this.brandNo,
    this.currentMiles,
    this.currentHours,
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
    this.starRatingId,
    this.plyId,
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

  factory CreateTyreModel.fromJson(Map<String, dynamic> json) {
    return CreateTyreModel(
      dispositionId: json['dispositionId'],
      manufacturerId: json['manufacturerId'],
      mileageType: json['mileageType'],
      registeredDate: json['registeredDate'] != null
          ? DateTime.parse(json['registeredDate'])
          : null,
      sizeId: json['sizeId'],
      tireSerialNo: json['tireSerialNo'],
      typeId: json['typeId'],
      tireId: json['tireId'],
      vehicleId: json['vehicleId'],
      locationId: json['locationId'],
      parentAccountId: json['parentAccountId'],
      brandNo: json['brandNo'],
      currentMiles: (json['currentMiles'] != null)
          ? json['currentMiles'].toDouble()
          : null,
      currentHours: (json['currentHours'] != null)
          ? json['currentHours'].toDouble()
          : null,
      tireStatusId: json['tireStatusId'],
      wheelPosition: json['wheelPosition'],
      isMountToRim: json['isMountToRim'],
      mountedRimId: json['mountedRimId'],
      mountedRimSerialNo: json['mountedRimSerialNo'],
      originalTread: (json['originalTread'] != null)
          ? json['originalTread'].toDouble()
          : null,
      purchasedTread: (json['purchasedTread'] != null)
          ? json['purchasedTread'].toDouble()
          : null,
      removeAt: (json['removeAt'] != null) ? json['removeAt'].toDouble() : null,
      outsideTread: (json['outsideTread'] != null)
          ? json['outsideTread'].toDouble()
          : null,
      middleTread: (json['middleTread'] != null)
          ? json['middleTread'].toDouble()
          : null,
      insideTread: (json['insideTread'] != null)
          ? json['insideTread'].toDouble()
          : null,
      averageTreadDepth: (json['averageTreadDepth'] != null)
          ? json['averageTreadDepth'].toDouble()
          : null,
      recommendedPressure: (json['recommendedPressure'] != null)
          ? json['recommendedPressure'].toDouble()
          : null,
      currentTreadDepth: (json['currentTreadDepth'] != null)
          ? json['currentTreadDepth'].toDouble()
          : null,
      currentPressure: (json['currentPressure'] != null)
          ? json['currentPressure'].toDouble()
          : null,
      percentageWorn: (json['percentageWorn'] != null)
          ? json['percentageWorn'].toDouble()
          : null,
      starRatingId: json['starRatingId'],
      plyId: json['plyId'],
      indCodeId: json['indCodeId'],
      compoundId: json['compoundId'],
      loadRatingId: json['loadRatingId'],
      speedRatingId: json['speedRatingId'],
      purchaseCost: (json['purchaseCost'] != null)
          ? json['purchaseCost'].toDouble()
          : null,
      casingValue: (json['casingValue'] != null)
          ? json['casingValue'].toDouble()
          : null,
      fillTypeId: json['fillTypeId'],
      fillCost: (json['fillCost'] != null) ? json['fillCost'].toDouble() : null,
      repairCost: (json['repairCost'] != null)
          ? json['repairCost'].toDouble()
          : null,
      retreadCost: (json['retreadCost'] != null)
          ? json['retreadCost'].toDouble()
          : null,
      repairCount: json['repairCount'],
      retreadCount: json['retreadCount'],
      costAdjustment: (json['costAdjustment'] != null)
          ? json['costAdjustment'].toDouble()
          : null,
      warrantyAdjustment: (json['warrantyAdjustment'] != null)
          ? json['warrantyAdjustment'].toDouble()
          : null,
      soldAmount: (json['soldAmount'] != null)
          ? json['soldAmount'].toDouble()
          : null,
      netCost: (json['netCost'] != null) ? json['netCost'].toDouble() : null,
      tireGraphData: json['tireGraphData'] != null
          ? TireGraphData.fromJson(json['tireGraphData'])
          : null,
      vehicleNumber: json['vehicleNumber'],
      tireHistory: json['tireHistory'] != null
          ? List<TireHistory>.from(
              json['tireHistory'].map((x) => TireHistory.fromJson(x)),
            )
          : null,
      tireHistory1: json['tireHistory1'] != null
          ? List<TireHistory1>.from(
              json['tireHistory1'].map((x) => TireHistory1.fromJson(x)),
            )
          : null,
      createdBy: json['createdBy'],
      isEditable: json['isEditable'],
      evaluationNo: json['evaluationNo'],
      lotNo: json['lotNo'],
      poNo: json['poNo'],
      imagesLocation: json['imagesLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'dispositionId': dispositionId,
      'manufacturerId': manufacturerId,
      'mileageType': mileageType,
      'registeredDate': registeredDate?.toIso8601String(),
      'sizeId': sizeId,
      'tireSerialNo': tireSerialNo,
      'typeId': typeId,
      'locationId': locationId,
      'parentAccountId': parentAccountId,
      'brandNo': brandNo,
      'currentMiles': currentMiles,
      'currentHours': currentHours,
      'tireStatusId': tireStatusId,
      'wheelPosition': wheelPosition,
      'isMountToRim': isMountToRim,
      'mountedRimSerialNo': mountedRimSerialNo,
      'originalTread': originalTread,
      'purchasedTread': purchasedTread,
      'removeAt': removeAt,
      'outsideTread': outsideTread,
      'middleTread': middleTread,
      'insideTread': insideTread,
      'averageTreadDepth': averageTreadDepth,
      'recommendedPressure': recommendedPressure,
      'currentTreadDepth': currentTreadDepth,
      'currentPressure': currentPressure,
      'percentageWorn': percentageWorn,
      'starRatingId': starRatingId,
      'plyId': plyId,
      'indCodeId': indCodeId,
      'compoundId': compoundId,
      'loadRatingId': loadRatingId,
      'speedRatingId': speedRatingId,
      'purchaseCost': purchaseCost,
      'casingValue': casingValue,
      'fillTypeId': fillTypeId,
      'fillCost': fillCost,
      'repairCost': repairCost,
      'retreadCost': retreadCost,
      'repairCount': repairCount,
      'retreadCount': retreadCount,
      'costAdjustment': costAdjustment,
      'warrantyAdjustment': warrantyAdjustment,
      'soldAmount': soldAmount,
      'netCost': netCost,
      'vehicleNumber': vehicleNumber,
      'createdBy': createdBy,
      'isEditable': isEditable,
      'evaluationNo': evaluationNo,
      'lotNo': lotNo,
      'poNo': poNo,
      'imagesLocation': imagesLocation,
    };

    // Only add optional IDs if not null
    data['tireId'] = tireId ?? 0;
    data['vehicleId'] = vehicleId ?? 0;
    data['mountedRimId'] = mountedRimId ?? 0;

    // Only add tireGraphData if not null
    data['tireGraphData'] =
        tireGraphData?.toJson() ??
        {
          "treadDepthList": [],
          "pressureList": [],
          "costPerHourList": [],
          "hoursPerTreadDepthList": [],
          "milesPerTreadDepthList": [],
        };

    return data;
  }
}

// Nested classes
class TireGraphData {
  List<TireMetric>? treadDepthList;
  List<TireMetric>? pressureList;
  List<TireMetric>? costPerHourList;
  List<TireMetric>? hoursPerTreadDepthList;
  List<TireMetric>? milesPerTreadDepthList;

  TireGraphData({
    this.treadDepthList,
    this.pressureList,
    this.costPerHourList,
    this.hoursPerTreadDepthList,
    this.milesPerTreadDepthList,
  });

  factory TireGraphData.fromJson(Map<String, dynamic> json) => TireGraphData(
    treadDepthList: json['treadDepthList'] != null
        ? List<TireMetric>.from(
            json['treadDepthList'].map((x) => TireMetric.fromJson(x)),
          )
        : null,
    pressureList: json['pressureList'] != null
        ? List<TireMetric>.from(
            json['pressureList'].map((x) => TireMetric.fromJson(x)),
          )
        : null,
    costPerHourList: json['costPerHourList'] != null
        ? List<TireMetric>.from(
            json['costPerHourList'].map((x) => TireMetric.fromJson(x)),
          )
        : null,
    hoursPerTreadDepthList: json['hoursPerTreadDepthList'] != null
        ? List<TireMetric>.from(
            json['hoursPerTreadDepthList'].map((x) => TireMetric.fromJson(x)),
          )
        : null,
    milesPerTreadDepthList: json['milesPerTreadDepthList'] != null
        ? List<TireMetric>.from(
            json['milesPerTreadDepthList'].map((x) => TireMetric.fromJson(x)),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'treadDepthList': treadDepthList?.map((x) => x.toJson()).toList(),
    'pressureList': pressureList?.map((x) => x.toJson()).toList(),
    'costPerHourList': costPerHourList?.map((x) => x.toJson()).toList(),
    'hoursPerTreadDepthList': hoursPerTreadDepthList
        ?.map((x) => x.toJson())
        .toList(),
    'milesPerTreadDepthList': milesPerTreadDepthList
        ?.map((x) => x.toJson())
        .toList(),
  };
}

class TireMetric {
  double? tireMetric;
  DateTime? timeSpan;
  String? info;

  TireMetric({this.tireMetric, this.timeSpan, this.info});

  factory TireMetric.fromJson(Map<String, dynamic> json) => TireMetric(
    tireMetric: (json['tireMetric'] != null)
        ? json['tireMetric'].toDouble()
        : null,
    timeSpan: json['timeSpan'] != null
        ? DateTime.parse(json['timeSpan'])
        : null,
    info: json['info'],
  );

  Map<String, dynamic> toJson() => {
    'tireMetric': tireMetric,
    'timeSpan': timeSpan?.toIso8601String(),
    'info': info,
  };
}

class TireHistory {
  int? eventId;
  String? eventName;
  DateTime? eventDate;
  String? disposition;
  double? treadDepth;
  double? pressure;
  double? hours;
  double? km;
  double? cost;
  String? vehicleNumber;
  String? wheelPosition;
  String? comments;
  String? user;
  int? tireId;
  DateTime? createdDate;
  DateTime? updatedDate;
  bool? isActive;

  TireHistory({
    this.eventId,
    this.eventName,
    this.eventDate,
    this.disposition,
    this.treadDepth,
    this.pressure,
    this.hours,
    this.km,
    this.cost,
    this.vehicleNumber,
    this.wheelPosition,
    this.comments,
    this.user,
    this.tireId,
    this.createdDate,
    this.updatedDate,
    this.isActive,
  });

  factory TireHistory.fromJson(Map<String, dynamic> json) => TireHistory(
    eventId: json['eventId'],
    eventName: json['eventName'],
    eventDate: json['eventDate'] != null
        ? DateTime.parse(json['eventDate'])
        : null,
    disposition: json['disposition'],
    treadDepth: (json['treadDepth'] != null)
        ? json['treadDepth'].toDouble()
        : null,
    pressure: (json['pressure'] != null) ? json['pressure'].toDouble() : null,
    hours: (json['hours'] != null) ? json['hours'].toDouble() : null,
    km: (json['km'] != null) ? json['km'].toDouble() : null,
    cost: (json['cost'] != null) ? json['cost'].toDouble() : null,
    vehicleNumber: json['vehicleNumber'],
    wheelPosition: json['wheelPosition'],
    comments: json['comments'],
    user: json['user'],
    tireId: json['tireId'],
    createdDate: json['createdDate'] != null
        ? DateTime.parse(json['createdDate'])
        : null,
    updatedDate: json['updatedDate'] != null
        ? DateTime.parse(json['updatedDate'])
        : null,
    isActive: json['isActive'],
  );

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'eventName': eventName,
    'eventDate': eventDate?.toIso8601String(),
    'disposition': disposition,
    'treadDepth': treadDepth,
    'pressure': pressure,
    'hours': hours,
    'km': km,
    'cost': cost,
    'vehicleNumber': vehicleNumber,
    'wheelPosition': wheelPosition,
    'comments': comments,
    'user': user,
    'tireId': tireId,
    'createdDate': createdDate?.toIso8601String(),
    'updatedDate': updatedDate?.toIso8601String(),
    'isActive': isActive,
  };
}

class TireHistory1 {
  int? eventId;
  String? eventName;
  DateTime? eventDate;
  String? disposition;
  double? treadDepth;
  double? pressure;
  double? hours;
  double? km;
  double? cost;
  String? vehicleNumber;
  String? wheelPosition;
  String? comments;
  String? user;
  int? tireId;
  DateTime? createdDate;
  DateTime? updatedDate;
  String? pressureType;

  TireHistory1({
    this.eventId,
    this.eventName,
    this.eventDate,
    this.disposition,
    this.treadDepth,
    this.pressure,
    this.hours,
    this.km,
    this.cost,
    this.vehicleNumber,
    this.wheelPosition,
    this.comments,
    this.user,
    this.tireId,
    this.createdDate,
    this.updatedDate,
    this.pressureType,
  });

  factory TireHistory1.fromJson(Map<String, dynamic> json) => TireHistory1(
    eventId: json['eventId'],
    eventName: json['eventName'],
    eventDate: json['eventDate'] != null
        ? DateTime.parse(json['eventDate'])
        : null,
    disposition: json['disposition'],
    treadDepth: (json['treadDepth'] != null)
        ? json['treadDepth'].toDouble()
        : null,
    pressure: (json['pressure'] != null) ? json['pressure'].toDouble() : null,
    hours: (json['hours'] != null) ? json['hours'].toDouble() : null,
    km: (json['km'] != null) ? json['km'].toDouble() : null,
    cost: (json['cost'] != null) ? json['cost'].toDouble() : null,
    vehicleNumber: json['vehicleNumber'],
    wheelPosition: json['wheelPosition'],
    comments: json['comments'],
    user: json['user'],
    tireId: json['tireId'],
    createdDate: json['createdDate'] != null
        ? DateTime.parse(json['createdDate'])
        : null,
    updatedDate: json['updatedDate'] != null
        ? DateTime.parse(json['updatedDate'])
        : null,
    pressureType: json['pressureType'],
  );

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'eventName': eventName,
    'eventDate': eventDate?.toIso8601String(),
    'disposition': disposition,
    'treadDepth': treadDepth,
    'pressure': pressure,
    'hours': hours,
    'km': km,
    'cost': cost,
    'vehicleNumber': vehicleNumber,
    'wheelPosition': wheelPosition,
    'comments': comments,
    'user': user,
    'tireId': tireId,
    'createdDate': createdDate?.toIso8601String(),
    'updatedDate': updatedDate?.toIso8601String(),
    'pressureType': pressureType,
  };
}
