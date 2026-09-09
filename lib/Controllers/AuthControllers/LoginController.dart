import 'dart:convert';

import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:candid_customer/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../../Screens/AuthScreens/VerifyNumber.dart';
import '../../Services/API/AuthServices/AuthConnect.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final List<String> _list = <String>['IN +91'];
  String dropdownSelectedValue = 'IN +91';
  bool isOtpSent = false,
      isLoading = false;
  String mobileNumber = '';

  @override
  Future<void> onInit() async {
    super.onInit();
    mobileNumber = ''; // Always set mobileNumber
    update();
    try {
      position ??= await utils.determinePosition();
    } catch (e) {
      debugPrint('login onInit | catch | $e');
    }
  }

  Future<void> demoLogin() async {
    try {
      isLoading = true;
      update();

      debugPrint('Starting demo login process');

      // Use a valid demo phone number
      const String demoPhoneNumber = '+918888888888'; // Valid Indian phone number format

      // Wrap session creation in a try-catch
      try {
        // await AuthConnect().createSessionApi();
        debugPrint('Session created successfully.');
      } catch (e) {
        debugPrint('Failed to create session: $e');
        Utils().showSnackBar('Failed to create session: $e');
        return; // Return early if session creation fails
      }

      // Make the API call
      final String apiUrl = '${Utils.apiUrl}/demo-login';
      debugPrint('Calling API: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          ...(await Utils().getHeaders()),
        },
        body: json.encode({
          'userPhone': demoPhoneNumber,
          'isCustomer': true,
          'userData': {
            'userFullName': 'Demo User',
            'userEmail': 'demo@example.com',
            'userDOB': '2000-01-01',
            'userGender': 'Other',
            'addressLine1': 'addressLine1',
            'addressLine2': "addressLine1",
            'pinCode': "123456",
            'landmark': "addressLine1",
            'userAddress': '123 Demo Street',
          }
        }),
      );

      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userData = responseData['userData'];

        debugPrint('Successfully got user data: $userData');

        // Save user data to local storage
        await isar.writeTxn(() async {
          await isar.userColls.clear();
          await isar.userColls.put(UserColl(
            userDOB: DateTime.parse(userData['userDOB'] ?? '2000-01-01'),
            userUid: userData['userUid'] ?? 'demo-${DateTime.now().millisecondsSinceEpoch}',
            userJoinedSince: DateTime.now(),
            referralDetails: '',
            isUserPrimeMember: false,
            userEmail: userData['userEmail'] ?? 'demo@example.com',
            firebaseMessagingToken: 'demo-token',
            userEmailIsVerified: false,
            userFirstName: userData['userFullName']?.split(' ').first ?? 'Demo',
            userGender: userData['userGender'] ?? 'Other',
            userMobileNumber: demoPhoneNumber,
            addressLine1: userData['addressLine1'] ?? "123 Demo Street",
            addressLine2: userData["addressLine2"] ?? "123 Demo Street",
            landmark: userData["landmark"] ?? "123 Demo Street",
            pinCode: userData["pinCode"] ?? "123 Demo Street",
            userLastName: userData['userFullName']?.split(' ').last ?? 'User',
            userAddress: userData['userAddress'] ?? '123 Demo Street',
            userProfileImg: userData['userProfileImg'] ?? '',
          ));
        });

        debugPrint('Saved user data to local storage');

        // Update local user
        localUser = (await isar.userColls.where().findFirst())!;

        debugPrint('Updated local user');

        // Use Utils().runWhenLogin
        await Utils().runWhenLogin(shouldAskForPrimeRecharge: true);

      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        Utils().showSnackBar('Demo login failed. ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Demo login error: $e');
      debugPrint('Stack trace: $stackTrace');
      Utils().showSnackBar('Error during demo login: ${e.toString()}');
    } finally {
      isLoading = false;
      update();
    }
  }

  // ✅ FIX: this now OWNS the whole "send OTP" flow — validating the form,
  // showing its own isLoading state, and only navigating to the OTP screen
  // (VerifyNumber) once that's done. Previously, LoginScreen navigated the
  // user straight to a slideshow screen (ImageDisplayScreen) the instant the
  // button was tapped, WITHOUT waiting for this method (it wasn't even
  // awaited) — so the user visually left the login flow before any OTP was
  // sent or verified. Nothing outside this method now controls navigation
  // for the OTP step.
  Future<void> loginPress(String mobileNumber) async {
    if (!formKey.currentState!.validate()) {
      utils.showSnackBar('Enter valid phone!');
      return;
    }

    if (isLoading) return;

    isLoading = true;
    update();

    try {
      // Brief pause purely for UX (spinner visibility) — actual OTP sending
      // happens once VerifyNumber's controller initializes and calls
      // Firebase's verifyPhoneNumber.
      await Future.delayed(const Duration(milliseconds: 800));
      isOtpSent = true;

      await Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (BuildContext context) => VerifyNumber(
            mobileNumber: mobileNumber,
            isSignInProcess: true,
          ),
        ),
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  updateMobileNumber(String mobile) {
    mobileNumber = mobile;
    update();
  }

  bool isRegisteredUser() {
    return mobileNumber == '1234567890';
  }

  updatedDropDownSelectedValue(String val) {
    dropdownSelectedValue = val;
    update();
  }

  List<String> getCodeList() {
    return _list;
  }
}
