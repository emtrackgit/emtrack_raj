import 'tyre_model.dart';

class TyreResponseModel {
  final String? message;
  final bool didError;
  final String? errorMessage;
  final int httpStatusCode;
  final int pageSize;
  final int pageNumber;
  final int currentTimeStamp;
  final List<TyreModel> model;

  TyreResponseModel({
    this.message,
    required this.didError,
    this.errorMessage,
    required this.httpStatusCode,
    required this.pageSize,
    required this.pageNumber,
    required this.currentTimeStamp,
    required this.model,
  });

  factory TyreResponseModel.fromJson(Map<String, dynamic> json) {
    final modelData = json['model'];

    List<TyreModel> tyres = [];

    if (modelData is List) {
      tyres = modelData.map((e) => TyreModel.fromJson(e)).toList();
    } else if (modelData is Map<String, dynamic>) {
      tyres = [TyreModel.fromJson(modelData)];
    }
    return TyreResponseModel(
      message: json['message'],
      didError: json['didError'] ?? false,
      errorMessage: json['errorMessage'],
      httpStatusCode: json['httpStatusCode'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      pageNumber: json['pageNumber'] ?? 0,
      currentTimeStamp: json['currentTimeStamp'] ?? 0,
      model: tyres,
    );
  }
}
