import 'package:animations/animations.dart';
import 'package:candid_customer/Controllers/HomeScreenController.dart';
import 'package:candid_customer/Utils/Utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'Controllers/BottomNavController.dart';
import 'Screens/HomeScreen.dart';
import 'Screens/OtherScreens/SplashScreen.dart';
import 'Services/Collections/App/AppDataColl.dart';
import 'Services/Collections/Notification/NotificationColl.dart';
import 'Services/Collections/User/UserColl.dart';
import 'Utils/MyWidgets.dart';
import 'Services/API/SubscriptionServices/SubscriptionService.dart';

final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'navigatorKey');
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
// final FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FirebaseDynamicLinks firebaseDynamicLinks = FirebaseDynamicLinks.instance;
final FirebasePerformance firebasePerformance = FirebasePerformance.instance;
final FirebaseCrashlytics firebaseCrashlytics = FirebaseCrashlytics.instance;
final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
final BottomNavController bottomNavController = BottomNavController();
final HomeScreenController homeScreenController = HomeScreenController();
late final Isar isar;
Position? position;
final Utils utils = Utils();
final MyWidgets myWidgets = MyWidgets();
/// Create a [AndroidNotificationChannel] for heads up notifications
late final AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;
late List<AppDataColl> list;
UserColl? localUser;
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
  ],
);

var drawer = Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    children: [
      MyWidgets().myDrawerHeader(),
      for (var item in bottomNavController.navDrawerItems)
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Margin around each card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding inside the card
            title: Text(item['title'],style: TextStyle(fontFamily: 'Aileron'
                ,fontWeight: FontWeight.bold,fontSize: 20.sp),),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16.0), // iOS-style forward button
            onTap: () => Navigator.of(navigatorKey.currentContext!).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => item['screen'])),
          ),
        ),
    ],
  ),
);

List<NotificationColl> notSeenNotifications = [];

Future<void> main() async {

  await utils.initRunCode();

  // Setup subscription check
  await SubscriptionService.setupPeriodicCheck();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        title: 'Candid Customers',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Set Scaffold background color to #F9F9F9
          cardColor: Colors.white,
          cardTheme: const CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
        ) // Remove elevation to avoid shadow
            .copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
            },
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
