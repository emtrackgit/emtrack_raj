import 'package:flutter/material.dart';

import '../create_tyre/tyre_rotation_controller.dart';
import '../models/tyre_drag_data.dart';

class VehicleDiagramRotateTyres extends StatefulWidget {
  const VehicleDiagramRotateTyres({super.key});

  @override
  State<VehicleDiagramRotateTyres> createState() =>
      _VehicleDiagramRotateTyresState();
}

/// ================= TYRE STATE =================

class _VehicleDiagramRotateTyresState extends State<VehicleDiagramRotateTyres> {
  /// ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        /// L R
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'L',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 170),
            Text(
              'R',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        /// AXLE 1
        _axle(axleNo: '1', leftIndex: 0, rightIndex: 1),

        const SizedBox(height: 26),

        /// AXLE 2
        _axle(axleNo: '2', leftIndex: 2, rightIndex: 3),
      ],
    );
  }

  /// ================= AXLE =================

  Widget _axle({
    required String axleNo,
    required int leftIndex,
    required int rightIndex,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tyreSlot(leftIndex),
        _axleCenter(axleNo),
        _tyreSlot(rightIndex),
      ],
    );
  }

  Widget _tyreSlot(int index) {
    final controller = TyreRotationController.instance;
    final data = controller.tyres[index];

    return DragTarget<TyreDragData>(
      onWillAccept: (drag) => drag != null && drag.slotIndex != index,
      onAccept: (drag) {
        setState(() {
          final controller = TyreRotationController.instance;

          /// From buffer
          if (drag.slotIndex == -1) {
            controller.placeFromBuffer(index);
            return;
          }

          /// Swap
          if (controller.tyres[index] != null) {
            controller.swapTyres(drag.slotIndex, index);
          }
          /// Move
          else {
            controller.moveTyre(drag.slotIndex, index);
          }
        });
      },

      builder: (context, candidateData, rejectedData) {
        if (data == null) {
          return _emptyTyre();
        }

        return Draggable<TyreDragData>(
          data: TyreDragData(diagramIndex: 0, slotIndex: index),
          feedback: Material(
            color: Colors.transparent,
            child: _tyreUI(data, dragging: true),
          ),
          childWhenDragging: _emptyTyre(),
          child: _tyreUI(data),
        );
      },
    );
  }

  /// ================= TYRE UI =================

  Widget _tyreUI(d, {bool dragging = false}) {
    return Column(
      children: [
        _serial(d.serial),
        const SizedBox(height: 8),
        Container(
          width: 95,
          height: 160,
          decoration: BoxDecoration(
            color: dragging ? Colors.blue : Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: d.borderColor, width: 4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _percent(d.percent, d.percentColor),
                const SizedBox(height: 8),
                _value('P', d.p),
                _value('To', d.to),
                _value('Ti', d.ti),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          d.miles,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _emptyTyre() {
    return Container(
      width: 95,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: const Center(child: Icon(Icons.open_with, color: Colors.grey)),
    );
  }

  /// ================= SMALL UI HELPERS =================

  Widget _serial(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue, fontSize: 12),
      ),
    );
  }

  Widget _percent(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _value(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$l   $v',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _axleCenter(String no) {
    return Column(
      children: [
        Container(width: 4, height: 60, color: Colors.grey.shade700),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade700,
          ),
          child: Center(
            child: Text(no, style: const TextStyle(color: Colors.white)),
          ),
        ),
        Container(width: 4, height: 60, color: Colors.grey.shade700),
      ],
    );
  }
}

/// ================= MODEL =================
