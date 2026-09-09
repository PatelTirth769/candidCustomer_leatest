import 'dart:convert';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

List<String> productTypes = [
  'Mobile',
  'Plumber service',
  'Popular',
  'Carpentry',
  'Printing',
  'Beauty',
  'Fashion',
  'Education Institutes',
  'Building architecture',
  'Home Appliances',
  'Website Design',
  'Furniture',
];

class SearchScreenController extends GetxController {
  bool isLoading = false;
  String searchStr = '';
  String selectedFilter = '';
  String filterproductType = '';
  late String _selectedServiceType;
  String get selectedServiceType => _selectedServiceType;
  List<String> filteredItems = []; // ✅ filtered list


  // void applyFilter(String newProductType) {
  //   filterproductType = newProductType;
  //   searchStr = newProductType; // Update the selected product type
  //   update();
  //   refreshStream();
  // }

  Future<void> saveSearchTerm(String userUid, String searchTerm) async {
    final url = Uri.parse('https://candidoffers.com:3636/api/firebase/saveAndUpdateMostSearched');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userUid': userUid,
          'searchTerm': searchTerm,
        }),
      );

      if (response.statusCode == 200) {
        print('Search term saved successfully');
      } else {
        print('Failed to save search term. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving search term: $e');
    }
  }

  void refreshStream() {
    update();
  }

  // void cancelFilter() {
  //   filterproductType = ''; // Reset the selected product type to cancel the filter
  //   update();
  // }

  // void changeSearchStr(String newSearchStr) {
  //   searchStr = newSearchStr.trim().toLowerCase(); // Normalize input to lowercase
  //   update();
  // }

  void applyFilter(String newProductType) {
    filterproductType = newProductType.trim().toLowerCase(); // Normalize filter to lowercase
    searchStr = newProductType.trim().toLowerCase(); // Keep the filter and search in sync
    update();
    refreshStream();
  }

  void cancelFilter() {
    filterproductType = ''; // Reset filters
    searchStr = ''; // Clear search string
    update();
  }
  void updateSelectedServiceType(String serviceType) {
    _selectedServiceType = serviceType;
    update(); // Notify listeners that selected service type has changed
  }

  @override
  void onInit() {
    _selectedServiceType = ''; // Initialize selected service type
    super.onInit();
  }

  void changeSearchStr(String newSearchStr) {
    if (newSearchStr.isNotEmpty) {
      searchStr = newSearchStr[0].toUpperCase() + newSearchStr.substring(1).toLowerCase();
      filteredItems = productTypes
          .where((item) => item.toLowerCase().contains(searchStr))
          .toList();
    } else {
      searchStr = '';
    }
    update();
  }
}

