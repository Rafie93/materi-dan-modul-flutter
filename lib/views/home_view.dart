import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/note_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/note_model.dart';
import '../routes/app_routes.dart';

/// HomeView - Halaman utama aplikasi
/// 
/// Menampilkan daftar catatan dengan fitur:
/// - List catatan
/// - Search
/// - Add new note
/// - Edit note
/// - Delete note
/// - Navigate to settings
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get controllers menggunakan GetX dependency injection
    final NoteController noteController = Get.find<NoteController>();
    final SettingsController settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        elevation: 2,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, noteController, settingsController),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => NavigationHelper.toSettings(),
          ),
        ],
      ),
      body: Obx(() {
        // Tampilkan loading indicator
        if (noteController.isLoading.value && noteController.notes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Tampilkan empty state jika tidak ada catatan
        if (noteController.filteredNotes.isEmpty) {
          return _buildEmptyState(noteController);
        }

        // Tampilkan list catatan
        return _buildNotesList(noteController, settingsController);
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NavigationHelper.toAddNote(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(NoteController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.searchQuery.value.isEmpty
                ? Icons.note_add_outlined
                : Icons.search_off,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isEmpty
                ? 'Belum ada catatan'
                : 'Tidak ada hasil pencarian',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isEmpty
                ? 'Tap tombol + untuk menambah catatan'
                : 'Coba kata kunci lain',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Build notes list widget
  Widget _buildNotesList(NoteController noteController, SettingsController settingsController) {
    return Column(
      children: [
        // Search indicator
        Obx(() {
          if (noteController.searchQuery.value.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(8),
              color: Get.theme.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pencarian: "${noteController.searchQuery.value}" (${noteController.filteredNotesCount} hasil)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => noteController.clearSearch(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        // Notes list
        Expanded(
          child: Obx(() {
            final notes = noteController.filteredNotes;
            return RefreshIndicator(
              onRefresh: () => noteController.loadNotes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _buildNoteCard(note, noteController, settingsController);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build single note card widget
  Widget _buildNoteCard(Note note, NoteController noteController, SettingsController settingsController) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      child: Dismissible(
        key: Key(note.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          // Konfirmasi sebelum hapus
          return await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Hapus catatan ini?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          noteController.deleteNote(note.id!);
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Obx(() => Text(
            note.title,
            style: settingsController.getTitleStyle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Obx(() => Text(
                note.content.isEmpty ? 'Tidak ada isi' : note.content,
                style: settingsController.getSubtitleStyle(
                  color: note.content.isEmpty ? Colors.grey : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(height: 8),
              Obx(() => Text(
                _formatDate(note.createdAt),
                style: settingsController.getTextStyle(
                  sizeFactor: 0.8,
                  color: Colors.grey,
                ),
              )),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => NavigationHelper.toEditNote(note.id!),
        ),
      ),
    );
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context, NoteController noteController, SettingsController settingsController) {
    final TextEditingController searchController = TextEditingController(
      text: noteController.searchQuery.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Cari Catatan'),
        content: Obx(() => TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Masukkan kata kunci...',
            prefixIcon: Icon(Icons.search),
          ),
          style: settingsController.getTextStyle(),
          autofocus: true,
          onChanged: (value) => noteController.setSearchQuery(value),
        )),
        actions: [
          TextButton(
            onPressed: () {
              noteController.clearSearch();
              Get.back();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Format date untuk display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
