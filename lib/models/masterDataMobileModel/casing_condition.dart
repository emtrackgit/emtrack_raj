class CasingCondition {
  final int casingConditionId;
  final String casingConditionName;

  CasingCondition({
    required this.casingConditionId,
    required this.casingConditionName,
  });

  factory CasingCondition.fromJson(Map<String, dynamic> json) {
    return CasingCondition(
      casingConditionId: json['casingConditionId'] ?? 0,
      casingConditionName: json['casingConditionName'] ?? '',
    );
  }
}
