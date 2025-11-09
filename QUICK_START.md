# 🚀 Quick Start Guide

## Setup Cepat (5 Menit)

### 1. Masuk ke Folder Project
```bash
cd flutter_scheduling_example
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

## ✨ Fitur yang Tersedia

### 1️⃣ Timer (Scheduling Sederhana)
- Countdown timer 10 detik
- Start/Stop button
- Real-time update UI

**Cara Pakai:**
- Tap "Start" untuk mulai countdown
- Tap "Stop" untuk hentikan

---

### 2️⃣ Local Notifications
Tiga jenis notifikasi:

#### A. Notifikasi Instant
- Tap "Notifikasi Sederhana"
- Notifikasi muncul langsung

#### B. Notifikasi Terjadwal
- Tap "Notifikasi Terjadwal (5 detik)"
- Tunggu 5 detik
- Notifikasi akan muncul

#### C. Notifikasi Berkala
- Tap "Notifikasi Berkala (per menit)"
- Notifikasi muncul setiap menit
- Tap "Batalkan Semua Notifikasi" untuk stop

---

### 3️⃣ Background Process (Isolate)
- Komputasi berat tanpa freeze UI
- Menghitung faktorial 20

**Cara Pakai:**
- Tap "Hitung Faktorial (Isolate)"
- UI tetap smooth saat menghitung
- Hasil ditampilkan setelah selesai

---

### 4️⃣ WorkManager (Background Task)
Task yang berjalan meskipun app ditutup:

#### A. One-Time Task
- Tap "One-Time Task (10 detik)"
- Tunggu 10 detik
- Notifikasi muncul
- **Coba tutup app → task tetap jalan!**

#### B. Periodic Task
- Tap "Periodic Task (15 menit)"
- Task berjalan setiap 15 menit
- Kirim notifikasi otomatis

#### C. Sync Task dengan Data
- Tap "Sync Task dengan Data (5 detik)"
- Task menerima dan memproses data
- Notifikasi menampilkan hasil

---

## 📱 Permissions yang Diperlukan

Saat pertama kali buka app, akan muncul request permission:

1. **Notifications** ✅
   - Allow untuk tampilkan notifikasi

2. **Exact Alarms** ✅
   - Allow untuk scheduled notifications

3. **Battery Optimization** ⚠️
   - Disable optimization untuk background task lebih stabil
   - Settings → Battery → Battery Optimization → Pilih app → Don't optimize

---

## 🧪 Testing Background Task

### Test 1: One-Time Task
1. Tap "One-Time Task (10 detik)"
2. Tutup aplikasi sepenuhnya
3. Tunggu 10 detik
4. Notifikasi tetap muncul! ✅

### Test 2: Periodic Task
1. Tap "Periodic Task (15 menit)"
2. Tutup aplikasi
3. Cek setiap 15 menit → notifikasi muncul
4. Task berjalan otomatis di background

### Test 3: After Reboot
1. Register periodic task
2. Restart device
3. Task masih aktif setelah reboot! ✅

---

## 📖 Struktur File Penting

```
flutter_scheduling_example/
├── lib/
│   ├── main.dart                      # Entry point + initialization
│   ├── screens/
│   │   └── home_screen.dart          # UI dengan semua contoh
│   └── services/
│       ├── notification_service.dart  # Service notifikasi
│       └── background_service.dart    # Service background task
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml       # Permissions & config
└── pubspec.yaml                       # Dependencies
```

---

## 🔍 Debugging

### Lihat Log Background Task

```bash
flutter logs
```

atau

```bash
adb logcat | grep "WorkManager"
```

### Enable Debug Mode

Di file `main.dart`:

```dart
await Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true,  // ← Set true untuk debug
);
```

---

## ❗ Troubleshooting Cepat

### Notifikasi tidak muncul?
1. Settings → Apps → [App Name] → Notifications → Enable
2. Restart app

### Background task tidak jalan?
1. Settings → Battery → Battery Optimization → [App Name] → Don't optimize
2. Pastikan ada internet (untuk constraint)

### App crash?
1. Run: `flutter clean`
2. Run: `flutter pub get`
3. Run: `flutter run`

---

## 📚 Dokumentasi Lengkap

- **Materi Teori:** `MATERI_FLUTTER_SCHEDULING.md`
- **Panduan Praktikum:** `PANDUAN_PRAKTIKUM.md`
- **Project README:** `flutter_scheduling_example/README.md`

---

## 💡 Tips

1. **Battery Saver Mode** dapat menunda background task
2. **Doze Mode** (Android) optimize task execution
3. **15 menit** adalah interval minimum untuk periodic task
4. **Debug Mode** bagus untuk testing, disable di production

---

## 🎯 Next Steps

1. ✅ Jalankan aplikasi
2. ✅ Test semua fitur
3. ✅ Baca materi teori
4. ✅ Kerjakan tugas praktikum
5. ✅ Modifikasi sesuai kebutuhan

---

**Happy Coding! 🎉**
