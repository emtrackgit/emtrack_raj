import 'package:flutter/material.dart';

import '../models/tyre_data.dart';

class TyreRotationController {
  static final TyreRotationController instance = TyreRotationController._();

  TyreRotationController._();

  TyreData? bufferTyre;
  int? bufferIndex;

  List<TyreData?> tyres = [
    TyreData(
      serial: 'F3R284522',
      percent: '57%',
      percentColor: const Color(0xFFB57B1C),
      borderColor: const Color(0xFFB57B1C),
      p: '0',
      to: '33',
      ti: '33',
      miles: '0 Miles\n4592 hrs',
    ),
    TyreData(
      serial: 'XES7843AB',
      percent: '19%',
      percentColor: Colors.green,
      borderColor: Colors.green,
      p: '90',
      to: '47',
      ti: '47',
      miles: '5 Miles\n1200 hrs',
    ),
    TyreData(
      serial: 'F3R382561',
      percent: '61%',
      percentColor: const Color(0xFFB57B1C),
      borderColor: const Color(0xFFB57B1C),
      p: '0',
      to: '30',
      ti: '30',
      miles: '0 Miles\n4592 hrs',
    ),
    TyreData(
      serial: 'F3R383276',
      percent: '51%',
      percentColor: const Color(0xFFB57B1C),
      borderColor: const Color(0xFFB57B1C),
      p: '0',
      to: '37',
      ti: '37',
      miles: '0 Miles\n4592 hrs',
    ),
  ];

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
