class UserManagementModel {
  // Login Info
  final String username;
  final String password;
  final String role;

  // Personal Details
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String country;

  // Preferences
  final String language;
  final String measurement;
  final String pressureUnit;

  UserManagementModel({
    required this.username,
    required this.password,
    required this.role,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.language,
    required this.measurement,
    required this.pressureUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "role": role,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "country": country,
      "language": language,
      "measurement": measurement,
      "pressureUnit": pressureUnit,
    };
  }

  factory UserManagementModel.fromJson(Map<String, dynamic> json) {
    return UserManagementModel(
      username: json["username"] ?? "",
      password: json["password"] ?? "",
      role: json["role"] ?? "",
      firstName: json["firstName"] ?? "",
      middleName: json["middleName"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      country: json["country"] ?? "",
      language: json["language"] ?? "",
      measurement: json["measurement"] ?? "",
      pressureUnit: json["pressureUnit"] ?? "",
    );
  }
}
