class WearCondition {
  final int wearConditionId;
  final String wearConditionName;

  WearCondition({
    required this.wearConditionId,
    required this.wearConditionName,
  });

  factory WearCondition.fromJson(Map<String, dynamic> json) {
    return WearCondition(
      wearConditionId: json['wearConditionId'] ?? 0,
      wearConditionName: json['wearConditionName'] ?? '',
    );
  }
}
