import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Controllers/OffersController/OfferDetailsController.dart';
import 'package:candid_customer/Screens/OffersScreens/OfferEnCashScreen.dart';
import 'package:candid_customer/Screens/OtherScreens/ShowLoadingScreen.dart';
import 'package:candid_customer/Utils/MyWidgets.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../../Services/Collections/Offers/OffersColl.dart';

class OfferDetailsScreen extends StatefulWidget {
  final String offerID;
  const OfferDetailsScreen({super.key, required this.offerID});

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  bool isExpanded = false;   // इसे अपनी class में ऊपर define करें

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: OfferDetailsController(offerID: widget.offerID),
      builder: (controller) {
        return StreamBuilder(
          stream: isar.offersColls
              .filter()
              .offerNameIsNotEmpty()
              .offerIDEqualTo(widget.offerID)
              .build()
              .watch(fireImmediately: true),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something is wrong!');
            } else if (!snapshot.hasData) {
              return const Text('No data!');
            }
            var ele = snapshot.data!.first;
            bool isPrimeMember = localUser!.isUserPrimeMember;
            return Scaffold(
              // appBar: MyWidgets().myAppBar(),
              drawer:
              Drawer(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      MyWidgets().myDrawerHeader(),

                      for (var item in bottomNavController.navDrawerItems)
                        Card(
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
                        ),
                    ],
                  ),
                ),
              ),
              body: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: controller.isLoading
                    ? const ShowLoadingScreen()
                    : Stack(
                  children: [
                    Column(
                      children: [
                        MyWidgets().offerDetailsAppBar(ele: ele, isActive: false),
                        Expanded(
                          flex: 11,
                          child: SizedBox(
                            width: 85.w,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildOfferImageCarousel(controller, ele),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Card(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text('PRIME', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: localUser!.isUserPrimeMember ? Colors.green : const Color(0xFFDB2020),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Extra ${int.parse(ele.discountNoPrime) - int.parse(ele.discountNo)}${ele.discountUoM}',
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Card(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text('REGULAR', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFDB2020),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      ' ${ele.discountNo}${ele.discountUoM}',
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Card(
                                        elevation: 4,
                                        margin: const EdgeInsets.all(8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Center(
                                                    child: IconButton(
                                                      icon: Icon(
                                                        ele.isInWishList
                                                            ? Icons.favorite_outlined
                                                            : Icons.favorite_border_outlined,
                                                        color: ele.isInWishList ? Colors.red : Colors.black,
                                                      ),
                                                      onPressed: () => controller.addOrRemoveOfferFromWishListClickHandler(offer: ele),
                                                    ),
                                                  ),
                                                  Text(
                                                    ele.isInWishList ? "Added to Wishlist" : "Add to Wishlist",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 14),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.share_outlined, color: Colors.black),
                                                        onPressed: () => controller.shareOfferOnSocialMedia(offer: ele),
                                                      ),
                                                      Text(
                                                        "${ele.sharesCount} Shares",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: SvgPicture.asset(
                                                          ele.likedByCurrentUser ? 'lib/Images/Vector.svg' : 'lib/Images/Vector.svg',
                                                          width: 24.0,
                                                          height: 24.0,
                                                        ),
                                                        onPressed: () {
                                                          controller.toggleLike(offer: ele);
                                                        },
                                                      ),
                                                      Text(
                                                        "${max(0, ele.likesCount)} ${ele.likesCount == 1 ? 'Like' : 'Likes'}",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Card(
                                        color: const Color(0xFF800000),
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'MRP',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontFamily: 'Aileron',
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              letterSpacing: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h,),
                                      SizedBox(
                                        width: 70.w,
                                        child: Text(
                                          '₹ ${ele.unitPrice2}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.sp,
                                            fontFamily: 'Aileron',
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.lineThrough,
                                            height: 1,
                                            letterSpacing: 0.02,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 2.h,),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '₹ ${ele.offerDiscountedPrice}',
                                                  style: TextStyle(
                                                    color: localUser!.isUserPrimeMember ? Colors.grey : Colors.red,
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.bold,
                                                    height: 0,
                                                    letterSpacing: 0.02,
                                                    decoration: localUser!.isUserPrimeMember ? TextDecoration.lineThrough : TextDecoration.none,
                                                  ),
                                                ),
                                                Text(
                                                  '* Regular Customer',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: localUser!.isUserPrimeMember ? TextDecoration.lineThrough : TextDecoration.none,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '₹ ${ele.offerPrimeDiscountedPrice}',
                                                  style: TextStyle(
                                                    color: localUser!.isUserPrimeMember ? Colors.green : Colors.red,
                                                    fontSize: localUser!.isUserPrimeMember ? 16.sp : 14.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.bold,
                                                    height: 0,
                                                    letterSpacing: 0.02,
                                                  ),
                                                ),
                                                Text(
                                                  '* Prime Customer',
                                                  style: TextStyle(
                                                    color: localUser!.isUserPrimeMember ? Colors.green : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (localUser!.isUserPrimeMember)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'You are a Prime member! You get this offer at ₹${ele.offerPrimeDiscountedPrice}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 8.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      SizedBox(height: 1.h,),
                                      Card(
                                        color: const Color(0xFF800000),
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'OFFER ID',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontFamily: 'Aileron',
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              letterSpacing: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      SizedBox(
                                        width: 70.w,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                ele.offerID,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.sp,
                                                  fontFamily: 'Aileron',
                                                  fontWeight: FontWeight.bold,
                                                  height: 0,
                                                  letterSpacing: 0.02,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(text: ele.offerID));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Offer ID copied to clipboard')),
                                                );
                                              },
                                              child: Icon(
                                                Icons.copy,
                                                size: 16.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 1.h,),
                                      Card(
                                        color: const Color(0xFF800000),
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'PRODUCT NAME',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontFamily: 'Aileron',
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              letterSpacing: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h,),
                                      SizedBox(
                                        width: 70.w,
                                        child: Text(
                                          ele.productName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontFamily: 'Aileron',
                                            fontWeight: FontWeight.bold,
                                            height: 0,
                                            letterSpacing: 0.02,
                                          ),
                                        ),
                                      ),
                                      const Divider(),

                                      Card(
                                        color: const Color(0xFF800000),
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'OFFER NAME',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontFamily: 'Aileron',
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              letterSpacing: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h,),
                                      SizedBox(
                                        width: 70.w,
                                        child: Text(
                                          ele.offerName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontFamily: 'Aileron',
                                            fontWeight: FontWeight.bold,
                                            height: 0,
                                            letterSpacing: 0.02,
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      Card(
                                        color: const Color(0xFF800000),
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'OFFER DESCRIPTION',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontFamily: 'Aileron',
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              letterSpacing: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h,),

                                      SizedBox(
                                        width: 70.w,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ele.offerDescription,
                                              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                              maxLines: isExpanded ? null : 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.sp,
                                                fontFamily: 'Aileron',
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                                letterSpacing: 0.02,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            // MORE / LESS Button
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isExpanded = !isExpanded;
                                                });
                                              },
                                              child: Text(
                                                isExpanded ? "Less" : "More",
                                                style: TextStyle(
                                                  color:   Colors.red,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 1.h,),
                                      Card(
                                        margin: const EdgeInsets.all(8.0),
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    _buildIconWithText(
                                                      svgPath: 'lib/Images/Deal Icon.svg',
                                                      label: 'Deal',
                                                      value: '${ele.discountNoPrime}${ele.discountUoM}',
                                                      iconSize: 30.0,
                                                      innerColor: Colors.redAccent,
                                                      outerColor: const Color(0xFF0D0140),
                                                    ),
                                                    _buildIconWithText(
                                                      svgPath: 'lib/Images/Validity Icon.svg',
                                                      label: 'Validity',
                                                      value: DateFormat.MMMMd().format(ele.selectedEndDate),
                                                      iconSize: 30.0,
                                                      innerColor: Colors.redAccent,
                                                      outerColor: const Color(0xFF0D0140),
                                                    ),
                                                    _buildIconWithText(
                                                      svgPath: 'lib/Images/Claimed icon.svg',
                                                      label: 'Claimed',
                                                      value: ele.offerClaimedCount.toString(),
                                                      iconSize: 30.0,
                                                      innerColor: Colors.redAccent,
                                                      outerColor: const Color(0xFF0D0140),
                                                    ),
                                                    _buildIconWithText(
                                                      svgPath: 'lib/Images/Saves icon.svg',
                                                      label: 'Likes',
                                                      value: ele.likesCount.toString(),
                                                      iconSize: 30.0,
                                                      innerColor: Colors.redAccent,
                                                      outerColor: const Color(0xFF0D0140),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                      ]),
                                  Card(
                                    color: Colors.white,
                                    child: ExpansionTile(
                                      title: const Text('Terms & Conditions',style: TextStyle(fontFamily: 'Aileron',),),
                                      children: <Widget>[
                                        Text('Warranty: ${ele.warranty}'),
                                        Text('Delivery: ${ele.delivery}'),
                                        Text('Refund: ${ele.refund}'),
                                        Text('Other: ${ele.other}'),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 2.h,),
                                  Center(
                                    child: SizedBox(
                                      width: 80.w,
                                      height: 6.h,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.of(navigatorKey.currentContext!).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => OfferEnCashScreen(
                                              ele: ele,
                                              shouldEnCash: false,
                                              isActive: false,
                                            ),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              const begin = Offset(0.0, 1.0);
                                              const end = Offset.zero;
                                              const curve = Curves.fastOutSlowIn;

                                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                              return SlideTransition(
                                                position: animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'REDEEM NOW ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.h,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      'Similar Offers',
                                      textScaleFactor: 1.5,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.h,),
                                  StreamBuilder<List<OffersColl>>(
                                    stream: isar.offersColls
                                        .filter()
                                        .offerStatusEqualTo(OfferStatus.live)
                                        .offerNameIsNotEmpty()
                                        .productTypeEqualTo(ele.productType)
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
                                        child:!snapshot.hasData || controller.trendingNowIsLoading
                                            ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                            : offers!.isEmpty
                                            ? const Center(
                                          child: Card(
                                            color: Colors.black,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'No offers found',
                                                textScaleFactor: 1.2,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                            : GridView.builder(

                                          itemCount: offers.length,
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.all(16.0),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.75,
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
                                                      Expanded(
                                                        flex: 3,
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: const BorderRadius.vertical(
                                                                top: Radius.circular(12),
                                                              ),
                                                              child: Container(
                                                                width: double.infinity,
                                                                height: double.infinity,
                                                                color: Colors.grey[100],
                                                                child: offer.offerImages.isNotEmpty
                                                                    ? CachedNetworkImage(
                                                                  imageUrl: offer.offerImages.first,
                                                                  fit: BoxFit.cover,
                                                                  placeholder: (context, url) => Center(
                                                                    child: CircularProgressIndicator(
                                                                      color: Theme.of(context).primaryColor,
                                                                    ),
                                                                  ),
                                                                  errorWidget: (context, url, error) => const Center(
                                                                    child: Icon(Icons.error_outline),
                                                                  ),
                                                                )
                                                                    : const Center(
                                                                  child: Icon(
                                                                    Icons.image_not_supported_outlined,
                                                                    size: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (offer.discountNo != null && offer.discountNo!= null)
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
                                                                    borderRadius: BorderRadius.circular(16),
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
                                                            Positioned(
                                                              top: 8,
                                                              right: 8,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  shape: BoxShape.circle,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.1),
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
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                  margin: const EdgeInsets.only(top: 4),
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 8,
                                                                    vertical: 4,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.amber[100],
                                                                    borderRadius: BorderRadius.circular(12),
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
                                                Positioned.fill(
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(12.0),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ))  ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 10.h,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isPrimeMember)
                      const Positioned(
                        top: 10,
                        right: 50,
                        left: 50,
                        child: PrimeOfferBalloon(),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOfferImageCarousel(OfferDetailsController controller, OffersColl ele) {
    return Column(
      children: [
        Container(
          height: 50.h,
          margin: const EdgeInsets.only(top: 8, left: 8),
          width: double.infinity,
          child: ele.offerImages.isEmpty
              ? Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No images available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
              : PageView.builder(
            itemCount: ele.offerImages.length,
            onPageChanged: (index) {
              controller.currentImageIndex.value = index;
            },
            itemBuilder: (context, index) {
              var imageUrl = ele.offerImages[index];
              return _buildImageItem(imageUrl);
            },
          ),
        ),
        const SizedBox(height: 10),
        if (ele.offerImages.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              ele.offerImages.length,
                  (index) => Obx(
                    () => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.currentImageIndex.value == index
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return SizedBox(
      width: 80.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 10),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                Text(
                  'URL: $imageUrl',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


Widget buildButton({required String label,
  required VoidCallback onPressed}) {
  return Container(
    width: 23.w,
    height: 4.h,
    margin: const EdgeInsets.only(left: 10),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(5),
    ),
    alignment: Alignment.center,
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'Aileron',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
      ),
    ),
  );
}

Widget buildItem({
  required String discount,
  required bool isFavorite,
  required String id,
  required String offerImage,
  required BuildContext context,
}) {
  const EdgeInsets imagePadding = EdgeInsets.all(10.0);
  const EdgeInsets discountPadding = EdgeInsets.only(left: 8.0, bottom: 8.0);

  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OfferDetailsScreen(offerID: id),
        ),
      );
    },
    child: Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFB0B0B0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: imagePadding,
              child: myWidgets.getCachedNetworkImage(imgUrl: offerImage),
            ),
          ),
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
            bottom: 10,
            child: Padding(
              padding: discountPadding,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                      fontSize: 12,
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


class PrimeOfferBalloon extends StatefulWidget {
  const PrimeOfferBalloon({super.key});

  @override
  _PrimeOfferBalloonState createState() => _PrimeOfferBalloonState();
}

class _PrimeOfferBalloonState extends State<PrimeOfferBalloon> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          children: [
            Icon(Icons.celebration, color: Colors.white),
            Text(
              'Congratulations!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'WELCOME TO PRIME CLUB',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildIconWithText({
  required String svgPath,
  required String label,
  required String value,
  required double iconSize,
  required Color innerColor,
  required Color outerColor,
}) {
  return Column(
    children: [
      Stack(
        children: [
          SvgPicture.asset(
            svgPath,
            width: iconSize,
            height: iconSize,
            color: outerColor,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                svgPath,
                width: iconSize,
                height: iconSize,
                color: innerColor,
              ),
            ),
          ),
        ],
      ),
      Text(
        label,
        style: const TextStyle(color: Colors.grey),
      ),
      Text(
        value,
        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
