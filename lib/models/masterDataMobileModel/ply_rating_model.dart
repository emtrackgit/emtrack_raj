class PlyRating {
  final int ratingId;
  final String ratingName;

  PlyRating({required this.ratingId, required this.ratingName});

  factory PlyRating.fromJson(Map<String, dynamic> json) {
    return PlyRating(
      ratingId: json['ratingId'] ?? 0,
      ratingName: json['ratingName'] ?? '',
    );
  }
}
