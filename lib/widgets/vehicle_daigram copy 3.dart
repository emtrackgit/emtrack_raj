import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleDiagram extends StatelessWidget {
  final List<InstalledTire> tires;

  const VehicleDiagram({super.key, required this.tires});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🌟 CENTER VERTICAL AXLE LINE (professional thickness)
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        /// CONTENT
        Column(
          children: [
            const SizedBox(height: 24),

            _axleRow(axleNo: '1', left: _dummyLeft(), right: _dummyRight()),

            const SizedBox(height: 48),

            _axleRow(axleNo: '2', left: _dummyLeft(), right: _dummyRight()),

            const SizedBox(height: 48),
          ],
        ),
      ],
    );
  }

  /* ================= AXLE ROW ================= */

  Widget _axleRow({
    required String axleNo,
    required _TyreData left,
    _TyreData? right,
  }) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// 🔗 HORIZONTAL CONNECTOR (perfect center)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          /// MAIN CONTENT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tyre(left),

              /// ⚙️ CENTER AXLE CIRCLE
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  axleNo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              right != null ? _tyre(right) : const SizedBox(width: 90),
            ],
          ),
        ],
      ),
    );
  }

  /* ================= TYRE ================= */

  Widget _tyre(_TyreData d) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.to(() => InspectTyreView()),
      child: Column(
        children: [
          _serial(d.serial),
          const SizedBox(height: 10),

          /// TYRE CARD
          Container(
            width: 92,
            height: 160,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/tirebackground.jpg"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: d.borderColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                _percent(d.percent, d.percentColor),
                const SizedBox(height: 10),
                _value('P', d.p),
                _value('To', d.to),
                _value('Ti', d.ti),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            d.miles,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  /* ================= DUMMY DATA ================= */

  _TyreData _dummyLeft() => _TyreData(
    serial: 'E878YU8',
    percent: '13%',
    percentColor: Colors.green,
    borderColor: Colors.green,
    p: '0',
    to: '75',
    ti: '75',
    miles: '0 Miles\n122243 hrs',
  );

  _TyreData _dummyRight() => _TyreData(
    serial: 'P87987R',
    percent: '64%',
    percentColor: Colors.orange,
    borderColor: Colors.orange,
    p: '0',
    to: '29',
    ti: '28',
    miles: '34 Miles\n123578 hrs',
  );

  /* ================= SMALL WIDGETS ================= */

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
          fontSize: 13,
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

/* ================= MODEL ================= */

class _TyreData {
  final String serial, percent, p, to, ti, miles;
  final Color borderColor, percentColor;

  _TyreData({
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
