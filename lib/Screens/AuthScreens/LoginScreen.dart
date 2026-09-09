import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:html_unescape/html_unescape.dart';
import '../../Controllers/AuthControllers/LoginController.dart';
import '../../Controllers/TermsAndConditionController.dart';
import '../../Services/API/TermsAndCondition/TermsAndConditionConnect.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isTermsAccepted = false;
  bool isOtpSent = false;
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final version = await _getAppVersion();
    setState(() {
      appVersion = version;
    });
  }

  void acceptTermsAndConditions() {
    setState(() {
      isTermsAccepted = true;
    });
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = LoginController();
    loginController.mobileNumber = '';

    void showTermsAndConditionsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Add your image here
                        Image.asset(
                          'lib/Images/RealOffers1.png', // Replace with your image asset path
                          width: 15.w, // Set the desired width
                          height: 10.h, // Set the desired height
                        ),
                        const SizedBox(
                            width:
                            15), // Add some space between the image and text
                        Text(
                          ' CANDID OFFERS CUSTOMER\n TERMS AND CONDITIONS',
                          style: GoogleFonts.workSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 1.0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<TermsAndConditions>(
                        future: fetchTermsAndConditions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text(
                                  'Error loading terms and conditions',
                                ));
                          } else if (snapshot.hasData) {
                            final termsAndConditions = snapshot.data!;
                            // Now you can safely access the data
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var section in snapshot.data!.sections)
                                    Section(section.title, section.content),
                                ],
                              ),
                            );
                          } else {
                            return const Center(
                                child: Text('No data available'));
                          }
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child:   Text('Cancel',style: GoogleFonts.workSans(
                            color: Colors.red, fontWeight: FontWeight.w600),),
                      ),
                      TextButton(
                        onPressed: () {
                          acceptTermsAndConditions();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Accept',
                          style: GoogleFonts.workSans(
                              color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        child: GetBuilder(
          init: loginController,
          builder: (controller) {
            final bool isRegisteredUser = controller.isRegisteredUser();

            if (isRegisteredUser) {
              isTermsAccepted = true;
            }

            return SingleChildScrollView(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 26.h,
                        width: 60.w,
                        padding: EdgeInsets.only(top: 6.h),
                        child:  Image.asset(
                          'lib/Images/RealOffers1.png', // Replace with your image asset path
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: 8.h),
                      // Phone number form section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Form(
                              key: controller.formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: GoogleFonts.workSans(
                                      // fontFamily: 'Aileron',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D0140),
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: '   +91 1234567890',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            hintStyle:
                                            TextStyle(color: Colors.grey),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                            EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0),
                                          ),
                                          initialValue: '',
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          onChanged: (value) => controller
                                              .updateMobileNumber(value),
                                          validator: (value) =>
                                              utils.validateMobileNumber(
                                                  value.toString()),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      // ✅ FIX: "SEND OTP" now ONLY calls controller.loginPress(),
                      // and waits on it. loginPress() itself validates the form,
                      // shows its own loading state, and pushes the VerifyNumber
                      // (OTP) screen — nothing here jumps ahead to any other
                      // screen. Previously this handler pushed straight to
                      // ImageDisplayScreen (a slideshow) via pushReplacement
                      // BEFORE loginPress even ran (and without awaiting it),
                      // which is why the app appeared to "open directly" without
                      // ever waiting for the OTP to be entered.
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(85.w, 6.h),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: (isTermsAccepted && !controller.isLoading)
                            ? () => controller.loginPress(
                            '${controller.dropdownSelectedValue.substring(controller.dropdownSelectedValue.indexOf('+'))} ${controller.mobileNumber}')
                            : null,
                        child: controller.isLoading
                            ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : Text(
                          'SEND OTP',
                          style: GoogleFonts.workSans(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      // Demo Login Section
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 10),
                      //   child: GestureDetector(
                      //     onTap: controller.isLoading
                      //         ? null
                      //         : controller.demoLogin,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         if (controller.isLoading)
                      //           const CircularProgressIndicator(),
                      //         if (!controller.isLoading) ...[
                      //           const Icon(Icons.person, color: Colors.black),
                      //           const SizedBox(width: 8),
                      //           Text(
                      //             'Demo Login',
                      //             style: GoogleFonts.workSans(
                      //               color: Colors.black,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // Terms and Conditions Checkbox
                      if (!isRegisteredUser)
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isTermsAccepted,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isTermsAccepted = value ?? false;
                                  });
                                },
                              ),
                              Text('I agree   ',
                                  style:
                                  GoogleFonts.workSans(color: Colors.grey)),
                              GestureDetector(
                                onTap: showTermsAndConditionsDialog,
                                child: Text(
                                  'Terms and Conditions',
                                  style: GoogleFonts.workSans(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 6.h,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Image.asset(
                              'lib/Images/RealOffers1.png',
                              height: 5.h,
                              width: 12.w,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Candid Customer',
                              style: GoogleFonts.workSans(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Version $appVersion',
                              style: GoogleFonts.workSans(
                                fontSize: 8.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      persistentFooterButtons: [
        Center(
          child: Text(
            'By Continuing, you agree to Candid offers\nTerms & Conditions and Privacy Policy',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}

class MyWidgets {
  Widget getLargeButton({
    required String title,
    required VoidCallback onPress,
    required Color bgColor,
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          // Adjust the padding as needed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white, // Set the text color to white
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// NOTE: ImageDisplayScreen is kept (in case it's used elsewhere as a
// deliberate onboarding/welcome slideshow), but it is no longer wired into
// the SEND OTP flow — it must never be shown before OTP verification
// succeeds.
class ImageDisplayScreen extends StatefulWidget {
  const ImageDisplayScreen({super.key});

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (Timer timer) {
      setState(() {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
      });
      // Animate to the next page
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });

    // Schedule a delayed task to proceed after the image slider finishes
    Future.delayed(const Duration(seconds: 9), () {});
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              Image.asset('lib/Images/Login OTP 2.png', fit: BoxFit.cover),
              Image.asset('lib/Images/customer-welcome-1 (1).png',
                  fit: BoxFit.cover),
              Image.asset('lib/Images/Login OTP 4.png', fit: BoxFit.cover),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 0 ? Colors.blue : Colors.grey,
                  ),
                ),
                Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 1 ? Colors.blue : Colors.grey,
                  ),
                ),
                Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 2 ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showCircularIndicator(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white, // Set background color to white
        child:   Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black), // Set color of the CircularProgressIndicator
              ),
              SizedBox(height: 8),
              Text(
                'Please Wait...',
                style: GoogleFonts.workSans(color: Colors.black), // Set color of the text
              ),
            ],
          ),
        ),
      );
    },
  );
}

class Section extends StatelessWidget {
  final String title;
  final String content;

  const Section(this.title, this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) // Check if title is not empty
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Aileron',
              fontWeight: FontWeight.w700,
            ),
          ),
        SizedBox(height: 2.h),
        // Render HTML content manually
        buildHtmlContent(content),
        const SizedBox(height: 20),
      ],
    );
  }
  // Manually parse and build HTML content

  Widget buildHtmlContent(String htmlContent) {
    // Create an instance of HtmlUnescape
    final unescape = HtmlUnescape();

    // Remove all HTML tags
    String cleanedContent =
    htmlContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    // Decode HTML entities
    cleanedContent = unescape.convert(cleanedContent);

    // Split cleaned content by newlines
    List<String> paragraphs = cleanedContent.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Text(
          paragraph.trim(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Aileron',
            fontWeight: FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}
