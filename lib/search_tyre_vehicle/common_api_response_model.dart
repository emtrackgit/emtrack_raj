class ApiListResponse<T> {
  final String? message;
  final bool didError;
  final String? errorMessage;
  final int httpStatusCode;
  final int pageSize;
  final int pageNumber;
  final int currentTimeStamp;
  final List<T> model;

  ApiListResponse({
    this.message,
    required this.didError,
    this.errorMessage,
    required this.httpStatusCode,
    required this.pageSize,
    required this.pageNumber,
    required this.currentTimeStamp,
    required this.model,
  });

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiListResponse<T>(
      message: json['message'],
      didError: json['didError'] ?? false,
      errorMessage: json['errorMessage'],
      httpStatusCode: json['httpStatusCode'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      pageNumber: json['pageNumber'] ?? 0,
      currentTimeStamp: json['currentTimeStamp'] ?? 0,
      model: (json['model'] as List).map((e) => fromJsonT(e)).toList(),
    );
  }
}
