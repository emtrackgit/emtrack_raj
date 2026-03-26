import 'package:emtrack/models/country/country_model.dart';

class CountryResponse {
  String? message;
  bool? didError;
  String? errorMessage;
  int? httpStatusCode;
  int? pageSize;
  int? pageNumber;
  int? currentTimeStamp;
  List<CountryModel>? model;

  CountryResponse({
    this.message,
    this.didError,
    this.errorMessage,
    this.httpStatusCode,
    this.pageSize,
    this.pageNumber,
    this.currentTimeStamp,
    this.model,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      message: json['message'],
      didError: json['didError'],
      errorMessage: json['errorMessage'],
      httpStatusCode: json['httpStatusCode'],
      pageSize: json['pageSize'],
      pageNumber: json['pageNumber'],
      currentTimeStamp: json['currentTimeStamp'],
      model: json['model'] != null
          ? List<CountryModel>.from(
              json['model'].map((x) => CountryModel.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'didError': didError,
      'errorMessage': errorMessage,
      'httpStatusCode': httpStatusCode,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
      'currentTimeStamp': currentTimeStamp,
      'model': model?.map((x) => x.toJson()).toList(),
    };
  }
}
