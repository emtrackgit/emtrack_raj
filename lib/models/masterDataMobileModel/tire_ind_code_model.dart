class TireIndCode {
  final int codeId;
  final String codeName;

  TireIndCode({required this.codeId, required this.codeName});

  factory TireIndCode.fromJson(Map<String, dynamic> json) {
    return TireIndCode(
      codeId: json['codeId'] ?? json['ratingId'] ?? 0,
      codeName: json['codeName'] ?? json['ratingName'] ?? '',
    );
  }
}
