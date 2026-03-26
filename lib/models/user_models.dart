class UserModel {
  final int id;
  final String username;
  final String token;
  final String message; // remove regex checks if present

  UserModel({
    required this.id,
    required this.username,
    required this.token,
    this.message = "",
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      message: json['message'] ?? '', // ✅ just assign string
    );
  }
}
