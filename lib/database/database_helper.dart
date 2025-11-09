import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

/// DatabaseHelper - Singleton class untuk mengelola database SQLite
/// 
/// Class ini menggunakan pattern Singleton untuk memastikan hanya ada
/// satu instance database yang digunakan di seluruh aplikasi
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Nama database dan tabel
  static const String _databaseName = 'notes_app.db';
  static const int _databaseVersion = 1;
  static const String tableNotes = 'notes';

  // Kolom tabel notes
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';

  /// Getter untuk database instance
  /// Jika database belum dibuat, akan memanggil _initDatabase()
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inisialisasi database
  /// Membuat database baru jika belum ada
  Future<Database> _initDatabase() async {
    // Mendapatkan path untuk database
    String path = join(await getDatabasesPath(), _databaseName);

    // Membuka database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Callback yang dipanggil saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    // Membuat tabel notes
    await db.execute('''
      CREATE TABLE $tableNotes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');

    print('Database created successfully');
  }

  /// Callback yang dipanggil saat database di-upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementasi upgrade database jika diperlukan
    // Contoh: menambah kolom baru, mengubah struktur tabel, dll
    if (oldVersion < newVersion) {
      // Tambahkan logic upgrade di sini
      print('Database upgraded from version $oldVersion to $newVersion');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// CREATE - Menambah catatan baru
  /// 
  /// @param note - Note object yang akan disimpan
  /// @return id dari catatan yang baru ditambahkan
  Future<int> insertNote(Note note) async {
    try {
      Database db = await database;
      int id = await db.insert(
        tableNotes,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Note inserted with id: $id');
      return id;
    } catch (e) {
      print('Error inserting note: $e');
      rethrow;
    }
  }

  /// READ - Mengambil semua catatan
  /// 
  /// @param orderBy - Kolom untuk sorting (default: createdAt DESC)
  /// @return List of Note objects
  Future<List<Note>> getAllNotes({String orderBy = '$columnCreatedAt DESC'}) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        orderBy: orderBy,
      );

      return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all notes: $e');
      return [];
    }
  }

  /// READ - Mengambil catatan berdasarkan ID
  /// 
  /// @param id - ID catatan yang akan diambil
  /// @return Note object atau null jika tidak ditemukan
  Future<Note?> getNoteById(int id) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return Note.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting note by id: $e');
      return null;
    }
  }

  /// READ - Mencari catatan berdasarkan keyword
  /// 
  /// @param keyword - Kata kunci untuk pencarian
  /// @return List of Note objects yang cocok dengan keyword
  Future<List<Note>> searchNotes(String keyword) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        where: '$columnTitle LIKE ? OR $columnContent LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: '$columnCreatedAt DESC',
      );

      return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
    } catch (e) {
      print('Error searching notes: $e');
      return [];
    }
  }

  /// UPDATE - Mengubah catatan
  /// 
  /// @param note - Note object dengan data yang sudah diupdate
  /// @return jumlah row yang ter-update
  Future<int> updateNote(Note note) async {
    try {
      Database db = await database;
      int count = await db.update(
        tableNotes,
        note.toMap(),
        where: '$columnId = ?',
        whereArgs: [note.id],
      );
      print('Note updated: $count row(s)');
      return count;
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  /// DELETE - Menghapus catatan berdasarkan ID
  /// 
  /// @param id - ID catatan yang akan dihapus
  /// @return jumlah row yang terhapus
  Future<int> deleteNote(int id) async {
    try {
      Database db = await database;
      int count = await db.delete(
        tableNotes,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      print('Note deleted: $count row(s)');
      return count;
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  /// DELETE - Menghapus semua catatan
  /// 
  /// @return jumlah row yang terhapus
  Future<int> deleteAllNotes() async {
    try {
      Database db = await database;
      int count = await db.delete(tableNotes);
      print('All notes deleted: $count row(s)');
      return count;
    } catch (e) {
      print('Error deleting all notes: $e');
      rethrow;
    }
  }

  /// Mendapatkan jumlah total catatan
  /// 
  /// @return jumlah catatan dalam database
  Future<int> getNotesCount() async {
    try {
      Database db = await database;
      var result = await db.rawQuery('SELECT COUNT(*) FROM $tableNotes');
      int? count = Sqflite.firstIntValue(result);
      return count ?? 0;
    } catch (e) {
      print('Error getting notes count: $e');
      return 0;
    }
  }

  /// Menutup koneksi database
  Future<void> close() async {
    Database db = await database;
    await db.close();
    _database = null;
    print('Database closed');
  }
}
