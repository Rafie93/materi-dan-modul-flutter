# 📋 Flutter Scheduling Cheatsheet

## 🚀 Quick Reference

---

## 1. ⏱️ TIMER

### Basic Timer
```dart
Timer(Duration(seconds: 5), () {
  print('Executed after 5 seconds');
});
```

### Periodic Timer
```dart
Timer _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  print('Executed every second');
});
```

### Cancel Timer
```dart
_timer.cancel();
```

### Future.delayed
```dart
await Future.delayed(Duration(seconds: 3));
print('After 3 seconds');
```

---

## 2. 📬 LOCAL NOTIFICATIONS

### Setup
```dart
final FlutterLocalNotificationsPlugin notifications = 
    FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings android = 
    AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings settings = InitializationSettings(android: android);

await notifications.initialize(settings);
```

### Simple Notification
```dart
await notifications.show(
  0,                              // ID
  'Title',                        // Title
  'Body',                         // Body
  NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
    ),
  ),
);
```

### Scheduled Notification
```dart
import 'package:timezone/timezone.dart' as tz;

await notifications.zonedSchedule(
  0,
  'Title',
  'Body',
  tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
  NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
    ),
  ),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
);
```

### Periodic Notification
```dart
await notifications.periodicallyShow(
  0,
  'Title',
  'Body',
  RepeatInterval.daily,          // daily, hourly, weekly, etc.
  NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
    ),
  ),
);
```

### Cancel Notifications
```dart
await notifications.cancel(0);           // Cancel specific
await notifications.cancelAll();         // Cancel all
```

### Request Permission (Android 13+)
```dart
final AndroidFlutterLocalNotificationsPlugin? android =
    notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

await android?.requestNotificationsPermission();
```

---

## 3. 🔄 ISOLATE (Background Process)

### Simple Isolate
```dart
import 'dart:isolate';

// Method 1: Isolate.run (Dart 3.0+)
final result = await Isolate.run(() {
  // Heavy computation
  return computeSomething();
});

// Method 2: Traditional
Future<int> runIsolate() async {
  final receivePort = ReceivePort();
  
  await Isolate.spawn(_isolateFunction, receivePort.sendPort);
  
  final result = await receivePort.first as int;
  return result;
}

void _isolateFunction(SendPort sendPort) {
  final result = heavyComputation();
  sendPort.send(result);
}
```

### Isolate with Parameters
```dart
Future<int> calculateFactorial(int number) async {
  final receivePort = ReceivePort();
  
  await Isolate.spawn(_factorialComputation, {
    'number': number,
    'sendPort': receivePort.sendPort,
  });

  final result = await receivePort.first as int;
  return result;
}

void _factorialComputation(Map<String, dynamic> args) {
  final number = args['number'] as int;
  final sendPort = args['sendPort'] as SendPort;

  int result = 1;
  for (int i = 1; i <= number; i++) {
    result *= i;
  }

  sendPort.send(result);
}
```

---

## 4. ⚙️ WORKMANAGER

### Setup
```dart
import 'package:workmanager/workmanager.dart';

// Callback (MUST be top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Task: $task');
    
    // Do background work here
    
    return Future.value(true);  // Success
  });
}

// Initialize in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  
  runApp(MyApp());
}
```

### One-Time Task
```dart
await Workmanager().registerOneOffTask(
  'uniqueTaskName',              // Unique name
  'taskIdentifier',              // Task type
  initialDelay: Duration(seconds: 10),
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
  ),
  inputData: {                   // Optional data
    'key': 'value',
  },
);
```

### Periodic Task
```dart
await Workmanager().registerPeriodicTask(
  'uniqueTaskName',
  'taskIdentifier',
  frequency: Duration(minutes: 15),    // Minimum 15 minutes
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
);
```

### Cancel Tasks
```dart
await Workmanager().cancelByUniqueName('taskName');
await Workmanager().cancelAll();
```

### Task with Input Data
```dart
// Register
await Workmanager().registerOneOffTask(
  'syncTask',
  'syncTask',
  inputData: {
    'url': 'https://api.example.com',
    'userId': 123,
  },
);

// Handle in callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'syncTask') {
      final url = inputData?['url'] as String?;
      final userId = inputData?['userId'] as int?;
      
      // Use the data
      await syncData(url, userId);
    }
    
    return Future.value(true);
  });
}
```

---

## 📦 DEPENDENCIES

### pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
  workmanager: ^0.5.2
```

---

## 🔑 PERMISSIONS

### android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <!-- Scheduling -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    
    <!-- Background Tasks -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    
</manifest>
```

---

## 🎯 DECISION TREE

```
Need PRECISE timing?
├─ YES
│  ├─ Work when app closed? → Local Notifications
│  └─ Only when app active? → Timer
│
└─ NO (Flexible timing OK)
   ├─ Work when app closed? → WorkManager
   └─ Only when app active?
      ├─ Heavy computation? → Isolate
      └─ Simple task? → Timer
```

---

## 💡 COMMON PATTERNS

### Pattern 1: Countdown with Notification
```dart
Timer? _timer;
int _seconds = 60;

void startCountdown() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (_seconds > 0) {
        _seconds--;
      } else {
        timer.cancel();
        _showNotification('Time\'s up!');
      }
    });
  });
}
```

### Pattern 2: Periodic Sync
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'syncTask') {
      // Fetch data from API
      final response = await http.get('https://api.example.com/data');
      
      // Save locally
      await saveToDatabase(response.body);
      
      // Show notification
      await showNotification('Data synced!');
    }
    return Future.value(true);
  });
}

// Register
Workmanager().registerPeriodicTask(
  'sync',
  'syncTask',
  frequency: Duration(minutes: 15),
);
```

### Pattern 3: Heavy Computation
```dart
Future<void> processLargeFile() async {
  setState(() => _isLoading = true);
  
  final result = await Isolate.run(() {
    // Heavy processing
    return parseAndComputeLargeFile();
  });
  
  setState(() {
    _isLoading = false;
    _result = result;
  });
}
```

### Pattern 4: Daily Reminder
```dart
Future<void> scheduleDailyReminder(TimeOfDay time) async {
  final now = DateTime.now();
  final scheduledDate = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  
  await notifications.zonedSchedule(
    0,
    'Daily Reminder',
    'Don\'t forget to...',
    tz.TZDateTime.from(scheduledDate, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel',
        'Daily Reminders',
        importance: Importance.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,  // Repeat daily
  );
}
```

---

## 🐛 TROUBLESHOOTING

### Notifications not showing?
```dart
// 1. Request permission
await android?.requestNotificationsPermission();

// 2. Check settings
Settings → Apps → [Your App] → Notifications → Enable

// 3. Use high importance
importance: Importance.high,
priority: Priority.high,
```

### WorkManager not running?
```bash
# 1. Check logs
adb logcat | grep "WorkManager"

# 2. Disable battery optimization
Settings → Battery → Battery Optimization → [App] → Don't optimize

# 3. Enable debug mode
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true,
);
```

### Isolate not working?
```dart
// Make sure function is static or top-level
static void computeFunction(SendPort sendPort) {
  // Your code
}

// NOT this:
void computeFunction(SendPort sendPort) {  // ❌ Non-static
  // Your code
}
```

---

## 📊 COMPARISON TABLE

| Feature | Timer | Isolate | Notification | WorkManager |
|---------|-------|---------|--------------|-------------|
| Precise timing | ✅ | ✅ | ✅ | ❌ |
| Works app closed | ❌ | ❌ | ✅ | ✅ |
| Battery efficient | ⚠️ | ✅ | ✅ | ✅ |
| Survives reboot | ❌ | ❌ | ✅ | ✅ |
| UI updates | ✅ | ✅ | ❌ | ❌ |
| Heavy computation | ❌ | ✅ | ❌ | ⚠️ |

---

## 🔗 USEFUL LINKS

- [Flutter Local Notifications Docs](https://pub.dev/packages/flutter_local_notifications)
- [WorkManager Docs](https://pub.dev/packages/workmanager)
- [Dart Isolates](https://dart.dev/guides/language/concurrency)
- [Android WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager)

---

## 💾 SAVE THIS CHEATSHEET!

**Tip:** Bookmark atau print cheatsheet ini untuk referensi cepat saat coding!

---

**Last Updated:** 2025-11-09
