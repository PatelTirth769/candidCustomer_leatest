import 'package:isar_community/isar.dart';

part 'AvailedOffersColl.g.dart';

// run command to generate file - flutter pub run build_runner build --delete-conflicting-outputs
// run command to use localhost api - adb reverse tcp:3636 tcp:3636

@collection
class AvailedOffersColl {
  var id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Index(unique: true, type: IndexType.value)
  final String availedOfferID;

  final DateTime offerAvailedDate;
  final String offerName,
      discountNoPrime,
      offerAddress,
      productName,
      offerImg,
      offerType,
      discountNo,
      offerID;
  final bool isOfferRedeemed;

  AvailedOffersColl(
      {required this.offerName,
      required this.discountNoPrime,
      required this.productName,
      required this.offerType,
      required this.availedOfferID,
      required this.isOfferRedeemed,
      required this.offerAvailedDate,
      required this.offerImg,
      required this.offerAddress,
      required this.discountNo,
      required this.offerID});
}
