class TireDisposition {
  final int dispositionId;
  final String dispositionName;
  final int dispositionGroupId;

  TireDisposition({
    required this.dispositionId,
    required this.dispositionName,
    required this.dispositionGroupId,
  });

  factory TireDisposition.fromJson(Map<String, dynamic> json) {
    return TireDisposition(
      dispositionId: json['dispositionId'] ?? 0,
      dispositionName: json['dispositionName'] ?? '',
      dispositionGroupId: json['dispositionGroupId'] ?? 0,
    );
  }
}
