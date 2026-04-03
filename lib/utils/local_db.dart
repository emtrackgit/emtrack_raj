import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static Database? _db;
  static const int _dbVersion = 2;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'emtrack.db');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSchema(db);
        }
      },
    );
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tires (
        tireId        INTEGER PRIMARY KEY,
        tireSerialNo  TEXT,
        sizeName      TEXT,
        typeName      TEXT,
        manufacturerName TEXT,
        dispositionId INTEGER,
        dispositionName  TEXT,
        vehicleNumber TEXT,
        wheelPosition TEXT,
        currentTreadDepth REAL,
        outsideTread  REAL,
        insideTread   REAL,
        currentPressure REAL,
        currentHours  REAL,
        currentMiles  REAL,
        originalTread REAL,
        removeAt      REAL,
        locationId    INTEGER,
        parentAccountId INTEGER,
        tireStatusName TEXT,
        percentageWorn REAL,
        updatedAt     TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_installs (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        payload       TEXT NOT NULL,
        tireId        INTEGER,
        vehicleId     INTEGER,
        wheelPosition TEXT,
        tireSerialNo  TEXT,
        createdAt     TEXT NOT NULL,
        syncStatus    TEXT DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS kv_cache (
        cacheKey  TEXT PRIMARY KEY,
        jsonValue TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_requests (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        method          TEXT NOT NULL,
        endpoint        TEXT NOT NULL,
        payload         TEXT NOT NULL,
        entityType      TEXT,
        localEntityId   INTEGER,
        clientRequestId TEXT,
        createdAt       TEXT NOT NULL,
        syncStatus      TEXT DEFAULT 'pending',
        attemptCount    INTEGER DEFAULT 0,
        lastError       TEXT
      )
    ''');
  }

  static Future<void> saveJsonCache(String cacheKey, dynamic value) async {
    final db = await database;
    await db.insert(
      'kv_cache',
      {
        'cacheKey':  cacheKey,
        'jsonValue': jsonEncode(value),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("✅ LocalDB: cache saved key=$cacheKey");
  }

  static Future<dynamic> getJsonCache(String cacheKey) async {
    final db = await database;
    final rows = await db.query(
      'kv_cache',
      where: 'cacheKey = ?',
      whereArgs: [cacheKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['jsonValue'] as String?;
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw);
  }

  static Future<int> enqueueRequest({
    required String method,
    required String endpoint,
    required dynamic payload,
    String? entityType,
    int? localEntityId,
    String? clientRequestId,
  }) async {
    final db = await database;
    if (clientRequestId != null && clientRequestId.isNotEmpty) {
      final existing = await db.query(
        'pending_requests',
        columns: ['id'],
        where: 'clientRequestId = ? AND syncStatus = ?',
        whereArgs: [clientRequestId, 'pending'],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final id = existing.first['id'] as int;
        print("✅ LocalDB: request already queued id=$id");
        return id;
      }
    }
    final id = await db.insert(
      'pending_requests',
      {
        'method':          method.toUpperCase(),
        'endpoint':        endpoint,
        'payload':         jsonEncode(payload),
        'entityType':      entityType,
        'localEntityId':   localEntityId,
        'clientRequestId': clientRequestId,
        'createdAt':       DateTime.now().toIso8601String(),
        'syncStatus':      'pending',
        'attemptCount':    0,
        'lastError':       null,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    print("✅ LocalDB: queued request id=$id $method $endpoint");
    return id;
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests({
    String syncStatus = 'pending',
    String? entityType,
  }) async {
    final db = await database;
    return await db.query(
      'pending_requests',
      where: entityType == null ? 'syncStatus = ?' : 'syncStatus = ? AND entityType = ?',
      whereArgs: entityType == null ? [syncStatus] : [syncStatus, entityType],
      orderBy: 'createdAt ASC',
    );
  }

  static Future<int> getPendingRequestsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM pending_requests WHERE syncStatus = 'pending'",
    );
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<void> markRequestSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_requests',
      {'syncStatus': 'synced', 'lastError': null},
      where: 'id = ?',
      whereArgs: [id],
    );
    print("✅ LocalDB: pending_request id=$id marked synced");
  }

  static Future<void> markRequestFailed(int id, String error) async {
    final db = await database;
    final current = await db.rawQuery(
      'SELECT attemptCount FROM pending_requests WHERE id = ?',
      [id],
    );
    final attempt = (current.isNotEmpty ? current.first['attemptCount'] as int? : null) ?? 0;
    await db.update(
      'pending_requests',
      {
        'syncStatus':   'pending',
        'attemptCount': attempt + 1,
        'lastError': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    print("❌ LocalDB: pending_request id=$id failed: $error");
  }



  static Future<void> saveTires(List<Map<String, dynamic>> tires) async {
    final db = await database;
    final batch = db.batch();

    for (final t in tires) {
      batch.insert(
        'tires',
        {
          'tireId':           t['tireId'],
          'tireSerialNo':     t['tireSerialNo'],
          'sizeName':         t['sizeName'],
          'typeName':         t['typeName'],
          'manufacturerName': t['manufacturerName'],
          'dispositionId':    t['dispositionId'],
          'dispositionName':  t['dispositionName'],
          'vehicleNumber':    t['vehicleNumber'],
          'wheelPosition':    t['wheelPosition'],
          'currentTreadDepth': t['currentTreadDepth'],
          'outsideTread':     t['outsideTread'],
          'insideTread':      t['insideTread'],
          'currentPressure':  t['currentPressure'],
          'currentHours':     t['currentHours'],
          'currentMiles':     t['currentMiles'],
          'originalTread':    t['originalTread'],
          'removeAt':         t['removeAt'],
          'locationId':       t['locationId'],
          'parentAccountId':  t['parentAccountId'],
          'tireStatusName':   t['tireStatusName'],
          'percentageWorn':   t['percentageWorn'],
          'updatedAt':        DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print("✅ LocalDB: ${tires.length} tires saved");
  }

  static Future<List<Map<String, dynamic>>> getInventoryTires({
    int? parentAccountId,
    int? locationId,
  }) async {
    final db = await database;

    String where = "(dispositionId = 8 OR LOWER(dispositionName) = 'inventory')";
    List<dynamic> args = [];

    if (parentAccountId != null) {
      where += " AND parentAccountId = ?";
      args.add(parentAccountId);
    }

    if (locationId != null) {
      where += " AND locationId = ?";
      args.add(locationId);
    }

    final result = await db.query(
      'tires',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'tireSerialNo ASC',
    );

    print("✅ LocalDB Inventory Tires: ${result.length}");
    return result;
  }

  static Future<List<Map<String, dynamic>>> searchInventoryTires({
    required String query,
    int? parentAccountId,
    int? locationId,
  }) async {
    final db = await database;
    final q = '%${query.toLowerCase()}%';

    String where = "(dispositionId = 8 OR LOWER(dispositionName) = 'inventory')"
        " AND (LOWER(tireSerialNo) LIKE ? OR LOWER(sizeName) LIKE ?"
        " OR LOWER(manufacturerName) LIKE ? OR LOWER(vehicleNumber) LIKE ?)";
    List<dynamic> args = [q, q, q, q];

    if (parentAccountId != null) {
      where += " AND parentAccountId = ?";
      args.add(parentAccountId);
    }

    if (locationId != null) {
      where += " AND locationId = ?";
      args.add(locationId);
    }

    final result = await db.query(
      'tires',
      where: where,
      whereArgs: args,
      orderBy: 'tireSerialNo ASC',
    );

    print("🔎 LocalDB Search '$query': ${result.length} results");
    return result;
  }

  static Future<Map<String, dynamic>?> getTireById(int tireId) async {
    final db = await database;
    final rows = await db.query(
      'tires',
      where: 'tireId = ?',
      whereArgs: [tireId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Ek tire ka disposition update karo locally (install ke baad)
  static Future<void> updateTireDisposition({
    required int tireId,
    required int dispositionId,
    required String dispositionName,
    String? wheelPosition,
    int? vehicleId,
  }) async {
    final db = await database;
    final updateData = <String, dynamic>{
      'dispositionId':   dispositionId,
      'dispositionName': dispositionName,
      'updatedAt':       DateTime.now().toIso8601String(),
    };
    if (wheelPosition != null) updateData['wheelPosition'] = wheelPosition;

    await db.update(
      'tires',
      updateData,
      where: 'tireId = ?',
      whereArgs: [tireId],
    );
    print("✅ LocalDB: tireId=$tireId disposition updated to $dispositionName");
  }

  static Future<void> updateTireMetrics({
    required int tireId,
    double? currentPressure,
    double? outsideTread,
    double? insideTread,
    double? currentTreadDepth,
  }) async {
    final db = await database;
    final updateData = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (currentPressure != null) updateData['currentPressure'] = currentPressure;
    if (outsideTread != null) updateData['outsideTread'] = outsideTread;
    if (insideTread != null) updateData['insideTread'] = insideTread;
    if (currentTreadDepth != null) updateData['currentTreadDepth'] = currentTreadDepth;

    await db.update(
      'tires',
      updateData,
      where: 'tireId = ?',
      whereArgs: [tireId],
    );
    print("✅ LocalDB: tireId=$tireId metrics updated");
  }

  static Future<void> replaceTireId({
    required int oldTireId,
    required int newTireId,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE tires SET tireId = ? WHERE tireId = ?',
        [newTireId, oldTireId],
      );
      await txn.rawUpdate(
        'UPDATE pending_installs SET tireId = ? WHERE tireId = ?',
        [newTireId, oldTireId],
      );
      await txn.rawUpdate(
        'UPDATE pending_requests SET localEntityId = ? WHERE localEntityId = ?',
        [newTireId, oldTireId],
      );
    });
    print("✅ LocalDB: tireId replaced $oldTireId -> $newTireId");
  }

  // ══════════════════════════════════════════════
  // 🟡 PENDING INSTALLS — Offline Queue
  // ══════════════════════════════════════════════

  static Future<void> addPendingInstall(Map<String, dynamic> payload) async {
    final db = await database;
    await db.insert('pending_installs', {
      'payload':       jsonEncode(payload),
      'tireId':       payload['tireId'],
      'vehicleId':    payload['vehicleId'],
      'wheelPosition': payload['wheelPosition'],
      'tireSerialNo': payload['tireSerialNo'],
      'createdAt':    DateTime.now().toIso8601String(),
      'syncStatus':   'pending',
    });
    print("✅ LocalDB: Pending install added for tire ${payload['tireId']}");
  }

  static Future<List<Map<String, dynamic>>> getPendingInstalls() async {
    final db = await database;
    return await db.query(
      'pending_installs',
      where: "syncStatus = 'pending'",
      orderBy: 'createdAt ASC',
    );
  }

  static Future<void> markInstallSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_installs',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
    print("✅ LocalDB: pending_install id=$id marked synced");
  }

  static Future<int> getPendingInstallsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM pending_installs WHERE syncStatus = 'pending'",
    );
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
