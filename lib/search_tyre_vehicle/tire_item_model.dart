class TireItem {
  final int tireId;
  final String tireSerialNo;
  final String manufacturerName;
  final String sizeName;
  final String typeName;
  final double currentHours;
  final double currentMiles;
  final double currentTreadDepth;
  final double percentageWorn;
  final String wheelPosition;
  final String dispositionName;
  final String vehicleNumber;

  TireItem({
    required this.tireId,
    required this.tireSerialNo,
    required this.manufacturerName,
    required this.sizeName,
    required this.typeName,
    required this.currentHours,
    required this.currentMiles,
    required this.currentTreadDepth,
    required this.percentageWorn,
    required this.wheelPosition,
    required this.dispositionName,
    required this.vehicleNumber,
  });

  /// ================= FROM JSON =================
  factory TireItem.fromJson(Map<String, dynamic> json) {
    return TireItem(
      tireId: json['tireId'] as int,
      tireSerialNo: json['tireSerialNo'] as String? ?? '',
      manufacturerName: json['manufacturerName'] as String? ?? '',
      sizeName: json['sizeName'] as String? ?? '',
      typeName: json['typeName'] as String? ?? '',
      currentHours: json['currentHours'] != null
          ? (json['currentHours'] as num).toDouble()
          : 0.0,
      currentMiles: json['currentMiles'] != null
          ? (json['currentMiles'] as num).toDouble()
          : 0.0,
      currentTreadDepth: json['currentTreadDepth'] != null
          ? (json['currentTreadDepth'] as num).toDouble()
          : 0.0,
      percentageWorn: json['percentageWorn'] != null
          ? (json['percentageWorn'] as num).toDouble()
          : 0.0,
      wheelPosition: json['wheelPosition'] as String? ?? '',
      dispositionName: json['dispositionName'] as String? ?? '',
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
    );
  }

  /// ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'tireId': tireId,
      'tireSerialNo': tireSerialNo,
      'manufacturerName': manufacturerName,
      'sizeName': sizeName,
      'typeName': typeName,
      'currentHours': currentHours,
      'currentMiles': currentMiles,
      'currentTreadDepth': currentTreadDepth,
      'percentageWorn': percentageWorn,
      'wheelPosition': wheelPosition,
      'dispositionName': dispositionName,
      'vehicleNumber': vehicleNumber,
    };
  }
}
