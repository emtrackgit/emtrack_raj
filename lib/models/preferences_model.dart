class PreferencesModel {
  String? updatedBy;
  String? userId;

  String language;
  String measurementSystem;
  String pressureUnit;

  String? logoLocation;
  DateTime? updatedDate;

  int? lastAccessedAccountId;
  int? lastAccessedLocationId;
  String? lastAccessedAccountName;
  String? lastAccessedLocationName;

  PreferencesModel({
    required this.updatedBy,
    required this.userId,
    required this.language,
    required this.measurementSystem,
    required this.pressureUnit,
    this.logoLocation,
    this.updatedDate,
    this.lastAccessedAccountId,
    this.lastAccessedLocationId,
    this.lastAccessedAccountName,
    this.lastAccessedLocationName,
  });

  // 🔹 FROM JSON
  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      updatedBy: json['updatedBy'] ?? '',
      userId: json['userId'] ?? '',
      language: json['userLanguage'] ?? '',
      measurementSystem: json['userMeasurementSystemValue'] ?? '',
      pressureUnit: json['userPressureUnit'] ?? '',
      logoLocation: json['logoLocation'] ?? '',
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'])
          : null,
      lastAccessedAccountId: json['lastAccessedAccountId'] ?? '',
      lastAccessedLocationId: json['lastAccessedLocationId'] ?? '',
      lastAccessedAccountName: json['lastAccessedAccountName'] ?? '',
      lastAccessedLocationName: json['lastAccessedLocationName'] ?? '',
    );
  }

  // 🔹 TO JSON (API SEND)
  Map<String, dynamic> toJson() {
    return {
      "updatedBy": updatedBy,
      "userId": userId,
      "userLanguage": language,
      "userMeasurementSystemValue": measurementSystem,
      "userPressureUnit": pressureUnit,
      "logoLocation": logoLocation,
      "updatedDate": updatedDate?.toIso8601String(),
      "lastAccessedAccountId": lastAccessedAccountId,
      "lastAccessedLocationId": lastAccessedLocationId,
      "lastAccessedAccountName": lastAccessedAccountName,
      "lastAccessedLocationName": lastAccessedLocationName,
    };
  }
}
