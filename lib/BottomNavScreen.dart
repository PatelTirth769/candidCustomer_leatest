import 'package:candid_customer/Utils/MyWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'main.dart';

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: homeScreenController,
      builder: (homeScreenController) => GetBuilder(
        init: bottomNavController,
        builder: (controller) {
          return Scaffold(
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
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          onTap: () => Navigator.of(navigatorKey.currentContext!).push(
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
            body: controller.widgetOptions.elementAt(bottomNavController.selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                buildAnimatedNavItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                ),
                buildAnimatedNavItem(
                  iconData: Icons.widgets_outlined,
                  label: 'Categories',
                  index: 1,
                ),
                BottomNavigationBarItem(
                  icon: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: bottomNavController.selectedIndex == 2 ? -6 : 0,
                    ),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      bool isSelected = bottomNavController.selectedIndex == 2;
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: Container(
                          width: 36,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite_outline,
                              size: 15.sp, // smaller icon
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  label: 'Wish List',
                ),
                buildAnimatedNavItem(
                  iconData: Icons.star_border,
                  label: 'Prime',
                  index: 3,
                ),
                buildAnimatedNavItem(
                  iconData: Icons.person_outline,
                  label: 'Profile',
                  index: 4,
                ),
              ],
              currentIndex: bottomNavController.selectedIndex,
              selectedItemColor: const Color(0xFFDB2020),
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: (index) => bottomNavController.changeSelectedIndex(index),
              type: BottomNavigationBarType.fixed,
            ),
          );
        },
      ),
    );
  }

  /// Helper to build animated nav item with move up + scale effect + blue circle background when selected
  BottomNavigationBarItem buildAnimatedNavItem({
    required IconData iconData,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: GetBuilder(
        init: bottomNavController,
        builder: (controller) {
          bool isSelected = controller.selectedIndex == index;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 1.0,
              end: isSelected ? 1.1 : 1.0,
            ),
            duration: const Duration(milliseconds: 200),
            builder: (context, scale, child) {
              return Transform.translate(
                offset: Offset(0, isSelected ? -0 : 0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: isSelected
                        ? const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDB2020), // your blue circle
                    )
                        : null,
                    child: Icon(
                      iconData,
                      size: 25.sp,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      label: label,
    );
  }
}
