import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT,
            password TEXT,
            role TEXT,
            subject TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN subject TEXT');
        }
      },
    );
  }

  Future<void> registerUser(User user) async {
    final db = await database;
    await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'password': user.password,
      'role': user.role,
      'subject': user.subject,
    });
  }

  Future<User?> loginUser(String name, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'],
        name: maps[0]['name'],
        password: maps[0]['password'],
        role: maps[0]['role'],
        subject: maps[0]['subject'],
      );
    }
    return null;
  }
}
