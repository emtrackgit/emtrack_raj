import 'package:emtrack/color/app_color.dart';
import 'package:emtrack/controllers/grand_parent_account_controller/grandparent_account_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GrandparentAccountListView extends StatefulWidget {
  const GrandparentAccountListView({super.key});

  @override
  State<GrandparentAccountListView> createState() =>
      _GrandparentAccountListViewState();
}

class _GrandparentAccountListViewState extends State<GrandparentAccountListView> {
  final c = Get.put(GrandparentAccountListController());
  bool shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shown) return;
      shown = true;
      final args = Get.arguments;
      if (args is Map && (args['showSuccess'] == true)) {
        final raw = args['msg']?.toString() ?? '';
        final msg = raw.trim().isNotEmpty
            ? raw
            : 'Grandparent assigned successfully';
        Get.snackbar(
          "Success",
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          "GRANDPARENT ACCOUNT OPTIONS",
          style: TextStyle(color: Colors.white, fontSize: 17),
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
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Grandparent",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "ID: ${a.id}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: a.isActive ? Colors.green : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            a.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: a.isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        a.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),
                      _row("Owned By", a.ownedBy),
                      _row("Created By", a.createdBy),
                      _row("Create Date", a.createDate),
                      _row("Updated By", a.updatedBy),
                      _row("Update Date", a.updateDate),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text("$label: $value", style: const TextStyle(color: Colors.grey)),
    );
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
