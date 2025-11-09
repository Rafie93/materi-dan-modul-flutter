# 📱 News App dengan GetX State Management

## 📚 Materi Pembelajaran: Pemrograman Mobile Flutter

Proyek ini adalah aplikasi berita sederhana yang dibuat dengan **Flutter** dan menggunakan **GetX** sebagai state management. Aplikasi ini mengambil data dari [NewsAPI](https://newsapi.org/) dan menampilkannya dalam format yang menarik.

---

## 🎯 Tujuan Pembelajaran

Setelah mempelajari proyek ini, Anda akan memahami:

1. **Arsitektur GetX** - Cara mengorganisir project dengan pattern GetX
2. **State Management** - Mengelola state aplikasi dengan reactive programming
3. **API Integration** - Mengambil data dari REST API
4. **Navigation** - Routing dan passing data antar halaman dengan GetX
5. **UI/UX Best Practices** - Membuat tampilan yang responsif dan user-friendly

---

## 🏗️ Struktur Project

```
lib/
├── app/
│   ├── core/                    # Core utilities dan constants
│   │   ├── utils/
│   │   │   └── date_formatter.dart    # Helper untuk format tanggal
│   │   └── values/
│   │       └── app_colors.dart        # Konstanta warna aplikasi
│   │
│   ├── data/                    # Layer data (Model & Provider)
│   │   ├── models/
│   │   │   ├── article_model.dart           # Model untuk Article
│   │   │   └── news_response_model.dart     # Model untuk API Response
│   │   └── providers/
│   │       └── news_api_provider.dart       # API Service
│   │
│   ├── modules/                 # Modules (Fitur aplikasi)
│   │   ├── home/
│   │   │   ├── controllers/
│   │   │   │   └── home_controller.dart     # Controller Home Page
│   │   │   └── views/
│   │   │       └── home_view.dart           # UI Home Page
│   │   └── detail/
│   │       ├── controllers/
│   │       │   └── detail_controller.dart   # Controller Detail Page
│   │       └── views/
│   │           └── detail_view.dart         # UI Detail Page
│   │
│   └── routes/                  # Routing configuration
│       ├── app_pages.dart       # Definisi GetPages dan Bindings
│       └── app_routes.dart      # Konstanta nama route
│
└── main.dart                    # Entry point aplikasi
```

---

## 📖 Penjelasan Arsitektur GetX

### 1. **Model (Data Layer)**

Model adalah representasi data dalam bentuk class. Berisi property dan method untuk parsing JSON.

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
}
```

**💡 Konsep Penting:**
- Menggunakan `factory constructor` untuk membuat object dari JSON
- Nullable fields menggunakan `?` (contoh: `String?`)
- Memberikan default value untuk mencegah null errors

---

### 2. **Provider (API Service)**

Provider bertanggung jawab untuk komunikasi dengan external API.

**Contoh: `news_api_provider.dart`**
```dart
class NewsApiProvider {
  Future<NewsResponseModel> getTopHeadlines() async {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return NewsResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load news');
    }
  }
}
```

**💡 Konsep Penting:**
- Menggunakan `async/await` untuk operasi asynchronous
- Error handling dengan `try-catch`
- Parsing JSON response ke Model

---

### 3. **Controller (Business Logic & State Management)**

Controller mengelola state dan business logic menggunakan GetX.

**Contoh: `home_controller.dart`**
```dart
class HomeController extends GetxController {
  // Reactive variables (Observable)
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchNews();  // Load data saat controller dibuat
  }
  
  Future<void> fetchNews() async {
    isLoading.value = true;
    try {
      final response = await _apiProvider.getTopHeadlines();
      articles.value = response.articles;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
```

**💡 Konsep Penting GetX:**

#### **Reactive Variables (Observables)**
- `.obs` - Membuat variabel menjadi observable (reactive)
- `.value` - Mengakses atau mengubah nilai observable
- GetX otomatis me-rebuild UI ketika observable berubah

#### **Lifecycle Methods**
- `onInit()` - Dipanggil saat controller pertama kali dibuat
- `onReady()` - Dipanggil setelah widget di-render
- `onClose()` - Dipanggil saat controller dihancurkan

---

### 4. **View (UI Layer)**

View adalah tampilan UI yang menggunakan data dari Controller.

**Contoh: `home_view.dart`**
```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // UI otomatis rebuild ketika observable berubah
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

**💡 Konsep Penting:**

#### **GetView<T>**
- Automatic controller injection
- Akses controller dengan `controller.`
- Tidak perlu `Get.find<T>()`

#### **Obx()**
- Widget yang otomatis rebuild ketika observable berubah
- Hanya rebuild widget dalam scope `Obx()`
- Sangat efisien untuk performa

---

### 5. **Routing (Navigation)**

GetX menyediakan routing yang powerful dan mudah digunakan.

**Setup Routes: `app_pages.dart`**
```dart
class AppPages {
  static final routes = [
    GetPage(
      name: '/home',
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
  ];
}
```

**Navigasi:**
```dart
// Navigate ke halaman lain
Get.toNamed('/detail', arguments: article);

// Kembali ke halaman sebelumnya
Get.back();

// Mengambil arguments
final article = Get.arguments;
```

**💡 Konsep Penting:**

#### **Bindings**
- Lazy loading controller (hanya dibuat saat dibutuhkan)
- Otomatis dispose controller saat tidak digunakan
- Memory efficient

#### **Named Routes**
- Type-safe routing dengan konstanta
- Mudah maintenance dan refactor

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Dapatkan API Key

1. Buka [NewsAPI.org](https://newsapi.org/)
2. Register dan dapatkan API key gratis
3. Buka file `lib/app/data/providers/news_api_provider.dart`
4. Replace `YOUR_API_KEY_HERE` dengan API key Anda

```dart
static const String _apiKey = 'your_actual_api_key_here';
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

---

## 🎨 Fitur Aplikasi

### ✅ Home Page
- ✨ Menampilkan daftar berita terkini
- 🔄 Pull-to-refresh untuk update data
- 🏷️ Filter berita berdasarkan kategori
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

## 🎓 Konsep GetX yang Dipelajari

### 1. **State Management**
- ✅ Reactive Programming dengan `.obs`
- ✅ Automatic UI rebuild dengan `Obx()`
- ✅ State management tanpa boilerplate code

### 2. **Dependency Injection**
- ✅ `Get.put()` - Instant injection
- ✅ `Get.lazyPut()` - Lazy loading
- ✅ Automatic disposal

### 3. **Route Management**
- ✅ Named routes
- ✅ Passing arguments
- ✅ Navigation methods (`toNamed`, `back`, dll)
- ✅ Bindings untuk controller

### 4. **Other Features**
- ✅ Snackbar - `Get.snackbar()`
- ✅ Dialog - `Get.dialog()`
- ✅ BottomSheet - `Get.bottomSheet()`

---

## 🔄 Flow Aplikasi

```
1. main.dart
   └─> GetMaterialApp dengan routing configuration

2. User membuka app
   └─> Navigate ke Home Page (initial route)
       └─> HomeController.onInit() dipanggil
           └─> fetchNews() - API call
               └─> Update articles.obs
                   └─> Obx() rebuild UI

3. User tap artikel
   └─> Get.toNamed('/detail', arguments: article)
       └─> DetailController dibuat
           └─> Get arguments dari Get.arguments
               └─> Tampilkan detail di UI

4. User back
   └─> Get.back()
       └─> DetailController dispose otomatis
```

---

## 💡 Best Practices

### 1. **Separation of Concerns**
- Model: Data structure
- Provider: API communication
- Controller: Business logic & state
- View: UI only

### 2. **Reactive Programming**
- Gunakan `.obs` untuk data yang berubah
- Wrap widget dengan `Obx()` untuk auto-rebuild
- Hindari setState()

### 3. **Error Handling**
- Selalu gunakan try-catch untuk async operations
- Tampilkan error message ke user
- Provide retry mechanism

### 4. **Performance**
- Lazy loading controllers dengan bindings
- Image caching dengan cached_network_image
- Minimize Obx() scope untuk rebuild yang efisien

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

4. **Multiple Languages**
   - Internationalization dengan GetX

5. **Dark Mode**
   - Theme switching dengan GetX

6. **Testing**
   - Unit test untuk controllers
   - Widget test untuk views

---

## 📚 Referensi

- [GetX Documentation](https://pub.dev/packages/get)
- [Flutter Documentation](https://flutter.dev/docs)
- [News API Documentation](https://newsapi.org/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

## 👨‍💻 Latihan

### Latihan 1: Tambah Kategori Favorit
1. Tambahkan field `favoriteCategory` di HomeController
2. Save kategori favorit ke GetStorage
3. Load kategori favorit saat app dibuka

### Latihan 2: Implement Bookmark
1. Buat controller untuk manage bookmark
2. Save bookmarked articles ke local storage
3. Tambahkan halaman untuk lihat bookmarks

### Latihan 3: Dark Mode
1. Buat ThemeController dengan GetX
2. Toggle between light/dark theme
3. Save preference ke storage

---

## 📄 Lisensi

Proyek ini dibuat untuk tujuan pembelajaran.

---

## 🙋‍♂️ Pertanyaan?

Jika ada pertanyaan tentang materi ini, silakan buat issue atau diskusikan dengan instruktur Anda.

**Happy Learning! 🚀**
