import 'dart:convert';
import 'package:candid_customer/Services/API/OffersServices/OffersConnect.dart';
import 'package:candid_customer/Services/Collections/City/CityColl.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:candid_customer/Services/Collections/Cat/CatsColl.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../Screens/OffersScreens/servicecatogory.dart';
import '../Sumit/Service_Search.dart';
import '../Utils/Utils.dart';

class HomeScreenController extends GetxController {
  bool arrowVisible = true;
  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  bool screenTypeProducts = false,
      isLoading = true,
      trendingNowIsLoading = false,
      showCatsName = false;
  bool showOnlyProductOffers = false;
  String selectedCity = '', appCheckToken = 'Waiting...', selectedCatID = '';
  List<String> cityList = <String>[];
  String searchStr = '';
  var selectedCategoryId = ''.obs;
  var navRailDest = <NavigationRailDestination>[];
  int selectedIndex = 0;
  ScrollController controller = ScrollController();
  final double listItemWidth = 80.0;
  List<String> selectedCategoryIDs = [];

  // ✅ Added for caching categories across app session
  List<CatsColl> cachedCategories = [];
  bool categoriesLoadedOnce = false;

  void cacheCategories(List<CatsColl> categories) {
    cachedCategories = categories;
    categoriesLoadedOnce = false;
  }

  void clearCachedCategories() {
    cachedCategories.clear();
    categoriesLoadedOnce = false;
  }

  void reorderCityList() {
    if (selectedCity.isNotEmpty && cityList.contains(selectedCity)) {
      cityList.remove(selectedCity);
      cityList.insert(0, selectedCity);
      update();
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading = true;
    update();
    cityList = [];

    isar.cityColls
        .filter()
        .cityNameIsNotEmpty()
        .build()
        .watch(fireImmediately: true)
        .listen((List<CityColl> cities) {
      cityList = [];
      for (var city in cities) {
        if (!cityList.contains(city.cityName)) {
          cityList.add(city.cityName);
        }
      }

      if (selectedCity.isNotEmpty) {
        reorderCityList();
      }

      update();
    });

    try {
      position ??= await utils.determinePosition();
      if (position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude,
          position!.longitude,
        );
        List<OffersColl> offerList = [];
        for (var offer in (await isar.offersColls
            .filter()
            .offerIDIsNotEmpty()
            .build()
            .findAll())) {
          offer.distanceFromUserInMeters = Geolocator.distanceBetween(
              position!.latitude,
              position!.longitude,
              offer.latitude,
              offer.longitude);
          offerList.add(offer);
        }
        await isar.writeTxn(() async {
          await isar.offersColls.putAll(offerList);
        });

        String? localityName = placemarks.isNotEmpty ? placemarks[0].locality : null;

        if (localityName != null && !cityList.contains(localityName)) {
          List<OffersColl> nearestOffers = await isar.offersColls
              .filter()
              .offerIDIsNotEmpty()
              .sortByDistanceFromUserInMeters()
              .build()
              .findAll();

          if (nearestOffers.isNotEmpty) {
            OffersColl nearestOffer = nearestOffers.first;
            List<Placemark> offerPlacemarks = await placemarkFromCoordinates(
              nearestOffer.latitude,
              nearestOffer.longitude,
            );
            selectedCity = (offerPlacemarks.isNotEmpty ? offerPlacemarks.first.locality : null)!;
          }
        } else {
          selectedCity = localityName!;
        }

        reorderCityList();
      }
    } catch (e) {
      debugPrint('Home controller on init catch | E | $e');
    } finally {
      selectedCity ??= (cityList.isNotEmpty ? cityList[0] : null)!;
      reorderCityList();
      isLoading = false;
      update();
    }
  }

  void toggleCatsName() {
    showCatsName = !showCatsName;
    update();
  }

  void toggleArrowVisibility(bool isVisible) {
    arrowVisible = isVisible;
    update();
  }

  void scrollToEnd(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void changeSelectedIndex(int index) {
    if (index == 1) {
      Get.to(() =>   ServiceCategory());
    } else {
      selectedIndex = index;
      update();
    }
  }

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

  void setSelectedCategoryId(String id) {
    selectedCategoryId.value = id;
  }

  changeSearchStr(String newSearchStr) {
    searchStr = newSearchStr;
    update();
  }

  changeSelectedCat(String newSelectCatID) async {
    selectedCatID = newSelectCatID;
    update();
    utils.analyticsLogSelectContent(
        contentType: Utils.categoryContentType, itemId: newSelectCatID);
  }

  updateSelectedCity(String city) {
    selectedCity = city;
    reorderCityList();
    update();
  }

  Future<void> updateScreenType(bool val) async {
    screenTypeProducts = val;
    selectedIndex = 0;
    navRailDest.clear();
    update();

    await OffersConnect().getAllOffersApi(screenTypeProducts);
  }

  Future<void> updateScreenTypeAndNavigate(bool val, Widget destination) async {
    screenTypeProducts = val;
    selectedIndex = 0;
    navRailDest.clear();
    update();

    await OffersConnect().getAllOffersApi(screenTypeProducts);
    Get.off(() => destination);
  }

  changeIsTrendingLoading(bool isLoading) {
    trendingNowIsLoading = isLoading;
    update();
  }

  updateSelectedIndex(int newSelectedIndex) {
    selectedIndex = newSelectedIndex;
    update();
  }

  moveUp() {
    controller.animateTo(controller.offset - (listItemWidth * 3),
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  moveDown() {
    controller.animateTo(controller.offset + (listItemWidth * 3),
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }
}
