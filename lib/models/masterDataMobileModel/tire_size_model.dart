class TireSize {
  final int tireSizeId;
  final String tireSizeName;
  final bool activeFlag;
  final String? updationComments;
  final int tireManufacturerId;

  TireSize({
    required this.tireSizeId,
    required this.tireSizeName,
    required this.activeFlag,
    this.updationComments,
    required this.tireManufacturerId,
  });

  factory TireSize.fromJson(Map<String, dynamic> json) {
    return TireSize(
      tireSizeId: json['tireSizeId'] ?? 0,
      tireSizeName: json['tireSizeName'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
      tireManufacturerId: json['tireManufacturerId'] ?? 0,
    );
  }
}
