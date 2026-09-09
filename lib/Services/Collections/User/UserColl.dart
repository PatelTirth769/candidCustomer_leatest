import 'package:isar_community/isar.dart';

part 'UserColl.g.dart';

@collection
class UserColl {
  Id? id;
  final DateTime? userJoinedSince;
  late DateTime userDOB;
  late String userUid;
  late String userMobileNumber;
  late String userFirstName;
  late String userLastName;
  late String userEmail;
  late String referralDetails;
  late String userGender;
  late String userProfileImg;
  late String userAddress;
  late String addressLine1;
  late String addressLine2;
  late String pinCode;
  late String landmark;
  late String firebaseMessagingToken;
  late bool userEmailIsVerified;
  late bool isUserPrimeMember;
  late DateTime? subscriptionEndDate;

  UserColl({
    this.id,
    required this.userUid,
    required this.userJoinedSince,
    required this.userMobileNumber,
    required this.userEmailIsVerified,
    required this.isUserPrimeMember,
    required this.userFirstName,
    required this.userLastName,
    required this.referralDetails,
    required this.addressLine1,
    required this.addressLine2,
    required this.pinCode,
    required this.landmark,
    required this.userAddress,
    required this.firebaseMessagingToken,
    required this.userEmail,
    required this.userGender,
    required this.userDOB,
    required this.userProfileImg,
    this.subscriptionEndDate,
  });

  factory UserColl.fromJson(Map<String, dynamic> json) {
    return UserColl(
      userJoinedSince: json['userJoinedSince'] != null
          ? DateTime.parse(json['userJoinedSince'] as String)
          : null,
      userUid: json['userUid'] as String,
      referralDetails: json['referralDetails'] as String,
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      userEmail: json['userEmail'] as String,
      userMobileNumber: json['userMobileNumber'] as String,
      userGender: json['userGender'] as String,
      userEmailIsVerified: json['userEmailIsVerified'] as bool,
      isUserPrimeMember: json['isUserPrimeMember'] as bool,
      userProfileImg: json['userProfileImg'] as String,
      userDOB: DateTime.parse(json['userDOB'] as String),
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String? ?? '',
      pinCode: json['pinCode'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      userAddress: json['userAddress'] as String,
      firebaseMessagingToken: json['firebaseMessagingToken'] as String,
     
      subscriptionEndDate: json['subscriptionEndDate'] != null 
          ? DateTime.parse(json['subscriptionEndDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userUid': userUid,
      'userJoinedSince': userJoinedSince?.toIso8601String(),
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userEmail': userEmail,
      'userMobileNumber': userMobileNumber,
      'userGender': userGender,
      'userEmailIsVerified': userEmailIsVerified,
      'isUserPrimeMember': isUserPrimeMember,
      'userProfileImg': userProfileImg,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'pinCode': pinCode,
      'landmark': landmark,
      'userDOB': userDOB.toIso8601String(),
      'userAddress': userAddress,
      'firebaseMessagingToken': firebaseMessagingToken,
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
    };
  }
}
