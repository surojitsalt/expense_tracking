import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('antigravity_expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE income_records (
        id $idType,
        amount $realType,
        category $textType,
        description $textTypeNullable,
        date $textType,
        created_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_records (
        id $idType,
        amount $realType,
        category $textType,
        description $textTypeNullable,
        date $textType,
        created_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_records (
        id $idType,
        amount $realType,
        category $textType,
        description $textTypeNullable,
        date $textType,
        created_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_withdrawals (
        id $idType,
        amount $realType,
        description $textTypeNullable,
        date $textType,
        created_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_categories (
        id $idType,
        name $textType,
        type $textType,
        UNIQUE(name, type)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_withdrawals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // Generic CRUD wrapper methods
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table, orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await instance.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> queryByDateRange(
      String table, String start, String end) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: 'date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
  }

  Future<int> update(String table, int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCustomCategories(String type) async {
    final db = await instance.database;
    return await db.query(
      'custom_categories',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<int> addCustomCategory(String name, String type) async {
    final db = await instance.database;
    try {
      return await db.insert(
        'custom_categories',
        {'name': name, 'type': type},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (_) {
      return -1; // Duplicate or error
    }
  }
}
