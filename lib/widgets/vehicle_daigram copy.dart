import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleDiagram extends StatelessWidget {
  const VehicleDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        //  const Text(
        //     'Vehicle Diagram',
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        //   ),
        const SizedBox(height: 12),

        /// LEGEND BOX
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tyre Serial Number',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _Dot(Colors.green),
                  SizedBox(width: 6),
                  Text('Inspected Tyre', style: TextStyle(color: Colors.green)),
                  SizedBox(width: 20),
                  _Dot(Colors.blue),
                  SizedBox(width: 6),
                  Text(
                    'Not Inspected Tyre',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        /// L R
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'L',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
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
        _axle(
          axleNo: '1',
          left: _TyreData(
            serial: 'F3R284522',
            percent: '57%',
            percentColor: const Color(0xFFB57B1C),
            borderColor: const Color(0xFFB57B1C),
            p: '0',
            to: '33',
            ti: '33',
            miles: '0 Miles\n4592 hrs',
          ),
          right: _TyreData(
            serial: 'XES7843AB',
            percent: '19%',
            percentColor: Colors.green,
            borderColor: Colors.green,
            p: '90',
            to: '47',
            ti: '47',
            miles: '5 Miles\n1200 hrs',
          ),
        ),

        const SizedBox(height: 26),

        /// AXLE 2
        _axle(
          axleNo: '2',
          left: _TyreData(
            serial: 'F3R382561',
            percent: '61%',
            percentColor: const Color(0xFFB57B1C),
            borderColor: const Color(0xFFB57B1C),
            p: '0',
            to: '30',
            ti: '30',
            miles: '0 Miles\n4592 hrs',
          ),
          right: _TyreData(
            serial: 'F3R383276',
            percent: '51%',
            percentColor: const Color(0xFFB57B1C),
            borderColor: const Color(0xFFB57B1C),
            p: '0',
            to: '37',
            ti: '37',
            miles: '0 Miles\n4592 hrs',
          ),
        ),
      ],
    );
  }

  /* ================= AXLE ================= */

  static Widget _axle({
    required String axleNo,
    required _TyreData left,
    required _TyreData right,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_tyre(left), _axleCenter(axleNo), _tyre(right)],
    );
  }

  /* ================= TYRE ================= */

  static Widget _tyre(_TyreData d) {
    return InkWell(
      onTap: () {
        Get.to(() => InspectTyreView());
      },
      child: Column(
        children: [
          _serial(d.serial),
          const SizedBox(height: 8),
          Container(
            width: 95,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black,
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
      ),
    );
  }

  static Widget _serial(String text) {
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

  static Widget _percent(String text, Color color) {
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

  static Widget _value(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$l   $v',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  /* ================= AXLE CENTER ================= */

  static Widget _axleCenter(String no) {
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

/* ================= HELPERS ================= */

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

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
