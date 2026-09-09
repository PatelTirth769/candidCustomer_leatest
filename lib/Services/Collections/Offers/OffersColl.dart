import 'package:isar_community/isar.dart';

part 'OffersColl.g.dart';

// run command to generate file - flutter pub run build_runner build --delete-conflicting-outputs
// run command to use localhost api - adb reverse tcp:3636 tcp:3636

@embedded
class OfferTC {
  String? delivery, other, warranty, refund, COD;
}

@collection
class OffersColl {
  var id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Index(unique: true, type: IndexType.value, replace: true)
  final String offerID;

 // final VendorUserColl vendor;

  final String offerName,
      discountNoPrime,
      userPinCode,
      userBusinessName,
      discountNo,
      offerType,
      catId,
      offerDescription,
      offerAddress,
      offerDiscountedPrice,
      regularUnitPrice,
      offerPrimeDiscountedPrice,
      warranty,
      refund,
      other,
      unitPrice2,
      userOutletAddress1,
      userOutletAddress2,
      userOutletAddressBuildingStreetArea,
      userMobile1,
      userMobile2,
      delivery,
      maxNumClaims,
      describeDealDetails,
      stepsToRedeem,
      discountNo2,
      offersPackageId,
      discountType,
      discountUoM,
      productType,
      vendorId,
      productName,
      productDescription,
      selectedState,
      selectedCity;
  @Index()
  late bool hasRated;
  bool isInStock, isTrending, isInWishList , isInRatingsList , isInLikesList,isBigDays;


  @Index()
  late double rating;

  @Index()
  late double averageRating;

  @Index()
  late int ratingCount;

  @Index()
  late double cumulativeRatingSum;
  int sharesCount = 0;
  bool likedByCurrentUser;
  int likesCount = 0;
  double latitude, longitude, distanceFromUserInMeters;

  @enumerated
  OfferStatus offerStatus = OfferStatus.live;

  final DateTime createTime, selectedStartDate;
  DateTime selectedEndDate;

  final List<String> offerImages;
  // final OfferTC offerTC;

  int offerSavedCount = 0, offerClaimedCount = 0;

  OffersColl({
    //required this.vendor,
    required this.offerID,
    required this.offerAddress,
    required this.userOutletAddressBuildingStreetArea,
    required this.userOutletAddress1,
    required this.userOutletAddress2,
    required this.latitude,
    required this.longitude,
    required this.userMobile1,
    required this.userMobile2,
    required this.isBigDays,
    required this.unitPrice2,
    required this.offerDiscountedPrice,
    required this.regularUnitPrice,
    required this.offerPrimeDiscountedPrice,
    required this.warranty,
    required this.refund,
    required this.other,
    required this.userBusinessName,
    required this.delivery,
    required this.maxNumClaims,
    required this.describeDealDetails,
    required this.stepsToRedeem,
    required this.userPinCode,
    required this.discountNo,
    required this.offerType,
    required this.catId,
    required this.offerStatus,
    required this.offerDescription,
    required this.discountNo2,
    required this.offersPackageId,
    required this.discountType,
    required this.vendorId,
    required this.productType,
    required this.createTime,
    required this.hasRated,
    required this.isTrending,
    required this.isInWishList,
    required this.isInLikesList,
    required this.isInRatingsList,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.offerName,
    this.rating = 0.0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.cumulativeRatingSum = 0,
    this.sharesCount = 0,
    this.likesCount = 0,
    required this.productName,
    required this.discountNoPrime,
    required this.discountUoM,
    required this.isInStock,
    required this.likedByCurrentUser,
    required List<String> offerImages,
    required this.selectedState,
    required this.selectedCity,
    required this.productDescription,
    required this.distanceFromUserInMeters,
    required this.offerSavedCount,
    required this.offerClaimedCount,
  }) : offerImages = offerImages.isNotEmpty ? offerImages : ['https://via.placeholder.com/150'];
}

enum OfferStatus {live,available,expired,totalEncash,outOfStock }
