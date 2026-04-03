import 'package:emtrack/models/user_models.dart';
import 'package:emtrack/routes/app_pages.dart';
import 'package:emtrack/user_management/user_management_list_controller.dart';
import 'package:emtrack/utils/app_dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_list_model.dart';

class UserManagementListView extends StatelessWidget {
  final c = Get.put(UserManagementListController());

  UserManagementListView({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("USER MANAGEMENT"), centerTitle: true),
      body: Column(
        children: [
          /// 🔴 CREATE USER BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: w,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppPages.USER_MANAGEMENT_VIEW);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "+ CREATE USER",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: c.search,
              decoration: InputDecoration(
                hintText: "Search User",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 📋 USER LIST
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: c.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = c.filteredUsers[index];

                  return _userCard(user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _userCard(UserlListModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LEFT DATA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   user.userRole.toString(),
                  //   style: const TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 16,
                  //   ),
                  // ),
                  if (user.firstName != null && user.firstName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${user.firstName}   ${user.lastName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  Text(
                    user.userRole.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    "phone: ${user.phoneNumber ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            /// 🗑 DELETE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => AppDialog.showConfirmDialog(
                title: 'Delete User',
                message: 'Are you sure you want to delete this user? ?',
                onOk: () {
                  Get.find<UserManagementListController>().deleteUser(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
