class VehicleModelItem {
  final int modelId;
  final int vehDefId;
  final int vehicleManufacturerId;
  final String modelName;
  final int vehicleTypeId;
  final int configurationId;
  final bool activeFlag;
  final String? updationComments;

  VehicleModelItem({
    required this.modelId,
    required this.vehDefId,
    required this.vehicleManufacturerId,
    required this.modelName,
    required this.vehicleTypeId,
    required this.configurationId,
    required this.activeFlag,
    this.updationComments,
  });

  factory VehicleModelItem.fromJson(Map<String, dynamic> json) {
    return VehicleModelItem(
      modelId: json['modelId'] ?? 0,
      vehDefId: json['vehDefId'] ?? 0,
      vehicleManufacturerId: json['vehicleManufacturerId'] ?? 0,
      modelName: json['modelName'] ?? '',
      vehicleTypeId: json['vehicleTypeId'] ?? 0,
      configurationId: json['configurationId'] ?? 0,
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
