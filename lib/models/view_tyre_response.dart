// To parse this JSON data, do
//
//     final viewTyreResponse = viewTyreResponseFromJson(jsonString);

import 'dart:convert';

ViewTyreResponse viewTyreResponseFromJson(String str) =>
    ViewTyreResponse.fromJson(json.decode(str));

String viewTyreResponseToJson(ViewTyreResponse data) =>
    json.encode(data.toJson());

class ViewTyreResponse {
  dynamic message;
  bool didError;
  dynamic errorMessage;
  int httpStatusCode;
  ViewModel viewModel;

  ViewTyreResponse({
    required this.message,
    required this.didError,
    required this.errorMessage,
    required this.httpStatusCode,
    required this.viewModel,
  });

  factory ViewTyreResponse.fromJson(Map<String, dynamic> json) =>
      ViewTyreResponse(
        message: json["message"],
        didError: json["didError"],
        errorMessage: json["errorMessage"],
        httpStatusCode: json["httpStatusCode"],
        viewModel: ViewModel.fromJson(json["model"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "didError": didError,
    "errorMessage": errorMessage,
    "httpStatusCode": httpStatusCode,
    "model": viewModel.toJson(),
  };
}

class ViewModel {
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

  dynamic mountedRimId;
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

  String? vehicleNumber;
  dynamic tireHistory;

  String? createdBy;
  bool? isEditable;

  String? evaluationNo;
  String? lotNo;
  String? poNo;
  String? imagesLocation;

  ViewModel({
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

    this.vehicleNumber,
    this.tireHistory,

    this.createdBy,
    this.isEditable,
    this.evaluationNo,
    this.lotNo,
    this.poNo,
    this.imagesLocation,
  });
  factory ViewModel.fromJson(Map<String, dynamic> json) => ViewModel(
    tireId: toInt(json["tireId"]),
    tireSerialNo: toStr(json["tireSerialNo"]),

    vehicleId: toInt(json["vehicleId"]),
    locationId: toInt(json["locationId"]),
    parentAccountId: toInt(json["parentAccountId"]),

    brandNo: toStr(json["brandNo"]),

    registeredDate: json["registeredDate"] != null
        ? DateTime.tryParse(json["registeredDate"].toString())
        : null,

    mileageType: toStr(json["mileageType"]),

    currentMiles: toDouble(json["currentMiles"]),
    currentHours: toDouble(json["currentHours"]),

    dispositionId: toInt(json["dispositionId"]),
    tireStatusId: toInt(json["tireStatusId"]),

    wheelPosition: toStr(json["wheelPosition"]),
    isMountToRim: json["isMountToRim"],

    mountedRimId: toInt(json["mountedRimId"]),
    mountedRimSerialNo: toStr(json["mountedRimSerialNo"]),

    originalTread: toDouble(json["originalTread"]),
    purchasedTread: toDouble(json["purchasedTread"]),
    removeAt: toDouble(json["removeAt"]),

    outsideTread: toDouble(json["outsideTread"]),
    middleTread: toDouble(json["middleTread"]),
    insideTread: toDouble(json["insideTread"]),
    averageTreadDepth: toDouble(json["averageTreadDepth"]),

    recommendedPressure: toDouble(json["recommendedPressure"]),
    currentTreadDepth: toDouble(json["currentTreadDepth"]),
    currentPressure: toDouble(json["currentPressure"]),
    percentageWorn: toDouble(json["percentageWorn"]),

    manufacturerId: toInt(json["manufacturerId"]),
    sizeId: toInt(json["sizeId"]),
    starRatingId: toInt(json["starRatingId"]),
    plyId: toInt(json["plyId"]),
    typeId: toInt(json["typeId"]),
    indCodeId: toInt(json["indCodeId"]),
    compoundId: toInt(json["compoundId"]),
    loadRatingId: toInt(json["loadRatingId"]),
    speedRatingId: toInt(json["speedRatingId"]),

    purchaseCost: toDouble(json["purchaseCost"]),
    casingValue: toDouble(json["casingValue"]),
    fillTypeId: toInt(json["fillTypeId"]),
    fillCost: toDouble(json["fillCost"]),
    repairCost: toDouble(json["repairCost"]),
    retreadCost: toDouble(json["retreadCost"]),

    repairCount: toInt(json["repairCount"]),
    retreadCount: toInt(json["retreadCount"]),

    costAdjustment: toDouble(json["costAdjustment"]),
    warrantyAdjustment: toDouble(json["warrantyAdjustment"]),
    soldAmount: toDouble(json["soldAmount"]),
    netCost: toDouble(json["netCost"]),

    vehicleNumber: toStr(json["vehicleNumber"]),

    tireHistory: json["tireHistory"],

    createdBy: toStr(json["createdBy"]),
    isEditable: json["isEditable"],

    evaluationNo: toStr(json["evaluationNo"]),
    lotNo: toStr(json["lotNo"]),
    poNo: toStr(json["poNo"]),
  );

  Map<String, dynamic> toJson() => {
    "tireId": tireId,
    "tireSerialNo": tireSerialNo,
    "vehicleId": vehicleId,
    "locationId": locationId,
    "parentAccountId": parentAccountId,
    "brandNo": brandNo,
    "registeredDate": registeredDate?.toIso8601String(),
    "mileageType": mileageType,
    "currentMiles": currentMiles,
    "currentHours": currentHours,
    "dispositionId": dispositionId,
    "tireStatusId": tireStatusId,
    "wheelPosition": wheelPosition,
    "isMountToRim": isMountToRim,
    "mountedRimId": mountedRimId,
    "mountedRimSerialNo": mountedRimSerialNo,
    "originalTread": originalTread,
    "purchasedTread": purchasedTread,
    "removeAt": removeAt,
    "outsideTread": outsideTread,
    "middleTread": middleTread,
    "insideTread": insideTread,
    "averageTreadDepth": averageTreadDepth,
    "recommendedPressure": recommendedPressure,
    "currentTreadDepth": currentTreadDepth,
    "currentPressure": currentPressure,
    "percentageWorn": percentageWorn,
    "manufacturerId": manufacturerId,
    "sizeId": sizeId,
    "starRatingId": starRatingId,
    "plyId": plyId,
    "typeId": typeId,
    "indCodeId": indCodeId,
    "compoundId": compoundId,
    "loadRatingId": loadRatingId,
    "speedRatingId": speedRatingId,
    "purchaseCost": purchaseCost,
    "casingValue": casingValue,
    "fillTypeId": fillTypeId,
    "fillCost": fillCost,
    "repairCost": repairCost,
    "retreadCost": retreadCost,
    "repairCount": repairCount,
    "retreadCount": retreadCount,
    "costAdjustment": costAdjustment,
    "warrantyAdjustment": warrantyAdjustment,
    "soldAmount": soldAmount,
    "netCost": netCost,

    "vehicleNumber": vehicleNumber,
    "tireHistory": tireHistory,

    "createdBy": createdBy,
    "isEditable": isEditable,
    "evaluationNo": evaluationNo,
    "lotNo": lotNo,
    "poNo": poNo,
    "imagesLocation": imagesLocation,
  };
}

int? toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}

String? toStr(dynamic v) {
  if (v == null) return null;
  return v.toString();
}
