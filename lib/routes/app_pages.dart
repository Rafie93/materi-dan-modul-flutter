import 'package:get/get.dart';
import '../views/home_view.dart';
import '../views/detail_view.dart';
import '../controllers/home_controller.dart';
import '../controllers/detail_controller.dart';
import 'app_routes.dart';

/// Kelas untuk mendefinisikan semua pages dan bindings
/// GetPage menghubungkan route dengan view dan controller
class AppPages {
  static const initial = AppRoutes.home;
  
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DetailController>(() => DetailController());
      }),
    ),
  ];
}
