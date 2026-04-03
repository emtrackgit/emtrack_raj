class VehicleIcon {
  final int typeId;
  final String typeName;
  final String iconsLocation;

  VehicleIcon({
    required this.typeId,
    required this.typeName,
    required this.iconsLocation,
  });

  factory VehicleIcon.fromJson(Map<String, dynamic> json) {
    return VehicleIcon(
      typeId: json['typeId'] ?? 0,
      typeName: json['typeName'] ?? '',
      iconsLocation: json['iconsLocation'] ?? '',
    );
  }
}
