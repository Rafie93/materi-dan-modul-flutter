# Aplikasi Catatan Flutter - CRUD dengan GetX dan SQLite

Aplikasi catatan sederhana yang dibangun dengan Flutter, menggunakan GetX untuk state management, dan SQLite untuk penyimpanan data lokal. Proyek ini mengimplementasikan arsitektur MVC (Model-View-Controller).

## 📋 Daftar Isi

- [Fitur](#-fitur)
- [Teknologi](#-teknologi)
- [Struktur Folder](#-struktur-folder)
- [Instalasi](#-instalasi)
- [Cara Menjalankan](#-cara-menjalankan)
- [Dokumentasi](#-dokumentasi)
- [Screenshots](#-screenshots)
- [Pembelajaran](#-pembelajaran)

## ✨ Fitur

### Manajemen Catatan (CRUD)
- ✅ **Create** - Tambah catatan baru dengan judul dan isi
- ✅ **Read** - Lihat daftar semua catatan
- ✅ **Update** - Edit catatan yang sudah ada
- ✅ **Delete** - Hapus catatan (swipe atau konfirmasi)

### Fitur Tambahan
- 🔍 **Search** - Cari catatan berdasarkan judul atau isi
- 🌓 **Dark Mode** - Toggle antara light dan dark theme
- 📝 **Font Size Adjustment** - Atur ukuran font sesuai preferensi
- 💾 **Persistent Storage** - Data disimpan lokal menggunakan SQLite
- ⚙️ **Settings** - Pengaturan menggunakan SharedPreferences
- 🔄 **Pull to Refresh** - Refresh data dengan gesture
- 📱 **Responsive UI** - Tampilan yang adaptif

## 🛠 Teknologi

### Framework & Libraries
- **Flutter** - Framework utama untuk membuat aplikasi mobile
- **GetX** (^4.6.6) - State management, dependency injection, dan routing
- **sqflite** (^2.3.0) - Database SQLite untuk Flutter
- **shared_preferences** (^2.2.2) - Penyimpanan key-value untuk pengaturan
- **intl** (^0.18.1) - Internationalization dan formatting tanggal

### Arsitektur
- **MVC (Model-View-Controller)** - Pemisahan concerns yang jelas
- **Reactive Programming** - Menggunakan GetX observable
- **Singleton Pattern** - Untuk database helper

## 📁 Struktur Folder

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   └── note_model.dart       # Model untuk catatan
├── views/                    # UI/Presentation layer
│   ├── home_view.dart        # Halaman utama (list catatan)
│   ├── add_note_view.dart    # Halaman tambah catatan
│   ├── edit_note_view.dart   # Halaman edit catatan
│   └── settings_view.dart    # Halaman pengaturan
├── controllers/              # Business logic layer
│   ├── note_controller.dart  # Controller untuk manajemen catatan
│   └── settings_controller.dart # Controller untuk pengaturan
├── database/                 # Database layer
│   └── database_helper.dart  # Helper untuk operasi SQLite
└── routes/                   # Routing configuration
    └── app_routes.dart       # Definisi routes dan bindings
```

## 🚀 Instalasi

### Prerequisites

Pastikan Anda sudah menginstall:
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Android Studio / VS Code dengan Flutter extension
- Android Emulator atau iOS Simulator

### Langkah Instalasi

1. **Clone atau download project ini**

2. **Navigate ke direktori project**
   ```bash
   cd /workspace
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verifikasi instalasi Flutter**
   ```bash
   flutter doctor
   ```

## 🎯 Cara Menjalankan

### Menjalankan di Emulator/Simulator

1. **Buka emulator/simulator**

2. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Menjalankan di Device Fisik

1. **Enable USB Debugging di device Android**

2. **Connect device via USB**

3. **Verify device terdeteksi**
   ```bash
   flutter devices
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# APK akan tersimpan di: build/app/outputs/flutter-apk/
```

### Build iOS (macOS only)

```bash
flutter build ios --release
```

## 📖 Dokumentasi

### File Dokumentasi Lengkap

Baca dokumentasi lengkap tentang konsep dan implementasi di:
**[MATERI_FLUTTER_DATA_PERSISTENCE.md](MATERI_FLUTTER_DATA_PERSISTENCE.md)**

Dokumentasi mencakup:
1. **Shared Preferences** - Konsep dan implementasi
2. **SQLite Database** - Konsep dan operasi CRUD
3. **GetX State Management** - Reactive programming dengan GetX
4. **MVC Architecture** - Struktur dan best practices
5. **Studi Kasus Lengkap** - Implementasi aplikasi catatan

### Penjelasan Singkat

#### Model (note_model.dart)
```dart
// Representasi data catatan
class Note {
  int? id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  
  // Method untuk konversi data
  Map<String, dynamic> toMap();
  factory Note.fromMap(Map<String, dynamic> map);
}
```

#### Controller (note_controller.dart)
```dart
// Business logic dan state management
class NoteController extends GetxController {
  final RxList<Note> notes = <Note>[].obs;
  
  Future<void> loadNotes();
  Future<bool> addNote(String title, String content);
  Future<bool> updateNote(int id, String title, String content);
  Future<bool> deleteNote(int id);
}
```

#### View (home_view.dart)
```dart
// UI yang reactive terhadap perubahan state
Obx(() => ListView.builder(
  itemCount: noteController.filteredNotes.length,
  itemBuilder: (context, index) {
    return _buildNoteCard(noteController.filteredNotes[index]);
  },
))
```

#### Database (database_helper.dart)
```dart
// Singleton database helper
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  Future<int> insertNote(Note note);
  Future<List<Note>> getAllNotes();
  Future<int> updateNote(Note note);
  Future<int> deleteNote(int id);
}
```

## 📱 Screenshots

### Halaman Utama
- List semua catatan
- Search functionality
- Swipe to delete
- Floating action button untuk tambah

### Halaman Tambah/Edit
- Form input judul dan isi
- Validasi input
- Auto-save saat back jika ada perubahan
- Info timestamp (edit page)

### Halaman Pengaturan
- Toggle dark mode
- Adjust font size dengan slider
- Info aplikasi
- Clear all notes
- Reset settings

## 📚 Pembelajaran

### Konsep yang Dipelajari

1. **Data Persistence**
   - SharedPreferences untuk data sederhana
   - SQLite untuk data kompleks
   - Perbedaan dan use case masing-masing

2. **State Management**
   - Reactive programming dengan GetX
   - Observable variables (.obs)
   - Controller lifecycle
   - Dependency injection

3. **Arsitektur**
   - Separation of concerns (MVC)
   - Single Responsibility Principle
   - Dependency Inversion

4. **CRUD Operations**
   - Create - Insert data ke database
   - Read - Query dan filter data
   - Update - Modify existing data
   - Delete - Remove data

5. **Best Practices**
   - Error handling
   - Input validation
   - User feedback (snackbar, dialog)
   - Loading states
   - Responsive design

### Pengembangan Selanjutnya

Ide untuk meningkatkan aplikasi:

1. **Fitur Tambahan**
   - [ ] Kategori/Tags untuk catatan
   - [ ] Backup & Restore data
   - [ ] Export ke PDF/Text
   - [ ] Reminder/Notification
   - [ ] Image attachment
   - [ ] Voice to text
   - [ ] Share catatan

2. **Peningkatan UI/UX**
   - [ ] Animasi transisi
   - [ ] Custom theme colors
   - [ ] Different font options
   - [ ] Grid/List view toggle
   - [ ] Pin important notes

3. **Security**
   - [ ] Password/PIN protection
   - [ ] Biometric authentication
   - [ ] Encrypt sensitive notes

4. **Cloud Integration**
   - [ ] Firebase sync
   - [ ] Multi-device support
   - [ ] Cloud backup

## 🤝 Kontribusi

Untuk pembelajaran, Anda bisa:
1. Fork project ini
2. Coba implementasikan fitur baru
3. Eksperimen dengan state management lain (Provider, Riverpod, Bloc)
4. Tambahkan testing (unit test, widget test, integration test)

## 📄 Lisensi

Project ini dibuat untuk tujuan pembelajaran.

## 👨‍💻 Kontak & Support

Jika ada pertanyaan atau isu:
1. Baca dokumentasi lengkap di [MATERI_FLUTTER_DATA_PERSISTENCE.md](MATERI_FLUTTER_DATA_PERSISTENCE.md)
2. Check Flutter documentation: https://flutter.dev/docs
3. GetX documentation: https://pub.dev/packages/get

## 🎓 Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [sqflite Package](https://pub.dev/packages/sqflite)
- [shared_preferences Package](https://pub.dev/packages/shared_preferences)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Happy Learning! 🚀**

Made with ❤️ using Flutter
