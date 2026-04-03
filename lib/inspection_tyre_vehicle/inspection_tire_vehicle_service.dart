class InspectionTireVehicleService {
  Future<List<String>> fetchVehicles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['#4032', '#5091', '12345', '1422', '2160', '2345', '24234'];
  }

  Future<List<String>> fetchTyres() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      '0316NJ3475',
      'F3R284522',
      'F3R382561',
      'F3R383276',
      'F3R383283',
      'XES7843AB',
      'ZA00045',
    ];
  }
}
