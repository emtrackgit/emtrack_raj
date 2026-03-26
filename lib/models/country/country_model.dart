import 'package:emtrack/models/country/state_model.dart';

class CountryModel {
  String countryName;
  int? countryId;
  String? currency;
  List<StateModel>? states;

  CountryModel({
    required this.countryName,
    this.countryId,
    this.currency,
    this.states,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      countryName: json['countryName'],
      countryId: json['countryId'],
      currency: json['currency'],
      states: json['states'] != null
          ? List<StateModel>.from(
              json['states'].map((x) => StateModel.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryName': countryName,
      'countryId': countryId,
      'currency': currency,
      'states': states?.map((x) => x.toJson()).toList(),
    };
  }
}
