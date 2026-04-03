import 'package:emtrack/models/masterDataMobileModel/master_model.dart';

class VehicleMasterResponse {
  final String? message;
  final bool didError;
  final String? errorMessage;
  final int httpStatusCode;
  final MasterModel? model;

  VehicleMasterResponse({
    this.message,
    required this.didError,
    this.errorMessage,
    required this.httpStatusCode,
    this.model,
  });

  factory VehicleMasterResponse.fromJson(Map<String, dynamic> json) {
    return VehicleMasterResponse(
      message: json['message'],
      didError: json['didError'] ?? false,
      errorMessage: json['errorMessage'],
      httpStatusCode: json['httpStatusCode'] ?? 0,
      model: json['model'] != null ? MasterModel.fromJson(json['model']) : null,
    );
  }
}
