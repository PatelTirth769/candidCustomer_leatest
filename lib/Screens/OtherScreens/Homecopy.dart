import 'dart:math';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Screens/OffersScreens/OfferDetailsScreen.dart';
import 'package:candid_customer/Services/Collections/Cat/CatsColl.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:candid_customer/Utils/MyWidgets.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../../Controllers/SearchControllers/SearchScreenController.dart';
import '../../Services/API/OffersServices/OffersConnect.dart';
import '../OffersScreens/OfferCategories.dart';
import '../OffersScreens/productlistingscreen.dart';
import '../OffersScreens/servicelistingscreen.dart';
// import '../Controllers/SearchControllers/SearchScreenController.dart';
// import '../OffersScreens/servicelistingscreen.dart';
// import '../Services/API/OffersServices/OffersConnect.dart';
// import 'OffersScreens/OfferCategories.dart';
// import 'OffersScreens/productlistingscreen.dart';
// import 'OffersScreens/servicelistingscreen.dart';


class HomeScreen1 extends StatefulWidget {


  const HomeScreen1({Key? key});

  @override
  State<HomeScreen1> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen1> {
  List<OffersColl> nearbyOffers = [];
  bool offersFound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNearbyOffers();
    });
  }


  @override
  void dispose() {
    _fetchNearbyOffers();
    super.dispose();
  }

  Future<void> _fetchNearbyOffers() async {
    Position position;
    try {
      position = await _determinePosition();
    } catch (e) {
      debugPrint('Error getting position: $e');
      return;
    }

    List<OffersColl> offers;
    try {
      offers = await _getOffersBasedOnCity(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      return;
    }

    // Check if the widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        nearbyOffers = offers;
        offersFound = offers.isNotEmpty;
      });

      // Log details
      debugPrint('User Location: Lat=${position.latitude}, Lon=${position.longitude}');
      debugPrint('Number of Nearby Offers: ${nearbyOffers.length}');
    }
  }


  Future<List<OffersColl>> _getOffersBasedOnCity(double latitude, double longitude) async {
    // Replace this with your API call logic to get offers based on latitude and longitude
    await OffersConnect().getAllOffersApi(true); // Example call
    return await isar.offersColls
        .filter()
        .distanceFromUserInMetersLessThan(10000) // Example range: 10km
        .findAll();
  }


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;
    final String? selectedCategoryName = arguments?['selectedCategoryName'] ?? 'defaultCategory'; // Provide a default value if null
    final TextEditingController searchController = TextEditingController();
    return GetBuilder(
      init: homeScreenController,
      builder: (controller) => Scaffold(
        appBar: MyWidgets().myAppBar(),
        drawer: Drawer(
          child: Container(
            color: Colors.white, // Set the background color of the drawer to pure white
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                // Ensure this is your custom header without dividers
                MyWidgets().myDrawerHeader(),

                // Generate cards for each item
                for (var item in bottomNavController.navDrawerItems)
                  Card(
                    color: Colors.white, // Ensure card background is pure white
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Adjust margin as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                    ),
                    elevation: 2, // Optional: adds a slight shadow for visual separation
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
                      title: Text(
                        item['title'],
                        style: TextStyle(
                          fontFamily: 'Aileron',
                          // fontWeight: FontWeight.bold, // Uncomment if needed
                          fontSize: 12.sp, // Ensure this fits your design needs
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                      ), // iOS-style forward button
                      onTap: () => Navigator.of(navigatorKey.currentContext!).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => item['screen'],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        resizeToAvoidBottomInset: true,
        body: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: controller.isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                    children: [
                      Container(
                        height: 15.h,
                        width: 100.w,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.1979, 1.0],
                              colors: [Color(0xFFDC2121), Color(0xFF8F0A0A)],
                            )
                        ),
                      ),
                      //  SizedBox(height: 10.h,),
                      Center(
                        child: GetBuilder(
                          init: SearchScreenController(),
                          builder: (controller) => Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextField(
                                    controller: searchController, // Assign TextEditingController
                                    onChanged: (val) => controller.changeSearchStr(val),
                                    style: const TextStyle(color: Colors.black), // Text color
                                    decoration: InputDecoration(
                                      hintText: 'Search for product or service here', // Hint text
                                      hintStyle: const TextStyle(color: Colors.grey), // Hint text color
                                      prefixIcon: const Icon(Icons.search, color: Colors.grey), // Search icon color
                                      suffixIcon: PopupMenuTheme(
                                        data: const PopupMenuThemeData(
                                          color: Colors.white, // Set the background color of the dropdown menu to white
                                          textStyle: TextStyle(color: Colors.black), // Optional: Set the text color if needed
                                        ),
                                        child: PopupMenuButton<String>(
                                          icon: SizedBox(
                                            width: 9.w, // Adjust the width as needed
                                            height: 4.h, // Adjust the height as needed
                                            child: SvgPicture.asset(
                                              'lib/Images/Filter (2).svg', // Replace with the path to your SVG file
                                              color: Colors.black, // Set the color of the SVG icon
                                            ),
                                          ),
                                          onSelected: (value) {
                                            controller.applyFilter(value);
                                            searchController.text = value; // Update search bar text
                                          },
                                          itemBuilder: (BuildContext context) => productTypes.map((String productType) {
                                            return PopupMenuItem<String>(
                                              value: productType,
                                              child: Text(productType),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.black),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.black),
                                      ),
                                      filled: true, // Enable background color
                                      fillColor: Colors.white, // Background color
                                    ),
                                  ),
                                ),
                                SizedBox(height: 7.h),
                                if (controller.searchStr.isNotEmpty) // Only show if searchStr is not empty
                                  Center(
                                    child: GetBuilder(
                                      init: SearchScreenController(),
                                      builder: (controller) => Center(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: TextField(
                                                controller: searchController, // Assign TextEditingController
                                                onChanged: (val) => controller.changeSearchStr(val),
                                                style: const TextStyle(color: Colors.black),
                                                decoration: InputDecoration(
                                                  hintText: 'Search for product or service here',
                                                  hintStyle: const TextStyle(color: Colors.grey),
                                                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                                  suffixIcon: PopupMenuTheme(
                                                    data: const PopupMenuThemeData(
                                                      color: Colors.white,
                                                      textStyle: TextStyle(color: Colors.black),
                                                    ),
                                                    child: PopupMenuButton<String>(
                                                      icon: SizedBox(
                                                        width: 9.w,
                                                        height: 4.h,
                                                        child: SvgPicture.asset(
                                                          'lib/Images/Filter (2).svg',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      onSelected: (value) {
                                                        controller.applyFilter(value);
                                                        searchController.text = value;
                                                      },
                                                      itemBuilder: (BuildContext context) => productTypes.map((String productType) {
                                                        return PopupMenuItem<String>(
                                                          value: productType,
                                                          child: Text(productType),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: Colors.black),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: Colors.black),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(color: Colors.black),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 7.h),
                                            if (controller.searchStr.isNotEmpty) // Only show if searchStr is not empty
                                              SizedBox(
                                                height: 25.h,
                                                width: 90.w,
                                                child: StreamBuilder<List<OffersColl>>(
                                                    stream: isar.offersColls
                                                        .filter()
                                                        .selectedCityEqualTo(homeScreenController.selectedCity)
                                                        .and()
                                                        .group((q) {
                                                      final searchLower = controller.searchStr.toLowerCase();
                                                      return q
                                                          .offerNameContains(searchLower, caseSensitive: false)
                                                          .or()
                                                          .offerTypeContains(searchLower, caseSensitive: false)
                                                          .or()
                                                          .userPinCodeContains(searchLower, caseSensitive: false)
                                                          .or()
                                                          .userBusinessNameContains(searchLower, caseSensitive: false)
                                                          .or()
                                                          .productTypeContains(searchLower, caseSensitive: false)
                                                          .or()
                                                          .productTypeEqualTo(controller.filterproductType ?? "");
                                                    })
                                                        .watch(fireImmediately: true),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return const Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {
                                                        return Text('Error: ${snapshot.error}');
                                                      } else if (snapshot.hasData) {
                                                        List<OffersColl> offers = snapshot.data!;
                                                        return AnimatedSwitcher(
                                                          duration: const Duration(seconds: 1),
                                                          child: offers.isEmpty
                                                              ? Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () => _showPopup(context),
                                                                    child: Image.asset(
                                                                      'lib/Images/carousel-category-templates_0000_Layer 8 copy.jpg',
                                                                      fit: BoxFit.contain,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                              : ListView.separated(
                                                            shrinkWrap: true,
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: offers.length,
                                                            itemBuilder: (context, index) {
                                                              var ele = offers[index];
                                                              return Container(
                                                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                                                width: 90.w,
                                                                child: Card(
                                                                  elevation: 4,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(12.0),
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      ele.offerName,
                                                                                      style: const TextStyle(
                                                                                        fontSize: 18,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                      maxLines: 2,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.favorite,
                                                                                        color: Colors.red,
                                                                                        size: 20,
                                                                                      ),
                                                                                      const SizedBox(width: 4),
                                                                                      Text(
                                                                                        '${ele.likesCount}', // Display the likes count here
                                                                                        style: const TextStyle(
                                                                                          color: Colors.red,
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 8),
                                                                              Text(
                                                                                ele.offerAddress,
                                                                                style: TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: Colors.grey[600],
                                                                                ),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              const Spacer(),
                                                                              ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => OfferDetailsScreen(offerID: ele.offerID),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.black,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                child: const Text(
                                                                                  'VIEW OFFERS',
                                                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 8), // Add some spacing
                                                                              Row(
                                                                                children: [
                                                                                  ...List.generate(5, (index) {
                                                                                    double averageRating = ele.averageRating; // No need to divide by count, as it's already average
                                                                                    return Icon(
                                                                                      index < averageRating.round() ? Icons.star : Icons.star_border,
                                                                                      color: Colors.amber,
                                                                                      size: 20,
                                                                                    );
                                                                                  }),
                                                                                  const SizedBox(width: 8),
                                                                                  Text(
                                                                                    ele.ratingCount > 0 ? '${ele.averageRating.toStringAsFixed(1)} / 5' : 'No ratings',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Colors.grey,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: ClipRRect(
                                                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                                                          child: ele.offerImages.isNotEmpty
                                                                              ? CachedNetworkImage(
                                                                            imageUrl: ele.offerImages.first,
                                                                            fit: BoxFit.cover,
                                                                            height: double.infinity,
                                                                          )
                                                                              : Container(
                                                                            color: Colors.grey,
                                                                            child: const Center(
                                                                              child: Text('No Image'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            separatorBuilder: (context, index) {
                                                              return const SizedBox(width: 4);
                                                            },
                                                          ),
                                                        );

                                                      } else {
                                                        print('No data found for query: ${controller.searchStr}');
                                                        return const Text('No data found!');
                                                      }
                                                    }
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
                SizedBox(height: 1.h,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        elevation: 4, // Adjust the elevation for shadow effect
                        color: const Color(0xFF2C3E6C), // Background color of the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'PRODUCT CATEGORIES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              height: 1, // Adjusted to 1 for better line height
                              letterSpacing: 0.02,
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 0.0), // Adjust the right padding as needed
                      //   child: SizedBox(
                      //     width: 25.w, // Adjust as needed
                      //     height: 5.h,  // Adjust as needed
                      //     child: MyWidgets().getLargeButton(
                      //       title: 'Browse All',
                      //       onPress: () => bottomNavController.changeSelectedIndex(1),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h,),
                Stack(
                  textDirection: TextDirection.rtl,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.showCatsName = !controller.showCatsName;
                        controller.update();
                      },
                      child: AnimatedContainer(
                        height: controller.showCatsName ? 18.h : 14.h,
                        width: 100.w,
                        duration: const Duration(milliseconds: 300),
                        child: StreamBuilder(
                          stream: isar.catsColls
                              .filter()
                              .catNameIsNotEmpty()
                              .catTypeEqualTo('product')
                              .not()
                              .catNameEqualTo('Popular')
                              .build()
                              .watch(fireImmediately: true),
                          builder: (context, snapshot) {
                            List<CatsColl> catsList = [];
                            if (snapshot.data != null && !snapshot.hasError) {
                              catsList = snapshot.data as List<CatsColl>;

                              // Debugging info
                              print('Cats List Length: ${catsList.length}');

                              if (controller.selectedCatID.isEmpty && catsList.isNotEmpty) {
                                Future.delayed(Duration.zero, () {
                                  controller.selectedCatID = catsList.first.catID;
                                  controller.update();
                                });
                              }
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }

                            // Limit items to 10 or less and add one item for "View More"
                            int itemCount = catsList.length > 10 ? 11 : catsList.length;

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: catsList.isEmpty
                                  ? const Text('Empty List')
                                  : ListView.separated(
                                controller: controller.controller,
                                shrinkWrap: true,
                                itemCount: itemCount,
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  // Show "View More" after 10 items
                                  if (index == 10 && catsList.length > 10) {
                                    return InkWell(
                                      onTap: () {
                                        print('View More tapped');
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => OfferCategories(),
                                        ));
                                      },
                                      child: SizedBox(
                                        width: controller.listItemWidth,
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.more_horiz, size: 30),
                                            SizedBox(height: 5),
                                            Text('View More', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  // Show the category item if index is less than 10
                                  var cat = catsList[index];
                                  return InkWell(
                                    onTap: () {
                                      if (controller.selectedCatID == cat.catID) {
                                        // Deselect if the same item is tapped
                                        controller.selectedCatID = '';
                                      } else {
                                        // Select the new item
                                        controller.selectedCatID = cat.catID;
                                      }
                                      controller.update();
                                    },
                                    child: SizedBox(
                                      width: controller.listItemWidth,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              border: cat.catID == controller.selectedCatID
                                                  ? Border.all(color: const Color(0xFFDB2020), width: 2.0)
                                                  : null,
                                            ),
                                            child: SvgPicture.network(
                                              cat.catImg,
                                              fit: BoxFit.cover,
                                              placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Flexible(
                                            child: SizedBox(
                                              height: 15.h, // Adjust height as needed
                                              child: SingleChildScrollView( // Allows scrolling if text overflows
                                                child: Text(
                                                  cat.catName,
                                                  style:  TextStyle(
                                                    fontSize: 8.sp,
                                                    fontWeight: FontWeight.bold,),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                const VerticalDivider(width: 5, color: Colors.transparent),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h,),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Featured Product Offers ',
                    textScaleFactor: 1.5,
                    style: TextStyle(
                      fontSize: 10.sp, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      // You can add more styling properties here such as fontFamily, letterSpacing, etc.
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: StreamBuilder(
                      stream: isar.offersColls
                          .filter()
                          .offerNameIsNotEmpty()
                          .selectedCityEqualTo(controller.selectedCity)
                          .offerTypeEqualTo('product')
                          .sortByDistanceFromUserInMeters()
                          .build()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        List<OffersColl>? offers = [];
                        if (snapshot.hasData) {
                          offers = snapshot.data;
                        }
                        return AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: !snapshot.hasData || controller.trendingNowIsLoading
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : offers!.isEmpty
                              ? Center(
                            child:  Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => _showPopup(context), // Specify your desired height
                                  child: Image.asset(
                                    'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
                                    fit: BoxFit.contain, // Use BoxFit to control how the image should be inscribed into the box
                                  ),
                                )
                            ),
                          )
                              : SizedBox(
                            height: 28.h,
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: offers.length > 10 ? 11 : offers.length,
                              itemBuilder: (context, index) {
                                if (index == 10) {
                                  // View More item
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ServiceListing(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 90.w,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: const Color(0xFFDB2020),
                                          child: const Center(
                                            child: Text(
                                              'View More',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                var ele = offers![index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 90.w,
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        ele.offerName,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${ele.likesCount}', // Display the likes count here
                                                          style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  ele.offerAddress,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const Spacer(),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => OfferDetailsScreen(offerID: ele.offerID),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.black,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'VIEW OFFERS',
                                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                                  ),
                                                ),
                                                const SizedBox(height: 8), // Add some spacing
                                                Row(
                                                  children: [
                                                    ...List.generate(5, (index) {
                                                      double averageRating = ele.ratingCount > 0
                                                          ? ele.cumulativeRatingSum / ele.ratingCount
                                                          : 0.0; // Handle zero or null values

                                                      return Icon(
                                                        index < averageRating.round()
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 20,
                                                      );
                                                    }),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      ele.ratingCount > 0
                                                          ? '${(ele.cumulativeRatingSum / ele.ratingCount).toStringAsFixed(1)} / 5'
                                                          : 'No ratings',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                            child: ele.offerImages.isNotEmpty
                                                ? CachedNetworkImage(
                                              imageUrl: ele.offerImages.first,
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                            )
                                                : Container(
                                              color: Colors.grey,
                                              child: const Center(
                                                child: Text('No Image'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 4);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20),
                //   child: Text(
                //     'Featured Products',
                //     textScaleFactor: 1.5,
                //     style: TextStyle(
                //       fontSize: 10.sp, // Adjust the font size as needed
                //       fontWeight: FontWeight.bold,
                //       color: Colors.black,
                //       // You can add more styling properties here such as fontFamily, letterSpacing, etc.
                //     ),
                //   ),
                // ),
                // SizedBox(height: 2.h,),
                // Container(
                //   height: 25.h,
                //   padding: const EdgeInsets.only(left: 8),
                //   child: StreamBuilder<List<OffersColl>>(
                //     stream: isar.offersColls
                //         .filter()
                //         .offerNameIsNotEmpty()
                //         .selectedCityEqualTo(controller.selectedCity)
                //         .offerTypeEqualTo('product') // Filter only product offers
                //         .sortByDistanceFromUserInMeters()
                //         .build()
                //         .watch(fireImmediately: true),
                //     builder: (context, snapshot) {
                //       List<OffersColl>? offers = [];
                //       if (snapshot.hasData) {
                //         offers = snapshot.data;
                //       }
                //       return AnimatedSwitcher(
                //         duration: const Duration(seconds: 1),
                //         child: !snapshot.hasData || controller.trendingNowIsLoading
                //             ? const Center(
                //           child: CircularProgressIndicator(),
                //         )
                //             : offers!.isEmpty
                //             ? const Center(
                //           child: Card(
                //             color: Colors.black,
                //             child: Padding(
                //               padding: EdgeInsets.all(8.0),
                //               child: Text(
                //                 'No offers found',
                //                 textScaleFactor: 1.2,
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         )
                //             : ListView.separated(
                //           shrinkWrap: true,
                //           scrollDirection: Axis.horizontal,
                //           itemCount: offers.length,
                //           separatorBuilder: (BuildContext context, int index) {
                //             return const SizedBox(width: 10); // Adjust spacing between items
                //           },
                //           itemBuilder: (context, index) {
                //             OffersColl offer = offers![index];
                //             return buildItem(
                //               id: offer.offerID,
                //               isFavorite: offer.isInWishList,
                //               title: offer.productName,
                //               discount: '${offer.discountNo} %',
                //               offerImage: offer.offerImages.first,
                //               context: context,
                //             );
                //           },
                //         ),
                //       );
                //     },
                //   ),
                // ),
                SizedBox(height: 1.h,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        elevation: 4, // Adjust the elevation for shadow effect
                        color: const Color(0xFF2C3E6C), // Background color of the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'SERVICE CATEGORIES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              height: 1, // Adjusted to 1 for better line height
                              letterSpacing: 0.02,
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 0.0), // Adjust the right padding as needed
                      //   child: SizedBox(
                      //     width: 25.w, // Adjust as needed
                      //     height: 5.h,  // Adjust as needed
                      //     child: MyWidgets().getLargeButton(
                      //       title: 'Browse All',
                      //       onPress: () => bottomNavController.changeSelectedIndex(1),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h,),
                Stack(
                  textDirection: TextDirection.rtl,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.showCatsName = !controller.showCatsName;
                        controller.update();
                      },
                      child: AnimatedContainer(
                        height: controller.showCatsName ? 18.h : 14.h,
                        width: 100.w,
                        duration: const Duration(milliseconds: 300),
                        child: StreamBuilder(
                          stream: isar.catsColls
                              .filter()
                              .catNameIsNotEmpty()
                              .catTypeEqualTo('service')
                              .not()
                              .catNameEqualTo('Popular')
                              .build()
                              .watch(fireImmediately: true),
                          builder: (context, snapshot) {
                            List<CatsColl> catsList = [];
                            if (snapshot.data != null && !snapshot.hasError) {
                              catsList = snapshot.data as List<CatsColl>;

                              // Debugging info
                              print('Cats List Length: ${catsList.length}');

                              if (controller.selectedCatID.isEmpty && catsList.isNotEmpty) {
                                Future.delayed(Duration.zero, () {
                                  controller.selectedCatID = catsList.first.catID;
                                  controller.update();
                                });
                              }
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }

                            // Limit items to 10 or less and add one item for "View More"
                            int itemCount = catsList.length > 10 ? 11 : catsList.length;

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: catsList.isEmpty
                                  ? const Text('Empty List')
                                  : ListView.separated(
                                controller: controller.controller,
                                shrinkWrap: true,
                                itemCount: itemCount,
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  // Show "View More" after 10 items
                                  if (index == 10 && catsList.length > 10) {
                                    return InkWell(
                                      onTap: () {
                                        print('View More tapped');
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => OfferCategories(),
                                        ));
                                      },
                                      child: SizedBox(
                                        width: controller.listItemWidth,
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.more_horiz, size: 30),
                                            SizedBox(height: 5),
                                            Text('View More', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  // Show the category item if index is less than 10
                                  var cat = catsList[index];
                                  return InkWell(
                                    onTap: () {
                                      if (controller.selectedCatID == cat.catID) {
                                        // Deselect if the same item is tapped
                                        controller.selectedCatID = '';
                                      } else {
                                        // Select the new item
                                        controller.selectedCatID = cat.catID;
                                      }
                                      controller.update();
                                    },
                                    child: SizedBox(
                                      width: controller.listItemWidth,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              border: cat.catID == controller.selectedCatID
                                                  ? Border.all(color: const Color(0xFFDB2020), width: 2.0)
                                                  : null,
                                            ),
                                            child: SvgPicture.network(
                                              cat.catImg,
                                              fit: BoxFit.contain,
                                              placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Flexible(
                                            child: SizedBox(
                                              height: 15.h, // Adjust height as needed
                                              child: SingleChildScrollView( // Allows scrolling if text overflows
                                                child: Text(
                                                  cat.catName,
                                                  style:  TextStyle(
                                                    fontSize: 8.sp,
                                                    fontWeight: FontWeight.bold,),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                const VerticalDivider(width: 5, color: Colors.transparent),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Featured Service Offers ',
                    textScaleFactor: 1.5,
                    style: TextStyle(
                      fontSize: 10.sp, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      // You can add more styling properties here such as fontFamily, letterSpacing, etc.
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                Container(
                  height: 25.h,
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StreamBuilder(
                              stream: isar.offersColls
                                  .filter()
                                  .offerNameIsNotEmpty()
                                  .selectedCityEqualTo(controller.selectedCity)
                                  .offerTypeEqualTo('service')
                                  .sortByDistanceFromUserInMeters()
                                  .build()
                                  .watch(fireImmediately: true),
                              builder: (context, snapshot) {
                                List<OffersColl>? offers = [];
                                if (snapshot.hasData) {
                                  offers = snapshot.data;
                                }
                                return AnimatedSwitcher(
                                  duration: const Duration(seconds: 1),
                                  child: !snapshot.hasData || controller.trendingNowIsLoading
                                      ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                      : offers!.isEmpty
                                      ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _showPopup(context),
                                            child: Image.asset(
                                              'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      : ListView.separated(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: offers.length > 10 ? 11 : offers.length,
                                    itemBuilder: (context, index) {
                                      if (index == 10) {
                                        // View More item
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const storelisting(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: 90.w,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                color: const Color(0xFFDB2020),
                                                child: const Center(
                                                  child: Text(
                                                    'View More',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      var ele = offers![index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 90.w,
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              ele.offerName,
                                                              style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.favorite,
                                                                color: Colors.red,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                '${ele.likesCount}', // Display the likes count here
                                                                style: const TextStyle(
                                                                  color: Colors.red,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        ele.offerAddress,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[600],
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const Spacer(),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => OfferDetailsScreen(offerID: ele.offerID),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.black,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'VIEW OFFERS',
                                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8), // Add some spacing
                                                      Row(
                                                        children: [
                                                          ...List.generate(5, (index) {
                                                            double averageRating = ele.ratingCount > 0
                                                                ? ele.cumulativeRatingSum / ele.ratingCount
                                                                : 0.0; // Handle zero or null values

                                                            return Icon(
                                                              index < averageRating.round()
                                                                  ? Icons.star
                                                                  : Icons.star_border,
                                                              color: Colors.amber,
                                                              size: 20,
                                                            );
                                                          }),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            ele.ratingCount > 0
                                                                ? '${(ele.cumulativeRatingSum / ele.ratingCount).toStringAsFixed(1)} / 5'
                                                                : 'No ratings',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                                  child: CachedNetworkImage(
                                                    imageUrl: ele.offerImages.first,
                                                    fit: BoxFit.cover,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );

                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(width: 4);
                                    },
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h,),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Deals Nearby',
                    textScaleFactor: 1.5,
                    style: TextStyle(
                      fontSize: 10.sp, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      // You can add more styling properties here such as fontFamily, letterSpacing, etc.
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Space on the sides
                    child: Row(
                      children: offersFound
                          ? nearbyOffers.map((offer) {
                        // Generate a unique color for each card
                        final color = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

                        // Determine whether to show distance in KM or meters
                        String distanceText;
                        if (offer.distanceFromUserInMeters < 1000) {
                          // Show distance in meters
                          distanceText = 'Within ${offer.distanceFromUserInMeters.toStringAsFixed(0)} Meters';
                        } else {
                          // Convert distance to kilometers and show with one decimal place
                          double distanceInKm = offer.distanceFromUserInMeters / 1000;
                          distanceText = 'Within ${distanceInKm.toStringAsFixed(1)} KM';
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
                              ),
                            );
                          },
                          child: buildLocationCard(
                            offer.offerAddress,
                            distanceText,
                            color,
                          ),
                        );
                      }).toList()
                          : [buildLocationCard('No Offers Found', 'Check back later', Colors.grey)],
                    ),
                  ),
                ),


                // Padding(
                //   padding: const EdgeInsets.only(left: 20),
                //   child: Text(
                //     'Featured Services',
                //     textScaleFactor: 1.5,
                //     style: TextStyle(
                //       fontSize: 10.sp, // Adjust the font size as needed
                //       fontWeight: FontWeight.bold,
                //       color: Colors.black,
                //       // You can add more styling properties here such as fontFamily, letterSpacing, etc.
                //     ),
                //   ),
                // ),
                // SizedBox(height: 2.h,),
                // Container(
                //   height: 25.h,
                //   padding: const EdgeInsets.only(left: 8),
                //   child: StreamBuilder<List<OffersColl>>(
                //     stream: isar.offersColls
                //         .filter()
                //         .offerNameIsNotEmpty()
                //         .selectedCityEqualTo(controller.selectedCity)
                //         .offerTypeEqualTo('service') // Filter only product offers
                //         .sortByDistanceFromUserInMeters()
                //         .build()
                //         .watch(fireImmediately: true),
                //     builder: (context, snapshot) {
                //       List<OffersColl>? offers = [];
                //       if (snapshot.hasData) {
                //         offers = snapshot.data;
                //       }
                //       return AnimatedSwitcher(
                //         duration: const Duration(seconds: 1),
                //         child: !snapshot.hasData || controller.trendingNowIsLoading
                //             ? const Center(
                //           child: CircularProgressIndicator(),
                //         )
                //             : offers!.isEmpty
                //             ? const Center(
                //           child: Card(
                //             color: Colors.black,
                //             child: Padding(
                //               padding: EdgeInsets.all(8.0),
                //               child: Text(
                //                 'No offers found',
                //                 textScaleFactor: 1.2,
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         )
                //             : ListView.separated(
                //           shrinkWrap: true,
                //           scrollDirection: Axis.horizontal,
                //           itemCount: offers.length,
                //           separatorBuilder: (BuildContext context, int index) {
                //             return const SizedBox(width: 10); // Adjust spacing between items
                //           },
                //           itemBuilder: (context, index) {
                //             OffersColl offer = offers![index];
                //             return buildItem(
                //               id: offer.offerID,
                //               isFavorite: offer.isInWishList,
                //               title: offer.productName,
                //               discount: '${offer.discountNo} %',
                //               offerImage: offer.offerImages.first,
                //               context: context,
                //             );
                //           },
                //         ),
                //       );
                //     },
                //   ),
                // ),
                SizedBox(height: 5.h,),
                // StreamBuilder(
                //   stream: isar.availedOffersColls
                //       .filter()
                //       .offerNameIsNotEmpty()
                //       .build()
                //       .watch(fireImmediately: true),
                //   builder: (context, snapshot) {
                //     List<AvailedOffersColl> availedOffersList =
                //         snapshot.data ?? [];
                //     return AnimatedSwitcher(
                //       duration: const Duration(seconds: 1),
                //       child: snapshot.hasError
                //           ? const Center(
                //               child: Text('Something is wrong!'))
                //           : !snapshot.hasData
                //               ? const Center(child: Text('No data'))
                //               : snapshot.hasData &&
                //                       availedOffersList.isNotEmpty
                //                   ? Column(
                //                       children: [
                //                         const Padding(
                //                           padding: EdgeInsets.only(
                //                               left: 8.0, top: 8.0),
                //                           child: Text(
                //                             'Grab Before Its gone',
                //                             textScaleFactor: 1.5,
                //                           ),
                //                         ),
                //                         GridView.builder(
                //                           shrinkWrap: true,
                //                           itemCount:
                //                               availedOffersList.length,
                //                           physics:
                //                               const NeverScrollableScrollPhysics(),
                //                           gridDelegate:
                //                               const SliverGridDelegateWithFixedCrossAxisCount(
                //                                   crossAxisCount: 3,
                //                                   childAspectRatio:
                //                                       2 / 3),
                //                           itemBuilder: (context, index) {
                //                             // var ele = controller
                //                             //     .grabBeforeItGoneList[index];
                //                             AvailedOffersColl offer =
                //                                 availedOffersList[index];
                //                             return OpenContainer(
                //                               closedColor: Colors.white,
                //                               middleColor: Colors.pink,
                //                               openColor: Colors.white,
                //                               clipBehavior: Clip
                //                                   .antiAliasWithSaveLayer,
                //                               closedElevation: 10,
                //                               transitionDuration:
                //                                   const Duration(
                //                                       seconds: 1),
                //                               transitionType:
                //                                   ContainerTransitionType
                //                                       .fadeThrough,
                //                               closedBuilder:
                //                                   (context, action) {
                //                                 return SizedBox(
                //                                   height: 20.h,
                //                                   child: Card(
                //                                     child: Column(
                //                                       children: [
                //                                         SizedBox(
                //                                             height: 15.h,
                //                                             child: CachedNetworkImage(
                //                                                 imageUrl:
                //                                                     offer
                //                                                         .offerImg)),
                //                                         Container(
                //                                           color: controller.screenTypeProducts
                //                                               ? Colors
                //                                                   .blue
                //                                                   .shade900
                //                                               : Colors
                //                                                   .pink,
                //                                           width: 100.w,
                //                                           child: Center(
                //                                             child: Text(
                //                                                 'min ${offer.discountNo}% off',
                //                                                 textScaleFactor:
                //                                                     1.1,
                //                                                 style: const TextStyle(
                //                                                     color:
                //                                                         Colors.white)),
                //                                           ),
                //                                         ),
                //                                         Text(offer
                //                                             .productName)
                //                                       ],
                //                                     ),
                //                                   ),
                //                                 );
                //                               },
                //                               openBuilder:
                //                                   (context, action) {
                //                                 return FutureBuilder(
                //                                   future: isar.offersColls
                //                                       .where()
                //                                       .offerIDEqualTo(
                //                                           offer.offerID)
                //                                       .build()
                //                                       .findFirst(),
                //                                   builder: (context,
                //                                       snapshot) {
                //                                     if (snapshot.connectionState ==
                //                                             ConnectionState
                //                                                 .done &&
                //                                         snapshot
                //                                             .hasData) {
                //                                       return OfferEnCashScreen(
                //                                           ele: snapshot
                //                                               .data!,
                //                                           shouldEnCash:
                //                                               false,
                //                                           orderID: offer
                //                                               .availedOfferID);
                //                                     }
                //                                     return const Center(
                //                                         child:
                //                                             CircularProgressIndicator());
                //                                   },
                //                                 );
                //                               },
                //                             );
                //                           },
                //                         )
                //                       ],
                //                     )
                //                   : availedOffersList.isEmpty
                //                       ? const SizedBox()
                //                       : const Center(
                //                           child:
                //                               CircularProgressIndicator(),
                //                         ),
                //     );
                //   },
                // )
              ],
            ),
          ),
        ),

      ),
    );
  }
}

Widget buildLocationCard(String title, String subtitle, Color color) {
  return Padding(
    padding: const EdgeInsets.only(right: 16.0), // Space between cards
    child: Column(
      children: [
        Container(
          width: 32.w, // Adjust width as needed
          height: 14.h, // Adjust height as needed
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.0, // Adjust font size as needed
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0), // Space between card and subtitle
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.0, // Adjust font size as needed
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  return await Geolocator.getCurrentPosition();
}




String _getSearchSubstring(String searchStr) {
  if (searchStr.length >= 2) {
    return searchStr.substring(0, 2);
  } else {
    return searchStr;
  }
}

void _showPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Demo Offer'),
        content: const Text(
          'This is the demo  offer. If we have offers nearby or in your city, real Offers will show in real time. Thank you from Candid Offer!',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// AnimatedSwitcher(
//   duration: const Duration(seconds: 1),
//   child: controller.showCatsName
//       ? FittedBox(
//     child: Text(
//       cat.catName,
//       overflow: TextOverflow.ellipsis,
//       maxLines: 2,
//       softWrap: true,
//       style: const TextStyle(color: Colors.black,),
//     ),
//   )
//       : const SizedBox(),
// )
// AnimatedSwitcher(
//   duration: const Duration(seconds: 1),
//   child: controller.showCatsName
//       ? FittedBox(
//     child: Text(
//       cat.catName,
//       overflow: TextOverflow.fade,
//       maxLines: 2,
//       softWrap: true,
//       style: const TextStyle(color: Colors.black), // Ensure clear visibility
//     ),
//   )
//       : const SizedBox(),
// )
// Row(
//   mainAxisAlignment: MainAxisAlignment.end,
//   children: [
//     SizedBox(
//       width: 40.w,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: MyWidgets().getLargeButton(
//             title: 'Refresh Offers',
//             onPress: () async {
//               controller.changeIsTrendingLoading(true);
//               OffersConnect().getAllOffersApi(
//                   homeScreenController
//                       .screenTypeProducts);
//               controller.changeIsTrendingLoading(false);
//             }),
//       ),
//     ),
//   ],
// ),
// AnimatedSwitcher(
//   duration: const Duration(seconds: 1),
//   child: controller.showCatsName
//       ? FittedBox(
//     child: Text(
//       cat.catName,
//       overflow: TextOverflow.ellipsis,
//       maxLines: 2,
//       softWrap: true,
//       style: const TextStyle(color: Colors.black,),
//     ),
//   )
//       : const SizedBox(),
// )






