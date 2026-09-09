// import 'package:audioplayers/audioplayers.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:candid_customer/Screens/NotificationScreens/NotificationScreen.dart';
// import 'package:candid_customer/Screens/ProfileScreens/ProfileUpdateScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../Services/Collections/Offers/OffersColl.dart';
// import '../main.dart';
// import 'CustomShape/MyParallelogram.dart';
// import 'Utils.dart';
//
// final AudioPlayer audioPlayer = AudioPlayer();
//
// class MyWidgets {
//   // Enhanced city search dialog with better UX - Cancel button moved to top right
//   void _showCitySearchDialog(BuildContext context) {
//     String searchQuery = '';
//     List<String> filteredCities = List.from(homeScreenController.cityList);
//     final FlutterTts flutterTts = FlutterTts();
//     Future _speak(String text) async {
//       await flutterTts.setLanguage('hi-IN'); // Hindi language
//       await flutterTts.setPitch(1); // Voice pitch (optional)
//       await flutterTts.speak(text); // Speak the text
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Prevent dismissing without selection if required
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               // Custom title with cancel button in top right
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on_outlined, color: Colors.red),
//                       const SizedBox(width: 8),
//                       const Text('Select City'),
//                     ],
//                   ),
//                   // Cancel button moved to top right
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close),
//                     iconSize: 24,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                     color: Colors.black,
//                   ),
//                 ],
//               ),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 height: 400,
//                 child: Column(
//                   children: [
//                     // Search TextField
//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: 'Search city...',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide:
//                               const BorderSide(color: Colors.red, width: 2),
//                         ),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           searchQuery = value.toLowerCase();
//                           if (searchQuery.isEmpty) {
//                             filteredCities =
//                                 List.from(homeScreenController.cityList);
//                           } else {
//                             // Filter cities and put matching ones at top
//                             List<String> exactMatches = [];
//                             List<String> partialMatches = [];
//                             List<String> otherCities = [];
//
//                             for (String city in homeScreenController.cityList) {
//                               String cityLower = city.toLowerCase();
//                               if (cityLower.startsWith(searchQuery)) {
//                                 exactMatches.add(city);
//                               } else if (cityLower.contains(searchQuery)) {
//                                 partialMatches.add(city);
//                               } else {
//                                 otherCities.add(city);
//                               }
//                             }
//
//                             filteredCities = [
//                               ...exactMatches,
//                               ...partialMatches,
//                               ...otherCities
//                             ];
//                           }
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Show message if no cities found
//                     if (filteredCities.isEmpty && searchQuery.isNotEmpty)
//                       Expanded(
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.search_off,
//                                   size: 48, color: Colors.grey),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No cities found',
//                                 style: GoogleFonts.workSans(
//                                   fontSize: 18,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       // City List
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: filteredCities.length,
//                           itemBuilder: (context, index) {
//                             String city = filteredCities[index];
//                             bool isHighlighted = searchQuery.isNotEmpty &&
//                                 city.toLowerCase().contains(searchQuery);
//
//                             return Card(
//                               margin: const EdgeInsets.symmetric(vertical: 2),
//                               child: ListTile(
//                                 leading: const Icon(Icons.location_on,
//                                     color: Colors.red),
//                                 title: Text(
//                                   city,
//                                   style: GoogleFonts.workSans(
//                                     fontWeight: isHighlighted
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                                     color: isHighlighted
//                                         ? Colors.red
//                                         : Colors.black,
//                                   ),
//                                 ),
//                                 onTap: () {
//                                   homeScreenController.updateSelectedCity(city);
//                                   Navigator.of(context).pop();
//                                   _speak(filteredCities[index]); // Speak on tap
//
//                                   // Show confirmation snackbar
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('City changed to $city'),
//                                       backgroundColor: Colors.green,
//                                       duration: const Duration(seconds: 2),
//                                     ),
//                                   );
//                                 },
//                                 trailing:
//                                     homeScreenController.selectedCity == city
//                                         ? const Icon(Icons.check_circle,
//                                             color: Colors.green)
//                                         : null,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // Removed actions array since cancel button is now in title
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Method to show city selection requirement dialog
//   void _showCityRequiredDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.warning, color: Colors.orange),
//               SizedBox(width: 8),
//               Text('City Selection Required'),
//             ],
//           ),
//           content: const Text(
//             'Please select your city to continue using the app. This helps us show you relevant offers and services.',
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _showCitySearchDialog(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Select City'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   getLargeButton(
//       {required String title,
//       required onPress,
//       txtScale = 1.0,
//       bgColor = Colors.black,
//       txtColor = Colors.white}) {
//     return SizedBox(
//       height: 6.h,
//       width: 95.w,
//       child: OutlinedButton(
//           style: OutlinedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               backgroundColor: bgColor,
//               foregroundColor: txtColor),
//           onPressed: onPress,
//           child: FittedBox(
//             fit: BoxFit.fill,
//             child: Text(
//               title,
//               textScaleFactor: txtScale,
//               style: GoogleFonts.workSans(fontSize: 20.sp),
//             ),
//           )),
//     );
//   }
//
//   AppBar myAppBar() {
//     return AppBar(
//       toolbarHeight: 80,
//       elevation: 0,
//       backgroundColor: bottomNavController.selectedIndex == 0
//           ? const Color(0xFFDC2121)
//           : Colors.white,
//       foregroundColor:
//           bottomNavController.selectedIndex == 0 ? Colors.white : Colors.black,
//       leading: Builder(
//         builder: (BuildContext context) {
//           return Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: IconButton(
//               icon: Icon(
//                 Icons.menu,
//                 color: bottomNavController.selectedIndex == 0
//                     ? Colors.white
//                     : Colors.black87,
//                 size: 28,
//               ),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             ),
//           );
//         },
//       ),
//       automaticallyImplyLeading: false,
//       titleSpacing: 0,
//       title: LayoutBuilder(
//         builder: (context, constraints) {
//           bool isSmallScreen = constraints.maxWidth < 600;
//           return Padding(
//             padding: const EdgeInsets.only(left: 0.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Location and City Dropdown Section
//                 Expanded(
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Icon(
//                       //   Icons.location_on_outlined,
//                       //   color: bottomNavController.selectedIndex == 0
//                       //       ? Colors.white
//                       //       :   Color.fromRGBO(252, 70, 70, 1),
//                       //   size: 24,
//                       // ),
//                       // IconButton(
//                       //   icon: Icon(
//                       //     Icons.location_on_outlined,
//                       //     color: bottomNavController.selectedIndex == 0
//                       //         ? Colors.white
//                       //         : Colors.black87,
//                       //     size: 28,
//                       //   ),
//                       //   onPressed: () {
//                       //
//                       //    },
//                       // ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.location_on_outlined,
//                           color: bottomNavController.selectedIndex == 0
//                               ? Colors.white
//                               : Colors.black87,
//                           size: 28,
//                         ),
//                         onPressed: () {},
//                         // onPressed: () async {
//                         //   final selectedCity = await Navigator.push(
//                         //     context,
//                         //     MaterialPageRoute(
//                         //       builder: (_) => CityPickerScreen(
//                         //         cityList:
//                         //             homeScreenController.cityList, // your list
//                         //         onCitySelected: (city) {
//                         //           homeScreenController.selectedCity = city;
//                         //           homeScreenController.update();
//                         //         },
//                         //       ),
//                         //     ),
//                         //   );
//                         // },
//                       ),
//
//                       SizedBox(width: 0),
//                       // City Selection Button (Enhanced)
//                       Flexible(
//                         child: Container(
//                           constraints: BoxConstraints(
//                             maxWidth: isSmallScreen ? 160 : 200,
//                           ),
//                           child: homeScreenController.cityList.isNotEmpty &&
//                                   !homeScreenController.isLoading
//                               ? GestureDetector(
//                                   onTap: () => _showCitySearchDialog(context),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 8),
//                                     decoration: BoxDecoration(
//                                       // color: (homeScreenController
//                                       //             .selectedCity?.isEmpty ??
//                                       //         true)
//                                       //     ? Colors.red.withOpacity(0.1)
//                                       //     : Colors.transparent,
//                                       color: Colors.white,
//                                       border: Border.all(
//                                         color: (homeScreenController
//                                                     .selectedCity?.isEmpty ??
//                                                 true)
//                                             ? Colors.black
//                                             : Colors.transparent,
//                                         width: 1,
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         // Show warning icon if no city selected
//                                         if (homeScreenController
//                                                 .selectedCity?.isEmpty ??
//                                             true)
//                                           if (homeScreenController
//                                                   .selectedCity?.isEmpty ??
//                                               true)
//                                             const SizedBox(width: 4),
//
//                                         Expanded(
//                                           child: Text(
//                                             homeScreenController.selectedCity
//                                                         ?.isEmpty ??
//                                                     true
//                                                 ? "City Select "
//                                                 : homeScreenController
//                                                     .selectedCity!,
//                                             style: TextStyle(
//                                               color: (homeScreenController
//                                                           .selectedCity
//                                                           ?.isEmpty ??
//                                                       true)
//                                                   ? Colors.black
//                                                   : Colors.black87,
//                                               fontSize:
//                                                   isSmallScreen ? 12.sp : 10.sp,
//                                               fontWeight: (homeScreenController
//                                                           .selectedCity
//                                                           ?.isEmpty ??
//                                                       true)
//                                                   ? FontWeight.w600
//                                                   : FontWeight.w500,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ),
//                                         Icon(
//                                           Icons.keyboard_arrow_down_sharp,
//                                           color: (homeScreenController
//                                                       .selectedCity?.isEmpty ??
//                                                   true)
//                                               ? Colors.black
//                                               : Colors.black54,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               : const SizedBox(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Notification and Profile Section
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Notification Button
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 4.0 : 8.0,
//                       ),
//                       child: Card(
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: SizedBox(
//                           height: 5.5.h,
//                           width: 12.5.w,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.notifications_outlined,
//                                   color: Colors.black87,
//                                   size: 28,
//                                 ),
//                                 onPressed: ()   {
//                                   // Play bell or ting sound here
//                                   // await audioPlayer.play(
//                                   //     AssetSource('sounds/notification.mp3'));
//
//                                   // Then navigate to NotificationScreen
//                                   Navigator.of(navigatorKey.currentContext!)
//                                       .push(
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           const NotificationScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               if (notSeenNotifications.isNotEmpty)
//                                 Positioned(
//                                   top: 8,
//                                   right: 8,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     decoration: const BoxDecoration(
//                                       color: Colors.red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Text(
//                                       notSeenNotifications.length.toString(),
//                                       style: GoogleFonts.workSans(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Profile Image
//                     Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: Card(
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: SizedBox(
//                           height: 5.5.h,
//                           width: 12.5.w,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () =>
//                                 Navigator.of(navigatorKey.currentContext!).push(
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             const ProfileUpdateScreen())),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: CachedNetworkImage(
//                                 imageUrl: localUser?.userProfileImg ?? "",
//                                 fit: BoxFit.cover,
//                                 placeholder: (context, url) => const Center(
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                                 errorWidget: (context, url, error) =>
//                                     const Icon(
//                                   Icons.person,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Method to check if city is selected and show dialog if not
//   bool checkCitySelection(BuildContext context) {
//     if (homeScreenController.selectedCity?.isEmpty ?? true) {
//       _showCityRequiredDialog(context);
//       return false;
//     }
//     return true;
//   }
//
//   AppBar offerDetailsAppBar({required OffersColl ele, required bool isActive}) {
//     return AppBar(
//       title: Text(
//         !isActive ? '           Offer Details' : 'Offer Activated',
//         style: GoogleFonts.workSans(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Colors.transparent,
//       foregroundColor: Colors.black,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//         onPressed: () => Navigator.of(navigatorKey.currentContext!).pop(),
//       ),
//       // centerTitle: true,
//     );
//   }
//
//   AppBar getAppBar({required String title}) {
//     return AppBar(
//       title: Text(
//         title,
//         style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Container getOfferHeadingContainer({required OffersColl ele}) {
//     return Container(
//       height: 8.h,
//       color: Colors.pink.shade100,
//       child: Row(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Expanded(
//               child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CachedNetworkImage(imageUrl: ele.offerImages.first),
//           )),
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(ele.productName,
//                       style: GoogleFonts.workSans(
//                           color: Colors.pink, fontWeight: FontWeight.bold)),
//                   Text(ele.offerAddress,
//                       style: GoogleFonts.workSans(color: Colors.pink)),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//               flex: 2,
//               child: CustomPaint(
//                 painter: MyParallelogram(),
//                 child: Center(
//                     child: Text(
//                   'Trending',
//                   style: GoogleFonts.workSans(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 )),
//               ))
//         ],
//       ),
//     );
//   }
//
//   productServiceSwitch() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.only(top: 11),
//         width: 60.w,
//         height: 5.h,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.pink,
//           ),
//           borderRadius: BorderRadius.circular(30.0),
//           gradient: LinearGradient(
//             colors: [
//               !homeScreenController.screenTypeProducts
//                   ? Colors.pink
//                   : Colors.pink.shade100,
//               !homeScreenController.screenTypeProducts
//                   ? Colors.blue.shade100
//                   : Colors.blue.shade900
//             ],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             stops: const [0.5, 0.5],
//           ),
//         ),
//         child: SizedBox(
//           width: 30.w,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                   !homeScreenController.screenTypeProducts
//                       ? 'PRODUCTS'
//                       : '        ',
//                   style: GoogleFonts.workSans(
//                       color: homeScreenController.screenTypeProducts
//                           ? Colors.pink
//                           : Colors.white,
//                       fontWeight: FontWeight.bold)),
//               Switch(
//                 value: homeScreenController.screenTypeProducts,
//                 activeColor: Colors.blue.shade900,
//                 inactiveThumbColor: Colors.pink,
//                 activeTrackColor: Colors.white,
//                 onChanged: (value) =>
//                     homeScreenController.updateScreenType(value),
//               ),
//               Text(
//                   homeScreenController.screenTypeProducts
//                       ? 'SERVICES'
//                       : '        ',
//                   style: GoogleFonts.workSans(
//                       color: homeScreenController.screenTypeProducts
//                           ? Colors.white
//                           : Colors.blue.shade900,
//                       fontWeight: FontWeight.bold))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget myDrawerHeader() {
//     return DrawerHeader(
//       child: Column(
//         children: [
//           // User Profile Row
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: CircleAvatar(
//                     radius: 46,
//                     backgroundColor: Colors.white,
//                     child: ClipOval(
//                       child: CachedNetworkImage(
//                         fit: BoxFit.cover,
//                         height: 26.h,
//                         width: 45.w,
//                         progressIndicatorBuilder:
//                             (context, url, downloadProgress) =>
//                                 CircularProgressIndicator(
//                                     value: downloadProgress.progress),
//                         errorWidget: (context, url, error) =>
//                             const Icon(Icons.error),
//                         imageUrl: localUser!.userProfileImg.isNotEmpty
//                             ? localUser!.userProfileImg
//                             : 'https://png.pngtree.com/png-vector/20190710/ourmid/pngtree-user-vector-avatar-png-image_1541962.jpg',
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 3.w),
//                 Expanded(
//                   flex: 2,
//                   child: Center(
//                     child: FittedBox(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '${localUser?.userFirstName} ${localUser?.userLastName}',
//                             style: TextStyle(
//                               fontFamily: 'Aileron',
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.sp,
//                             ),
//                           ),
//                           Text(
//                             '${localUser?.userEmail}',
//                             style: const TextStyle(
//                               fontFamily: 'Aileron',
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Footer Divider
//           Divider(
//             color: Colors.grey[300],
//             thickness: 1,
//           ),
//           // Footer with Logo, App Name, and Version
//           SizedBox(
//             height: 40,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'lib/Images/RealOffers1.png',
//                   height: 5.h,
//                   width: 7.w,
//                 ),
//                 const SizedBox(width: 8),
//                 Flexible(
//                   child: Text(
//                     'Candid Customer',
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.workSans(
//                       fontSize: 9.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   logOutAlertDialog() {
//     debugPrint('logOutAlertDialog clicked!');
//     showDialog(
//       context: navigatorKey.currentContext!,
//       builder: (context) => AlertDialog(
//         title: const Text('Are you sure, you want to logout?'),
//         content: const Text('Click yes to logout!'),
//         actions: [
//           Row(
//             children: [
//               Expanded(
//                   child: Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: MyWidgets().getLargeButton(
//                   onPress: () => Navigator.of(context).pop(),
//                   title: 'No',
//                 ),
//               )),
//               Expanded(
//                   child: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: MyWidgets().getLargeButton(
//                   onPress: Utils().logOutUser,
//                   title: 'Yes',
//                 ),
//               )),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget getCandidBranding() {
//     return Center(
//       child: Container(
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'lib/Images/RealOffers1.png',
//               width: 30,
//               height: 30,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   width: 30,
//                   height: 30,
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.image_not_supported, size: 20),
//                 );
//               },
//             ),
//             const SizedBox(width: 8),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Candid Customer',
//                   style: GoogleFonts.workSans(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   CachedNetworkImage getCachedNetworkImage({required String imgUrl}) {
//     // Define a default placeholder
//     const defaultPlaceholder = 'https://via.placeholder.com/150';
//
//     // Validate the URL
//     String validatedUrl = imgUrl;
//     try {
//       final uri = Uri.tryParse(imgUrl);
//       if (imgUrl.isEmpty || uri == null || !uri.hasAbsolutePath) {
//         validatedUrl = defaultPlaceholder;
//       }
//     } catch (e) {
//       debugPrint('Error parsing image URL: $e');
//       validatedUrl = defaultPlaceholder;
//     }
//
//     return CachedNetworkImage(
//       imageUrl: validatedUrl,
//       placeholder: (context, url) => Container(
//         color: Colors.grey[200],
//         child: const Center(child: CircularProgressIndicator()),
//       ),
//       errorWidget: (context, url, error) => Container(
//         color: Colors.grey[200],
//         child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
//       ),
//     );
//   }
//
//   SizedBox getNotificationCard({
//     required String headline,
//     required String description,
//     required bool isSeen,
//     required VoidCallback onMarkAsRead,
//   }) {
//     return SizedBox(
//       width: 320,
//       height: 120,
//       child: Center(
//         child: Stack(
//           children: [
//             Positioned(
//               left: 0,
//               top: 0,
//               child: Container(
//                 width: 320,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 16,
//               top: 42,
//               child: SizedBox(
//                 width: 278,
//                 child: Text(
//                   description,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 12,
//                     fontFamily: 'Aileron',
//                     fontWeight: FontWeight.w400,
//                     letterSpacing: 0.02,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 16,
//               top: 15,
//               child: Text(
//                 headline,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                   fontFamily: 'Aileron',
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.02,
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 16,
//               top: 90,
//               child: GestureDetector(
//                 onTap: onMarkAsRead,
//                 child: SizedBox(
//                   width: 144,
//                   height: 15,
//                   child: Text(
//                     'Mark as Read',
//                     style: TextStyle(
//                       color: isSeen ? Colors.grey : const Color(0xFF727173),
//                       fontSize: 12,
//                       fontFamily: 'Aileron',
//                       fontWeight: FontWeight.w400,
//                       letterSpacing: 0.02,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 294,
//               top: 16,
//               child: Visibility(
//                 visible: !isSeen,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.red,
//                   ),
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
// class CityPickerScreen extends StatefulWidget {
//   final List<String> cityList;
//   final Function(String) onCitySelected;
//
//   const CityPickerScreen({
//     required this.cityList,
//     required this.onCitySelected,
//   });
//
//   @override
//   State<CityPickerScreen> createState() => _CityPickerScreenState();
// }
//
// class _CityPickerScreenState extends State<CityPickerScreen> {
//   LatLng? pickedLocation;
//   String? detectedCity;
//   bool isLoading = false;
//
//   void _onMapTap(LatLng position) async {
//     setState(() {
//       pickedLocation = position;
//       detectedCity = null;
//       isLoading = true;
//     });
//
//     String? city;
//
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         city = placemarks.first.locality ??
//             placemarks.first.subAdministrativeArea ??
//             "Unknown";
//       }
//     } catch (e) {
//       city = null;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to detect city. Please try again.")),
//       );
//     } finally {
//       setState(() {
//         detectedCity = city;
//         isLoading = false;
//       });
//     }
//
//     if (city == null || city == "Unknown") {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("City could not be detected.")),
//       );
//       return;
//     }
//
//     // Normalize for matching
//     String cityLower = city.trim().toLowerCase();
//     List<String> cityListLower =
//         widget.cityList.map((c) => c.trim().toLowerCase()).toList();
//
//     if (cityListLower.contains(cityLower)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("City matched: $city")),
//       );
//       widget.onCitySelected(city);
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("City not matched.")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Pick a City on Map")),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(22.7196, 75.8577), // example: Indore
//               zoom: 10,
//             ),
//             onTap: _onMapTap,
//             markers: pickedLocation != null
//                 ? {
//                     Marker(
//                       markerId: MarkerId("picked"),
//                       position: pickedLocation!,
//                     )
//                   }
//                 : {},
//           ),
//           if (isLoading)
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }





import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Screens/NotificationScreens/NotificationScreen.dart';
import 'package:candid_customer/Screens/ProfileScreens/ProfileUpdateScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/API/CityServices/CityConnect.dart';
import '../Services/API/OffersServices/OffersConnect.dart';
import '../Services/Collections/Offers/OffersColl.dart';
import '../main.dart';
import 'CustomShape/MyParallelogram.dart';
import 'Utils.dart';

final AudioPlayer audioPlayer = AudioPlayer();

class MyWidgets {
  // Enhanced city search dialog with better UX - Cancel button moved to top right
  void _showCitySearchDialog(BuildContext context) {
    String searchQuery = '';
    List<String> filteredCities = List.from(homeScreenController.cityList);
    final FlutterTts flutterTts = FlutterTts();
    Future _speak(String text) async {
      await flutterTts.setLanguage('hi-IN'); // Hindi language
      await flutterTts.setPitch(1); // Voice pitch (optional)
      await flutterTts.speak(text); // Speak the text
    }

    showDialog(
      context: context,
      barrierDismissible:
      false, // Prevent dismissing without selection if required
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // Custom title with cancel button in top right
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Select City'),
                    ],
                  ),
                  // Cancel button moved to top right
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.black,
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Search TextField
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          if (searchQuery.isEmpty) {
                            filteredCities =
                                List.from(homeScreenController.cityList);
                          } else {
                            // Filter cities and put matching ones at top
                            List<String> exactMatches = [];
                            List<String> partialMatches = [];
                            List<String> otherCities = [];

                            for (String city in homeScreenController.cityList) {
                              String cityLower = city.toLowerCase();
                              if (cityLower.startsWith(searchQuery)) {
                                exactMatches.add(city);
                              } else if (cityLower.contains(searchQuery)) {
                                partialMatches.add(city);
                              } else {
                                otherCities.add(city);
                              }
                            }

                            filteredCities = [
                              ...exactMatches,
                              ...partialMatches,
                              ...otherCities
                            ];
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Show message if no cities found
                    if (filteredCities.isEmpty && searchQuery.isNotEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No cities found',
                                style: GoogleFonts.workSans(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                    // City List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCities.length,
                          itemBuilder: (context, index) {
                            String city = filteredCities[index];
                            bool isHighlighted = searchQuery.isNotEmpty &&
                                city.toLowerCase().contains(searchQuery);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              child: ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.red),
                                title: Text(
                                  city,
                                  style: GoogleFonts.workSans(
                                    fontWeight: isHighlighted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isHighlighted
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  homeScreenController.updateSelectedCity(city);
                                  Navigator.of(context).pop();
                                  _speak(filteredCities[index]); // Speak on tap

                                  // Show confirmation snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('City changed to $city'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                trailing:
                                homeScreenController.selectedCity == city
                                    ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Removed actions array since cancel button is now in title
            );
          },
        );
      },
    );
  }

  // Method to show city selection requirement dialog
  void _showCityRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('City Selection Required'),
            ],
          ),
          content: const Text(
            'Please select your city to continue using the app. This helps us show you relevant offers and services.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCitySearchDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Select City'),
            ),
          ],
        );
      },
    );
  }

  getLargeButton(
      {required String title,
        required onPress,
        txtScale = 1.0,
        bgColor = Colors.black,
        txtColor = Colors.white}) {
    return SizedBox(
      height: 6.h,
      width: 95.w,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: bgColor,
              foregroundColor: txtColor),
          onPressed: onPress,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text(
              title,
              textScaleFactor: txtScale,
              style: GoogleFonts.workSans(fontSize: 20.sp),
            ),
          )),
    );
  }

  AppBar myAppBar() {
    return AppBar(
      toolbarHeight: 80,
      elevation: 0,
      backgroundColor: bottomNavController.selectedIndex == 0
          ? const Color(0xFFDC2121)
          : Colors.white,
      foregroundColor:
      bottomNavController.selectedIndex == 0 ? Colors.white : Colors.black,
      leading: Builder(
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: bottomNavController.selectedIndex == 0
                    ? Colors.white
                    : Colors.black87,
                size: 28,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          );
        },
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          return Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location and City Dropdown Section
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.location_on_outlined,
                          color: bottomNavController.selectedIndex == 0
                              ? Colors.white
                              : Colors.black87,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),

                      SizedBox(width: 0),
                      // City Selection Button (Enhanced)
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 160 : 200,
                          ),
                          child: homeScreenController.cityList.isNotEmpty &&
                              !homeScreenController.isLoading
                              ? GestureDetector(
                            onTap: () => _showCitySearchDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: (homeScreenController
                                      .selectedCity?.isEmpty ??
                                      true)
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Show warning icon if no city selected
                                  if (homeScreenController
                                      .selectedCity?.isEmpty ??
                                      true)
                                    if (homeScreenController
                                        .selectedCity?.isEmpty ??
                                        true)
                                      const SizedBox(width: 4),

                                  Expanded(
                                    child: Text(
                                      homeScreenController.selectedCity
                                          ?.isEmpty ??
                                          true
                                          ? "City Select "
                                          : homeScreenController
                                          .selectedCity!,
                                      style: TextStyle(
                                        color: (homeScreenController
                                            .selectedCity
                                            ?.isEmpty ??
                                            true)
                                            ? Colors.black
                                            : Colors.black87,
                                        fontSize:
                                        isSmallScreen ? 12.sp : 10.sp,
                                        fontWeight: (homeScreenController
                                            .selectedCity
                                            ?.isEmpty ??
                                            true)
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_sharp,
                                    color: (homeScreenController
                                        .selectedCity?.isEmpty ??
                                        true)
                                        ? Colors.black
                                        : Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification and Profile Section
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Notification Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 4.0 : 8.0,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          height: 5.5.h,
                          width: 12.5.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.black87,
                                  size: 28,
                                ),
                                onPressed: ()   {
                                  // Play bell or ting sound here
                                  // await audioPlayer.play(
                                  //     AssetSource('sounds/notification.mp3'));

                                  // Then navigate to NotificationScreen
                                  Navigator.of(navigatorKey.currentContext!)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const NotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (notSeenNotifications.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      notSeenNotifications.length.toString(),
                                      style: GoogleFonts.workSans(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ✅ FIX: Refresh button now compiles correctly.
                    // - `localSeller` does not exist in this (customer) app;
                    //   this app has `localUser` instead, and re-running
                    //   loginRegisterAccount here isn't needed just to
                    //   refresh the dashboard — that method also requires a
                    //   Firebase `user` + `additionalUserInfo` which aren't
                    //   available in this button's context.
                    // - `OffersConnect` and `CityConnect` are proper
                    //   instance classes (now imported above), so they are
                    //   called as `OffersConnect()` / `CityConnect()`
                    //   instead of as static members.
                    // - `getOfferHistoryApi()` does not exist on
                    //   OffersConnect; the real method is
                    //   `getAllOffersApi(bool offerType)`, called once for
                    //   products and once for services so both refresh.
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.black,
                      onPressed: () async {
                        utils.showSnackBar('Refreshing dashboard...');
                        try {
                          await OffersConnect().getAllOffersApi(true);
                          await OffersConnect().getAllOffersApi(false);
                          await CityConnect().getCityListApi();
                          utils.showSnackBar('Dashboard refreshed!');
                        } catch (e) {
                          utils.showSnackBar('Refresh failed: $e');
                        }
                      },
                    ),

                    // Profile Image
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          height: 5.5.h,
                          width: 12.5.w,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                Navigator.of(navigatorKey.currentContext!).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const ProfileUpdateScreen())),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: localUser?.userProfileImg ?? "",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Method to check if city is selected and show dialog if not
  bool checkCitySelection(BuildContext context) {
    if (homeScreenController.selectedCity?.isEmpty ?? true) {
      _showCityRequiredDialog(context);
      return false;
    }
    return true;
  }

  AppBar offerDetailsAppBar({required OffersColl ele, required bool isActive}) {
    return AppBar(
      title: Text(
        !isActive ? '           Offer Details' : 'Offer Activated',
        style: GoogleFonts.workSans(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.of(navigatorKey.currentContext!).pop(),
      ),
      // centerTitle: true,
    );
  }

  AppBar getAppBar({required String title}) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
      ),
    );
  }

  Container getOfferHeadingContainer({required OffersColl ele}) {
    return Container(
      height: 8.h,
      color: Colors.pink.shade100,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedNetworkImage(imageUrl: ele.offerImages.first),
              )),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(ele.productName,
                      style: GoogleFonts.workSans(
                          color: Colors.pink, fontWeight: FontWeight.bold)),
                  Text(ele.offerAddress,
                      style: GoogleFonts.workSans(color: Colors.pink)),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: CustomPaint(
                painter: MyParallelogram(),
                child: Center(
                    child: Text(
                      'Trending',
                      style: GoogleFonts.workSans(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
              ))
        ],
      ),
    );
  }

  productServiceSwitch() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 11),
        width: 60.w,
        height: 5.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.pink,
          ),
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            colors: [
              !homeScreenController.screenTypeProducts
                  ? Colors.pink
                  : Colors.pink.shade100,
              !homeScreenController.screenTypeProducts
                  ? Colors.blue.shade100
                  : Colors.blue.shade900
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.5, 0.5],
          ),
        ),
        child: SizedBox(
          width: 30.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  !homeScreenController.screenTypeProducts
                      ? 'PRODUCTS'
                      : '        ',
                  style: GoogleFonts.workSans(
                      color: homeScreenController.screenTypeProducts
                          ? Colors.pink
                          : Colors.white,
                      fontWeight: FontWeight.bold)),
              Switch(
                value: homeScreenController.screenTypeProducts,
                activeColor: Colors.blue.shade900,
                inactiveThumbColor: Colors.pink,
                activeTrackColor: Colors.white,
                onChanged: (value) =>
                    homeScreenController.updateScreenType(value),
              ),
              Text(
                  homeScreenController.screenTypeProducts
                      ? 'SERVICES'
                      : '        ',
                  style: GoogleFonts.workSans(
                      color: homeScreenController.screenTypeProducts
                          ? Colors.white
                          : Colors.blue.shade900,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }

  Widget myDrawerHeader() {
    return DrawerHeader(
      child: Column(
        children: [
          // User Profile Row
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 26.h,
                        width: 45.w,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                        imageUrl: localUser!.userProfileImg.isNotEmpty
                            ? localUser!.userProfileImg
                            : 'https://png.pngtree.com/png-vector/20190710/ourmid/pngtree-user-vector-avatar-png-image_1541962.jpg',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: FittedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${localUser?.userFirstName} ${localUser?.userLastName}',
                            style: TextStyle(
                              fontFamily: 'Aileron',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                          Text(
                            '${localUser?.userEmail}',
                            style: const TextStyle(
                              fontFamily: 'Aileron',
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer Divider
          Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
          // Footer with Logo, App Name, and Version
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/Images/RealOffers1.png',
                  height: 5.h,
                  width: 7.w,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Candid Customer',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.workSans(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  logOutAlertDialog() {
    debugPrint('logOutAlertDialog clicked!');
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure, you want to logout?'),
        content: const Text('Click yes to logout!'),
        actions: [
          Row(
            children: [
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MyWidgets().getLargeButton(
                      onPress: () => Navigator.of(context).pop(),
                      title: 'No',
                    ),
                  )),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MyWidgets().getLargeButton(
                      onPress: Utils().logOutUser,
                      title: 'Yes',
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget getCandidBranding() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/Images/RealOffers1.png',
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 30,
                  height: 30,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 20),
                );
              },
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Candid Customer',
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CachedNetworkImage getCachedNetworkImage({required String imgUrl}) {
    // Define a default placeholder
    const defaultPlaceholder = 'https://via.placeholder.com/150';

    // Validate the URL
    String validatedUrl = imgUrl;
    try {
      final uri = Uri.tryParse(imgUrl);
      if (imgUrl.isEmpty || uri == null || !uri.hasAbsolutePath) {
        validatedUrl = defaultPlaceholder;
      }
    } catch (e) {
      debugPrint('Error parsing image URL: $e');
      validatedUrl = defaultPlaceholder;
    }

    return CachedNetworkImage(
      imageUrl: validatedUrl,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }

  SizedBox getNotificationCard({
    required String headline,
    required String description,
    required bool isSeen,
    required VoidCallback onMarkAsRead,
  }) {
    return SizedBox(
      width: 320,
      height: 120,
      child: Center(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 320,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 42,
              child: SizedBox(
                width: 278,
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Aileron',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 15,
              child: Text(
                headline,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Aileron',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.02,
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 90,
              child: GestureDetector(
                onTap: onMarkAsRead,
                child: SizedBox(
                  width: 144,
                  height: 15,
                  child: Text(
                    'Mark as Read',
                    style: TextStyle(
                      color: isSeen ? Colors.grey : const Color(0xFF727173),
                      fontSize: 12,
                      fontFamily: 'Aileron',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.02,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 294,
              top: 16,
              child: Visibility(
                visible: !isSeen,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CityPickerScreen extends StatefulWidget {
  final List<String> cityList;
  final Function(String) onCitySelected;

  const CityPickerScreen({
    required this.cityList,
    required this.onCitySelected,
  });

  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  LatLng? pickedLocation;
  String? detectedCity;
  bool isLoading = false;

  void _onMapTap(LatLng position) async {
    setState(() {
      pickedLocation = position;
      detectedCity = null;
      isLoading = true;
    });

    String? city;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        city = placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            "Unknown";
      }
    } catch (e) {
      city = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to detect city. Please try again.")),
      );
    } finally {
      setState(() {
        detectedCity = city;
        isLoading = false;
      });
    }

    if (city == null || city == "Unknown") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("City could not be detected.")),
      );
      return;
    }

    // Normalize for matching
    String cityLower = city.trim().toLowerCase();
    List<String> cityListLower =
    widget.cityList.map((c) => c.trim().toLowerCase()).toList();

    if (cityListLower.contains(cityLower)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("City matched: $city")),
      );
      widget.onCitySelected(city);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("City not matched.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick a City on Map")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(22.7196, 75.8577), // example: Indore
              zoom: 10,
            ),
            onTap: _onMapTap,
            markers: pickedLocation != null
                ? {
              Marker(
                markerId: MarkerId("picked"),
                position: pickedLocation!,
              )
            }
                : {},
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
