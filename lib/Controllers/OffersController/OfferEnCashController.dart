import 'dart:async';
import 'dart:convert';
import 'package:candid_customer/Services/API/OffersServices/OffersConnect.dart';
import 'package:candid_customer/Services/Collections/Offers/AvailedOffers/AvailedOffersColl.dart';
import 'package:candid_customer/Utils/Utils.dart';
import 'package:candid_customer/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../../Services/Collections/Offers/OffersColl.dart';

class OfferEnCashController extends GetxController {
  final OffersColl ele;
  final bool shouldEnCash;
  final  addressController = TextEditingController();
  final String? orderID;
  bool isLoading = true,
       isActive;
  double? selectedRating;
  // create QR from these fields -> order ID, customer name, scan date
  String jsonStrForQR = '',
       redeemDuration = '';

  Timer? timer;

  OfferEnCashController({
    required this.ele,
    required this.shouldEnCash,
    this.orderID,
    required this.isActive,
  });

  redeemActivateOffer() async {
    isLoading = true;
    update();
    Map<String, dynamic> offerAvailDetails = {
     'userPhone': localUser?.userMobileNumber.replaceAll(" ", "") ?? "", // Null check added here
      'offerID': ele.offerID,
      'isOfferRedeemed': false,
      'orderID': orderID,
      'isUserPrimeMember': localUser?.isUserPrimeMember, // Null check added here
      'StoreAddress': ele.offerAddress,
      'productName': ele.productName,
      'offerName': ele.offerName,
    };
    try {
      await OffersConnect().availOffer(
        offerAvailDetails: offerAvailDetails,
        offerEnCashController: this,
      );
      isActive = true;
      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      debugPrint('availOffer | EnCash Controller | CATCH : $e');
    }
  }

  Future<void> submitRating(OffersColl offer, double rating) async {
    if (offer.hasRated) {
      debugPrint("User has already rated this offer.");
      Fluttertoast.showToast(
        msg: "You have already rated this offer.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
      );
      return;
    }

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

        final currentRatingCount = offerDoc.data()?['ratingCount'] ?? 0;
        final currentCumulativeRating = offerDoc.data()?['cumulativeRating'] ?? 0.0;
        final userRatings = Map<String, double>.from(offerDoc.data()?['userRatings'] ?? {});

        if (userRatings.containsKey(currentUserId)) {
          throw Exception("User has already rated this offer");
        }

        final newRatingCount = currentRatingCount + 1;
        final newCumulativeRating = currentCumulativeRating + rating;
        final newAverageRating = newCumulativeRating / newRatingCount;
        userRatings[currentUserId] = rating;

        transaction.update(offerDocRef, {
          'ratingCount': newRatingCount,
          'cumulativeRating': newCumulativeRating,
          'averageRating': newAverageRating,
          'userRatings': userRatings,
        });

        // Update the local Isar database
        await isar.writeTxn(() async {
          offer.ratingCount = newRatingCount;
          offer.cumulativeRatingSum = newCumulativeRating;
          offer.rating = rating;
          offer.averageRating = newAverageRating;
          offer.hasRated = true;
          await isar.offersColls.put(offer);
        });
      });

      // Fetch the updated offer from Isar to ensure we have the latest data
      final updatedOffer = await isar.offersColls.get(offer.id);
      if (updatedOffer != null) {
        offer = updatedOffer;
      }

      // Verify that the Isar database has been updated correctly
      final verifiedOffer = await isar.offersColls.get(offer.id);
      if (verifiedOffer != null) {
        debugPrint("Isar update verification: hasRated = ${verifiedOffer.hasRated}, rating = ${verifiedOffer.rating}, averageRating = ${verifiedOffer.averageRating}, ratingCount = ${verifiedOffer.ratingCount}");
      } else {
        debugPrint("Failed to verify Isar update: Offer not found in Isar database");
      }

      update();
    } catch (e) {
      debugPrint('submitRating | catch | $e');
      if (e.toString().contains("User has already rated this offer")) {
        Fluttertoast.showToast(
          msg: "You have already rated this offer.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
        );
      }
    } finally {
      update();
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    if (shouldEnCash) {
      await redeemActivateOffer();
    } else {
      Map<String, dynamic> offerAvailDetails = {
        'userPhone': localUser!.userMobileNumber.replaceAll(" ", ""),
        'offerID': ele.offerID,
        'isOfferRedeemed': false,
        'orderID': orderID,
        'StoreAddress':ele.offerAddress,
        'productName':ele.productName,
        'offerName':ele.offerName,
      };
      changeJsonStringForQR(jsonEncode(offerAvailDetails));
      isLoading = false;
      update();
    }

    if (!isActive) {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (isActive) {
          timer?.cancel();
          return;
        }
        Duration differTime = ele.selectedEndDate.difference(DateTime.now());
        redeemDuration =
            "${differTime.inHours} : ${differTime.inMinutes} : ${differTime.inSeconds}";
        update();
      });
    } else {
      isar.availedOffersColls
          .filter()
          .offerIDEqualTo(ele.offerID)
          .build()
          .findFirst()
          .then((AvailedOffersColl? availedOffersColl) {
        if (availedOffersColl != null) {
          utils.analyticsLogSelectContent(
              contentType: Utils.offerAvailedContentType,
              itemId: availedOffersColl.availedOfferID);
        }
      });
    }
  }

  changeJsonStringForQR(String jsonString) {
    jsonStrForQR = jsonString;
    update();
  }

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  @override
  void dispose() {
    if (isActive) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  void onClose() {
    if (isActive) {
      timer?.cancel();
    }
    super.onClose();
  }
}
