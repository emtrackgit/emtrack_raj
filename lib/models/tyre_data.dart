import 'dart:ui';

class TyreData {
  final String serial, percent, p, to, ti, miles;
  final Color borderColor, percentColor;

  TyreData({
    required this.serial,
    required this.percent,
    required this.percentColor,
    required this.borderColor,
    required this.p,
    required this.to,
    required this.ti,
    required this.miles,
  });
}
