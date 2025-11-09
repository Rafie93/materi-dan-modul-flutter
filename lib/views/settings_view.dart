import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/note_controller.dart';

/// SettingsView - Halaman pengaturan aplikasi
/// 
/// Fitur:
/// - Toggle dark/light mode
/// - Adjust font size
/// - Sort preferences
/// - Clear all notes
/// - App info
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();
    final NoteController noteController = Get.find<NoteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 2,
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader('Tampilan', Icons.palette),
          
          // Dark Mode Toggle
          Obx(() => SwitchListTile(
            title: Text(
              'Dark Mode',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              settingsController.isDarkMode.value
                  ? 'Mode gelap diaktifkan'
                  : 'Mode terang diaktifkan',
              style: settingsController.getSubtitleStyle(),
            ),
            value: settingsController.isDarkMode.value,
            onChanged: (value) => settingsController.toggleDarkMode(),
            secondary: Icon(
              settingsController.isDarkMode.value
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          )),
          
          const Divider(),
          
          // Font Size Slider
          Obx(() => ListTile(
            leading: const Icon(Icons.format_size),
            title: Text(
              'Ukuran Font',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ukuran: ${settingsController.fontSize.value.toStringAsFixed(0)}',
                  style: settingsController.getSubtitleStyle(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: settingsController.fontSize.value > 10
                          ? () => settingsController.decreaseFontSize()
                          : null,
                    ),
                    Expanded(
                      child: Slider(
                        value: settingsController.fontSize.value,
                        min: 10,
                        max: 24,
                        divisions: 14,
                        label: settingsController.fontSize.value.toStringAsFixed(0),
                        onChanged: (value) => settingsController.setFontSize(value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: settingsController.fontSize.value < 24
                          ? () => settingsController.increaseFontSize()
                          : null,
                    ),
                  ],
                ),
                Text(
                  'Preview: Ini adalah contoh teks',
                  style: settingsController.getTextStyle(),
                ),
              ],
            ),
          )),
          
          // Reset Font Size
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(
              'Reset Ukuran Font',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Kembalikan ke ukuran default (14)',
              style: settingsController.getSubtitleStyle(),
            ),
            onTap: () => settingsController.resetFontSize(),
          ),
          
          const Divider(thickness: 8),
          
          // Data Section
          _buildSectionHeader('Data', Icons.storage),
          
          // Notes Count
          Obx(() => ListTile(
            leading: const Icon(Icons.note),
            title: Text(
              'Total Catatan',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Chip(
              label: Text(
                '${noteController.notesCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )),
          
          // Clear All Notes
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: Text(
              'Hapus Semua Catatan',
              style: settingsController.getTextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              'Menghapus semua catatan secara permanen',
              style: settingsController.getSubtitleStyle(),
            ),
            onTap: () => _confirmDeleteAllNotes(noteController),
          ),
          
          const Divider(thickness: 8),
          
          // Settings Section
          _buildSectionHeader('Pengaturan Aplikasi', Icons.settings),
          
          // Clear Settings
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(
              'Reset Pengaturan',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Kembalikan semua pengaturan ke default',
              style: settingsController.getSubtitleStyle(),
            ),
            onTap: () => _confirmResetSettings(settingsController),
          ),
          
          const Divider(thickness: 8),
          
          // About Section
          _buildSectionHeader('Tentang', Icons.info),
          
          ListTile(
            leading: const Icon(Icons.app_settings_alt),
            title: Text(
              'Aplikasi Catatan',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Versi 1.0.0',
              style: settingsController.getSubtitleStyle(),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(
              'Framework',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Flutter dengan GetX State Management',
              style: settingsController.getSubtitleStyle(),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.architecture),
            title: Text(
              'Arsitektur',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'MVC (Model-View-Controller)',
              style: settingsController.getSubtitleStyle(),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(
              'Database',
              style: settingsController.getTextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'SQLite untuk data lokal\nShared Preferences untuk pengaturan',
              style: settingsController.getSubtitleStyle(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Footer
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Text(
                'Made with ❤️ using Flutter',
                style: settingsController.getTextStyle(
                  color: Colors.grey,
                  sizeFactor: 0.9,
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Get.theme.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Get.theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm delete all notes
  void _confirmDeleteAllNotes(NoteController noteController) {
    if (noteController.notesCount == 0) {
      Get.snackbar(
        'Info',
        'Tidak ada catatan untuk dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah Anda yakin ingin menghapus semua catatan? Tindakan ini tidak dapat dibatalkan.',
      textConfirm: 'Ya, Hapus Semua',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Get.theme.primaryColor,
      onConfirm: () {
        noteController.deleteAllNotes();
      },
    );
  }

  /// Confirm reset settings
  void _confirmResetSettings(SettingsController settingsController) {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Reset semua pengaturan ke default?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        settingsController.clearSettings();
        Get.back();
      },
    );
  }
}
