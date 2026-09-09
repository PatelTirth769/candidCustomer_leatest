// import 'dart:async';
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../BottomNavScreen.dart';
// import '../../Screens/AuthScreens/CreateProfile.dart';
// import '../../Services/API/AuthServices/AuthConnect.dart';
// import '../../Utils/Utils.dart';
// import '../../main.dart';
//
// class VerifyMobileController extends GetxController {
//   String vId = '';
//   int? reToken;
//   bool isLoading = true, enableResend = false;
//   final String mobileNumber;
//   final bool isSignInProcess;
//   final formKey = GlobalKey<FormState>();
//   int secondsRemaining = 120;
//   late Timer timer;
//
//   TextEditingController otp1Controller = TextEditingController(),
//       otp2Controller = TextEditingController(),
//       otp3Controller = TextEditingController(),
//       otp4Controller = TextEditingController(),
//       otp5Controller = TextEditingController(),
//       otp6Controller = TextEditingController();
//
//   final focus1 = FocusNode(),
//       focus2 = FocusNode(),
//       focus3 = FocusNode(),
//       focus4 = FocusNode(),
//       focus5 = FocusNode(),
//       focus6 = FocusNode();
//
//   UserCredential? userCredential;
//
//   VerifyMobileController(
//       {required this.mobileNumber,
//
//         required this.isSignInProcess});
//
//   signInWithPhoneCred(PhoneAuthCredential credential) async {
//     userCredential = (await firebaseAuth.signInWithCredential(credential));
//     debugPrint('isSignInProcess: $isSignInProcess');
//
//     try {
//       await AuthConnect().createSessionApi();
//       utils.showSnackBar(
//           'Verification is done, click on google sign in button to go forward!');
//       isLoading = false;
//       update();
//     } catch (e) {
//       isLoading = false;
//       update();
//       debugPrint(
//           'SIGN IN | catch | E | createSessionApi | loginRegisterAccount $e');
//     }
//   }
//
//    sendOTP() async {
//     try {
//       isLoading = true;
//       update();
//       debugPrint('Starting phone verification...');
//       await firebaseAuth.verifyPhoneNumber(
//         phoneNumber: mobileNumber,
//         forceResendingToken: reToken,
//         timeout: const Duration(seconds: 120),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await signInWithPhoneCred(credential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           isLoading = false;
//           update();
//           debugPrint('verifyPhone: verificationFailed : $e');
//
//           String errorMessage = '';
//           switch (e.code) {
//             case 'invalid-phone-number':
//               errorMessage = 'The provided phone number is not valid.';
//               break;
//             case 'missing-client-identifier':
//               errorMessage = 'An error occurred during authentication. Please check your app\'s Firebase configuration.';
//               break;
//             default:
//               errorMessage = e.message ?? 'An unknown error occurred during authentication.';
//           }
//           utils.showSnackBar(errorMessage);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           startTimer();
//           debugPrint('verifyPhone: codeSent');
//           utils.showSnackBar('OTP is sent!');
//           isLoading = false;
//           vId = verificationId;
//           reToken = resendToken;
//           update();
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           isLoading = false;
//           vId = verificationId;
//           update();
//           debugPrint('verifyPhone: codeAutoRetrievalTimeout');
//           if (firebaseAuth.currentUser == null) {
//             utils.showSnackBar('Timeout, Try to re-send OTP');
//           }
//         },
//       );
//     } catch (e) {
//       isLoading = false;
//       update();
//       debugPrint('Error in sendOTP(): ${e.runtimeType} - $e');
//
//       String errorMessage = '';
//       if (e is FirebaseAuthException) {
//         errorMessage = e.message ?? 'An unexpected authentication error occurred.';
//       } else if (e is PlatformException) {
//         errorMessage = e.message ?? 'A platform-specific error occurred during authentication.';
//       } else {
//         errorMessage = 'An unknown error occurred during authentication.';
//       }
//       utils.showSnackBar(errorMessage);
//     }
//   }
//
//   Future<void> handleNewUser(AuthCredential credential, GoogleSignInAccount googleSignInAccount) async {
//     final googleUserCredential = await firebaseAuth.currentUser!.linkWithCredential(credential);
//
//     debugPrint('googleUserCredential.additionalUserInfo: ${googleUserCredential.additionalUserInfo}');
//     debugPrint('providerId: ${googleUserCredential.additionalUserInfo?.providerId}');
//     debugPrint('SIGN UP');
//
//     await firebaseAuth.currentUser!.updatePhotoURL(
//         googleUserCredential.additionalUserInfo!.profile?['picture'] ?? ""
//     );
//     await firebaseAuth.currentUser?.reload();
//
//     isLoading = false;
//     update();
//
//     await Navigator.of(navigatorKey.currentContext!).push(
//         MaterialPageRoute(
//             builder: (BuildContext context) => CreateProfile(
//                 mobileNumber: mobileNumber,
//                 user: googleUserCredential.user!,
//                 additionalUserInfo: googleUserCredential.additionalUserInfo!
//             )
//         )
//     );
//   }
//
//   Future<void> handleExistingUser(AuthCredential credential) async {
//     try {
//       debugPrint('SIGN IN | Starting existing user flow');
//       isLoading = true;
//       update();
//
//       // Sign in with Google credential
//       UserCredential googleUserCredential = await firebaseAuth.signInWithCredential(credential);
//       debugPrint('SIGN IN | Google user credentials obtained');
//
//       // Login/Register account
//       final loginResponse = await AuthConnect().loginRegisterAccount(
//           mobileNumber: mobileNumber.replaceAll(' ', ''),
//           isSignUp: false,
//           user: googleUserCredential.user!,
//           additionalUserInfo: googleUserCredential.additionalUserInfo!
//       );
//
//       debugPrint('SIGN IN | Login response received');
//
//       // Ensure we're not disposed before proceeding
//       if (!Get.isRegistered<VerifyMobileController>()) {
//         debugPrint('SIGN IN | Controller was disposed, stopping navigation');
//         return;
//       }
//
//       // Run post-login operations
//       await Utils().runWhenLogin(shouldAskForPrimeRecharge: true);
//
//       // Ensure we have a valid context before navigation
//       if (navigatorKey.currentContext == null) {
//         debugPrint('SIGN IN | No valid context for navigation');
//         return;
//       }
//
//       // Navigate to bottom nav screen
//       await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
//         MaterialPageRoute(
//             builder: (BuildContext context) => const BottomNavScreen()
//         ),
//             (route) => false,
//       );
//
//       debugPrint('SIGN IN | Navigation completed');
//     } catch (error) {
//       debugPrint('SIGN IN | Error during existing user flow: $error');
//       utils.showSnackBar('Failed to complete sign in. Please try again.');
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }
//
//   Future<void> handleGoogleSignIn() async {
//     if (firebaseAuth.currentUser == null || userCredential == null) {
//       utils.showSnackBar("Verify number first!");
//       return;
//     }
//
//     try {
//       isLoading = true;
//       update();
//
//       final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
//       if (googleSignInAccount == null) {
//         throw Exception('Google Sign In cancelled by user');
//       }
//
//       final authentication = await googleSignInAccount.authentication;
//       final credential = GoogleAuthProvider.credential(
//         idToken: authentication.idToken,
//         accessToken: authentication.accessToken,
//       );
//
//       debugPrint('SIGN IN | User exists: ${!userCredential!.additionalUserInfo!.isNewUser}');
//
//       if (userCredential!.additionalUserInfo!.isNewUser) {
//         await handleNewUser(credential, googleSignInAccount);
//       } else {
//         await handleExistingUser(credential);
//       }
//
//     } catch (error) {
//       debugPrint('SIGN IN | Google sign in error: $error');
//       String errorMessage = 'Failed to sign in with Google. Please try again.';
//
//       if (error is FirebaseAuthException) {
//         errorMessage = error.message ?? errorMessage;
//       }
//
//       utils.showSnackBar(errorMessage);
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       focus1.requestFocus();
//     });
//     sendOTP();
//   }
//
//   Future<void> _initializeController() async {
//     try {
//       await sendOTP();
//     } catch (e) {
//       debugPrint('VERIFY PHONE | Init error: $e');
//       utils.showSnackBar('Failed to initialize verification. Please try again.');
//     }
//   }
//
//   verifyOTP() async {
//     if (firebaseAuth.currentUser == null) {
//       try {
//         if (!formKey.currentState!.validate()) {
//           utils.showSnackBar('Write OTP to process further!');
//           return;
//         } else {
//           isLoading = true;
//           update();
//           String otp = '${otp1Controller.text}${otp2Controller.text}'
//               '${otp3Controller.text}${otp4Controller.text}'
//               '${otp5Controller.text}${otp6Controller.text}';
//           try {
//             await signInWithPhoneCred(PhoneAuthProvider.credential(
//                 verificationId: vId, smsCode: otp));
//           } on FirebaseAuthException catch (e) {
//             isLoading = false;
//             update();
//             debugPrint('E: Catch: ${e.message}');
//             if (e.message!.contains('phone auth credential is invalid')) {
//               utils.showSnackBar('Invalid OTP');
//             } else if (e.message!.contains('The sms code has expired')) {
//               utils.showSnackBar('Resend OTP due to OTP expired');
//             }
//           } catch (e) {
//             isLoading = false;
//             update();
//             debugPrint('credential: E: Catch: $e');
//           }
//         }
//       } catch (e) {
//         debugPrint('verify OTP : E: Catch: $e');
//       }
//     }
//   }
//
//   pasteOTPToAllFields() async {
//     ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
//     try {
//       if (cdata!.text!.isNotEmpty &&
//           cdata.text != null &&
//           cdata.text!.length == 6 &&
//           isNumeric(cdata.text)) {
//         List<String> otp = cdata.text!.split("");
//         otp1Controller.text = otp[0];
//         otp2Controller.text = otp[1];
//         otp3Controller.text = otp[2];
//         otp4Controller.text = otp[3];
//         otp5Controller.text = otp[4];
//         otp6Controller.text = otp[5];
//         FocusManager.instance.primaryFocus?.unfocus();
//       }
//     } catch (e) {
//       debugPrint('pasteOTPToAllFields: catch: E : $e');
//     }
//   }
//
//   bool isNumeric(String? s) {
//     if (s == null) {
//       return false;
//     }
//     return double.tryParse(s) != null;
//   }
//
//   startTimer() {
//     enableResend = false;
//     update();
//     timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (secondsRemaining != 0) {
//         secondsRemaining--;
//         update();
//       } else {
//         enableResend = true;
//         update();
//       }
//     });
//   }
//
//   @override
//   Future<void> dispose() async {
//     timer.cancel();
//     otp1Controller.dispose();
//     otp2Controller.dispose();
//     otp3Controller.dispose();
//     otp4Controller.dispose();
//     otp5Controller.dispose();
//     otp6Controller.dispose();
//     [focus1, focus2, focus3, focus4, focus5, focus6].forEach((node) {
//       node.dispose();
//     });
//     super.dispose();
//   }
//
//   @override
//   Future<void> onClose() async {
//     timer.cancel();
//     otp1Controller.dispose();
//     otp2Controller.dispose();
//     otp3Controller.dispose();
//     otp4Controller.dispose();
//     otp5Controller.dispose();
//     otp6Controller.dispose();
//     super.onClose();
//   }
// }
//



import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../Screens/AuthScreens/CreateProfile.dart';
import '../../Services/API/AuthServices/AuthConnect.dart';
import '../../Utils/Utils.dart';
import '../../main.dart';

class VerifyMobileController extends GetxController with CodeAutoFill {
  String vId = '';
  int? reToken;
  bool isLoading = true, enableResend = false;
  final String mobileNumber;
  final bool isSignInProcess;
  final formKey = GlobalKey<FormState>();
  int secondsRemaining = 120;
  late Timer timer;

  String? otpCode;

  TextEditingController otp1Controller = TextEditingController(),
      otp2Controller = TextEditingController(),
      otp3Controller = TextEditingController(),
      otp4Controller = TextEditingController(),
      otp5Controller = TextEditingController(),
      otp6Controller = TextEditingController();

  final focus1 = FocusNode(),
      focus2 = FocusNode(),
      focus3 = FocusNode(),
      focus4 = FocusNode(),
      focus5 = FocusNode(),
      focus6 = FocusNode();

  UserCredential? userCredential;

  VerifyMobileController({
    required this.mobileNumber,
    required this.isSignInProcess,
  });

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focus1.requestFocus();
    });
    _initSmsListener();
    sendOTP();
  }

  void _initSmsListener() async {
    try {
      await SmsAutoFill().unregisterListener(); // Clean previous listeners
      await SmsAutoFill().listenForCode(); // Start new listener
      listenForCode(); // Enable CodeAutoFill callback
      final signature = await SmsAutoFill().getAppSignature;
      debugPrint('App Signature: $signature'); // Share with backend
    } catch (e) {
      debugPrint('Error initializing SMS listener: $e');
    }
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length == 6) {
      debugPrint('Auto-filled OTP: $code');
      otpCode = code;
      fillOTPFields(code!);
      Future.delayed(const Duration(milliseconds: 500), () {
        verifyOTP();
      });
    }
  }

  void fillOTPFields(String otp) {
    if (otp.length == 6) {
      otp1Controller.text = otp[0];
      otp2Controller.text = otp[1];
      otp3Controller.text = otp[2];
      otp4Controller.text = otp[3];
      otp5Controller.text = otp[4];
      otp6Controller.text = otp[5];
      update();
    }
  }

  sendOTP() async {
    try {
      isLoading = true;
      update();

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        forceResendingToken: reToken,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await signInWithPhoneCred(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading = false;
          update();
          debugPrint('verifyPhone: verificationFailed : $e');
          utils.showSnackBar(
            e.message ?? 'Verification failed. Try again.',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          startTimer();
          isLoading = false;
          vId = verificationId;
          reToken = resendToken;
          utils.showSnackBar('OTP is sent!');
          update();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          vId = verificationId;
          isLoading = false;
          update();
          utils.showSnackBar('OTP retrieval timed out.');
        },
      );
    } catch (e) {
      isLoading = false;
      update();
      utils.showSnackBar('OTP sending error: $e');
    }
  }

  verifyOTP() async {
    try {
      String otp = '${otp1Controller.text}${otp2Controller.text}'
          '${otp3Controller.text}${otp4Controller.text}'
          '${otp5Controller.text}${otp6Controller.text}';

      if (otp.length != 6) {
        utils.showSnackBar('Please enter a valid 6-digit OTP');
        return;
      }

      isLoading = true;
      update();

      try {
        await signInWithPhoneCred(PhoneAuthProvider.credential(
          verificationId: vId,
          smsCode: otp,
        ));
      } on FirebaseAuthException catch (e) {
        isLoading = false;
        update();
        if (e.message!.contains('invalid')) {
          utils.showSnackBar('Invalid OTP. Try again.');
        } else if (e.message!.contains('expired')) {
          utils.showSnackBar('OTP expired. Resend again.');
        } else {
          utils.showSnackBar(e.message ?? 'OTP verification failed.');
        }
      }
    } catch (e) {
      isLoading = false;
      update();
      utils.showSnackBar('OTP verification error: $e');
    }
  }

  // --- UPDATED METHOD FOR REDIRECTION LOGIC ---
  signInWithPhoneCred(PhoneAuthCredential credential) async {
    try {
      userCredential = await firebaseAuth.signInWithCredential(credential);
      final User user = userCredential!.user!;
      final AdditionalUserInfo additionalUserInfo =
      userCredential!.additionalUserInfo!;

      // 1. Create session cookie
      await AuthConnect().createSessionApi();

      // 2. Check if the user is already registered on the backend
      // AuthConnect will handle the redirection:
      // - Existing user: Navigates to main app using Utils().runWhenLogin()
      // - New user: Navigates to CreateProfile
      await AuthConnect().loginRegisterAccount(
        mobileNumber: mobileNumber,
        isSignUp: false, // We are checking for existing account
        user: user,
        additionalUserInfo: additionalUserInfo,
      );

      isLoading = false;
      update();

      // Note: No direct navigation to CreateProfile here. AuthConnect handles it.
    } catch (e) {
      isLoading = false;
      update();
      utils.showSnackBar('Phone sign-in failed: $e');
    }
  }

  startTimer() {
    enableResend = false;
    secondsRemaining = 120;
    update();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        update();
      } else {
        enableResend = true;
        timer.cancel();
        update();
      }
    });
  }

  pasteOTPToAllFields() async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    if (cdata?.text != null &&
        cdata!.text!.length == 6 &&
        isNumeric(cdata.text)) {
      fillOTPFields(cdata.text!);
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  bool isNumeric(String? s) {
    if (s == null) return false;
    return double.tryParse(s) != null;
  }

  @override
  void onClose() {
    if (timer.isActive) timer.cancel();
    SmsAutoFill().unregisterListener();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();
    [focus1, focus2, focus3, focus4, focus5, focus6]
        .forEach((node) => node.dispose());
    super.onClose();
  }
}

