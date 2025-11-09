# 🚀 Panduan Instalasi dan Setup

## Prasyarat

Pastikan Anda sudah menginstall:
- ✅ Flutter SDK (versi 3.0.0 atau lebih baru)
- ✅ Dart SDK
- ✅ IDE (VS Code, Android Studio, atau IntelliJ)
- ✅ Android Emulator atau iOS Simulator (atau device fisik)

---

## 📦 Langkah-langkah Instalasi

### 1. Clone atau Download Project

```bash
# Jika menggunakan Git
git clone <repository-url>
cd news_app_getx

# Atau download dan extract ZIP
```

### 2. Cek Struktur Folder

Pastikan struktur folder sesuai dengan arsitektur MVC:

```
lib/
├── main.dart
├── controllers/      # Business logic
├── models/          # Data structures
├── views/           # User interface
├── services/        # API/Network layer
├── routes/          # Navigation
└── utils/           # Helper classes
```

### 3. Install Dependencies

Jalankan perintah berikut di terminal:

```bash
flutter pub get
```

Ini akan menginstall semua dependencies yang tercantum di `pubspec.yaml`:
- `get` - State management & routing
- `http` - HTTP client
- `intl` - Internationalization
- `cached_network_image` - Image caching

### 4. Setup News API Key

#### A. Daftar di News API

1. Buka [https://newsapi.org/](https://newsapi.org/)
2. Klik **"Get API Key"**
3. Daftar dengan email Anda (GRATIS)
4. Setelah registrasi, Anda akan mendapat API Key

#### B. Tambahkan API Key ke Project

1. Buka file: `lib/services/news_api_service.dart`
2. Cari baris:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```
3. Replace dengan API key Anda:
   ```dart
   static const String _apiKey = 'abc123xyz456...';  // API key Anda
   ```
4. **Save file**

> ⚠️ **PENTING**: Jangan share API key Anda di public repository!

### 5. Verifikasi Setup

Cek apakah Flutter sudah terinstall dengan baik:

```bash
flutter doctor
```

Pastikan tidak ada error kritis (✓ atau ✗).

### 6. Jalankan Aplikasi

#### A. Menggunakan Terminal

```bash
# List available devices
flutter devices

# Run pada device yang tersedia
flutter run

# Run pada device spesifik
flutter run -d chrome        # Web
flutter run -d emulator-5554  # Android Emulator
flutter run -d iPhone         # iOS Simulator
```

#### B. Menggunakan IDE

**VS Code:**
1. Buka Command Palette (`Ctrl+Shift+P` atau `Cmd+Shift+P`)
2. Ketik "Flutter: Select Device"
3. Pilih device (emulator/simulator/physical)
4. Tekan `F5` atau klik "Run > Start Debugging"

**Android Studio:**
1. Pilih device di toolbar atas
2. Klik icon Run (▶️) atau tekan `Shift+F10`

---

## 🔧 Troubleshooting

### Error: "Failed to load news"

**Penyebab:** API key belum di-setup atau salah

**Solusi:**
1. Pastikan API key sudah ditambahkan di `lib/services/news_api_service.dart`
2. Cek koneksi internet
3. Verifikasi API key di [https://newsapi.org/account](https://newsapi.org/account)

### Error: "Package not found"

**Penyebab:** Dependencies belum terinstall

**Solusi:**
```bash
flutter clean
flutter pub get
```

### Error: Gradle build failed (Android)

**Solusi:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: CocoaPods (iOS)

**Solusi:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

### UI tidak update saat data berubah

**Penyebab:** Lupa menggunakan `.obs` atau `Obx()`

**Solusi:**
- Pastikan variable di controller menggunakan `.obs`
- Pastikan widget wrapped dengan `Obx()`
- Update value dengan `.value`

**Contoh:**
```dart
// Di Controller
final articles = <Article>[].obs;  // ✅ Gunakan .obs

// Update
articles.value = newData;  // ✅ Update dengan .value

// Di View
Obx(() => ListView(...))  // ✅ Wrap dengan Obx()
```

---

## 📁 Memahami Struktur MVC

### Model (`lib/models/`)
Data structure dan JSON parsing
```dart
class ArticleModel {
  final String title;
  factory ArticleModel.fromJson(Map json) { }
}
```

### View (`lib/views/`)
User Interface (UI widgets)
```dart
class HomeView extends GetView<HomeController> {
  Widget build(BuildContext context) { }
}
```

### Controller (`lib/controllers/`)
Business logic dan state management
```dart
class HomeController extends GetxController {
  final articles = <Article>[].obs;
  Future<void> fetchArticles() { }
}
```

### Service (`lib/services/`)
API calls dan network requests
```dart
class NewsApiService {
  Future<List<Article>> getArticles() { }
}
```

### Routes (`lib/routes/`)
Navigation configuration
```dart
class AppRoutes {
  static const home = '/home';
}
```

---

## 🎨 Customize Aplikasi

### Mengubah Nama Aplikasi

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="News App Saya"
    ...>
```

**iOS:** `ios/Runner/Info.plist`
```xml
<key>CFBundleName</key>
<string>News App Saya</string>
```

### Mengubah Warna Theme

Edit file: `lib/utils/app_colors.dart`

```dart
class AppColors {
  static const Color primary = Color(0xFF1976D2);  // Ubah ini
  static const Color accent = Color(0xFFFF5722);   // Dan ini
}
```

### Mengubah Negara Berita

Edit file: `lib/controllers/home_controller.dart`

```dart
final response = await _apiService.getTopHeadlines(
  country: 'id',  // id = Indonesia, us = USA, gb = UK
  category: selectedCategory.value,
);
```

Kode negara yang tersedia:
- `us` - United States
- `gb` - United Kingdom
- `id` - Indonesia
- `au` - Australia
- `in` - India
- Dan banyak lagi...

---

## 📊 Build Release Version

### Android APK

```bash
flutter build apk --release
```

File APK akan ada di: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (untuk Google Play)

```bash
flutter build appbundle --release
```

### iOS (macOS only)

```bash
flutter build ios --release
```

---

## 🔍 Debug Mode

### Hot Reload
Saat app running, tekan `r` di terminal untuk hot reload (update UI tanpa restart)

### Hot Restart
Tekan `R` (capital R) untuk hot restart (restart app dengan state baru)

### Debug Console
Gunakan `print()` untuk log ke console:
```dart
print('Debug: ${controller.articles.length}');
```

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 🧪 Testing Aplikasi

### Menambah File untuk Testing

Buat folder `test/` dan tambahkan unit tests:

```dart
// test/controllers/home_controller_test.dart
void main() {
  test('HomeController loads articles', () async {
    final controller = HomeController();
    await controller.fetchArticles();
    expect(controller.articles.isNotEmpty, true);
  });
}
```

### Run Tests

```bash
flutter test
```

---

## 📚 Resource Tambahan

### Official Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [GetX Docs](https://pub.dev/packages/get)
- [News API Docs](https://newsapi.org/docs)

### Tutorials
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)
- [MVC Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## ✅ Checklist Setup

Sebelum mulai development, pastikan:

- [ ] Flutter SDK terinstall
- [ ] Dependencies ter-install (`flutter pub get`)
- [ ] API Key sudah ditambahkan di `services/news_api_service.dart`
- [ ] App bisa running di device/emulator
- [ ] Hot reload berfungsi
- [ ] Bisa fetch dan display data dari API
- [ ] Memahami struktur folder MVC

---

## 🎓 Tips Belajar

### 1. Mulai dari Struktur
```
1. Pahami main.dart
2. Baca routes/app_pages.dart
3. Lihat models/
4. Baca services/
5. Pahami controllers/
6. Terakhir views/
```

### 2. Trace Data Flow
```
User tap button (View)
  → Controller method dipanggil
    → Service fetch dari API
      → Model parse JSON
        → Controller update state
          → View auto-rebuild
```

### 3. Experiment!
- Tambah field baru di Model
- Buat controller method baru
- Tambah widget di View
- Try & error adalah cara terbaik belajar!

---

## 🆘 Need Help?

Jika mengalami masalah:

1. Cek dokumentasi di `README.md`
2. Baca error message dengan teliti
3. Google error message + "flutter"
4. Cek `PENJELASAN_GETX.md` untuk detail GetX
5. Lihat `CONTOH_KODE.md` untuk code examples
6. Tanya di Stack Overflow dengan tag `flutter` dan `getx`

---

## 📝 Common Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Hot reload
r (di terminal saat app running)

# Hot restart
R (di terminal saat app running)

# Clean project
flutter clean

# Build APK
flutter build apk --release

# Run tests
flutter test

# Check Flutter installation
flutter doctor

# Update Flutter
flutter upgrade
```

---

**Selamat Coding! 🎉**
