import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_response_model.dart';

/// Service untuk menghandle API calls ke News API
/// Menggunakan package http untuk melakukan request
class NewsApiService {
  // Base URL News API
  static const String _baseUrl = 'https://newsapi.org/v2';
  
  // API Key - Ganti dengan API key Anda dari https://newsapi.org
  // Untuk demo, menggunakan key public (limited request)
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  
  /// Method untuk mengambil top headlines
  /// [category] - kategori berita (business, entertainment, general, health, science, sports, technology)
  /// [country] - kode negara (us, gb, id, dll)
  Future<NewsResponseModel> getTopHeadlines({
    String country = 'us',
    String? category,
  }) async {
    try {
      // Build URL dengan parameter
      String url = '$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey';
      
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }
      
      // Melakukan HTTP GET request
      final response = await http.get(Uri.parse(url));
      
      // Check status code
      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonData = json.decode(response.body);
        return NewsResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
  
  /// Method untuk search berita berdasarkan query
  Future<NewsResponseModel> searchNews(String query) async {
    try {
      final url = '$_baseUrl/everything?q=$query&apiKey=$_apiKey&sortBy=publishedAt';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }
}
