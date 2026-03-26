class TireLoadRating {
  final int ratingId;
  final String ratingName;

  TireLoadRating({required this.ratingId, required this.ratingName});

  factory TireLoadRating.fromJson(Map<String, dynamic> json) {
    return TireLoadRating(
      ratingId: json['ratingId'] ?? 0,
      ratingName: json['ratingName'] ?? '',
    );
  }
}
