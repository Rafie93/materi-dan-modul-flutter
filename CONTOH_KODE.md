# 💻 Contoh Kode MVC + GetX

Dokumen ini berisi contoh-contoh kode praktis untuk berbagai skenario dalam aplikasi News App dengan arsitektur MVC.

---

## 📋 Table of Contents

1. [Model Examples](#1-model-examples)
2. [Service Examples](#2-service-examples)
3. [Controller Examples](#3-controller-examples)
4. [View Examples](#4-view-examples)
5. [Navigation Examples](#5-navigation-examples)
6. [State Management Patterns](#6-state-management-patterns)
7. [Error Handling](#7-error-handling)

---

## 1. Model Examples

### Basic Model dengan JSON Parsing

**File:** `lib/models/article_model.dart`

```dart
class ArticleModel {
  final int id;
  final String title;
  final String? description;  // Nullable
  final DateTime createdAt;
  
  ArticleModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });
  
  // Parsing dari JSON
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### Model dengan Nested Object

```dart
// models/article_model.dart
class ArticleModel {
  final String title;
  final Source source;  // Nested object
  final List<Tag> tags; // List of objects
  
  ArticleModel({
    required this.title,
    required this.source,
    required this.tags,
  });
  
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] as String,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>)
          .map((tag) => Tag.fromJson(tag as Map<String, dynamic>))
          .toList(),
    );
  }
}

// models/source_model.dart
class Source {
  final String id;
  final String name;
  
  Source({required this.id, required this.name});
  
  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
    );
  }
}
```

### Model dengan Validation

```dart
// models/user_model.dart
class UserModel {
  final String email;
  final String password;
  
  UserModel({required this.email, required this.password});
  
  // Validation methods
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  bool get isValidPassword {
    return password.length >= 8;
  }
  
  String? validateEmail() {
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!isValidEmail) return 'Format email tidak valid';
    return null;
  }
  
  String? validatePassword() {
    if (password.isEmpty) return 'Password tidak boleh kosong';
    if (password.length < 8) return 'Password minimal 8 karakter';
    return null;
  }
}
```

---

## 2. Service Examples

### Basic API Service

**File:** `lib/services/news_api_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';
import '../models/news_response_model.dart';

class NewsApiService {
  static const String _baseUrl = 'https://api.example.com';
  static const String _apiKey = 'YOUR_API_KEY';
  
  // GET Request
  Future<List<ArticleModel>> getArticles() async {
    try {
      final url = Uri.parse('$_baseUrl/articles?apiKey=$_apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return (jsonData['articles'] as List)
            .map((item) => ArticleModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // GET with Parameters
  Future<NewsResponseModel> getTopHeadlines({
    String country = 'us',
    String? category,
    int page = 1,
  }) async {
    final queryParams = {
      'country': country,
      'apiKey': _apiKey,
      'page': page.toString(),
    };
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    final url = Uri.parse('$_baseUrl/top-headlines').replace(
      queryParameters: queryParams,
    );
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      return NewsResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load');
    }
  }
}
```

### POST Request Service

```dart
// services/article_service.dart
class ArticleService {
  static const String _baseUrl = 'https://api.example.com';
  
  // POST - Create Article
  Future<ArticleModel> createArticle(ArticleModel article) async {
    final url = Uri.parse('$_baseUrl/articles');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(article.toJson()),
    );
    
    if (response.statusCode == 201) {
      return ArticleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create');
    }
  }
  
  // PUT - Update Article
  Future<ArticleModel> updateArticle(int id, ArticleModel article) async {
    final url = Uri.parse('$_baseUrl/articles/$id');
    
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(article.toJson()),
    );
    
    if (response.statusCode == 200) {
      return ArticleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update');
    }
  }
  
  // DELETE - Delete Article
  Future<bool> deleteArticle(int id) async {
    final url = Uri.parse('$_baseUrl/articles/$id');
    final response = await http.delete(url);
    return response.statusCode == 204;
  }
}
```

### Service dengan Timeout dan Retry

```dart
// services/api_service.dart
import 'dart:async';
import 'dart:io';

class ApiService {
  static const int _timeoutSeconds = 10;
  static const int _maxRetries = 3;
  
  Future<T> getWithRetry<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(Duration(seconds: _timeoutSeconds));
        
        if (response.statusCode == 200) {
          return fromJson(json.decode(response.body));
        } else if (response.statusCode >= 500) {
          // Server error, retry
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        } else {
          throw Exception('Error: ${response.statusCode}');
        }
      } on TimeoutException {
        retryCount++;
        if (retryCount >= _maxRetries) {
          throw Exception('Request timeout after $retryCount retries');
        }
      } on SocketException {
        throw Exception('No internet connection');
      }
    }
    
    throw Exception('Failed after $_maxRetries retries');
  }
}
```

---

## 3. Controller Examples

### Basic Controller

**File:** `lib/controllers/home_controller.dart`

```dart
import 'package:get/get.dart';
import '../models/article_model.dart';
import '../services/news_api_service.dart';

class HomeController extends GetxController {
  // Service
  final NewsApiService _apiService = NewsApiService();
  
  // Observable state
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }
  
  Future<void> fetchArticles() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _apiService.getArticles();
      articles.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    // Cleanup
    super.onClose();
  }
}
```

### Controller dengan Pagination

```dart
// controllers/article_list_controller.dart
class ArticleListController extends GetxController {
  final NewsApiService _apiService = NewsApiService();
  
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadArticles();
  }
  
  // Load first page
  Future<void> loadArticles() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final result = await _apiService.getArticles(page: 1);
      articles.value = result;
      currentPage.value = 1;
      hasMore.value = result.length >= 20;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load next page
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final result = await _apiService.getArticles(page: nextPage);
      
      if (result.isEmpty) {
        hasMore.value = false;
      } else {
        articles.addAll(result);
        currentPage.value = nextPage;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  // Pull to refresh
  Future<void> refresh() async {
    await loadArticles();
  }
}
```

### Controller dengan Search Debounce

```dart
// controllers/search_controller.dart
import 'package:get/get.dart';

class SearchController extends GetxController {
  final NewsApiService _apiService = NewsApiService();
  
  final RxList<ArticleModel> searchResults = <ArticleModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Debounce: Tunggu 500ms setelah user berhenti typing
    debounce(
      searchQuery,
      (query) {
        if (query.toString().isNotEmpty) {
          performSearch(query.toString());
        } else {
          searchResults.clear();
        }
      },
      time: Duration(milliseconds: 500),
    );
  }
  
  void updateQuery(String query) {
    searchQuery.value = query;
  }
  
  Future<void> performSearch(String query) async {
    isSearching.value = true;
    try {
      final results = await _apiService.searchArticles(query);
      searchResults.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
    } finally {
      isSearching.value = false;
    }
  }
  
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }
}
```

### Controller dengan Form Validation

```dart
// controllers/login_controller.dart
class LoginController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  
  // Computed property
  bool get isValid => emailError.isEmpty && passwordError.isEmpty;
  
  void updateEmail(String value) {
    email.value = value;
    validateEmail();
  }
  
  void updatePassword(String value) {
    password.value = value;
    validatePassword();
  }
  
  void validateEmail() {
    if (email.value.isEmpty) {
      emailError.value = 'Email tidak boleh kosong';
    } else if (!GetUtils.isEmail(email.value)) {
      emailError.value = 'Format email tidak valid';
    } else {
      emailError.value = '';
    }
  }
  
  void validatePassword() {
    if (password.value.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
    } else if (password.value.length < 8) {
      passwordError.value = 'Password minimal 8 karakter';
    } else {
      passwordError.value = '';
    }
  }
  
  Future<void> login() async {
    validateEmail();
    validatePassword();
    
    if (!isValid) return;
    
    isLoading.value = true;
    try {
      // Call login API
      await Future.delayed(Duration(seconds: 2)); // Simulate API
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## 4. View Examples

### Basic View dengan GetView

**File:** `lib/views/home_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.fetchArticles,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorWidget();
        }
        
        if (controller.articles.isEmpty) {
          return _buildEmptyWidget();
        }
        
        return _buildArticleList();
      }),
    );
  }
  
  Widget _buildArticleList() {
    return ListView.builder(
      itemCount: controller.articles.length,
      itemBuilder: (context, index) {
        final article = controller.articles[index];
        return ListTile(
          title: Text(article.title),
          subtitle: Text(article.description ?? ''),
          onTap: () {
            Get.toNamed('/detail', arguments: article);
          },
        );
      },
    );
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(controller.errorMessage.value),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchArticles,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('Tidak ada data'),
        ],
      ),
    );
  }
}
```

### View dengan Pull to Refresh

```dart
// views/article_list_view.dart
class ArticleListView extends GetView<ArticleListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Articles')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            itemCount: controller.articles.length + 1,
            itemBuilder: (context, index) {
              // Load more indicator
              if (index == controller.articles.length) {
                if (controller.isLoadingMore.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return SizedBox.shrink();
              }
              
              // Trigger load more
              if (index == controller.articles.length - 3) {
                controller.loadMore();
              }
              
              final article = controller.articles[index];
              return ArticleCard(article: article);
            },
          ),
        );
      }),
    );
  }
}
```

### View dengan Search

```dart
// views/search_view.dart
class SearchView extends GetView<SearchController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: controller.updateQuery,
        ),
        actions: [
          Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : SizedBox.shrink()
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isSearching.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.searchQuery.isEmpty) {
          return Center(child: Text('Enter search query'));
        }
        
        if (controller.searchResults.isEmpty) {
          return Center(child: Text('No results found'));
        }
        
        return ListView.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final article = controller.searchResults[index];
            return ArticleCard(article: article);
          },
        );
      }),
    );
  }
}
```

---

## 5. Navigation Examples

### Basic Navigation

```dart
// Navigate to another page
ElevatedButton(
  onPressed: () => Get.toNamed('/detail'),
  child: Text('Go to Detail'),
)

// Back
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => Get.back(),
)

// Replace (can't go back)
Get.offNamed('/home');

// Clear all and navigate
Get.offAllNamed('/login');
```

### Passing Data

```dart
// Send data
Get.toNamed('/detail', arguments: {
  'id': article.id,
  'title': article.title,
  'article': article,
});

// Receive in Controller
class DetailController extends GetxController {
  late int id;
  late String title;
  late ArticleModel article;
  
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    id = args['id'];
    title = args['title'];
    article = args['article'];
  }
}
```

### Navigation with Result

```dart
// Navigate and wait for result
final result = await Get.toNamed('/edit', arguments: article);
if (result != null && result == true) {
  controller.refresh();
}

// Return result from EditView
ElevatedButton(
  onPressed: () {
    // Save data...
    Get.back(result: true);
  },
  child: Text('Save'),
)
```

---

## 6. State Management Patterns

### Workers (Reactions)

```dart
class MyController extends GetxController {
  final count = 0.obs;
  final email = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // ever: Called every time value changes
    ever(count, (value) {
      print('Count changed to: $value');
    });
    
    // once: Called only first time
    once(count, (value) {
      print('First change: $value');
    });
    
    // debounce: Called after user stops changing
    debounce(
      email,
      (value) => print('Search: $value'),
      time: Duration(milliseconds: 500),
    );
    
    // interval: Called with interval
    interval(
      count,
      (value) => print('Interval: $value'),
      time: Duration(seconds: 1),
    );
  }
}
```

### Computed Properties

```dart
class CartController extends GetxController {
  final RxList<Item> items = <Item>[].obs;
  
  // Computed property
  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.price);
  }
  
  int get itemCount => items.length;
  
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
```

---

## 7. Error Handling

### Try-Catch Pattern

```dart
Future<void> fetchData() async {
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    final result = await apiService.fetch();
    data.value = result;
  } on TimeoutException {
    errorMessage.value = 'Request timeout';
  } on SocketException {
    errorMessage.value = 'No internet connection';
  } on FormatException {
    errorMessage.value = 'Invalid data format';
  } catch (e) {
    errorMessage.value = 'Error: $e';
  } finally {
    isLoading.value = false;
  }
}
```

### Global Error Handler

```dart
// utils/error_handler.dart
class ErrorHandler {
  static void handle(dynamic error) {
    String message;
    
    if (error is TimeoutException) {
      message = 'Request timeout';
    } else if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is FormatException) {
      message = 'Invalid data format';
    } else {
      message = 'An error occurred';
    }
    
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

// Usage
try {
  await fetchData();
} catch (e) {
  ErrorHandler.handle(e);
}
```

---

**Semoga contoh-contoh ini membantu! 🚀**
