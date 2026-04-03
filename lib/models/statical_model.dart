class DashboardResponse {
  final String? message;
  final bool? didError;
  final String? errorMessage;
  final int? httpStatusCode;
  final DashboardModel? model;

  DashboardResponse({
    this.message,
    this.didError,
    this.errorMessage,
    this.httpStatusCode,
    this.model,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      message: json['message'],
      didError: json['didError'],
      errorMessage: json['errorMessage'],
      httpStatusCode: json['httpStatusCode'],
      model: json['model'] != null
          ? DashboardModel.fromJson(json['model'])
          : null,
    );
  }
}

class DashboardModel {
  final int? scrapTireCount;
  final int? tiresInServiceCount;
  final int? tiresInInventoryCount;
  final int? vehicleCount;
  final int? removedTireCount;
  final int? tiresBelowInflationCount;
  final int? tiresWithLowTreadDepthCount;
  final int? tireConditionCount;
  final int? rimCount;
  final int? totalTiresCount;

  DashboardModel({
    this.scrapTireCount,
    this.tiresInServiceCount,
    this.tiresInInventoryCount,
    this.vehicleCount,
    this.removedTireCount,
    this.tiresBelowInflationCount,
    this.tiresWithLowTreadDepthCount,
    this.tireConditionCount,
    this.rimCount,
    this.totalTiresCount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      scrapTireCount: json['scrapTireCount'],
      tiresInServiceCount: json['tiresInServiceCount'],
      tiresInInventoryCount: json['tiresInInventoryCount'],
      vehicleCount: json['vehicleCount'],
      removedTireCount: json['removedTireCount'],
      tiresBelowInflationCount: json['tiresBelowInflationCount'],
      tiresWithLowTreadDepthCount: json['tiresWithLowTreadDepthCount'],
      tireConditionCount: json['tireConditionCount'],
      rimCount: json['rimCount'],
      totalTiresCount: json['totalTiresCount'],
    );
  }
}