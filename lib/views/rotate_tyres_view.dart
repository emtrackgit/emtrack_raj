import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/widgets/vehicle_daigram_Rotate_tyres.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../create_tyre/tyre_rotation_controller.dart';
import '../models/tyre_data.dart';
import '../models/tyre_drag_data.dart';

class RotateTyresView extends StatefulWidget {
  const RotateTyresView({super.key});

  @override
  State<RotateTyresView> createState() => _RotateTyresViewState();
}

class _RotateTyresViewState extends State<RotateTyresView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Rotate Tyres", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Parent Account and Location:"),
              Text(
                "Daves Test-Daves Test",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              Divider(),
              Text("Vehicle ID:"),
              Text(
                "#4032",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  VehicleDiagramRotateTyres(),
                  const SizedBox(width: 20),
                  _centerBuffer(),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  _colorBox('N/I', Colors.grey.shade300),
                  _colorBox('<25', Colors.greenAccent),
                  _colorBox('<50', Colors.yellow),
                  _colorBox('<75', Colors.orange),
                  _colorBox('>75', Colors.redAccent),
                ],
              ),

              const SizedBox(height: 10),
              const Text(
                'Tread Depth: (To) Outside (Ti) Inside (Tm) Middle\nPressure (P) Tyre Pressure',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () {
                  final controller = TyreRotationController.instance;

                  if (controller.bufferTyre != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please place the tyre in a slot before saving"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tyre rotation saved successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );

                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.buttonDanger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 11),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.buttonDanger),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _colorBox(String text, Color color) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: color,
        child: Text(text),
      ),
    );
  }

  Widget _centerBuffer() {
    final controller = TyreRotationController.instance;

    return DragTarget<TyreDragData>(
      onWillAccept: (data) => controller.bufferTyre == null,

      onAccept: (data) {
        setState(() {
          /// Move tyre from slot → buffer
          controller.moveToBuffer(data.slotIndex);
        });
      },

      builder: (context, candidateData, rejectedData) {
        final tyre = controller.bufferTyre;

        return Container(
          width: 90,
          height: 230,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20),
            color: tyre != null ? Colors.white : Colors.transparent,
          ),
          child: tyre != null
              ? Draggable<TyreDragData>(
                  data: TyreDragData(
                    diagramIndex: -1, // ⭐ means coming from buffer
                    slotIndex: -1,
                  ),
                  feedback: Material(
                    color: Colors.transparent,
                    child: _bufferTyreUI(tyre, dragging: true),
                  ),
                  child: _bufferTyreUI(tyre),
                )
              : Text.rich(
                  TextSpan(
                    text: "Rotate \n",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: const [
                      TextSpan(
                        text: "Tire\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "Position"),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
        );
      },
    );
  }

  Widget _bufferTyreUI(TyreData d, {bool dragging = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            d.serial,
            style: const TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 95,
          height: 150,
          decoration: BoxDecoration(
            color: dragging ? Colors.blue : Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: d.borderColor, width: 4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: d.percentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    d.percent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('P   ${d.p}', style: const TextStyle(color: Colors.white)),
                Text(
                  'To  ${d.to}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Ti  ${d.ti}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          d.miles,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
