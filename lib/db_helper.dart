import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'profit_loss_tracker.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE raw_materials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          cost REAL
        )
        ''');
        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          raw_material_id INTEGER,
          count INTEGER,
          selling_price REAL,
          created_at TEXT,
          FOREIGN KEY (raw_material_id) REFERENCES raw_materials(id)
        )
        ''');
        await db.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          buyer TEXT,
          amount REAL,
          is_paid INTEGER,
          sold_at TEXT,
          FOREIGN KEY (product_id) REFERENCES products(id)
        )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db!.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db!.query(table);
  }
}
