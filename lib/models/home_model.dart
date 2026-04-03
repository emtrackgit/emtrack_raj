class HomeModel {
  final String username;
  final String role;
  final String parentAccount;
  final String location;
  final int totalTyres;
  final int vehicles;
  final String imageUrl;
  final int unsyncedInspections;
  final int syncedInspections;
  final String? lastInspection;
  final String appVersion;

  HomeModel({
    required this.username,
    required this.role,
    required this.parentAccount,
    required this.location,
    required this.totalTyres,
    required this.vehicles,
    required this.imageUrl,
    required this.unsyncedInspections,
    required this.syncedInspections,
    this.lastInspection,
    required this.appVersion,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      username:            json['username'] ?? '',
      role:                json['role'] ?? '',
      // ✅ parentAccount aur location — multiple field names try karo
      // Server alag alag keys de sakta hai
      parentAccount: json['parentAccount'] ??
          json['parent_account'] ??
          json['accountName'] ??
          '',
      location: json['location'] ??
          json['locationName'] ??
          json['location_name'] ??
          '',
      totalTyres:          (json['totalTyres'] ?? json['total_tyres'] ?? 0) as int,
      vehicles:            (json['vehicles'] ?? 0) as int,
      imageUrl:            json['imageUrl'] ?? json['image'] ?? '',
      unsyncedInspections: (json['unsyncedInspections'] ?? json['unsynced_inspections'] ?? 0) as int,
      syncedInspections:   (json['syncedInspections'] ?? json['synced_inspections'] ?? 0) as int,
      lastInspection:      json['lastInspection'] ?? json['last_inspection'],
      appVersion:          json['appVersion']?.toString() ??
          json['app_version']?.toString() ??
          '1.0',
    );
  }
}