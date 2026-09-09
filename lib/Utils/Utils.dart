import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:candid_customer/Screens/PaymentScreens/PrimeCustomerPaymentScreen.dart';
import 'package:candid_customer/Services/API/AuthServices/AuthConnect.dart';
import 'package:candid_customer/Services/API/NotificationServices/NotificationConnect.dart';
import 'package:candid_customer/Services/Collections/App/AppDataColl.dart';
import 'package:candid_customer/Services/Collections/City/CityColl.dart';
import 'package:candid_customer/Services/Collections/Notification/NotificationColl.dart';
import 'package:candid_customer/Services/Collections/Offers/AvailedOffers/AvailedOffersColl.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../BottomNavScreen.dart';
import '../Screens/AuthScreens/LoginScreen.dart';
import '../Services/API/CatsServices/CatsConnect.dart';
import '../Services/API/CityServices/CityConnect.dart';
import '../Services/API/OffersServices/OffersConnect.dart';
import '../Services/Collections/Cat/CatsColl.dart';
import '../firebase_options.dart';
import '../main.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Handling a background message: ${message.messageId}");
}

class Utils {
  // run command to use localhost api - adb reverse tcp:5001 tcp:5001
  // flutter build apk --split-per-abi
  static String apiUrl =
      'https://us-central1-candid-cf9fc.cloudfunctions.net/app',
      categoryContentType = 'category',
      offerContentType = 'offer',
      offerAvailedContentType = 'offerAvailed',
      offerShareContentType = 'share_offer';

  // kDebugMode
  //     ? 'http://127.0.0.1:5001/candid-cf9fc/us-central1/app'
  //     : 'https://us-central1-candid-cf9fc.cloudfunctions.net/app';

  Color defaultColor = Colors.pink;
  static String localurl = 'http://127.0.0.1:5001/candid-cf9fc/us-central1/app';
  void showSnackBar(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      // backgroundColor: const Color(0xFFEE0000), // Background color
      textColor: Colors.white, // Text color
      fontSize: 16.0, // Font size
    );
  }

  validateMobileNumber(String mobileNumber) {
    if (mobileNumber.isEmpty) {
      return 'Please enter some text';
    } else if (mobileNumber.length < 10) {
      return 'Enter 10 digit';
    }
    return null;
  }

  logOutUser() async {
    try {
      await firebaseAuth.signOut();
      try {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      } catch (e) {
        debugPrint('logOutUser: GOOGLE SIGN_OUT CATCH: $e');
      }
      await isar.writeTxn(() async {
        await isar.clear();
      });
      await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('logOutUser: CATCH: $e');
    }
  }

  Future<void> writeToFile(ByteData data, String path) async {
    debugPrint('writeToFile');
    final buffer = data.buffer;
    File file = await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    var xyz = await ImageGallerySaverPlus.saveImage(file.path as Uint8List);
    debugPrint('xyz: $xyz');
  }

  validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter some text';
    } else if (!RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return 'Email is not valid!';
    }
    return null;
  }

  Future getUser() async {
    return await isar.userColls.buildQuery().findFirst();
  }

  initRunCode() async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseCrashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = (errorDetails) {
      firebaseCrashlytics.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      firebaseCrashlytics.recordError(error, stack, fatal: true);
      return true;
    };
    await firebaseAnalytics.logAppOpen();
    await dotenv.load(fileName: ".env");
    //Assign publishable key to flutter_stripe
    //  Stripe.publishableKey = dotenv.env['STRIPE_TEST_PublishableKey']!;
    // await firebaseAppCheck.activate(
    //     androidProvider: AndroidProvider.playIntegrity,
    //     appleProvider: AppleProvider.appAttestWithDeviceCheckFallback);
    // await firebaseAppCheck.setTokenAutoRefreshEnabled(true);
    isar = await Isar.open([
      UserCollSchema,
      CityCollSchema,
      OffersCollSchema,
      AvailedOffersCollSchema,
      CatsCollSchema,
      SubCatsCollSchema,
      AppDataCollSchema,
      NotificationCollSchema
    ],
        directory:
        !kIsWeb ? (await getApplicationSupportDirectory()).path : ' ');
    try {
      if (kDebugMode) {
        // final emulatorHost =
        //     (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        //         ? '10.0.2.2'
        //         : 'localhost';
        //
        // await firebaseStorage.useStorageEmulator(emulatorHost, 9199);
        // await firebaseAuth.useAuthEmulator("localhost", 9099);
        // await Utils().logOutUser();
      }
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      debugPrint('USE EMEmulator: AUTH | CATCH: E: $e');
      if (e.code == 'firebase_auth/user-not-found' ||
          e.message!.contains('There is no user record corresponding')) {
        // await utils.logOutUser();
      }
    } catch (e) {
      debugPrint('USE EMEmulator: CATCH: E: $e');
    }
    if (!kIsWeb) {
      await setupFlutterNotifications();
    }
    list = await isar.appDataColls.where().findAll();
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (firebaseAuth.currentUser != null) {
        AuthConnect().updateUser(
            userData: {'firebaseMessagingToken': newToken},
            shouldShowMessage: false);
      }
    });
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        debugPrint('notification : $notification');
        debugPrint('android : $android');
        // android
        if (notification != null && android != null) {
          showFlutterNotification(message);
          debugPrint(
              'Message also contained a notification: ${message.notification}');
        }
      });
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  runWhenLogin({required bool shouldAskForPrimeRecharge}) async {
    // await compute(
    //     (message) => Future.wait([CityConnect().getCityListApi()]), '');
    localUser =
    (await isar.userColls.get((await Utils().getUser() as UserColl).id!))!;
    // await CityConnect().getCityListApi();
    // await CatsConnect().getCatsList();
    // await OffersConnect()
    //     .getAllOffersApi(homeScreenController.screenTypeProducts);
    // await OffersConnect().availedOffers();

    Future.microtask(() async {
      await CityConnect().getCityListApi();
      await CatsConnect().getCatsList();
      await OffersConnect()
          .getAllOffersApi(homeScreenController.screenTypeProducts);
      await OffersConnect().availedOffers();
    });

    if (shouldAskForPrimeRecharge) {
      if (!localUser!.isUserPrimeMember) {
        await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const BottomNavScreen()),
              (route) => false,
        );
      }
    } else {
      await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const BottomNavScreen()),
            (route) => false,
      );
    }
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  getHeaders() async {
    // final appCheckToken = await firebaseAppCheck.getToken(true);
    // debugPrint('appCheckToken : $appCheckToken');
    // if (appCheckToken != null) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'X-Firebase-AppCheck': appCheckToken,
      'userPhone': firebaseAuth.currentUser?.phoneNumber ?? '',
      'userIdToken': (await firebaseAuth.currentUser?.getIdToken(true)) ?? '',
      'sessionCookie': list.isNotEmpty ? list[0].sessionCookie : '',
      // 'appId': firebaseAuth.app.options.appId,
      'isCustomer': 'true',
    };
    // } else {
    //   debugPrint("Error: couldn't get an App Check token.");
    //   return {
    //     'Content-Type': 'application/json',
    //     'Accept': 'application/json',
    //     'isCustomer': 'true',
    //   };
    // }
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            icon: notification.android?.imageUrl ?? '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  analyticsLogSelectContent(
      {required String contentType, required String itemId}) async {
    Future.delayed(
      const Duration(seconds: 5),
          () async {
        await firebaseAnalytics.logSelectContent(
          contentType: contentType,
          itemId: itemId,
        );
        debugPrint('analyticsLogSelectContent | called for $contentType');
      },
    );
  }

  analyticsLogEvent({
    required String eventName,
    // required Map<String, Object?>? parameters
  }) async {
    Future.delayed(
      const Duration(seconds: 5),
          () async {
        await firebaseAnalytics.logEvent(
          name: Utils.offerShareContentType,
          // parameters: parameters,
        );
        // debugPrint(
        //     'analyticsLogEvent | called for $eventName with parameters: $parameters');
      },
    );
  }

  Future<void> refreshUser() async {
    try {
      // Get fresh data from Firebase
      final userDoc = await FirebaseFirestore.instance
          .collection('candidCustomers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data()!;

        // Convert any map values to strings
        userData = userData.map((key, value) {
          if (value is Map) {
            return MapEntry(key, jsonEncode(value));
          }
          return MapEntry(key, value);
        });

        // Update local user object
        final userColl = UserColl.fromJson(userData);

        // Update Isar database
        final isar = await Isar.getInstance();
        if (isar != null) {
          await isar.writeTxn(() async {
            await isar.userColls.put(userColl);
          });
        }

        // Update global user object
        localUser = userColl;

        debugPrint('User data refreshed successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('Error refreshing user data: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static dynamic sanitizeForJson(dynamic value) {
    if (value is String) {
      return value.replaceAll('\\', '\\\\');
    }
    return value;
  }
}

extension Utility on BuildContext {
  void nextEditableTextFocus() {
    do {
      FocusScope.of(this).nextFocus();
    } while (
    FocusScope.of(this).focusedChild?.context?.widget is! EditableText);
  }
}
