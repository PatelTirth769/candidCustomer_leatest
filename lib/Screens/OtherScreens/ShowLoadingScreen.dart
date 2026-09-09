import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

class ShowLoadingScreen extends StatelessWidget {
  const ShowLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 26.h,
              width: 60.w,
              padding: EdgeInsets.only(top: 6.h),
              child: SvgPicture.asset(
                'lib/Images/Group 366.svg', // Path to your SVG asset
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 20.h), // Adjust the spacing as needed
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
