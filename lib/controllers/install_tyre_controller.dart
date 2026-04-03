import 'package:emtrack/inspection/vehicle_inspe_controller.dart';
import 'package:emtrack/controllers/search_install_tire_controller.dart';
import 'package:emtrack/models/install_tyre_model.dart';
import 'package:emtrack/services/master_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tyre_model.dart';
import '../services/tyre_service.dart';
import '../utils/local_db.dart';

class InstallTyreController extends GetxController {

  // ════════════════════════════════════
  // DEPENDENCIES
  // ════════════════════════════════════
  final tyreService    = TyreService();
  final picker         = ImagePicker();
  final _masterService = MasterDataService();

  // ════════════════════════════════════
  // STATE
  // ════════════════════════════════════
  final RxBool isSubmitting     = false.obs;
  final RxBool isInitialLoading = false.obs;

  Rx<InstallTireModel> model = InstallTireModel().obs;

  final wearConditionsList   = <String>[].obs;
  final wearConditionsIdList = <int>[].obs;
  final RxInt selectedWearConditionsId = 0.obs;
  final wearConditionsId = TextEditingController();

  final casingConditionList   = <String>[].obs;
  final casingConditionIdList = <int>[].obs;
  final RxInt selectedCasingConditionId = 0.obs;
  final casingConditionsId = TextEditingController();

  final dispositionList   = <String>[].obs;
  final dispositionIdList = <int>[].obs;
  final RxInt installedDispositionId = 0.obs;

  RxList<TyreModel> tyreList = <TyreModel>[].obs;
  RxDouble avgTread          = 0.0.obs;
  final RxString vehicleNumber = ''.obs;

  double safeOriginalTread = 140.0;
  double safeRemoveAt      = 0.0;

  final commentsController        = TextEditingController();
  final previousCommentController = TextEditingController(
      text: 'List Of Previous Comments');

  // ════════════════════════════════════
  // SANITIZERS
  // ════════════════════════════════════
  double _sanitizeTread(double? v, double fallback) {
    if (v == null || v <= 0 || v > 100) return fallback;
    return v;
  }

  double _sanitizePressure(double? v) {
    if (v == null || v <= 0 || v > 500) return 28.0;
    return v;
  }

  double _sanitizeOriginal(double? v) {
    if (v == null || v <= 0 || v > 1000) return 140.0;
    return v;
  }

  double _sanitizeRemoveAt(double? v) {
    if (v == null || v < 0 || v > 100) return 0.0;
    return v;
  }

  // ════════════════════════════════════
  // INIT
  // ════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    commentsController.text = model.value.comments ?? '';

    final args = Get.arguments ?? {};
    print('📦 InstallTyre args => $args');

    final int    vehicleId = args['vehicleId']     ?? 0;
    final String vNumber   = args['vehicleNumber'] ?? '';
    final String wheelPos  = args['wheelPosition'] ?? '';
    final int    tireId    = args['tireId']        ?? 0;
    final String serialNo  = args['serialNo']      ?? '';

    vehicleNumber.value = vNumber;

    model.update((m) {
      m!.vehicleId        = vehicleId;
      m.wheelPosition     = wheelPos;
      m.tireId            = tireId;
      m.tireSerialNo      = serialNo;
      m.currentTreadDepth = 0.0;
    });

    print('🔑 vehicleId=$vehicleId | wheel=$wheelPos | tireId=$tireId');

    loadMasterData();


    if (tireId > 0) {
      _initTyreData(tireId);
    }
  }


  Future<void> _initTyreData(int tireId) async {
    isInitialLoading.value = true;
    try {
      await _loadTyreFromLocal(tireId);
      await _loadTyreFromApi(tireId);
    } finally {
      isInitialLoading.value = false;
      print('✅ Tyre init complete — tyreList.length=${tyreList.length}');
    }
  }

  // ════════════════════════════════════
  // COUNTER ACTIONS
  // ════════════════════════════════════
  void incAir()     => model.update((m) => m!.currentPressure++);
  void decAir()     => model.update((m) {
    if (m!.currentPressure > 0) m.currentPressure--;
  });
  void incOutside() => model.update((m) { m!.outsideTread++; _avg(m); });
  void decOutside() => model.update((m) {
    if (m!.outsideTread > 0) m.outsideTread--;
    _avg(m);
  });
  void incInside()  => model.update((m) { m!.insideTread++; _avg(m); });
  void decInside()  => model.update((m) {
    if (m!.insideTread > 0) m.insideTread--;
    _avg(m);
  });

  void _avg(InstallTireModel m) {
    m.currentTreadDepth = double.parse(
        ((m.outsideTread + m.insideTread) / 2).toStringAsFixed(2));
  }

  // ════════════════════════════════════
  // STEP 1 — LOCAL SQLite se tyre load
  // ════════════════════════════════════
  Future<void> _loadTyreFromLocal(int tireId) async {
    try {
      final db     = await LocalDatabaseService.database;
      final result = await db.query(
        'tires',
        where: 'tireId = ?', whereArgs: [tireId], limit: 1,
      );

      if (result.isNotEmpty) {
        final t  = result.first;
        final o  = _sanitizeTread((t['outsideTread']    as num?)?.toDouble(), 1.0);
        final i  = _sanitizeTread((t['insideTread']     as num?)?.toDouble(), 1.0);
        final p  = _sanitizePressure((t['currentPressure'] as num?)?.toDouble());
        final av = double.parse(((o + i) / 2).toStringAsFixed(2));

        model.update((m) {
          m!.outsideTread     = o;
          m.insideTread       = i;
          m.currentTreadDepth = av;
          m.currentPressure   = p;
          if ((m.tireSerialNo ?? '').isEmpty)
            m.tireSerialNo = t['tireSerialNo'] as String? ?? '';
        });
        print('✅ Local DB loaded: tireId=$tireId | outside=$o | inside=$i | pressure=$p');
      } else {
        print('⚠️ No local data found for tireId=$tireId');
      }
    } catch (e) {
      print('⚠️ Local load failed: $e');
    }
  }


  Future<void> _loadTyreFromApi(int tireId) async {
    if (tireId <= 0) return;
    try {
      final tyres = await tyreService.getTyresById(tireId);
      tyreList..clear()..addAll(tyres);

      if (tyreList.isNotEmpty) {
        final t  = tyreList.first;
        safeOriginalTread = _sanitizeOriginal(t.originalTread);
        safeRemoveAt      = _sanitizeRemoveAt(t.removeAt);

        final o  = _sanitizeTread(t.outsideTread, 1.0);
        final i  = _sanitizeTread(t.insideTread,  1.0);
        final p  = _sanitizePressure(t.currentPressure);
        final av = double.parse(((o + i) / 2).toStringAsFixed(2));
        avgTread.value = av;

        model.update((m) {
          m!.outsideTread     = o;
          m.insideTread       = i;
          m.currentTreadDepth = av;
          m.currentPressure   = p;
          if ((m.tireSerialNo ?? '').isEmpty)
            m.tireSerialNo = t.tireSerialNo ?? '';
        });
        print('✅ API data loaded: serial=${t.tireSerialNo} | outside=$o | inside=$i | pressure=$p');
      } else {
        print('⚠️ API returned empty tyreList for tireId=$tireId');
      }
    } catch (e) {
      print('⚠️ API load failed (using local data): $e');
    }
  }

  // ════════════════════════════════════
  // MASTER DATA
  // ════════════════════════════════════
  Future<void> loadMasterData() async {
    try {
      final data = await _masterService.fetchMasterData();

      wearConditionsList.assignAll(
        (data['wearConditions'] as List)
            .map((e) => e['wearConditionName'].toString().toUpperCase())
            .toSet().toList(),
      );
      wearConditionsIdList.assignAll(
        (data['wearConditions'] as List)
            .map((e) => e['wearConditionId'] as int)
            .toSet().toList(),
      );

      casingConditionList.assignAll(
        (data['casingCondition'] as List)
            .map((e) => e['casingConditionName'].toString().toUpperCase())
            .toSet().toList(),
      );
      casingConditionIdList.assignAll(
        (data['casingCondition'] as List)
            .map((e) => e['casingConditionId'] as int)
            .toSet().toList(),
      );

      if (wearConditionsIdList.isNotEmpty)
        selectedWearConditionsId.value = wearConditionsIdList.first;
      if (casingConditionIdList.isNotEmpty)
        selectedCasingConditionId.value = casingConditionIdList.first;

      dispositionList.assignAll(
        (data['tireDispositions'] as List)
            .map((e) => e['dispositionName'].toString().toUpperCase())
            .toList(),
      );
      dispositionIdList.assignAll(
        (data['tireDispositions'] as List)
            .map((e) => e['dispositionId'] as int)
            .toList(),
      );

      for (var d in data['tireDispositions']) {
        if (d['dispositionName'].toString().toLowerCase() == 'installed') {
          installedDispositionId.value = d['dispositionId'];
          break;
        }
      }

      if (installedDispositionId.value == 0) installedDispositionId.value = 2;

      print('✅ Master data loaded | installedId=${installedDispositionId.value}');
    } catch (e) {
      print('❌ Master data error: $e');
      installedDispositionId.value = 2; // safe fallback
    }
  }

  // ════════════════════════════════════════════════════════════
  // SUBMIT
  // ✅ FIX: tyreList ready hone ke baad diagram mein
  //         real data (tread, pressure, serial) dikhega
  // ════════════════════════════════════════════════════════════
  Future<void> submit() async {
    if (isSubmitting.value) return;

    // ✅ FIX: Loading abhi bhi chal rahi hai — user ko rok do
    if (isInitialLoading.value) {
      Get.snackbar(
        'Please Wait',
        'Tyre data still loading, please wait...',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final m = model.value;

      // ── Validation ──────────────────────────────────────
      if ((m.tireId ?? 0) <= 0) {
        Get.snackbar('Error', 'Please select a tyre from inventory',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if ((m.wheelPosition ?? '').trim().isEmpty) {
        Get.snackbar('Error', 'Wheel position missing',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }


      final tyreData = tyreList.isNotEmpty ? tyreList.first : null;

      final double outside = _sanitizeTread(m.outsideTread, 1.0);
      final double inside  = _sanitizeTread(m.insideTread,  1.0);
      final double middle  = double.parse(
          ((outside + inside) / 2).toStringAsFixed(2));

      final String tireSerialNo = (m.tireSerialNo ?? '').isNotEmpty
          ? m.tireSerialNo!
          : (tyreData?.tireSerialNo ?? '');

      final String wheelPos = m.wheelPosition!.trim().toUpperCase();

      print('🔵 LOCAL install: $wheelPos | serial=$tireSerialNo | outside=$outside | inside=$inside | pressure=${m.currentPressure}');

      // ════════════════════════════════════════════════════
      // STEP 1: SQLite  disposition → INSTALLED
      // ════════════════════════════════════════════════════
      await LocalDatabaseService.updateTireDisposition(
        tireId:          m.tireId!,
        dispositionId:   installedDispositionId.value,
        dispositionName: 'INSTALLED',
        wheelPosition:   wheelPos,
      );
      print('✅ SQLite: tireId=${m.tireId} → INSTALLED @ $wheelPos');

      _updateDiagram(
        m:            m,
        tyreData:     tyreData,
        tireSerialNo: tireSerialNo,
        outside:      outside,
        inside:       inside,
        middle:       middle,
        wheelPos:     wheelPos,
      );


      Get.back();
      Get.back();

      Get.snackbar(
        '✅ Installed',
        '$tireSerialNo → $wheelPos (Locally Saved)',
        backgroundColor: Colors.green,
        colorText:       Colors.white,
        duration:        const Duration(seconds: 3),
        snackPosition:   SnackPosition.TOP,
      );

    } catch (e) {
      print('❌ Install error: $e');
      Get.snackbar('Error', 'Failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }


  void _updateDiagram({
    required InstallTireModel m,
    required TyreModel?       tyreData,
    required String           tireSerialNo,
    required double           outside,
    required double           inside,
    required double           middle,
    required String           wheelPos,
  }) {
    try {
      final vehicleCtrl = Get.find<VehicleInspeController>();

      final localTyre = TyreModel(
        tireId:            m.tireId,
        tireSerialNo:      tireSerialNo,
        wheelPosition:     wheelPos,

        currentTreadDepth: middle,
        outsideTread:      outside,
        insideTread:       inside,
        currentPressure:   _sanitizePressure(m.currentPressure),

        currentHours:      tyreData?.currentHours      ?? 0.0,
        percentageWorn:    tyreData?.percentageWorn     ?? 0.0,
        originalTread:     tyreData?.originalTread      ?? safeOriginalTread,
        sizeName:          tyreData?.sizeName            ?? '',
        typeName:          tyreData?.typeName            ?? '',
        manufacturerName:  tyreData?.manufacturerName   ?? '',

        dispositionId:     installedDispositionId.value,
        casingConditionId: selectedCasingConditionId.value,
        wearConditionId:   selectedWearConditionsId.value,
      );

      vehicleCtrl.addInstalledTyreLocally(localTyre);

      print('✅ Diagram SVG updated: $wheelPos → $tireSerialNo');
      print('   tread=$middle | pressure=${m.currentPressure} | size=${tyreData?.sizeName}');
    } catch (e) {
      print('⚠️ VehicleInspeController not found: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // INVENTORY SE HATAO
  // ════════════════════════════════════════════════════════════
  void _removeFromInventory(int tireId) {
    try {
      final sc = Get.find<SearchInstallTireController>();
      sc.allTyres.removeWhere((t)     => t.tireId == tireId);
      sc.visibleTyres.removeWhere((t) => t.tireId == tireId);
      print('✅ Removed from inventory list: tireId=$tireId');
    } catch (e) {
      print('⚠️ SearchCtrl not found: $e');
    }
  }

  // ════════════════════════════════════
  // DISPOSE
  // ════════════════════════════════════
  @override
  void onClose() {
    commentsController.dispose();
    previousCommentController.dispose();
    wearConditionsId.dispose();
    casingConditionsId.dispose();
    super.onClose();
  }
}