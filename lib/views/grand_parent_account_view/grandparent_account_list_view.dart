import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/grand_parent_account_controller/grandparent_account_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GrandparentAccountListView extends StatelessWidget {
  final c = Get.put(GrandparentAccountListController());

  GrandparentAccountListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          "GRANDPARENT ACCOUNT LIST",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(child: _list()),
          _pagination(),
        ],
      ),
    );
  }

  /// 🔍 Search
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Grandparent Account",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        onChanged: c.onSearch,
      ),
    );
  }

  /// 📋 List
  Widget _list() {
    return Obx(() {
      return Stack(
        children: [
          if (c.loading.value) const Center(child: CircularProgressIndicator()),
          if (!c.loading.value && c.accounts.isEmpty)
            const Center(child: Text("No accounts found")),

          ListView.builder(
            itemCount: c.accounts.length,
            itemBuilder: (context, index) {
              final a = c.accounts[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "1 Location", // API doesn't provide this yet, using placeholder as per requirement
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: a.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              a.isActive ? "ACTIVE" : "INACTIVE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: a.isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Created By: ${a.createdBy.isEmpty ? 'N/A' : a.createdBy}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  /// ⬅️ Pagination
  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: c.prevPage,
          ),
          Obx(() {
            final start = (c.currentPage.value - 1) * c.pageSize + 1;
            final end = start + c.accounts.length - 1;

            return Text(
              c.totalRecords.value == 0
                  ? "0 - 0"
                  : "$start - $end of ${c.totalRecords.value}",
            );
          }),

          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: c.nextPage,
          ),
        ],
      ),
    );
  }
}
