import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/note_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/note_model.dart';
import '../routes/app_routes.dart';

/// EditNoteView - Halaman untuk mengedit catatan
/// 
/// Fitur:
/// - Load data catatan yang dipilih
/// - Form edit judul dan isi
/// - Update database
/// - Delete note
class EditNoteView extends StatefulWidget {
  const EditNoteView({Key? key}) : super(key: key);

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  // Controllers untuk form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  // Form key untuk validasi
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Focus nodes
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  
  // Note ID dari arguments
  late int noteId;
  
  // Note object
  Note? note;
  
  // Track changes
  String initialTitle = '';
  String initialContent = '';

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  /// Load note dari controller
  void _loadNote() {
    // Get note ID dari arguments
    final args = Get.arguments as Map<String, dynamic>;
    noteId = args['noteId'] as int;

    // Get note dari controller
    final NoteController noteController = Get.find<NoteController>();
    note = noteController.getNoteById(noteId);

    if (note != null) {
      // Set initial values
      initialTitle = note!.title;
      initialContent = note!.content;
      
      // Set controller values
      _titleController.text = note!.title;
      _contentController.text = note!.content;
    } else {
      // Note not found, go back
      Get.snackbar(
        'Error',
        'Catatan tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      NavigationHelper.goBack();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  /// Check if there are changes
  bool get hasChanges {
    return _titleController.text != initialTitle ||
        _contentController.text != initialContent;
  }

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();
    final SettingsController settingsController = Get.find<SettingsController>();

    if (note == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (hasChanges) {
          return await _confirmCancel() ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Catatan'),
          elevation: 2,
          actions: [
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(noteController),
            ),
            // Save button
            Obx(() => IconButton(
              icon: noteController.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: noteController.isLoading.value ? null : () => _updateNote(noteController),
            )),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info card
              Card(
                color: Get.theme.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                            'Informasi Catatan',
                            style: settingsController.getTextStyle(
                              fontWeight: FontWeight.bold,
                              sizeFactor: 0.9,
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        'Dibuat: ${_formatDateTime(note!.createdAt)}',
                        style: settingsController.getTextStyle(sizeFactor: 0.85),
                      )),
                      Obx(() => Text(
                        'Diubah: ${_formatDateTime(note!.updatedAt)}',
                        style: settingsController.getTextStyle(sizeFactor: 0.85),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title input
              Obx(() => TextFormField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Masukkan judul catatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                style: settingsController.getTitleStyle(),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  _contentFocusNode.requestFocus();
                },
              )),
              const SizedBox(height: 16),
              
              // Content input
              Obx(() => TextFormField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  hintText: 'Masukkan isi catatan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: settingsController.getTextStyle(),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 10,
                minLines: 5,
              )),
              const SizedBox(height: 24),
              
              // Update button
              Obx(() => ElevatedButton.icon(
                onPressed: noteController.isLoading.value ? null : () => _updateNote(noteController),
                icon: noteController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  noteController.isLoading.value ? 'Menyimpan...' : 'Update Catatan',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )),
              const SizedBox(height: 8),
              
              // Cancel button
              OutlinedButton.icon(
                onPressed: () => _confirmCancel(),
                icon: const Icon(Icons.cancel),
                label: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Update note in database
  Future<void> _updateNote(NoteController controller) async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Cek apakah ada perubahan
    if (!hasChanges) {
      Get.snackbar(
        'Info',
        'Tidak ada perubahan',
        snackPosition: SnackPosition.BOTTOM,
      );
      NavigationHelper.goBack();
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Update note
    bool success = await controller.updateNote(
      noteId,
      _titleController.text,
      _contentController.text,
    );

    // Navigate back jika berhasil
    if (success) {
      NavigationHelper.goBack();
    }
  }

  /// Confirm delete
  Future<void> _confirmDelete(NoteController controller) async {
    bool? confirmed = await Get.dialog<bool>(
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
    );

    if (confirmed == true) {
      bool success = await controller.deleteNote(noteId);
      if (success) {
        NavigationHelper.goBack();
      }
    }
  }

  /// Confirm cancel jika ada perubahan
  Future<bool?> _confirmCancel() async {
    if (!hasChanges) {
      return true;
    }

    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Buang perubahan yang belum disimpan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Format datetime untuk display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}
