# 📱 News App dengan GetX - Arsitektur MVC

## 📚 Materi Pembelajaran: Pemrograman Mobile Flutter

Proyek ini adalah aplikasi berita sederhana yang dibuat dengan **Flutter** menggunakan **arsitektur MVC (Model-View-Controller)** dan **GetX** sebagai state management. Aplikasi ini mengambil data dari [NewsAPI](https://newsapi.org/) dan menampilkannya dalam format yang menarik.

---

## 🎯 Tujuan Pembelajaran

Setelah mempelajari proyek ini, Anda akan memahami:

1. **Arsitektur MVC** - Cara mengorganisir project dengan pattern MVC yang simple
2. **State Management GetX** - Mengelola state aplikasi dengan reactive programming
3. **API Integration** - Mengambil data dari REST API dengan service layer
4. **Navigation** - Routing dan passing data antar halaman dengan GetX
5. **UI/UX Best Practices** - Membuat tampilan yang responsif dan user-friendly

---

## 🏗️ Struktur Project (Arsitektur MVC)

```
lib/
├── main.dart                      # Entry point aplikasi
│
├── models/                        # MODEL - Data Structure
│   ├── article_model.dart         # Model untuk Article
│   └── news_response_model.dart   # Model untuk API Response
│
├── views/                         # VIEW - User Interface
│   ├── home_view.dart             # UI Home Page
│   └── detail_view.dart           # UI Detail Page
│
├── controllers/                   # CONTROLLER - Business Logic
│   ├── home_controller.dart       # Logic Home Page
│   └── detail_controller.dart     # Logic Detail Page
│
├── services/                      # SERVICES - Network/API Layer
│   └── news_api_service.dart      # Service untuk News API
│
├── routes/                        # ROUTES - Navigation
│   ├── app_routes.dart            # Konstanta route names
│   └── app_pages.dart             # Route configuration
│
└── utils/                         # UTILITIES - Helper Classes
    ├── app_colors.dart            # Color constants
    └── date_formatter.dart        # Date formatting helper
```

---

## 📖 Penjelasan Arsitektur MVC + GetX

### Konsep MVC (Model-View-Controller)

```
┌─────────────────────────────────────────────┐
│                   VIEW                      │
│  (User Interface - views/)                 │
│  - Menampilkan data ke user                │
│  - Menerima input dari user                │
│  - Tidak ada business logic                │
└───────────────┬─────────────────────────────┘
                │
                ↓ User Action
                │
┌───────────────┴─────────────────────────────┐
│              CONTROLLER                     │
│  (Business Logic - controllers/)           │
│  - Mengatur alur aplikasi                  │
│  - Memproses input dari View               │
│  - Memanggil Model/Service                 │
│  - Update View melalui state               │
└───────────────┬─────────────────────────────┘
                │
                ↓ Get/Update Data
                │
┌───────────────┴─────────────────────────────┐
│               MODEL                         │
│  (Data Structure - models/)                │
│  - Representasi data                       │
│  - Parse JSON dari API                     │
│  - Business rules untuk data               │
└─────────────────────────────────────────────┘
                │
┌───────────────┴─────────────────────────────┐
│              SERVICE                        │
│  (Network Layer - services/)               │
│  - Komunikasi dengan API                   │
│  - HTTP requests                           │
│  - Error handling                          │
└─────────────────────────────────────────────┘
```

---

### 1. **MODEL (Data Layer)**

Model adalah representasi data dalam bentuk class. Tidak ada business logic, hanya struktur data dan parsing.

**Lokasi:** `lib/models/`

**Contoh: `article_model.dart`**

```dart
class ArticleModel {
  final String title;
  final String? description;
  
  ArticleModel({required this.title, this.description});
  
  // Factory untuk parsing JSON dari API
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? 'No Title',
      description: json['description'],
    );
  }
  
  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}
```

**💡 Tanggung Jawab Model:**
- ✅ Mendefinisikan struktur data
- ✅ Parsing JSON (fromJson)
- ✅ Serialisasi data (toJson)
- ❌ TIDAK ada business logic
- ❌ TIDAK ada API calls

---

### 2. **SERVICE (Network Layer)**

Service bertanggung jawab untuk komunikasi dengan external API atau data sources.

**Lokasi:** `lib/services/`

**Contoh: `news_api_service.dart`**

```dart
class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'YOUR_API_KEY';
  
  Future<NewsResponseModel> getTopHeadlines({
    String country = 'us',
    String? category,
  }) async {
    final url = '$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return NewsResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load news');
    }
  }
}
```

**💡 Tanggung Jawab Service:**
- ✅ HTTP requests (GET, POST, dll)
- ✅ Parse response ke Model
- ✅ Handle HTTP errors
- ❌ TIDAK ada UI logic
- ❌ TIDAK ada state management

---

### 3. **CONTROLLER (Business Logic & State)**

Controller mengelola state dan business logic menggunakan GetX. Ini adalah "otak" dari aplikasi.

**Lokasi:** `lib/controllers/`

**Contoh: `home_controller.dart`**

```dart
class HomeController extends GetxController {
  // Service instance
  final NewsApiService _apiService = NewsApiService();
  
  // Reactive state (Observable)
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchNews();  // Load data saat pertama kali
  }
  
  // Business logic method
  Future<void> fetchNews() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getTopHeadlines();
      articles.value = response.articles;  // Update state
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void changeCategory(String category) {
    // Business logic untuk ganti kategori
    selectedCategory.value = category;
    fetchNews();
  }
}
```

**💡 Tanggung Jawab Controller:**
- ✅ Manage application state
- ✅ Business logic
- ✅ Call services/APIs
- ✅ Handle user actions
- ✅ Update UI through reactive state
- ❌ TIDAK ada UI code (Widget)

---

### 4. **VIEW (User Interface)**

View adalah tampilan UI yang murni presentational. Menggunakan data dari Controller.

**Lokasi:** `lib/views/`

**Contoh: `home_view.dart`**

```dart
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News App')),
      body: Obx(() {
        // UI otomatis rebuild saat observable berubah
        if (controller.isLoading.value) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: controller.articles.length,
          itemBuilder: (context, index) {
            return ArticleCard(controller.articles[index]);
          },
        );
      }),
    );
  }
}
```

**💡 Tanggung Jawab View:**
- ✅ Menampilkan UI
- ✅ Menerima user input
- ✅ Trigger controller methods
- ✅ Observe state changes
- ❌ TIDAK ada business logic
- ❌ TIDAK ada API calls
- ❌ TIDAK ada state management

---

### 5. **ROUTES (Navigation)**

Routes mendefinisikan navigasi aplikasi dengan GetX.

**Lokasi:** `lib/routes/`

**app_routes.dart** - Konstanta route names:
```dart
class AppRoutes {
  static const String home = '/home';
  static const String detail = '/detail';
}
```

**app_pages.dart** - Route configuration:
```dart
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
  ];
}
```

**💡 Keuntungan Route Management:**
- ✅ Named routes (type-safe)
- ✅ Automatic dependency injection
- ✅ Lazy loading controllers
- ✅ Easy navigation

---

## 🔄 Flow Aplikasi MVC + GetX

### Flow Lengkap:

```
1. User membuka app
   └─> main.dart
       └─> GetMaterialApp dengan routes
           └─> Navigate ke HomeView (initial route)
               └─> HomeController dibuat (via Binding)
                   └─> onInit() dipanggil
                       └─> fetchNews()
                           └─> NewsApiService.getTopHeadlines()
                               └─> HTTP Request ke API
                                   └─> Parse JSON ke Model
                                       └─> Update articles.obs
                                           └─> Obx() auto-rebuild UI
                                               └─> User lihat list berita

2. User tap artikel
   └─> Get.toNamed('/detail', arguments: article)
       └─> DetailController dibuat
           └─> onInit(): Get article from arguments
               └─> DetailView shows data

3. User tap kategori
   └─> controller.changeCategory('technology')
       └─> Update selectedCategory
           └─> fetchNews() dengan kategori baru
               └─> UI auto-update
```

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Dapatkan API Key

1. Buka [NewsAPI.org](https://newsapi.org/)
2. Register dan dapatkan API key gratis
3. Buka file `lib/services/news_api_service.dart`
4. Replace `YOUR_API_KEY_HERE` dengan API key Anda

```dart
static const String _apiKey = 'your_actual_api_key_here';
```

### 3. Jalankan Aplikasi
```bash
flutter run
```
![alt text](https://github.com/Rafie93/materi-dan-modul-flutter/blob/build-simple-news-app-with-getx/hasil%20run.PNG?raw=true)

---

## 🎨 Fitur Aplikasi

### ✅ Home Page
- ✨ Menampilkan daftar berita terkini
- 🔄 Pull-to-refresh untuk update data
- 🏷️ Filter berita berdasarkan kategori (general, business, tech, dll)
- 🔍 Search berita
- 📱 UI responsive dengan image caching

### ✅ Detail Page
- 📄 Menampilkan detail berita lengkap
- 🖼️ Full-screen image dengan SliverAppBar
- 🔗 Link ke sumber berita
- 📤 Tombol share (placeholder)
- 🔖 Tombol bookmark (placeholder)

---

## 📦 Dependencies

```yaml
dependencies:
  get: ^4.6.6                      # State management & routing
  http: ^1.1.0                     # HTTP client untuk API calls
  intl: ^0.18.1                    # Internationalization (format tanggal)
  cached_network_image: ^3.3.0    # Caching image dari network
```

---

## 🎓 Konsep GetX dalam MVC

### 1. **Reactive State (.obs)**
```dart
// Di Controller
final count = 0.obs;           // Observable integer
final items = <String>[].obs;  // Observable list

// Update
count.value = 10;
items.add('New item');
```

### 2. **Auto-rebuild UI (Obx)**
```dart
// Di View
Obx(() => Text('Count: ${controller.count.value}'))
```

### 3. **GetView<T>**
```dart
// Automatic controller injection
class HomeView extends GetView<HomeController> {
  // Akses controller langsung dengan: controller.xxx
}
```

### 4. **Dependency Injection**
```dart
// Di app_pages.dart
binding: BindingsBuilder(() {
  Get.lazyPut(() => HomeController());  // Lazy loading
})
```

### 5. **Navigation**
```dart
// Navigate
Get.toNamed('/detail', arguments: article);

// Back
Get.back();

// Get arguments
final article = Get.arguments;
```

---

## 💡 Best Practices MVC + GetX

### ✅ DO (Lakukan)

**Model:**
- Hanya data structure dan parsing
- Gunakan factory constructor untuk fromJson
- Gunakan nullable types dengan benar

**Service:**
- Satu service per API/data source
- Return model objects
- Handle errors dengan proper exceptions

**Controller:**
- Satu controller per page/feature
- Gunakan `.obs` untuk reactive state
- Call services, jangan langsung HTTP
- Cleanup di onClose()

**View:**
- Gunakan `GetView<T>` untuk injection
- Gunakan `Obx()` untuk reactive widgets
- Extract widgets untuk readability
- JANGAN taruh business logic di view

### ❌ DON'T (Jangan)

- ❌ Jangan taruh API calls di View
- ❌ Jangan taruh business logic di Model
- ❌ Jangan taruh UI widgets di Controller
- ❌ Jangan langsung akses Service dari View
- ❌ Jangan lupa dispose resources di onClose()

---

## 📊 Perbandingan: MVC Flat vs Nested Modules

### Struktur MVC (Yang Sekarang) ✅

```
lib/
├── models/          # Semua models
├── views/           # Semua views
├── controllers/     # Semua controllers
├── services/        # Semua services
└── routes/          # Routes
```

**Keuntungan:**
- ✅ Simple dan mudah dipahami pemula
- ✅ Jelas separation by type
- ✅ Easy to navigate
- ✅ Cocok untuk small-medium apps

### Struktur Nested Modules (Alternative)

```
lib/
└── modules/
    ├── home/
    │   ├── home_controller.dart
    │   └── home_view.dart
    └── detail/
        ├── detail_controller.dart
        └── detail_view.dart
```

**Keuntungan:**
- ✅ Separation by feature
- ✅ Scalable untuk large apps
- ✅ Independent modules

---

## 🛠️ Pengembangan Lebih Lanjut

Fitur yang bisa ditambahkan:

1. **Local Storage**
   - Bookmark artikel dengan GetStorage
   - Cache data offline

2. **Search History**
   - Simpan history pencarian
   - Quick access ke pencarian sebelumnya

3. **Share Functionality**
   - Implement share dengan package share_plus

4. **Dark Mode**
   - Theme switching dengan GetX

5. **Testing**
   - Unit test untuk controllers
   - Widget test untuk views

---

## 📚 Referensi

- [GetX Documentation](https://pub.dev/packages/get)
- [Flutter Documentation](https://flutter.dev/docs)
- [News API Documentation](https://newsapi.org/docs)
- [MVC Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)

---

## 👨‍💻 Latihan

### Latihan 1: Tambah Field di Model
1. Tambahkan field `source` di ArticleModel
2. Parse dari JSON API
3. Tampilkan di UI

### Latihan 2: Buat Controller Baru
1. Buat BookmarkController
2. Implement save/delete bookmark
3. Gunakan GetStorage untuk persistence

### Latihan 3: Tambah View Baru
1. Buat BookmarkView untuk lihat saved articles
2. Connect dengan BookmarkController
3. Setup routing

---

## 📄 Lisensi

Proyek ini dibuat untuk tujuan pembelajaran.

---

## 🙋‍♂️ Pertanyaan?

Jika ada pertanyaan tentang materi ini, silakan diskusikan dengan instruktur Anda.

**Happy Learning dengan MVC + GetX! 🚀**
