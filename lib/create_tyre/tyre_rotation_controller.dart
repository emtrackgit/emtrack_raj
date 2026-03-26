import 'package:flutter/material.dart';

import '../inspection/vehicle_inspe_model.dart';
import '../models/tyre_data.dart';

class TyreRotationController {
  static final TyreRotationController instance = TyreRotationController._();

  TyreRotationController._();

  InstalledTire? bufferTyre;
  int? bufferIndex;

  List<String> slotWheelPositions = [];
  List<InstalledTire?> tyres = [];

  void loadFromInstalledTires(List<InstalledTire> installed) {
    final slots = <String>['1L', '1R', '2L', '2R'];
    final byPos = <String, InstalledTire>{};
    for (final t in installed) {
      final key = (t.wheelPosition ?? '').toUpperCase().trim();
      if (key.isEmpty) continue;
      byPos.putIfAbsent(key, () => t);
    }

    tyres = slots.map((s) => byPos[s]).toList();
    slotWheelPositions = List<String>.from(slots);
  }

  TyreData toUi(InstalledTire t) {
    final percentValue = (t.percentageWorn ?? 0).round();
    final percent = percentValue <= 0 ? 'N/I' : '$percentValue%';
    final color = _percentColor(percentValue);
    final p = ((t.currentPressure ?? 0).round()).toString();
    final to = ((t.outsideTread ?? 0).round()).toString();
    final ti = ((t.insideTread ?? 0).round()).toString();
    final miles = '${(t.currentMiles ?? 0).round()} Miles\n${(t.currentHours ?? 0).round()} hrs';

    return TyreData(
      serial: t.tireSerialNo ?? '',
      percent: percent,
      percentColor: color,
      borderColor: color,
      p: p,
      to: to,
      ti: ti,
      miles: miles,
    );
  }

  Color _percentColor(int percent) {
    if (percent <= 0) return Colors.grey.shade300;
    if (percent < 25) return Colors.green;
    if (percent < 50) return Colors.yellow;
    if (percent < 75) return Colors.orange;
    return Colors.redAccent;
  }

  /// MOVE to empty slot
  void moveTyre(int from, int to) {
    tyres[to] = tyres[from];
    tyres[from] = null;
  }

  /// SWAP tyres
  void swapTyres(int from, int to) {
    final temp = tyres[to];
    tyres[to] = tyres[from];
    tyres[from] = temp;
  }

  /// Move tyre to buffer
  void moveToBuffer(int index) {
    bufferTyre = tyres[index];
    bufferIndex = index;
    tyres[index] = null;
  }

  /// Place buffer tyre
  void placeFromBuffer(int index) {
    if (bufferTyre == null) return;

    tyres[index] = bufferTyre;
    bufferTyre = null;
    bufferIndex = null;
  }
}
