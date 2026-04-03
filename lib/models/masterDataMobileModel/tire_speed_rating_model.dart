class TireSpeedRating {
  final int speedRatingId;
  final String speedRatingName;

  TireSpeedRating({required this.speedRatingId, required this.speedRatingName});

  factory TireSpeedRating.fromJson(Map<String, dynamic> json) {
    return TireSpeedRating(
      speedRatingId: json['speedRatingId'] ?? json['ratingId'] ?? 0,
      speedRatingName: json['speedRatingName'] ?? json['ratingName'] ?? '',
    );
  }
}
