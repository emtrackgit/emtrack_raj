class PasswordResetModel {
  String username;
  String oldPassword;
  String newPassword;

  PasswordResetModel({
    required this.username,
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    };
  }
}