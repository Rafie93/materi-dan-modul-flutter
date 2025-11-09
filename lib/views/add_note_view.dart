import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../controllers/settings_controller.dart';
import '../routes/app_routes.dart';

/// AddNoteView - Halaman untuk menambah catatan baru
/// 
/// Fitur:
/// - Form input judul dan isi catatan
/// - Validasi input
/// - Simpan ke database
class AddNoteView extends StatefulWidget {
  const AddNoteView({Key? key}) : super(key: key);

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  // Controllers untuk form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  // Form key untuk validasi
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Focus nodes
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus ke title saat halaman dibuka
    Future.delayed(const Duration(milliseconds: 300), () {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();
    final SettingsController settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
        elevation: 2,
        actions: [
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
            onPressed: noteController.isLoading.value ? null : () => _saveNote(noteController),
          )),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                // Pindah ke content field saat enter
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
            
            // Save button
            Obx(() => ElevatedButton.icon(
              onPressed: noteController.isLoading.value ? null : () => _saveNote(noteController),
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
                noteController.isLoading.value ? 'Menyimpan...' : 'Simpan Catatan',
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
    );
  }

  /// Save note to database
  Future<void> _saveNote(NoteController controller) async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Save note
    bool success = await controller.addNote(
      _titleController.text,
      _contentController.text,
    );

    // Navigate back jika berhasil
    if (success) {
      NavigationHelper.goBack();
    }
  }

  /// Confirm cancel jika ada perubahan
  void _confirmCancel() {
    // Cek apakah ada input
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      NavigationHelper.goBack();
      return;
    }

    // Tampilkan konfirmasi
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Buang perubahan yang belum disimpan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              NavigationHelper.goBack(); // Navigate back
            },
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
