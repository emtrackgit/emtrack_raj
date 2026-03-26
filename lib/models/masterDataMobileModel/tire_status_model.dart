class TireStatus {
  final int statusId;
  final String statusName;

  TireStatus({required this.statusId, required this.statusName});

  factory TireStatus.fromJson(Map<String, dynamic> json) {
    return TireStatus(
      statusId: json['statusId'] ?? 0,
      statusName: json['statusName'] ?? '',
    );
  }
}
