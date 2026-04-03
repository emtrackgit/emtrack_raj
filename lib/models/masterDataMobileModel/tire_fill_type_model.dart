class TireFillType {
  final int fillTypeId;
  final String fillTypeName;

  TireFillType({required this.fillTypeId, required this.fillTypeName});

  factory TireFillType.fromJson(Map<String, dynamic> json) {
    return TireFillType(
      fillTypeId: json['fillTypeId'] ?? 0,
      fillTypeName: json['fillTypeName'] ?? '',
    );
  }
}
