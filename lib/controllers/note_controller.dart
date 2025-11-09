import 'package:get/get.dart';
import '../models/note_model.dart';
import '../database/database_helper.dart';

/// NoteController - Controller untuk mengelola state dan business logic catatan
/// 
/// Menggunakan GetX untuk reactive state management
/// Semua operasi CRUD dilakukan melalui controller ini
class NoteController extends GetxController {
  // Database helper instance
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Observable list untuk menyimpan semua catatan
  // .obs membuat variable menjadi reactive (otomatis update UI)
  final RxList<Note> notes = <Note>[].obs;

  // Observable untuk status loading
  final RxBool isLoading = false.obs;

  // Observable untuk search query
  final RxString searchQuery = ''.obs;

  // Getter untuk filtered notes berdasarkan search query
  List<Note> get filteredNotes {
    if (searchQuery.value.isEmpty) {
      return notes;
    }
    return notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  /// Lifecycle method yang dipanggil saat controller pertama kali dibuat
  @override
  void onInit() {
    super.onInit();
    loadNotes(); // Load data saat controller diinisialisasi
  }

  /// Lifecycle method yang dipanggil saat controller akan dihapus
  @override
  void onClose() {
    super.onClose();
    // Cleanup jika diperlukan
  }

  // ==================== CRUD OPERATIONS ====================

  /// Load semua catatan dari database
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      List<Note> loadedNotes = await _dbHelper.getAllNotes();
      notes.value = loadedNotes;
      print('Loaded ${loadedNotes.length} notes');
    } catch (e) {
      print('Error loading notes: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat catatan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Menambah catatan baru
  /// 
  /// @param title - Judul catatan
  /// @param content - Isi catatan
  /// @return true jika berhasil, false jika gagal
  Future<bool> addNote(String title, String content) async {
    try {
      // Validasi input
      if (title.trim().isEmpty) {
        Get.snackbar(
          'Validasi',
          'Judul tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      isLoading.value = true;

      // Buat note baru
      Note newNote = Note(
        title: title.trim(),
        content: content.trim(),
      );

      // Insert ke database
      int id = await _dbHelper.insertNote(newNote);

      // Update note dengan id dari database
      newNote.id = id;

      // Tambahkan ke list (reactive)
      notes.insert(0, newNote); // Insert di awal list

      Get.snackbar(
        'Berhasil',
        'Catatan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('Error adding note: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan catatan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update catatan yang sudah ada
  /// 
  /// @param id - ID catatan yang akan diupdate
  /// @param title - Judul baru
  /// @param content - Isi baru
  /// @return true jika berhasil, false jika gagal
  Future<bool> updateNote(int id, String title, String content) async {
    try {
      // Validasi input
      if (title.trim().isEmpty) {
        Get.snackbar(
          'Validasi',
          'Judul tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      isLoading.value = true;

      // Cari note di list
      int index = notes.indexWhere((note) => note.id == id);
      if (index == -1) {
        throw Exception('Note not found');
      }

      // Update note
      Note updatedNote = notes[index].copyWith(
        title: title.trim(),
        content: content.trim(),
        updatedAt: DateTime.now(),
      );

      // Update di database
      await _dbHelper.updateNote(updatedNote);

      // Update di list (reactive)
      notes[index] = updatedNote;

      Get.snackbar(
        'Berhasil',
        'Catatan berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('Error updating note: $e');
      Get.snackbar(
        'Error',
        'Gagal mengupdate catatan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus catatan
  /// 
  /// @param id - ID catatan yang akan dihapus
  /// @return true jika berhasil, false jika gagal
  Future<bool> deleteNote(int id) async {
    try {
      isLoading.value = true;

      // Hapus dari database
      await _dbHelper.deleteNote(id);

      // Hapus dari list (reactive)
      notes.removeWhere((note) => note.id == id);

      Get.snackbar(
        'Berhasil',
        'Catatan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('Error deleting note: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus catatan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus semua catatan dengan konfirmasi
  Future<void> deleteAllNotes() async {
    // Konfirmasi menggunakan GetX dialog
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah Anda yakin ingin menghapus semua catatan?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () async {
        try {
          isLoading.value = true;
          await _dbHelper.deleteAllNotes();
          notes.clear();
          Get.back(); // Close dialog
          Get.snackbar(
            'Berhasil',
            'Semua catatan berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          print('Error deleting all notes: $e');
          Get.snackbar(
            'Error',
            'Gagal menghapus semua catatan',
            snackPosition: SnackPosition.BOTTOM,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  /// Set search query untuk filtering
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear search query
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Get note by ID
  Note? getNoteById(int id) {
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total notes count
  int get notesCount => notes.length;

  /// Get filtered notes count
  int get filteredNotesCount => filteredNotes.length;
}
