# Materi Pemrograman Mobile Flutter
## Background Tasks, Scheduling, dan Notifications

---

## 1. Pengenalan Konsep Scheduling di Flutter

### Apa itu Scheduling?

Scheduling adalah proses penjadwalan tugas atau operasi untuk dijalankan pada waktu tertentu atau secara berkala. Dalam aplikasi mobile, scheduling sangat penting untuk:

- Mengirim notifikasi pada waktu tertentu
- Melakukan sinkronisasi data di background
- Menjalankan tugas maintenance secara berkala
- Mengatur alarm dan reminder

### Jenis-jenis Scheduling di Flutter

#### 1.1 Timer-based Scheduling
Menggunakan `Timer` atau `Future.delayed()` untuk tugas sederhana yang berjalan ketika aplikasi aktif.

```dart
Timer.periodic(Duration(seconds: 5), (timer) {
  print('Task dijalankan setiap 5 detik');
});
```

**Kelemahan:** Hanya berjalan saat aplikasi aktif/foreground.

#### 1.2 Background Scheduling
Menggunakan plugin seperti `workmanager` untuk menjalankan tugas bahkan saat aplikasi tertutup.

**Keunggulan:**
- Berjalan di background
- Persisten (tetap berjalan meskipun aplikasi ditutup)
- Efisien dalam penggunaan baterai

---

## 2. Notifikasi menggunakan Flutter Local Notifications

### Apa itu Flutter Local Notifications?

`flutter_local_notifications` adalah plugin yang memungkinkan aplikasi Flutter menampilkan notifikasi lokal (tidak memerlukan server).

### Fitur Utama:

1. **Notifikasi Sederhana** - Tampilan notifikasi basic dengan judul dan isi
2. **Scheduled Notifications** - Notifikasi terjadwal
3. **Periodic Notifications** - Notifikasi berulang
4. **Notification Actions** - Tombol aksi pada notifikasi
5. **Custom Sound & Vibration** - Suara dan getaran custom

### Instalasi

Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  flutter_local_notifications: ^16.3.0
```

### Konfigurasi Android

Di `android/app/src/main/AndroidManifest.xml`, tambahkan permissions:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Setup Dasar

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
```

### Menampilkan Notifikasi Sederhana

```dart
Future<void> showSimpleNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: 'Channel description',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // ID notifikasi
    'Judul Notifikasi',
    'Ini adalah isi pesan notifikasi',
    notificationDetails,
  );
}
```

### Notifikasi Terjadwal

```dart
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Notifikasi Terjadwal',
    'Ini akan muncul 5 detik dari sekarang',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        importance: Importance.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

---

## 3. Background Process

### Apa itu Background Process?

Background Process adalah proses yang berjalan di latar belakang, bahkan ketika aplikasi tidak aktif atau ditutup oleh user.

### Use Cases:

- Download file besar
- Sinkronisasi data dengan server
- Tracking lokasi
- Pemrosesan data berkala

### Metode Background Process di Flutter

#### 3.1 Isolate (Untuk Komputasi Berat)

```dart
import 'dart:isolate';

// Fungsi yang berjalan di isolate terpisah
void heavyComputation(SendPort sendPort) {
  // Proses komputasi berat
  int result = 0;
  for (int i = 0; i < 1000000; i++) {
    result += i;
  }
  sendPort.send(result);
}

// Memanggil isolate
Future<void> runBackgroundTask() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(heavyComputation, receivePort.sendPort);
  
  receivePort.listen((data) {
    print('Hasil: $data');
  });
}
```

**Catatan:** Isolate hanya berjalan saat aplikasi aktif.

#### 3.2 Background Fetch (iOS) & Background Service (Android)

Untuk task yang perlu berjalan meskipun aplikasi ditutup, gunakan `workmanager`.

---

## 4. Alarm Manager dan WorkManager

### WorkManager di Flutter

`workmanager` adalah plugin yang menggunakan:
- **Android**: WorkManager API
- **iOS**: Background Fetch

### Karakteristik WorkManager:

✅ Berjalan meskipun aplikasi ditutup  
✅ Bertahan setelah reboot device  
✅ Efisien untuk baterai  
✅ Dijamin dijalankan oleh sistem  
❌ Waktu eksekusi tidak presisi (sistem menentukan)  

### Instalasi

```yaml
dependencies:
  workmanager: ^0.5.2
```

### Konfigurasi Android

Di `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### Setup WorkManager

```dart
import 'package:workmanager/workmanager.dart';

// Callback yang dipanggil di background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Background task dijalankan: $task");
    
    // Lakukan tugas di sini
    // Contoh: sync data, kirim notifikasi, dll
    
    return Future.value(true);
  });
}

// Initialize di main()
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set false di production
  );
  runApp(MyApp());
}
```

### Mendaftarkan Task Sekali Jalan

```dart
Workmanager().registerOneOffTask(
  "1", // Unique task name
  "simpleTask",
  initialDelay: Duration(seconds: 10),
  constraints: Constraints(
    networkType: NetworkType.connected, // Harus ada internet
    requiresBatteryNotLow: true,
  ),
);
```

### Mendaftarkan Task Berkala

```dart
Workmanager().registerPeriodicTask(
  "2",
  "periodicTask",
  frequency: Duration(minutes: 15), // Minimal 15 menit
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
);
```

### Membatalkan Task

```dart
// Batalkan task tertentu
Workmanager().cancelByUniqueName("1");

// Batalkan semua task
Workmanager().cancelAll();
```

---

## Perbandingan Metode Background Task

| Metode | Presisi Waktu | Berjalan saat App Tutup | Efisiensi Baterai | Use Case |
|--------|---------------|-------------------------|-------------------|----------|
| Timer | ✅ Presisi | ❌ Tidak | ⚠️ Sedang | Countdown, polling saat app aktif |
| Isolate | ✅ Presisi | ❌ Tidak | ✅ Baik | Komputasi berat tanpa freeze UI |
| Local Notifications | ✅ Presisi | ✅ Ya | ✅ Baik | Reminder, alarm |
| WorkManager | ❌ Tidak Presisi | ✅ Ya | ✅ Sangat Baik | Sync data, maintenance berkala |

---

## Best Practices

### 1. **Pilih Metode yang Tepat**
   - Gunakan Timer untuk task sederhana saat app aktif
   - Gunakan Local Notifications untuk reminder/alarm
   - Gunakan WorkManager untuk sync data berkala

### 2. **Efisiensi Baterai**
   - Hindari background task yang terlalu sering
   - Gunakan constraint (hanya saat charging, wifi, dll)
   - Batch beberapa operasi menjadi satu

### 3. **Handle Permissions**
   - Request permission notifikasi di Android 13+
   - Jelaskan ke user mengapa butuh background access

### 4. **Testing**
   ```dart
   // Enable debug mode saat development
   Workmanager().initialize(
     callbackDispatcher,
     isInDebugMode: true,
   );
   ```

### 5. **Error Handling**
   ```dart
   Workmanager().executeTask((task, inputData) {
     try {
       // Task logic
       return Future.value(true); // Success
     } catch (e) {
       print('Error: $e');
       return Future.value(false); // Retry
     }
   });
   ```

---

## Kesimpulan

Scheduling dan background task adalah fitur penting dalam aplikasi mobile modern. Flutter menyediakan berbagai tools untuk implementasi:

- **Flutter Local Notifications** untuk notifikasi lokal
- **WorkManager** untuk background task yang persisten
- **Isolate** untuk komputasi berat tanpa blocking UI
- **Timer** untuk task sederhana saat aplikasi aktif

Pilih metode yang sesuai dengan kebutuhan aplikasi Anda, dan selalu pertimbangkan efisiensi baterai serta user experience.

---

## Referensi

- [Flutter Local Notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [WorkManager Plugin](https://pub.dev/packages/workmanager)
- [Flutter Isolate](https://dart.dev/guides/language/concurrency)
- [Android WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager)
