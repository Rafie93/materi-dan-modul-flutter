import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  
  // Timer demo
  int _timerSeconds = 10;
  Timer? _timer;
  bool _isTimerRunning = false;

  // Isolate demo
  bool _isCalculating = false;
  String _isolateResult = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ========================================
  // 1. TIMER SCHEDULING
  // ========================================
  
  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _timerSeconds = 10;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _isTimerRunning = false;
          timer.cancel();
          _showSnackBar('⏰ Timer selesai!');
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _timerSeconds = 10;
    });
  }

  // ========================================
  // 2. LOCAL NOTIFICATIONS
  // ========================================

  Future<void> _showSimpleNotification() async {
    await _notificationService.showSimpleNotification(
      title: '📬 Notifikasi Sederhana',
      body: 'Ini adalah contoh notifikasi instant!',
    );
    _showSnackBar('Notifikasi sederhana ditampilkan');
  }

  Future<void> _scheduleNotification() async {
    await _notificationService.scheduleNotification(
      title: '⏰ Notifikasi Terjadwal',
      body: 'Notifikasi ini muncul 5 detik setelah dijadwalkan',
      delay: const Duration(seconds: 5),
    );
    _showSnackBar('Notifikasi akan muncul dalam 5 detik');
  }

  Future<void> _schedulePeriodicNotification() async {
    await _notificationService.schedulePeriodicNotification(
      title: '🔁 Notifikasi Berkala',
      body: 'Notifikasi ini muncul setiap menit',
    );
    _showSnackBar('Notifikasi berkala diaktifkan (setiap menit)');
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    _showSnackBar('Semua notifikasi dibatalkan');
  }

  // ========================================
  // 3. BACKGROUND PROCESS (Isolate)
  // ========================================

  Future<void> _runIsolateComputation() async {
    setState(() {
      _isCalculating = true;
      _isolateResult = 'Menghitung...';
    });

    try {
      // Hitung faktorial 20 di background thread
      final result = await IsolateService.calculateFactorial(20);
      
      setState(() {
        _isolateResult = 'Faktorial 20 = $result';
        _isCalculating = false;
      });
      
      _showSnackBar('Komputasi di Isolate selesai!');
    } catch (e) {
      setState(() {
        _isolateResult = 'Error: $e';
        _isCalculating = false;
      });
    }
  }

  // ========================================
  // 4. WORKMANAGER (Background Task)
  // ========================================

  Future<void> _registerOneTimeTask() async {
    await BackgroundService.registerOneTimeTask(
      taskName: 'simpleTask',
      delay: const Duration(seconds: 10),
    );
    _showSnackBar('One-time task dijadwalkan (10 detik)');
  }

  Future<void> _registerPeriodicTask() async {
    await BackgroundService.registerPeriodicTask(
      taskName: 'periodicTask',
      frequency: const Duration(minutes: 15),
    );
    _showSnackBar('Periodic task dijadwalkan (setiap 15 menit)');
  }

  Future<void> _registerSyncTask() async {
    await BackgroundService.registerOneTimeTask(
      taskName: 'syncTask',
      delay: const Duration(seconds: 5),
      inputData: {'message': 'Data dari aplikasi'},
    );
    _showSnackBar('Sync task dijadwalkan (5 detik)');
  }

  Future<void> _cancelAllTasks() async {
    await BackgroundService.cancelAllTasks();
    _showSnackBar('Semua background task dibatalkan');
  }

  // ========================================
  // UI HELPERS
  // ========================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Scheduling Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========================================
          // 1. TIMER SECTION
          // ========================================
          _buildSectionCard(
            title: '1. Timer Scheduling',
            icon: Icons.timer,
            color: Colors.blue,
            children: [
              Text(
                'Countdown: $_timerSeconds detik',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isTimerRunning ? null : _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isTimerRunning ? _stopTimer : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ========================================
          // 2. NOTIFICATIONS SECTION
          // ========================================
          _buildSectionCard(
            title: '2. Local Notifications',
            icon: Icons.notifications,
            color: Colors.orange,
            children: [
              _buildButton(
                label: 'Notifikasi Sederhana',
                icon: Icons.message,
                onPressed: _showSimpleNotification,
              ),
              _buildButton(
                label: 'Notifikasi Terjadwal (5 detik)',
                icon: Icons.schedule,
                onPressed: _scheduleNotification,
              ),
              _buildButton(
                label: 'Notifikasi Berkala (per menit)',
                icon: Icons.repeat,
                onPressed: _schedulePeriodicNotification,
              ),
              _buildButton(
                label: 'Batalkan Semua Notifikasi',
                icon: Icons.cancel,
                color: Colors.red,
                onPressed: _cancelAllNotifications,
              ),
            ],
          ),

          // ========================================
          // 3. ISOLATE SECTION
          // ========================================
          _buildSectionCard(
            title: '3. Background Process (Isolate)',
            icon: Icons.memory,
            color: Colors.green,
            children: [
              if (_isolateResult.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isolateResult,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _buildButton(
                label: _isCalculating
                    ? 'Menghitung...'
                    : 'Hitung Faktorial (Isolate)',
                icon: Icons.calculate,
                onPressed: _isCalculating ? null : _runIsolateComputation,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Menghitung faktorial 20 tanpa freeze UI',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          // ========================================
          // 4. WORKMANAGER SECTION
          // ========================================
          _buildSectionCard(
            title: '4. WorkManager (Background Task)',
            icon: Icons.work,
            color: Colors.purple,
            children: [
              _buildButton(
                label: 'One-Time Task (10 detik)',
                icon: Icons.play_circle,
                onPressed: _registerOneTimeTask,
              ),
              _buildButton(
                label: 'Periodic Task (15 menit)',
                icon: Icons.repeat_one,
                onPressed: _registerPeriodicTask,
              ),
              _buildButton(
                label: 'Sync Task dengan Data (5 detik)',
                icon: Icons.sync,
                onPressed: _registerSyncTask,
              ),
              _buildButton(
                label: 'Batalkan Semua Task',
                icon: Icons.cancel,
                color: Colors.red,
                onPressed: _cancelAllTasks,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '💡 Background task akan mengirim notifikasi ketika selesai',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: color,
          foregroundColor: color != null ? Colors.white : null,
        ),
      ),
    );
  }
}
