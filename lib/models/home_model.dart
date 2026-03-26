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
  final String? lastInspection; // ISO date or display string
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
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      parentAccount: json['parent_account'] ?? '',
      location: json['location'] ?? '',
      totalTyres: (json['total_tyres'] ?? 0) as int,
      vehicles: (json['vehicles'] ?? 0) as int,
      imageUrl: json["image"] ?? "",
      unsyncedInspections: (json['unsynced_inspections'] ?? 0) as int,
      syncedInspections: (json['synced_inspections'] ?? 0) as int,
      lastInspection: json['last_inspection'],
      appVersion: json['app_version']?.toString() ?? '1.0',
    );
  }

  get ctrl => null;
}
