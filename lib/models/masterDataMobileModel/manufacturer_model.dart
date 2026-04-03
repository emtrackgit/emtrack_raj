class Manufacturer {
  final int manufacturerId;
  final String manufacturerName;
  final bool activeFlag;
  final String? updationComments;

  Manufacturer({
    required this.manufacturerId,
    required this.manufacturerName,
    required this.activeFlag,
    this.updationComments,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      manufacturerId: json['manufacturerId'] ?? 0,
      manufacturerName: json['manufacturerName'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
