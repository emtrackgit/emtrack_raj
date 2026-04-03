class StateModel {
  int? stateId;
  String? stateName;
  int? countryId;

  StateModel({this.stateId, this.stateName, this.countryId});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['stateId'],
      stateName: json['stateName'],
      countryId: json['countryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'stateId': stateId, 'stateName': stateName, 'countryId': countryId};
  }
}
