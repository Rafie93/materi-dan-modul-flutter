import 'package:get/get.dart';
import '../models/article_model.dart';

/// Controller untuk Detail Page (Menggunakan konsep MVC)
class DetailController extends GetxController {
  // Article yang akan ditampilkan di detail page
  late ArticleModel article;
  
  @override
  void onInit() {
    super.onInit();
    // Mendapatkan data article yang dikirim dari halaman sebelumnya
    article = Get.arguments as ArticleModel;
  }
  
  /// Method untuk share article (bisa dikembangkan dengan package share)
  void shareArticle() {
    // TODO: Implement share functionality
    Get.snackbar(
      'Info',
      'Fitur share akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  /// Method untuk bookmark article (bisa dikembangkan dengan local storage)
  void bookmarkArticle() {
    // TODO: Implement bookmark functionality
    Get.snackbar(
      'Info',
      'Artikel berhasil di-bookmark',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
