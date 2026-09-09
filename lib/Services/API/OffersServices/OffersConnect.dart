// import 'dart:convert';
//
// import 'package:candid_customer/Controllers/OffersController/OfferEnCashController.dart';
// import 'package:candid_customer/Services/Collections/Offers/AvailedOffers/AvailedOffersColl.dart';
// import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
// import 'package:candid_customer/Services/Collections/User/UserColl.dart';
// import 'package:candid_customer/main.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:isar_community/isar.dart';
// import '../../../Controllers/NotificationControllers/NotificationController.dart';
// import '../../../Controllers/SmsApiController/SmsApiController.dart';
// import '../../../Utils/Utils.dart';
//
// class OffersConnect extends GetConnect {
//   DateTime parseDateTime(dynamic date) {
//     if (date is String) {
//       // Ensure the date string has a valid format
//       date = ensureValidDateFormat(date);
//       return DateTime.parse(date);
//     } else if (date is DateTime) {
//       return date;
//     } else {
//       throw ArgumentError('Invalid date format');
//     }
//   }
//
//   String ensureValidDateFormat(String dateStr) {
//     // Split the date part and time part
//     List<String> parts = dateStr.split('T');
//     String datePart = parts[0];
//     String timePart = parts.length > 1 ? 'T' + parts[1] : '';
//
//     // Ensure the day is two digits
//     List<String> dateComponents = datePart.split('-');
//     if (dateComponents.length == 3 && dateComponents[2].length == 1) {
//       dateComponents[2] = dateComponents[2].padLeft(2, '0');
//     }
//
//     return dateComponents.join('-') + timePart;
//   }
//
//   getAllOffersApi(bool offerType) async {
//     Response res = await post(
//       '${Utils.apiUrl}/getOffers',
//       {
//         'userId': (await Utils().getUser() as UserColl).userUid,
//         'offerType': offerType ? 'service' : 'product'
//       },
//       headers: await Utils().getHeaders(),
//     );
//
//     if (res.statusCode != 200) {
//       if (res.statusCode == 401) {
//         Utils().showSnackBar('Session expire! login again!');
//       }
//       try {
//         if (res.body != null &&
//             res.body['message'] != null &&
//             res.body['message']
//                 .toString()
//                 .contains('Offers are here for you!')) {
//           debugPrint('No data found!');
//         } else {
//           throw 'while getAllOffersApi offer list with Exp or error : ${res.body}';
//         }
//       } catch (e) {
//         debugPrint(
//             'Something is wrong while fetching offers list! | ${res.body}');
//       }
//       return;
//     }
//
//     if (res.statusCode == 200) {
//       List<OffersColl> offers = [];
//
//       // Safe parsing functions
//       int parseInteger(dynamic value) {
//         if (value == null) return 0;
//         if (value is int) return value;
//         if (value is double) return value.round();
//         if (value is String) {
//           return int.tryParse(value) ?? 0;
//         }
//         return 0;
//       }
//
//       String parseIntegerToString(dynamic value) {
//         if (value == null) return "0";
//         if (value is int) return value.toString();
//         if (value is String) return value.isEmpty ? "0" : value;
//         return "0";
//       }
//
//       double parseDouble(dynamic value) {
//         if (value == null) return 0.0;
//         if (value is double) return value;
//         if (value is int) return value.toDouble();
//         if (value is String) {
//           return double.tryParse(value) ?? 0.0;
//         }
//         return 0.0;
//       }
//
//       bool parseBoolean(dynamic value) {
//         if (value == null) return false;
//         if (value is bool) return value;
//         if (value is String) {
//           return value.toLowerCase() == 'true';
//         }
//         return false;
//       }
//
//       /// ✅ NEW: Safe image list parser
//       List<String> parseOfferImages(dynamic value) {
//         // Define a default placeholder image
//         const defaultImage = 'https://via.placeholder.com/150';
//
//         // If value is null, return default image
//         if (value == null) return [defaultImage];
//
//         try {
//           // Handle string case
//           if (value is String) {
//             final trimmed = value.trim();
//             final uri = Uri.tryParse(trimmed);
//             if (trimmed.isEmpty || uri == null || !uri.hasAbsolutePath) {
//               return [defaultImage];
//             }
//             return [trimmed];
//           }
//
//           // Handle list case
//           if (value is List) {
//             final images = <String>[];
//             for (var item in value) {
//               if (item != null) {
//                 final str = item.toString().trim();
//                 final uri = Uri.tryParse(str);
//                 if (str.isNotEmpty && uri != null && uri.hasAbsolutePath) {
//                   images.add(str);
//                 }
//               }
//             }
//             return images.isNotEmpty ? images : [defaultImage];
//           }
//
//           // For any other type, try to convert to string
//           final str = value.toString().trim();
//           final uri = Uri.tryParse(str);
//           if (str.isEmpty || uri == null || !uri.hasAbsolutePath) {
//             return [defaultImage];
//           }
//           return [str];
//         } catch (e) {
//           debugPrint('Error parsing offer images: $e');
//           return [defaultImage];
//         }
//       }
//
//       if (res.body['data'] is! List) {
//         debugPrint(
//             'Invalid data format: Expected list of offers, got ${res.body['data']}');
//         return;
//       }
//
//       for (var offer in res.body['data']) {
//         try {
//           var offerData = offer is Map ? offer['offerData'] : null;
//           if (offerData == null || offerData is! Map) {
//             debugPrint('Invalid offer data structure: $offer');
//             continue;
//           }
//
//           DateTime selectedStartDate =
//               parseDateTime(offerData['selectedStartDate'] ?? '');
//           DateTime selectedEndDate =
//               parseDateTime(offerData['selectedEndDate'] ?? '');
//
//           OfferStatus offerStatus = OfferStatus.live;
//           switch (offerData['offerStatus'].toString().toLowerCase()) {
//             case 'live':
//               offerStatus = OfferStatus.live;
//               break;
//             case 'available':
//               offerStatus = OfferStatus.available;
//               break;
//             case 'end':
//               offerStatus = OfferStatus.expired;
//               break;
//             case 'total encash':
//               offerStatus = OfferStatus.totalEncash;
//               break;
//             case 'out of stock':
//               offerStatus = OfferStatus.outOfStock;
//               break;
//           }
//
//           double latitude = parseDouble(offerData['latitude']);
//           double longitude = parseDouble(offerData['longitude']);
//
//           Placemark placeMark =
//               (await placemarkFromCoordinates(latitude, longitude)).first;
//
//           offers.add(
//             OffersColl(
//               distanceFromUserInMeters: Geolocator.distanceBetween(
//                 position?.latitude ?? 0.0,
//                 position?.longitude ?? 0.0,
//                 latitude,
//                 longitude,
//               ),
//               offerID: offer['offerID'],
//               userPinCode: offerData['userPinCode']?.toString() ?? "",
//               discountNo: offerData['discountNo']?.toString() ?? " ",
//               offerType: offerData['offerType']?.toString() ?? "",
//               catId: offerData['catId']?.toString() ?? "",
//               userOutletAddress1:
//                   offerData['userOutletAddress1']?.toString() ?? '',
//               userMobile1: offerData['userMobile1']?.toString() ?? '',
//               userBusinessName: offerData['userBusinessName']?.toString() ?? '',
//               userMobile2: offerData['userMobile2']?.toString() ?? '',
//               userOutletAddress2:
//                   offerData['userOutletAddress2']?.toString() ?? '',
//               userOutletAddressBuildingStreetArea:
//                   offerData['userOutletAddressBuildingStreetArea']
//                           ?.toString() ??
//                       '',
//               latitude: latitude,
//               longitude: longitude,
//               offerStatus: offerStatus,
//               isInWishList: parseBoolean(offerData['isInWishList']),
//               isInRatingsList: parseBoolean(offerData['isInRatingsList']),
//               isInLikesList: parseBoolean(offerData['isInLikesList']),
//               hasRated: parseBoolean(offerData['hasRated']),
//               offerAddress: '${placeMark.subLocality}, ${placeMark.locality}',
//               offerDescription: offerData['offerDescription']?.toString() ?? '',
//               offerDiscountedPrice:
//                   offerData['offerDiscountedPrice']?.toString() ?? "0",
//               regularUnitPrice:
//                   offerData['regularUnitPrice']?.toString() ?? "0",
//               unitPrice2: offerData['unitPrice2']?.toString() ?? "0",
//               offerPrimeDiscountedPrice:
//                   offerData['offerPrimeDiscountedPrice']?.toString() ?? "0",
//               warranty: offerData['warranty']?.toString() ?? '',
//               refund: offerData['refund']?.toString() ?? '',
//               other: offerData['other']?.toString() ?? '',
//               delivery: offerData['delivery']?.toString() ?? '',
//               maxNumClaims: parseIntegerToString(offerData['maxNumClaims']),
//               describeDealDetails:
//                   offerData['describeDealDetails']?.toString() ?? '',
//               stepsToRedeem: offerData['stepsToRedeem']?.toString() ?? '',
//               discountNo2: offerData['discountNo2']?.toString() ?? "",
//               offersPackageId: offerData['offersPackageId']?.toString() ?? "",
//               discountType: offerData['discountType']?.toString() ?? "",
//               productType: offerData['productType']?.toString() ?? "",
//               createTime: DateTime.parse(offer['createTime']),
//               isTrending: parseBoolean(offerData['isTrending']),
//               isBigDays: parseBoolean(offerData['isBigDays']),
//               likedByCurrentUser: parseBoolean(offerData['likedByCurrentUser']),
//               vendorId: offerData['vendorId']?.toString() ?? '',
//               selectedStartDate: selectedStartDate,
//               selectedEndDate: selectedEndDate,
//               offerName: offerData['offerName']?.toString() ?? '',
//               productName: offerData['productName']?.toString() ?? '',
//               discountNoPrime: offerData['discountNoPrime']?.toString() ?? "",
//               discountUoM: offerData['discountUoM']?.toString() ?? '',
//               isInStock: parseBoolean(offerData['isInStock']),
//
//               /// ✅ UPDATED: Safe offerImages parsing here
//               offerImages: parseOfferImages(offerData['offerImages']),
//
//               productDescription:
//                   offerData['productDescription']?.toString() ?? '',
//               selectedCity: offerData['selectedCity']?.toString() ?? '',
//               selectedState: offerData['selectedState']?.toString() ?? '',
//               rating: parseDouble(offerData['rating']),
//               ratingCount: parseInteger(offerData['ratingCount']),
//               sharesCount: parseInteger(offerData['sharesCount']),
//               likesCount: parseInteger(offerData['likesCount']),
//               cumulativeRatingSum:
//                   parseDouble(offerData['cumulativeRatingSum']),
//               offerClaimedCount: parseInteger(offerData['offerClaimedCount']),
//               offerSavedCount: parseInteger(offerData['offerSavedCount']),
//             ),
//           );
//         } catch (e) {
//           debugPrint('Error processing offer: $e');
//           continue; // Skip this offer and continue with the next one
//         }
//       }
//
//       if (offers.isEmpty) {
//         debugPrint('No valid offers found in the response');
//         return;
//       }
//
//       await isar.writeTxn(() async {
//         await isar.offersColls.putAll(offers);
//       });
//     }
//   }
//
//   availOffer({
//     required Map<String, dynamic> offerAvailDetails,
//     required OfferEnCashController offerEnCashController,
//   }) async {
//     try {
//       Response res = await post(
//         '${Utils.apiUrl}/availOfferByCustomer',
//         offerAvailDetails,
//         headers: await Utils().getHeaders(),
//       );
//       debugPrint('availOffer');
//
//       if (res.statusCode != 200) {
//         if (res.statusCode == 401) {
//           Utils().showSnackBar('Session expired!');
//           return;
//         }
//         throw 'Something went wrong while availing offer. Error: ${res.body}';
//       }
//
//       if (res.statusCode == 200) {
//         // Access the response body directly without decoding
//         final responseData = res.body as Map<String, dynamic>;
//         final orderID = responseData['data']?['orderID'];
//         final availedOfferData = responseData['data']?['availedOfferData'];
//
//         if (orderID != null && availedOfferData != null) {
//           // Update offerAvailDetails with the orderID for QR generation
//           offerAvailDetails['orderID'] = orderID;
//           offerEnCashController
//               .changeJsonStringForQR(offerAvailDetails.toString());
//           debugPrint(
//               'offerAvailDetails.toString() | ${offerAvailDetails.toString()}');
//
//           // Save `orderID` in Firebase
//           await FirebaseFirestore.instance
//               .collection('availedOffers')
//               .doc(orderID)
//               .set(offerAvailDetails);
//
//           // Fetch existing offer from the local Isar database
//           OffersColl? offer = await isar.offersColls
//               .where()
//               .offerIDEqualTo(availedOfferData['offerID'])
//               .build()
//               .findFirst();
//
//           if (offer != null) {
//             // Write to the local Isar database in a transaction
//             await isar.writeTxn(() async {
//               await isar.availedOffersColls.put(
//                 AvailedOffersColl(
//                   offerName: availedOfferData['offerName'],
//                   discountNoPrime: availedOfferData['discountNoPrime'],
//                   productName: availedOfferData['productName'],
//                   offerType: availedOfferData['offerType'],
//                   availedOfferID: orderID,
//                   offerID: availedOfferData['offerID'],
//                   isOfferRedeemed: false,
//                   offerAvailedDate:
//                       DateTime.parse(availedOfferData['offerAvailedDate']),
//                   offerImg: List<String>.from(availedOfferData['offerImages'])
//                           .first ??
//                       "",
//                   offerAddress: offer.offerAddress,
//                   discountNo: availedOfferData['discountNo'],
//                 ),
//               );
//
//               // Increment the offerClaimedCount and save the updated offer
//               offer.offerClaimedCount += 1;
//               await isar.offersColls.put(offer);
//             });
//
//             Utils().showSnackBar(responseData['message']);
//           } else {
//             Utils().showSnackBar('Offer not found in local database.');
//           }
//         } else {
//           Utils().showSnackBar(
//               'Order ID or offer data is missing in the response.');
//         }
//       }
//     } catch (error) {
//       debugPrint('Error in availOffer: $error');
//       Utils().showSnackBar('An error occurred while availing the offer.');
//     }
//   }
//
//   availedOffers() async {
//     try {
//       Response res = await post('${Utils.apiUrl}/availedOffersByCustomer',
//           {'userPhone': firebaseAuth.currentUser!.phoneNumber},
//           headers: await Utils().getHeaders());
//
//       if (res.statusCode != 200) {
//         if (res.statusCode == 401) {
//           Utils().showSnackBar('Session expire! login again!');
//           return;
//         }
//         if (res.body != null &&
//             res.body['message'].toString().contains('no data')) {
//           debugPrint('No data found!');
//           return;
//         } else {
//           throw 'while availedOffersByCustomer offer list with Exp or error : ${res.body}';
//         }
//       }
//
//       List offerAvailedList = (res.body['offerAvailedList'] as List);
//       if (offerAvailedList.isNotEmpty) {
//         List<AvailedOffersColl> availedOffers = [];
//
//         for (var availedOffer in offerAvailedList) {
//           OffersColl? offer = await isar.offersColls
//               .where()
//               .offerIDEqualTo(availedOffer['availedOfferData']['offerID'])
//               .build()
//               .findFirst();
//
//           if (offer != null) {
//             // Safely handle the offerImages list
//             String offerImage = "";
//             if (offer.offerImages != null && offer.offerImages.isNotEmpty) {
//               offerImage = offer.offerImages.first;
//             }
//
//             availedOffers.add(AvailedOffersColl(
//                 offerName: offer.offerName ?? "",
//                 discountNoPrime: offer.discountNoPrime ?? "",
//                 productName: offer.productName ?? "",
//                 offerType: offer.offerType ?? "",
//                 discountNo: offer.discountNo ?? "",
//                 availedOfferID: availedOffer['availedOfferId'] ?? "",
//                 offerID: availedOffer['availedOfferData']['offerID'] ?? "",
//                 isOfferRedeemed: availedOffer['availedOfferData']
//                         ['isOfferRedeemed'] ??
//                     false,
//                 offerAvailedDate: DateTime.parse(
//                     availedOffer['availedOfferData']['offerAvailedDate'] ?? ""),
//                 offerImg: offerImage ?? "", // Use the safely retrieved image
//                 offerAddress: offer.offerAddress ?? ""));
//           }
//         }
//
//         // Only proceed with database write if we have offers to save
//         if (availedOffers.isNotEmpty) {
//           await isar.writeTxn(() async {
//             await isar.availedOffersColls.clear();
//             await isar.availedOffersColls.putAll(availedOffers);
//           });
//         }
//       }
//     } catch (e, stackTrace) {
//       debugPrint('offerAvailedList error: $e');
//       debugPrint('Stack trace: $stackTrace');
//       // You might want to report this to Firebase Crashlytics
//       // FirebaseCrashlytics.instance.recordError(e, stackTrace);
//     }
//   }
//
//   addOrRemoveOfferFromWishList({required String offerID}) async {
//     UserColl user = await Utils().getUser() as UserColl;
//     var offer = await isar.offersColls
//         .filter()
//         .offerIDEqualTo(offerID)
//         .build()
//         .findFirst();
//     if (offer!.isInWishList) {
//       Response res = await post('${Utils.apiUrl}/removeOfferFromWishList',
//           {'userPhone': user.userMobileNumber, 'offerID': offerID},
//           headers: await Utils().getHeaders());
//
//       debugPrint('remove from wishlist statusCode| ${res.statusCode}');
//       debugPrint('remove from wishlist body| ${res.body}');
//       if (res.statusCode != 200) {
//         return throw 'can not remove offer from wishlist';
//       }
//       if (res.statusCode == 200) {
//         var offer = await isar.offersColls
//             .filter()
//             .offerIDEqualTo(offerID)
//             .build()
//             .findFirst();
//         await isar.writeTxn(() async {
//           offer!.isInWishList = false;
//           offer.offerSavedCount = offer.offerSavedCount - 1;
//           isar.offersColls.put(offer);
//         });
//         Utils().showSnackBar(res.body['message']);
//       }
//     } else {
//       Response res = await post('${Utils.apiUrl}/addOfferToWishList',
//           {'userPhone': user.userMobileNumber, 'offerID': offerID},
//           headers: await Utils().getHeaders());
//       debugPrint('add from wishlist statusCode| ${res.statusCode}');
//       debugPrint('add from wishlist body| ${res.body}');
//
//       if (res.statusCode != 200) {
//         return throw 'can not remove offer from wishlist';
//       }
//       if (res.statusCode == 200) {
//         var offer = await isar.offersColls
//             .filter()
//             .offerIDEqualTo(offerID)
//             .build()
//             .findFirst();
//         await isar.writeTxn(() async {
//           offer!.isInWishList = true;
//           offer.offerSavedCount = offer.offerSavedCount + 1;
//           await isar.offersColls.put(offer);
//         });
//         await firebaseAnalytics.logAddToWishlist(items: [
//           AnalyticsEventItem(
//               itemId: offer?.offerID ?? "",
//               discount: num.parse(offer?.discountNo ?? "0"))
//         ]);
//         Utils().showSnackBar(res.body['message']);
//       }
//     }
//   }
//
//   Future<bool> addOrRemoveOfferFromlikeList({required String offerID}) async {
//     UserColl user = await Utils().getUser() as UserColl;
//     var offer = await isar.offersColls
//         .filter()
//         .offerIDEqualTo(offerID)
//         .build()
//         .findFirst();
//
//     if (offer == null) {
//       throw Exception("Offer not found");
//     }
//
//     String endpoint =
//         offer.isInLikesList ? '/removefromelike' : '/addOfferToLikeList';
//
//     Response res = await post('${Utils.apiUrl}$endpoint',
//         {'userPhone': user.userMobileNumber, 'offerID': offerID},
//         headers: await Utils().getHeaders());
//
//     debugPrint(
//         '${offer.isInLikesList ? "Remove from" : "Add to"} like list statusCode| ${res.statusCode}');
//     debugPrint(
//         '${offer.isInLikesList ? "Remove from" : "Add to"} like list body| ${res.body}');
//
//     if (res.statusCode == 200) {
//       Utils().showSnackBar(res.body['message']);
//       return true;
//     } else {
//       throw Exception(
//           'Failed to ${offer.isInLikesList ? "remove offer from" : "add offer to"} like list');
//     }
//   }
//
//   addOrRemoveOfferFromratingList({required String offerID}) async {
//     UserColl user = await Utils().getUser() as UserColl;
//     var offer = await isar.offersColls
//         .filter()
//         .offerIDEqualTo(offerID)
//         .build()
//         .findFirst();
//     if (offer!.isInLikesList) {
//       Response res = await post('${Utils.apiUrl}/removefromelike',
//           {'userPhone': user.userMobileNumber, 'offerID': offerID},
//           headers: await Utils().getHeaders());
//
//       debugPrint('remove from wishlist statusCode| ${res.statusCode}');
//       debugPrint('remove from wishlist body| ${res.body}');
//       if (res.statusCode != 200) {
//         return throw 'can not remove offer from Likes';
//       }
//       if (res.statusCode == 200) {
//         var offer = await isar.offersColls
//             .filter()
//             .offerIDEqualTo(offerID)
//             .build()
//             .findFirst();
//         await isar.writeTxn(() async {
//           offer!.isInRatingsList = false;
//           offer.ratingCount = offer.ratingCount - 1;
//           isar.offersColls.put(offer);
//         });
//         Utils().showSnackBar(res.body['message']);
//       }
//     } else {
//       Response res = await post('${Utils.apiUrl}/addOfferToRatings',
//           {'userPhone': user.userMobileNumber, 'offerID': offerID},
//           headers: await Utils().getHeaders());
//       debugPrint('add from wishlist statusCode| ${res.statusCode}');
//       debugPrint('add from wishlist body| ${res.body}');
//
//       if (res.statusCode != 200) {
//         return throw 'can not remove offer from wishlist';
//       }
//       if (res.statusCode == 200) {
//         var offer = await isar.offersColls
//             .filter()
//             .offerIDEqualTo(offerID)
//             .build()
//             .findFirst();
//         await isar.writeTxn(() async {
//           offer!.isInRatingsList = true;
//           offer.ratingCount = offer.ratingCount + 1;
//           await isar.offersColls.put(offer);
//         });
//         // await firebaseAnalytics.logAddToWishlist(items: [
//         //   AnalyticsEventItem(
//         //       itemId: offer?.offerID ?? "",
//         //       discount: num.parse(offer?.discountNo ?? "0"))
//         // ]);
//         Utils().showSnackBar(res.body['message']);
//       }
//     }
//   }
//
//   getCustomerOfferWishListApi() async {
//     if (firebaseAuth.currentUser != null) {
//       try {
//         Response res = await post(
//           '${Utils.apiUrl}/getCustomerOfferWishList',
//           {'userPhone': firebaseAuth.currentUser!.phoneNumber},
//           headers: await Utils().getHeaders(),
//         );
//
//         debugPrint('getCustomerOfferWishList');
//         debugPrint(' RES statusCode : ${res.statusCode}');
//         debugPrint(' RES body : ${res.body}');
//
//         if (res.statusCode == 200) {
//           if (res.body != null) {
//             var responseBody = res.body;
//             if (responseBody['offerList'] != null) {
//               List offerList = List.from(responseBody['offerList']);
//               if (offerList.isNotEmpty) {
//                 for (var offer in offerList) {
//                   OffersColl? offerColl = await isar.offersColls
//                       .where()
//                       .offerIDEqualTo(offer['offerID'])
//                       .findFirst();
//                   if (offerColl != null) {
//                     await isar.writeTxn(() async {
//                       offerColl.isInWishList = true;
//                       await isar.offersColls.put(offerColl);
//                     });
//                   }
//                 }
//               }
//             } else {
//               debugPrint('No offer list found in the response body!');
//             }
//           } else {
//             debugPrint('Response body is null!');
//           }
//         } else {
//           if (res.statusCode == 401) {
//             // await Utils().logOutUser();
//             Utils().showSnackBar('Session expired! Please login again.');
//           } else {
//             throw 'Error while fetching offer list: ${res.statusCode}';
//           }
//         }
//       } catch (e) {
//         debugPrint('Exception occurred: $e');
//         throw 'Error while fetching offer list: $e';
//       }
//     } else {
//       debugPrint('User is not authenticated.');
//     }
//   }
// }



import 'dart:convert';
import 'package:candid_customer/Controllers/OffersController/OfferEnCashController.dart';
import 'package:candid_customer/Services/Collections/Offers/AvailedOffers/AvailedOffersColl.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:candid_customer/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Fresh token ke liye
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../../../Controllers/NotificationControllers/NotificationController.dart';
import '../../../Controllers/SmsApiController/SmsApiController.dart';
import '../../../Utils/Utils.dart';

class OffersConnect extends GetConnect {

  /// ✅ NEW: Fresh Header Function - 401 Error solve karne ke liye
  Future<Map<String, String>> _getFreshHeaders() async {
    final headers = await Utils().getHeaders();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("No Firebase user logged in");
      return headers;
    }

    try {
      final token = await user.getIdToken(true);

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';

      return headers;
    } catch (e) {
      debugPrint("Failed to refresh Firebase token: $e");
      return headers;
    }
  }

  DateTime parseDateTime(dynamic date) {
    if (date is String) {
      if (date.isEmpty) return DateTime.now();
      date = ensureValidDateFormat(date);
      return DateTime.parse(date);
    } else if (date is DateTime) {
      return date;
    } else {
      return DateTime.now(); // Fallback to avoid crash
    }
  }

  String ensureValidDateFormat(String dateStr) {
    List<String> parts = dateStr.split('T');
    String datePart = parts[0];
    String timePart = parts.length > 1 ? 'T' + parts[1] : '';

    List<String> dateComponents = datePart.split('-');
    if (dateComponents.length == 3 && dateComponents[2].length == 1) {
      dateComponents[2] = dateComponents[2].padLeft(2, '0');
    }

    return dateComponents.join('-') + timePart;
  }

  getAllOffersApi(bool offerType) async {
    UserColl? user = await Utils().getUser() as UserColl?;
    if (user == null) return;

    final body = {
      'userId': user.userUid,
      'offerType': offerType ? 'service' : 'product',
    };

// First request
    Response res = await post(
      '${Utils.apiUrl}/getOffers',
      body,
      headers: await _getFreshHeaders(),
    );

// If backend says Unauthorized, refresh token and retry once
    if (res.statusCode == 401) {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        try {
          await firebaseUser.getIdToken(true);

          // Retry the same request with the newly refreshed token
          res = await post(
            '${Utils.apiUrl}/getOffers',
            body,
            headers: await _getFreshHeaders(),
          );
        } catch (e) {
          debugPrint("Token refresh/retry failed: $e");
        }
      }
    }


    if (res.statusCode != 200) {
      if (res.statusCode == 401) {
        debugPrint('401 Unauthorized: Session is invalid even after refresh.');
        // Utils().showSnackBar('Session expire! login again!'); // Optional: user ko tang na karne ke liye silent rakhein
      }
      try {
        if (res.body != null &&
            res.body['message'] != null &&
            res.body['message'].toString().contains('Offers are here for you!')) {
          debugPrint('No data found!');
        } else {
          debugPrint('API Error Detail: ${res.body}');
        }
      } catch (e) {
        debugPrint('Something is wrong while fetching offers list!');
      }
      return;
    }

    if (res.statusCode == 200) {
      List<OffersColl> offers = [];

      // Safe parsing functions
      int parseInteger(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.round();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      String parseIntegerToString(dynamic value) {
        if (value == null) return "0";
        if (value is int) return value.toString();
        if (value is String) return value.isEmpty ? "0" : value;
        return "0";
      }

      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      bool parseBoolean(dynamic value) {
        if (value == null) return false;
        if (value is bool) return value;
        if (value is String) return value.toLowerCase() == 'true';
        return false;
      }

      List<String> parseOfferImages(dynamic value) {
        const defaultImage = 'https://via.placeholder.com/150';
        if (value == null) return [defaultImage];
        try {
          if (value is String) {
            final trimmed = value.trim();
            return trimmed.isEmpty ? [defaultImage] : [trimmed];
          }
          if (value is List) {
            final images = value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
            return images.isNotEmpty ? images : [defaultImage];
          }
          return [value.toString()];
        } catch (e) {
          return [defaultImage];
        }
      }

      if (res.body['data'] is! List) {
        debugPrint('Invalid data format');
        return;
      }

      for (var offer in res.body['data']) {
        try {
          var offerData = offer is Map ? offer['offerData'] : null;
          if (offerData == null || offerData is! Map) continue;

          DateTime selectedStartDate = parseDateTime(offerData['selectedStartDate'] ?? '');
          DateTime selectedEndDate = parseDateTime(offerData['selectedEndDate'] ?? '');

          OfferStatus offerStatus = OfferStatus.live;
          switch (offerData['offerStatus'].toString().toLowerCase()) {
            case 'live': offerStatus = OfferStatus.live; break;
            case 'available': offerStatus = OfferStatus.available; break;
            case 'end': offerStatus = OfferStatus.expired; break;
            case 'total encash': offerStatus = OfferStatus.totalEncash; break;
            case 'out of stock': offerStatus = OfferStatus.outOfStock; break;
          }

          double latitude = parseDouble(offerData['latitude']);
          double longitude = parseDouble(offerData['longitude']);

          String address = "Location Loading...";
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
            if(placemarks.isNotEmpty) {
              Placemark placeMark = placemarks.first;
              address = '${placeMark.subLocality}, ${placeMark.locality}';
            }
          } catch(e) {
            address = "Address not found";
          }

          offers.add(
            OffersColl(
              distanceFromUserInMeters: Geolocator.distanceBetween(
                position?.latitude ?? 0.0,
                position?.longitude ?? 0.0,
                latitude,
                longitude,
              ),
              offerID: offer['offerID']?.toString() ?? "",
              userPinCode: offerData['userPinCode']?.toString() ?? "",
              discountNo: offerData['discountNo']?.toString() ?? " ",
              offerType: offerData['offerType']?.toString() ?? "",
              catId: offerData['catId']?.toString() ?? "",
              userOutletAddress1: offerData['userOutletAddress1']?.toString() ?? '',
              userMobile1: offerData['userMobile1']?.toString() ?? '',
              userBusinessName: offerData['userBusinessName']?.toString() ?? '',
              userMobile2: offerData['userMobile2']?.toString() ?? '',
              userOutletAddress2: offerData['userOutletAddress2']?.toString() ?? '',
              userOutletAddressBuildingStreetArea: offerData['userOutletAddressBuildingStreetArea']?.toString() ?? '',
              latitude: latitude,
              longitude: longitude,
              offerStatus: offerStatus,
              isInWishList: parseBoolean(offerData['isInWishList']),
              isInRatingsList: parseBoolean(offerData['isInRatingsList']),
              isInLikesList: parseBoolean(offerData['isInLikesList']),
              hasRated: parseBoolean(offerData['hasRated']),
              offerAddress: address,
              offerDescription: offerData['offerDescription']?.toString() ?? '',
              offerDiscountedPrice: offerData['offerDiscountedPrice']?.toString() ?? "0",
              regularUnitPrice: offerData['regularUnitPrice']?.toString() ?? "0",
              unitPrice2: offerData['unitPrice2']?.toString() ?? "0",
              offerPrimeDiscountedPrice: offerData['offerPrimeDiscountedPrice']?.toString() ?? "0",
              warranty: offerData['warranty']?.toString() ?? '',
              refund: offerData['refund']?.toString() ?? '',
              other: offerData['other']?.toString() ?? '',
              delivery: offerData['delivery']?.toString() ?? '',
              maxNumClaims: parseIntegerToString(offerData['maxNumClaims']),
              describeDealDetails: offerData['describeDealDetails']?.toString() ?? '',
              stepsToRedeem: offerData['stepsToRedeem']?.toString() ?? '',
              discountNo2: offerData['discountNo2']?.toString() ?? "",
              offersPackageId: offerData['offersPackageId']?.toString() ?? "",
              discountType: offerData['discountType']?.toString() ?? "",
              productType: offerData['productType']?.toString() ?? "",
              createTime: DateTime.tryParse(offer['createTime'] ?? "") ?? DateTime.now(),
              isTrending: parseBoolean(offerData['isTrending']),
              isBigDays: parseBoolean(offerData['isBigDays']),
              likedByCurrentUser: parseBoolean(offerData['likedByCurrentUser']),
              vendorId: offerData['vendorId']?.toString() ?? '',
              selectedStartDate: selectedStartDate,
              selectedEndDate: selectedEndDate,
              offerName: offerData['offerName']?.toString() ?? '',
              productName: offerData['productName']?.toString() ?? '',
              discountNoPrime: offerData['discountNoPrime']?.toString() ?? "",
              discountUoM: offerData['discountUoM']?.toString() ?? '',
              isInStock: parseBoolean(offerData['isInStock']),
              offerImages: parseOfferImages(offerData['offerImages']),
              productDescription: offerData['productDescription']?.toString() ?? '',
              selectedCity: offerData['selectedCity']?.toString() ?? '',
              selectedState: offerData['selectedState']?.toString() ?? '',
              rating: parseDouble(offerData['rating']),
              ratingCount: parseInteger(offerData['ratingCount']),
              sharesCount: parseInteger(offerData['sharesCount']),
              likesCount: parseInteger(offerData['likesCount']),
              cumulativeRatingSum: parseDouble(offerData['cumulativeRatingSum']),
              offerClaimedCount: parseInteger(offerData['offerClaimedCount']),
              offerSavedCount: parseInteger(offerData['offerSavedCount']),
            ),
          );
        } catch (e) {
          debugPrint('Error processing offer: $e');
        }
      }

      if (offers.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.offersColls.putAll(offers);
        });
      }
    }
  }

  availOffer({
    required Map<String, dynamic> offerAvailDetails,
    required OfferEnCashController offerEnCashController,
  }) async {
    try {
      Response res = await post(
        '${Utils.apiUrl}/availOfferByCustomer',
        offerAvailDetails,
        headers: await _getFreshHeaders(),
      );

      if (res.statusCode != 200) {
        Utils().showSnackBar('Error: ${res.statusCode}');
        return;
      }

      final responseData = res.body as Map<String, dynamic>;
      final orderID = responseData['data']?['orderID'];
      final availedOfferData = responseData['data']?['availedOfferData'];

      if (orderID != null && availedOfferData != null) {
        offerAvailDetails['orderID'] = Utils.sanitizeForJson(orderID);
        offerEnCashController.changeJsonStringForQR(jsonEncode(offerAvailDetails));

        await FirebaseFirestore.instance.collection('availedOffers').doc(orderID).set(offerAvailDetails);

        OffersColl? offer = await isar.offersColls.where().offerIDEqualTo(availedOfferData['offerID']).findFirst();

        if (offer != null) {
          await isar.writeTxn(() async {
            await isar.availedOffersColls.put(
              AvailedOffersColl(
                offerName: availedOfferData['offerName'] ?? "",
                discountNoPrime: availedOfferData['discountNoPrime'] ?? "",
                productName: availedOfferData['productName'] ?? "",
                offerType: availedOfferData['offerType'] ?? "",
                availedOfferID: orderID,
                offerID: availedOfferData['offerID'] ?? "",
                isOfferRedeemed: false,
                offerAvailedDate: DateTime.tryParse(availedOfferData['offerAvailedDate'] ?? "") ?? DateTime.now(),
                offerImg: (availedOfferData['offerImages'] as List?)?.first ?? "",
                offerAddress: offer.offerAddress,
                discountNo: availedOfferData['discountNo'] ?? "",
              ),
            );
            offer.offerClaimedCount += 1;
            await isar.offersColls.put(offer);
          });
          Utils().showSnackBar(responseData['message']);
        }
      }
    } catch (error) {
      debugPrint('Error in availOffer: $error');
    }
  }

  availedOffers() async {
    try {
      if (firebaseAuth.currentUser == null) return;
      Response res = await post(
          '${Utils.apiUrl}/availedOffersByCustomer',
          {'userPhone': firebaseAuth.currentUser!.phoneNumber},
          headers: await _getFreshHeaders()
      );

      if (res.statusCode == 200 && res.body['offerAvailedList'] != null) {
        List offerAvailedList = (res.body['offerAvailedList'] as List);
        List<AvailedOffersColl> availedOffers = [];

        for (var availedOffer in offerAvailedList) {
          String offerID = availedOffer['availedOfferData']?['offerID'] ?? "";
          OffersColl? offer = await isar.offersColls.where().offerIDEqualTo(offerID).findFirst();

          if (offer != null) {
            String offerImage = offer.offerImages.isNotEmpty ? offer.offerImages.first : "";

            availedOffers.add(
                AvailedOffersColl(
                    offerName: offer.offerName ?? "",
                    discountNoPrime: offer.discountNoPrime ?? "",
                    productName: offer.productName ?? "",
                    offerType: offer.offerType ?? "",
                    discountNo: offer.discountNo ?? "",
                    availedOfferID: availedOffer['availedOfferId'] ?? "",
                    offerID: offerID,
                    isOfferRedeemed: availedOffer['availedOfferData']?['isOfferRedeemed'] ?? false,
                    offerAvailedDate: DateTime.tryParse(availedOffer['availedOfferData']?['offerAvailedDate'] ?? "") ?? DateTime.now(),
                    offerImg: offerImage,
                    offerAddress: offer.offerAddress ?? ""
                )
            );
          }
        }

        if (availedOffers.isNotEmpty) {
          await isar.writeTxn(() async {
            await isar.availedOffersColls.clear();
            await isar.availedOffersColls.putAll(availedOffers);
          });
        }
      }
    } catch (e) {
      debugPrint('availedOffers error: $e');
    }
  }

  addOrRemoveOfferFromWishList({required String offerID}) async {
    UserColl user = await Utils().getUser() as UserColl;
    var offer = await isar.offersColls.filter().offerIDEqualTo(offerID).findFirst();
    if (offer == null) return;

    String endpoint = offer.isInWishList ? '/removeOfferFromWishList' : '/addOfferToWishList';

    Response res = await post('${Utils.apiUrl}$endpoint',
        {'userPhone': user.userMobileNumber, 'offerID': offerID},
        headers: await _getFreshHeaders());

    if (res.statusCode == 200) {
      await isar.writeTxn(() async {
        offer.isInWishList = !offer.isInWishList;
        offer.offerSavedCount = offer.isInWishList ? offer.offerSavedCount + 1 : offer.offerSavedCount - 1;
        await isar.offersColls.put(offer);
      });
      Utils().showSnackBar(res.body['message']);
    }
  }

  Future<bool> addOrRemoveOfferFromlikeList({required String offerID}) async {
    UserColl user = await Utils().getUser() as UserColl;
    var offer = await isar.offersColls.filter().offerIDEqualTo(offerID).findFirst();

    if (offer == null) return false;

    String endpoint = offer.isInLikesList ? '/removefromelike' : '/addOfferToLikeList';

    Response res = await post('${Utils.apiUrl}$endpoint',
        {'userPhone': user.userMobileNumber, 'offerID': offerID},
        headers: await _getFreshHeaders());

    if (res.statusCode == 200) {
      Utils().showSnackBar(res.body['message']);
      return true;
    }
    return false;
  }

  getCustomerOfferWishListApi() async {
    if (firebaseAuth.currentUser != null) {
      try {
        Response res = await post(
          '${Utils.apiUrl}/getCustomerOfferWishList',
          {'userPhone': firebaseAuth.currentUser!.phoneNumber},
          headers: await _getFreshHeaders(),
        );

        if (res.statusCode == 200 && res.body['offerList'] != null) {
          List offerList = List.from(res.body['offerList']);
          for (var offer in offerList) {
            OffersColl? offerColl = await isar.offersColls.where().offerIDEqualTo(offer['offerID']).findFirst();
            if (offerColl != null) {
              await isar.writeTxn(() async {
                offerColl.isInWishList = true;
                await isar.offersColls.put(offerColl);
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Exception in wishlist api: $e');
      }
    }
  }
}

