class InspectionModel {
  final String id;
  final String vehicleNo;
  final bool isSynced;

  InspectionModel({
    required this.id,
    required this.vehicleNo,
    required this.isSynced,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString().toLowerCase();
    final isSynced = rawStatus == 'synced' ||
        rawStatus == 'approved' ||
        rawStatus == 'complete' ||
        rawStatus == 'completed';

    final id = (json['inspRequestId'] ?? json['id'] ?? '').toString();
    final vehicleNo = (json['vehicleNumber'] ??
            json['vehicleNo'] ??
            json['vehicleId'] ??
            '')
        .toString();

    return InspectionModel(id: id, vehicleNo: vehicleNo, isSynced: isSynced);
  }
}
