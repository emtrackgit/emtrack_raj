import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/search_tyre_vehicle/search_vehicle_tyre_view.dart';
import 'package:emtrack/user_management/user_management_list_view.dart';
import 'package:emtrack/user_management/user_management_view.dart';
import 'package:emtrack/views/change_account_view.dart';
import 'package:emtrack/views/create_vehicle_view.dart';
import 'package:emtrack/views/grand_parent_account_view/grand_parent_account_view.dart';
import 'package:emtrack/views/grand_parent_account_view/grandparent_account_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';

class HomeDrawer extends StatelessWidget {
  final HomeController hc = Get.find<HomeController>();
  final AuthController auth = Get.find<AuthController>();

  HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = hc.homeData.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CLOSE ICON + LOGO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Image.asset('assets/images/logo.png', width: 120),
              ],
            ),
            const SizedBox(height: 6),

            /// USER INFO
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: hc.imageUrl.isNotEmpty
                      ? NetworkImage(hc.imageUrl)
                      : null,
                  child: hc.imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hc.username.value,
                      style: TextStyle(
                        color: AppColors.drawerHighlight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   data?.role ?? 'EMSUADMIN',
                    //   style: const TextStyle(color: Colors.white, fontSize: 12),
                    // ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// PARENT ACCOUNT
            Text(
              'Parent Account:',
              style: TextStyle(color: AppColors.drawerHighlight),
            ),
            const SizedBox(height: 6),
            Text(
              data?.parentAccount ?? hc.selectedParentAccountName.value,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// LOCATION
            Text(
              'Location:',
              style: TextStyle(color: AppColors.drawerHighlight),
            ),
            const SizedBox(height: 6),
            Text(
              data?.location ?? hc.selectedLocationName.value,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            /// CHANGE ACCOUNT BUTTON
            InkWell(
              onTap: () {
                Get.to(() => ChangeAccountView());
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.buttonDanger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place, color: Colors.white),
                    Text(
                      ' Change Location/ Account',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// ================= MENU AREA =================
            Expanded(
              child: Obx(() {
                /// 🔽 CREATE SUB MENU
                if (hc.isCreateOpen.value) {
                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DrawerItem(
                        '← Main Menu',
                        color: AppColors.drawermenu,
                        onTap: hc.closeCreateMenu,
                      ),
                      DrawerItem(
                        'Vehicle',
                        color: AppColors.textWhite,
                        onTap: () {
                          Get.back();
                          Get.to(() => CreateVehicleView());
                          //hc.closeCreateMenu();
                          // Get.back();
                        },
                      ),

                      DrawerItem(
                        'Tire',
                        color: AppColors.textWhite,
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppPages.CREATE_TYRE);
                        },
                      ),
                    ],
                  );
                }

                /// 🔹 MAIN MENU
                return ListView(
                  children: [
                    DrawerItem(
                      'Home',
                      color: AppColors.textWhite,
                      onTap: () => Get.back(),
                    ),
                    DrawerItem(
                      'Create >',
                      color: AppColors.textWhite,
                      onTap: hc.openCreateMenu,
                    ),
                    DrawerItem(
                      'Start Inspection',
                      color: AppColors.textWhite,
                      onTap: () {
                        Get.back();
                        Get.to(() => SearchVehicleTyreView());
                      },
                    ),
                    DrawerItem(
                      'Preferences',
                      color: AppColors.textWhite,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppPages.PREFERENCE);
                      },
                    ),
                    // DrawerItem(
                    //   'Search,Install',
                    //   color: AppColors.textWhite,
                    //   onTap: () {
                    //     Get.back();
                    //     Get.to(() => SearchInstallView());
                    //   },
                    // ),
                    DrawerItem(
                      'User ',
                      color: AppColors.textWhite,
                      onTap: () {
                        Get.back();
                        Get.to(() => UserManagementView());
                      },
                    ),

                    Obx(() {
                      if (auth.userRole.value == "EMTSUADMIN") {
                        return Column(
                          children: [
                            DrawerItem(
                              'User Management List',
                              color: AppColors.textWhite,
                              onTap: () {
                                Get.back();
                                Get.to(() => UserManagementListView());
                              },
                            ),

                            DrawerItem(
                              'Grandparent Account',
                              color: AppColors.textWhite,
                              onTap: () {
                                Get.back();
                                Get.to(() => GrandparentAccountView());
                              },
                            ),

                            DrawerItem(
                              'Grandparent Account List',
                              color: AppColors.textWhite,
                              onTap: () {
                                Get.back();
                                Get.to(() => GrandparentAccountListView());
                              },
                            ),
                          ],
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),

                    // DrawerItem(
                    //   'User Management List',
                    //   color: AppColors.textWhite,
                    //   onTap: () {
                    //     Get.back();
                    //     Get.to(() => UserManagementListView());
                    //   },
                    // ),
                    // DrawerItem(
                    //   'Grandparent Account',
                    //   color: AppColors.textWhite,
                    //   onTap: () {
                    //     Get.back();
                    //     Get.to(() => GrandparentAccountView());
                    //   },
                    // ),
                    // DrawerItem(
                    //   'Grandparent Account List',
                    //   color: AppColors.textWhite,
                    //   onTap: () {
                    //     Get.back();
                    //     Get.to(() => GrandparentAccountListView());
                    //   },
                    // ),
                    DrawerItem(
                      'Logout',
                      color: AppColors.textWhite,
                      onTap: _showLogoutDialog,
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 12),

            /// APP VERSION
            Text(
              'App Version: ${data?.appVersion ?? '14'}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// FOOTER
            Row(
              children: [
                Image.asset('assets/images/apk_logo.png', width: 40),
                const SizedBox(width: 8),
                const Text(
                  '@2025 The Yokohama Rubber Co., Ltd.',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // ❌ Cancel
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDanger,
            ),
            onPressed: () {
              Get.back(); // close dialog
              auth.logout(); // ✅ logout
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

/// ================= DRAWER ITEM =================
class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const DrawerItem(this.title, {this.color, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: color, fontSize: 18)),
      onTap: onTap,
    );
  }
}
