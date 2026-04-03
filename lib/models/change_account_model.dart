class ParentAccountModel {
  final int parentAccountId;
  final String accountName;
  final String createdBy;

  ParentAccountModel({
    required this.parentAccountId,
    required this.accountName,
    required this.createdBy,
  });

  factory ParentAccountModel.fromJson(Map<String, dynamic> json) {
    return ParentAccountModel(
      parentAccountId: json['parentAccountId'] ?? 0,
      accountName: json['accountName'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }
}

class LocationModel {
  final int locationId;
  final String locationName;

  LocationModel({required this.locationId, required this.locationName});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationId: json['locationId'] ?? 0,
      locationName: json['locationName'] ?? '',
    );
  }
}
