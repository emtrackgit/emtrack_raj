import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/widgets/vehicle_daigram_Rotate_tyres.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../create_tyre/tyre_rotation_controller.dart';
import '../inspection/vehicle_inspe_controller.dart';
import '../inspection/vehicle_inspe_model.dart';
import '../inspection/vehicle_inspe_service.dart';
import '../models/tyre_data.dart';
import '../models/tyre_drag_data.dart';
import '../services/inspect_tyre_service.dart';

class RotateTyresView extends StatefulWidget {
  const RotateTyresView({super.key});

  @override
  State<RotateTyresView> createState() => _RotateTyresViewState();
}

class _RotateTyresViewState extends State<RotateTyresView> {
  final rotationController = TyreRotationController.instance;
  final vehicleInspeService = VehicleInspeService();
  final inspectService = InspectTyreService();
  final selectedCtrl = Get.put(SelectedAccountController());

  int vehicleId = 0;
  String vehicleNumber = '';

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args is Map) {
      final rawVehicleId = args['vehicleId'];
      if (rawVehicleId is int) vehicleId = rawVehicleId;
      if (rawVehicleId is String) vehicleId = int.tryParse(rawVehicleId) ?? 0;
      vehicleNumber = (args['vehicleNumber'] ?? '').toString();

      final rawTires = args['tires'];
      if (rawTires is List) {
        final installed = rawTires.whereType<InstalledTire>().toList();
        rotationController.loadFromInstalledTires(installed);
      }
    }
  }

  Future<void> _saveRotation() async {
    final slotPositions = rotationController.slotWheelPositions;
    if (slotPositions.isEmpty || slotPositions.length != rotationController.tyres.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rotation data missing")),
      );
      return;
    }

    Map<String, dynamic> emptyGraph() {
      return {
        "treadDepthList": [],
        "pressureList": [],
        "costPerHourList": [],
        "hoursPerTreadDepthList": [],
        "milesPerTreadDepthList": [],
      };
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final tireList = <Map<String, dynamic>>[];
    for (var i = 0; i < rotationController.tyres.length; i++) {
      final t = rotationController.tyres[i];
      if (t == null) continue;
      final wp = slotPositions[i];
      if (wp.trim().isEmpty) continue;

      final tireId = t.tireId ?? 0;
      Map<String, dynamic> payload = {};
      if (tireId > 0) {
        try {
          payload = await inspectService.getTireById(tireId);
        } catch (e) {
          print("❌ Rotate fetch tire failed for $tireId => $e");
          payload = {};
        }
      }

      payload["tireId"] ??= tireId;
      payload["vehicleId"] ??= t.vehicleId ?? vehicleId;
      payload["locationId"] ??= t.locationId ?? 0;
      payload["parentAccountId"] ??= t.parentAccountId ?? 0;
      payload["tireSerialNo"] ??= t.tireSerialNo ?? "";
      payload["brandNo"] ??= t.brandNo;
      payload["manufacturerId"] ??= t.manufacturerId ?? 0;
      payload["typeId"] ??= t.typeId ?? 0;
      payload["sizeId"] ??= t.sizeId ?? 0;
      payload["dispositionId"] ??= t.dispositionId ?? 0;
      payload["currentMiles"] ??= t.currentMiles ?? 0.0;
      payload["currentHours"] ??= t.currentHours ?? 0.0;
      payload["outsideTread"] ??= (t.outsideTread ?? 0).toDouble();
      payload["middleTread"] ??= (t.middleTread ?? 0).toDouble();
      payload["insideTread"] ??= (t.insideTread ?? 0).toDouble();
      payload["currentTreadDepth"] ??= (t.currentTreadDepth ?? 0).toDouble();
      payload["currentPressure"] ??= (t.currentPressure ?? 0).toDouble();
      payload["percentageWorn"] ??= (t.percentageWorn ?? 0).toDouble();

      payload["wheelPosition"] = wp;

      payload["tireGraphData"] ??= emptyGraph();

      tireList.add(payload);
    }

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    final ok = await vehicleInspeService.saveVehicleFootPrintDetails(
      tireList: tireList,
    );

    if (!mounted) return;

    if (ok) {
      if (Get.isRegistered<VehicleInspeController>()) {
        await Get.find<VehicleInspeController>().fetchInspectionData();
      }
      if (!mounted) return;
      Navigator.pop(context);
      Get.snackbar(
        "Tire Rotation Successful.",
        "Tire rotation updated and saved successfully on Vehicle ${vehicleNumber.isNotEmpty ? vehicleNumber : '#$vehicleId'}.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    Get.snackbar(
      "Error",
      "Rotation save failed. Check console logs for ROTATE STATUS/RESP.",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Rotate Tires", style: TextStyle(color: Colors.white)),
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
              Obx(() {
                final text =
                    "${selectedCtrl.parentAccountName.value}-${selectedCtrl.locationName.value}";
                return Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                );
              }),

              Divider(),
              Text("Vehicle ID:"),
              Text(
                vehicleNumber.isNotEmpty ? vehicleNumber : "#$vehicleId",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                onTap: _saveRotation,
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
                  onPressed: () => Navigator.pop(context),
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
                    child: _bufferTyreUI(controller.toUi(tyre), dragging: true),
                  ),
                  child: _bufferTyreUI(controller.toUi(tyre)),
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
