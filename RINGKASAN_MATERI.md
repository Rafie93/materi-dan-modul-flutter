# 📝 Ringkasan Materi Flutter Scheduling

## Overview

Materi ini mencakup 4 konsep utama dalam mobile programming Flutter:

1. ⏱️ **Scheduling dengan Timer**
2. 📬 **Local Notifications**
3. 🔄 **Background Process (Isolate)**
4. ⚙️ **WorkManager (Background Task)**

---

## 1. Timer Scheduling

### Kapan Digunakan?
- Countdown timer
- Polling data saat app aktif
- Update UI berkala

### Karakteristik:
- ✅ Presisi tinggi
- ✅ Mudah diimplementasi
- ❌ Hanya jalan saat app aktif
- ❌ Stop saat app ditutup

### Code Example:

```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  setState(() {
    _counter++;
  });
});
```

### Use Case:
- Stopwatch app
- Game timer
- Real-time dashboard

---

## 2. Local Notifications

### Kapan Digunakan?
- Reminder
- Alarm
- Task notification
- Event alert

### Karakteristik:
- ✅ Tidak perlu server
- ✅ Berjalan meski app ditutup
- ✅ Presisi waktu tinggi
- ✅ Hemat baterai

### Jenis Notifikasi:

#### A. Simple Notification (Instant)
```dart
await flutterLocalNotificationsPlugin.show(
  0,
  'Title',
  'Body',
  notificationDetails,
);
```

#### B. Scheduled Notification
```dart
await flutterLocalNotificationsPlugin.zonedSchedule(
  0,
  'Title',
  'Body',
  scheduledTime,
  notificationDetails,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
);
```

#### C. Periodic Notification
```dart
await flutterLocalNotificationsPlugin.periodicallyShow(
  0,
  'Title',
  'Body',
  RepeatInterval.daily,
  notificationDetails,
);
```

### Use Case:
- Medicine reminder
- Daily alarm
- Appointment reminder
- Habit tracker

---

## 3. Background Process (Isolate)

### Kapan Digunakan?
- Komputasi matematika berat
- Parse JSON besar
- Image processing
- Data encryption

### Karakteristik:
- ✅ Tidak freeze UI
- ✅ Multi-threading
- ✅ Presisi tinggi
- ❌ Hanya saat app aktif

### Code Example:

```dart
// Main thread
final result = await Isolate.run(() {
  // Heavy computation di thread terpisah
  return computeFactorial(1000);
});

// UI tetap responsive!
```

### Use Case:
- Parse large JSON
- Image compression
- Complex calculations
- File processing

---

## 4. WorkManager

### Kapan Digunakan?
- Sync data berkala
- Upload file di background
- Database cleanup
- Fetch data otomatis

### Karakteristik:
- ✅ Berjalan meski app ditutup
- ✅ Bertahan setelah reboot
- ✅ Hemat baterai (system-optimized)
- ✅ Guaranteed execution
- ❌ Waktu tidak presisi

### Code Example:

```dart
// Callback (MUST have @pragma)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task logic
    await syncData();
    return Future.value(true);
  });
}

// Initialize
await Workmanager().initialize(callbackDispatcher);

// Register one-time task
await Workmanager().registerOneOffTask(
  "task1",
  "simpleTask",
  initialDelay: Duration(minutes: 5),
);

// Register periodic task (min 15 minutes)
await Workmanager().registerPeriodicTask(
  "task2",
  "periodicTask",
  frequency: Duration(minutes: 15),
);
```

### Use Case:
- Data synchronization
- Auto backup
- Content update
- Location tracking

---

## 📊 Perbandingan Metode

| Fitur | Timer | Isolate | Notifications | WorkManager |
|-------|-------|---------|---------------|-------------|
| **Presisi Waktu** | ✅ Sangat Presisi | ✅ Instant | ✅ Presisi | ❌ Tidak Presisi |
| **Jalan Saat App Tutup** | ❌ Tidak | ❌ Tidak | ✅ Ya | ✅ Ya |
| **Hemat Baterai** | ⚠️ Sedang | ✅ Baik | ✅ Baik | ✅ Sangat Baik |
| **Kompleksitas** | 🟢 Mudah | 🟡 Sedang | 🟡 Sedang | 🔴 Agak Sulit |
| **Bertahan Setelah Reboot** | ❌ Tidak | ❌ Tidak | ✅ Ya | ✅ Ya |

---

## 🎯 Decision Tree: Pilih Metode yang Tepat

```
Apakah task harus PRESISI waktu?
│
├─ YA → Butuh jalan saat app tutup?
│       ├─ YA → Local Notifications ✅
│       └─ TIDAK → Timer ✅
│
└─ TIDAK → Butuh jalan saat app tutup?
        ├─ YA → WorkManager ✅
        └─ TIDAK → Isolate (jika komputasi berat) ✅
                   atau Timer (jika sederhana) ✅
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_local_notifications: ^16.3.0  # Notifications
  timezone: ^0.9.2                      # Timezone support
  workmanager: ^0.5.2                   # Background tasks
```

---

## 🔑 Permissions (Android)

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

---

## 💡 Best Practices

### 1. Battery Optimization
```dart
// Gunakan constraints
Workmanager().registerPeriodicTask(
  "task",
  "taskName",
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
    requiresCharging: true,  // Hanya saat charging
  ),
);
```

### 2. Error Handling
```dart
Workmanager().executeTask((task, inputData) async {
  try {
    await doSomething();
    return Future.value(true);  // Success
  } catch (e) {
    print('Error: $e');
    return Future.value(false);  // Retry
  }
});
```

### 3. Debug Mode
```dart
// Development
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true,
);

// Production
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: false,
);
```

### 4. Notification Channels
```dart
// Buat channel yang sesuai kebutuhan
const AndroidNotificationDetails(
  'important_channel',
  'Important Notifications',
  importance: Importance.high,    // Prioritas tinggi
  priority: Priority.high,
  sound: RawResourceAndroidNotificationSound('alarm'),
);
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Notifikasi tidak muncul di Android 13+
**Solution:** Request runtime permission
```dart
await flutterLocalNotificationsPlugin
  .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.requestNotificationsPermission();
```

### Issue 2: WorkManager task tidak berjalan
**Solutions:**
1. Disable battery optimization
2. Check constraints (network, battery)
3. Verify `@pragma('vm:entry-point')` ada
4. Enable debug mode dan cek log

### Issue 3: Scheduled notification tidak presisi
**Solution:** Gunakan `exactAllowWhileIdle`
```dart
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
```

### Issue 4: App crash setelah update
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Real-World Examples

### 1. Alarm Clock App
- ⏰ Timer untuk countdown
- 📬 Notification untuk alarm
- 🔄 WorkManager untuk recurring alarm

### 2. Fitness Tracker
- ⏱️ Timer untuk workout session
- 📬 Notification untuk rest reminder
- 🔄 WorkManager untuk daily summary

### 3. Note App dengan Auto-Sync
- 🔄 WorkManager untuk sync setiap 15 menit
- 📬 Notification saat sync selesai
- 💾 Isolate untuk parse data besar

### 4. Medicine Reminder
- 📬 Scheduled notification untuk waktu minum obat
- 🔄 WorkManager untuk check missed doses
- ⏱️ Timer untuk countdown next dose

---

## 🚀 Advanced Topics

### 1. Combine Multiple Methods
```dart
// Timer untuk UI countdown
Timer.periodic(Duration(seconds: 1), (timer) {
  updateUI();
});

// WorkManager untuk background sync
Workmanager().registerPeriodicTask("sync", "syncTask");

// Notification ketika sync selesai
await notificationService.showSimpleNotification();
```

### 2. Notification Actions
```dart
const AndroidNotificationDetails(
  'channel',
  'Channel Name',
  actions: [
    AndroidNotificationAction('snooze', 'Snooze'),
    AndroidNotificationAction('dismiss', 'Dismiss'),
  ],
);
```

### 3. Data Persistence
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt('last_sync') ?? 0;
    
    // Sync only if > 1 hour
    if (DateTime.now().millisecondsSinceEpoch - lastSync > 3600000) {
      await syncData();
      await prefs.setInt('last_sync', DateTime.now().millisecondsSinceEpoch);
    }
    
    return Future.value(true);
  });
}
```

---

## 📖 Resources

### Documentation
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [WorkManager Plugin](https://pub.dev/packages/workmanager)
- [Flutter Isolate](https://dart.dev/guides/language/concurrency)

### Sample Projects
- Lihat folder: `flutter_scheduling_example/`
- Materi lengkap: `MATERI_FLUTTER_SCHEDULING.md`
- Panduan praktikum: `PANDUAN_PRAKTIKUM.md`

---

## ✅ Checklist Materi

- [ ] Memahami kapan menggunakan Timer
- [ ] Membuat 3 jenis notifikasi (simple, scheduled, periodic)
- [ ] Menggunakan Isolate untuk komputasi berat
- [ ] Setup WorkManager dengan callback
- [ ] Mendaftarkan one-time dan periodic task
- [ ] Handle permissions (Android 13+)
- [ ] Debugging background task
- [ ] Optimize battery consumption
- [ ] Combine multiple methods
- [ ] Build real-world app

---

**🎓 Selamat belajar dan semoga sukses!**
