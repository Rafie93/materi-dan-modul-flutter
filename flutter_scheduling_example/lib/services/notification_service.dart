import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission untuk Android 13+
    await _requestPermissions();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  // Handler ketika notifikasi di-tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notifikasi diklik: ${response.payload}');
  }

  // 1. NOTIFIKASI SEDERHANA (Instant)
  Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'simple_channel',
      'Simple Notifications',
      channelDescription: 'Channel untuk notifikasi sederhana',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0, // ID notifikasi
      title,
      body,
      notificationDetails,
      payload: 'simple_notification',
    );
  }

  // 2. NOTIFIKASI TERJADWAL
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel untuk notifikasi terjadwal',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      1,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduled_notification',
    );
  }

  // 3. NOTIFIKASI BERKALA (Periodic)
  Future<void> schedulePeriodicNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'periodic_channel',
      'Periodic Notifications',
      channelDescription: 'Channel untuk notifikasi berkala',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.periodicallyShow(
      2,
      title,
      body,
      RepeatInterval.everyMinute, // Setiap menit (untuk demo)
      notificationDetails,
      payload: 'periodic_notification',
    );
  }

  // Batalkan notifikasi tertentu
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Batalkan semua notifikasi
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Dapatkan notifikasi yang sedang aktif
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
