import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Screens/OffersScreens/productcateogry.dart';
import 'package:candid_customer/Screens/OffersScreens/servicecatogory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';

import '../../Controllers/OffersController/MyFavouritesController.dart';
import '../../Controllers/SearchControllers/SearchScreenController.dart';
import '../../Sumit/Product_Search.dart';
import '../../Sumit/Service_Search.dart';
import '../../Services/Collections/Offers/OffersColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

import 'OfferDetailsScreen.dart'; // Import OfferDetailsScreen

class MyFavouritesScreen extends StatelessWidget {
  const MyFavouritesScreen({Key? key});

  Widget buildItem({
    required String title,
    required String discount,
    required bool isFavorite,
    required String id,
    required String offerImage,
    required BuildContext context,
  }) {
    const EdgeInsets imagePadding = EdgeInsets.all(10.0);
    const EdgeInsets discountPadding = EdgeInsets.only(left: 1, bottom: 20);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OfferDetailsScreen(offerID: id),
          ),
        );
      },
      child: Container(
        width: 50.w,
        height: 20.h,
        decoration: const BoxDecoration(
          color: Color(0xFFB0B0B0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: imagePadding,
                child: myWidgets.getCachedNetworkImage(imgUrl: offerImage),
              ),
            ),
            // Positioned(
            //   left: 10,
            //   bottom: 3,
            //   child: Text(
            //     title,
            //     style: const TextStyle(
            //       color: Colors.black,
            //       fontSize: 14,
            //       fontFamily: 'Aileron',
            //       fontWeight: FontWeight.w700,
            //     ),
            //   ),
            // ),
            Positioned(
              right: 10,
              top: 10,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,

              ),
            ),
            Positioned(
              left: 10,
              top: 150,
              child: Padding(
                padding: discountPadding,
                child: Container(
                  width: 50,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      discount,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontFamily: 'Aileron',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: MyWidgets().myAppBar(),
      drawer: Drawer(
        child: Container(
          color: Colors
              .white, // Set the background color of the drawer to pure white
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              MyWidgets().myDrawerHeader(),
              for (var item in bottomNavController.navDrawerItems)
                Card(
                  color: Colors.white, // Ensure card background is pure white
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0), // Adjust margin as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // Adjust the border radius as needed
                  ),
                  elevation:
                      2, // Optional: adds a slight shadow for visual separation
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // Adjust padding as needed
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        fontFamily: 'Aileron',
                        // fontWeight: FontWeight.bold,
                        fontSize: 12.sp, // Ensure this fits your design needs
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ), // iOS-style forward button
                    onTap: () =>
                        Navigator.of(navigatorKey.currentContext!).push(
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
      body: GetBuilder(
        init: MyFavouritesController(),
        builder: (controller) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) => controller.changeSearchStr(val),
                  style: const TextStyle(color: Colors.black), // Text color
                  decoration: InputDecoration(
                    hintText: 'Search for product or service here', // Hint text
                    hintStyle:
                        const TextStyle(color: Colors.grey), // Hint text color
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(
                          10.0), // Adjust padding as needed
                      child: Image.asset(
                        'lib/Images/RealOffers1.png',
                        width: 40, // Set your desired width
                        height: 35, // Set your desired height
                      ),
                    ), // Search icon color
                    suffixIcon: PopupMenuTheme(
                      data: const PopupMenuThemeData(
                        color: Colors
                            .white, // Set the background color of the dropdown menu to white
                        textStyle: TextStyle(
                            color: Colors
                                .black), // Optional: Set the text color if needed
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
                          if (value == 'Products') {
                            Get.to(() =>   Productcateogry());
                          } else if (value == 'Services') {
                            Get.to(() =>   ServiceCategory());
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'Products',
                            child: Row(
                              children: [
                                Icon(Icons.shopping_cart, color: Colors.black),
                                SizedBox(width: 8),
                                Text('Products'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Services',
                            child: Row(
                              children: [
                                Icon(Icons.build, color: Colors.black),
                                SizedBox(width: 8),
                                Text('Services'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true, // Enable background color
                    fillColor: Colors.white, // Background color
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<OffersColl>>(
                stream: isar.offersColls
                    .filter()
                    .isInWishListEqualTo(true)
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
                      .userBusinessNameContains(searchLower,
                          caseSensitive: false)
                      .or()
                      .productTypeContains(searchLower, caseSensitive: false)
                      .or()
                      .productTypeEqualTo(controller.filterproductType ?? "");
                }).watch(fireImmediately: true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong!'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => _showPopup(context),
                            child: SvgPicture.asset(
                              'lib/Images/Group 400.svg',
                              fit: BoxFit.contain,
                              // height: 100, // Adjust the height as needed
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showPopup(context),
                            child: SvgPicture.asset(
                              'lib/Images/Group 400.svg',
                              fit: BoxFit.contain,
                              // height: 100, // Adjust the height as needed
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  List<OffersColl> offers = snapshot.data!;
                  return GridView.builder(
                    itemCount: offers.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75, // Adjust for taller cards
                    ),
                    itemBuilder: (context, index) {
                      OffersColl offer = offers![index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Container
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child:  Container(
                                          height: 150, // ✅ Fixed height to avoid zero-size issue
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 8.0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12.0),
                                            child: offer.offerImages != null &&
                                                offer.offerImages is List &&
                                                offer.offerImages.isNotEmpty &&
                                                offer.offerImages.first != null &&
                                                offer.offerImages.first.toString().isNotEmpty
                                                ? CachedNetworkImage(
                                              imageUrl: offer.offerImages.first,
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: double.infinity,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(Icons.broken_image,
                                                      color: Colors.grey, size: 40),
                                                ),
                                              ),
                                            )
                                                : Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.image_not_supported,
                                                    color: Colors.grey, size: 40),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Discount Badge
                                      if (offer.discountNo != null &&
                                          offer.discountNo != null)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              '${offer.discountNo}% OFF',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Wishlist Button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              offer.isInWishList
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 20,
                                            ),
                                            color: offer.isInWishList
                                                ? Colors.red
                                                : Colors.grey,
                                            onPressed: () {
                                              // Handle wishlist toggle
                                            },
                                            constraints: const BoxConstraints(
                                              minHeight: 36,
                                              minWidth: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Product Info
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          offer.offerName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Aileron',
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (offer.isTrending ?? false)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 4),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Best Selling',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.amber[900],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Make entire card clickable
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OfferDetailsScreen(
                                          offerID: offer.offerID),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // SizedBox(height: 32.h),
              // myWidgets.getCandidBranding(),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
