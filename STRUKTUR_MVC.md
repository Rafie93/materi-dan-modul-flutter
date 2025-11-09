# 🏗️ Struktur MVC - Visual Guide

Panduan visual untuk memahami arsitektur MVC dalam project News App dengan GetX.

---

## 📁 Struktur Folder

```
lib/
├── main.dart                    # 🚀 Entry point aplikasi
│
├── models/                      # 📦 MODEL - Data Structure
│   ├── article_model.dart
│   └── news_response_model.dart
│
├── views/                       # 🎨 VIEW - User Interface
│   ├── home_view.dart
│   └── detail_view.dart
│
├── controllers/                 # 🧠 CONTROLLER - Business Logic
│   ├── home_controller.dart
│   └── detail_controller.dart
│
├── services/                    # 🌐 SERVICE - Network/API
│   └── news_api_service.dart
│
├── routes/                      # 🗺️ ROUTES - Navigation
│   ├── app_routes.dart
│   └── app_pages.dart
│
└── utils/                       # 🛠️ UTILS - Helpers
    ├── app_colors.dart
    └── date_formatter.dart
```

---

## 🎯 Diagram Arsitektur MVC

```
┌───────────────────────────────────────────────────────┐
│                   USER INTERACTION                    │
│             (Tap, Scroll, Type, etc.)                │
└─────────────────────┬─────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────┐
│                    VIEW LAYER                           │
│                  lib/views/                             │
├─────────────────────────────────────────────────────────┤
│  • home_view.dart                                       │
│  • detail_view.dart                                     │
│                                                         │
│  TANGGUNG JAWAB:                                        │
│  ✅ Display UI (Widgets)                                │
│  ✅ Receive user input                                  │
│  ✅ Trigger controller methods                          │
│  ✅ Observe state changes (Obx)                         │
│                                                         │
│  TIDAK BOLEH:                                           │
│  ❌ Business logic                                      │
│  ❌ API calls                                           │
│  ❌ State management                                    │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ Events (onTap, onChanged)
                      │
┌─────────────────────────────────────────────────────────┐
│                 CONTROLLER LAYER                        │
│               lib/controllers/                          │
├─────────────────────────────────────────────────────────┤
│  • home_controller.dart                                 │
│  • detail_controller.dart                               │
│                                                         │
│  TANGGUNG JAWAB:                                        │
│  ✅ Manage state (.obs variables)                       │
│  ✅ Business logic                                      │
│  ✅ Call services                                       │
│  ✅ Handle user actions                                 │
│  ✅ Validate data                                       │
│                                                         │
│  TIDAK BOLEH:                                           │
│  ❌ Build widgets                                       │
│  ❌ Direct HTTP calls (use Service)                     │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ Call API / Data Request
                      │
┌─────────────────────────────────────────────────────────┐
│                  SERVICE LAYER                          │
│                 lib/services/                           │
├─────────────────────────────────────────────────────────┤
│  • news_api_service.dart                                │
│                                                         │
│  TANGGUNG JAWAB:                                        │
│  ✅ HTTP requests (GET, POST, PUT, DELETE)              │
│  ✅ Parse response to Model                             │
│  ✅ Handle network errors                               │
│  ✅ Authentication headers                              │
│                                                         │
│  TIDAK BOLEH:                                           │
│  ❌ State management                                    │
│  ❌ UI logic                                            │
│  ❌ Business rules                                      │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ API Response (JSON)
                      │
┌─────────────────────────────────────────────────────────┐
│                    MODEL LAYER                          │
│                   lib/models/                           │
├─────────────────────────────────────────────────────────┤
│  • article_model.dart                                   │
│  • news_response_model.dart                             │
│                                                         │
│  TANGGUNG JAWAB:                                        │
│  ✅ Data structure definition                           │
│  ✅ JSON parsing (fromJson)                             │
│  ✅ JSON serialization (toJson)                         │
│  ✅ Data validation                                     │
│                                                         │
│  TIDAK BOLEH:                                           │
│  ❌ Business logic                                      │
│  ❌ API calls                                           │
│  ❌ UI widgets                                          │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ Data Flow Back
                      │
              [Controller Updates State]
                      │
                      ↓ State Change Notification
                      │
              [Obx() Auto Rebuild View]
                      │
                      ↓
           [User Sees Updated UI]
```

---

## 🔄 Data Flow Example

### Skenario: User Tap Refresh Button

```
1. USER ACTION
   User tap refresh button di HomeView
   
2. VIEW → CONTROLLER
   views/home_view.dart:
   ↓
   onPressed: controller.fetchNews()
   
3. CONTROLLER
   controllers/home_controller.dart:
   ↓
   isLoading.value = true  // Update state
   ↓
   Call service
   
4. CONTROLLER → SERVICE
   ↓
   await _apiService.getTopHeadlines()
   
5. SERVICE → API
   services/news_api_service.dart:
   ↓
   HTTP GET to https://newsapi.org/v2/top-headlines
   ↓
   Receive JSON response
   
6. SERVICE → MODEL
   ↓
   Parse JSON dengan NewsResponseModel.fromJson()
   ↓
   Create List<ArticleModel>
   
7. SERVICE → CONTROLLER
   ↓
   Return List<ArticleModel> ke controller
   
8. CONTROLLER
   ↓
   articles.value = result  // Update observable
   ↓
   isLoading.value = false
   
9. CONTROLLER → VIEW
   ↓
   Obx() detect state change
   ↓
   Rebuild ListView widget
   
10. VIEW
    ↓
    Display updated articles to user
```

---

## 📝 Checklist: Di Mana Menaruh Kode?

### ❓ Saya ingin parse JSON dari API
**✅ MODEL** (`lib/models/article_model.dart`)
```dart
factory ArticleModel.fromJson(Map<String, dynamic> json) {
  return ArticleModel(
    title: json['title'],
    description: json['description'],
  );
}
```

### ❓ Saya ingin fetch data dari API
**✅ SERVICE** (`lib/services/news_api_service.dart`)
```dart
Future<List<ArticleModel>> getArticles() async {
  final response = await http.get(url);
  // Parse and return
}
```

### ❓ Saya ingin manage state aplikasi
**✅ CONTROLLER** (`lib/controllers/home_controller.dart`)
```dart
final articles = <ArticleModel>[].obs;
final isLoading = false.obs;

void fetchArticles() {
  isLoading.value = true;
  // Call service
}
```

### ❓ Saya ingin build widget/UI
**✅ VIEW** (`lib/views/home_view.dart`)
```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Obx(() => ListView(...)),
  );
}
```

### ❓ Saya ingin validate form input
**✅ CONTROLLER** (`lib/controllers/login_controller.dart`)
```dart
void validateEmail() {
  if (email.isEmpty) {
    emailError.value = 'Email required';
  }
}
```

### ❓ Saya ingin setup routing
**✅ ROUTES** (`lib/routes/app_pages.dart`)
```dart
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
)
```

### ❓ Saya ingin format tanggal
**✅ UTILS** (`lib/utils/date_formatter.dart`)
```dart
static String formatDate(String isoDate) {
  // Format logic
}
```

---

## 🎯 Comparison Table

| Task | Model | Service | Controller | View |
|------|-------|---------|------------|------|
| Parse JSON | ✅ | ❌ | ❌ | ❌ |
| HTTP Request | ❌ | ✅ | ❌ | ❌ |
| State Management | ❌ | ❌ | ✅ | ❌ |
| Build Widgets | ❌ | ❌ | ❌ | ✅ |
| Business Logic | ❌ | ❌ | ✅ | ❌ |
| Validation | ❌ | ❌ | ✅ | ❌ |
| Call API | ❌ | ✅ | ❌ | ❌ |
| Display Data | ❌ | ❌ | ❌ | ✅ |
| User Input | ❌ | ❌ | ❌ | ✅ |
| Error Handling | ❌ | ✅ | ✅ | ❌ |

---

## 📚 File Relationships

### Home Page Flow

```
main.dart
  ↓
routes/app_pages.dart
  ↓ (Route: /home)
views/home_view.dart
  ↓ (uses)
controllers/home_controller.dart
  ↓ (calls)
services/news_api_service.dart
  ↓ (returns)
models/article_model.dart
  ↓ (updates)
controllers/home_controller.dart (state)
  ↓ (notifies)
views/home_view.dart (Obx rebuild)
```

### Detail Page Flow

```
views/home_view.dart
  ↓ (onTap article)
Get.toNamed('/detail', arguments: article)
  ↓
routes/app_pages.dart
  ↓ (Route: /detail)
views/detail_view.dart
  ↓ (uses)
controllers/detail_controller.dart
  ↓ (onInit: Get.arguments)
models/article_model.dart
```

---

## 🛠️ Cara Menambah Fitur Baru

### Example: Tambah Bookmark Feature

**1. Buat Model** (`lib/models/bookmark_model.dart`)
```dart
class BookmarkModel {
  final int articleId;
  final DateTime createdAt;
  
  BookmarkModel({required this.articleId, required this.createdAt});
  
  factory BookmarkModel.fromJson(Map<String, dynamic> json) { }
  Map<String, dynamic> toJson() { }
}
```

**2. Buat Service** (`lib/services/bookmark_service.dart`)
```dart
class BookmarkService {
  Future<List<BookmarkModel>> getBookmarks() async { }
  Future<bool> addBookmark(int articleId) async { }
  Future<bool> deleteBookmark(int id) async { }
}
```

**3. Buat Controller** (`lib/controllers/bookmark_controller.dart`)
```dart
class BookmarkController extends GetxController {
  final BookmarkService _service = BookmarkService();
  final bookmarks = <BookmarkModel>[].obs;
  
  Future<void> fetchBookmarks() async { }
  void addBookmark(int articleId) { }
  void deleteBookmark(int id) { }
}
```

**4. Buat View** (`lib/views/bookmark_view.dart`)
```dart
class BookmarkView extends GetView<BookmarkController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ListView.builder(...)),
    );
  }
}
```

**5. Setup Route** (`lib/routes/app_pages.dart`)
```dart
GetPage(
  name: '/bookmarks',
  page: () => BookmarkView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => BookmarkController());
  }),
)
```

**6. Add Route Name** (`lib/routes/app_routes.dart`)
```dart
class AppRoutes {
  static const String bookmarks = '/bookmarks';
}
```

---

## ✅ Best Practices Checklist

### Model ✅
- [ ] Hanya data structure
- [ ] Factory fromJson untuk parsing
- [ ] Method toJson untuk serialization
- [ ] Nullable fields menggunakan `?`
- [ ] Required fields menggunakan `required`

### Service ✅
- [ ] Satu service per API/data source
- [ ] Return model objects
- [ ] Handle HTTP errors
- [ ] Use const untuk base URL dan API keys
- [ ] Implement timeout

### Controller ✅
- [ ] Gunakan `.obs` untuk reactive state
- [ ] Call service, jangan direct HTTP
- [ ] Implement onInit() untuk initialization
- [ ] Implement onClose() untuk cleanup
- [ ] Handle errors dengan try-catch
- [ ] Show user feedback (snackbar, dialog)

### View ✅
- [ ] Extend GetView<Controller>
- [ ] Gunakan Obx() untuk reactive widgets
- [ ] Extract widgets untuk readability
- [ ] TIDAK ada business logic
- [ ] TIDAK ada API calls
- [ ] TIDAK ada state management

---

## 🚀 Quick Reference

### Import Statements

```dart
// Model
import '../models/article_model.dart';

// Service
import '../services/news_api_service.dart';

// Controller
import '../controllers/home_controller.dart';

// View
import '../views/home_view.dart';

// Routes
import '../routes/app_routes.dart';

// Utils
import '../utils/app_colors.dart';

// GetX
import 'package:get/get.dart';

// HTTP
import 'package:http/http.dart' as http;
```

### Common Patterns

**Controller Pattern:**
```dart
class XxxController extends GetxController {
  final service = XxxService();
  final data = <Model>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  
  Future<void> fetchData() async { }
  
  @override
  void onClose() {
    // cleanup
    super.onClose();
  }
}
```

**View Pattern:**
```dart
class XxxView extends GetView<XxxController> {
  const XxxView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Title')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return CircularProgressIndicator();
        }
        return ListView(...);
      }),
    );
  }
}
```

---

**Gunakan dokumen ini sebagai referensi cepat saat coding! 🎯**
