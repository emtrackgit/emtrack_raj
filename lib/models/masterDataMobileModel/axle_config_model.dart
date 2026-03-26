class AxleConfig {
  final int configurationId;
  final String configurationName;
  final String configurationText;
  final String configurationPosition;
  final bool activeFlag;
  final String? updationComments;

  AxleConfig({
    required this.configurationId,
    required this.configurationName,
    required this.configurationText,
    required this.configurationPosition,
    required this.activeFlag,
    this.updationComments,
  });

  factory AxleConfig.fromJson(Map<String, dynamic> json) {
    return AxleConfig(
      configurationId: json['configurationId'] ?? 0,
      configurationName: json['configurationName'] ?? '',
      configurationText: json['configurationText'] ?? '',
      configurationPosition: json['configurationPosition'] ?? '',
      activeFlag: json['activeFlag'] ?? false,
      updationComments: json['updationComments'],
    );
  }
}
