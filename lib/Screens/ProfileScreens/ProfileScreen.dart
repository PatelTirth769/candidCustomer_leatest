import 'package:candid_customer/Controllers/ProfileController.dart';
import 'package:candid_customer/Screens/NotificationScreens/NotificationScreen.dart';
import 'package:candid_customer/Screens/OffersScreens/MyCreditsScreen.dart';
import 'package:candid_customer/Screens/OffersScreens/MyDealsScreen.dart';
import 'package:candid_customer/Screens/PaymentScreens/PrimeCustomerPaymentScreen.dart';
import 'package:candid_customer/Screens/PrimeMembership/PrimeMembershipScreen.dart';
import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:package_info_plus/package_info_plus.dart'; // To get app version info

import '../../Utils/MyWidgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWidgets().myAppBar(),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              MyWidgets().myDrawerHeader(),
              for (var item in bottomNavController.navDrawerItems)
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        fontFamily: 'Aileron',
                        fontSize: 12.sp,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                    onTap: () =>
                        Navigator.of(navigatorKey.currentContext!).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => item['screen'],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            color: localUser!.isUserPrimeMember ? Colors.black : Colors.white,
            height: MediaQuery.of(context).size.height / 2,
          ),
          Positioned.fill(
            bottom: 0,
            child: GetBuilder(
              init: ProfileController(),
              builder: (controller) {
                return StreamBuilder(
                  stream: isar.userColls
                      .filter()
                      .userFirstNameIsNotEmpty()
                      .watch(fireImmediately: true),
                  builder: (context, snapshot) {
                    UserColl? user;
                    if (snapshot.data != null &&
                        (snapshot.data as List<UserColl>).isNotEmpty) {
                      user = (snapshot.data as List<UserColl>).first;
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: snapshot.hasError ||
                              !snapshot.hasData ||
                              controller.isLoading ||
                              user == null
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundImage: NetworkImage(
                                          user.userProfileImg.isNotEmpty
                                              ? user.userProfileImg
                                              : 'https://png.pngtree.com/png-vector/20190710/ourmid/pngtree-user-vector-avatar-png-image_1541962.jpg',
                                        ),
                                      ),
                                      const SizedBox(width: 40),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${user.userFirstName} ${user.userLastName}',
                                            style: TextStyle(
                                              color:
                                                  localUser!.isUserPrimeMember
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            user.userEmail,
                                            style: const TextStyle(
                                              color: Color(0xFF727173),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        Text(
                                        'Joined Since:  ',
                                        style: GoogleFonts.workSans(
                                          color: Color(0xFF727173),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.userJoinedSince != null
                                            ? DateFormat('dd MMMM yyyy')
                                                .format(user.userJoinedSince!)
                                            : "Unknown",
                                        style:   GoogleFonts.workSans(
                                          color: Color(0xFF727173),
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        user.userAddress,
                                        style:   GoogleFonts.workSans(
                                          color: Color(0xFF727173),
                                          fontSize: 12,

                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (localUser!.isUserPrimeMember)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MyCreditsScreen(),
                                              ),
                                            );
                                          },
                                          child: _buildCard(
                                            localUser!.isUserPrimeMember
                                                ? 'lib/Images/Group 195 (1).svg'
                                                : 'lib/Images/Group 195.svg',
                                            localUser!.isUserPrimeMember
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyDealsScreen(),
                                            ),
                                          );
                                        },
                                        child: _buildCard(
                                          localUser!.isUserPrimeMember
                                              ? 'lib/Images/Group 194 (1).svg'
                                              : 'lib/Images/Group 194.svg',
                                          localUser!.isUserPrimeMember
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/Images/RealOffers1.png',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          children: [
                            Text(
                              'Candid Customer',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Version: Loading...',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF727173),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/Images/RealOffers1.png',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              'Candid Customer',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: localUser!.isUserPrimeMember
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              'Version: ${snapshot.data}',
                              style: TextStyle(
                                fontSize: 7.sp,
                                color: const Color(0xFF727173),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('Failed to load version'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String assetName, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SvgPicture.asset(assetName),
    );
  }
}
