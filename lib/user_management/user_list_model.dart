class UserlListModel {
  final String? userId;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? userRole;
  final DateTime? updatedDate;
  final String? phoneNumber;
  final String? countryCode;
  final String? emailAddress;
  final int? grandParentAccountId;
  final bool? isDeleted;

  UserlListModel({
    this.userId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.userRole,
    this.updatedDate,
    this.phoneNumber,
    this.countryCode,
    this.emailAddress,
    this.grandParentAccountId,
    this.isDeleted,
  });

  factory UserlListModel.fromJson(Map<String, dynamic> json) {
    return UserlListModel(
      userId: json['userId'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      userRole: json['userRole'],
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      emailAddress: json['emailAddress'],
      grandParentAccountId: json['grandParentAccountId'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'userRole': userRole,
      'updatedDate': updatedDate?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'emailAddress': emailAddress,
      'grandParentAccountId': grandParentAccountId,
      'isDeleted': isDeleted,
    };
  }
}
