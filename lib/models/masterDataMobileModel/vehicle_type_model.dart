class VehicleType {
  final int typeId;
  final String typeName;
  final int manufacturerId;
  final bool activeFlag;
  final String? updationComments;

  VehicleType({
    required this.typeId,
    required this.typeName,
    required this.manufacturerId,
    required this.activeFlag,
    this.updationComments,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      typeId: json['typeId'] ?? 0,
      typeName: json['typeName'] ?? '',
      manufacturerId: json['manufacturerId'] ?? 0,
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
