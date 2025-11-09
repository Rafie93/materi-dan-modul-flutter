# Panduan Praktikum Flutter Scheduling

## 📋 Daftar Isi
1. [Persiapan](#persiapan)
2. [Menjalankan Aplikasi](#menjalankan-aplikasi)
3. [Latihan 1: Timer](#latihan-1-timer)
4. [Latihan 2: Local Notifications](#latihan-2-local-notifications)
5. [Latihan 3: Background Process dengan Isolate](#latihan-3-background-process-dengan-isolate)
6. [Latihan 4: WorkManager](#latihan-4-workmanager)
5. [Tugas Mandiri](#tugas-mandiri)

---

## Persiapan

### 1. Sistem Requirement
- Flutter SDK 3.0.0 atau lebih baru
- Android Studio / VS Code
- Android Device atau Emulator (Android 5.0+)
- Koneksi internet untuk download dependencies

### 2. Clone & Setup Project

```bash
cd flutter_scheduling_example
flutter pub get
```

### 3. Periksa Instalasi

```bash
flutter doctor
```

Pastikan semua checklist hijau ✅

---

## Menjalankan Aplikasi

### 1. Hubungkan Device/Emulator

```bash
flutter devices
```

### 2. Jalankan Aplikasi

```bash
flutter run
```

Atau tekan **F5** di VS Code / Android Studio

### 3. Verifikasi Permissions

Saat pertama kali berjalan, aplikasi akan meminta permission:
- ✅ Notifications
- ✅ Exact Alarms

**Penting:** Berikan semua permission agar aplikasi berfungsi dengan baik.

---

## Latihan 1: Timer

### 🎯 Tujuan
Memahami cara membuat countdown timer sederhana menggunakan `Timer.periodic`

### 📝 Langkah-langkah

1. **Buka file** `lib/screens/home_screen.dart`

2. **Perhatikan kode Timer** di line ~23-40:

```dart
void _startTimer() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (_timerSeconds > 0) {
        _timerSeconds--;
      } else {
        timer.cancel();
      }
    });
  });
}
```

3. **Test di Aplikasi:**
   - Tekan tombol **"Start"**
   - Amati countdown dari 10 ke 0
   - Tekan **"Stop"** untuk membatalkan

### 💡 Konsep Penting

- `Timer.periodic()` - Menjalankan fungsi secara berkala
- `setState()` - Update UI
- `timer.cancel()` - Stop timer

### ✏️ Modifikasi

**Challenge 1:** Ubah countdown menjadi 30 detik

```dart
int _timerSeconds = 30; // Ubah dari 10 ke 30
```

**Challenge 2:** Tambahkan sound/notification saat timer selesai

```dart
if (_timerSeconds == 0) {
  _notificationService.showSimpleNotification(
    title: 'Timer Selesai!',
    body: 'Countdown telah berakhir',
  );
}
```

---

## Latihan 2: Local Notifications

### 🎯 Tujuan
Memahami berbagai jenis notifikasi lokal di Flutter

### 📝 Jenis Notifikasi yang Dipelajari

#### A. Notifikasi Sederhana (Instant)

1. **Buka file** `lib/services/notification_service.dart`

2. **Perhatikan method** `showSimpleNotification()` (line ~44-68)

3. **Test di Aplikasi:**
   - Tekan **"Notifikasi Sederhana"**
   - Notifikasi muncul langsung
   - Cek notification tray

#### B. Notifikasi Terjadwal

1. **Perhatikan method** `scheduleNotification()` (line ~71-97)

2. **Konsep penting:**
   ```dart
   final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
   ```

3. **Test di Aplikasi:**
   - Tekan **"Notifikasi Terjadwal (5 detik)"**
   - Tunggu 5 detik
   - Notifikasi akan muncul

#### C. Notifikasi Berkala

1. **Perhatikan method** `schedulePeriodicNotification()` (line ~100-121)

2. **Test di Aplikasi:**
   - Tekan **"Notifikasi Berkala (per menit)"**
   - Notifikasi akan muncul setiap menit
   - Tekan **"Batalkan Semua Notifikasi"** untuk stop

### 💡 Konsep Penting

- **Channels** - Grouping notifikasi
- **Importance** - Prioritas notifikasi
- **Scheduling** - Penjadwalan dengan timezone

### ✏️ Modifikasi

**Challenge 1:** Buat notifikasi dengan custom icon

```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'custom_channel',
  'Custom Notifications',
  importance: Importance.high,
  icon: 'app_icon', // Custom icon
  largeIcon: DrawableResourceAndroidBitmap('app_icon'),
);
```

**Challenge 2:** Tambahkan action button

```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'action_channel',
  'Action Notifications',
  importance: Importance.high,
  actions: <AndroidNotificationAction>[
    AndroidNotificationAction(
      'id_1',
      'Action 1',
      showsUserInterface: true,
    ),
  ],
);
```

---

## Latihan 3: Background Process dengan Isolate

### 🎯 Tujuan
Memahami cara menjalankan komputasi berat tanpa freeze UI

### 📝 Langkah-langkah

1. **Buka file** `lib/services/background_service.dart`

2. **Perhatikan kode Isolate** (line ~10-38):

```dart
static Future<int> calculateFactorial(int number) async {
  final receivePort = ReceivePort();
  
  await Isolate.spawn(_factorialComputation, {
    'number': number,
    'sendPort': receivePort.sendPort,
  });

  final result = await receivePort.first as int;
  return result;
}
```

3. **Test di Aplikasi:**
   - Tekan **"Hitung Faktorial (Isolate)"**
   - Perhatikan: UI tetap responsive!
   - Hasil muncul setelah komputasi selesai

### 💡 Konsep Penting

- **Isolate** - Thread terpisah dari UI
- **ReceivePort** - Menerima data dari isolate
- **SendPort** - Mengirim data ke main thread

### 🔍 Perbandingan

**Tanpa Isolate (Akan Freeze UI):**
```dart
int result = 1;
for (int i = 1; i <= 1000000; i++) {
  result *= i; // UI FREEZE!
}
```

**Dengan Isolate (UI Tetap Smooth):**
```dart
final result = await IsolateService.calculateFactorial(1000000);
// UI tetap responsive!
```

### ✏️ Modifikasi

**Challenge 1:** Hitung fibonacci

```dart
static void _fibonacciComputation(Map<String, dynamic> args) {
  final n = args['number'] as int;
  final sendPort = args['sendPort'] as SendPort;
  
  int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
  }
  
  sendPort.send(fib(n));
}
```

**Challenge 2:** Parse JSON besar di background

```dart
static void _parseJsonComputation(Map<String, dynamic> args) {
  final jsonString = args['json'] as String;
  final sendPort = args['sendPort'] as SendPort;
  
  final parsed = jsonDecode(jsonString);
  sendPort.send(parsed);
}
```

---

## Latihan 4: WorkManager

### 🎯 Tujuan
Memahami background task yang persisten (berjalan meskipun app ditutup)

### 📝 Langkah-langkah

#### A. One-Time Task

1. **Perhatikan callback dispatcher** di `background_service.dart` (line ~53-78)

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Task dijalankan di sini
    return Future.value(true);
  });
}
```

2. **Test di Aplikasi:**
   - Tekan **"One-Time Task (10 detik)"**
   - Tunggu 10 detik
   - Notifikasi muncul: "Simple Task Selesai"
   - **Bahkan jika app ditutup!**

#### B. Periodic Task

1. **Test di Aplikasi:**
   - Tekan **"Periodic Task (15 menit)"**
   - Task akan berjalan setiap 15 menit
   - Tutup aplikasi → task tetap berjalan!

#### C. Task dengan Data

1. **Perhatikan method** `_handleSyncTask()` (line ~112-125)

2. **Test di Aplikasi:**
   - Tekan **"Sync Task dengan Data (5 detik)"**
   - Notifikasi menampilkan data yang dikirim

### 💡 Konsep Penting

- **@pragma('vm:entry-point')** - WAJIB untuk callback
- **Constraints** - Kondisi task (wifi, battery, dll)
- **inputData** - Mengirim data ke background task

### 🔍 Debugging

**Enable Debug Mode:**

```dart
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true, // Tampilkan log
);
```

**Lihat Log:**

```bash
flutter logs
# atau
adb logcat | grep "WM-WorkManager"
```

### ✏️ Modifikasi

**Challenge 1:** Background download

```dart
Future<void> _handleDownloadTask() async {
  final response = await http.get(Uri.parse('https://api.example.com/data'));
  final data = response.body;
  
  // Save to local storage
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('downloaded_data', data);
  
  await _showBackgroundNotification(
    'Download Selesai',
    'Data berhasil didownload',
  );
}
```

**Challenge 2:** Location tracking

```dart
Future<void> _handleLocationTask() async {
  final position = await Geolocator.getCurrentPosition();
  
  await _showBackgroundNotification(
    'Lokasi Diupdate',
    'Lat: ${position.latitude}, Lng: ${position.longitude}',
  );
}
```

---

## Tugas Mandiri

### 🎯 Tugas 1: Reminder App
Buat aplikasi reminder sederhana:
- Input waktu reminder
- Kirim notifikasi pada waktu yang ditentukan
- Fitur snooze (tunda 5 menit)

**Hint:**
```dart
Future<void> setReminder(DateTime time) async {
  final scheduledTime = tz.TZDateTime.from(time, tz.local);
  await _notificationService.zonedSchedule(...);
}
```

### 🎯 Tugas 2: Data Sync App
Buat aplikasi yang sync data setiap 15 menit:
- Fetch data dari API
- Simpan ke local database
- Tampilkan notifikasi saat selesai

**Hint:**
```dart
@pragma('vm:entry-point')
void syncCallback() {
  Workmanager().executeTask((task, inputData) async {
    final response = await http.get('https://api.example.com/data');
    await saveToDatabase(response.body);
    await showNotification('Sync Selesai');
    return Future.value(true);
  });
}
```

### 🎯 Tugas 3: Pomodoro Timer
Buat aplikasi Pomodoro Timer:
- 25 menit work
- 5 menit break
- Notifikasi saat selesai
- Background timer tetap jalan

**Features:**
- Timer countdown
- Local notification
- Background service
- History tracking

---

## 🐛 Troubleshooting

### Problem 1: Notifikasi tidak muncul

**Solusi:**
1. Periksa permission di Settings → Apps → Flutter Scheduling → Notifications
2. Enable "Allow notification" 
3. Restart aplikasi

### Problem 2: Background task tidak jalan

**Solusi:**
1. Periksa battery optimization: Settings → Battery → Battery Optimization → Flutter Scheduling → Don't optimize
2. Pastikan ada internet (jika pakai constraint)
3. Check log: `adb logcat | grep "WorkManager"`

### Problem 3: Scheduled notification tidak presisi

**Solusi:**
1. Gunakan `AndroidScheduleMode.exactAllowWhileIdle`
2. Request `SCHEDULE_EXACT_ALARM` permission
3. Catat: Android 12+ ada batasan exact alarm

### Problem 4: App crash saat start

**Solusi:**
1. Pastikan timezone initialized:
   ```dart
   tz.initializeTimeZones();
   ```
2. Check AndroidManifest.xml permissions
3. Run `flutter clean && flutter pub get`

---

## 📚 Referensi Lengkap

### Dokumentasi
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [WorkManager](https://pub.dev/packages/workmanager)
- [Flutter Isolate](https://dart.dev/guides/language/concurrency)

### Tutorial
- [Background Tasks in Flutter](https://docs.flutter.dev/development/packages-and-plugins/background-processes)
- [Android WorkManager Guide](https://developer.android.com/topic/libraries/architecture/workmanager)

### Sample Code
- Lihat folder: `flutter_scheduling_example/`
- Materi teori: `MATERI_FLUTTER_SCHEDULING.md`

---

## ✅ Checklist Pembelajaran

- [ ] Memahami konsep Timer di Flutter
- [ ] Membuat notifikasi sederhana
- [ ] Membuat notifikasi terjadwal
- [ ] Membuat notifikasi berkala
- [ ] Menggunakan Isolate untuk komputasi berat
- [ ] Mendaftarkan WorkManager one-time task
- [ ] Mendaftarkan WorkManager periodic task
- [ ] Mengirim data ke background task
- [ ] Handle notification tap
- [ ] Debugging background task

---

## 💪 Level Up!

Setelah menguasai materi ini, coba:
1. **Combine** Timer + Notification + WorkManager
2. **Integrate** dengan Firebase Cloud Messaging
3. **Build** aplikasi real-world (Alarm, Reminder, Habit Tracker)
4. **Optimize** battery consumption
5. **Handle** edge cases (reboot, low battery, airplane mode)

---

**Selamat Belajar! 🚀**

Jika ada pertanyaan, jangan ragu untuk bertanya!
