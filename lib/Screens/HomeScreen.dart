// import 'dart:math';
// import 'dart:ui';
// import 'package:candid_customer/Screens/OffersScreens/productcateogry.dart';
// import 'package:candid_customer/Screens/OffersScreens/productlistingscreen.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:candid_customer/Screens/OffersScreens/OfferDetailsScreen.dart';
// import 'package:candid_customer/Services/Collections/Cat/CatsColl.dart';
// import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
// import 'package:candid_customer/Utils/MyWidgets.dart';
// import 'package:candid_customer/main.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isar_community/isar.dart';
// import 'package:sizer/sizer.dart';
// import '../Controllers/SearchControllers/SearchScreenController.dart';
// import '../Sumit/Product_Search.dart';
// import '../S/Voice.dart';
// import '../Sumit/Service_Search.dart';
// import '../Services/API/OffersServices/OffersConnect.dart';
// import 'OffersScreens/OfferCategories.dart';
// import 'OffersScreens/selectedcatoffers.dart';
// import 'OffersScreens/servicecatogory.dart';
// import 'OffersScreens/servicelistingscreen.dart';
//
// class HomeScreen extends StatefulWidget {
//   final String? initialTab;
//   const HomeScreen({Key? key, this.initialTab});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   List<OffersColl> nearbyOffers = [];
//   bool offersFound = false;
//
//   String searchQuery = '';
//   List<OffersColl> searchResults = [];
//   bool isSearching = false;
//   String searchType = 'All'; // 'All', 'Products', 'Services'
//   late TextEditingController searchController;
//
//   @override
//   void initState() {
//     super.initState();
//     searchController = TextEditingController();
//     searchController.addListener(_onSearchChanged);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchNearbyOffers();
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     _fetchNearbyOffers();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       searchQuery = searchController.text.toLowerCase();
//       isSearching = searchQuery.isNotEmpty;
//       _performSearch();
//     });
//   }
//
//   void _performSearch() {
//     if (searchQuery.isEmpty) {
//       setState(() {
//         searchResults = [];
//         isSearching = false;
//       });
//       return;
//     }
//
//     List<OffersColl> results = [];
//
//     // Filter based on search type
//     List<OffersColl> offersToSearch = nearbyOffers;
//
//     if (searchType == 'Products') {
//       offersToSearch = nearbyOffers.where((offer) => offer.offerType == 'product').toList();
//     } else if (searchType == 'Services') {
//       offersToSearch = nearbyOffers.where((offer) => offer.offerType == 'service').toList();
//     }
//
//     // Search through offers
//     for (var offer in offersToSearch) {
//       if (offer.offerName.toLowerCase().contains(searchQuery) ||
//           offer.offerAddress.toLowerCase().contains(searchQuery) ||
//           (offer.productName?.toLowerCase().contains(searchQuery) ?? false)) {
//         results.add(offer);
//       }
//     }
//
//     setState(() {
//       searchResults = results;
//     });
//   }
//
//   void _clearSearch() {
//     searchController.clear();
//     setState(() {
//       searchQuery = '';
//       searchResults = [];
//       isSearching = false;
//     });
//   }
//
//   Future<void> _fetchNearbyOffers() async {
//     Position position;
//
//     try {
//       position = await _determinePosition();
//     } catch (e) {
//       debugPrint('Error getting position: $e');
//       if (mounted) {
//         setState(() {
//           nearbyOffers = [];
//           offersFound = false;
//         });
//       }
//       return;
//     }
//
//     List<OffersColl> offers;
//
//     try {
//       offers =
//       await _getOffersBasedOnCity(position.latitude, position.longitude);
//     } catch (e) {
//       debugPrint('Error fetching offers: $e');
//       if (mounted) {
//         setState(() {
//           nearbyOffers = [];
//           offersFound = false;
//         });
//       }
//       return;
//     }
//
//     if (mounted) {
//       setState(() {
//         nearbyOffers = offers;
//         offersFound = offers.isNotEmpty;
//       });
//
//       debugPrint(
//           'User Location: Lat=${position.latitude}, Lon=${position.longitude}');
//       debugPrint('Number of Nearby Offers: ${nearbyOffers.length}');
//     }
//   }
//
//   Future<List<OffersColl>> _getOffersBasedOnCity(
//       double latitude, double longitude) async {
//     await OffersConnect()
//         .getAllOffersApi(true); // Ensure this fetches offers correctly
//     return await isar.offersColls
//         .filter()
//         .distanceFromUserInMetersLessThan(
//         10000) // Ensure correct filtering logic
//         .findAll();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic>? arguments =
//     Get.arguments as Map<String, dynamic>?;
//     final String? selectedCategoryName = arguments?['selectedCategoryName'] ??
//         'defaultCategory'; // Provide a default value if null
//     // final TextEditingController searchController = TextEditingController();
//     return GetBuilder(
//       init: homeScreenController,
//       builder: (controller) => Scaffold(
//         appBar: MyWidgets().myAppBar(),
//         drawer: Drawer(
//           child: Container(
//             color: Colors.white,
//             // Set the background color of the drawer to pure white
//             child: ListView(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               children: [
//                 // Ensure this is your custom header without dividers
//                 MyWidgets().myDrawerHeader(),
//                 // Generate cards for each item
//                 for (var item in bottomNavController.navDrawerItems)
//                   Card(
//                     color: Colors.white,
//                     // Ensure card background is pure white
//                     margin: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                     // Adjust margin as needed
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                           8.0), // Adjust the border radius as needed
//                     ),
//                     elevation: 2,
//                     // Optional: adds a slight shadow for visual separation
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16.0), // Adjust padding as needed
//                       title: Text(
//                         item['title'],
//                         style: GoogleFonts.workSans(
//                           // fontWeight: FontWeight.bold, // Uncomment if needed
//                           fontSize: 12.sp, // Ensure this fits your design needs
//                         ),
//                       ),
//                       trailing: const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16.0,
//                       ), // iOS-style forward button
//                       onTap: () =>
//                           Navigator.of(navigatorKey.currentContext!).push(
//                             MaterialPageRoute(
//                               builder: (BuildContext context) => item['screen'],
//                             ),
//                           ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         resizeToAvoidBottomInset: true,
//         body:
//         Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height * 0.10,
//               width: MediaQuery.of(context).size.width,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: [0.1979, 1.0],
//                   colors: [Color(0xFFDC2121), Color(0xFF8F0A0A)],
//                 ),
//               ),
//               child: Center(
//                 child: GetBuilder<SearchScreenController>(
//                   init: SearchScreenController(),
//                   builder: (controller) =>
//                       Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: TextField(
//                                 controller: searchController,
//                                 decoration: InputDecoration(
//                                   hintText: 'Search products, services, or locations...',
//                                   hintStyle: TextStyle(color: Colors.grey[500]),
//                                   prefixIcon: const Icon(Icons.search, color: Colors.black),
//                                   suffixIcon: isSearching
//                                       ? IconButton(
//                                     icon: const Icon(Icons.clear, color: Colors.black),
//                                     onPressed: _clearSearch,
//                                   )
//                                       : null,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 15, horizontal: 20),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(color: Colors.black),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(color: Colors.black),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: const BorderSide(
//                                       color: Colors.black,
//                                       width: 2,
//                                     ),
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                 ),
//               ),
//             ),
//             GetBuilder<SearchScreenController>(
//               builder: (controller) {
//                 if (controller.searchStr.isEmpty) {
//                   return const SizedBox.shrink();
//                 }
//                 return Expanded(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     color: Colors.white,
//                     child: StreamBuilder<List<OffersColl>>(
//                       stream: isar.offersColls
//                           .filter()
//                           .selectedCityEqualTo(
//                           homeScreenController.selectedCity)
//                           .and()
//                           .group((q) {
//                         final searchLower =
//                         controller.searchStr.toLowerCase().trim();
//                         return q
//                             .offerNameContains(searchLower,
//                             caseSensitive: false)
//                             .or()
//                             .offerTypeContains(searchLower,
//                             caseSensitive: false)
//                             .or()
//                             .userPinCodeContains(searchLower,
//                             caseSensitive: false)
//                             .or()
//                             .userBusinessNameContains(searchLower,
//                             caseSensitive: false)
//                             .or()
//                             .productTypeContains(searchLower,
//                             caseSensitive: false)
//                             .or()
//                             .productTypeEqualTo(
//                             controller.filterproductType ?? "");
//                       })
//                           .build()
//                           .watch(fireImmediately: true),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         if (snapshot.hasError) {
//                           return Center(
//                               child: Text('Error: ${snapshot.error}'));
//                         }
//                         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                           return const Center(
//                             child: Text(
//                               'No results found',
//                               style: TextStyle(color: Colors.black),
//                             ),
//                           );
//                         }
//                         final offers = snapshot.data!;
//                         return ListView.builder(
//                           padding: const EdgeInsets.all(8),
//                           itemCount: offers.length,
//                           itemBuilder: (context, index) {
//                             final offer = offers[index];
//                             return Container(
//                               width: MediaQuery.of(context).size.width * 0.92,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     offset: const Offset(0, 4),
//                                     blurRadius: 15,
//                                     spreadRadius: 1,
//                                   ),
//                                 ],
//                               ),
//                               child: Material(
//                                 // Added for ripple effect
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(16),
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             OfferDetailsScreen(
//                                                 offerID: offer.offerID),
//                                       ),
//                                     );
//                                   },
//                                   child: Row(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       // Left Content Section
//                                       Expanded(
//                                         flex: 3,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(16),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               // Offer Name and Likes Section
//                                               Column(
//                                                 crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     crossAxisAlignment:
//                                                     CrossAxisAlignment
//                                                         .start,
//                                                     children: [
//                                                       Expanded(
//                                                         child: Text(
//                                                           offer.offerName,
//                                                           style:
//                                                           const TextStyle(
//                                                             fontSize: 18,
//                                                             fontWeight:
//                                                             FontWeight.w700,
//                                                             color: Color(
//                                                                 0xFF2C3E50),
//                                                             height: 1.3,
//                                                           ),
//                                                           maxLines: 2,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                       Container(
//                                                         padding:
//                                                         const EdgeInsets
//                                                             .symmetric(
//                                                           horizontal: 8,
//                                                           vertical: 4,
//                                                         ),
//                                                         decoration:
//                                                         BoxDecoration(
//                                                           color: Colors
//                                                               .red.shade50,
//                                                           borderRadius:
//                                                           BorderRadius
//                                                               .circular(20),
//                                                         ),
//                                                         child: Row(
//                                                           mainAxisSize:
//                                                           MainAxisSize.min,
//                                                           children: [
//                                                             Icon(
//                                                               Icons.favorite,
//                                                               color: Colors
//                                                                   .red.shade400,
//                                                               size: 16,
//                                                             ),
//                                                             const SizedBox(
//                                                                 width: 4),
//                                                             Text(
//                                                               '${offer.likesCount}',
//                                                               style: TextStyle(
//                                                                 color: Colors
//                                                                     .red
//                                                                     .shade400,
//                                                                 fontSize: 14,
//                                                                 fontWeight:
//                                                                 FontWeight
//                                                                     .w600,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 12),
//                                                   // Address Section
//                                                   Row(
//                                                     children: [
//                                                       Icon(
//                                                         Icons
//                                                             .location_on_outlined,
//                                                         size: 16,
//                                                         color: Colors.grey[600],
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Expanded(
//                                                         child: Text(
//                                                           offer.offerAddress,
//                                                           style: TextStyle(
//                                                             fontSize: 14,
//                                                             color: Colors
//                                                                 .grey[600],
//                                                             height: 1.4,
//                                                           ),
//                                                           maxLines: 2,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                               const SizedBox(height: 16),
//                                               // Rating Section
//                                               StreamBuilder<DocumentSnapshot>(
//                                                 stream: FirebaseFirestore
//                                                     .instance
//                                                     .collection('candidOffers')
//                                                     .doc(offer.offerID)
//                                                     .snapshots(),
//                                                 builder: (context, snapshot) {
//                                                   if (snapshot
//                                                       .connectionState ==
//                                                       ConnectionState.waiting) {
//                                                     return const LinearProgressIndicator(
//                                                       minHeight: 2,
//                                                       backgroundColor:
//                                                       Colors.transparent,
//                                                     );
//                                                   }
//
//                                                   if (!snapshot.hasData ||
//                                                       !snapshot.data!.exists) {
//                                                     return const SizedBox
//                                                         .shrink();
//                                                   }
//
//                                                   final data = snapshot.data!
//                                                       .data()
//                                                   as Map<String, dynamic>?;
//                                                   if (data == null) {
//                                                     return const SizedBox
//                                                         .shrink();
//                                                   }
//
//                                                   final cumulativeRating =
//                                                       (data['cumulativeRating']
//                                                       as num?)
//                                                           ?.toDouble() ??
//                                                           0.0;
//                                                   final ratingCount =
//                                                       (data['ratingCount']
//                                                       as int?) ??
//                                                           0;
//                                                   final averageRating =
//                                                   ratingCount > 0
//                                                       ? cumulativeRating /
//                                                       ratingCount
//                                                       : 0.0;
//
//                                                   return Column(
//                                                     crossAxisAlignment:
//                                                     CrossAxisAlignment
//                                                         .start,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisSize:
//                                                         MainAxisSize.min,
//                                                         children: [
//                                                           // Star icons with fixed size
//                                                           ...List.generate(5,
//                                                                   (index) {
//                                                                 return Icon(
//                                                                   index <
//                                                                       averageRating
//                                                                           .round()
//                                                                       ? Icons
//                                                                       .star_rounded
//                                                                       : Icons
//                                                                       .star_outline_rounded,
//                                                                   color: const Color(
//                                                                       0xFFFFB800),
//                                                                   size:
//                                                                   18, // Slightly reduced size
//                                                                 );
//                                                               }),
//                                                           const SizedBox(
//                                                               width: 4),
//                                                           // Reduced spacing
//                                                           // Expandable text that handles overflow
//                                                           Expanded(
//                                                             child: Text(
//                                                               ratingCount > 0
//                                                                   ? '${averageRating.toStringAsFixed(1)} / 5'
//                                                                   : 'No ratings yet',
//                                                               style:
//                                                               const TextStyle(
//                                                                 fontSize: 13,
//                                                                 // Slightly reduced font size
//                                                                 fontWeight:
//                                                                 FontWeight
//                                                                     .w500,
//                                                                 color: Color(
//                                                                     0xFF6B7280),
//                                                               ),
//                                                               overflow:
//                                                               TextOverflow
//                                                                   .ellipsis,
//                                                               // Handle text overflow
//                                                               maxLines: 1,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       )
//                                                     ],
//                                                   );
//                                                 },
//                                               ),
//                                               const SizedBox(height: 16),
//                                               // View Offers Button
//                                               SizedBox(
//                                                 width: double.infinity,
//                                                 child: ElevatedButton(
//                                                   onPressed: () {
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             OfferDetailsScreen(
//                                                                 offerID: offer
//                                                                     .offerID),
//                                                       ),
//                                                     );
//                                                   },
//                                                   style:
//                                                   ElevatedButton.styleFrom(
//                                                     foregroundColor:
//                                                     Colors.white,
//                                                     backgroundColor:
//                                                     const Color(0xFF1A1A1A),
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         vertical: 12),
//                                                     shape:
//                                                     RoundedRectangleBorder(
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                           10),
//                                                     ),
//                                                     elevation: 0,
//                                                   ),
//                                                   child: const Text(
//                                                     'VIEW OFFERS',
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                       FontWeight.w600,
//                                                       letterSpacing: 0.5,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       // Right Image Section
//                                       Expanded(
//                                         flex: 2,
//                                         child: ClipRRect(
//                                             borderRadius:
//                                             const BorderRadius.only(
//                                               topRight: Radius.circular(16),
//                                               bottomRight: Radius.circular(16),
//                                             ),
//                                             child: SizedBox(
//                                               height: 220,
//                                               child: offer
//                                                   .offerImages.isNotEmpty
//                                                   ? CachedNetworkImage(
//                                                 imageUrl: offer
//                                                     .offerImages.first
//                                                     .startsWith(
//                                                     'http')
//                                                     ? offer
//                                                     .offerImages.first
//                                                     : 'https://firebasestorage.googleapis.com/v0/b/candid-cf9fc.appspot.com/o/${Uri.encodeFull(offer.offerImages.first)}',
//                                                 fit: BoxFit.cover,
//                                                 placeholder:
//                                                     (context, url) {
//                                                   print(
//                                                       'Loading image URL: $url'); // Debug print
//                                                   return Container(
//                                                     color:
//                                                     Colors.grey[100],
//                                                     child: Center(
//                                                       child:
//                                                       CircularProgressIndicator(
//                                                         strokeWidth: 2,
//                                                         color: Colors
//                                                             .grey[400],
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                                 errorWidget: (context,
//                                                     url, error) {
//                                                   print(
//                                                       'Error loading image: $error'); // Debug print
//                                                   return Container(
//                                                     color:
//                                                     Colors.grey[100],
//                                                     child: const Center(
//                                                       child: Icon(
//                                                         Icons
//                                                             .image_not_supported_outlined,
//                                                         color:
//                                                         Colors.grey,
//                                                         size: 32,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               )
//                                                   : Container(
//                                                 color: Colors.grey[100],
//                                                 child: const Center(
//                                                   child: Icon(
//                                                     Icons.image_outlined,
//                                                     color: Colors.grey,
//                                                     size: 32,
//                                                   ),
//                                                 ),
//                                               ),
//                                             )),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 1.h,),
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Card(
//                                 elevation: 4,
//                                 // Adjust the elevation for shadow effect
//                                 color: Color(0xFF2C3E6C),
//                                 // Background color of the card
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       8.0), // Adjust the border radius as needed
//                                 ),
//                                 child: Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'PRODUCT CATEGORIES',
//                                     style: GoogleFonts.workSans(
//                                       color: Colors.white,
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w600,
//                                       height: 1,
//                                       // Adjusted to 1 for better line height
//                                       letterSpacing: 0.02,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 0.0),
//                                 // Adjust the right padding as needed
//                                 child: SizedBox(
//                                   width: 25.w, // Adjust as needed
//                                   height: 34, // Adjust as needed
//                                   child: MyWidgets().getLargeButton(
//                                     title: 'Browse All',
//                                     onPress: () =>
//                                         Get.to(() => Productcateogry()),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Add some space between the rows
//                           LayoutBuilder(
//                             builder: (context, constraints) {
//                               // Calculate responsive sizes based on screen width
//                               final screenWidth =
//                                   MediaQuery.of(context).size.width;
//                               final isSmallScreen = screenWidth < 360;
//                               final isMediumScreen =
//                                   screenWidth >= 360 && screenWidth < 600;
//                               final isLargeScreen = screenWidth >= 600;
//
//                               // Adjust sizes based on screen size
//                               final fontSize = isSmallScreen
//                                   ? 12.sp
//                                   : isMediumScreen
//                                   ? 14.sp
//                                   : 16.sp;
//
//                               final iconSize = isSmallScreen
//                                   ? 16.sp
//                                   : isMediumScreen
//                                   ? 18.sp
//                                   : 20.sp;
//
//                               final containerSize = isSmallScreen
//                                   ? 28.0
//                                   : isMediumScreen
//                                   ? 32.0
//                                   : 36.0;
//
//                               final horizontalPadding = isSmallScreen
//                                   ? 12.0
//                                   : isMediumScreen
//                                   ? 16.0
//                                   : 20.0;
//
//                               return Container(
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: 8.0,
//                                   horizontal: horizontalPadding,
//                                 ),
//                                 constraints: BoxConstraints(
//                                   maxWidth:
//                                   isLargeScreen ? 600.0 : double.infinity,
//                                 ),
//                                 child: FittedBox(
//                                   fit: BoxFit.scaleDown,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           'Explore More Product Categories',
//                                           style: GoogleFonts.workSans(
//                                             color: Colors.black,
//                                             fontSize: fontSize,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                           width: isSmallScreen ? 4.w : 8.w),
//                                       InkWell(
//                                         onTap: () {
//                                           controller.scrollToEnd(
//                                               controller.scrollController1);
//                                         },
//                                         child: Container(
//                                           width: containerSize,
//                                           height: containerSize,
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             shape: BoxShape.circle,
//                                             // Add subtle shadow for better visibility
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.black
//                                                     .withOpacity(0.1),
//                                                 blurRadius: 4,
//                                                 offset: Offset(0, 2),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Center(
//                                             child: Icon(
//                                               Icons.arrow_forward,
//                                               color: Colors.white,
//                                               // size: iconSize,
//                                               size: 30,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           )
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 1.h,),
//                     Stack(
//                       textDirection: TextDirection.rtl,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             controller.toggleCatsName();
//                           },
//                           child: AnimatedContainer(
//                             height: controller.showCatsName ? 12.h : 14.h,
//                             width: 100.w,
//                             duration: const Duration(milliseconds: 300),
//                             child: StreamBuilder(
//                               stream: isar.catsColls
//                                   .filter()
//                                   .catNameIsNotEmpty()
//                                   .catTypeEqualTo('product')
//                                   .not()
//                                   .catNameEqualTo('Popular')
//                                   .build()
//                                   .watch(fireImmediately: true),
//                               builder: (context, snapshot) {
//                                 List<CatsColl> catsList = [];
//                                 if (snapshot.data != null &&
//                                     !snapshot.hasError) {
//                                   catsList = snapshot.data as List<CatsColl>;
//
//                                   if (controller.selectedCatID.isEmpty &&
//                                       catsList.isNotEmpty) {
//                                     Future.delayed(Duration.zero, () {
//                                       controller.selectedCatID =
//                                           catsList.first.catID;
//                                       controller.update();
//                                     });
//                                   }
//                                 } else {
//                                   return const Center(
//                                       child: Text('Loading...'));
//                                 }
//
//                                 int itemCount =
//                                 catsList.length > 10 ? 11 : catsList.length;
//
//                                 return AnimatedSwitcher(
//                                   duration: const Duration(milliseconds: 0),
//                                   child: catsList.isEmpty
//                                       ? const Text('Empty List')
//                                       : ListView.separated(
//                                     controller:
//                                     controller.scrollController1,
//                                     shrinkWrap: true,
//                                     itemCount: itemCount,
//                                     scrollDirection: Axis.horizontal,
//                                     physics:
//                                     const AlwaysScrollableScrollPhysics(),
//                                     itemBuilder: (context, index) {
//                                       if (index == 10 &&
//                                           catsList.length > 10) {
//                                         return InkWell(
//                                           onTap: () {
//                                             Navigator.of(context).push(
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                 const OfferCategories(),
//                                               ),
//                                             );
//                                           },
//                                           child: SizedBox(
//                                             width:
//                                             controller.listItemWidth,
//                                             child: const Column(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .center,
//                                               children: [
//                                                 Icon(Icons.more_horiz,
//                                                     size: 30),
//                                                 SizedBox(height: 5),
//                                                 Text('View More',
//                                                     style: TextStyle(
//                                                         fontSize: 12)),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       }
//
//                                       var cat = catsList[index];
//
//                                       return InkWell(
//                                         onTap: () {
//                                           Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   OffersScreen(
//                                                       selectedCatID:
//                                                       cat.catID),
//                                             ),
//                                           );
//                                         },
//                                         child: SizedBox(
//                                           width: controller.listItemWidth,
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 decoration: BoxDecoration(
//                                                   border: cat.catID ==
//                                                       controller
//                                                           .selectedCatID
//                                                       ? Border.all(
//                                                       color: const Color(
//                                                           0xFFDB2020),
//                                                       width: 3.0)
//                                                       : null,
//                                                 ),
//                                                 child: SvgPicture.network(
//                                                   cat.catImg,
//                                                   fit: BoxFit.contain,
//                                                   placeholderBuilder:
//                                                       (BuildContext
//                                                   context) =>
//                                                       Image.asset(
//                                                         'lib/Images/app_icon_mid.jpeg',
//                                                         fit: BoxFit.contain,
//                                                       ),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 3),
//                                               SizedBox(
//                                                 width: controller
//                                                     .listItemWidth,
//                                                 child: Text(
//                                                   cat.catName,
//                                                   style: TextStyle(
//                                                     fontSize: 8.sp,
//                                                     fontWeight:
//                                                     FontWeight.bold,
//                                                   ),
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   overflow: TextOverflow
//                                                       .ellipsis,
//                                                   maxLines: 3,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     separatorBuilder: (context, index) =>
//                                     const VerticalDivider(
//                                         width: 5,
//                                         color: Colors.transparent),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     // Center(
//                     //   child: Stack(
//                     //     textDirection: TextDirection.rtl,
//                     //     children: [
//                     //       InkWell(
//                     //         onTap: () {
//                     //           controller.toggleCatsName();
//                     //         },
//                     //         child: AnimatedContainer(
//                     //           height: controller.showCatsName ? 12.h : 14.h,
//                     //           width: 100.w,
//                     //           duration: const Duration(milliseconds: 300),
//                     //           child: Builder(
//                     //             builder: (context) {
//                     //               final categoryList =
//                     //                   mainCategories.keys.toList();
//                     //               final itemCount = categoryList.length > 10
//                     //                   ? 11
//                     //                   : categoryList.length;
//                     //
//                     //               return ListView.separated(
//                     //                 controller: controller.scrollController1,
//                     //                 shrinkWrap: true,
//                     //                 itemCount: itemCount,
//                     //                 scrollDirection: Axis.horizontal,
//                     //                 physics:
//                     //                     const AlwaysScrollableScrollPhysics(),
//                     //                 itemBuilder: (context, index) {
//                     //                   if (index == 10 &&
//                     //                       categoryList.length > 10) {
//                     //                     return InkWell(
//                     //                       onTap: () {
//                     //                         Navigator.of(context).push(
//                     //                           MaterialPageRoute(
//                     //                             builder: (context) =>
//                     //                                 const OfferCategories(),
//                     //                           ),
//                     //                         );
//                     //                       },
//                     //                       child: SizedBox(
//                     //                         width: controller.listItemWidth,
//                     //                         child: const Column(
//                     //                           mainAxisAlignment:
//                     //                               MainAxisAlignment.center,
//                     //                           children: [
//                     //                             Icon(Icons.more_horiz, size: 30),
//                     //                             SizedBox(height: 5),
//                     //                             Text('View More',
//                     //                                 style:
//                     //                                     TextStyle(fontSize: 12)),
//                     //                           ],
//                     //                         ),
//                     //                       ),
//                     //                     );
//                     //                   }
//                     //
//                     //                   // final catName = categoryList[index];
//                     //                   // final icon = categoryIcons[catName] ??
//                     //                   //     Icons.category;
//                     //
//                     //                   return InkWell(
//                     //                     onTap: () {
//                     //                       showDialog(
//                     //                         context: context,
//                     //                         builder: (context) {
//                     //                           return Center(
//                     //                             child: Container(
//                     //                               width: 70.w,
//                     //                               height: 70.w,
//                     //                               padding:
//                     //                                   const EdgeInsets.all(16),
//                     //                               decoration: BoxDecoration(
//                     //                                 color: Colors.white,
//                     //                                 borderRadius:
//                     //                                     BorderRadius.circular(12),
//                     //                                 boxShadow: [
//                     //                                   BoxShadow(
//                     //                                     color: Colors.black26,
//                     //                                     blurRadius: 8,
//                     //                                     offset:
//                     //                                         const Offset(0, 4),
//                     //                                   ),
//                     //                                 ],
//                     //                               ),
//                     //                               child: Center(
//                     //                                 child: Column(
//                     //                                   mainAxisSize:
//                     //                                       MainAxisSize.min,
//                     //                                   children: [
//                     //                                     Icon(icon,
//                     //                                         size: 50,
//                     //                                         color: Colors.red),
//                     //                                     const SizedBox(
//                     //                                         height: 10),
//                     //                                     Text(
//                     //                                       catName,
//                     //                                       textAlign:
//                     //                                           TextAlign.center,
//                     //                                       style: TextStyle(
//                     //                                         fontSize: 14.sp,
//                     //                                         fontWeight:
//                     //                                             FontWeight.bold,
//                     //                                       ),
//                     //                                     ),
//                     //                                     // const SizedBox(height: 20),
//                     //                                     // ElevatedButton(
//                     //                                     //   onPressed: () {
//                     //                                     //     Navigator.pop(context); // Close dialog
//                     //                                     //     Navigator.of(context).push(
//                     //                                     //       MaterialPageRoute(
//                     //                                     //         builder: (context) => OffersScreen(
//                     //                                     //           selectedCatID: catName,
//                     //                                     //         ),
//                     //                                     //       ),
//                     //                                     //     );
//                     //                                     //   },
//                     //                                     //   child: const Text("Continue"),
//                     //                                     // ),
//                     //                                   ],
//                     //                                 ),
//                     //                               ),
//                     //                             ),
//                     //                           );
//                     //                         },
//                     //                       );
//                     //                     },
//                     //                     child: SizedBox(
//                     //                       width: controller.listItemWidth,
//                     //                       child: Column(
//                     //                         children: [
//                     //                           Container(
//                     //                             width: 50,
//                     //                             height: 50,
//                     //                             decoration: BoxDecoration(
//                     //                               border: catName ==
//                     //                                       controller.selectedCatID
//                     //                                   ? Border.all(
//                     //                                       color: const Color(
//                     //                                           0xFFDB2020),
//                     //                                       width: 3.0,
//                     //                                     )
//                     //                                   : null,
//                     //                             ),
//                     //                             child: Icon(icon,
//                     //                                 size: 40, color: Colors.red),
//                     //                           ),
//                     //                           const SizedBox(height: 3),
//                     //                           SizedBox(
//                     //                             width: controller.listItemWidth,
//                     //                             child: Text(
//                     //                               catName,
//                     //                               style: TextStyle(
//                     //                                 fontSize: 8.sp,
//                     //                                 fontWeight: FontWeight.bold,
//                     //                               ),
//                     //                               textAlign: TextAlign.center,
//                     //                               overflow: TextOverflow.ellipsis,
//                     //                               maxLines: 2,
//                     //                             ),
//                     //                           ),
//                     //                         ],
//                     //                       ),
//                     //                     ),
//                     //                   );
//                     //                 },
//                     //                 separatorBuilder: (context, index) =>
//                     //                     const VerticalDivider(
//                     //                         width: 5, color: Colors.transparent),
//                     //               );
//                     //             },
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//
//                     StreamBuilder<List<OffersColl>>(
//                       stream: isar.offersColls
//                           .filter()
//                           .isBigDaysEqualTo(true)
//                           .selectedCityEqualTo(controller.selectedCity)
//                           .build()
//                           .watch(fireImmediately: true),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//
//                         if (snapshot.hasError) {
//                           return Center(
//                               child: Text('Error: ${snapshot.error}'));
//                         }
//
//                         List<OffersColl> bigDaysOffers = snapshot.data ?? [];
//
//                         return Visibility(
//                           visible: bigDaysOffers.isNotEmpty,
//                           child: Column(
//                             children: [
//                               const Divider(),
//                               Card(
//                                 elevation: 0,
//                                 color: const Color(0xFF87CEEB),
//                                 // Even lighter shade of blue
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'BIG DAYS OFFERS',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.bold,
//                                       height: 1,
//                                       letterSpacing: 0.02,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const Divider(),
//                               SizedBox(height: 2.h),
//                               CarouselSlider.builder(
//                                 itemCount: bigDaysOffers.length,
//                                 options: CarouselOptions(
//                                   height: 200,
//                                   viewportFraction: 0.8,
//                                   enlargeCenterPage: true,
//                                   autoPlay: true,
//                                   autoPlayInterval: const Duration(seconds: 3),
//                                 ),
//                                 itemBuilder: (context, index, realIndex) {
//                                   var offer = bigDaysOffers[index];
//                                   return GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               OfferDetailsScreen(
//                                                   offerID: offer.offerID),
//                                         ),
//                                       );
//                                     },
//                                     child: Card(
//                                       elevation: 4,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: LayoutBuilder(
//                                         builder: (context, constraints) {
//                                           return Row(
//                                             children: [
//                                               Expanded(
//                                                 flex: 3,
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.all(
//                                                       12.0),
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                     CrossAxisAlignment
//                                                         .start,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                         children: [
//                                                           Flexible(
//                                                             child: Text(
//                                                               offer.offerName,
//                                                               style:
//                                                               const TextStyle(
//                                                                 fontSize: 18,
//                                                                 fontWeight:
//                                                                 FontWeight
//                                                                     .bold,
//                                                               ),
//                                                               maxLines: 2,
//                                                               overflow:
//                                                               TextOverflow
//                                                                   .ellipsis,
//                                                             ),
//                                                           ),
//                                                           Row(
//                                                             mainAxisSize:
//                                                             MainAxisSize
//                                                                 .min,
//                                                             children: [
//                                                               const Icon(
//                                                                 Icons.favorite,
//                                                                 color:
//                                                                 Colors.red,
//                                                                 size: 20,
//                                                               ),
//                                                               const SizedBox(
//                                                                   width: 4),
//                                                               Text(
//                                                                 '${offer.likesCount}',
//                                                                 style:
//                                                                 const TextStyle(
//                                                                   color: Colors
//                                                                       .red,
//                                                                   fontSize: 14,
//                                                                   fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(height: 8),
//                                                       Flexible(
//                                                         child: Text(
//                                                           offer.offerAddress,
//                                                           style: TextStyle(
//                                                             fontSize: 14,
//                                                             color: Colors
//                                                                 .grey[600],
//                                                           ),
//                                                           maxLines: 2,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                       const Spacer(),
//                                                       ElevatedButton(
//                                                         onPressed: () {
//                                                           Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   OfferDetailsScreen(
//                                                                       offerID: offer
//                                                                           .offerID),
//                                                             ),
//                                                           );
//                                                         },
//                                                         style: ElevatedButton
//                                                             .styleFrom(
//                                                           backgroundColor:
//                                                           Colors.black,
//                                                           shape:
//                                                           RoundedRectangleBorder(
//                                                             borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                 10),
//                                                           ),
//                                                         ),
//                                                         child: const Text(
//                                                           'VIEW OFFERS',
//                                                           style: TextStyle(
//                                                               color:
//                                                               Colors.white,
//                                                               fontSize: 12),
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 8),
//                                                       StreamBuilder<
//                                                           DocumentSnapshot>(
//                                                         stream: FirebaseFirestore
//                                                             .instance
//                                                             .collection(
//                                                             'candidOffers')
//                                                             .doc(offer.offerID)
//                                                             .snapshots(),
//                                                         builder: (context,
//                                                             snapshot) {
//                                                           if (snapshot
//                                                               .connectionState ==
//                                                               ConnectionState
//                                                                   .waiting) {
//                                                             return const SizedBox(
//                                                               height: 20,
//                                                               width: 20,
//                                                               child:
//                                                               CircularProgressIndicator(
//                                                                   strokeWidth:
//                                                                   2),
//                                                             );
//                                                           }
//
//                                                           if (snapshot
//                                                               .hasError) {
//                                                             return Text(
//                                                                 'Error: ${snapshot.error}',
//                                                                 style:
//                                                                 const TextStyle(
//                                                                     fontSize:
//                                                                     12));
//                                                           }
//
//                                                           if (!snapshot
//                                                               .hasData ||
//                                                               !snapshot.data!
//                                                                   .exists) {
//                                                             return const Text(
//                                                                 'Offer not found',
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                     12));
//                                                           }
//
//                                                           final data = snapshot
//                                                               .data!
//                                                               .data()
//                                                           as Map<String,
//                                                               dynamic>?;
//
//                                                           if (data == null) {
//                                                             return const Text(
//                                                                 'No data available',
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                     12));
//                                                           }
//
//                                                           final cumulativeRating =
//                                                               (data['cumulativeRating']
//                                                               as num?)
//                                                                   ?.toDouble() ??
//                                                                   0.0;
//                                                           final ratingCount =
//                                                               (data['ratingCount']
//                                                               as int?) ??
//                                                                   0;
//                                                           final averageRating =
//                                                           ratingCount > 0
//                                                               ? cumulativeRating /
//                                                               ratingCount
//                                                               : 0.0;
//
//                                                           return Row(
//                                                             mainAxisSize:
//                                                             MainAxisSize
//                                                                 .min,
//                                                             children: [
//                                                               ...List.generate(
//                                                                   5, (index) {
//                                                                 return Icon(
//                                                                   index <
//                                                                       averageRating
//                                                                           .round()
//                                                                       ? Icons
//                                                                       .star
//                                                                       : Icons
//                                                                       .star_border,
//                                                                   color: Colors
//                                                                       .amber,
//                                                                   size: 16,
//                                                                 );
//                                                               }),
//                                                               const SizedBox(
//                                                                   width: 4),
//                                                               Text(
//                                                                 ratingCount > 0
//                                                                     ? '${averageRating.toStringAsFixed(1)} / 5'
//                                                                     : 'No ratings',
//                                                                 style:
//                                                                 const TextStyle(
//                                                                   fontSize: 12,
//                                                                   fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           );
//                                                         },
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 flex: 2,
//                                                 child: ClipRRect(
//                                                   borderRadius:
//                                                   const BorderRadius
//                                                       .horizontal(
//                                                       right:
//                                                       Radius.circular(
//                                                           10)),
//                                                   child: offer.offerImages
//                                                       .isNotEmpty
//                                                       ? CachedNetworkImage(
//                                                     imageUrl: offer
//                                                         .offerImages
//                                                         .first,
//                                                     fit: BoxFit.cover,
//                                                     height:
//                                                     double.infinity,
//                                                   )
//                                                       : Container(
//                                                     color: Colors.grey,
//                                                     child: const Center(
//                                                       child: Text(
//                                                           'No Image'),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               )
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     StreamBuilder<List<OffersColl>>(
//                       stream: isar.offersColls
//                           .filter()
//                           .isTrendingEqualTo(true)
//                           .offerTypeEqualTo('product')
//                           .selectedCityEqualTo(controller.selectedCity)
//                           .build()
//                           .watch(fireImmediately: true),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//
//                         if (snapshot.hasError) {
//                           return Center(child: Text('Error: ${snapshot.error}'));
//                         }
//
//                         List<OffersColl> isTrending = snapshot.data ?? [];
//
//                         // ✅ Use SingleChildScrollView to avoid overflow when content is taller than screen
//                         return Visibility(
//                           visible: isTrending.isNotEmpty,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Divider(),
//                                   Card(
//                                     elevation: 0,
//                                     color: const Color(0xFFDC2121),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                     ),
//                                     child: const Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Text(
//                                         '🔥 Trending Offers',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const Divider(),
//                                   const SizedBox(height: 8),
//
//                                   // ✅ Constrain the Carousel height
//                                   CarouselSlider.builder(
//                                     itemCount: isTrending.length,
//                                     options: CarouselOptions(
//                                       height: 240, // increased slightly for better layout
//                                       viewportFraction: 0.85,
//                                       enlargeCenterPage: true,
//                                       autoPlay: true,
//                                       autoPlayInterval: const Duration(seconds: 3),
//                                       autoPlayAnimationDuration: const Duration(milliseconds: 800),
//                                     ),
//                                     itemBuilder: (context, index, realIndex) {
//                                       var offer = isTrending[index];
//                                       final imageUrl = offer.offerImages.isNotEmpty
//                                           ? offer.offerImages.first
//                                           : null;
//
//                                       return SizedBox(
//                                         height: 240,
//                                         child: Card(
//                                           elevation: 4,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                           clipBehavior: Clip.antiAlias,
//                                           child: Column(
//                                             mainAxisSize: MainAxisSize.min, // 👈 Add this line
//                                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                                             children: [
//                                               // ✅ Image area
//                                               SizedBox(
//                                                 height: 140,
//                                                 child: imageUrl != null
//                                                     ? CachedNetworkImage(
//                                                   imageUrl: imageUrl,
//                                                   fit: BoxFit.cover,
//                                                   placeholder: (context, url) =>
//                                                   const Center(
//                                                     child: CircularProgressIndicator(
//                                                         strokeWidth: 2),
//                                                   ),
//                                                   errorWidget: (context, url, error) =>
//                                                       Container(
//                                                         color: Colors.grey[200],
//                                                         child: const Center(
//                                                           child: Icon(Icons.broken_image,
//                                                               color: Colors.grey, size: 40),
//                                                         ),
//                                                       ),
//                                                 )
//                                                     : Container(
//                                                   color: Colors.grey[200],
//                                                   child: const Center(
//                                                     child: Icon(Icons.image_not_supported,
//                                                         color: Colors.grey, size: 40),
//                                                   ),
//                                                 ),
//                                               ),
//
//                                               // ✅ Offer Details area
//                                               Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Column(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       offer.offerName,
//                                                       style: const TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight: FontWeight.bold,
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       offer.offerAddress,
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         color: Colors.grey[600],
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ) ,
//                     // SizedBox(
//                     //   height: 2.h,
//                     // ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 18),
//                       child: Card(
//                         elevation: 0,
//                         color: const Color(0xFF2C3E6C),
//                         // Even lighter shade of blue
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'FEATURED PRODUCT OFFERS',
//                             style: GoogleFonts.workSans(
//                               color: Colors.white,
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w600,
//                               height: 1,
//                               letterSpacing: 0.02,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 2.h,
//                     ),
//                     SingleChildScrollView(
//                       child: Container(
//                         height: 25.h,
//                         child: Stack(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: StreamBuilder<List<OffersColl>>(
//                                     stream: isar.offersColls
//                                         .filter()
//                                         .offerNameIsNotEmpty()
//                                         .selectedCityEqualTo(controller.selectedCity)
//                                         .offerTypeEqualTo('product')
//                                         .sortByDistanceFromUserInMeters()
//                                         .build()
//                                         .watch(fireImmediately: true),
//                                     builder: (context, snapshot) {
//                                       if (snapshot.connectionState ==
//                                           ConnectionState.waiting) {
//                                         return const Center(
//                                             child: CircularProgressIndicator());
//                                       }
//                                       if (snapshot.hasError) {
//                                         return Center(
//                                             child: Text(
//                                                 'Error: ${snapshot.error}'));
//                                       }
//                                       List<OffersColl> offers =
//                                           snapshot.data ?? [];
//                                       if (offers.isEmpty) {
//                                         return Center(
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: () =>
//                                                       _showPopup(context),
//                                                   child: Image.asset(
//                                                     'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                       // Debug print to check the length of the offers list
//                                       print('Offers length: ${offers.length}');
//                                       // Make sure that the length is correctly handled
//                                       int itemCount = offers.length > 10
//                                           ? 11
//                                           : offers.length;
//                                       return ListView.separated(
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         itemCount: itemCount,
//                                         itemBuilder: (context, index) {
//                                           print(
//                                               'Building item at index: $index');
//                                           if (index == 10 &&
//                                               offers.length > 10) {
//                                             // View More item
//                                             return GestureDetector(
//                                               onTap: () {
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                     const ServiceListing(), // Assuming StoreListing is a widget
//                                                   ),
//                                                 );
//                                               },
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                 BorderRadius.circular(10),
//                                                 child: const Center(
//                                                   child: Icon(
//                                                     Icons.arrow_forward_ios,
//                                                     // Replace with the icon you prefer
//                                                     color: Colors.black,
//                                                     size:
//                                                     30, // Adjust icon size as needed
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           }
//
//                                           // Safety check to prevent index out of range errors
//                                           if (index >= offers.length) {
//                                             print(
//                                                 'Index $index out of range for offers list');
//                                             return const SizedBox
//                                                 .shrink(); // Return an empty widget if index is out of range
//                                           }
//                                           var ele = offers[index];
//                                           return Container(
//                                             width: MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.92,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                               BorderRadius.circular(16),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.black
//                                                       .withOpacity(0.05),
//                                                   offset: const Offset(0, 4),
//                                                   blurRadius: 15,
//                                                   spreadRadius: 1,
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Material(
//                                               // Added for ripple effect
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 borderRadius:
//                                                 BorderRadius.circular(16),
//                                                 onTap: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           OfferDetailsScreen(
//                                                               offerID:
//                                                               ele.offerID),
//                                                     ),
//                                                   );
//                                                 },
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                                   children: [
//                                                     // Left Content Section
//                                                     Expanded(
//                                                       flex: 3,
//                                                       child: SingleChildScrollView( // 👈 **FIX 1: Wrap the Column with a SingleChildScrollView**
//                                                         child: Padding(
//                                                           padding:
//                                                           const EdgeInsets
//                                                               .all(16),
//                                                           child: Column(
//                                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                                             children: [
//                                                               // TOP CONTENT
//                                                               // Note: You had an Expanded here causing the overflow. Removing it
//                                                               // and wrapping the parent Column with SingleChildScrollView is the
//                                                               // correct approach since you're already in a scrollable view.
//                                                               Column(
//                                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                                 children: [
//                                                                   // Offer Name and Likes Section
//                                                                   Row(
//                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                     children: [
//                                                                       Expanded(
//                                                                         child: Text(
//                                                                           ele.offerName,
//                                                                           style: const TextStyle(
//                                                                             fontSize: 18,
//                                                                             fontWeight: FontWeight.w700,
//                                                                             color: Color(0xFF2C3E50),
//                                                                             height: 1.3,
//                                                                           ),
//                                                                           maxLines: 2,
//                                                                           overflow: TextOverflow.ellipsis,
//                                                                         ),
//                                                                       ),
//                                                                       Container(
//                                                                         padding: const EdgeInsets.symmetric(
//                                                                           horizontal: 8,
//                                                                           vertical: 4,
//                                                                         ),
//                                                                         decoration: BoxDecoration(
//                                                                           color: Colors.red.shade50,
//                                                                           borderRadius: BorderRadius.circular(20),
//                                                                         ),
//                                                                         child: Row(
//                                                                           mainAxisSize: MainAxisSize.min,
//                                                                           children: [
//                                                                             Icon(
//                                                                               Icons.favorite,
//                                                                               color: Colors.red.shade400,
//                                                                               size: 16,
//                                                                             ),
//                                                                             const SizedBox(width: 4),
//                                                                             Text(
//                                                                               '${ele.likesCount}',
//                                                                               style: TextStyle(
//                                                                                 color: Colors.red.shade400,
//                                                                                 fontSize: 14,
//                                                                                 fontWeight: FontWeight.w600,
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                   const SizedBox(height: 12),
//                                                                   // Address Section
//                                                                   Row(
//                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                     children: [
//                                                                       Icon(
//                                                                         Icons.location_on_outlined,
//                                                                         size: 16,
//                                                                         color: Colors.grey[600],
//                                                                       ),
//                                                                       const SizedBox(width: 4),
//                                                                       Expanded(
//                                                                         child: Text(
//                                                                           ele.offerAddress,
//                                                                           style: TextStyle(
//                                                                             fontSize: 14,
//                                                                             color: Colors.grey[600],
//                                                                             height: 1.4,
//                                                                           ),
//                                                                           maxLines: 2,
//                                                                           overflow: TextOverflow.ellipsis,
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               const SizedBox(height: 8),
//
//                                                               // Rating Section stays below safely
//                                                               StreamBuilder<DocumentSnapshot>(
//                                                                 stream: FirebaseFirestore.instance
//                                                                     .collection('candidOffers')
//                                                                     .doc(ele.offerID)
//                                                                     .snapshots(),
//                                                                 builder: (context, snapshot) {
//                                                                   if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                     return const LinearProgressIndicator(
//                                                                       minHeight: 2,
//                                                                       backgroundColor: Colors.transparent,
//                                                                     );
//                                                                   }
//
//                                                                   if (!snapshot.hasData || !snapshot.data!.exists) {
//                                                                     return const SizedBox.shrink();
//                                                                   }
//
//                                                                   final data = snapshot.data!.data() as Map<String, dynamic>?;
//                                                                   if (data == null) {
//                                                                     return const SizedBox.shrink();
//                                                                   }
//
//                                                                   final cumulativeRating =
//                                                                       (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
//                                                                   final ratingCount = (data['ratingCount'] as int?) ?? 0;
//                                                                   final averageRating =
//                                                                   ratingCount > 0 ? cumulativeRating / ratingCount : 0.0;
//
//                                                                   return Row(
//                                                                     mainAxisSize: MainAxisSize.min,
//                                                                     children: [
//                                                                       ...List.generate(5, (index) {
//                                                                         return Icon(
//                                                                           index < averageRating.round()
//                                                                               ? Icons.star_rounded
//                                                                               : Icons.star_outline_rounded,
//                                                                           color: const Color(0xFFFFB800),
//                                                                           size: 18,
//                                                                         );
//                                                                       }),
//                                                                       const SizedBox(width: 4),
//                                                                       Expanded(
//                                                                         child: Text(
//                                                                           ratingCount > 0
//                                                                               ? '${averageRating.toStringAsFixed(1)} / 5'
//                                                                               : 'No ratings yet',
//                                                                           style: const TextStyle(
//                                                                             fontSize: 13,
//                                                                             fontWeight: FontWeight.w500,
//                                                                             color: Color(0xFF6B7280),
//                                                                           ),
//                                                                           overflow: TextOverflow.ellipsis,
//                                                                           maxLines: 1,
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   );
//                                                                 },
//                                                               ),
//
//                                                               const SizedBox(height: 16),
//
//                                                               // VIEW OFFERS BUTTON (pinned at bottom)
//                                                               SizedBox(
//                                                                 width: double.infinity,
//                                                                 child: ElevatedButton(
//                                                                   onPressed: () {
//                                                                     Navigator.push(
//                                                                       context,
//                                                                       MaterialPageRoute(
//                                                                         builder: (context) =>
//                                                                             OfferDetailsScreen(offerID: ele.offerID),
//                                                                       ),
//                                                                     );
//                                                                   },
//                                                                   style: ElevatedButton.styleFrom(
//                                                                     foregroundColor: Colors.white,
//                                                                     backgroundColor: const Color(0xFF1A1A1A),
//                                                                     padding: const EdgeInsets.symmetric(vertical: 12),
//                                                                     shape: RoundedRectangleBorder(
//                                                                       borderRadius: BorderRadius.circular(10),
//                                                                     ),
//                                                                     elevation: 0,
//                                                                   ),
//                                                                   child: const Text(
//                                                                     'VIEW OFFERS',
//                                                                     style: TextStyle(
//                                                                       fontSize: 14,
//                                                                       fontWeight: FontWeight.w600,
//                                                                       letterSpacing: 0.5,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     // Right Image Section
//                                                     Expanded(
//                                                       flex: 2,
//                                                       child: ClipRRect(
//                                                         borderRadius:
//                                                         const BorderRadius
//                                                             .only(
//                                                           topRight:
//                                                           Radius.circular(
//                                                               16),
//                                                           bottomRight:
//                                                           Radius.circular(
//                                                               16),
//                                                         ),
//                                                         child: SizedBox(
//                                                           height: 220,
//                                                           // Fixed height for consistency
//                                                           child: ele.offerImages
//                                                               .isNotEmpty
//                                                               ? CachedNetworkImage(
//                                                             imageUrl: ele
//                                                                 .offerImages
//                                                                 .first,
//                                                             fit: BoxFit
//                                                                 .cover,
//                                                             placeholder: (context,
//                                                                 url) =>
//                                                                 Container(
//                                                                   color: Colors
//                                                                       .grey[
//                                                                   100],
//                                                                   child:
//                                                                   Center(
//                                                                     child:
//                                                                     CircularProgressIndicator(
//                                                                       strokeWidth:
//                                                                       2,
//                                                                       color: Colors
//                                                                           .grey[400],
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                             errorWidget: (context,
//                                                                 url,
//                                                                 error) =>
//                                                                 Container(
//                                                                   color: Colors
//                                                                       .grey[
//                                                                   100],
//                                                                   child:
//                                                                   const Center(
//                                                                     child:
//                                                                     Icon(
//                                                                       Icons
//                                                                           .image_not_supported_outlined,
//                                                                       color: Colors
//                                                                           .grey,
//                                                                       size:
//                                                                       32,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                           )
//                                                               : Container(
//                                                             color: Colors
//                                                                 .grey[
//                                                             100],
//                                                             child:
//                                                             const Center(
//                                                               child: Icon(
//                                                                 Icons
//                                                                     .image_outlined,
//                                                                 color: Colors
//                                                                     .grey,
//                                                                 size: 32,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         separatorBuilder: (context, index) {
//                                           return const SizedBox(width: 4);
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),                    // const SizedBox(height: 8),
//                     // Padding(
//                     //   padding: const EdgeInsets.only(left: 20),
//                     //   child: Text(
//                     //     'Featured Products',
//                     //     textScaleFactor: 1.5,
//                     //     style: TextStyle(
//                     //       fontSize: 10.sp, // Adjust the font size as needed
//                     //       fontWeight: FontWeight.bold,
//                     //       color: Colors.black,
//                     //       // You can add more styling properties here such as fontFamily, letterSpacing, etc.
//                     //     ),
//                     //   ),
//                     // ),
//                     // SizedBox(height: 2.h,),
//                     // Container(
//                     //   height: 25.h,
//                     //   padding: const EdgeInsets.only(left: 8),
//                     //   child: StreamBuilder<List<OffersColl>>(
//                     //     stream: isar.offersColls
//                     //         .filter()
//                     //         .offerNameIsNotEmpty()
//                     //         .selectedCityEqualTo(controller.selectedCity)
//                     //         .offerTypeEqualTo('product') // Filter only product offers
//                     //         .sortByDistanceFromUserInMeters()
//                     //         .build()
//                     //         .watch(fireImmediately: true),
//                     //     builder: (context, snapshot) {
//                     //       List<OffersColl>? offers = [];
//                     //       if (snapshot.hasData) {
//                     //         offers = snapshot.data;
//                     //       }
//                     //       return AnimatedSwitcher(
//                     //         duration: const Duration(seconds: 1),
//                     //         child: !snapshot.hasData || controller.trendingNowIsLoading
//                     //             ? const Center(
//                     //           child: CircularProgressIndicator(),
//                     //         )
//                     //             : offers!.isEmpty
//                     //             ? const Center(
//                     //           child: Card(
//                     //             color: Colors.black,
//                     //             child: Padding(
//                     //               padding: EdgeInsets.all(8.0),
//                     //               child: Text(
//                     //                 'No offers found',
//                     //                 textScaleFactor: 1.2,
//                     //                 style: TextStyle(
//                     //                   color: Colors.white,
//                     //                   fontWeight: FontWeight.bold,
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //           ),
//                     //         )
//                     //             : ListView.separated(
//                     //           shrinkWrap: true,
//                     //           scrollDirection: Axis.horizontal,
//                     //           itemCount: offers.length,
//                     //           separatorBuilder: (BuildContext context, int index) {
//                     //             return const SizedBox(width: 10); // Adjust spacing between items
//                     //           },
//                     //           itemBuilder: (context, index) {
//                     //             OffersColl offer = offers![index];
//                     //             return buildItem(
//                     //               id: offer.offerID,
//                     //               isFavorite: offer.isInWishList,
//                     //               title: offer.productName,
//                     //               discount: '${offer.discountNo} %',
//                     //               offerImage: offer.offerImages.first,
//                     //               context: context,
//                     //             );
//                     //           },
//                     //         ),
//                     //       );
//                     //     },
//                     //   ),
//                     // ),
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Card(
//                                 elevation: 4,
//                                 // Adjust the elevation for shadow effect
//                                 color: Color(0xFF2C3E6C),
//                                 // Background color of the card
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       8.0), // Adjust the border radius as needed
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'SERVICE CATEGORIES',
//                                     style: GoogleFonts.workSans(
//                                       color: Colors.white,
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w600,
//                                       height: 1,
//                                       // Adjusted to 1 for better line height
//                                       letterSpacing: 0.02,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 0.0),
//                                 // Adjust the right padding as needed
//                                 child: SizedBox(
//                                   width: 25.w, // Adjust as needed
//                                   height: 34, // Adjust as neededeeded
//                                   child: MyWidgets().getLargeButton(
//                                     title: 'Browse All',
//                                     onPress: () =>
//                                         Get.to(() => ServiceCategory()),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Add space between the sections
//                           LayoutBuilder(
//                             builder: (context, constraints) {
//                               // Calculate responsive sizes based on screen width
//                               final screenWidth =
//                                   MediaQuery.of(context).size.width;
//                               final isSmallScreen = screenWidth < 360;
//                               final isMediumScreen =
//                                   screenWidth >= 360 && screenWidth < 600;
//                               final isLargeScreen = screenWidth >= 600;
//
//                               // Adjust sizes based on screen size
//                               final fontSize = isSmallScreen
//                                   ? 12.sp
//                                   : isMediumScreen
//                                   ? 14.sp
//                                   : 16.sp;
//
//                               final iconSize = isSmallScreen
//                                   ? 14.sp
//                                   : isMediumScreen
//                                   ? 18.sp
//                                   : 20.sp;
//
//                               final containerSize = isSmallScreen
//                                   ? 28.0
//                                   : isMediumScreen
//                                   ? 32.0
//                                   : 36.0;
//
//                               final horizontalPadding = isSmallScreen
//                                   ? 12.0
//                                   : isMediumScreen
//                                   ? 16.0
//                                   : 20.0;
//
//                               return Container(
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: 8.0,
//                                   horizontal: horizontalPadding,
//                                 ),
//                                 constraints: BoxConstraints(
//                                   maxWidth:
//                                   isLargeScreen ? 600.0 : double.infinity,
//                                 ),
//                                 child: FittedBox(
//                                   fit: BoxFit.scaleDown,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           'Explore More Service Categories',
//                                           style: GoogleFonts.workSans(
//                                             color: Colors.black,
//                                             fontSize: fontSize,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                           width: isSmallScreen ? 4.w : 8.w),
//                                       InkWell(
//                                         onTap: () {
//                                           controller.scrollToEnd(
//                                               controller.scrollController2);
//                                         },
//                                         child: Container(
//                                           width: containerSize,
//                                           height: containerSize,
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             shape: BoxShape.circle,
//                                             // Add subtle shadow for better visibility
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.black
//                                                     .withOpacity(0.1),
//                                                 blurRadius: 4,
//                                                 offset: Offset(0, 2),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Center(
//                                             child: Icon(
//                                               Icons.arrow_forward,
//                                               color: Colors.white,
//                                               // size: iconSize,
//                                               size: 30,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           )
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 1.h,),
//                     Stack(
//                       textDirection: TextDirection.rtl,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             controller.toggleCatsName();
//                           },
//                           child: AnimatedContainer(
//                             height: controller.showCatsName ? 12.h : 14.h,
//                             width: 100.w,
//                             duration: const Duration(milliseconds: 300),
//                             child: StreamBuilder(
//                               stream: isar.catsColls
//                                   .filter()
//                                   .catNameIsNotEmpty()
//                                   .catTypeEqualTo('service')
//                                   .not()
//                                   .catNameEqualTo('Popular')
//                                   .build()
//                                   .watch(fireImmediately: true),
//                               builder: (context, snapshot) {
//                                 List<CatsColl> catsList = [];
//                                 if (snapshot.data != null &&
//                                     !snapshot.hasError) {
//                                   catsList = snapshot.data as List<CatsColl>;
//
//                                   if (controller.selectedCatID.isEmpty &&
//                                       catsList.isNotEmpty) {
//                                     Future.delayed(Duration.zero, () {
//                                       controller.selectedCatID =
//                                           catsList.first.catID;
//                                       controller.update();
//                                     });
//                                   }
//                                 } else {
//                                   return const Center(
//                                       child: Text('Loading...'));
//                                 }
//
//                                 int itemCount =
//                                 catsList.length > 10 ? 11 : catsList.length;
//
//                                 return AnimatedSwitcher(
//                                   duration: const Duration(milliseconds: 0),
//                                   child: catsList.isEmpty
//                                       ? const Text('Empty List')
//                                       : ListView.separated(
//                                     controller:
//                                     controller.scrollController2,
//                                     shrinkWrap: true,
//                                     itemCount: itemCount,
//                                     scrollDirection: Axis.horizontal,
//                                     physics:
//                                     const AlwaysScrollableScrollPhysics(),
//                                     itemBuilder: (context, index) {
//                                       if (index == 10 &&
//                                           catsList.length > 10) {
//                                         return InkWell(
//                                           onTap: () {
//                                             Navigator.of(context).push(
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                 const OfferCategories(),
//                                               ),
//                                             );
//                                           },
//                                           child: SizedBox(
//                                             width:
//                                             controller.listItemWidth,
//                                             child: const Column(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .center,
//                                               children: [
//                                                 Icon(Icons.more_horiz,
//                                                     size: 30),
//                                                 SizedBox(height: 5),
//                                                 Text('View More',
//                                                     style: TextStyle(
//                                                         fontSize: 12)),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       }
//
//                                       var cat = catsList[index];
//
//                                       return InkWell(
//                                         onTap: () {
//                                           Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   OffersScreen(
//                                                       selectedCatID:
//                                                       cat.catID),
//                                             ),
//                                           );
//                                         },
//                                         child: SizedBox(
//                                           width: controller.listItemWidth,
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 decoration: BoxDecoration(
//                                                   border: cat.catID ==
//                                                       controller
//                                                           .selectedCatID
//                                                       ? Border.all(
//                                                       color: const Color(
//                                                           0xFFDB2020),
//                                                       width: 3.0)
//                                                       : null,
//                                                 ),
//                                                 child: SvgPicture.network(
//                                                   cat.catImg,
//                                                   fit: BoxFit.contain,
//                                                   placeholderBuilder:
//                                                       (BuildContext
//                                                   context) =>
//                                                       Image.asset(
//                                                         'lib/Images/app_icon_mid.jpeg',
//                                                         fit: BoxFit.contain,
//                                                       ),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 3),
//                                               SizedBox(
//                                                 width: controller
//                                                     .listItemWidth,
//                                                 child: Text(
//                                                   cat.catName,
//                                                   style: TextStyle(
//                                                     fontSize: 8.sp,
//                                                     fontWeight:
//                                                     FontWeight.bold,
//                                                   ),
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   overflow: TextOverflow
//                                                       .ellipsis,
//                                                   maxLines: 3,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     separatorBuilder: (context, index) =>
//                                     const VerticalDivider(
//                                         width: 5,
//                                         color: Colors.transparent),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 4.h),
//                     // Center(
//                     //   child: Stack(
//                     //     textDirection: TextDirection.rtl,
//                     //     children: [
//                     //       InkWell(
//                     //         onTap: () {
//                     //           controller.toggleCatsName();
//                     //         },
//                     //         child: AnimatedContainer(
//                     //           height: controller.showCatsName ? 12.h : 14.h,
//                     //           width: 100.w,
//                     //           duration: const Duration(milliseconds: 300),
//                     //           child: Builder(
//                     //             builder: (context) {
//                     //               final categoryList =
//                     //                   mainCategories2.keys.toList();
//                     //               final itemCount = categoryList.length > 10
//                     //                   ? 11
//                     //                   : categoryList.length;
//                     //
//                     //               return ListView.separated(
//                     //                 controller: controller.scrollController1,
//                     //                 shrinkWrap: true,
//                     //                 itemCount: itemCount,
//                     //                 scrollDirection: Axis.horizontal,
//                     //                 physics:
//                     //                     const AlwaysScrollableScrollPhysics(),
//                     //                 itemBuilder: (context, index) {
//                     //                   if (index == 10 &&
//                     //                       categoryList.length > 10) {
//                     //                     // ✅ View More opens ServiceHomeScreen
//                     //                     return InkWell(
//                     //                       onTap: () {
//                     //                         Navigator.of(context).push(
//                     //                           MaterialPageRoute(
//                     //                             builder: (context) =>
//                     //                                 const ServiceHomeScreen(),
//                     //                           ),
//                     //                         );
//                     //                       },
//                     //                       child: SizedBox(
//                     //                         width: controller.listItemWidth,
//                     //                         child: const Column(
//                     //                           mainAxisAlignment:
//                     //                               MainAxisAlignment.center,
//                     //                           children: [
//                     //                             Icon(Icons.more_horiz, size: 30),
//                     //                             SizedBox(height: 5),
//                     //                             Text('View More',
//                     //                                 style:
//                     //                                     TextStyle(fontSize: 12)),
//                     //                           ],
//                     //                         ),
//                     //                       ),
//                     //                     );
//                     //                   }
//                     //
//                     //                   final catName = categoryList[index];
//                     //                   final icon = categoryIcons2[catName] ??
//                     //                       Icons.category;
//                     //
//                     //                   return InkWell(
//                     //                     onTap: () {
//                     //                       showDialog(
//                     //                         context: context,
//                     //                         builder: (context) {
//                     //                           return Center(
//                     //                             child: Container(
//                     //                               width: 70.w,
//                     //                               height: 70.w,
//                     //                               padding:
//                     //                                   const EdgeInsets.all(16),
//                     //                               decoration: BoxDecoration(
//                     //                                 color: Colors.white,
//                     //                                 borderRadius:
//                     //                                     BorderRadius.circular(12),
//                     //                                 boxShadow: [
//                     //                                   BoxShadow(
//                     //                                     color: Colors.black26,
//                     //                                     blurRadius: 8,
//                     //                                     offset:
//                     //                                         const Offset(0, 4),
//                     //                                   ),
//                     //                                 ],
//                     //                               ),
//                     //                               child: Center(
//                     //                                 child: Column(
//                     //                                   mainAxisSize:
//                     //                                       MainAxisSize.min,
//                     //                                   children: [
//                     //                                     Icon(icon,
//                     //                                         size: 50,
//                     //                                         color: Colors.red),
//                     //                                     const SizedBox(
//                     //                                         height: 10),
//                     //                                     Text(
//                     //                                       catName,
//                     //                                       textAlign:
//                     //                                           TextAlign.center,
//                     //                                       style: TextStyle(
//                     //                                         fontSize: 14.sp,
//                     //                                         fontWeight:
//                     //                                             FontWeight.bold,
//                     //                                       ),
//                     //                                     ),
//                     //                                     // const SizedBox(height: 20),
//                     //                                     // ElevatedButton(
//                     //                                     //   onPressed: () {
//                     //                                     //     Navigator.pop(context); // Close dialog
//                     //                                     //     Navigator.of(context).push(
//                     //                                     //       MaterialPageRoute(
//                     //                                     //         builder: (context) => OffersScreen(
//                     //                                     //           selectedCatID: catName,
//                     //                                     //         ),
//                     //                                     //       ),
//                     //                                     //     );
//                     //                                     //   },
//                     //                                     //   child: const Text("Continue"),
//                     //                                     // ),
//                     //                                   ],
//                     //                                 ),
//                     //                               ),
//                     //                             ),
//                     //                           );
//                     //                         },
//                     //                       );
//                     //                     },
//                     //                     child: SizedBox(
//                     //                       width: controller.listItemWidth,
//                     //                       child: Column(
//                     //                         children: [
//                     //                           Container(
//                     //                             width: 50,
//                     //                             height: 50,
//                     //                             decoration: BoxDecoration(
//                     //                               border: catName ==
//                     //                                       controller.selectedCatID
//                     //                                   ? Border.all(
//                     //                                       color: const Color(
//                     //                                           0xFFDB2020),
//                     //                                       width: 3.0,
//                     //                                     )
//                     //                                   : null,
//                     //                             ),
//                     //                             child: Icon(icon,
//                     //                                 size: 40, color: Colors.red),
//                     //                           ),
//                     //                           const SizedBox(height: 3),
//                     //                           SizedBox(
//                     //                             width: controller.listItemWidth,
//                     //                             child: Text(
//                     //                               catName,
//                     //                               style: TextStyle(
//                     //                                 fontSize: 8.sp,
//                     //                                 fontWeight: FontWeight.bold,
//                     //                               ),
//                     //                               textAlign: TextAlign.center,
//                     //                               overflow: TextOverflow.ellipsis,
//                     //                               maxLines: 2,
//                     //                             ),
//                     //                           ),
//                     //                         ],
//                     //                       ),
//                     //                     ),
//                     //                   );
//                     //                 },
//                     //                 separatorBuilder: (context, index) =>
//                     //                     const VerticalDivider(
//                     //                         width: 5, color: Colors.transparent),
//                     //               );
//                     //             },
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                     StreamBuilder<List<OffersColl>>(
//                       stream: isar.offersColls
//                           .filter()
//                           .isTrendingEqualTo(true)
//                           .offerTypeEqualTo('service')
//                           .selectedCityEqualTo(controller.selectedCity)
//                           .build()
//                           .watch(fireImmediately: true),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//
//                         if (snapshot.hasError) {
//                           return Center(
//                               child: Text('Error: ${snapshot.error}'));
//                         }
//
//                         List<OffersColl> isTrending = snapshot.data ?? [];
//
//                         return Visibility(
//                           visible: isTrending.isNotEmpty,
//                           child: Column(
//                             children: [
//                               const Divider(),
//                               Card(
//                                 elevation: 0,
//                                 color: const Color(0xFFDC2121),
//                                 // Even lighter shade of blue
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text(
//                                     '🔥 Trending Offers',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const Divider(),
//                               SizedBox(height: 1.h),
//                               CarouselSlider.builder(
//                                 itemCount: isTrending.length,
//                                 options: CarouselOptions(
//                                   height: 31.h,
//                                   viewportFraction: 0.85,
//                                   enlargeCenterPage: true,
//                                   autoPlay: true,
//                                   autoPlayInterval: const Duration(seconds: 3),
//                                   autoPlayAnimationDuration:
//                                   const Duration(milliseconds: 800),
//                                 ),
//                                 itemBuilder: (context, index, realIndex) {
//                                   return _buildCarouselOfferCard(
//                                       isTrending[index], context, true);
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20),
//                       child: Card(
//                         elevation: 0,
//                         color: const Color(0xFF2C3E6C),
//                         // Even lighter shade of blue
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'FEATURED SERVICE OFFERS',
//                             style: GoogleFonts.workSans(
//                               color: Colors.white,
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w600,
//                               height: 1,
//                               letterSpacing: 0.02,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 2.h,
//                     ),
//                     Container(
//                       height: 25.h,
//                       padding: const EdgeInsets.only(left: 8),
//                       child: Stack(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: StreamBuilder(
//                                   stream: isar.offersColls
//                                       .filter()
//                                       .offerNameIsNotEmpty()
//                                       .selectedCityEqualTo(
//                                       controller.selectedCity)
//                                       .offerTypeEqualTo('service')
//                                       .sortByDistanceFromUserInMeters()
//                                       .build()
//                                       .watch(fireImmediately: true),
//                                   builder: (context, snapshot) {
//                                     List<OffersColl> offers = [];
//                                     if (snapshot.hasData) {
//                                       offers = snapshot.data ?? [];
//                                     }
//                                     return AnimatedSwitcher(
//                                       duration: const Duration(seconds: 1),
//                                       child:
//                                       !snapshot.hasData ||
//                                           controller
//                                               .trendingNowIsLoading
//                                           ? const Center(
//                                         child:
//                                         CircularProgressIndicator(),
//                                       )
//                                           : offers.isEmpty
//                                           ? Center(
//                                         child: Padding(
//                                           padding:
//                                           const EdgeInsets
//                                               .all(8.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment
//                                                 .spaceEvenly,
//                                             children: [
//                                               GestureDetector(
//                                                 onTap: () =>
//                                                     _showPopup(
//                                                         context),
//                                                 child:
//                                                 Image.asset(
//                                                   'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
//                                                   fit: BoxFit
//                                                       .contain,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                           : ListView.separated(
//                                         shrinkWrap: true,
//                                         scrollDirection:
//                                         Axis.horizontal,
//                                         itemCount:
//                                         offers.length > 10
//                                             ? 11
//                                             : offers.length,
//                                         itemBuilder:
//                                             (context, index) {
//                                           if (index == 10) {
//                                             // View More item
//                                             return GestureDetector(
//                                               onTap: () {
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder:
//                                                         (context) =>
//                                                     const storelisting(), // Assuming StoreListing is a widget
//                                                   ),
//                                                 );
//                                               },
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                 BorderRadius
//                                                     .circular(
//                                                     10),
//                                                 child:
//                                                 const Center(
//                                                   child: Icon(
//                                                     Icons
//                                                         .arrow_forward_ios,
//                                                     // Replace with the icon you prefer
//                                                     color: Colors
//                                                         .black,
//                                                     size:
//                                                     30, // Adjust icon size as needed
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                           var ele = offers[index];
//                                           return Container(
//                                             width: MediaQuery.of(
//                                                 context)
//                                                 .size
//                                                 .width *
//                                                 0.92,
//                                             decoration:
//                                             BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                               BorderRadius
//                                                   .circular(
//                                                   16),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors
//                                                       .black
//                                                       .withOpacity(
//                                                       0.05),
//                                                   offset:
//                                                   const Offset(
//                                                       0, 4),
//                                                   blurRadius: 15,
//                                                   spreadRadius: 1,
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Material(
//                                               // Added for ripple effect
//                                               color: Colors
//                                                   .transparent,
//                                               child: InkWell(
//                                                 borderRadius:
//                                                 BorderRadius
//                                                     .circular(
//                                                     16),
//                                                 onTap: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           OfferDetailsScreen(
//                                                               offerID:
//                                                               ele.offerID),
//                                                     ),
//                                                   );
//                                                 },
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                   CrossAxisAlignment
//                                                       .start,
//                                                   children: [
//                                                     // Left Content Section
//                                                     Expanded(
//                                                       flex: 3,
//                                                       child:
//                                                       SingleChildScrollView( // 👈 **FIX: Wrap the content with SingleChildScrollView**
//                                                         child: Padding(
//                                                           padding: const EdgeInsets
//                                                               .all(
//                                                               16),
//                                                           child:
//                                                           Column(
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.start,
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.spaceBetween,
//                                                             children: [
//                                                               // Offer Name and Likes Section
//                                                               Column(
//                                                                 crossAxisAlignment:
//                                                                 CrossAxisAlignment.start,
//                                                                 children: [
//                                                                   Row(
//                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                     children: [
//                                                                       Expanded(
//                                                                         child: Text(
//                                                                           ele.offerName,
//                                                                           style: const TextStyle(
//                                                                             fontSize: 18,
//                                                                             fontWeight: FontWeight.w700,
//                                                                             color: Color(0xFF2C3E50),
//                                                                             height: 1.3,
//                                                                           ),
//                                                                           maxLines: 2,
//                                                                           overflow: TextOverflow.ellipsis,
//                                                                         ),
//                                                                       ),
//                                                                       Container(
//                                                                         padding: const EdgeInsets.symmetric(
//                                                                           horizontal: 8,
//                                                                           vertical: 4,
//                                                                         ),
//                                                                         decoration: BoxDecoration(
//                                                                           color: Colors.red.shade50,
//                                                                           borderRadius: BorderRadius.circular(20),
//                                                                         ),
//                                                                         child: Row(
//                                                                           mainAxisSize: MainAxisSize.min,
//                                                                           children: [
//                                                                             Icon(
//                                                                               Icons.favorite,
//                                                                               color: Colors.red.shade400,
//                                                                               size: 16,
//                                                                             ),
//                                                                             const SizedBox(width: 4),
//                                                                             Text(
//                                                                               '${ele.likesCount}',
//                                                                               style: TextStyle(
//                                                                                 color: Colors.red.shade400,
//                                                                                 fontSize: 14,
//                                                                                 fontWeight: FontWeight.w600,
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                   const SizedBox(height: 12),
//                                                                   // Address Section
//                                                                   Row(
//                                                                     children: [
//                                                                       Icon(
//                                                                         Icons.location_on_outlined,
//                                                                         size: 16,
//                                                                         color: Colors.grey[600],
//                                                                       ),
//                                                                       const SizedBox(width: 4),
//                                                                       Expanded(
//                                                                         child: Text(
//                                                                           ele.offerAddress,
//                                                                           style: TextStyle(
//                                                                             fontSize: 14,
//                                                                             color: Colors.grey[600],
//                                                                             height: 1.4,
//                                                                           ),
//                                                                           maxLines: 2,
//                                                                           overflow: TextOverflow.ellipsis,
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 16),
//                                                               // Rating Section
//                                                               StreamBuilder<
//                                                                   DocumentSnapshot>(
//                                                                 stream:
//                                                                 FirebaseFirestore.instance.collection('candidOffers').doc(ele.offerID).snapshots(),
//                                                                 builder:
//                                                                     (context, snapshot) {
//                                                                   if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                     return const LinearProgressIndicator(
//                                                                       minHeight: 2,
//                                                                       backgroundColor: Colors.transparent,
//                                                                     );
//                                                                   }
//
//                                                                   if (!snapshot.hasData || !snapshot.data!.exists) {
//                                                                     return const SizedBox.shrink();
//                                                                   }
//
//                                                                   final data = snapshot.data!.data() as Map<String, dynamic>?;
//                                                                   if (data == null) {
//                                                                     return const SizedBox.shrink();
//                                                                   }
//
//                                                                   final cumulativeRating = (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
//                                                                   final ratingCount = (data['ratingCount'] as int?) ?? 0;
//                                                                   final averageRating = ratingCount > 0 ? cumulativeRating / ratingCount : 0.0;
//
//                                                                   return Column(
//                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                     children: [
//                                                                       Row(
//                                                                         mainAxisSize: MainAxisSize.min,
//                                                                         children: [
//                                                                           // Star icons with fixed size
//                                                                           ...List.generate(5, (index) {
//                                                                             return Icon(
//                                                                               index < averageRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
//                                                                               color: const Color(0xFFFFB800),
//                                                                               size: 18, // Slightly reduced size
//                                                                             );
//                                                                           }),
//                                                                           const SizedBox(width: 4),
//                                                                           // Reduced spacing
//                                                                           // Expandable text that handles overflow
//                                                                           Expanded(
//                                                                             child: Text(
//                                                                               ratingCount > 0 ? '${averageRating.toStringAsFixed(1)} / 5' : 'No ratings yet',
//                                                                               style: const TextStyle(
//                                                                                 fontSize: 13,
//                                                                                 // Slightly reduced font size
//                                                                                 fontWeight: FontWeight.w500,
//                                                                                 color: Color(0xFF6B7280),
//                                                                               ),
//                                                                               overflow: TextOverflow.ellipsis,
//                                                                               // Handle text overflow
//                                                                               maxLines: 1,
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       )
//                                                                     ],
//                                                                   );
//                                                                 },
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 16),
//                                                               // View Offers Button
//                                                               SizedBox(
//                                                                 width:
//                                                                 double.infinity,
//                                                                 child:
//                                                                 ElevatedButton(
//                                                                   onPressed: () {
//                                                                     Navigator.push(
//                                                                       context,
//                                                                       MaterialPageRoute(
//                                                                         builder: (context) => OfferDetailsScreen(offerID: ele.offerID),
//                                                                       ),
//                                                                     );
//                                                                   },
//                                                                   style: ElevatedButton.styleFrom(
//                                                                     foregroundColor: Colors.white,
//                                                                     backgroundColor: const Color(0xFF1A1A1A),
//                                                                     padding: const EdgeInsets.symmetric(vertical: 12),
//                                                                     shape: RoundedRectangleBorder(
//                                                                       borderRadius: BorderRadius.circular(10),
//                                                                     ),
//                                                                     elevation: 0,
//                                                                   ),
//                                                                   child: const Text(
//                                                                     'VIEW OFFERS',
//                                                                     style: TextStyle(
//                                                                       fontSize: 14,
//                                                                       fontWeight: FontWeight.w600,
//                                                                       letterSpacing: 0.5,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     // Right Image Section
//                                                     Expanded(
//                                                       flex: 2,
//                                                       child:
//                                                       ClipRRect(
//                                                         borderRadius:
//                                                         const BorderRadius
//                                                             .only(
//                                                           topRight:
//                                                           Radius.circular(16),
//                                                           bottomRight:
//                                                           Radius.circular(16),
//                                                         ),
//                                                         child:
//                                                         SizedBox(
//                                                           height:
//                                                           220,
//                                                           // Fixed height for consistency
//                                                           child: ele.offerImages.isNotEmpty
//                                                               ? CachedNetworkImage(
//                                                             imageUrl: ele.offerImages.first,
//                                                             fit: BoxFit.cover,
//                                                             placeholder: (context, url) => Container(
//                                                               color: Colors.grey[100],
//                                                               child: Center(
//                                                                 child: CircularProgressIndicator(
//                                                                   strokeWidth: 2,
//                                                                   color: Colors.grey[400],
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             errorWidget: (context, url, error) => Container(
//                                                               color: Colors.grey[100],
//                                                               child: const Center(
//                                                                 child: Icon(
//                                                                   Icons.image_not_supported_outlined,
//                                                                   color: Colors.grey,
//                                                                   size: 32,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           )
//                                                               : Container(
//                                                             color: Colors.grey[100],
//                                                             child: const Center(
//                                                               child: Icon(
//                                                                 Icons.image_outlined,
//                                                                 color: Colors.grey,
//                                                                 size: 32,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         separatorBuilder:
//                                             (context, index) {
//                                           return const SizedBox(
//                                               width: 4);
//                                         },
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 2.h,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20),
//                       child: Card(
//                         elevation: 0,
//                         color: const Color(0xFF2C3E6C),
//                         // Deep blue base color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'DEALS ',
//                                 style: GoogleFonts.workSans(
//                                   color: Colors.white,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w600,
//                                   height: 1,
//                                   letterSpacing: 0.02,
//                                 ),
//                               ),
//                               Text(
//                                 'NEARBY',
//                                 style: GoogleFonts.workSans(
//                                   color: const Color(0xFFE63946),
//                                   // Red accent color
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w600,
//                                   height: 1,
//                                   letterSpacing: 0.02,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Row(
//                           children: offersFound
//                               ? nearbyOffers.map((offer) {
//                             final color = Color(
//                                 (Random().nextDouble() * 0xFFFFFF)
//                                     .toInt())
//                                 .withOpacity(1.0);
//                             String distanceText;
//                             if (offer.distanceFromUserInMeters < 1000) {
//                               distanceText =
//                               'Within ${offer.distanceFromUserInMeters.toStringAsFixed(0)} Meters';
//                             } else {
//                               double distanceInKm =
//                                   offer.distanceFromUserInMeters / 1000;
//                               distanceText =
//                               'Within ${distanceInKm.toStringAsFixed(1)} KM';
//                             }
//                             return GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         OfferDetailsScreen(
//                                             offerID: offer.offerID),
//                                   ),
//                                 );
//                               },
//                               child: buildLocationCard(
//                                 offer.offerAddress,
//                                 distanceText,
//                                 color,
//                               ),
//                             );
//                           }).toList()
//                               : [
//                             buildLocationCard('No Offers Found',
//                                 'Check back later', Colors.grey)
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Padding(
//                     //   padding: const EdgeInsets.only(left: 20),
//                     //   child: Text(
//                     //     'Featured Services',
//                     //     textScaleFactor: 1.5,
//                     //     style: TextStyle(
//                     //       fontSize: 10.sp, // Adjust the font size as needed
//                     //       fontWeight: FontWeight.bold,
//                     //       color: Colors.black,
//                     //       // You can add more styling properties here such as fontFamily, letterSpacing, etc.
//                     //     ),
//                     //   ),
//                     // ),
//                     // SizedBox(height: 2.h,),
//                     // Container(
//                     //   height: 25.h,
//                     //   padding: const EdgeInsets.only(left: 8),
//                     //   child: StreamBuilder<List<OffersColl>>(
//                     //     stream: isar.offersColls
//                     //         .filter()
//                     //         .offerNameIsNotEmpty()
//                     //         .selectedCityEqualTo(controller.selectedCity)
//                     //         .offerTypeEqualTo('service') // Filter only product offers
//                     //         .sortByDistanceFromUserInMeters()
//                     //         .build()
//                     //         .watch(fireImmediately: true),
//                     //     builder: (context, snapshot) {
//                     //       List<OffersColl>? offers = [];
//                     //       if (snapshot.hasData) {
//                     //         offers = snapshot.data;
//                     //       }
//                     //       return AnimatedSwitcher(
//                     //         duration: const Duration(seconds: 1),
//                     //         child: !snapshot.hasData || controller.trendingNowIsLoading
//                     //             ? const Center(
//                     //           child: CircularProgressIndicator(),
//                     //         )
//                     //             : offers!.isEmpty
//                     //             ? const Center(
//                     //           child: Card(
//                     //             color: Colors.black,
//                     //             child: Padding(
//                     //               padding: EdgeInsets.all(8.0),
//                     //               child: Text(
//                     //                 'No offers found',
//                     //                 textScaleFactor: 1.2,
//                     //                 style: TextStyle(
//                     //                   color: Colors.white,
//                     //                   fontWeight: FontWeight.bold,
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //           ),
//                     //         )
//                     //             : ListView.separated(
//                     //           shrinkWrap: true,
//                     //           scrollDirection: Axis.horizontal,
//                     //           itemCount: offers.length,
//                     //           separatorBuilder: (BuildContext context, int index) {
//                     //             return const SizedBox(width: 10); // Adjust spacing between items
//                     //           },
//                     //           itemBuilder: (context, index) {
//                     //             OffersColl offer = offers![index];
//                     //             return buildItem(
//                     //               id: offer.offerID,
//                     //               isFavorite: offer.isInWishList,
//                     //               title: offer.productName,
//                     //               discount: '${offer.discountNo} %',
//                     //               offerImage: offer.offerImages.first,
//                     //               context: context,
//                     //             );
//                     //           },
//                     //         ),
//                     //       );
//                     //     },
//                     //   ),
//                     // ),
//                     SizedBox(
//                       height: 5.h,
//                     ),
//                     // StreamBuilder(
//                     //   stream: isar.availedOffersColls
//                     //       .filter()
//                     //       .offerNameIsNotEmpty()
//                     //       .build()
//                     //       .watch(fireImmediately: true),
//                     //   builder: (context, snapshot) {
//                     //     List<AvailedOffersColl> availedOffersList =
//                     //         snapshot.data ?? [];
//                     //     return AnimatedSwitcher(
//                     //       duration: const Duration(seconds: 1),
//                     //       child: snapshot.hasError
//                     //           ? const Center(
//                     //               child: Text('Something is wrong!'))
//                     //           : !snapshot.hasData
//                     //               ? const Center(child: Text('No data'))
//                     //               : snapshot.hasData &&
//                     //                       availedOffersList.isNotEmpty
//                     //                   ? Column(
//                     //                       children: [
//                     //                         const Padding(
//                     //                           padding: EdgeInsets.only(
//                     //                               left: 8.0, top: 8.0),
//                     //                           child: Text(
//                     //                             'Grab Before Its gone',
//                     //                             textScaleFactor: 1.5,
//                     //                           ),
//                     //                         ),
//                     //                         GridView.builder(
//                     //                           shrinkWrap: true,
//                     //                           itemCount:
//                     //                               availedOffersList.length,
//                     //                           physics:
//                     //                               const NeverScrollableScrollPhysics(),
//                     //                           gridDelegate:
//                     //                               const SliverGridDelegateWithFixedCrossAxisCount(
//                     //                                   crossAxisCount: 3,
//                     //                                   childAspectRatio:
//                     //                                       2 / 3),
//                     //                           itemBuilder: (context, index) {
//                     //                             // var ele = controller
//                     //                             //     .grabBeforeItGoneList[index];
//                     //                             AvailedOffersColl offer =
//                     //                                 availedOffersList[index];
//                     //                             return OpenContainer(
//                     //                               closedColor: Colors.white,
//                     //                               middleColor: Colors.pink,
//                     //                               openColor: Colors.white,
//                     //                               clipBehavior: Clip
//                     //                                   .antiAliasWithSaveLayer,
//                     //                               closedElevation: 10,
//                     //                               transitionDuration:
//                     //                                   const Duration(
//                     //                                       seconds: 1),
//                     //                               transitionType:
//                     //                                   ContainerTransitionType
//                     //                                       .fadeThrough,
//                     //                               closedBuilder:
//                     //                                   (context, action) {
//                     //                                 return SizedBox(
//                     //                                   height: 20.h,
//                     //                                   child: Card(
//                     //                                     child: Column(
//                     //                                       children: [
//                     //                                         SizedBox(
//                     //                                             height: 15.h,
//                     //                                             child: CachedNetworkImage(
//                     //                                                 imageUrl:
//                     //                                                     offer
//                     //                                                         .offerImg)),
//                     //                                         Container(
//                     //                                           color: controller.screenTypeProducts
//                     //                                               ? Colors
//                     //                                                   .blue
//                     //                                                   .shade900
//                     //                                               : Colors
//                     //                                                   .pink,
//                     //                                           width: 100.w,
//                     //                                           child: Center(
//                     //                                             child: Text(
//                     //                                                 'min ${offer.discountNo}% off',
//                     //                                                 textScaleFactor:
//                     //                                                     1.1,
//                     //                                                 style: const TextStyle(
//                     //                                                     color:
//                     //                                                         Colors.white)),
//                     //                                           ),
//                     //                                         ),
//                     //                                         Text(offer
//                     //                                             .productName)
//                     //                                       ],
//                     //                                     ),
//                     //                                   ),
//                     //                                 );
//                     //                               },
//                     //                               openBuilder:
//                     //                                   (context, action) {
//                     //                                 return FutureBuilder(
//                     //                                   future: isar.offersColls
//                     //                                       .where()
//                     //                                       .offerIDEqualTo(
//                     //                                           offer.offerID)
//                     //                                       .build()
//                     //                                       .findFirst(),
//                     //                                   builder: (context,
//                     //                                       snapshot) {
//                     //                                     if (snapshot.connectionState ==
//                     //                                             ConnectionState
//                     //                                                 .done &&
//                     //                                         snapshot
//                     //                                             .hasData) {
//                     //                                       return OfferEnCashScreen(
//                     //                                           ele: snapshot
//                     //                                               .data!,
//                     //                                           shouldEnCash:
//                     //                                               false,
//                     //                                           orderID: offer
//                     //                                               .availedOfferID);
//                     //                                     }
//                     //                                     return const Center(
//                     //                                         child:
//                     //                                             CircularProgressIndicator());
//                     //                                   },
//                     //                                 );
//                     //                               },
//                     //                             );
//                     //                           },
//                     //                         )
//                     //                       ],
//                     //                     )
//                     //                   : availedOffersList.isEmpty
//                     //                       ? const SizedBox()
//                     //                       : const Center(
//                     //                           child:
//                     //                               CircularProgressIndicator(),
//                     //                         ),
//                     //     );
//                     //   },
//                     // )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Widget buildLocationCard(String title, String subtitle, Color color) {
//   return Padding(
//     padding: const EdgeInsets.only(right: 16.0), // Space between cards
//     child: Column(
//       children: [
//         Container(
//           width: 32.w, // Adjust width as needed
//           height: 14.h, // Adjust height as needed
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Center(
//             child: Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 12.0, // Adjust font size as needed
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8.0), // Space between card and subtitle
//         Text(
//           subtitle,
//           style: const TextStyle(
//             fontSize: 10.0, // Adjust font size as needed
//             color: Colors.black,
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     debugPrint('Location services are disabled.');
//     return Future.error('Location services are disabled.');
//   }
//
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       debugPrint('Location permissions are denied');
//       return Future.error('Location permissions are denied');
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     debugPrint('Location permissions are permanently denied.');
//     return Future.error('Location permissions are permanently denied.');
//   }
//
//   return await Geolocator.getCurrentPosition();
// }
//
// Widget _buildCarouselOfferCard(
//     OffersColl offer, BuildContext context, bool isTrending) {
//   return Card(
//     elevation: isTrending ? 6 : 4,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//       side: isTrending
//           ? const BorderSide(color: Color(0xFFDC2121), width: 1.5)
//           : BorderSide.none,
//     ),
//     child: InkWell(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
//         ),
//       ),
//       child: Column(
//         children: [
//           if (isTrending)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               decoration: const BoxDecoration(
//                 color: Color(0xFFDC2121),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.local_fire_department,
//                       color: Colors.white, size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     'TRENDING',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Padding(
//                     padding: const EdgeInsets.all(15.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 offer.offerName,
//                                 style: TextStyle(
//                                   fontSize: isTrending ? 18 : 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.shade50,
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.favorite,
//                                     color: Colors.red,
//                                     size: 16,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '${offer.likesCount}',
//                                     style: const TextStyle(
//                                       color: Colors.red,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.location_on,
//                               size: 16,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 offer.offerAddress,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Spacer(),
//                         ElevatedButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => OfferDetailsScreen(
//                                 offerID: offer.offerID,
//                               ),
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                             isTrending ? Color(0xFFDC2121) : Colors.black,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'VIEW OFFERS',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: isTrending
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               const Icon(Icons.arrow_forward, size: 16),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildRatingWidget(offer.offerID),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.horizontal(
//                       right: Radius.circular(12),
//                     ),
//                     child: Container(
//                       height: double.infinity,
//                       color: Colors.grey[200],
//                       child: offer.offerImages.isNotEmpty
//                           ? CachedNetworkImage(
//                         imageUrl: offer.offerImages.first,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                         errorWidget: (context, url, error) => const Icon(
//                           Icons.image_not_supported,
//                           color: Colors.grey,
//                           size: 50,
//                         ),
//                       )
//                           : const Icon(
//                         Icons.image_not_supported,
//                         color: Colors.grey,
//                         size: 50,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildRatingWidget(String offerID) {
//   return StreamBuilder<DocumentSnapshot>(
//     stream: FirebaseFirestore.instance
//         .collection('candidOffers')
//         .doc(offerID)
//         .snapshots(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(strokeWidth: 2),
//         );
//       }
//
//       if (!snapshot.hasData || !snapshot.data!.exists) {
//         return const SizedBox.shrink();
//       }
//
//       final data = snapshot.data!.data() as Map<String, dynamic>?;
//       if (data == null) return const SizedBox.shrink();
//
//       final cumulativeRating =
//           (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
//       final ratingCount = (data['ratingCount'] as int?) ?? 0;
//       final averageRating =
//       ratingCount > 0 ? cumulativeRating / ratingCount : 0.0;
//
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ...List.generate(5, (index) {
//             return Icon(
//               index < averageRating.round() ? Icons.star : Icons.star_border,
//               color: Colors.amber,
//               size: 16,
//             );
//           }),
//           const SizedBox(width: 8),
//           Text(
//             ratingCount > 0
//                 ? '${averageRating.toStringAsFixed(1)} / 5'
//                 : 'No ratings',
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
//
// String _getSearchSubstring(String searchStr) {
//   if (searchStr.length >= 2) {
//     return searchStr.substring(0, 2);
//   } else {
//     return searchStr;
//   }
// }
//
// void _showPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Demo Offer'),
//         content: const Text(
//           'This is the demo  offer. If we have offers nearby or in your city, real deals will show in real time. Thank you from Candid Offer!',
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
//
// class ProductDetailScreen extends StatelessWidget {
//   final String product;
//   final IconData icon;
//
//   const ProductDetailScreen({
//     required this.product,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 120,
//               color: Colors.green.shade700,
//             ),
//             SizedBox(height: 30),
//             Text(
//               product,
//               style: GoogleFonts.workSans(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               onPressed: () => Navigator.pop(context),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 child: Text(
//                   'Go Back',
//                   style:
//                   GoogleFonts.workSans(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math';
import 'dart:ui';
import 'package:candid_customer/Screens/OffersScreens/productcateogry.dart';
import 'package:candid_customer/Screens/OffersScreens/productlistingscreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Screens/OffersScreens/OfferDetailsScreen.dart';
import 'package:candid_customer/Services/Collections/Cat/CatsColl.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:candid_customer/Utils/MyWidgets.dart';
import 'package:candid_customer/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../Controllers/SearchControllers/SearchScreenController.dart';
import '../Sumit/Product_Search.dart';
import '../S/Voice.dart';
import '../Sumit/Service_Search.dart';
import '../Services/API/OffersServices/OffersConnect.dart';
import '../UnifiedCategorySearchScreen.dart';
import 'OffersScreens/OfferCategories.dart';
import 'OffersScreens/selectedcatoffers.dart';
import 'OffersScreens/servicecatogory.dart';
import 'OffersScreens/servicelistingscreen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialTab;
  const HomeScreen({Key? key, this.initialTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final Map<String, List<String>> mainCategories = {
  //   'Fruit': ['Apple', 'Banana', 'Orange', 'Grapes'],
  //   'Dairy': ['Milk', 'Cheese', 'Butter', 'Curd'],
  //   'Grain': ['Rice', 'Wheat', 'Barley', 'Corn'],
  //   'Food': ['Pizza', 'Burger', 'Pasta', 'Sushi'],
  //   'Vegetable': ['Potato', 'Tomato', 'Carrot', 'Spinach'],
  //   'Beverage': ['Tea', 'Coffee', 'Juice', 'Soda'],
  //   'Snack': ['Chips', 'Cookies', 'Popcorn', 'Nuts'],
  //   'Meat': ['Chicken', 'Beef', 'Mutton', 'Fish'],
  //   'Bakery': ['Bread', 'Cake', 'Bun', 'Muffin'],
  //   'Frozen': ['Ice Cream', 'Frozen Peas', 'Frozen Pizza', 'Frozen Fries'],
  //   'Condiment': ['Salt', 'Pepper', 'Ketchup', 'Mayonnaise'],
  //   'Spice': ['Turmeric', 'Cumin', 'Coriander', 'Chili'],
  //   'Dry Fruit': ['Almonds', 'Cashews', 'Walnuts', 'Raisins'],
  //   'Oil': ['Mustard Oil', 'Sunflower Oil', 'Olive Oil', 'Coconut Oil'],
  //   'Beauty': ['Lipstick', 'Foundation', 'Face Wash', 'Moisturizer'],
  //   'Cleaning': ['Soap', 'Shampoo', 'Detergent', 'Disinfectant'],
  //   'Stationery': ['Pen', 'Notebook', 'Pencil', 'Eraser'],
  //   'Electronics': ['TV', 'Fan', 'Mobile', 'Laptop'],
  //   'Appliances': ['Oven', 'Fridge', 'Mixer', 'Washing Machine'],
  //   'Toy': ['Doll', 'Car', 'Puzzle', 'Blocks'],
  // };
  // final Map<String, IconData> categoryIcons = {
  //   'Fruit': Icons.apple,
  //   'Dairy': Icons.icecream,
  //   'Grain': Icons.rice_bowl,
  //   'Food': Icons.fastfood,
  //   'Vegetable': Icons.eco,
  //   'Beverage': Icons.local_cafe,
  //   'Snack': Icons.cookie,
  //   'Meat': Icons.set_meal,
  //   'Bakery': Icons.cake,
  //   'Frozen': Icons.ac_unit,
  //   'Condiment': Icons.kitchen,
  //   'Spice': Icons.fireplace,
  //   'Dry Fruit': Icons.spa,
  //   'Oil': Icons.oil_barrel,
  //   'Beauty': Icons.brush,
  //   'Cleaning': Icons.cleaning_services,
  //   'Stationery': Icons.edit,
  //   'Electronics': Icons.devices,
  //   'Appliances': Icons.kitchen,
  //   'Toy': Icons.toys,
  // };
  //
  // final Map<String, List<String>> mainCategories2 = {
  //   'Home Services': ['Electrician', 'Plumber', 'Carpenter', 'Painter'],
  //   'Health Services': ['Doctor', 'Nurse', 'Physiotherapist', 'Dentist'],
  //   'Education': ['Tutor', 'Coach', 'Music Teacher', 'Yoga Instructor'],
  //   'Vehicle Services': [
  //     'Mechanic',
  //     'Car Wash',
  //     'Tyre Repair',
  //     'Battery Service'
  //   ],
  //   'Beauty & Wellness': ['Beautician', 'Hair Stylist', 'Masseuse', 'Spa'],
  //   'Repair': ['AC Repair', 'Fridge Repair', 'TV Repair', 'Mobile Repair'],
  //   'Cleaning': [
  //     'House Cleaning',
  //     'Sofa Cleaning',
  //     'Water Tank Cleaning',
  //     'Pest Control'
  //   ],
  //   'Delivery': ['Courier', 'Parcel', 'Food Delivery', 'Grocery Delivery'],
  //   'Event': ['Photographer', 'DJ', 'Caterer', 'Decorator'],
  //   'Security': ['Security Guard', 'Bodyguard', 'Bouncer', 'CCTV Monitor'],
  //   'Transportation': ['Driver', 'Taxi Service', 'Auto Rickshaw', 'Bike Taxi'],
  //   'Home Appliances': [
  //     'Washing Machine Repair',
  //     'Microwave Repair',
  //     'Geyser Repair',
  //     'Chimney Repair'
  //   ],
  //   'Fitness': [
  //     'Personal Trainer',
  //     'Gym Trainer',
  //     'Zumba Instructor',
  //     'Dietician'
  //   ],
  //   'Legal': ['Lawyer', 'Notary', 'Document Writer', 'Legal Advisor'],
  //   'Finance': [
  //     'Accountant',
  //     'Tax Consultant',
  //     'Loan Agent',
  //     'Insurance Agent'
  //   ],
  //   'Childcare': ['Babysitter', 'Nanny', 'Daycare', 'Tuition Teacher'],
  //   'Elder Care': [
  //     'Caregiver',
  //     'Old Age Companion',
  //     'Walking Assistant',
  //     'Medicine Reminder'
  //   ],
  //   'IT Support': [
  //     'Computer Repair',
  //     'Software Install',
  //     'WiFi Setup',
  //     'Printer Setup'
  //   ],
  //   'Construction': ['Mason', 'Welder', 'Painter', 'Tile Worker'],
  //   'Miscellaneous': ['Gardener', 'Laundry', 'Key Maker', 'Pet Walker'],
  // };
  // final Map<String, IconData> categoryIcons2 = {
  //   'Home Services': Icons.home_repair_service,
  //   'Health Services': Icons.health_and_safety,
  //   'Education': Icons.school,
  //   'Vehicle Services': Icons.car_repair,
  //   'Beauty & Wellness': Icons.spa,
  //   'Repair': Icons.build,
  //   'Cleaning': Icons.cleaning_services,
  //   'Delivery': Icons.local_shipping,
  //   'Event': Icons.celebration,
  //   'Security': Icons.security,
  //   'Transportation': Icons.directions_car,
  //   'Home Appliances': Icons.kitchen,
  //   'Fitness': Icons.fitness_center,
  //   'Legal': Icons.gavel,
  //   'Finance': Icons.account_balance,
  //   'Childcare': Icons.child_friendly,
  //   'Elder Care': Icons.elderly,
  //   'IT Support': Icons.computer,
  //   'Construction': Icons.construction,
  //   'Miscellaneous': Icons.miscellaneous_services,
  // };

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
      if (mounted) {
        setState(() {
          nearbyOffers = [];
          offersFound = false;
        });
      }
      return;
    }

    List<OffersColl> offers;

    try {
      offers =
          await _getOffersBasedOnCity(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      if (mounted) {
        setState(() {
          nearbyOffers = [];
          offersFound = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        nearbyOffers = offers;
        offersFound = offers.isNotEmpty;
      });

      debugPrint(
          'User Location: Lat=${position.latitude}, Lon=${position.longitude}');
      debugPrint('Number of Nearby Offers: ${nearbyOffers.length}');
    }
  }

  Future<List<OffersColl>> _getOffersBasedOnCity(
      double latitude, double longitude) async {
    await OffersConnect()
        .getAllOffersApi(true); // Ensure this fetches offers correctly
    return await isar.offersColls
        .filter()
        .distanceFromUserInMetersLessThan(
            10000) // Ensure correct filtering logic
        .findAll();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final String? selectedCategoryName = arguments?['selectedCategoryName'] ??
        'defaultCategory'; // Provide a default value if null
    final TextEditingController searchController = TextEditingController();
    return GetBuilder(
      init: homeScreenController,
      builder: (controller) => Scaffold(
        appBar: MyWidgets().myAppBar(),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
            // Set the background color of the drawer to pure white
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                // Ensure this is your custom header without dividers
                MyWidgets().myDrawerHeader(),
                // Generate cards for each item
                for (var item in bottomNavController.navDrawerItems)
                  Card(
                    color: Colors.white,
                    // Ensure card background is pure white
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    // Adjust margin as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Adjust the border radius as needed
                    ),
                    elevation: 2,
                    // Optional: adds a slight shadow for visual separation
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0), // Adjust padding as needed
                      title: Text(
                        item['title'],
                        style: GoogleFonts.workSans(
                          // fontWeight: FontWeight.bold, // Uncomment if needed
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
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1979, 1.0],
                  colors: [Color(0xFFDC2121), Color(0xFF8F0A0A)],
                ),
              ),
              child: Center(
                child: GetBuilder<SearchScreenController>(
                  init: SearchScreenController(),
                  builder: (controller) => Padding(
                    padding: const EdgeInsets.only(
                        left: 13.0, right: 13, bottom: 13),
                    child: TextField(
                      controller: searchController,
                      readOnly: true,
                      onTap: () {
                        Get.to(() => Productcateogry());
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search for product or service here...',
                        hintStyle: GoogleFonts.workSans(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'lib/Images/candid1.png',
                            height: 30,
                          ),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.mic, // 🎤 Mic icon
                                color: Colors.black,
                                size: 25, // Icon size aap change kar sakte ho
                              ),
                              onPressed: () {
                                // Mic par tap karne par navigation
                                Get.to(() => UnifiedCategorySearchScreen());
                              },
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
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
                ),
              ),
            ),
            GetBuilder<SearchScreenController>(
              builder: (controller) {
                if (controller.searchStr.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: StreamBuilder<List<OffersColl>>(
                      stream: isar.offersColls
                          .filter()
                          .selectedCityEqualTo(
                              homeScreenController.selectedCity)
                          .and()
                          .group((q) {
                            final searchLower =
                                controller.searchStr.toLowerCase().trim();
                            return q
                                .offerNameContains(searchLower,
                                    caseSensitive: false)
                                .or()
                                .offerTypeContains(searchLower,
                                    caseSensitive: false)
                                .or()
                                .userPinCodeContains(searchLower,
                                    caseSensitive: false)
                                .or()
                                .userBusinessNameContains(searchLower,
                                    caseSensitive: false)
                                .or()
                                .productTypeContains(searchLower,
                                    caseSensitive: false)
                                .or()
                                .productTypeEqualTo(
                                    controller.filterproductType ?? "");
                          })
                          .build()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }
                        final offers = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            final offer = offers[index];
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.92,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black.withOpacity(0.05),
                                //     offset: const Offset(0, 4),
                                //     blurRadius: 15,
                                //     spreadRadius: 1,
                                //   ),
                                // ],
                              ),
                              child: Material(
                                // Added for ripple effect
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OfferDetailsScreen(
                                                offerID: offer.offerID),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left Content Section
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Offer Name and Likes Section
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          offer.offerName,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xFF2C3E50),
                                                            height: 1.3,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .red.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.favorite,
                                                              color: Colors
                                                                  .red.shade400,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              '${offer.likesCount}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .red
                                                                    .shade400,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // Address Section
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          offer.offerAddress,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                            height: 1.4,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              // Rating Section
                                              StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('candidOffers')
                                                    .doc(offer.offerID)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const LinearProgressIndicator(
                                                      minHeight: 2,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    );
                                                  }

                                                  if (!snapshot.hasData ||
                                                      !snapshot.data!.exists) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  final data = snapshot.data!
                                                          .data()
                                                      as Map<String, dynamic>?;
                                                  if (data == null) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  final cumulativeRating =
                                                      (data['cumulativeRating']
                                                                  as num?)
                                                              ?.toDouble() ??
                                                          0.0;
                                                  final ratingCount =
                                                      (data['ratingCount']
                                                              as int?) ??
                                                          0;
                                                  final averageRating =
                                                      ratingCount > 0
                                                          ? cumulativeRating /
                                                              ratingCount
                                                          : 0.0;

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // Star icons with fixed size
                                                          ...List.generate(5,
                                                              (index) {
                                                            return Icon(
                                                              index <
                                                                      averageRating
                                                                          .round()
                                                                  ? Icons
                                                                      .star_rounded
                                                                  : Icons
                                                                      .star_outline_rounded,
                                                              color: const Color(
                                                                  0xFFFFB800),
                                                              size:
                                                                  18, // Slightly reduced size
                                                            );
                                                          }),
                                                          const SizedBox(
                                                              width: 4),
                                                          // Reduced spacing
                                                          // Expandable text that handles overflow
                                                          Expanded(
                                                            child: Text(
                                                              ratingCount > 0
                                                                  ? '${averageRating.toStringAsFixed(1)} / 5'
                                                                  : 'No ratings yet',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 13,
                                                                // Slightly reduced font size
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFF6B7280),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              // Handle text overflow
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              // View Offers Button
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            OfferDetailsScreen(
                                                                offerID: offer
                                                                    .offerID),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        const Color(0xFF1A1A1A),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(
                                                    'VIEW OFFERS',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Right Image Section
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      child: SizedBox(
                                        height: 220,
                                        child: () {
                                          if (offer.offerImages.isEmpty) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: Colors.grey,
                                                  size: 32,
                                                ),
                                              ),
                                            );
                                          }

                                          final raw = offer.offerImages.first.toString().trim();
                                          if (raw.isEmpty) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: Colors.grey,
                                                  size: 32,
                                                ),
                                              ),
                                            );
                                          }

                                          final String imageUrl = raw.startsWith('http')
                                              ? raw
                                              : 'https://firebasestorage.googleapis.com/v0/b/candid-cf9fc.appspot.com/o/${Uri.encodeFull(raw)}';

                                          print('Loading image URL: $imageUrl');

                                          return CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) {
                                              return Container(
                                                color: Colors.grey[100],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              );
                                            },
                                            errorWidget: (context, url, error) {
                                              print('Error loading image: $error');
                                              return Container(
                                                color: Colors.grey[100],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported_outlined,
                                                    color: Colors.grey,
                                                    size: 32,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }(),
                                      ),
                                    ),
                                  ),

                                  ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 1.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                elevation: 4,
                                // Adjust the elevation for shadow effect
                                color: Color(0xFF2C3E6C),
                                // Background color of the card
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust the border radius as needed
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'PRODUCT CATEGORIES',
                                    style: GoogleFonts.workSans(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                      // Adjusted to 1 for better line height
                                      letterSpacing: 0.02,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 0.0),
                                // Adjust the right padding as needed
                                child: SizedBox(
                                  width: 25.w, // Adjust as needed
                                  height: 34, // Adjust as needed
                                  child: MyWidgets().getLargeButton(
                                    title: 'Browse All',
                                    onPress: () =>
                                        Get.to(() => Productcateogry()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Add some space between the rows
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate responsive sizes based on screen width
                              final screenWidth =
                                  MediaQuery.of(context).size.width;
                              final isSmallScreen = screenWidth < 360;
                              final isMediumScreen =
                                  screenWidth >= 360 && screenWidth < 600;
                              final isLargeScreen = screenWidth >= 600;

                              // Adjust sizes based on screen size
                              final fontSize = isSmallScreen
                                  ? 12.sp
                                  : isMediumScreen
                                      ? 14.sp
                                      : 16.sp;

                              final iconSize = isSmallScreen
                                  ? 16.sp
                                  : isMediumScreen
                                      ? 18.sp
                                      : 20.sp;

                              final containerSize = isSmallScreen
                                  ? 28.0
                                  : isMediumScreen
                                      ? 32.0
                                      : 36.0;

                              final horizontalPadding = isSmallScreen
                                  ? 12.0
                                  : isMediumScreen
                                      ? 16.0
                                      : 20.0;

                              return Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: horizontalPadding,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      isLargeScreen ? 600.0 : double.infinity,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Explore More Product Categories',
                                          style: GoogleFonts.workSans(
                                            color: Colors.black,
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                          width: isSmallScreen ? 4.w : 8.w),
                                      InkWell(
                                        onTap: () {
                                          controller.scrollToEnd(
                                              controller.scrollController1);
                                        },
                                        child: Container(
                                          width: containerSize,
                                          height: containerSize,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                            // Add subtle shadow for better visibility
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.black
                                            //         .withOpacity(0.1),
                                            //     blurRadius: 4,
                                            //     offset: Offset(0, 2),
                                            //   ),
                                            // ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              // size: iconSize,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Stack(
                      textDirection: TextDirection.rtl,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.toggleCatsName();
                          },
                          child: AnimatedContainer(
                            height: controller.showCatsName ? 12.h : 14.h,
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
                                if (snapshot.data != null &&
                                    !snapshot.hasError) {
                                  catsList = snapshot.data as List<CatsColl>;

                                  if (controller.selectedCatID.isEmpty &&
                                      catsList.isNotEmpty) {
                                    Future.delayed(Duration.zero, () {
                                      controller.selectedCatID =
                                          catsList.first.catID;
                                      controller.update();
                                    });
                                  }
                                } else {
                                  return const Center(
                                      child: Text('Loading...'));
                                }

                                int itemCount =
                                    catsList.length > 10 ? 11 : catsList.length;

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 0),
                                  child: catsList.isEmpty
                                      ? const Text('Empty List')
                                      : ListView.separated(
                                          controller:
                                              controller.scrollController1,
                                          shrinkWrap: true,
                                          itemCount: itemCount,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            if (index == 10 &&
                                                catsList.length > 10) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const OfferCategories(),
                                                    ),
                                                  );
                                                },
                                                child: SizedBox(
                                                  width:
                                                      controller.listItemWidth,
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.more_horiz,
                                                          size: 30),
                                                      SizedBox(height: 5),
                                                      Text('View More',
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            var cat = catsList[index];

                                            return InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OffersScreen(
                                                            selectedCatID:
                                                                cat.catID),
                                                  ),
                                                );
                                              },
                                              child: SizedBox(
                                                width: controller.listItemWidth,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        border: cat.catID ==
                                                                controller
                                                                    .selectedCatID
                                                            ? Border.all(
                                                                color: const Color(
                                                                    0xFFDB2020),
                                                                width: 3.0)
                                                            : null,
                                                      ),
                                                      child: SvgPicture.network(
                                                        cat.catImg,
                                                        fit: BoxFit.contain,
                                                        placeholderBuilder:
                                                            (BuildContext
                                                                    context) =>
                                                                Image.asset(
                                                          'lib/Images/app_icon_mid.jpeg',
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    SizedBox(
                                                      width: controller
                                                          .listItemWidth,
                                                      child: Text(
                                                        cat.catName,
                                                        style: TextStyle(
                                                          fontSize: 8.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const VerticalDivider(
                                                  width: 5,
                                                  color: Colors.transparent),
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Center(
                    //   child: Stack(
                    //     textDirection: TextDirection.rtl,
                    //     children: [
                    //       InkWell(
                    //         onTap: () {
                    //           controller.toggleCatsName();
                    //         },
                    //         child: AnimatedContainer(
                    //           height: controller.showCatsName ? 12.h : 14.h,
                    //           width: 100.w,
                    //           duration: const Duration(milliseconds: 300),
                    //           child: Builder(
                    //             builder: (context) {
                    //               final categoryList =
                    //                   mainCategories.keys.toList();
                    //               final itemCount = categoryList.length > 10
                    //                   ? 11
                    //                   : categoryList.length;
                    //
                    //               return ListView.separated(
                    //                 controller: controller.scrollController1,
                    //                 shrinkWrap: true,
                    //                 itemCount: itemCount,
                    //                 scrollDirection: Axis.horizontal,
                    //                 physics:
                    //                     const AlwaysScrollableScrollPhysics(),
                    //                 itemBuilder: (context, index) {
                    //                   if (index == 10 &&
                    //                       categoryList.length > 10) {
                    //                     return InkWell(
                    //                       onTap: () {
                    //                         Navigator.of(context).push(
                    //                           MaterialPageRoute(
                    //                             builder: (context) =>
                    //                                 const OfferCategories(),
                    //                           ),
                    //                         );
                    //                       },
                    //                       child: SizedBox(
                    //                         width: controller.listItemWidth,
                    //                         child: const Column(
                    //                           mainAxisAlignment:
                    //                               MainAxisAlignment.center,
                    //                           children: [
                    //                             Icon(Icons.more_horiz, size: 30),
                    //                             SizedBox(height: 5),
                    //                             Text('View More',
                    //                                 style:
                    //                                     TextStyle(fontSize: 12)),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     );
                    //                   }
                    //
                    //                   // final catName = categoryList[index];
                    //                   // final icon = categoryIcons[catName] ??
                    //                   //     Icons.category;
                    //
                    //                   return InkWell(
                    //                     onTap: () {
                    //                       showDialog(
                    //                         context: context,
                    //                         builder: (context) {
                    //                           return Center(
                    //                             child: Container(
                    //                               width: 70.w,
                    //                               height: 70.w,
                    //                               padding:
                    //                                   const EdgeInsets.all(16),
                    //                               decoration: BoxDecoration(
                    //                                 color: Colors.white,
                    //                                 borderRadius:
                    //                                     BorderRadius.circular(12),
                    //                                 boxShadow: [
                    //                                   BoxShadow(
                    //                                     color: Colors.black26,
                    //                                     blurRadius: 8,
                    //                                     offset:
                    //                                         const Offset(0, 4),
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                               child: Center(
                    //                                 child: Column(
                    //                                   mainAxisSize:
                    //                                       MainAxisSize.min,
                    //                                   children: [
                    //                                     Icon(icon,
                    //                                         size: 50,
                    //                                         color: Colors.red),
                    //                                     const SizedBox(
                    //                                         height: 10),
                    //                                     Text(
                    //                                       catName,
                    //                                       textAlign:
                    //                                           TextAlign.center,
                    //                                       style: TextStyle(
                    //                                         fontSize: 14.sp,
                    //                                         fontWeight:
                    //                                             FontWeight.bold,
                    //                                       ),
                    //                                     ),
                    //                                     // const SizedBox(height: 20),
                    //                                     // ElevatedButton(
                    //                                     //   onPressed: () {
                    //                                     //     Navigator.pop(context); // Close dialog
                    //                                     //     Navigator.of(context).push(
                    //                                     //       MaterialPageRoute(
                    //                                     //         builder: (context) => OffersScreen(
                    //                                     //           selectedCatID: catName,
                    //                                     //         ),
                    //                                     //       ),
                    //                                     //     );
                    //                                     //   },
                    //                                     //   child: const Text("Continue"),
                    //                                     // ),
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           );
                    //                         },
                    //                       );
                    //                     },
                    //                     child: SizedBox(
                    //                       width: controller.listItemWidth,
                    //                       child: Column(
                    //                         children: [
                    //                           Container(
                    //                             width: 50,
                    //                             height: 50,
                    //                             decoration: BoxDecoration(
                    //                               border: catName ==
                    //                                       controller.selectedCatID
                    //                                   ? Border.all(
                    //                                       color: const Color(
                    //                                           0xFFDB2020),
                    //                                       width: 3.0,
                    //                                     )
                    //                                   : null,
                    //                             ),
                    //                             child: Icon(icon,
                    //                                 size: 40, color: Colors.red),
                    //                           ),
                    //                           const SizedBox(height: 3),
                    //                           SizedBox(
                    //                             width: controller.listItemWidth,
                    //                             child: Text(
                    //                               catName,
                    //                               style: TextStyle(
                    //                                 fontSize: 8.sp,
                    //                                 fontWeight: FontWeight.bold,
                    //                               ),
                    //                               textAlign: TextAlign.center,
                    //                               overflow: TextOverflow.ellipsis,
                    //                               maxLines: 2,
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   );
                    //                 },
                    //                 separatorBuilder: (context, index) =>
                    //                     const VerticalDivider(
                    //                         width: 5, color: Colors.transparent),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    StreamBuilder<List<OffersColl>>(
                      stream: isar.offersColls
                          .filter()
                          .isBigDaysEqualTo(true)
                          .selectedCityEqualTo(controller.selectedCity)
                          .build()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        List<OffersColl> bigDaysOffers = snapshot.data ?? [];

                        return Visibility(
                          visible: bigDaysOffers.isNotEmpty,
                          child: Column(
                            children: [
                              const Divider(),
                              Card(
                                elevation: 0,
                                color: const Color(0xFF2C3E6C),
                                // Even lighter shade of blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'BIG DAYS OFFERS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                      letterSpacing: 0.02,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              SizedBox(height: 2.h),
                              CarouselSlider.builder(
                                itemCount: bigDaysOffers.length,
                                options: CarouselOptions(
                                  height: 200,
                                  viewportFraction: 0.8,
                                  enlargeCenterPage: true,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  var offer = bigDaysOffers[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OfferDetailsScreen(
                                                  offerID: offer.offerID),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // 🔹 OFFER NAME
// 🔹 OFFER NAME + LIKES ROW
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              offer.productName,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Aileron',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                            ),
                                                          ),

                                                          // ❤️ Likes Count
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons.favorite,
                                                                color:
                                                                    Colors.red,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                '${offer.likesCount}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),

                                                      // 🔹 PRODUCT NAME
                                                      Text(
                                                        'OFFER NAME: ${offer.offerName}',
                                                        style:   TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 14,
                                                          fontFamily: 'Aileron',
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),

                                                      // 🔹 OFFER DESCRIPTION
                                                      Text(
                                                        offer.offerDescription ??
                                                            'No Description',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),

                                                      // 🔹 OFFER ADDRESS
                                                      Flexible(
                                                        child: Text(
                                                          offer.offerAddress,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),


                                                      // 🔹 VIEW OFFER BUTTON
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OfferDetailsScreen(
                                                                      offerID: offer
                                                                          .offerID),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'VIEW OFFERS',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12),
                                                        ),
                                                      ),

                                                      // 🔹 RATING SECTION (unchanged)
                                                      StreamBuilder<
                                                          DocumentSnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'candidOffers')
                                                            .doc(offer.offerID)
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const SizedBox(
                                                              height: 20,
                                                              width: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            );
                                                          }

                                                          if (snapshot
                                                              .hasError) {
                                                            return Text(
                                                                'Error: ${snapshot.error}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12));
                                                          }

                                                          if (!snapshot
                                                                  .hasData ||
                                                              !snapshot.data!
                                                                  .exists) {
                                                            return const Text(
                                                                'Offer not found',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12));
                                                          }

                                                          final data = snapshot
                                                                  .data!
                                                                  .data()
                                                              as Map<String,
                                                                  dynamic>?;
                                                          if (data == null) {
                                                            return const Text(
                                                                'No data available',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12));
                                                          }

                                                          final cumulativeRating =
                                                              (data['cumulativeRating']
                                                                          as num?)
                                                                      ?.toDouble() ??
                                                                  0.0;
                                                          final ratingCount =
                                                              (data['ratingCount']
                                                                      as int?) ??
                                                                  0;
                                                          final averageRating =
                                                              ratingCount > 0
                                                                  ? cumulativeRating /
                                                                      ratingCount
                                                                  : 0.0;

                                                          return Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              ...List.generate(
                                                                  5, (index) {
                                                                return Icon(
                                                                  index <
                                                                          averageRating
                                                                              .round()
                                                                      ? Icons
                                                                          .star
                                                                      : Icons
                                                                          .star_border,
                                                                  color: Colors
                                                                      .amber,
                                                                  size: 16,
                                                                );
                                                              }),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                ratingCount > 0
                                                                    ? '${averageRating.toStringAsFixed(1)} / 5'
                                                                    : 'No ratings',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey,
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
                                              // 🔹 IMAGE SECTION (same)
                                              Expanded(
                                                flex: 2,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .horizontal(
                                                          right:
                                                              Radius.circular(
                                                                  10)),
                                                  child: offer.offerImages
                                                          .isNotEmpty
                                                      ? CachedNetworkImage(
                                                          imageUrl: offer
                                                              .offerImages
                                                              .first,
                                                          fit: BoxFit.cover,
                                                          height:
                                                              double.infinity,
                                                        )
                                                      : Container(
                                                          color: Colors.grey,
                                                          child: const Center(
                                                              child: Text(
                                                                  'No Image')),
                                                        ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 2.h),
                    StreamBuilder<List<OffersColl>>(
                      stream: isar.offersColls
                          .filter()
                          .isTrendingEqualTo(true)
                          .offerTypeEqualTo('product')
                          .selectedCityEqualTo(controller.selectedCity)
                          .build()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        List<OffersColl> isTrending = snapshot.data ?? [];

                        // ✅ Use SingleChildScrollView to avoid overflow when content is taller than screen
                        return Visibility(
                          visible: isTrending.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),
                                  // ✅ Constrain the Carousel height
                                  StreamBuilder<List<OffersColl>>(
                                    stream: isar.offersColls
                                        .filter()
                                        .isTrendingEqualTo(true)
                                        .offerTypeEqualTo('product')
                                        .selectedCityEqualTo(
                                            controller.selectedCity)
                                        .build()
                                        .watch(fireImmediately: true),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }

                                      List<OffersColl> isTrending =
                                          snapshot.data ?? [];

                                      return Visibility(
                                        visible: isTrending.isNotEmpty,
                                        child: Column(
                                          children: [
                                            const Divider(),
                                            Card(
                                              elevation: 0,
                                              color: const Color(0xFFDC2121),
                                              // Even lighter shade of blue
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  '🔥 Trending Offers',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Divider(),
                                            SizedBox(height: 1.h),
                                            CarouselSlider.builder(
                                              itemCount: isTrending.length,
                                              options: CarouselOptions(
                                                height: 31.h,
                                                viewportFraction: 0.85,
                                                enlargeCenterPage: true,
                                                autoPlay: true,
                                                autoPlayInterval:
                                                    const Duration(seconds: 3),
                                                autoPlayAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 800),
                                              ),
                                              itemBuilder:
                                                  (context, index, realIndex) {
                                                return _buildCarouselOfferCard(
                                                    isTrending[index],
                                                    context,
                                                    true);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // SizedBox(
                    //   height: 2.h,
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Card(
                        elevation: 0,
                        color: const Color(0xFF2C3E6C),
                        // Even lighter shade of blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'FEATURED PRODUCT OFFERS',
                            style: GoogleFonts.workSans(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0.02,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    SingleChildScrollView(
                      child: Container(
                        height: 25.h,
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StreamBuilder<List<OffersColl>>(
                                    stream: isar.offersColls
                                        .filter()
                                        .offerNameIsNotEmpty()
                                        .selectedCityEqualTo(
                                            controller.selectedCity)
                                        .offerTypeEqualTo('product')
                                        .sortByDistanceFromUserInMeters()
                                        .build()
                                        .watch(fireImmediately: true),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }
                                      List<OffersColl> offers =
                                          snapshot.data ?? [];
                                      if (offers.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showPopup(context),
                                                  child: Image.asset(
                                                    'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      // Debug print to check the length of the offers list
                                      print('Offers length: ${offers.length}');
                                      // Make sure that the length is correctly handled
                                      int itemCount = offers.length > 10
                                          ? 11
                                          : offers.length;
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: itemCount,
                                        itemBuilder: (context, index) {
                                          print(
                                              'Building item at index: $index');
                                          if (index == 10 &&
                                              offers.length > 10) {
                                            // View More item
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ServiceListing(), // Assuming StoreListing is a widget
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    // Replace with the icon you prefer
                                                    color: Colors.black,
                                                    size:
                                                        30, // Adjust icon size as needed
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          // Safety check to prevent index out of range errors
                                          if (index >= offers.length) {
                                            print(
                                                'Index $index out of range for offers list');
                                            return const SizedBox
                                                .shrink(); // Return an empty widget if index is out of range
                                          }
                                          var ele = offers[index];
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.92,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.black
                                              //         .withOpacity(0.05),
                                              //     offset: const Offset(0, 4),
                                              //     blurRadius: 15,
                                              //     spreadRadius: 1,
                                              //   ),
                                              // ],
                                            ),
                                            child: Material(
                                              // Added for ripple effect
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          OfferDetailsScreen(
                                                              offerID:
                                                                  ele.offerID),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Left Content Section
// Left Content Section
                                                    Expanded(
                                                      flex: 3,
                                                      child: SingleChildScrollView(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(16),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // 🟢 PRODUCT NAME + LIKES ROW
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      ele.productName ?? 'Unnamed Product',
                                                                      style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Color(0xFF2C3E50),
                                                                        height: 1.3,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.red.shade50,
                                                                      borderRadius: BorderRadius.circular(20),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Icon(
                                                                          Icons.favorite,
                                                                          color: Colors.red.shade400,
                                                                          size: 16,
                                                                        ),
                                                                         Text(
                                                                          '${ele.likesCount}',
                                                                          style: TextStyle(
                                                                            color: Colors.red.shade400,
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              // 🟣 OFFER NAME
                                                              Text(
                                                                 'OFFER NAME: ${ele.offerName}',
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.green,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),

                                                              // 🟡 OFFER DESCRIPTION
                                                              Text(
                                                                ele.offerDescription ?? '',
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.black54,
                                                                  height: 1.4,
                                                                ),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              const SizedBox(height: 5),

                                                              // 🔹 Address Section
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Icon(
                                                                    Icons.location_on_outlined,
                                                                    size: 16,
                                                                    color: Colors.grey[600],
                                                                  ),
                                                                  const SizedBox(width: 4),
                                                                  Expanded(
                                                                    child: Text(
                                                                      ele.offerAddress,
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.grey[600],
                                                                        height: 1.4,
                                                                      ),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),


                                                              // 🔹 Rating StreamBuilder (same as before)
                                                              StreamBuilder<DocumentSnapshot>(
                                                                stream: FirebaseFirestore.instance
                                                                    .collection('candidOffers')
                                                                    .doc(ele.offerID)
                                                                    .snapshots(),
                                                                builder: (context, snapshot) {
                                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                                    return const LinearProgressIndicator(
                                                                      minHeight: 2,
                                                                      backgroundColor: Colors.transparent,
                                                                    );
                                                                  }

                                                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                                                    return const SizedBox.shrink();
                                                                  }

                                                                  final data =
                                                                  snapshot.data!.data() as Map<String, dynamic>?;
                                                                  if (data == null) {
                                                                    return const SizedBox.shrink();
                                                                  }

                                                                  final cumulativeRating =
                                                                      (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
                                                                  final ratingCount = (data['ratingCount'] as int?) ?? 0;
                                                                  final averageRating = ratingCount > 0
                                                                      ? cumulativeRating / ratingCount
                                                                      : 0.0;

                                                                  return Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      ...List.generate(5, (index) {
                                                                        return Icon(
                                                                          index < averageRating.round()
                                                                              ? Icons.star_rounded
                                                                              : Icons.star_outline_rounded,
                                                                          color: const Color(0xFFFFB800),
                                                                          size: 18,
                                                                        );
                                                                      }),
                                                                      const SizedBox(width: 4),
                                                                      Expanded(
                                                                        child: Text(
                                                                          ratingCount > 0
                                                                              ? '${averageRating.toStringAsFixed(1)} / 5'
                                                                              : 'No ratings yet',
                                                                          style: const TextStyle(
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight.w500,
                                                                            color: Color(0xFF6B7280),
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              ),

                                                              const SizedBox(height: 8),

                                                              // 🔹 VIEW OFFERS BUTTON
                                                              SizedBox(
                                                                width: double.infinity,
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            OfferDetailsScreen(offerID: ele.offerID),
                                                                      ),
                                                                    );
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                    foregroundColor: Colors.white,
                                                                    backgroundColor: const Color(0xFF1A1A1A),
                                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    elevation: 0,
                                                                  ),
                                                                  child: const Text(
                                                                    'VIEW OFFERS',
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w600,
                                                                      letterSpacing: 0.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Right Image Section
                                                    Expanded(
                                                      flex: 2,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topRight:
                                                              Radius.circular(
                                                                  16),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  16),
                                                        ),
                                                        child: SizedBox(
                                                          height: 220,
                                                          // Fixed height for consistency
                                                          child: ele.offerImages
                                                                  .isNotEmpty
                                                              ? CachedNetworkImage(
                                                                  imageUrl: ele
                                                                      .offerImages
                                                                      .first,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Container(
                                                                    color: Colors
                                                                            .grey[
                                                                        100],
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        color: Colors
                                                                            .grey[400],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Container(
                                                                    color: Colors
                                                                            .grey[
                                                                        100],
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .image_not_supported_outlined,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            32,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  color: Colors
                                                                          .grey[
                                                                      100],
                                                                  child:
                                                                      const Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .image_outlined,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 32,
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(width: 4);
                                        },
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ), // const SizedBox(height: 8),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                elevation: 4,
                                // Adjust the elevation for shadow effect
                                color: Color(0xFF2C3E6C),
                                // Background color of the card
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust the border radius as needed
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'SERVICE CATEGORIES',
                                    style: GoogleFonts.workSans(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                      // Adjusted to 1 for better line height
                                      letterSpacing: 0.02,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 0.0),
                                // Adjust the right padding as needed
                                child: SizedBox(
                                  width: 25.w, // Adjust as needed
                                  height: 34, // Adjust as neededeeded
                                  child: MyWidgets().getLargeButton(
                                    title: 'Browse All',
                                    onPress: () =>
                                        Get.to(() => ServiceCategory()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Add space between the sections
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate responsive sizes based on screen width
                              final screenWidth =
                                  MediaQuery.of(context).size.width;
                              final isSmallScreen = screenWidth < 360;
                              final isMediumScreen =
                                  screenWidth >= 360 && screenWidth < 600;
                              final isLargeScreen = screenWidth >= 600;

                              // Adjust sizes based on screen size
                              final fontSize = isSmallScreen
                                  ? 12.sp
                                  : isMediumScreen
                                      ? 14.sp
                                      : 16.sp;

                              final iconSize = isSmallScreen
                                  ? 14.sp
                                  : isMediumScreen
                                      ? 18.sp
                                      : 20.sp;

                              final containerSize = isSmallScreen
                                  ? 28.0
                                  : isMediumScreen
                                      ? 32.0
                                      : 36.0;

                              final horizontalPadding = isSmallScreen
                                  ? 12.0
                                  : isMediumScreen
                                      ? 16.0
                                      : 20.0;

                              return Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: horizontalPadding,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      isLargeScreen ? 600.0 : double.infinity,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Explore More Service Categories',
                                          style: GoogleFonts.workSans(
                                            color: Colors.black,
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                          width: isSmallScreen ? 4.w : 8.w),
                                      InkWell(
                                        onTap: () {
                                          controller.scrollToEnd(
                                              controller.scrollController2);
                                        },
                                        child: Container(
                                          width: containerSize,
                                          height: containerSize,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                            // Add subtle shadow for better visibility
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.black
                                            //         .withOpacity(0.1),
                                            //     blurRadius: 4,
                                            //     offset: Offset(0, 2),
                                            //   ),
                                            // ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              // size: iconSize,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Stack(
                      textDirection: TextDirection.rtl,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.toggleCatsName();
                          },
                          child: AnimatedContainer(
                            height: controller.showCatsName ? 12.h : 14.h,
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
                                if (snapshot.data != null &&
                                    !snapshot.hasError) {
                                  catsList = snapshot.data as List<CatsColl>;

                                  if (controller.selectedCatID.isEmpty &&
                                      catsList.isNotEmpty) {
                                    Future.delayed(Duration.zero, () {
                                      controller.selectedCatID =
                                          catsList.first.catID;
                                      controller.update();
                                    });
                                  }
                                } else {
                                  return const Center(
                                      child: Text('Loading...'));
                                }

                                int itemCount =
                                    catsList.length > 10 ? 11 : catsList.length;

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 0),
                                  child: catsList.isEmpty
                                      ? const Text('Empty List')
                                      : ListView.separated(
                                          controller:
                                              controller.scrollController2,
                                          shrinkWrap: true,
                                          itemCount: itemCount,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            if (index == 10 &&
                                                catsList.length > 10) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const OfferCategories(),
                                                    ),
                                                  );
                                                },
                                                child: SizedBox(
                                                  width:
                                                      controller.listItemWidth,
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.more_horiz,
                                                          size: 30),
                                                      SizedBox(height: 5),
                                                      Text('View More',
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            var cat = catsList[index];

                                            return InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OffersScreen(
                                                            selectedCatID:
                                                                cat.catID),
                                                  ),
                                                );
                                              },
                                              child: SizedBox(
                                                width: controller.listItemWidth,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        border: cat.catID ==
                                                                controller
                                                                    .selectedCatID
                                                            ? Border.all(
                                                                color: const Color(
                                                                    0xFFDB2020),
                                                                width: 3.0)
                                                            : null,
                                                      ),
                                                      child: SvgPicture.network(
                                                        cat.catImg,
                                                        fit: BoxFit.contain,
                                                        placeholderBuilder:
                                                            (BuildContext
                                                                    context) =>
                                                                Image.asset(
                                                          'lib/Images/app_icon_mid.jpeg',
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    SizedBox(
                                                      width: controller
                                                          .listItemWidth,
                                                      child: Text(
                                                        cat.catName,
                                                        style: TextStyle(
                                                          fontSize: 8.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const VerticalDivider(
                                                  width: 5,
                                                  color: Colors.transparent),
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Center(
                    //   child: Stack(
                    //     textDirection: TextDirection.rtl,
                    //     children: [
                    //       InkWell(
                    //         onTap: () {
                    //           controller.toggleCatsName();
                    //         },
                    //         child: AnimatedContainer(
                    //           height: controller.showCatsName ? 12.h : 14.h,
                    //           width: 100.w,
                    //           duration: const Duration(milliseconds: 300),
                    //           child: Builder(
                    //             builder: (context) {
                    //               final categoryList =
                    //                   mainCategories2.keys.toList();
                    //               final itemCount = categoryList.length > 10
                    //                   ? 11
                    //                   : categoryList.length;
                    //
                    //               return ListView.separated(
                    //                 controller: controller.scrollController1,
                    //                 shrinkWrap: true,
                    //                 itemCount: itemCount,
                    //                 scrollDirection: Axis.horizontal,
                    //                 physics:
                    //                     const AlwaysScrollableScrollPhysics(),
                    //                 itemBuilder: (context, index) {
                    //                   if (index == 10 &&
                    //                       categoryList.length > 10) {
                    //                     // ✅ View More opens ServiceHomeScreen
                    //                     return InkWell(
                    //                       onTap: () {
                    //                         Navigator.of(context).push(
                    //                           MaterialPageRoute(
                    //                             builder: (context) =>
                    //                                 const ServiceHomeScreen(),
                    //                           ),
                    //                         );
                    //                       },
                    //                       child: SizedBox(
                    //                         width: controller.listItemWidth,
                    //                         child: const Column(
                    //                           mainAxisAlignment:
                    //                               MainAxisAlignment.center,
                    //                           children: [
                    //                             Icon(Icons.more_horiz, size: 30),
                    //                             SizedBox(height: 5),
                    //                             Text('View More',
                    //                                 style:
                    //                                     TextStyle(fontSize: 12)),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     );
                    //                   }
                    //
                    //                   final catName = categoryList[index];
                    //                   final icon = categoryIcons2[catName] ??
                    //                       Icons.category;
                    //
                    //                   return InkWell(
                    //                     onTap: () {
                    //                       showDialog(
                    //                         context: context,
                    //                         builder: (context) {
                    //                           return Center(
                    //                             child: Container(
                    //                               width: 70.w,
                    //                               height: 70.w,
                    //                               padding:
                    //                                   const EdgeInsets.all(16),
                    //                               decoration: BoxDecoration(
                    //                                 color: Colors.white,
                    //                                 borderRadius:
                    //                                     BorderRadius.circular(12),
                    //                                 boxShadow: [
                    //                                   BoxShadow(
                    //                                     color: Colors.black26,
                    //                                     blurRadius: 8,
                    //                                     offset:
                    //                                         const Offset(0, 4),
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                               child: Center(
                    //                                 child: Column(
                    //                                   mainAxisSize:
                    //                                       MainAxisSize.min,
                    //                                   children: [
                    //                                     Icon(icon,
                    //                                         size: 50,
                    //                                         color: Colors.red),
                    //                                     const SizedBox(
                    //                                         height: 10),
                    //                                     Text(
                    //                                       catName,
                    //                                       textAlign:
                    //                                           TextAlign.center,
                    //                                       style: TextStyle(
                    //                                         fontSize: 14.sp,
                    //                                         fontWeight:
                    //                                             FontWeight.bold,
                    //                                       ),
                    //                                     ),
                    //                                     // const SizedBox(height: 20),
                    //                                     // ElevatedButton(
                    //                                     //   onPressed: () {
                    //                                     //     Navigator.pop(context); // Close dialog
                    //                                     //     Navigator.of(context).push(
                    //                                     //       MaterialPageRoute(
                    //                                     //         builder: (context) => OffersScreen(
                    //                                     //           selectedCatID: catName,
                    //                                     //         ),
                    //                                     //       ),
                    //                                     //     );
                    //                                     //   },
                    //                                     //   child: const Text("Continue"),
                    //                                     // ),
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           );
                    //                         },
                    //                       );
                    //                     },
                    //                     child: SizedBox(
                    //                       width: controller.listItemWidth,
                    //                       child: Column(
                    //                         children: [
                    //                           Container(
                    //                             width: 50,
                    //                             height: 50,
                    //                             decoration: BoxDecoration(
                    //                               border: catName ==
                    //                                       controller.selectedCatID
                    //                                   ? Border.all(
                    //                                       color: const Color(
                    //                                           0xFFDB2020),
                    //                                       width: 3.0,
                    //                                     )
                    //                                   : null,
                    //                             ),
                    //                             child: Icon(icon,
                    //                                 size: 40, color: Colors.red),
                    //                           ),
                    //                           const SizedBox(height: 3),
                    //                           SizedBox(
                    //                             width: controller.listItemWidth,
                    //                             child: Text(
                    //                               catName,
                    //                               style: TextStyle(
                    //                                 fontSize: 8.sp,
                    //                                 fontWeight: FontWeight.bold,
                    //                               ),
                    //                               textAlign: TextAlign.center,
                    //                               overflow: TextOverflow.ellipsis,
                    //                               maxLines: 2,
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   );
                    //                 },
                    //                 separatorBuilder: (context, index) =>
                    //                     const VerticalDivider(
                    //                         width: 5, color: Colors.transparent),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    StreamBuilder<List<OffersColl>>(
                      stream: isar.offersColls
                          .filter()
                          .isTrendingEqualTo(true)
                          .offerTypeEqualTo('service')
                          .selectedCityEqualTo(controller.selectedCity)
                          .build()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        List<OffersColl> isTrending = snapshot.data ?? [];

                        return Visibility(
                          visible: isTrending.isNotEmpty,
                          child: Column(
                            children: [
                              const Divider(),
                              Card(
                                elevation: 0,
                                color: const Color(0xFFDC2121),
                                // Even lighter shade of blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    '🔥 Trending Offers',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              SizedBox(height: 1.h),
                              CarouselSlider.builder(
                                itemCount: isTrending.length,
                                options: CarouselOptions(
                                  height: 31.h,
                                  viewportFraction: 0.85,
                                  enlargeCenterPage: true,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  return _buildCarouselOfferCard(
                                      isTrending[index], context, true);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Card(
                        elevation: 0,
                        color: const Color(0xFF2C3E6C),
                        // Even lighter shade of blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'FEATURED SERVICE OFFERS',
                            style: GoogleFonts.workSans(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0.02,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
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
                                      .selectedCityEqualTo(
                                          controller.selectedCity)
                                      .offerTypeEqualTo('service')
                                      .sortByDistanceFromUserInMeters()
                                      .build()
                                      .watch(fireImmediately: true),
                                  builder: (context, snapshot) {
                                    List<OffersColl> offers = [];
                                    if (snapshot.hasData) {
                                      offers = snapshot.data ?? [];
                                    }
                                    return AnimatedSwitcher(
                                      duration: const Duration(seconds: 1),
                                      child:
                                          !snapshot.hasData ||
                                                  controller
                                                      .trendingNowIsLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : offers.isEmpty
                                                  ? Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  _showPopup(
                                                                      context),
                                                              child:
                                                                  Image.asset(
                                                                'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : ListView.separated(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          offers.length > 10
                                                              ? 11
                                                              : offers.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index == 10) {
                                                          // View More item
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const storelisting(), // Assuming StoreListing is a widget
                                                                ),
                                                              );
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  const Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  // Replace with the icon you prefer
                                                                  color: Colors
                                                                      .black,
                                                                  size:
                                                                      30, // Adjust icon size as needed
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        var ele = offers[index];
                                                        return Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.92,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            // boxShadow: [
                                                            //   BoxShadow(
                                                            //     color: Colors
                                                            //         .black
                                                            //         .withOpacity(
                                                            //         0.05),
                                                            //     offset:
                                                            //     const Offset(
                                                            //         0, 4),
                                                            //     blurRadius: 15,
                                                            //     spreadRadius: 1,
                                                            //   ),
                                                            // ],
                                                          ),
                                                          child: Material(
                                                            // Added for ripple effect
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        OfferDetailsScreen(
                                                                            offerID:
                                                                                ele.offerID),
                                                                  ),
                                                                );
                                                              },
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Left Content Section
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: SingleChildScrollView(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(16),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            // 🟢 PRODUCT NAME + LIKES
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    ele.productName ?? 'Unnamed Product',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 18,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF2C3E50),
                                                                                      height: 1.3,
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.red.shade50,
                                                                                    borderRadius: BorderRadius.circular(20),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.favorite,
                                                                                        color: Colors.red.shade400,
                                                                                        size: 16,
                                                                                      ),
                                                                                      const SizedBox(width: 4),
                                                                                      Text(
                                                                                        '${ele.likesCount}',
                                                                                        style: TextStyle(
                                                                                          color: Colors.red.shade400,
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),

                                                                            // 🟣 OFFER NAME
                                                                            Text(
                                                                              'OFFER NAME: ${ele.offerName}',
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.green,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),

                                                                            // 🟡 OFFER DESCRIPTION
                                                                            Text(
                                                                              ele.offerDescription ?? '',
                                                                              style: const TextStyle(
                                                                                fontSize: 14,
                                                                                color: Colors.black54,
                                                                                height: 1.4,
                                                                              ),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                            const SizedBox(height: 6),

                                                                            // 📍 ADDRESS
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.location_on_outlined,
                                                                                  size: 16,
                                                                                  color: Colors.grey[600],
                                                                                ),
                                                                                const SizedBox(width: 4),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    ele.offerAddress,
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      color: Colors.grey[600],
                                                                                      height: 1.4,
                                                                                    ),
                                                                                    maxLines: 2,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),

                                                                            // ⭐ RATING SECTION
                                                                            StreamBuilder<DocumentSnapshot>(
                                                                              stream: FirebaseFirestore.instance
                                                                                  .collection('candidOffers')
                                                                                  .doc(ele.offerID)
                                                                                  .snapshots(),
                                                                              builder: (context, snapshot) {
                                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                  return const LinearProgressIndicator(
                                                                                    minHeight: 2,
                                                                                    backgroundColor: Colors.transparent,
                                                                                  );
                                                                                }

                                                                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                                                                  return const SizedBox.shrink();
                                                                                }

                                                                                final data =
                                                                                snapshot.data!.data() as Map<String, dynamic>?;
                                                                                if (data == null) {
                                                                                  return const SizedBox.shrink();
                                                                                }

                                                                                final cumulativeRating =
                                                                                    (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
                                                                                final ratingCount = (data['ratingCount'] as int?) ?? 0;
                                                                                final averageRating = ratingCount > 0
                                                                                    ? cumulativeRating / ratingCount
                                                                                    : 0.0;

                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    ...List.generate(5, (index) {
                                                                                      return Icon(
                                                                                        index < averageRating.round()
                                                                                            ? Icons.star_rounded
                                                                                            : Icons.star_outline_rounded,
                                                                                        color: const Color(0xFFFFB800),
                                                                                        size: 18,
                                                                                      );
                                                                                    }),
                                                                                    const SizedBox(width: 4),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        ratingCount > 0
                                                                                            ? '${averageRating.toStringAsFixed(1)} / 5'
                                                                                            : 'No ratings yet',
                                                                                        style: const TextStyle(
                                                                                          fontSize: 13,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          color: Color(0xFF6B7280),
                                                                                        ),
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        maxLines: 1,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            ),
                                                                            const SizedBox(height: 8),

                                                                            // 🔘 VIEW OFFERS BUTTON
                                                                            SizedBox(
                                                                              width: double.infinity,
                                                                              child: ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) =>
                                                                                          OfferDetailsScreen(offerID: ele.offerID),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  foregroundColor: Colors.white,
                                                                                  backgroundColor: const Color(0xFF1A1A1A),
                                                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                  elevation: 0,
                                                                                ),
                                                                                child: const Text(
                                                                                  'VIEW OFFERS',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    letterSpacing: 0.5,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  // Right Image Section
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topRight:
                                                                            Radius.circular(16),
                                                                        bottomRight:
                                                                            Radius.circular(16),
                                                                      ),
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            220,
                                                                        // Fixed height for consistency
                                                                        child: ele.offerImages.isNotEmpty
                                                                            ? CachedNetworkImage(
                                                                                imageUrl: ele.offerImages.first,
                                                                                fit: BoxFit.cover,
                                                                                placeholder: (context, url) => Container(
                                                                                  color: Colors.grey[100],
                                                                                  child: Center(
                                                                                    child: CircularProgressIndicator(
                                                                                      strokeWidth: 2,
                                                                                      color: Colors.grey[400],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                errorWidget: (context, url, error) => Container(
                                                                                  color: Colors.grey[100],
                                                                                  child: const Center(
                                                                                    child: Icon(
                                                                                      Icons.image_not_supported_outlined,
                                                                                      color: Colors.grey,
                                                                                      size: 32,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(
                                                                                color: Colors.grey[100],
                                                                                child: const Center(
                                                                                  child: Icon(
                                                                                    Icons.image_outlined,
                                                                                    color: Colors.grey,
                                                                                    size: 32,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      separatorBuilder:
                                                          (context, index) {
                                                        return const SizedBox(
                                                            width: 4);
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
                    SizedBox(
                      height: 2.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Card(
                        elevation: 0,
                        color: const Color(0xFF2C3E6C),
                        // Deep blue base color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'DEALS ',
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                  letterSpacing: 0.02,
                                ),
                              ),
                              Text(
                                'NEARBY',
                                style: GoogleFonts.workSans(
                                  color: const Color(0xFFE63946),
                                  // Red accent color
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                  letterSpacing: 0.02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: offersFound
                              ? nearbyOffers.map((offer) {
                                  final color = Color(
                                          (Random().nextDouble() * 0xFFFFFF)
                                              .toInt())
                                      .withOpacity(1.0);
                                  String distanceText;
                                  if (offer.distanceFromUserInMeters < 1000) {
                                    distanceText =
                                        'Within ${offer.distanceFromUserInMeters.toStringAsFixed(0)} Meters';
                                  } else {
                                    double distanceInKm =
                                        offer.distanceFromUserInMeters / 1000;
                                    distanceText =
                                        'Within ${distanceInKm.toStringAsFixed(1)} KM';
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OfferDetailsScreen(
                                                  offerID: offer.offerID),
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
                              : [
                                  buildLocationCard('No Offers Found',
                                      'Check back later', Colors.grey)
                                ],
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
                    SizedBox(
                      height: 5.h,
                    ),
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
          ],
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
    debugPrint('Location services are disabled.');
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Location permissions are denied');
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint('Location permissions are permanently denied.');
    return Future.error('Location permissions are permanently denied.');
  }

  return await Geolocator.getCurrentPosition();
}

Widget _buildCarouselOfferCard(
    OffersColl offer, BuildContext context, bool isTrending) {
  return Card(
    elevation: isTrending ? 6 : 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: isTrending
          ? const BorderSide(color: Color(0xFFDC2121), width: 1.5)
          : BorderSide.none,
    ),
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
        ),
      ),
      child: Column(
        children: [
          if (isTrending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: const BoxDecoration(
                color: Color(0xFFDC2121),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'TRENDING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Product Name + Likes Row
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      offer.productName, // ✅ PRODUCT NAME
                                      style: TextStyle(
                                        fontSize: isTrending ? 18 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
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
                                      mainAxisSize: MainAxisSize.min,
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


                              // 🔹 Offer Name
                              Text(
                                'OFFER NAME: ${offer.offerName}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),


                              // 🔹 Offer Description
                              Text(
                                offer.offerDescription ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                               // 🔹 Address
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      offer.offerAddress,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),


                              // 🔹 Rating + Button
                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.bottomLeft,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OfferDetailsScreen(
                                        offerID: offer.offerID,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isTrending
                                        ? const Color(0xFFDC2121)
                                        : Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 5,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'VIEW OFFERS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              _buildRatingWidget(offer.offerID),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Image Section
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                    child: Container(
                      height: double.infinity,
                      color: Colors.grey[200],
                      child: offer.offerImages.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: offer.offerImages.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 50,
                        ),
                      )
                          : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildRatingWidget(String offerID) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('candidOffers')
        .doc(offerID)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const SizedBox.shrink();
      }

      final data = snapshot.data!.data() as Map<String, dynamic>?;
      if (data == null) return const SizedBox.shrink();

      final cumulativeRating =
          (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
      final ratingCount = (data['ratingCount'] as int?) ?? 0;
      final averageRating =
          ratingCount > 0 ? cumulativeRating / ratingCount : 0.0;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            return Icon(
              index < averageRating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            );
          }),
          // const SizedBox(width: 4),
          Text(
            ratingCount > 0
                ? '${averageRating.toStringAsFixed(1)} / 5'
                : 'No ratings',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      );
    },
  );
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

class ProductDetailScreen extends StatelessWidget {
  final String product;
  final IconData icon;

  const ProductDetailScreen({
    required this.product,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 120,
              color: Colors.green.shade700,
            ),
            SizedBox(height: 30),
            Text(
              product,
              style: GoogleFonts.workSans(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Go Back',
                  style:
                      GoogleFonts.workSans(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
