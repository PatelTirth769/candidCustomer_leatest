import 'package:candid_customer/Screens/AuthScreens/LogoutScreen.dart';
import 'package:candid_customer/Screens/HelpSupportScreens/HelpSupportScreen.dart';
import 'package:candid_customer/Screens/OffersScreens/About.dart';
import 'package:candid_customer/Screens/OffersScreens/MyCreditsScreen.dart';
import 'package:candid_customer/Screens/OffersScreens/MyDealsScreen.dart';
import 'package:candid_customer/Screens/OffersScreens/ShareandReferScreen.dart';
import 'package:candid_customer/Screens/PrimeMembership/PrimeMembershipScreen.dart';
import 'package:candid_customer/Screens/ProfileScreens/ProfileScreen.dart';
import 'package:candid_customer/Screens/candidPrime/candidPrime.dart';
import 'package:candid_customer/Services/API/OffersServices/OffersConnect.dart';
import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../Screens/HomeScreen.dart';
import '../Screens/NotificationScreens/NotificationScreen.dart';
import '../Screens/OffersScreens/MyFavouritesScreen.dart';
import '../Screens/OffersScreens/OfferCategories.dart';
import '../Screens/OffersScreens/StoreListingScreen.dart';
import '../Screens/OffersScreens/OffersAvailedScreen.dart';

class BottomNavController extends GetxController {
  int selectedIndex = 0;
  String jsonStrForQR =
      "{'endDate': '2022-02-12', 'vendorId': 1, '%discount': 6, 'startDate': '2022-02-02', 'categoryId': '2', 'amountDiscount': 100}";

  List<Widget> widgetOptions = <Widget>[
    const HomeScreen(),
    OfferCategories(),
    const MyFavouritesScreen(),
    CandidPrimeScreen(),
    // const OffersAvailedScreen(),
    const ProfileScreen(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  final List<Map<String, dynamic>> navDrawerItems = [
    {'title': 'My Profile', 'screen': const ProfileScreen()},
    if (localUser!.isUserPrimeMember)
      {'title': 'Refer and Earn', 'screen': MyCreditsScreen()},
    {'title': 'Store Listing', 'screen': const StoreListingScreen()},
    {'title': 'My Activated Offers', 'screen': const MyDealsScreen()},
    {'title': 'My Favourites', 'screen': const MyFavouritesScreen()},
    //  {'title': 'Share and Refer', 'screen': ShareRefer()},
    {'title': 'Prime Membership', 'screen': const PrimeMembership()},
    {'title': 'Notifications', 'screen': const NotificationScreen()},
    {'title': 'Help', 'screen': const HelpAndSupportScreen()},
    {'title': 'About', 'screen': const AboutScreen()},
    {'title': 'Log out', 'screen': LogoutScreen()},
  ];

  changeSelectedIndex(int index) async {
    selectedIndex = index;
    update();
    if (index == 0) {
      await OffersConnect()
          .getAllOffersApi(homeScreenController.screenTypeProducts);
    }
  }

  @override
  Future<void> onInit() async {
    isar.userColls
        .filter()
        .idEqualTo((await utils.getUser() as UserColl).id!)
        .watch(fireImmediately: true)
        .listen((userList) {
      if (userList.isNotEmpty) {
        localUser = userList.first;
        update();
      }
    });
    super.onInit();
  }

  @override
  Future<void> dispose() async {
    await firebaseCrashlytics.sendUnsentReports();
    super.dispose();
  }

  @override
  Future<void> onClose() async {
    await firebaseCrashlytics.sendUnsentReports();
    super.onClose();
  }
}
