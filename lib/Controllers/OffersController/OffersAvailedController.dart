import 'package:candid_customer/Services/API/OffersServices/OffersConnect.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';

import '../../main.dart';

class OffersAvailedController extends GetxController {
  bool isLoading = true;
  List<OffersColl> offersList = []; // Changed from `late` to empty list
  String searchStr = '';
  String selectedFilter = '';
  String filterproductType = '';
  late String _selectedServiceType;
  String get selectedServiceType => _selectedServiceType;

  void applyFilter(String newProductType) {
    filterproductType = newProductType;
    searchStr = newProductType; // Update the selected product type
    update();
    refreshStream();
  }

  void refreshStream() {
  }

  void cancelFilter() {
    filterproductType = ''; // Reset the selected product type to cancel the filter
    update();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    OffersConnect().availedOffers();
    offersList = await isar.offersColls.where().build().findAll();
    isLoading = false;
    update();
  }

  changeSearchStr(String newSearchStr) {
    searchStr = newSearchStr;
    update();
  }
}

