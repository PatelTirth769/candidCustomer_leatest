// run command to use localhost api - adb reverse tcp:3636 tcp:3636
// run command to use localhost api - adb reverse tcp:5001 tcp:5001

import 'package:candid_customer/Services/Collections/App/AppDataColl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../../../Controllers/SmsApiController/SmsApiController.dart';
import '../../../Screens/AuthScreens/CreateProfile.dart';
import '../../../Utils/Utils.dart';
import '../../../main.dart';
import '../../Collections/User/UserColl.dart';

class AuthConnect extends GetConnect {
  SmsApiController smsController = SmsApiController();

  /// LOGIN + SIGNUP COMBINED FLOW
  ///
  /// - Agar backend se userData NA mile -> NEW USER -> CreateProfile
  /// - Agar backend se userData mile -> EXISTING USER -> direct main screen
  Future<void> loginRegisterAccount({
    required String mobileNumber,
    required bool isSignUp,
    Map<String, dynamic>? userData,
    required User user,
    required AdditionalUserInfo additionalUserInfo,
  }) async {
    try {
      final String url = '${Utils.apiUrl}/login-register';
      debugPrint('URL: $url');

      // Mobile normalize
      mobileNumber = mobileNumber.replaceAll(' ', '');

      // FCM token
      String token = "";
      try {
        token = (await firebaseMessaging.getToken(
          vapidKey:
          "BD93uA4LT6RTzfWR3aWZs-u2b4Uh0utaTEIQ6X5xgetpTTafFzXFZSIkrKg465rJhDbcLtdipMWARn-Dbu5NAJA",
        ))
            .toString();
      } catch (e) {
        debugPrint('FCM Token Fetch Error: $e');
      }

      // SignUp ke time extra data bhejna ho to:
      if (isSignUp) {
        userData ??= {};
        userData['firebaseMessagingToken'] = token;
      }

      // API CALL
      Response res = await post(
        url,
        {
          'userPhone': mobileNumber,
          'isCustomer': 'true',
          'userData': isSignUp ? userData : {}, // login pe mostly {} hi jayega
        },
        contentType: 'application/json',
        headers: await Utils().getHeaders(),
      );

      debugPrint('login | ${res.statusCode}');
      debugPrint('login | ${res.body}');

      // ----- STATUS CODE CHECK -----
      if (res.statusCode == null || res.statusCode != 200) {
        if (res.statusCode == 401) {
          Utils().showSnackBar('Session expired!');
          return;
        }
        Utils().showSnackBar('Try again later!');
        throw 'Something is wrong while sign in / create profile | ${res.body}';
      }

      // ------------- RESPONSE PARSE -------------
      final dynamic rawMessage = res.body['message'];
      final String message = rawMessage?.toString() ?? '';

      final dynamic rawUserData = res.body['userData'];

      // ====== CASE 1: userData null/empty => NEW USER => CreateProfile ======
      if (rawUserData == null ||
          (rawUserData is Map && rawUserData.isEmpty)) {
        debugPrint('loginRegisterAccount: NEW USER (no userData found in backend)');

        // Sirf yahi case me CreateProfile dikhana hai
        final currentUser = firebaseAuth.currentUser;
        if (currentUser != null && currentUser.phoneNumber != null) {
          await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => CreateProfile(
                mobileNumber: currentUser.phoneNumber!,
                user: user,
                additionalUserInfo: additionalUserInfo,
              ),
            ),
                (route) => false,
          );
        } else {
          Utils().showSnackBar(
            'This mobile number or email ID is already used by another account. Please try with a different number and email.',
          );
          Navigator.of(navigatorKey.currentContext!)
              .popUntil((route) => route.isFirst);
        }
        return;
      }

      // ====== CASE 2: userData present => EXISTING USER => DIRECT LOGIN ======
      debugPrint('loginRegisterAccount: EXISTING USER (userData found)');

      final Map<String, dynamic> body =
      Map<String, dynamic>.from(rawUserData as Map);

      debugPrint('body : $body');

      // Safely parse DOB
      DateTime parsedDob;
      try {
        final dobStr = (body['userDOB'] ?? '1970-01-01').toString();
        parsedDob = DateTime.parse(dobStr);
      } catch (_) {
        parsedDob = DateTime(1970, 1, 1);
      }

      final bool isPrime = (body['isUserPrimeMember'] is bool)
          ? body['isUserPrimeMember'] as bool
          : false;

      final bool emailVerified = (body['userEmailIsVerified'] is bool)
          ? body['userEmailIsVerified'] as bool
          : false;

      final String localMobile = mobileNumber.replaceAll(' ', '');

      // Firebase photo url safe update
      try {
        await user.updatePhotoURL((body['userProfileImg'] ?? '').toString());
      } catch (e) {
        debugPrint('updatePhotoURL error: $e');
      }

      // ISAR me user save karo
      await isar.writeTxn(() async {
        await isar.userColls.clear();
        await isar.userColls.put(
          UserColl(
            userDOB: parsedDob,
            userUid: user.uid,
            userJoinedSince:
            user.metadata.creationTime ?? DateTime.now(),
            referralDetails: (body['referralDetails'] ?? '').toString(),
            isUserPrimeMember: isPrime,
            userEmail: (body['userEmail'] ?? '').toString(),
            firebaseMessagingToken: token,
            userEmailIsVerified: emailVerified,
            userFirstName: (body['userFirstName'] ?? '').toString(),
            userGender: (body['userGender'] ?? '').toString(),
            addressLine1: (body['addressLine1'] ?? '').toString(),
            addressLine2: (body['addressLine2'] ?? '').toString(),
            landmark: (body['landmark'] ?? '').toString(),
            pinCode: (body['pinCode'] ?? '').toString(),
            userMobileNumber: localMobile,
            userLastName: (body['userLastName'] ?? '').toString(),
            userAddress: (body['userAddress'] ?? '').toString(),
            userProfileImg: (body['userProfileImg'] ?? '').toString(),
          ),
        );
      });

      // Backend pe FCM token update (silent)
      updateUser(
        userData: {'firebaseMessagingToken': token},
        shouldShowMessage: false,
      );

      // Message show (agar aaye to)
      if (message.isNotEmpty) {
        Utils().showSnackBar(message);
      }

      // localUser set karo
      localUser = (await isar.userColls
          .get((await Utils().getUser() as UserColl).id!))!;

      await firebaseAnalytics.logLogin(loginMethod: 'phone');

      // YAHI PE DIRECT MAIN APP
      await Utils().runWhenLogin(shouldAskForPrimeRecharge: true);
    } catch (e) {
      debugPrint('loginRegisterAccount ERROR: $e');
      Utils().showSnackBar('Login error: $e');
    }
  }

  // -------------------- UPDATE USER --------------------
  updateUser({
    required Map<String, dynamic> userData,
    required bool shouldShowMessage,
  }) async {
    debugPrint('URL: ${'${Utils.apiUrl}/updateProfileByID'}');

    Response res = await post(
      '${Utils.apiUrl}/updateProfileByID',
      {
        'userPhone':
        firebaseAuth.currentUser!.phoneNumber!.replaceAll(' ', ''),
        'userData': userData,
        'userID': (await Utils().getUser() as UserColl?)?.userUid ?? '',
      },
      headers: await Utils().getHeaders(),
    );

    debugPrint('updateProfileByID statusCode: ${res.statusCode}');
    debugPrint('updateProfileByID body: ${res.body}');
    debugPrint('userData: $userData');

    if (res.statusCode != 200) {
      if (res.statusCode == 401) {
        Utils().showSnackBar('Session expired!');
        return;
      }
      throw 'Something went wrong while updating your profile! ${res.body}';
    } else {
      var user = await Utils().getUser();
      if (user == null) {
        throw 'User not found. Please make sure you are logged in.';
      }

      var localUser = await isar.userColls.get(user.id!);
      if (localUser == null) {
        throw 'Local user data not found.';
      }

      if (userData.containsKey('userProfileImg')) {
        localUser.userProfileImg = userData['userProfileImg'];
        await firebaseAuth.currentUser
            ?.updatePhotoURL(userData['userProfileImg']);
      }
      if (userData.containsKey('userFirstName')) {
        localUser.userFirstName = userData['userFirstName'];
      }
      if (userData.containsKey('userLastName')) {
        localUser.userLastName = userData['userLastName'];
      }
      if (userData.containsKey('userEmail')) {
        localUser.userEmail = userData['userEmail'];
      }
      if (userData.containsKey('userGender')) {
        localUser.userGender = userData['userGender'];
      }
      if (userData.containsKey('isUserPrimeMember')) {
        localUser.isUserPrimeMember = userData['isUserPrimeMember'];
      }
      if (userData.containsKey('addressLine1')) {
        localUser.addressLine1 = userData['addressLine1'];
      }
      if (userData.containsKey('addressLine2')) {
        localUser.addressLine2 = userData['addressLine2'];
      }
      if (userData.containsKey('landmark')) {
        localUser.landmark = userData['landmark'];
      }
      if (userData.containsKey('pinCode')) {
        localUser.pinCode = userData['pinCode'];
      }
      if (userData.containsKey('userAddress')) {
        localUser.userAddress = userData['userAddress'];
      }
      if (userData.containsKey('firebaseMessagingToken')) {
        localUser.firebaseMessagingToken =
        userData['firebaseMessagingToken'];
      }

      await isar.writeTxn(() async {
        await isar.userColls.put(localUser);
      });

      if (shouldShowMessage) {
        Utils().showSnackBar(res.body['message']);
      }
    }
  }

  // -------------------- SESSION COOKIE API --------------------
  Future<void> createSessionApi() async {
    try {
      Response res = await post(
        '${Utils.apiUrl}/createSessionCookie',
        {},
        headers: await Utils().getHeaders(),
      );

      if (res.statusCode != 200) {
        debugPrint(
            'Failed to create session. Status Code: ${res.statusCode}, Body: ${res.body}');
        Utils().showSnackBar('Fail to create session! ${res.body}');
        throw Exception('Failed to create session: ${res.statusCode}');
      }

      await isar.writeTxn(() async {
        await isar.appDataColls.clear();
        await isar.appDataColls.put(
          AppDataColl(
            isSignedIn: false,
            sessionCookie: res.body['sessionCookie'],
          ),
        );
      });

      list = await isar.appDataColls.where().findAll();
      debugPrint(
          'Session created successfully with cookie: ${res.body['sessionCookie']}');
    } catch (e) {
      debugPrint('Error in createSessionApi: $e');
      throw e;
    }
  }
}
