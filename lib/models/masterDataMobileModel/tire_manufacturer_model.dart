class TireManufacturer {
  final int manufacturerId;
  final String manufacturerName;
  final bool activeFlag;
  final String? updationComments;

  TireManufacturer({
    required this.manufacturerId,
    required this.manufacturerName,
    required this.activeFlag,
    this.updationComments,
  });

  factory TireManufacturer.fromJson(Map<String, dynamic> json) {
    return TireManufacturer(
      manufacturerId: json['manufacturerId'] ?? 0,
      manufacturerName: json['manufacturerName'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
