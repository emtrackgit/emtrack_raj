import 'package:emtrack/controllers/all_vehicles_controller.dart';
import 'package:emtrack/controllers/install_tyre_controller.dart';
import 'package:emtrack/controllers/password_reset_controller.dart';
import 'package:emtrack/controllers/preferences_controller.dart';
import 'package:emtrack/controllers/remove_tyre_controller.dart';
import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/controllers/all_tyre_controller.dart';
import 'package:emtrack/controllers/update_hours_controller.dart';
import 'package:emtrack/controllers/vehicles_tires_inscetion/tire_inspection_controller.dart';
import 'package:emtrack/create_tyre/create_tyre_controller.dart';
import 'package:emtrack/edit_tyre/edit_tyre_controller.dart';
import 'package:emtrack/controllers/vehicles_tires_inscetion/vehicle_inspection_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VehicleInspectionController());
    Get.lazyPut(() => CreateTyreController());
    Get.lazyPut(() => PreferencesController());
    Get.lazyPut(() => AllTyreController());
    Get.lazyPut(() => AllVehicleController());
    Get.lazyPut(() => SelectedAccountController());
    Get.lazyPut(() => UpdateHoursController());
    Get.lazyPut(() => EditTyreController());
    Get.lazyPut(() => VehicleInspectionController());
    Get.lazyPut(() => TireInspectionController());
    Get.lazyPut(() => RemoveTyreController());
    Get.lazyPut(() => VehicleInspeController());
    Get.lazyPut(() => InstallTyreController());
    Get.lazyPut(() => ResetPasswordController());
  }
}
