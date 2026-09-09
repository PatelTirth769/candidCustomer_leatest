import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:candid_customer/Utils/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Services/API/OffersServices/OffersConnect.dart';
import '../../main.dart';

class OfferDetailsController extends GetxController {
  final String offerID;
  OfferDetailsController({required this.offerID});

  List<String> offerImages = [
    'lib/Images/offer.jpg',
    'lib/Images/offer.jpg',
    'lib/Images/offer.jpg'
  ];
  bool isLoading = false, trendingNowIsLoading = false;
  String selectedCity = '';
  var currentImageIndex = 0.obs;

Future<void> shareOfferOnSocialMedia({required OffersColl offer}) async {
  // Create dynamic link parameters
  DynamicLinkParameters dynamicLinkParams = DynamicLinkParameters(
    link: Uri.parse(
        "https://candidcustomer.page.link/?offerID=${offer.offerID}"),
    uriPrefix: "https://candidcustomer.page.link",
    androidParameters: const AndroidParameters(
      packageName: "com.customer.candid.candid_customer",
      minimumVersion: 1,
    ),
    iosParameters: const IOSParameters(
      bundleId: "com.candid.customer",
      minimumVersion: "1",
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: offer.offerName,
      description: offer.offerDescription,
      imageUrl: Uri.parse(offer.offerImages.isNotEmpty ? offer.offerImages[0] : 'https://example.com/default-image.png'),
    ),
  );

  // Generate short dynamic link
  final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
    dynamicLinkParams,
    shortLinkType: ShortDynamicLinkType.unguessable,
  );

  // Share the dynamic link and wait for the result
  final result = await Share.share(
    'Checkout this offer ${dynamicLink.shortUrl}',
    subject: offer.offerName,
  ).then((ShareResult result) {
    // Check if share was successful
    if (result.status == ShareResultStatus.success) {
      return true;
    }
    return false;
  }).catchError((error) {
    print("Error sharing: $error");
    return false;
  });

  // Only increment count if sharing was successful
  if (result) {
    try {
      final firestore = FirebaseFirestore.instance;
      final offerDocRef = firestore.collection('candidOffers').doc(offer.offerID);
      
      await firestore.runTransaction((transaction) async {
        final offerDoc = await transaction.get(offerDocRef);
        
        if (!offerDoc.exists) {
          throw Exception("Offer not found");
        }
        
        final currentSharedCount = offerDoc.data()?['sharesCount'] ?? 0;
        transaction.update(offerDocRef, {'sharesCount': currentSharedCount + 1});
        
        await isar.writeTxn(() async {
          if (!offer.isInRatingsList) {
            offer.isInRatingsList = true;
            offer.sharesCount++;
            isar.offersColls.put(offer);
          }
        });
      });
      
      // Log event to analytics
      utils.analyticsLogEvent(
        eventName: Utils.offerShareContentType,
        // parameters: {
        //   "offerID": offer.offerID,
        // },
      );
    } catch (e) {
      print("Failed to update share count: $e");
    }
  }
}

  Future<void> addOrRemoveOfferFromWishListClickHandler({required OffersColl offer}) async {
    try {
      isLoading = true;
      update(); // Update UI to show loading state

      // Toggle wishlist status via API call
      await OffersConnect().addOrRemoveOfferFromWishList(offerID: offer.offerID);

      // Update local Isar database and offer state
      await isar.writeTxn(() async {
        offer.isInWishList = !offer.isInWishList;
        if (offer.isInWishList) {
          offer.offerSavedCount++;
        } else {
          offer.offerSavedCount--;
        }
        isar.offersColls.put(offer);
      }
      );
      isLoading = false;
      update(); // Update UI to reflect new state
    } catch (e) {
      isLoading = false;
      update(); // Update UI in case of errors
      debugPrint('addOrRemoveOfferFromWishListClickHandler | catch | $e');
      // Handle error gracefully
    }
  }

  Future<void> toggleLike({required OffersColl offer}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final offerDocRef = firestore.collection('candidOffers').doc(offer.offerID);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception("User not logged in");
      }
      await firestore.runTransaction((transaction) async {
        final offerDoc = await transaction.get(offerDocRef);

        if (!offerDoc.exists) {
          throw Exception("Offer not found");
        }

        final currentLikesCount = offerDoc.data()?['likesCount'] ?? 0;
        final likedBy = Set<String>.from(offerDoc.data()?['likedBy'] ?? []);

        if (likedBy.contains(currentUserId)) {
          // User is disliking
          likedBy.remove(currentUserId);
          offer.likedByCurrentUser = false;
          offer.likesCount = currentLikesCount - 1;
        } else {
          // User is liking
          likedBy.add(currentUserId);
          offer.likedByCurrentUser = true;
          offer.likesCount = currentLikesCount + 1;
        }
        transaction.update(offerDocRef, {
          'likesCount': offer.likesCount,
          'likedBy': likedBy.toList(),
        });
        await isar.writeTxn(() async {
          await isar.offersColls.put(offer);
        });
      });
      update();
    } catch (e) {
      update();
      debugPrint("Failed to update Like: $e");
    }
  }


  // Future<void> submitRating(OffersColl offer, double rating) async {
  //   if (offer.hasRated) {
  //     debugPrint("User has already rated this offer.");
  //     Fluttertoast.showToast(
  //       msg: "You have already rated this offer.",
  //       toastLength: Toast.LENGTH_LONG, // Make it longer to ensure visibility
  //       gravity: ToastGravity.CENTER,
  //       backgroundColor: Colors.black.withOpacity(0.7), // Set background color for better visibility
  //       textColor: Colors.white, // Set text color for better contrast
  //     );
  //     return;
  //   }
  //   try {
  //     final firestore = FirebaseFirestore.instance;
  //     final offerDocRef = firestore.collection('candidOffers').doc(offer.offerID);
  //     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  //     if (currentUserId == null) {
  //       throw Exception("User not logged in");
  //     }
  //
  //     await firestore.runTransaction((transaction) async {
  //       final offerDoc = await transaction.get(offerDocRef);
  //       if (!offerDoc.exists) {
  //         throw Exception("Offer not found");
  //       }
  //
  //       final currentRatingCount = offerDoc.data()?['ratingCount'] ?? 0;
  //       final currentCumulativeRating = offerDoc.data()?['cumulativeRating'] ?? 0.0;
  //       final userRatings = Map<String, double>.from(offerDoc.data()?['userRatings'] ?? {});
  //
  //       if (userRatings.containsKey(currentUserId)) {
  //         throw Exception("User has already rated this offer");
  //       }
  //
  //       final newRatingCount = currentRatingCount + 1;
  //       final newCumulativeRating = currentCumulativeRating + rating;
  //       final newAverageRating = newCumulativeRating / newRatingCount;
  //       userRatings[currentUserId] = rating;
  //
  //       transaction.update(offerDocRef, {
  //         'ratingCount': newRatingCount,
  //         'cumulativeRating': newCumulativeRating,
  //         'averageRating': newAverageRating,
  //         'userRatings': userRatings,
  //       });
  //
  //       // Update the local Isar database
  //       await isar.writeTxn(() async {
  //         offer.ratingCount = newRatingCount;
  //         offer.cumulativeRatingSum = newCumulativeRating;
  //         offer.rating = rating;
  //         offer.averageRating = newAverageRating;
  //         offer.hasRated = true;
  //         await isar.offersColls.put(offer);
  //       });
  //     });
  //
  //     // Fetch the updated offer from Isar to ensure we have the latest data
  //     final updatedOffer = await isar.offersColls.get(offer.id);
  //     if (updatedOffer != null) {
  //       offer = updatedOffer;
  //     }
  //
  //     update();
  //   } catch (e) {
  //     debugPrint('submitRating | catch | $e');
  //     if (e.toString().contains("User has already rated this offer")) {
  //       Fluttertoast.showToast(
  //         msg: "You have already rated this offer.",
  //         toastLength: Toast.LENGTH_LONG, // Make it longer to ensure visibility
  //         gravity: ToastGravity.CENTER,
  //         backgroundColor: Colors.black.withOpacity(0.7), // Set background color for better visibility
  //         textColor: Colors.white, // Set text color for better contrast
  //       );
  //     }
  //   } finally {
  //     update();
  //   }
  // }



  Future<void> fetchWishlistStatus() async {
    try {
      isLoading = true;
      update();

      // Fetch the wishlist data from the backend
      await OffersConnect().getCustomerOfferWishListApi();

      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      debugPrint('fetchWishlistStatus | catch | $e');
      // Handle error gracefully
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchWishlistStatus();
    utils.analyticsLogSelectContent(
        contentType: Utils.offerContentType, itemId: offerID);
  }
}
