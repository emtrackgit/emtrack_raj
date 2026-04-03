import 'package:emtrack/controllers/selected_account_controller.dart';
import 'package:emtrack/models/tyre_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tyre_view_controller.dart';

class TyreView extends StatelessWidget {
  TyreView({super.key});

  final controller = Get.put(TyreViewController());
  final selectController = Get.put(SelectedAccountController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("View tire", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final tyre = controller.tyre.value;
        if (tyre == null) {
          return const Center(child: Text("No data available"));
        }

        return Column(
          children: [
            _header(tyre),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _identificationTab(tyre),
                  _descriptionTab(tyre),
                  _treadDepthTab(tyre),
                  _costsTab(tyre),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _header(TyreViewModel tyre) {
    return FutureBuilder<String>(
      future: controller.getParentAccountName(),
      builder: (context, snapshot) {
        final parentName = snapshot.data ?? "Loading...";
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selected parent account and Location"),
              const SizedBox(height: 4),
              Text(
                "${selectController.parentAccountName.value} - ${selectController.locationName.value}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 4),
              const Text("Vehicle Id:"),
              const SizedBox(height: 4),
              Text(
                tyre.vehicleNumber.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _tabBar() {
    return TabBar(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      tabAlignment: TabAlignment.start,
      controller: controller.tabController,
      isScrollable: true,
      indicator: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(2),
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      tabs: const [
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text("Identification"),
          ),
        ),
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text("Description"),
          ),
        ),
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text("Tread Depth(/32)"),
          ),
        ),
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text("Costs"),
          ),
        ),
      ],
    );
  }

  Widget _row(String title, String value, {String? subvalue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subvalue != null)
                Text(
                  "$subvalue % Worn",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _identificationTab(TyreViewModel tyre) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row("Tire Serial Number", tyre.tireSerialNo.toString()),
        _row("Enter Brand Number", tyre.brandNo.toString()),
        _row("Registered Date", tyre.registeredDate.toString()),
        _row("Evaluation Number", tyre.evaluationNo.toString()),
        _row("Purchase Order Number", tyre.purchaseCost.toString()),
        _row("Lot Number", tyre.lotNo.toString()),
        _row("Disposition", controller.getDispositionName(tyre.dispositionId)),
        _row("Status", controller.getTireStatusName(tyre.tireStatusId)),
        _row("Tracking Method", controller.getTrackingMethod(tyre.mileageType)),
      ],
    );
  }

  Widget _descriptionTab(TyreViewModel tyre) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row(
          "Manufacturer",
          controller.getManufacturerName(tyre.manufacturerId ?? 0),
        ),
        _row("Tyre Size", controller.getTireSizeName(tyre.sizeId ?? 0)),
        _row("Type", controller.getTypeName(tyre.typeId ?? 0)),
        _row(
          "Star Rating",
          controller.getStarRatingName(tyre.starRatingId ?? 0),
        ),
        _row("Ind. Code", controller.getIndCodeName(tyre.indCodeId ?? 0)),
        _row("Compound", controller.getCompoundName(tyre.compoundId ?? 0)),
        _row(
          "Load Rating",
          controller.getLoadRatingName(tyre.loadRatingId ?? 0),
        ),
      ],
    );
  }

  Widget _treadDepthTab(TyreViewModel tyre) {
    int usd1 =
        ((1 -
                    (tyre.outsideTread! - tyre.removeAt!) /
                        (tyre.originalTread! - tyre.removeAt!)) *
                100)
            .round();

    int usd2 =
        ((1 -
                    (tyre.insideTread! - tyre.removeAt!) /
                        (tyre.originalTread! - tyre.removeAt!)) *
                100)
            .round();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row("Original Tread", tyre.originalTread.toString()),
        _row("Remove At", tyre.removeAt.toString()),
        _row("Purchase Tread", tyre.purchasedTread.toString()),
        _row(
          "Outside(a)",
          tyre.outsideTread.toString(),
          subvalue: usd1.toString(),
        ),
        _row(
          "Inside(c)",
          tyre.insideTread.toString(),
          subvalue: usd2.toString(),
        ),
      ],
    );
  }

  Widget _costsTab(TyreViewModel tyre) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row("Purchase Cost", tyre.purchaseCost.toString()),
        _row("Casing Value", tyre.casingValue.toString()),
        _row("Fill Type", controller.getFillTypeName(tyre.fillTypeId ?? 0)),
        // _row("Fill Type", tyre.fillTypeId.toString()),
        _row("Fill Cost", tyre.fillCost.toString()),
        _row("Number Of Repairs", tyre.repairCount.toString()),
        _row("Repair Cost", tyre.repairCost.toString()),
        _row("Number of Retreads", tyre.retreadCount.toString()),
        _row("Retread Cost", tyre.retreadCost.toString()),
        _row("Warranty Adjustment", tyre.warrantyAdjustment.toString()),
        _row("Cost Adjustment", tyre.costAdjustment.toString()),
        _row("Sold Amount", tyre.soldAmount.toString()),
        _row("Net Cost", tyre.netCost.toString()),
      ],
    );
  }
}
