import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:emtrack/views/search_install_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class VehicleDiagramForView extends StatefulWidget {
  final RxList<InstalledTire> tires;

  final int vehicleId;

  const VehicleDiagramForView({
    super.key,
    required this.tires,
    required this.vehicleId,
  });

  @override
  State<VehicleDiagramForView> createState() => _VehicleDiagramForViewState();

  static Widget _value(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$l   $v',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _percent(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
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

  static Widget _serial(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue, width: 1.4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VehicleDiagramForViewState extends State<VehicleDiagramForView> {
  String generateRandomSerial() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random();

    String letters = List.generate(
      3,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();

    String numbers = rand.nextInt(9999).toString().padLeft(4, '0');

    return "$letters$numbers"; // Example: ABC4821
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tires = widget.tires;

      // Fixed 2 axle system
      InstalledTire? findTire(String position) {
        return tires.firstWhereOrNull((t) => t.wheelPosition == position);
      }

      return Stack(
        children: [
          /// CENTER VERTICAL AXLE LINE
          Padding(
            padding: const EdgeInsets.only(top: 110.0),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          /// AXLES
          Column(
            children: [
              const SizedBox(height: 24),

              /// AXLE 1
              _axleRow(
                axleNo: "1",
                left: findTire("1L"),
                right: findTire("1R"),
              ),

              const SizedBox(height: 48),

              /// AXLE 2
              _axleRow(
                axleNo: "2",
                left: findTire("2L"),
                right: findTire("2R"),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _axleRow({
    required String axleNo,
    InstalledTire? left,
    InstalledTire? right,
  }) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              left != null
                  ? _tyre(left)
                  : _emptyTyreBox(axleNo: axleNo, side: 'L'),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                ),
                alignment: Alignment.center,
                child: Text(
                  axleNo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              right != null
                  ? _tyre(right)
                  : _emptyTyreBox(axleNo: axleNo, side: 'R'),
            ],
          ),
        ],
      ),
    );
  }

  /// Placeholder box for empty tire positions
  Widget _emptyTyreBox({required String axleNo, required String side}) {
    return InkWell(
      /*  onTap: () async {
        Get.to(
          () => SearchInstallView(),
          arguments: {
            "vehicleId": widget.vehicleId,
            "wheelPosition": "$axleNo$side",
          },
        );
      },*/
      child: Container(
        width: 92,
        height: 160,
        decoration: BoxDecoration(
          //color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade500, width: 2),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              "tire",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              "Installed",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tyre(InstalledTire tire) {
    final percent = (tire.percentageWorn ?? 0).toInt();

    Color borderColor;
    if (percent >= 75) {
      borderColor = Colors.red;
    } else if (percent >= 50) {
      borderColor = Colors.orange;
    } else if (percent >= 25) {
      borderColor = Colors.yellow;
    } else {
      borderColor = Colors.green;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // onTap: () => Get.to(() => InspectTyreView(), arguments: tire),
      child: Column(
        children: [
          VehicleDiagramForView._serial(tire.tireSerialNo ?? ""),
          const SizedBox(height: 10),
          Container(
            width: 92,
            height: 160,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/tirebackground.jpg"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                VehicleDiagramForView._percent("$percent%", borderColor),
                const SizedBox(height: 10),
                VehicleDiagramForView._value(
                  'P',
                  tire.currentPressure?.toString() ?? '',
                ),
                VehicleDiagramForView._value(
                  'To',
                  tire.outsideTread?.toString() ?? '',
                ),
                VehicleDiagramForView._value(
                  'Ti',
                  tire.insideTread?.toString() ?? '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${tire.currentMiles ?? ''} Miles\n${tire.currentHours ?? ''} hrs",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
