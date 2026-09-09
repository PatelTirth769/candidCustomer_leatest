
import 'package:candid_customer/Controllers/OffersController/OfferEnCashController.dart';
import 'package:candid_customer/Screens/HomeScreen.dart';
import 'package:candid_customer/Screens/ProfileScreens/ProfileUpdateScreen.dart';
import 'package:candid_customer/Utils/MyWidgets.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/Collections/Offers/OffersColl.dart';


class OfferEnCashScreen extends StatefulWidget {
  final OffersColl ele;
  final bool shouldEnCash, isActive;
  final String? orderID;

  const OfferEnCashScreen({Key? key,
    required this.ele,
    required this.shouldEnCash,
    this.orderID,
    required this.isActive})
      : super(key: key);

  @override
  State<OfferEnCashScreen> createState() => _OfferEnCashScreenState();
}

class _OfferEnCashScreenState extends State<OfferEnCashScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: OfferEnCashController(
          ele: widget.ele,
          shouldEnCash: widget.shouldEnCash,
          orderID: widget.orderID,
          isActive: widget.isActive),
      builder: (controller) {
        return Scaffold(
          // appBar: MyWidgets().myAppBar(),
          drawer: drawer,
          body: Center(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: controller.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // MyWidgets().getOfferHeadingContainer(ele: ele),
                            MyWidgets().offerDetailsAppBar(
                                ele: widget.ele, isActive: controller.isActive),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: 30.h,
                                    minWidth: 80.w,
                                    maxHeight: 30.0.h,
                                    maxWidth: 80.w,
                                  ),
                                  child: Center(
                                    child: Container(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(seconds: 1),
                                    child: !controller.isActive
                                        ? Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'ACTIVATE TO\nUNLOCK QR',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp),
                                      ),
                                    )
                                        : Padding(
                                      padding:
                                      EdgeInsets.only(top: 10.0.h),
                                      child: QrImageView(
                                        data: controller.jsonStrForQR,
                                        version: QrVersions.auto,
                                        size: 200.0,
                                        backgroundColor: Colors.white,
                                        gapless: false,
                                        semanticsLabel: 'Offer QR',
                                        errorStateBuilder: (cxt, err) {
                                          return const Center(
                                            child: Text(
                                              "Uh oh! Something went wrong...",
                                              textAlign:
                                              TextAlign.center,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(seconds: 1),
                              child: !controller.isActive
                                  ? Padding(
                                padding: EdgeInsets.only(
                                    left: 10.w, top: 16),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Requirements',
                                      style: TextStyle(
                                        color: const Color(0xFFC4C4C4),
                                        fontSize: 10.sp,
                                        fontFamily: 'Aileron',
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                        letterSpacing: 0.02,
                                      ),
                                    ),
                                    SizedBox(height: 1.h,),
                                    Row(
                                      children: [
                                        Container(
                                          width: 24.0, // Adjust width as needed
                                          height: 24.0, // Adjust height as needed
                                          decoration: const BoxDecoration(
                                            color: Colors.green, // Green background color
                                            shape: BoxShape.circle, // Make the container circular
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.done_outlined,
                                              color: Colors.white, // White tick icon
                                              size: 16.0, // Adjust size as needed
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 1.w,),
                                        Text(
                                          'Verified User',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontFamily: 'Aileron',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 1.h,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start of the column
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 24.0, // Adjust width as needed
                                              height: 24.0, // Adjust height as needed
                                              decoration: const BoxDecoration(
                                                color: Colors.green, // Green background color
                                                shape: BoxShape.circle, // Make the container circular
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.done_outlined,
                                                  color: Colors.white, // White tick icon
                                                  size: 16.0, // Adjust size as needed
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 1.w,),
                                            Text(
                                              'Phone Number Verified',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.sp,
                                                fontFamily: 'Aileron',
                                                fontWeight: FontWeight.w400,
                                                height: 0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2.h,), // Space between the text and the card
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const ProfileUpdateScreen()),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(color: Colors.grey, width: 2.0), // Lighter border
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min, // Ensure the card is only as wide as needed
                                              children: [
                                                const Icon(Icons.edit, color: Colors.black),
                                                const SizedBox(width: 4.0,),
                                                Text(
                                                  'Want to Update Shipping Address',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h,),
                                    // Row(
                                    //   children: [
                                    //     Container(
                                    //       width: 24.0, // Adjust width as needed
                                    //       height: 24.0, // Adjust height as needed
                                    //       decoration: const BoxDecoration(
                                    //         color: Colors.green, // Green background color
                                    //         shape: BoxShape.circle, // Make the container circular
                                    //       ),
                                    //       child: const Center(
                                    //         child: Icon(
                                    //           Icons.done_outlined,
                                    //           color: Colors.white, // White tick icon
                                    //           size: 16.0, // Adjust size as needed
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     SizedBox(width: 1.w,),
                                    //     Text(
                                    //       'GET 200 Credits on this purchase.',
                                    //       style: TextStyle(
                                    //         color: Colors.black,
                                    //         fontSize: 14.sp,
                                    //         fontFamily: 'Aileron',
                                    //         fontWeight: FontWeight.w400,
                                    //         height: 0,
                                    //       ),
                                    //     )
                                    //   ],
                                    // )
                                  ],
                                ),
                              )
                                  : const SizedBox(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 3.h),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(seconds: 1),
                                  child: !controller.isActive
                                      ? SizedBox(
                                    width: 85.w,
                                    child: MyWidgets().getLargeButton(
                                        bgColor: const Color(0xFFFF0000),
                                        title: 'ACTIVATE NOW',
                                        onPress: controller.redeemActivateOffer),
                                  )
                                      : Column(
                                    mainAxisSize: MainAxisSize.min, // Ensure the Column sizes itself based on its children
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.h),
                                        child: Container(
                                          width: 80.w,
                                          height: 5.h,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFE4E4E4),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6)),
                                            shadows: const [
                                              BoxShadow(
                                                color: Color(0x2D99AAC5),
                                                blurRadius: 62,
                                                offset: Offset(0, 4),
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'ACTIVATED ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.w700,
                                                    height: 0,
                                                    letterSpacing: 0.84,
                                                  ),
                                                ),
                                                Container(
                                                  width: 24.0, // Adjust width as needed
                                                  height: 24.0, // Adjust height as needed
                                                  decoration: const BoxDecoration(
                                                    color: Colors.green, // Green background color
                                                    shape: BoxShape.circle, // Make the container circular
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.done_outlined,
                                                      color: Colors.white, // White tick icon
                                                      size: 16.0, // Adjust size as needed
                                                    ),
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0), // Add spacing between the two cards
                                      Card(
                                        elevation: 4.0, // Add elevation to give a shadow effect
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0), // Padding inside the card
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Congratulations! Your offer has been successfully redeemed.\n\n',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'Offer ID: ',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: widget.ele.offerID,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent, // Highlight color for the offer ID
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      Clipboard.setData(ClipboardData(text: widget.ele.offerID)).then((_) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Offer ID copied to clipboard!')),
                                                        );
                                                      });
                                                    },
                                                ),
                                                WidgetSpan(
                                                  child: SizedBox(width: 3.w), // Adjust the width value as needed
                                                ),
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Clipboard.setData(ClipboardData(text: widget.ele.offerID)).then((_) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Offer ID copied to clipboard!')),
                                                        );
                                                      }
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.copy,
                                                      size: 16.sp, // Adjust the size of the icon
                                                      color: Colors.redAccent, // Match the color of the text
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '\nYou can connect with the seller through call, WhatsApp, or visit the outlet as per convenience.\nHappy Shopping!',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontFamily: 'Aileron',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // AnimatedSwitcher(
                            //   duration: const Duration(seconds: 1),
                            //   child: !controller.isActive
                            //       ? Column(
                            //     children: [
                            //       Padding(
                            //         padding: EdgeInsets.only(top: 8.h),
                            //         child: Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.center,
                            //           children: [
                            //             const Icon(
                            //                 Icons.watch_later_outlined),
                            //             Text(
                            //               'Redeem in ${controller.redeemDuration}',
                            //               style: TextStyle(
                            //                 color: Colors.black,
                            //                 fontSize: 14.sp,
                            //                 fontFamily: 'Aileron',
                            //                 fontWeight: FontWeight.w400,
                            //                 height: 0,
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       ),
                            //       Center(
                            //         child: SizedBox(
                            //             width: 80.w,
                            //             child: const Divider(
                            //                 color: Color(0xFF31B426),
                            //                 thickness: 10)),
                            //       ),
                            //     ],
                            //   )
                            //       : const SizedBox(),
                            // ),
                            SizedBox(height: 2.h,),
                            AnimatedSwitcher(
                              duration: const Duration(seconds: 1),
                              child: controller.isActive
                                  ? Center(
                                  child: SizedBox(
                                    height: 55.h,
                                    width: 85.w,
                                    child: Card(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.store, // You can use any other icon from the Icons class or a custom SVG
                                                    size: 24.0,  // Adjust the size of the icon as needed
                                                    color: Colors.black, // Adjust the color as needed
                                                  ),
                                                  SizedBox(width: 8.0), // Space between the icon and the text
                                                  Text(
                                                    'Seller Store Information ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16.0, // Adjust the font size as needed
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(widget.ele.offerAddress),
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(widget.ele.userBusinessName),
                                                  const Divider(),
                                                  Text(widget.ele.userOutletAddressBuildingStreetArea),
                                                  const Divider(),
                                                  Text(widget.ele.userOutletAddress1),
                                                  const Divider(),
                                                  Text(widget.ele.userOutletAddress2),
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(widget.ele.userPinCode),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  // WhatsApp button for userMobile1
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        FocusManager.instance.primaryFocus?.unfocus();

                                                        // Create a well-formatted message for seller notification
                                                        String offerDetails = """
👋 *Hi, I've Redeemed Your Offer!*

I would like to use the following offer:

🏷️ *${widget.ele.offerName}*
📝 ${widget.ele.offerDescription}

📋 *My Redemption Details:*
▫️ Offer Code: ${widget.ele.offerID}
▫️ Valid Till: ${widget.ele.selectedEndDate}

I'm looking forward to using this offer. Please confirm the redemption.

Thank you! 😊""";

                                                        // Encode the message to be URL-safe
                                                        var whatsappUrl = "whatsapp://send?phone=${widget.ele.userMobile1}"
                                                            "&text=${Uri.encodeComponent(offerDetails)}";

                                                        try {
                                                          // Launch WhatsApp with the constructed message
                                                          launch(whatsappUrl);
                                                        } catch (e) {
                                                          debugPrint("Unable to open WhatsApp: $e");
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Unable to open WhatsApp'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: const Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.chat_bubble_outlined,
                                                            color: Colors.black,  // WhatsApp green color
                                                            size: 24,
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'WhatsApp',
                                                            style: TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  // Visit Outlet button (Google Maps)
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () async {
                                                        String googleUrl =
                                                            'https://www.google.com/maps/search/?api=1&query=${widget.ele.latitude},${widget.ele.longitude}';
                                                        if (await canLaunch(googleUrl)) {
                                                          await launch(
                                                            googleUrl,
                                                            forceSafariVC: false,
                                                            forceWebView: false,
                                                          );
                                                        } else {
                                                          throw 'Could not open the map.';
                                                        }
                                                      },
                                                      child: const Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.location_on_outlined,
                                                            color: Colors.black,
                                                          ),
                                                          Text(
                                                            'Visit Outlet',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  // Call button for making a phone call to userMobile1
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                        var phoneUrl = "tel:${widget.ele.userMobile1}";
                                                        try {
                                                          launch(phoneUrl);
                                                        } catch (e) {
                                                          debugPrint("Unable to make a call: $e");
                                                        }
                                                      },
                                                      child: const Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.call,
                                                            color: Colors.black,
                                                          ),
                                                          Text(
                                                            'Call',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 25.h,
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Card(
                                                    elevation: 4.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Rate this offer',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 16.sp,
                                                              fontFamily: 'Aileron',
                                                              fontWeight: FontWeight.w700,
                                                              height: 0,
                                                              letterSpacing: 0.02,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8.0),
                                                          if (!widget.ele.hasRated)
                                                            Column(
                                                              children: [
                                                                RatingBar.builder(
                                                                  initialRating: widget.ele.rating,
                                                                  minRating: 1,
                                                                  direction: Axis.horizontal,
                                                                  allowHalfRating: false,
                                                                  itemCount: 5,
                                                                  itemSize: 30.0,
                                                                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                                  itemBuilder: (context, _) => const Icon(
                                                                    Icons.star,
                                                                    color: Color(0xFFFF0000),
                                                                  ),
                                                                  onRatingUpdate: (rating) {
                                                                    controller.ele.rating = rating;
                                                                  },
                                                                ),
                                                                SizedBox(height: 2.h),
                                                                SizedBox(
                                                                  width: 30.w,
                                                                  height: 6.h,
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.black,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                      ),
                                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                                    ),
                                                                    onPressed: () {
                                                                      controller.submitRating(widget.ele, widget.ele.rating);
                                                                      // Update local state to reflect that the user has rated
                                                                      setState(() {
                                                                        widget.ele.hasRated = true;
                                                                      });
                                                                    },
                                                                    child: const Text('Submit Rating', style: TextStyle(color: Colors.white)),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          else
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                                              child: Text(
                                                                widget.ele.hasRated ? 'Thank you for your feedback!' : 'You have already rated this offer.',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: widget.ele.hasRated ? Colors.green : Colors.orange,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
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
                                  )
                              )    : const SizedBox(),
                            ),

                            SizedBox(height: 2.h,),

                            Padding(
                              padding: EdgeInsets.only(top: 1.0.h),
                              child: Center(
                                child: SizedBox(
                                  width: 30.w,
                                  child: MyWidgets().getLargeButton(
                                    title: 'MORE DEALS',
                                    onPress: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => const HomeScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h,),
                            // Container(
                            //   margin: const EdgeInsets.all(8),
                            //   padding: const EdgeInsets.all(8),
                            //   decoration: BoxDecoration(
                            //       color: Colors.blue.shade100,
                            //       border: Border.all(color: Colors.blue),
                            //       borderRadius: BorderRadius.circular(10)),
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(ele.offerName,
                            //           textScaleFactor: 1.3,
                            //           style: TextStyle(
                            //               color: Colors.blue.shade900,
                            //               fontWeight: FontWeight.bold)),
                            //       Card(
                            //         child: Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceAround,
                            //           children: [
                            //             const Padding(
                            //               padding: EdgeInsets.all(8.0),
                            //               child: Text('PRIME',
                            //                   style: TextStyle(
                            //                       fontWeight:
                            //                           FontWeight.bold)),
                            //             ),
                            //             Container(
                            //               decoration: BoxDecoration(
                            //                   color: Colors.purple,
                            //                   borderRadius:
                            //                       BorderRadius.circular(10)),
                            //               child: Padding(
                            //                 padding:
                            //                     const EdgeInsets.all(8.0),
                            //                 child: Text(
                            //                     'Extra ${int.parse(ele.discountNoPrime) - int.parse(ele.discountNo)}${ele.discountUoM}',
                            //                     style: const TextStyle(
                            //                         color: Colors.white)),
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only(top: 5.h),
                            //   child: Text(
                            //       'CONGRATULATION!\nYour offer is Ready',
                            //       textScaleFactor: 2,
                            //       style: TextStyle(
                            //           color: Colors.blue.shade900,
                            //           fontWeight: FontWeight.bold)),
                            // ),
                            // QrImageView(
                            //   data: controller.jsonStrForQR,
                            //   version: QrVersions.auto,
                            //   size: 200.0,
                            //   backgroundColor: Colors.white,
                            //   gapless: false,
                            //   semanticsLabel: 'Offer QR',
                            //   errorStateBuilder: (cxt, err) {
                            //     return const Center(
                            //       child: Text(
                            //         "Uh oh! Something went wrong...",
                            //         textAlign: TextAlign.center,
                            //       ),
                            //     );
                            //   },
                            // ),
                            // SizedBox(
                            //   width: 80.w,
                            //   child: const Text(
                            //     'Show this QR code at the outlet to availed the offer',
                            //     textScaleFactor: 1.3,
                            //     style: TextStyle(color: Colors.grey),
                            //   ),
                            // ),
                            // MyWidgets().getLargeButton(
                            //     onPress: () async {
                            //       if (!await Permission.storage
                            //           .request()
                            //           .isGranted) {
                            //         Utils().showSnackBar(
                            //             'Storage Permission is not granted!');
                            //         return;
                            //       }
                            //
                            //       final qrValidationResult =
                            //           QrValidator.validate(
                            //         data: controller.jsonStrForQR,
                            //         version: QrVersions.auto,
                            //         errorCorrectionLevel:
                            //             QrErrorCorrectLevel.L,
                            //       );
                            //       controller.setIsLoading(true);
                            //       if (qrValidationResult.status ==
                            //               QrValidationStatus.valid &&
                            //           qrValidationResult.qrCode != null) {
                            //         final qrCode = qrValidationResult.qrCode!;
                            //         final painter = QrPainter.withQr(
                            //             eyeStyle: const QrEyeStyle(
                            //                 color: Colors.black,
                            //                 eyeShape: QrEyeShape.square),
                            //             qr: qrCode);
                            //         Directory tempDir =
                            //             await getTemporaryDirectory();
                            //         tempDir.deleteSync(recursive: true);
                            //         tempDir.create();
                            //         String tempPath = tempDir.path;
                            //         final ts = DateTime.now()
                            //             .millisecondsSinceEpoch
                            //             .toString();
                            //         String path = '$tempPath/$ts.png';
                            //         final picData = await painter.toImageData(
                            //             2048,
                            //             format: ImageByteFormat.png);
                            //         await Utils().writeToFile(picData!, path);
                            //         controller.setIsLoading(false);
                            //         Utils().showSnackBar('QR code is saved!');
                            //         debugPrint('QR code is saved!');
                            //         debugPrint('QR path: $path');
                            //       } else {
                            //         controller.setIsLoading(false);
                            //         Utils().showSnackBar(
                            //             'Not valid or null QR code!');
                            //       }
                            //     },
                            //     title: 'Save QR'),
                          ],
                        ),
                      )),
                  // Container(
                  //   height: 11.h,
                  //   color: Colors.blue.shade900,
                  //   padding: const EdgeInsets.only(left: 8),
                  //   child: Column(
                  //     children: [
                  //       Padding(
                  //         padding:
                  //             const EdgeInsets.only(left: 8.0, top: 8),
                  //         child: Row(
                  //           children: [
                  //             ClipRRect(
                  //                 borderRadius: BorderRadius.circular(15),
                  //                 child: SizedBox(
                  //                     height: 5.h,
                  //                     child: CachedNetworkImage(
                  //                         imageUrl:
                  //                             ele.offerImages.first))),
                  //             const SizedBox(
                  //               width: 10,
                  //             ),
                  //             const Text(
                  //               'CANDID OFFERS',
                  //               textScaleFactor: 1.3,
                  //               style: TextStyle(color: Colors.white),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       const Text(
                  //         'Where Offers Never End',
                  //         textScaleFactor: 1.3,
                  //         style: TextStyle(color: Colors.white),
                  //       )
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool enabled = true,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  required String? Function(String?) validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF0D0140),fontWeight: FontWeight.bold
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2), // Offset of the shadow
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 10.0,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ),
    ],
  );
}
