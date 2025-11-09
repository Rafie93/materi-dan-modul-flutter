import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SettingsController - Controller untuk mengelola pengaturan aplikasi
/// 
/// Menggunakan SharedPreferences untuk menyimpan preferensi user
/// seperti theme mode, font size, dll
class SettingsController extends GetxController {
  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Observable variables untuk settings
  final RxBool isDarkMode = false.obs;
  final RxDouble fontSize = 14.0.obs;
  final RxString sortBy = 'date'.obs; // 'date' atau 'title'

  // Keys untuk SharedPreferences
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyFontSize = 'font_size';
  static const String _keySortBy = 'sort_by';

  /// Lifecycle method yang dipanggil saat controller pertama kali dibuat
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load settings dari SharedPreferences
  Future<void> loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load dark mode setting
      isDarkMode.value = _prefs.getBool(_keyDarkMode) ?? false;

      // Load font size setting (default: 14.0)
      fontSize.value = _prefs.getDouble(_keyFontSize) ?? 14.0;

      // Load sort by setting (default: 'date')
      sortBy.value = _prefs.getString(_keySortBy) ?? 'date';

      // Terapkan theme mode
      _applyThemeMode();

      print('Settings loaded: isDarkMode=$isDarkMode, fontSize=$fontSize, sortBy=$sortBy');
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      await _prefs.setBool(_keyDarkMode, isDarkMode.value);
      _applyThemeMode();
      
      Get.snackbar(
        'Theme',
        isDarkMode.value ? 'Dark mode diaktifkan' : 'Light mode diaktifkan',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      print('Error toggling dark mode: $e');
    }
  }

  /// Set dark mode
  Future<void> setDarkMode(bool value) async {
    try {
      isDarkMode.value = value;
      await _prefs.setBool(_keyDarkMode, value);
      _applyThemeMode();
    } catch (e) {
      print('Error setting dark mode: $e');
    }
  }

  /// Apply theme mode ke aplikasi
  void _applyThemeMode() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  /// Set font size
  Future<void> setFontSize(double size) async {
    try {
      // Validasi range font size (10.0 - 24.0)
      if (size < 10.0 || size > 24.0) {
        Get.snackbar(
          'Validasi',
          'Ukuran font harus antara 10 dan 24',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      fontSize.value = size;
      await _prefs.setDouble(_keyFontSize, size);
      
      print('Font size changed to: $size');
    } catch (e) {
      print('Error setting font size: $e');
    }
  }

  /// Increase font size
  Future<void> increaseFontSize() async {
    if (fontSize.value < 24.0) {
      await setFontSize(fontSize.value + 1.0);
    }
  }

  /// Decrease font size
  Future<void> decreaseFontSize() async {
    if (fontSize.value > 10.0) {
      await setFontSize(fontSize.value - 1.0);
    }
  }

  /// Reset font size ke default (14.0)
  Future<void> resetFontSize() async {
    await setFontSize(14.0);
  }

  /// Set sort by preference
  Future<void> setSortBy(String value) async {
    try {
      // Validasi value
      if (value != 'date' && value != 'title') {
        print('Invalid sort by value: $value');
        return;
      }

      sortBy.value = value;
      await _prefs.setString(_keySortBy, value);
      
      Get.snackbar(
        'Sorting',
        value == 'date' ? 'Urutkan berdasarkan tanggal' : 'Urutkan berdasarkan judul',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      print('Error setting sort by: $e');
    }
  }

  /// Clear all settings (reset ke default)
  Future<void> clearSettings() async {
    try {
      await _prefs.clear();
      isDarkMode.value = false;
      fontSize.value = 14.0;
      sortBy.value = 'date';
      _applyThemeMode();
      
      Get.snackbar(
        'Berhasil',
        'Pengaturan direset ke default',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }

  /// Get text style berdasarkan font size setting
  TextStyle getTextStyle({
    FontWeight? fontWeight,
    Color? color,
    double? sizeFactor = 1.0,
  }) {
    return TextStyle(
      fontSize: fontSize.value * (sizeFactor ?? 1.0),
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Get title text style
  TextStyle getTitleStyle({Color? color}) {
    return getTextStyle(
      fontWeight: FontWeight.bold,
      sizeFactor: 1.2,
      color: color,
    );
  }

  /// Get subtitle text style
  TextStyle getSubtitleStyle({Color? color}) {
    return getTextStyle(
      fontWeight: FontWeight.normal,
      sizeFactor: 0.9,
      color: color,
    );
  }
}
