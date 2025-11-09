# Materi Pemrograman Mobile Flutter
## Data Persistence dan Aplikasi CRUD

---

## 1. Penyimpanan Data dengan Shared Preferences

### Apa itu Shared Preferences?

Shared Preferences adalah metode penyimpanan data sederhana dalam bentuk key-value pairs. Cocok untuk menyimpan data konfigurasi aplikasi, preferensi pengguna, dan data sederhana lainnya.

### Karakteristik Shared Preferences:
- ✅ Ringan dan cepat
- ✅ Cocok untuk data sederhana (String, int, bool, double, List<String>)
- ✅ Persistent (data tetap ada setelah aplikasi ditutup)
- ❌ Tidak cocok untuk data kompleks atau besar
- ❌ Tidak mendukung query data

### Cara Penggunaan:

```dart
// 1. Install package di pubspec.yaml
// shared_preferences: ^2.2.2

// 2. Import package
import 'package:shared_preferences/shared_preferences.dart';

// 3. Menyimpan data
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('username', 'John Doe');
await prefs.setInt('age', 25);
await prefs.setBool('isDarkMode', true);

// 4. Membaca data
String? username = prefs.getString('username');
int? age = prefs.getInt('age');
bool? isDarkMode = prefs.getBool('isDarkMode');

// 5. Menghapus data
await prefs.remove('username');
await prefs.clear(); // Menghapus semua data
```

### Use Case Shared Preferences:
- Pengaturan tema aplikasi (dark/light mode)
- Bahasa aplikasi
- Token autentikasi
- Status onboarding (sudah ditampilkan atau belum)
- Preferensi tampilan

---

## 2. Penggunaan Database Lokal dengan SQLite

### Apa itu SQLite?

SQLite adalah database relasional yang ringan dan tidak memerlukan server terpisah. Database disimpan dalam satu file lokal di device.

### Karakteristik SQLite:
- ✅ Mendukung query SQL standar
- ✅ Cocok untuk data terstruktur dan kompleks
- ✅ Mendukung relasi antar tabel
- ✅ Performa tinggi untuk data besar
- ✅ Mendukung transaksi (ACID)
- ❌ Lebih kompleks dibanding Shared Preferences

### Package untuk SQLite di Flutter:

Kita akan menggunakan **sqflite** - package resmi untuk SQLite di Flutter.

```dart
// Install di pubspec.yaml
// sqflite: ^2.3.0
// path: ^1.8.3
```

### Operasi Dasar SQLite:

#### 1. Membuat Database

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
  
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
```

#### 2. Operasi CRUD (Create, Read, Update, Delete)

##### CREATE - Menambah Data

```dart
Future<int> insertNote(Map<String, dynamic> note) async {
  Database db = await database;
  return await db.insert('notes', note);
}
```

##### READ - Membaca Data

```dart
// Membaca semua data
Future<List<Map<String, dynamic>>> getAllNotes() async {
  Database db = await database;
  return await db.query('notes', orderBy: 'createdAt DESC');
}

// Membaca data berdasarkan ID
Future<Map<String, dynamic>?> getNoteById(int id) async {
  Database db = await database;
  List<Map<String, dynamic>> results = await db.query(
    'notes',
    where: 'id = ?',
    whereArgs: [id],
  );
  return results.isNotEmpty ? results.first : null;
}
```

##### UPDATE - Mengubah Data

```dart
Future<int> updateNote(int id, Map<String, dynamic> note) async {
  Database db = await database;
  return await db.update(
    'notes',
    note,
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

##### DELETE - Menghapus Data

```dart
Future<int> deleteNote(int id) async {
  Database db = await database;
  return await db.delete(
    'notes',
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

### Perbandingan Shared Preferences vs SQLite:

| Aspek | Shared Preferences | SQLite |
|-------|-------------------|---------|
| **Kompleksitas** | Sederhana | Lebih kompleks |
| **Tipe Data** | Primitif (String, int, bool) | Semua tipe, terstruktur |
| **Query** | Tidak mendukung | SQL penuh |
| **Performa (data besar)** | Lambat | Cepat |
| **Relasi Data** | Tidak mendukung | Mendukung |
| **Use Case** | Preferensi, settings | Data aplikasi utama |

---

## 3. Studi Kasus: Aplikasi Catatan Sederhana (CRUD)

### Arsitektur Aplikasi

Kita akan menggunakan **MVC (Model-View-Controller)** dengan **GetX** untuk state management.

```
lib/
├── main.dart
├── routes/
│   └── app_routes.dart
├── models/
│   └── note_model.dart
├── controllers/
│   ├── note_controller.dart
│   └── settings_controller.dart
├── views/
│   ├── home_view.dart
│   ├── add_note_view.dart
│   ├── edit_note_view.dart
│   └── settings_view.dart
└── database/
    └── database_helper.dart
```

### Penjelasan Arsitektur:

#### **Model** (Data Layer)
- Merepresentasikan struktur data
- Berisi logika untuk konversi data (toMap, fromMap, toJson)
- Tidak memiliki logika bisnis

#### **View** (Presentation Layer)
- UI/tampilan aplikasi
- Menampilkan data dari Controller
- Mengirim user input ke Controller
- Tidak memiliki logika bisnis

#### **Controller** (Business Logic Layer)
- Mengelola state aplikasi
- Mengatur komunikasi antara Model dan View
- Berisi logika bisnis
- Memanggil database operations

#### **Database Helper**
- Mengelola koneksi database
- Menyediakan method untuk operasi CRUD
- Singleton pattern untuk efisiensi

#### **Routes**
- Mengatur navigasi antar halaman
- Menggunakan GetX routing

---

## Fitur Aplikasi Catatan:

### 1. **Home Screen**
- Menampilkan daftar catatan
- Fitur search/filter
- Navigasi ke halaman tambah catatan
- Tap untuk edit catatan
- Swipe atau long press untuk hapus

### 2. **Add Note Screen**
- Form input judul dan isi catatan
- Validasi input
- Simpan ke database

### 3. **Edit Note Screen**
- Load data catatan yang dipilih
- Form edit judul dan isi
- Update database

### 4. **Settings Screen**
- Toggle dark/light mode (Shared Preferences)
- Pilihan font size (Shared Preferences)
- Clear all notes

---

## State Management dengan GetX

### Mengapa GetX?

1. **Reactive Programming** - Otomatis update UI ketika data berubah
2. **Dependency Management** - Mudah inject dependencies
3. **Route Management** - Navigasi tanpa context
4. **Performance** - Ringan dan cepat
5. **Simple Syntax** - Mudah dipelajari

### Konsep Dasar GetX:

#### 1. Reactive State (.obs)

```dart
// Membuat observable variable
var count = 0.obs;

// Mengubah value
count.value = 5;

// Di UI, otomatis update ketika value berubah
Obx(() => Text('${count.value}'))
```

#### 2. GetX Controller

```dart
class CounterController extends GetxController {
  var count = 0.obs;
  
  void increment() {
    count.value++;
  }
  
  @override
  void onInit() {
    super.onInit();
    // Dipanggil saat controller pertama kali dibuat
  }
  
  @override
  void onClose() {
    super.onClose();
    // Cleanup saat controller dihapus
  }
}
```

#### 3. Dependency Injection

```dart
// Register controller
Get.put(CounterController());

// Atau lazy load
Get.lazyPut(() => CounterController());

// Menggunakan controller di view
final controller = Get.find<CounterController>();
```

#### 4. Navigation

```dart
// Pindah halaman
Get.to(() => NextPage());

// Pindah dan hapus halaman sebelumnya
Get.off(() => NextPage());

// Pindah dengan named route
Get.toNamed('/next');

// Kembali
Get.back();

// Kirim data
Get.to(() => NextPage(), arguments: {'id': 1});

// Terima data
var data = Get.arguments;
```

---

## Best Practices

### 1. Database
- ✅ Gunakan transactions untuk multiple operations
- ✅ Buat index untuk kolom yang sering di-query
- ✅ Handle error dengan try-catch
- ✅ Close database connection yang tidak digunakan
- ✅ Gunakan prepared statements (sudah otomatis di sqflite)

### 2. Shared Preferences
- ✅ Jangan simpan data sensitif tanpa enkripsi
- ✅ Gunakan untuk data kecil saja
- ✅ Buat class wrapper untuk type safety
- ✅ Handle null values dengan proper default

### 3. GetX State Management
- ✅ Satu controller untuk satu fitur/screen
- ✅ Dispose/cleanup di onClose()
- ✅ Gunakan workers untuk reaktif terhadap perubahan
- ✅ Pisahkan business logic dari UI

### 4. MVC Architecture
- ✅ Model hanya data structure
- ✅ View hanya UI, tidak ada logic
- ✅ Controller handle semua business logic
- ✅ Gunakan dependency injection

---

## Testing Tips

### 1. Test Database Operations
```dart
test('Insert note should return id', () async {
  final helper = DatabaseHelper();
  final id = await helper.insertNote({
    'title': 'Test',
    'content': 'Test content',
    'createdAt': DateTime.now().toIso8601String(),
  });
  expect(id, greaterThan(0));
});
```

### 2. Test Controller Logic
```dart
test('Add note should increase notes list', () {
  final controller = NoteController();
  final initialCount = controller.notes.length;
  controller.addNote('Title', 'Content');
  expect(controller.notes.length, initialCount + 1);
});
```

---

## Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Shared Preferences Package](https://pub.dev/packages/shared_preferences)
- [sqflite Package](https://pub.dev/packages/sqflite)

---

## Kesimpulan

Dalam materi ini, kita telah mempelajari:

1. ✅ **Shared Preferences** - untuk data konfigurasi sederhana
2. ✅ **SQLite Database** - untuk data terstruktur dan kompleks
3. ✅ **CRUD Operations** - Create, Read, Update, Delete
4. ✅ **GetX State Management** - untuk reactive programming
5. ✅ **MVC Architecture** - untuk kode yang terorganisir dan maintainable

Dengan menggabungkan semua konsep ini, kita bisa membuat aplikasi Flutter yang powerful dengan data persistence yang baik!

---

**Happy Coding! 🚀**
