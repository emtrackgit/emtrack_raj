class TireType {
  final int typeId;
  final int tireManufacturerId;
  final String typeName;
  final bool activeFlag;
  final String? updationComments;
  final int tireSizeId;

  TireType({
    required this.typeId,
    required this.tireManufacturerId,
    required this.typeName,
    required this.activeFlag,
    this.updationComments,
    required this.tireSizeId,
  });

  factory TireType.fromJson(Map<String, dynamic> json) {
    return TireType(
      typeId: json['typeId'] ?? 0,
      tireManufacturerId: json['tireManufacturerId'] ?? 0,
      typeName: json['typeName'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
      tireSizeId: json['tireSizeId'] ?? 0,
    );
  }
}
