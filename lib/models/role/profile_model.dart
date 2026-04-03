class UserProfile {
  String? userId;
  String? firstName;
  String? middleName;
  String? lastName;
  String? userRole;
  String? phoneNumber;
  String? countryCode;
  String? emailAddress;

  UserProfile({
    this.userId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.userRole,
    this.phoneNumber,
    this.countryCode,
    this.emailAddress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      userRole: json['userRole'],
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      emailAddress: json['emailAddress'],
    );
  }
}