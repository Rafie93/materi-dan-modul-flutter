import 'package:get/get.dart';
import '../views/home_view.dart';
import '../views/add_note_view.dart';
import '../views/edit_note_view.dart';
import '../views/settings_view.dart';
import '../controllers/note_controller.dart';
import '../controllers/settings_controller.dart';

/// AppRoutes - Konfigurasi routing menggunakan GetX
/// 
/// Mendefinisikan semua route dalam aplikasi dan binding controllernya
class AppRoutes {
  // Route names (constants untuk type safety)
  static const String home = '/';
  static const String addNote = '/add-note';
  static const String editNote = '/edit-note';
  static const String settings = '/settings';

  /// GetX Pages configuration
  /// 
  /// Setiap page memiliki:
  /// - name: Route path
  /// - page: Widget yang akan ditampilkan
  /// - binding: Binding untuk inject controller
  /// - transition: Animasi transisi halaman
  static final routes = [
    // Home Page
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        // Inject controllers yang diperlukan
        Get.lazyPut<NoteController>(() => NoteController());
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Add Note Page
    GetPage(
      name: addNote,
      page: () => const AddNoteView(),
      binding: BindingsBuilder(() {
        // NoteController sudah di-inject di home, jadi gunakan Get.find()
        // Tapi pastikan controller exist dengan lazyPut
        if (!Get.isRegistered<NoteController>()) {
          Get.lazyPut<NoteController>(() => NoteController());
        }
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Edit Note Page
    GetPage(
      name: editNote,
      page: () => const EditNoteView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NoteController>()) {
          Get.lazyPut<NoteController>(() => NoteController());
        }
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Settings Page
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(() => SettingsController());
        }
        if (!Get.isRegistered<NoteController>()) {
          Get.lazyPut<NoteController>(() => NoteController());
        }
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

/// AppBinding - Initial binding untuk aplikasi
/// 
/// Controller yang di-inject di sini akan tersedia di seluruh aplikasi
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Inject controllers yang diperlukan di seluruh aplikasi
    Get.lazyPut<NoteController>(() => NoteController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}

/// Helper class untuk navigasi
/// 
/// Menyediakan method-method untuk navigasi yang mudah digunakan
class NavigationHelper {
  /// Navigate to home
  static void toHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  /// Navigate to add note
  static void toAddNote() {
    Get.toNamed(AppRoutes.addNote);
  }

  /// Navigate to edit note
  /// 
  /// @param noteId - ID catatan yang akan diedit
  static void toEditNote(int noteId) {
    Get.toNamed(
      AppRoutes.editNote,
      arguments: {'noteId': noteId},
    );
  }

  /// Navigate to settings
  static void toSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  /// Go back
  static void goBack() {
    Get.back();
  }

  /// Go back with result
  static void goBackWithResult(dynamic result) {
    Get.back(result: result);
  }
}
