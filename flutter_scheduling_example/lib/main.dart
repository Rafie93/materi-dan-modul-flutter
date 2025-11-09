import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone untuk scheduled notifications
  tz.initializeTimeZones();

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Background Service (WorkManager)
  await BackgroundService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Scheduling Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
