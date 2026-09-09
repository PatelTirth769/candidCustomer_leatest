import 'package:candid_customer/Services/API/OffersServices/OffersConnect.dart';
import 'package:get/get.dart';

class MyFavouritesController extends GetxController {
  String searchStr = '';
  String selectedFilter = '';
  String filterproductType = '';

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
  void onInit() {
    super.onInit();

    OffersConnect().getCustomerOfferWishListApi();
  }

  changeSearchStr(String newSearchStr) {
    searchStr = newSearchStr;
    update();
  }

}
