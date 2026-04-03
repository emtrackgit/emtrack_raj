import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_model.dart';
import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/services/update_vehicle_service.dart';
import 'package:emtrack/widgets/vehicle_daigram_for_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vehicle_model.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({super.key});

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  final UpdateVehicleService _vehicleService = UpdateVehicleService();
  final selectedCtrl = Get.put(SelectedAccountController());

  final VehicleInspeController c = Get.put(VehicleInspeController());
  VehicleModel? vehicle;
  bool isLoading = true;

  /// ✅ Required for VehicleDiagram
  final RxList<InstalledTire> rxTires = <InstalledTire>[].obs;
  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    final int? vehicleId = Get.arguments;
    if (vehicleId == null) {
      Get.snackbar("Error", "No Vehicle ID provided");
      setState(() => isLoading = false);
      return;
    }

    final fetchedVehicle = await _vehicleService.getVehicleById(vehicleId);
    if (fetchedVehicle == null) {
      Get.snackbar("Error", "Vehicle not found");
    }

    setState(() {
      vehicle = fetchedVehicle;
      isLoading = false;
    });
  }

  int get parsedVehicleId =>
      int.tryParse(vehicle?.vehicleId.toString() ?? "0") ?? 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "View Vehicle",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicle == null
          ? const Center(child: Text("Vehicle not available"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selected parent account & Location"),
                  Obx(
                    () => Text(
                      "${selectedCtrl.parentAccountName.value} - ${selectedCtrl.locationName.value}",
                      style: TextStyle(
                        color: AppColors.buttonDanger,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildInfoRow("Vehicle ID", vehicle!.vehicleNumber ?? '-'),
                  _buildInfoRow(
                    "Tracking Method",
                    vehicle!.mileageType == 1
                        ? "Hours"
                        : vehicle!.mileageType == 2
                        ? "Distance"
                        : vehicle!.mileageType == 3
                        ? "Both"
                        : "-",
                  ),
                  _buildInfoRow(
                    "Current Hours",
                    "${vehicle!.currentHours ?? '-'}",
                  ),
                  _buildInfoRow("Manufacturer", vehicle!.manufacturer ?? "-"),
                  _buildInfoRow("Type", vehicle!.typeName ?? "-"),
                  _buildInfoRow("Model", vehicle!.modelName ?? "-"),
                  _buildInfoRow("Tyre Size", vehicle!.tireSize ?? "-"),
                  _buildInfoRow(
                    "Removal Tread",
                    "${vehicle!.removalTread ?? '-'}",
                  ),
                  _buildInfoRow(
                    "Vehicle Comments",
                    vehicle!.severityComments ?? "-",
                  ),
                  const SizedBox(height: 20),
                  const Text("Vehicle Diagram"),
                  //VehicleDiagramForView(tires: rxTires, vehicleId: parsedVehicleId),
                  Obx(() {
                    final response = c.inspectionResponse.value;

                    if (response == null) {
                      return const Center(child: Text(""));
                    }

                    final tires = response.model?.installedTires ?? [];

                    return VehicleDiagramForView(
                      // tires: tires.obs,
                      tires: c.tires,
                      vehicleId: parsedVehicleId,
                    );
                  }),

                  const SizedBox(height: 20),
                  _buildInfoRow(
                    "Recommended Pressure for Axel1",
                    "${vehicle!.recommendedPressure ?? 0} PSI",
                  ),
                  _buildInfoRow(
                    "Recommended Pressure for Axel2",
                    "${vehicle!.recommendedPressure ?? 'NaN'} PSI",
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 24,
        height: 56,
        child: Material(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Get.to(() => VehicleInspeView(), arguments: vehicle?.vehicleId);
            },
            child: const Center(
              child: Text(
                "Inspect",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
