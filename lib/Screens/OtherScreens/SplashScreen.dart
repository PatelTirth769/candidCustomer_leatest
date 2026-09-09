import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../Services/Collections/User/UserColl.dart';
import '../../main.dart';
import '../OffersScreens/OfferDetailsScreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () async {
      debugPrint('Splash Screen');
      try {
        final user = await utils.getUser();
        if (user != null && user is UserColl) {
          // User is not null and is of type UserColl
          localUser = user;
          await utils.runWhenLogin(shouldAskForPrimeRecharge: false);
        } else {
          await utils.logOutUser();
        }
      } catch (e) {
        debugPrint('Splash Screen | Future.delayed $e');
        await utils.logOutUser();
      }
      // if (!e.toString().contains('Null')) {
      //   Future.delayed(const Duration(milliseconds: 100), () async {
      //     Navigator.of(navigatorKey.currentContext!).pushReplacement(
      //         MaterialPageRoute(
      //             builder: (BuildContext context) =>
      //                 firebaseAuth.currentUser == null
      //                     ? const LoginScreen()
      //                     : CreateProfile(
      //                         mobileNumber:
      //                             firebaseAuth.currentUser!.phoneNumber!,
      //                         user: firebaseAuth.currentUser!,
      //                         additionalUserInfo: firebaseAuth.currentUser!,
      //                       )));
      //   });
      // } else {

      if (firebaseAuth.currentUser != null) {
        // Get any initial links
        final PendingDynamicLinkData? initialLink =
            await firebaseDynamicLinks.getInitialLink();
        if (initialLink != null) {
          final Uri deepLink = initialLink.link;
          debugPrint('initialLink.link | ${initialLink.link}');
          debugPrint('initialLink.link.path | ${initialLink.link.path}');
          debugPrint(
              'initialLink.queryParameters | ${initialLink.link.queryParameters}');
          if (deepLink.queryParameters['offerID'] != null) {
            Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
                builder: (BuildContext context) => OfferDetailsScreen(
                    offerID: deepLink.queryParameters['offerID'].toString())));
          }
          // Example of using the dynamic link to push the user to a different screen
          // Navigator.pushNamed(navigatorKey.currentContext!, deepLink.path);
        }

        firebaseDynamicLinks.onLink.listen((dynamicLinkData) {
          debugPrint(
              'dynamicLinkData.link.path | ${dynamicLinkData.link.path}');
          var deepLink = dynamicLinkData.link;
          debugPrint('DynamicLinks onLink $deepLink');
          debugPrint(
              'DynamicLinks onLink queryParameters${deepLink.queryParameters}');
          debugPrint(
              'if if if : ${deepLink.queryParameters['offerID'] != null}');
          if (deepLink.queryParameters['offerID'] != null) {
            Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
                builder: (BuildContext context) => OfferDetailsScreen(
                    offerID: deepLink.queryParameters['offerID'].toString())));
          }
        }).onError((error) {
          debugPrint('firebaseDynamicLinks.listen ERR | $error');
        });
      }
    });
    return Scaffold(
         body: Center(
           child: Image(
         image: const AssetImage('lib/Images/RealOffers2.png'),
         width: kIsWeb ? 50.w : double.infinity,
         height: double.infinity,
         fit: BoxFit.fill,
      ),
    ));
  }
}
