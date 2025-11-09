# 💻 Contoh Kode dan Use Cases

Dokumen ini berisi contoh-contoh kode praktis untuk berbagai skenario dalam aplikasi News App.

---

## 📋 Table of Contents

1. [Model & Data Parsing](#1-model--data-parsing)
2. [API Calls](#2-api-calls)
3. [Controller Examples](#3-controller-examples)
4. [UI Examples](#4-ui-examples)
5. [Navigation](#5-navigation)
6. [State Management](#6-state-management)
7. [Error Handling](#7-error-handling)

---

## 1. Model & Data Parsing

### Membuat Model Sederhana

```dart
class User {
  final int id;
  final String name;
  final String? email;  // Nullable
  
  User({
    required this.id,
    required this.name,
    this.email,
  });
  
  // Parsing dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
    );
  }
  
  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

### Model dengan Nested Object

```dart
class Article {
  final String title;
  final Source source;  // Nested object
  
  Article({required this.title, required this.source});
  
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
    );
  }
}

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

### Parsing List dari JSON

```dart
// JSON response:
// { "articles": [...] }

final jsonData = json.decode(response.body);
final articlesList = (jsonData['articles'] as List)
    .map((item) => Article.fromJson(item as Map<String, dynamic>))
    .toList();
```

---

## 2. API Calls

### Basic GET Request

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Article>> fetchArticles() async {
  final url = Uri.parse('https://api.example.com/articles');
  
  try {
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final articles = (jsonData['articles'] as List)
          .map((item) => Article.fromJson(item))
          .toList();
      return articles;
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
```

### GET with Query Parameters

```dart
Future<List<Article>> searchArticles(String query, {int page = 1}) async {
  final url = Uri.parse('https://api.example.com/search').replace(
    queryParameters: {
      'q': query,
      'page': page.toString(),
      'apiKey': _apiKey,
    },
  );
  
  final response = await http.get(url);
  // ... parse response
}
```

### POST Request

```dart
Future<bool> createArticle(Article article) async {
  final url = Uri.parse('https://api.example.com/articles');
  
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    },
    body: json.encode(article.toJson()),
  );
  
  return response.statusCode == 201;
}
```

### Request dengan Timeout

```dart
Future<List<Article>> fetchWithTimeout() async {
  final url = Uri.parse('https://api.example.com/articles');
  
  try {
    final response = await http
        .get(url)
        .timeout(Duration(seconds: 10));
    
    // ... process response
  } on TimeoutException {
    throw Exception('Request timeout');
  } catch (e) {
    throw Exception('Error: $e');
  }
}
```

---

## 3. Controller Examples

### Basic Controller

```dart
class ArticleController extends GetxController {
  final articles = <Article>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }
  
  Future<void> fetchArticles() async {
    isLoading.value = true;
    try {
      // API call
      final result = await _apiProvider.getArticles();
      articles.value = result;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
```

### Controller dengan Multiple States

```dart
class NewsController extends GetxController {
  // States
  final articles = <Article>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedCategory = 'general'.obs;
  final searchQuery = ''.obs;
  
  // Computed properties
  bool get hasArticles => articles.isNotEmpty;
  bool get hasError => errorMessage.isNotEmpty;
  
  // Methods
  Future<void> fetchNews() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _apiProvider.getNews(
        category: selectedCategory.value,
      );
      articles.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  void changeCategory(String category) {
    selectedCategory.value = category;
    fetchNews();
  }
  
  void clearError() {
    errorMessage.value = '';
  }
}
```

### Controller dengan Pagination

```dart
class PaginatedController extends GetxController {
  final articles = <Article>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }
  
  Future<void> fetchArticles() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final result = await _apiProvider.getArticles(page: 1);
      articles.value = result;
      currentPage.value = 1;
      hasMore.value = result.length >= 20; // Assuming 20 per page
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final result = await _apiProvider.getArticles(page: nextPage);
      
      if (result.isEmpty) {
        hasMore.value = false;
      } else {
        articles.addAll(result);
        currentPage.value = nextPage;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }
}
```

### Controller dengan Search Debounce

```dart
class SearchController extends GetxController {
  final searchResults = <Article>[].obs;
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Debounce: Tunggu 500ms setelah user berhenti mengetik
    debounce(
      searchQuery,
      (query) {
        if (query.toString().isNotEmpty) {
          performSearch(query.toString());
        }
      },
      time: Duration(milliseconds: 500),
    );
  }
  
  Future<void> performSearch(String query) async {
    isSearching.value = true;
    try {
      final results = await _apiProvider.search(query);
      searchResults.value = results;
    } finally {
      isSearching.value = false;
    }
  }
}
```

---

## 4. UI Examples

### Loading State

```dart
// Simple loading
Obx(() => controller.isLoading.value
    ? Center(child: CircularProgressIndicator())
    : ArticleList()
)

// Loading overlay
Stack(
  children: [
    ArticleList(),
    Obx(() => controller.isLoading.value
        ? Container(
            color: Colors.black54,
            child: Center(child: CircularProgressIndicator()),
          )
        : SizedBox.shrink()
    ),
  ],
)
```

### Empty State

```dart
Obx(() {
  if (controller.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
  
  if (controller.articles.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Tidak ada berita'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: controller.fetchNews,
            child: Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
  
  return ArticleList();
})
```

### Error State

```dart
Obx(() {
  if (controller.errorMessage.isNotEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.clearError();
              controller.fetchNews();
            },
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
  
  return ArticleList();
})
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: controller.fetchNews,
  child: Obx(() => ListView.builder(
    itemCount: controller.articles.length,
    itemBuilder: (context, index) {
      return ArticleCard(controller.articles[index]);
    },
  )),
)
```

### Infinite Scroll (Load More)

```dart
ListView.builder(
  itemCount: controller.articles.length + 1,
  itemBuilder: (context, index) {
    // Load more indicator di akhir list
    if (index == controller.articles.length) {
      return Obx(() => controller.isLoadingMore.value
          ? Center(child: CircularProgressIndicator())
          : SizedBox.shrink()
      );
    }
    
    // Load more saat scroll mendekati akhir
    if (index == controller.articles.length - 3) {
      controller.loadMore();
    }
    
    return ArticleCard(controller.articles[index]);
  },
)
```

---

## 5. Navigation

### Basic Navigation

```dart
// Navigate ke halaman lain
ElevatedButton(
  onPressed: () => Get.toNamed('/details'),
  child: Text('Go to Details'),
)

// Back
ElevatedButton(
  onPressed: () => Get.back(),
  child: Text('Back'),
)
```

### Passing Data

```dart
// Method 1: Arguments
Get.toNamed('/details', arguments: {
  'id': article.id,
  'title': article.title,
});

// Receive
class DetailsController extends GetxController {
  late int articleId;
  late String articleTitle;
  
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    articleId = args['id'];
    articleTitle = args['title'];
  }
}

// Method 2: Pass entire object
Get.toNamed('/details', arguments: article);

// Receive
final article = Get.arguments as Article;
```

### Navigation with Result

```dart
// Page 1: Navigate dan tunggu result
final result = await Get.toNamed('/edit', arguments: article);
if (result != null && result == true) {
  // Refresh data
  controller.fetchNews();
}

// Page 2: Return result
ElevatedButton(
  onPressed: () {
    // Save changes
    Get.back(result: true);
  },
  child: Text('Save'),
)
```

### Replace & Clear Navigation

```dart
// Replace current page (tidak bisa back)
Get.offNamed('/home');

// Clear semua dan navigate
Get.offAllNamed('/login');

// Replace sampai kondisi tertentu
Get.offNamedUntil('/home', (route) => route.isFirst);
```

---

## 6. State Management

### Reactive Variables

```dart
// Primitive types
final count = 0.obs;
final name = 'John'.obs;
final isActive = true.obs;

// Update
count.value = 10;
name.value = 'Jane';
isActive.value = false;

// Collections
final items = <String>[].obs;
items.add('New item');
items.remove('Old item');

// Custom class
final user = User().obs;
user.value = newUser;

// Update property (use update())
user.update((val) {
  val?.name = 'New Name';
});
```

### Workers (Reactions)

```dart
class MyController extends GetxController {
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // ever: Dipanggil setiap kali value berubah
    ever(count, (value) {
      print('Count changed to: $value');
    });
    
    // once: Dipanggil hanya sekali saat pertama kali berubah
    once(count, (value) {
      print('First change: $value');
    });
    
    // debounce: Dipanggil setelah user berhenti mengubah value
    debounce(
      count,
      (value) => print('Final value: $value'),
      time: Duration(milliseconds: 500),
    );
    
    // interval: Dipanggil dengan interval tertentu
    interval(
      count,
      (value) => print('Interval update: $value'),
      time: Duration(seconds: 1),
    );
  }
}
```

### GetBuilder (Alternative)

```dart
// Controller
class CounterController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update(); // Trigger rebuild
  }
  
  void incrementWithId() {
    count++;
    update(['counter']); // Update hanya builder dengan id 'counter'
  }
}

// View
GetBuilder<CounterController>(
  id: 'counter', // Optional
  builder: (controller) {
    return Text('Count: ${controller.count}');
  },
)
```

---

## 7. Error Handling

### Try-Catch Pattern

```dart
Future<void> fetchData() async {
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    final result = await apiCall();
    data.value = result;
  } on TimeoutException {
    errorMessage.value = 'Request timeout. Coba lagi.';
  } on SocketException {
    errorMessage.value = 'Tidak ada koneksi internet.';
  } on FormatException {
    errorMessage.value = 'Format data tidak valid.';
  } catch (e) {
    errorMessage.value = 'Terjadi kesalahan: $e';
  } finally {
    isLoading.value = false;
  }
}
```

### Custom Error Class

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

// Usage
throw ApiException('Server error', 500);

// Catch
try {
  // ...
} on ApiException catch (e) {
  print('API Error: ${e.message} (${e.statusCode})');
}
```

### Global Error Handler

```dart
class ErrorHandler {
  static void handle(dynamic error) {
    String message;
    
    if (error is TimeoutException) {
      message = 'Request timeout';
    } else if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is ApiException) {
      message = error.message;
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

## 🎓 Tips & Best Practices

### 1. Separation of Concerns
```dart
// ❌ Bad: Business logic di View
class BadView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await http.get(...);
        // Process result
      },
      child: Text('Fetch'),
    );
  }
}

// ✅ Good: Business logic di Controller
class GoodView extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: controller.fetchData,
      child: Text('Fetch'),
    );
  }
}
```

### 2. Const Widgets
```dart
// ✅ Use const untuk widget yang tidak berubah
const Text('Static text');
const SizedBox(height: 16);
const Icon(Icons.home);
```

### 3. Extract Widgets
```dart
// ✅ Extract complex widgets untuk readability
Widget _buildHeader() {
  return Container(/* ... */);
}

Widget _buildBody() {
  return Column(/* ... */);
}
```

---

**Semoga contoh-contoh ini membantu! 🚀**
