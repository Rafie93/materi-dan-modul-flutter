import 'package:get/get.dart';
import '../models/article_model.dart';
import '../services/news_api_service.dart';

/// Controller untuk Home Page (Menggunakan konsep MVC)
/// Menggunakan GetX untuk state management
class HomeController extends GetxController {
  // Instance dari NewsApiService
  final NewsApiService _apiService = NewsApiService();
  
  // Observable list untuk menyimpan artikel
  // Rx membuat variabel menjadi reactive (observable)
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  
  // Observable untuk loading state
  final RxBool isLoading = false.obs;
  
  // Observable untuk error message
  final RxString errorMessage = ''.obs;
  
  // Selected category
  final RxString selectedCategory = 'general'.obs;
  
  // List kategori yang tersedia
  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];
  
  @override
  void onInit() {
    super.onInit();
    // Fetch news saat controller pertama kali dibuat
    fetchNews();
  }
  
  /// Method untuk fetch news dari API
  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Call API Service
      final response = await _apiService.getTopHeadlines(
        country: 'us',
        category: selectedCategory.value,
      );
      
      // Update articles list
      articles.value = response.articles;
      
    } catch (e) {
      errorMessage.value = 'Gagal memuat berita: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Method untuk refresh data
  Future<void> refreshNews() async {
    await fetchNews();
  }
  
  /// Method untuk mengubah kategori
  void changeCategory(String category) {
    selectedCategory.value = category;
    fetchNews();
  }
  
  /// Method untuk search news
  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      fetchNews();
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.searchNews(query);
      articles.value = response.articles;
      
    } catch (e) {
      errorMessage.value = 'Gagal mencari berita: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
