import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../../Controllers/SearchControllers/SearchScreenController.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';
import '../NotificationScreens/NotificationScreen.dart';
import 'OfferDetailsScreen.dart';

class ServiceListing extends StatelessWidget {
  const ServiceListing({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;
    final String? selectedCategoryName = arguments?['selectedCategoryName'] ?? 'defaultCategory';
    final TextEditingController searchController = TextEditingController();

    return GetBuilder(
      init: homeScreenController,
      builder: (controller) => Scaffold(
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        resizeToAvoidBottomInset: true,
        body: _buildBody(controller, searchController, context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Products',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () => Navigator.of(
              navigatorKey.currentContext!)
              .push(MaterialPageRoute(
              builder: (context) =>
              const NotificationScreen())),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            MyWidgets().myDrawerHeader(),
            ..._buildDrawerItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return bottomNavController.navDrawerItems.map((item) {
      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          title: Text(
            item['title'],
            style: TextStyle(
              fontFamily: 'Aileron',
              fontSize: 12.sp,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16.0,
          ),
          onTap: () => Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (BuildContext context) => item['screen'],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBody(dynamic controller, TextEditingController searchController, BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(searchController, context),
            _buildFeaturedProductsSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(TextEditingController searchController, BuildContext context) {
    return GetBuilder(
      init: SearchScreenController(),
      builder: (controller) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSearchBar(controller, searchController),
            if (controller.searchStr.isNotEmpty)
              _buildSearchResults(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchScreenController controller, TextEditingController searchController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: searchController,
        onChanged: (val) => controller.changeSearchStr(val),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search for Products here',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _buildFilterButton(controller, searchController),
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
    );
  }

  Widget _buildFilterButton(SearchScreenController controller, TextEditingController searchController) {
    return PopupMenuTheme(
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
    );
  }

  Widget _buildSearchResults(SearchScreenController controller) {
    return SizedBox(
      height: 25.h,
      width: 90.w,
      child: _buildSearchResultsStream(controller),
    );
  }

  Widget _buildSearchResultsStream(SearchScreenController controller) {
    return StreamBuilder<List<OffersColl>>(
      stream: _getSearchStream(controller),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoResultsFound(context);
        }
        return _buildSearchResultsList(snapshot.data!);
      },
    );
  }

  Stream<List<OffersColl>> _getSearchStream(SearchScreenController controller) {
    return isar.offersColls
        .filter()
        .selectedCityEqualTo(homeScreenController.selectedCity)
        .and()
        .group((q) {
      final searchLower = controller.searchStr.toLowerCase().trim();
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
    }).build().watch(fireImmediately: true);
  }

  Widget _buildSearchResultsList(List<OffersColl> offers) {
    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: offers.length,
      itemBuilder: (context, index) => _buildOfferCard(offers[index], context),
      separatorBuilder: (context, index) => const SizedBox(width: 4),
    );
  }

  Widget _buildOfferCard(OffersColl offer, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 90.w,
      height: 28.h,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildOfferDetails(offer, context),
            _buildOfferImage(offer),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferDetails(OffersColl offer, BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              offer.offerName,
              textScaleFactor: 1.3,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 35.w,
              child: Text(
                offer.offerAddress,
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const Spacer(),
            _buildViewOffersButton(offer, context),
          ],
        ),
      ),
    );
  }

  Widget _buildViewOffersButton(OffersColl offer, BuildContext context) {
    return OpenContainer(
      closedColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 200),
      transitionType: ContainerTransitionType.fade,
      closedBuilder: (context, action) => ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'VIEW OFFERS',
          style: TextStyle(color: Colors.white, fontSize: 8),
        ),
      ),
      openBuilder: (context, action) => OfferDetailsScreen(offerID: offer.offerID),
    );
  }

  Widget _buildOfferImage(OffersColl offer) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          child: CachedNetworkImage(
            imageUrl: offer.offerImages.first,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(dynamic controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Featured Product Offers',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        _buildFeaturedProductsList(controller),
      ],
    );
  }

  Widget _buildFeaturedProductsList(dynamic controller) {
    return StreamBuilder(
      stream: _getFeaturedProductsStream(controller),
      builder: (context, snapshot) {
        if (!snapshot.hasData || controller.trendingNowIsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        List<OffersColl>? offers = snapshot.data;
        if (offers == null || offers.isEmpty) {
          return _buildNoOffersFound(context);
        }
        return Column(
          children: offers.map((offer) => _buildFeaturedOfferCard(offer, context)).toList(),
        );
      },
    );
  }
  Widget _buildFeaturedOfferCard(OffersColl offer, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 28.h,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offer Name and Likes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            offer.offerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${offer.likesCount}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Address
                    Text(
                      offer.offerAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // View Offers Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'VIEW OFFERS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Rating Section
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('candidOffers')
                          .doc(offer.offerID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const SizedBox.shrink();
                        }

                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        if (data == null) return const SizedBox.shrink();

                        final cumulativeRating = (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
                        final ratingCount = (data['ratingCount'] as int?) ?? 0;
                        final averageRating = ratingCount > 0 ? cumulativeRating / ratingCount : 0.0;

                        return Row(
                          children: [
                            ...List.generate(5, (index) {
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
                              ratingCount > 0
                                  ? '${averageRating.toStringAsFixed(1)} / 5'
                                  : 'No ratings',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Offer Image
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(15),
                ),
                child: offer.offerImages.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: offer.offerImages.first,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                )
                    : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 32,
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
  Stream<List<OffersColl>> _getFeaturedProductsStream(dynamic controller) {
    return isar.offersColls
        .filter()
        .offerNameIsNotEmpty()
        .selectedCityEqualTo(controller.selectedCity)
        .offerTypeEqualTo('product')
        .sortByDistanceFromUserInMeters()
        .build()
        .watch(fireImmediately: true);
  }

  Widget _buildNoResultsFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => _showPopup(context),
          child: Image.asset(
            'lib/Images/carousel-category-templates_0000_Layer 8 copy.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildNoOffersFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => _showPopup(context),
          child: Image.asset(
            'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
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
          'This is the demo  offer. If we have offers nearby or in your city, real offers will show in real time. Thank you from Candid Offer!',
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

