class TireRemovalReason {
  final int reasonId;
  final String reasonName;
  final bool activeFlag;
  final String? updationComments;

  TireRemovalReason({
    required this.reasonId,
    required this.reasonName,
    required this.activeFlag,
    this.updationComments,
  });

  factory TireRemovalReason.fromJson(Map<String, dynamic> json) {
    return TireRemovalReason(
      reasonId: json['reasonId'] ?? 0,
      reasonName: json['reasonName'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
