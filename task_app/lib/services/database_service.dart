import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/models/profile_model.dart';

class DatabaseService {
  // --- SIMULACIÓN DE USUARIO ---
  static const String currentUserId = 'user_alejandro_puga';
  static final Profile currentUserProfile = Profile(
    id: currentUserId,
    fullName: 'Alejandro Puga',
    avatarUrl:
        'lib/assets/images/default_avatar.png', // Ruta del avatar por defecto
    rating: 4.8,
  );
  // --- FIN SIMULACIÓN ---

  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();

  factory DatabaseService() => instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'tasker_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,

      // --- ¡ESTA ES LA MODIFICACIÓN CLAVE! ---
      // onConfigure se llama cada vez que se abre la BD.
      onConfigure: (db) async {
        // Activa la validación de llaves foráneas.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // --- FIN DE LA MODIFICACIÓN ---
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles(
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        avatarUrl TEXT,
        rating REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        reward TEXT,
        location TEXT,
        taskImagePath TEXT, 
        dueDate TEXT NOT NULL,
        posterId TEXT NOT NULL,
        FOREIGN KEY (posterId) REFERENCES profiles (id)
      )
    ''');

    // Inserta el perfil de usuario simulado si no existe
    await db.insert(
      'profiles',
      currentUserProfile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, // No lo inserta si ya existe
    );
  }

  // --- CRUD DE TAREAS (Sin cambios) ---

  Future<int> createTask({
    required String title,
    required String description,
    required String reward,
    required String location,
    required DateTime dueDate,
    required String taskImagePath,
  }) async {
    final db = await database;
    Map<String, dynamic> row = {
      'title': title,
      'description': description,
      'reward': reward,
      'location': location,
      'dueDate': dueDate.toIso8601String(),
      'taskImagePath': taskImagePath,
      'posterId': currentUserId,
    };
    return await db.insert('tasks', row);
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        T.*, 
        P.fullName, 
        P.avatarUrl, 
        P.rating 
      FROM tasks T
      JOIN profiles P ON T.posterId = P.id
      ORDER BY T.dueDate DESC
    ''');

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask({
    required int id,
    required String title,
    required String description,
    required String reward,
    required String location,
    required DateTime dueDate,
    required String taskImagePath,
  }) async {
    final db = await database;
    Map<String, dynamic> row = {
      'title': title,
      'description': description,
      'reward': reward,
      'location': location,
      'dueDate': dueDate.toIso8601String(),
      'taskImagePath': taskImagePath,
      'posterId': currentUserId,
    };
    return await db.update('tasks', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- ¡NUEVO! CRUD DE PERFIL ---

  // READ (Obtener el perfil del usuario actual)
  Future<Profile> getCurrentUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [currentUserId],
    );

    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    } else {
      // Si algo sale mal y no existe, devuelve el de por defecto
      return currentUserProfile;
    }
  }

  // UPDATE (Actualizar el perfil del usuario actual)
  Future<int> updateUserProfile({
    required String fullName,
    required String avatarUrl,
    // (Añade aquí otros campos como email, phone si los implementas)
  }) async {
    final db = await database;
    Map<String, dynamic> row = {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      // No actualizamos el rating ni el ID
    };
    return await db.update(
      'profiles',
      row,
      where: 'id = ?',
      whereArgs: [currentUserId],
    );
  }
}
