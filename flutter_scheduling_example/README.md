# Flutter Scheduling Example

Aplikasi contoh untuk mempelajari:
1. ✅ Scheduling dengan Timer
2. 📬 Flutter Local Notifications
3. 🔄 Background Process
4. ⏰ WorkManager

## Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Jalankan Aplikasi
```bash
flutter run
```

## Fitur

### 1. Simple Timer
- Countdown timer sederhana
- Menampilkan waktu tersisa

### 2. Local Notifications
- Notifikasi sederhana (instant)
- Notifikasi terjadwal (5 detik)
- Notifikasi berkala

### 3. Background Process dengan Isolate
- Komputasi berat tanpa freeze UI
- Menghitung faktorial di background

### 4. WorkManager
- Background task sekali jalan
- Background task berkala (15 menit)
- Menampilkan notifikasi dari background

## Struktur Kode

```
lib/
├── main.dart                 # Entry point
├── screens/
│   └── home_screen.dart     # UI utama
├── services/
│   ├── notification_service.dart   # Service untuk notifikasi
│   └── background_service.dart     # Service untuk background tasks
└── utils/
    └── constants.dart       # Konstanta
```

## Catatan Penting

1. **Android 13+**: Perlu request permission untuk notifikasi
2. **WorkManager**: Minimal interval 15 menit untuk periodic task
3. **Testing**: Enable debug mode untuk lihat log background task
4. **Battery**: Background task di-optimize oleh sistem untuk hemat baterai

## Permissions

Aplikasi ini memerlukan permissions:
- POST_NOTIFICATIONS (Android 13+)
- RECEIVE_BOOT_COMPLETED
- SCHEDULE_EXACT_ALARM
- WAKE_LOCK
