import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/auth_controller.dart';
import 'package:emtrack/inspection/vehicle_inspe_view.dart';
import 'package:emtrack/inspection_tyre_vehicle/inspection_vehicle_tyre_view.dart';
import 'package:emtrack/l10n/app_localizations.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/search_tyre_vehicle/search_vehicle_tyre_view.dart';
import 'package:emtrack/views/all_vehicles_list_view.dart';
import 'package:emtrack/views/change_account_view.dart';
import 'package:emtrack/views/view_inspection_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_snackbar.dart';
import 'home_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeController ctrl = Get.put(HomeController());
  final auth = Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final args = Get.arguments;
      print("DEBUG: Home Arguments: $args");

      if (args == null || args["showSuccess"] != true) return;

      final bool isTyre = args["module"] == "tyre";

      final String message = isTyre
          ? (args["type"] == "update"
          ? "Tire updated successfully"
          : "New Tire submitted successfully")
          : (args["type"] == "update"
          ? "Vehicle updated successfully"
          : "New Vehicle Created successfully.");

      final String numberText = isTyre
          ? "Tire Serial No: ${args["serialNo"] ?? '-'}"
          : "Vehicle with Id: Vehicle ${args["vehicleNo"] ?? '-'} Created Successfully.";

      final int? vehicleId = isTyre
          ? null
          : (args["vehicleId"] is int
          ? args["vehicleId"]
          : int.tryParse(args["vehicleId"].toString()));

      print("DEBUG: vehicleId = $vehicleId");

      await ctrl.fetchHome();
      await ctrl.fetchReportDashboardDataHome();

      AppSnackbar.success("$message\n$numberText");

      Future.delayed(const Duration(seconds: 3), () {
        if (!isTyre && vehicleId != null && vehicleId > 0) {
          Connectivity().checkConnectivity().then((result) {
            final isOffline = result.contains(ConnectivityResult.none);
            if (!isOffline) {
              Get.offAll(() => VehicleInspeView(), arguments: vehicleId);
            }
          });
        }
      });
    });
  }

  String _getLocationText() {
    final account = (ctrl.homeData.value?.parentAccount?.isNotEmpty == true)
        ? ctrl.homeData.value!.parentAccount!
        : ctrl.selectedParentAccountName.value;

    final location = (ctrl.homeData.value?.location?.isNotEmpty == true)
        ? ctrl.homeData.value!.location!
        : ctrl.selectedLocationName.value;

    final accountText  = account.isNotEmpty  ? account  : '--';
    final locationText = location.isNotEmpty ? location : '--';
    return "$accountText - $locationText";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/apk_logo.png', width: 80),
            const SizedBox(width: 8),
            Image.asset('assets/images/logo.png', width: 120),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: SafeArea(child: HomeDrawer()),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Obx(() {
              final data = ctrl.homeData.value;
              return RefreshIndicator(
                onRefresh: ctrl.refreshHome,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ─── Welcome Block ───
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        color: Colors.grey[850],
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Greeting ───
                            Obx(
                                  () => Text(
                                "${AppLocalizations.of(context)!.greeting}, ${ctrl.username.value},",
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Selected Parent Account & Location',
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColors.textWhite,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.5,
                                      child: Obx(
                                            () => Text(
                                          _getLocationText(),
                                          style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    final updated = await Get.to(
                                          () => ChangeAccountView(),
                                    );
                                    if (updated == true) {
                                      await ctrl.fetchHome();
                                      await ctrl.fetchReportDashboardDataHome();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Change",
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // ─── Search Box ───
                            GestureDetector(
                              onTap: () => Get.to(() => SearchVehicleTyreView()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.white54),
                                    SizedBox(width: 10),
                                    Text(
                                      'Search Vehicle / Tire for inspection',
                                      style: TextStyle(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ─── Total Tires + Vehicles Cards ───
                            Row(
                              children: [
                                // ─── Total Tires Card ───
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.toNamed(AppPages.ALL_TYRE_WIEW),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svgImage/total-tires-icon.svg',
                                                width: 40,
                                                height: 40,
                                                colorFilter: const ColorFilter.mode(
                                                  Colors.red,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Total Tires',
                                                    style: TextStyle(
                                                      color: AppColors.textWhite,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // ✅ tyreCount — local-first, network se update
                                                  Obx(
                                                        () => Text(
                                                      ctrl.tyreCount.value.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 26,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'View',
                                                  style: TextStyle(
                                                    color: AppColors.textWhite,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  ' >',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // ─── Vehicles Card ───
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => AllVehicleListView()),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svgImage/vehicle-icon.svg',
                                                width: 40,
                                                height: 40,
                                                colorFilter: const ColorFilter.mode(
                                                  Colors.red,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Vehicles',
                                                    style: TextStyle(
                                                      color: AppColors.textWhite,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // ✅ vehicleCount — local-first, network se update
                                                  Obx(
                                                        () => Text(
                                                      ctrl.vehicleCount.value.toString(),
                                                      style: const TextStyle(
                                                        color: AppColors.textWhite,
                                                        fontSize: 26,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'View',
                                                  style: TextStyle(
                                                    color: AppColors.textWhite,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  ' >',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ─── Last Inspection + Sync ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Inspection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  data?.lastInspection ?? '--',
                                  style: const TextStyle(color: AppColors.textGrey),
                                ),
                              ],
                            ),
                            Obx(
                                  () => ElevatedButton.icon(
                                onPressed: ctrl.isLoading.value
                                    ? null
                                    : () => ctrl.syncInspections(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.red),
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(Icons.sync, color: Colors.red),
                                label: const Text(
                                  'Sync',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ─── View Inspections ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'View Inspections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () => Get.to(
                                        () => const ViewInspectionPage(),
                                    arguments: 0,
                                  ),
                                  child: Obx(
                                        () => inspectionCard(
                                      title: 'Unsynced Inspection',
                                      count: ctrl.homeData.value
                                          ?.unsyncedInspections
                                          .toString() ??
                                          '0',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => Get.to(
                                        () => const InspectionVehicleTyreView(),
                                    arguments: 1,
                                  ),
                                  child: Obx(
                                        () => inspectionCard(
                                      title: 'Synced Inspection',
                                      count: ctrl.homeData.value
                                          ?.syncedInspections
                                          .toString() ??
                                          '0',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── Vehicles/Tires Inspections ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vehicles/Tires Inspections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // ─── Vehicle Inspection Card ───
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Vehicle Inspection",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Obx(
                                              () => Text(
                                            ctrl.homeCount.value?.vehicleCount
                                                ?.toString() ??
                                                "0",
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Get.to(
                                                () => InspectionVehicleTyreView(),
                                          ),
                                          child: const Text(
                                            "view >",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ─── Tire Inspection Card ───
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Tire Inspection",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Obx(
                                              () => Text(
                                            ctrl.homeCount.value?.totalTiresCount
                                                ?.toString() ??
                                                "0",
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Get.to(
                                                () => InspectionVehicleTyreView(),
                                          ),
                                          child: const Text(
                                            "view >",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              );
            }),
          ),

          // ─── Loader Overlay ───
          Obx(() {
            if (!ctrl.isLoading.value) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                  child: Center(
                    child: Image.asset(
                      'assets/images/emtrack_loader.gif',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      bottomNavigationBar: InkWell(
        onTap: () async {
          await Get.to(() => SearchVehicleTyreView());
          ctrl.fetchHome();
          ctrl.loadTyreCountByAccount();
          ctrl.loadVehicleCountByAccount();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 7,
                ),
                child: const Text(
                  "Start Inspection",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () => Get.to(() => SearchVehicleTyreView()),
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inspectionCard({required String title, required String count}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(count, style: const TextStyle(fontSize: 18)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "View >",
                style: TextStyle(
                  color: AppColors.buttonDanger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
