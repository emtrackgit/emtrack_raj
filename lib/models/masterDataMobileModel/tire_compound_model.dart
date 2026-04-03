class TireCompound {
  final int compoundId;
  final String compoundName;
  final bool activeFlag;
  final String? updationComments;

  TireCompound({
    required this.compoundId,
    required this.compoundName,
    required this.activeFlag,
    this.updationComments,
  });

  factory TireCompound.fromJson(Map<String, dynamic> json) {
    return TireCompound(
      compoundId: json['compoundId'] ?? 0,
      compoundName: json['compoundName'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
