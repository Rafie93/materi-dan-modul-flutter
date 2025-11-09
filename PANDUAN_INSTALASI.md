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

### 2. Install Dependencies

Jalankan perintah berikut di terminal:

```bash
flutter pub get
```

Ini akan menginstall semua dependencies yang tercantum di `pubspec.yaml`:
- `get` - State management
- `http` - HTTP client
- `intl` - Internationalization
- `cached_network_image` - Image caching

### 3. Setup News API Key

#### A. Daftar di News API

1. Buka [https://newsapi.org/](https://newsapi.org/)
2. Klik **"Get API Key"**
3. Daftar dengan email Anda (GRATIS)
4. Setelah registrasi, Anda akan mendapat API Key

#### B. Tambahkan API Key ke Project

1. Buka file: `lib/app/data/providers/news_api_provider.dart`
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

### 4. Verifikasi Setup

Cek apakah Flutter sudah terinstall dengan baik:

```bash
flutter doctor
```

Pastikan tidak ada error kritis (✓ atau ✗).

### 5. Jalankan Aplikasi

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
1. Pastikan API key sudah ditambahkan di `news_api_provider.dart`
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

---

## 📱 Testing di Berbagai Platform

### Android
```bash
flutter run -d android
```

### iOS (hanya di macOS)
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Windows (Windows only)
```bash
flutter run -d windows
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

Edit file: `lib/app/core/values/app_colors.dart`

```dart
class AppColors {
  static const Color primary = Color(0xFF1976D2);  // Ubah ini
  static const Color accent = Color(0xFFFF5722);   // Dan ini
}
```

### Mengubah Negara Berita

Edit file: `lib/app/modules/home/controllers/home_controller.dart`

```dart
final response = await _apiProvider.getTopHeadlines(
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

## 📚 Resource Tambahan

### Official Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [GetX Docs](https://pub.dev/packages/get)
- [News API Docs](https://newsapi.org/docs)

### Tutorials
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## ✅ Checklist Setup

Sebelum mulai development, pastikan:

- [ ] Flutter SDK terinstall
- [ ] Dependencies ter-install (`flutter pub get`)
- [ ] API Key sudah ditambahkan
- [ ] App bisa running di device/emulator
- [ ] Hot reload berfungsi
- [ ] Bisa fetch dan display data dari API

---

## 🆘 Need Help?

Jika mengalami masalah:

1. Cek dokumentasi di `README.md`
2. Baca error message dengan teliti
3. Google error message + "flutter"
4. Tanya di Stack Overflow dengan tag `flutter` dan `getx`
5. Konsultasi dengan instruktur atau mentor

---

**Selamat Coding! 🎉**
