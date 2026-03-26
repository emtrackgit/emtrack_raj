import 'package:emtrack/views/inspect_tyre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleDiagram extends StatelessWidget {
  const VehicleDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// CENTER VERTICAL LINE (ONE SINGLE LINE)
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(width: 8, color: Colors.grey.shade700),
          ),
        ),

        /// CONTENT
        Column(
          children: [
            const SizedBox(height: 20),

            _axleRow(axleNo: '1', left: _dummyLeft(), right: _dummyRight()),

            const SizedBox(height: 40),

            _axleRow(axleNo: '2', left: _dummyLeft(), right: _dummyRight()),

            const SizedBox(height: 40),
          ],
        ),
      ],
    );
  }

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
          /// 🔴 LEFT HORIZONTAL LINE
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 6, // thickness
                width: double.infinity, // 🔥 full fill
                color: Colors.grey.shade700,
              ),
            ),
          ),

          /// 🔴 RIGHT HORIZONTAL LINE (only if tyre exists)
          if (right != null)
            Positioned(
              left: MediaQuery.of(Get.context!).size.width / 2,
              right: 0,
              child: Container(height: 3, color: Colors.grey.shade700),
            ),

          /// CONTENT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tyre(left),

              /// CENTER CIRCLE
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: Text(
                    axleNo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              right != null ? _tyre(right) : const SizedBox(width: 95),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tyre(_TyreData d) {
    return InkWell(
      onTap: () {
        Get.to(() => InspectTyreView());
      },
      child: Column(
        children: [
          _serial(d.serial),
          const SizedBox(height: 8),
          Container(
            width: 90,
            height: 160,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tirebackground.jpg"),
                fit: BoxFit.cover,
              ),
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
          Text(d.miles, textAlign: TextAlign.center),
        ],
      ),
    );
  }

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
  static Widget _value(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$l   $v',
        style: const TextStyle(color: Colors.white, fontSize: 14),
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
