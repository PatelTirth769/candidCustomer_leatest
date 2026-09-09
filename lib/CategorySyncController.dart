import 'package:get/get.dart';
import '../../Services/Collections/Cat/CatsColl.dart';

class CategorySyncController extends GetxController {
  final RxList<CatsColl> sharedServices = <CatsColl>[].obs;
  final RxList<CatsColl> sharedProducts = <CatsColl>[].obs;

  void updateServices(List<CatsColl> list) {
    sharedServices.assignAll(list);
  }

  void updateProducts(List<CatsColl> list) {
    sharedProducts.assignAll(list);
  }

  void clearAll() {
    sharedServices.clear();
    sharedProducts.clear();
  }
}
