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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final bool _isUserOpeningDrawer = false;

  final HomeController ctrl = Get.put(HomeController());

  final auth = Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args = Get.arguments;
      print("DEBUG: Home Arguments: $args");

      // Agar arguments nahi aaye ya showSuccess true nahi hai, return
      if (args == null || args["showSuccess"] != true) return;

      // Module check: tyre ya vehicle
      final bool isTyre = args["module"] == "tyre";

      // Dialog message
      final String message = isTyre
          ? (args["type"] == "update"
                ? "Tire updated successfully"
                : "New Tire submitted successfully")
          : (args["type"] == "update"
                ? "Vehicle updated successfully"
                : "New Vehicle Created successfully.");

      // Number text
      final String numberText = isTyre
          ? "Tire Serial No: ${args["serialNo"] ?? '-'}"
          : "Vehicle with Id: Vehicle ${args["vehicleNo"] ?? '-'} Created Successfully.";

      // Vehicle ID only for vehicle
      final int? vehicleId = isTyre
          ? null
          : (args["vehicleId"] is int
                ? args["vehicleId"]
                : int.tryParse(args["vehicleId"].toString()));

      print("DEBUG: vehicleId = $vehicleId"); // Debug print

      // Get.snackbar(
      //   "Success",
      //   "$message\n$numberText",
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      //   margin: const EdgeInsets.all(10),
      //   borderRadius: 8,
      //   duration: const Duration(seconds: 3),
      // );

      AppSnackbar.success("$message\n$numberText");

      Future.delayed(const Duration(seconds: 3), () {
        if (!isTyre && vehicleId != null) {
          Get.offAll(() => VehicleInspeView(), arguments: vehicleId);
        }
      });

      // Show dialog
      // Get.dialog(
      //   AlertDialog(
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     title: const Text(
      //       "Success",
      //       style: TextStyle(fontWeight: FontWeight.bold),
      //     ),
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(message),
      //         const SizedBox(height: 12),
      //         Text(
      //           numberText,
      //           style: const TextStyle(
      //             fontWeight: FontWeight.bold,
      //             color: Colors.black,
      //             fontSize: 16,
      //           ),
      //         ),
      //         if (!isTyre && vehicleId != null) ...[
      //           const SizedBox(height: 8),
      //           /*  Text(
      //             "Vehicle with ID: Vehicle $vehicleId Created Successfuly.",
      //             style: const TextStyle(
      //               fontWeight: FontWeight.bold,
      //               color: Colors.blue,
      //               fontSize: 16,
      //             ),
      //           ),*/
      //           Text("Redirecting to Vehicle Inspection Now."),
      //         ],
      //       ],
      //     ),
      //     /* actions: [
      //       /* TextButton(
      //         onPressed: () {
      //           if (isTyre) {
      //             Get.back();
      //           } else {
      //             // ✅ Correctly pass vehicleId as a Map
      //             Get.offAll(() => VehicleInspeView(), arguments: vehicleId);
      //           }
      //         },
      //         child: const Text("OK"),
      //       ),*/
      //     ],*/
      //   ),
      //   barrierDismissible: false,
      // );

      // /// 🔥 AUTO REDIRECT AFTER 2 SECONDS
      // Future.delayed(const Duration(seconds: 10), () {
      //   Get.back(); // Close dialog

      //   if (!isTyre && vehicleId != null) {
      //     Get.offAll(
      //       () => VehicleInspeView(),
      //       arguments: vehicleId,
      //       //  {
      //       //   "vehicleId": vehicleId,
      //       //   "inspectionId": args['vehicleNo'],
      //       // },
      //     );
      //   }
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(
                context,
              ).openDrawer(); // open drawer only when user clicks
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/apk_logo.png', width: 80),
            SizedBox(width: 8),
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
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Welcome block + selected parent account
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        color: Colors.grey[850],
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  "Welcome, ${ctrl.username.value}",
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Selected Parent Account & Location',
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AppColors.textWhite,
                                    ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(
                                        "${data?.parentAccount ?? ctrl.selectedParentAccountName.value}-${data?.location ?? ctrl.selectedLocationName.value}",
                                        style: TextStyle(
                                          color: AppColors.textWhite,
                                          fontWeight: FontWeight.bold,
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
                                      ctrl.fetchHome(); // refresh home
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
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
                            SizedBox(height: 12),
                            // Search box
                            GestureDetector(
                              onTap: () {
                                // open search page
                                Get.to(() => SearchVehicleTyreView());
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.white54),
                                    SizedBox(width: 10),
                                    Text(
                                      'Search Vehicle / Tire for inspection',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            // cards row
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.toNamed(AppPages.ALL_TYRE_WIEW);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svgImage/total-tires-icon.svg',
                                                width: 34,
                                                height: 34,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Colors.red,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Total Tires',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textWhite,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        ctrl
                                                                .homeCount
                                                                .value
                                                                ?.totalTiresCount
                                                                .toString() ??
                                                            "0",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 26,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
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
                                SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => AllVehicleListView());
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svgImage/vehicle-icon.svg',
                                                width: 34,
                                                height: 34,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Colors.red,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Vehicles',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textWhite,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        ctrl
                                                                .homeCount
                                                                .value
                                                                ?.vehicleCount
                                                                .toString() ??
                                                            "0",
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.textWhite,
                                                          fontSize: 26,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
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

                      SizedBox(height: 14),

                      // Last inspection + Sync button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Inspection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  data?.lastInspection ?? '--',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: ctrl.isLoading.value
                                  ? null
                                  : () => ctrl.syncInspections(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.red),
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: Icon(Icons.sync, color: Colors.red),
                              label: Text(
                                'Sync',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18),

                      // View Inspections boxes
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View Inspections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Unsynced Card
                                GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => const ViewInspectionPage(),
                                      arguments: 0, // Unsynced
                                    );
                                  },
                                  child: inspectionCard(
                                    title: 'Unsynced Inspection',
                                    count: '0',
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Synced Card
                                GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => const ViewInspectionPage(),
                                      arguments: 1, // Synced
                                    );
                                  },
                                  child: inspectionCard(
                                    title: 'Synced Inspection',
                                    count: '0',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // View Inspections boxes
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicles/Tires Inspections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Synced Card
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Vehicle Inspection",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          "32",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(
                                              () => InspectionVehicleTyreView(),
                                            );
                                          },
                                          child: Text(
                                            "view >",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Tire Inspection",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                          "12",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(
                                              () => InspectionVehicleTyreView(),
                                            );
                                          },
                                          child: Text(
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

                      SizedBox(height: 120),
                      // space for bottom button
                    ],
                  ),
                ),
              );
            }),
          ),
          // 🔹 LOADER OVERLAY (TOP)
          Obx(() {
            if (!ctrl.isLoading.value) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  color: Colors.white.withOpacity(0.6), // 👈 background dikhe
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

      // Floating bottom "Start Inspection" + plus button
      bottomNavigationBar: InkWell(
        onTap: () {
          Get.to(() => SearchVehicleTyreView());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // START INSPECTION DESIGN (exact same)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                    topRight: Radius.circular(40), // nukila effect
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

              // PLUS BUTTON (EXACT CIRCLE)
              FloatingActionButton(
                onPressed: () {
                  Get.to(() => SearchVehicleTyreView());
                },
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
          // LEFT CONTENT
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
