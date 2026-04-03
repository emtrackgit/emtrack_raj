class AssignGrandparentModel {
  final int parentAccountId;
  final int grandparentAccountId;
  final int userId;

  AssignGrandparentModel({
    required this.parentAccountId,
    required this.grandparentAccountId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      "parentAccountId": parentAccountId,
      "grandparentAccountId": grandparentAccountId,
      "username": userId,
    };
  }
}
