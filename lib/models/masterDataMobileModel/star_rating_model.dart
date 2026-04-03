class StarRating {
  final int ratingId;
  final String ratingName;

  StarRating({required this.ratingId, required this.ratingName});

  factory StarRating.fromJson(Map<String, dynamic> json) {
    return StarRating(
      ratingId: json['ratingId'] ?? 0,
      ratingName: json['ratingName'] ?? '',
    );
  }
}
