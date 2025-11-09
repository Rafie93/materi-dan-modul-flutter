# 🎓 Materi Pemrograman Mobile Flutter
## Background Tasks, Scheduling, dan Notifications

---

## 📚 Konten yang Tersedia

Repositori ini berisi materi lengkap tentang **Scheduling, Notifications, Background Process, dan WorkManager** di Flutter, termasuk teori dan praktik.

---

## 📖 Dokumentasi

### 1. **MATERI_FLUTTER_SCHEDULING.md** 📘
   Materi teori lengkap mencakup:
   - ⏱️ Pengenalan konsep Scheduling di Flutter
   - 📬 Notifikasi menggunakan Flutter Local Notifications
   - 🔄 Background Process dengan Isolate
   - ⚙️ Alarm Manager dan WorkManager
   - 📊 Perbandingan metode dan best practices

### 2. **PANDUAN_PRAKTIKUM.md** 🧪
   Panduan praktikum step-by-step:
   - Setup dan persiapan
   - 4 latihan terstruktur dengan penjelasan
   - Modifikasi dan challenge
   - Troubleshooting
   - Tugas mandiri

### 3. **RINGKASAN_MATERI.md** 📝
   Ringkasan singkat semua konsep:
   - Overview setiap metode
   - Code examples
   - Decision tree untuk pilih metode
   - Common issues & solutions
   - Real-world examples

### 4. **QUICK_START.md** 🚀
   Quick start guide 5 menit:
   - Setup cepat
   - Cara pakai setiap fitur
   - Testing background task
   - Troubleshooting cepat

---

## 💻 Aplikasi Contoh

### Lokasi: `flutter_scheduling_example/`

Aplikasi Flutter lengkap dengan implementasi:

#### ✨ Fitur Aplikasi:

1. **Timer Scheduling**
   - Countdown timer 10 detik
   - Start/Stop functionality
   - Real-time UI update

2. **Local Notifications**
   - Notifikasi instant
   - Notifikasi terjadwal (5 detik)
   - Notifikasi berkala (setiap menit)

3. **Background Process (Isolate)**
   - Komputasi faktorial tanpa freeze UI
   - Demo multi-threading

4. **WorkManager**
   - One-time background task
   - Periodic background task (15 menit)
   - Sync task dengan data input

---

## 🚀 Cara Memulai

### Option 1: Quick Start (Rekomendasi)

```bash
# 1. Masuk ke folder project
cd flutter_scheduling_example

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run
```

### Option 2: Baca Materi Dulu

1. Baca `MATERI_FLUTTER_SCHEDULING.md` untuk teori
2. Baca `QUICK_START.md` untuk overview
3. Jalankan aplikasi contoh
4. Ikuti `PANDUAN_PRAKTIKUM.md` untuk latihan

---

## 📁 Struktur Project

```
/workspace/
│
├── 📘 MATERI_FLUTTER_SCHEDULING.md    # Materi teori lengkap
├── 🧪 PANDUAN_PRAKTIKUM.md            # Panduan praktikum
├── 📝 RINGKASAN_MATERI.md             # Ringkasan singkat
├── 🚀 QUICK_START.md                  # Quick start guide
│
└── 💻 flutter_scheduling_example/     # Aplikasi contoh
    ├── lib/
    │   ├── main.dart                  # Entry point
    │   ├── screens/
    │   │   └── home_screen.dart      # UI utama
    │   └── services/
    │       ├── notification_service.dart   # Service notifikasi
    │       └── background_service.dart     # Service background
    │
    ├── android/
    │   └── app/src/main/
    │       └── AndroidManifest.xml    # Permissions
    │
    ├── pubspec.yaml                   # Dependencies
    └── README.md                      # Project README
```

---

## 🎯 Topik yang Dibahas

### 1. Scheduling dengan Timer ⏱️

**Konsep:**
- Timer.periodic untuk task berkala
- setState untuk update UI
- Cancel timer

**Use Case:**
- Countdown timer
- Stopwatch
- Polling data

**Kode:**
```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  setState(() {
    _counter++;
  });
});
```

---

### 2. Local Notifications 📬

**Konsep:**
- Simple notification (instant)
- Scheduled notification (waktu tertentu)
- Periodic notification (berulang)
- Notification channels

**Use Case:**
- Reminder
- Alarm
- Daily notification
- Event alert

**Kode:**
```dart
await flutterLocalNotificationsPlugin.show(
  0,
  'Judul',
  'Pesan',
  notificationDetails,
);
```

---

### 3. Background Process (Isolate) 🔄

**Konsep:**
- Isolate untuk multi-threading
- SendPort & ReceivePort
- Komputasi tanpa freeze UI

**Use Case:**
- Parse JSON besar
- Image processing
- Complex calculations
- Data encryption

**Kode:**
```dart
final result = await Isolate.run(() {
  return heavyComputation();
});
```

---

### 4. WorkManager ⚙️

**Konsep:**
- Background task persisten
- One-time & periodic task
- Constraints (network, battery)
- Callback dispatcher

**Use Case:**
- Data sync
- Auto backup
- Upload file
- Database cleanup

**Kode:**
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task
    return Future.value(true);
  });
}
```

---

## 📊 Perbandingan Metode

| Metode | Presisi | Background | Baterai | Use Case |
|--------|---------|------------|---------|----------|
| **Timer** | ✅ Tinggi | ❌ Tidak | ⚠️ Sedang | Countdown, polling |
| **Isolate** | ✅ Tinggi | ❌ Tidak | ✅ Baik | Komputasi berat |
| **Notifications** | ✅ Tinggi | ✅ Ya | ✅ Baik | Reminder, alarm |
| **WorkManager** | ❌ Rendah | ✅ Ya | ✅ Sangat Baik | Sync data, backup |

---

## 🛠️ Requirements

### Software:
- Flutter SDK 3.0.0+
- Android Studio / VS Code
- Android Device / Emulator (Android 5.0+)

### Packages:
```yaml
dependencies:
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
  workmanager: ^0.5.2
```

### Permissions (Android):
- `RECEIVE_BOOT_COMPLETED`
- `VIBRATE`
- `SCHEDULE_EXACT_ALARM`
- `POST_NOTIFICATIONS`
- `WAKE_LOCK`

---

## 📱 Testing

### Test Notifications:
1. Tap "Notifikasi Sederhana" → Notifikasi muncul instant
2. Tap "Notifikasi Terjadwal" → Tunggu 5 detik
3. Tap "Notifikasi Berkala" → Muncul setiap menit

### Test Background Task:
1. Tap "One-Time Task (10 detik)"
2. **Tutup aplikasi sepenuhnya**
3. Tunggu 10 detik
4. Notifikasi tetap muncul ✅

### Test Isolate:
1. Tap "Hitung Faktorial"
2. Perhatikan UI tetap responsive
3. Hasil muncul setelah komputasi selesai

---

## 🐛 Troubleshooting

### Notifikasi tidak muncul?
- ✅ Periksa permission di Settings
- ✅ Enable notifications untuk app
- ✅ Restart aplikasi

### Background task tidak jalan?
- ✅ Disable battery optimization
- ✅ Periksa constraints (network, battery)
- ✅ Lihat log: `flutter logs`

### App crash?
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Cara Belajar (Rekomendasi)

### 🎯 Untuk Pemula:

1. **Hari 1: Teori**
   - Baca `MATERI_FLUTTER_SCHEDULING.md`
   - Pahami konsep dasar

2. **Hari 2: Praktik Dasar**
   - Baca `QUICK_START.md`
   - Jalankan aplikasi contoh
   - Test semua fitur

3. **Hari 3: Deep Dive**
   - Ikuti `PANDUAN_PRAKTIKUM.md`
   - Kerjakan latihan 1-4
   - Coba modifikasi code

4. **Hari 4: Project**
   - Kerjakan tugas mandiri
   - Build aplikasi sederhana
   - Combine multiple methods

### 🚀 Untuk Advanced:

1. Baca `RINGKASAN_MATERI.md` untuk overview
2. Langsung ke code di `flutter_scheduling_example/`
3. Study service files:
   - `notification_service.dart`
   - `background_service.dart`
4. Build real-world project

---

## 💡 Tips & Best Practices

### 1. Battery Optimization
```dart
// Gunakan constraints untuk hemat baterai
Workmanager().registerPeriodicTask(
  "task",
  "taskName",
  constraints: Constraints(
    requiresBatteryNotLow: true,
    requiresCharging: true,
  ),
);
```

### 2. Error Handling
```dart
try {
  await doSomething();
  return Future.value(true);
} catch (e) {
  print('Error: $e');
  return Future.value(false);
}
```

### 3. Debug Mode
```dart
// Development
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true,
);
```

---

## 🎓 Learning Outcomes

Setelah menyelesaikan materi ini, Anda akan mampu:

- ✅ Membuat countdown timer dengan Flutter
- ✅ Implementasi 3 jenis notifikasi lokal
- ✅ Menjalankan komputasi berat tanpa freeze UI
- ✅ Setup background task yang persisten
- ✅ Memilih metode yang tepat untuk kebutuhan
- ✅ Handle permissions di Android 13+
- ✅ Debug dan troubleshoot background task
- ✅ Build aplikasi dengan scheduling & notifications

---

## 🌟 Project Ideas

### Beginner:
1. **Simple Alarm** - Timer + Notification
2. **Pomodoro Timer** - Timer + Background notification
3. **Daily Reminder** - Scheduled notification

### Intermediate:
1. **Habit Tracker** - Periodic notification + local storage
2. **Fitness Timer** - Timer + WorkManager + Notification
3. **Medicine Reminder** - Complex scheduling

### Advanced:
1. **Auto Backup App** - WorkManager + File handling
2. **Location Tracker** - Background service + Notification
3. **Smart Sync** - WorkManager + API + Notification

---

## 📞 Support & Resources

### Dokumentasi Resmi:
- [Flutter Docs](https://docs.flutter.dev/)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [WorkManager Plugin](https://pub.dev/packages/workmanager)

### Sample Code:
- Lihat folder `flutter_scheduling_example/`
- Semua contoh sudah siap dijalankan
- Code sudah diberi comment untuk memudahkan pemahaman

---

## ✅ Checklist Materi

- [ ] Membaca materi teori
- [ ] Setup dan run aplikasi contoh
- [ ] Test Timer functionality
- [ ] Test 3 jenis notifikasi
- [ ] Test Isolate computation
- [ ] Test WorkManager one-time task
- [ ] Test WorkManager periodic task
- [ ] Kerjakan latihan praktikum
- [ ] Modifikasi code sesuai kebutuhan
- [ ] Build project sendiri

---

## 📝 Catatan Penting

1. **Android 13+**: Perlu request runtime permission untuk notifikasi
2. **Battery Optimization**: Disable untuk background task lebih stabil
3. **WorkManager Interval**: Minimal 15 menit untuk periodic task
4. **Debug Mode**: Set `false` di production
5. **Constraints**: Gunakan untuk optimize battery

---

## 🎉 Selamat Belajar!

Semoga materi ini bermanfaat untuk pembelajaran Anda. 

**Happy Coding! 🚀**

---

## 📄 License

Materi ini dibuat untuk tujuan edukasi dan bebas digunakan untuk pembelajaran.

## 👨‍💻 Author

Dibuat dengan ❤️ untuk pembelajaran Flutter

---

**Last Updated:** 2025-11-09
