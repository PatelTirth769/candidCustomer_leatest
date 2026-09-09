// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../Controllers/AuthControllers/VerifyMobileController.dart';
// import '../../main.dart';
//
// class VerifyNumber extends StatelessWidget {
//   final String mobileNumber;
//   final bool isSignInProcess;
//
//   const VerifyNumber({
//     Key? key,
//     required this.mobileNumber,
//     required this.isSignInProcess,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         try {
//           await utils.logOutUser();
//           return true;
//         } catch (e) {
//           return false;
//         }
//       },
//       child: Scaffold(
//         // Add resizeToAvoidBottomInset to handle keyboard properly
//         resizeToAvoidBottomInset: true,
//         body: SafeArea(
//           child: GetBuilder(
//             init: VerifyMobileController(
//               mobileNumber: mobileNumber,
//               isSignInProcess: isSignInProcess,
//             ),
//             builder: (VerifyMobileController controller) {
//               return AnimatedSwitcher(
//                 duration: const Duration(seconds: 1),
//                 child: controller.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _buildMainContent(controller),
//               );
//             },
//           ),
//         ),
//         persistentFooterButtons:  [
//           Center(
//             child: Text(
//               'By Continuing, you agree to Candid offers\nTerms & Conditions and Privacy Policy',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 10.sp,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainContent(VerifyMobileController controller) {
//     return SingleChildScrollView(
//       // Add keyboardDismissBehavior to handle keyboard dismiss on scroll
//       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//       child: Center(
//         child: FractionallySizedBox(
//           widthFactor: 0.90,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Logo
//               Center(
//                 child: Container(
//                   height: 26.h,
//                   width: 65.w,
//                   padding: EdgeInsets.only(top: 6.h),
//                   child: SvgPicture.asset(
//                     'lib/Images/Group 366.svg',
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12.h),
//
//               // OTP Form
//               Form(
//                 key: controller.formKey,
//                 child: Column(
//                   children: [
//                     _buildOTPFields(controller),
//                     SizedBox(height: 2.h),
//                     _buildResendSection(controller),
//                     if (firebaseAuth.currentUser == null)
//                       _buildVerifyButton(controller),
//                   ],
//                 ),
//               ),
//
//               // Google Sign In Button
//               SizedBox(height: 1.h),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Center(
//                   child: Opacity(
//                     opacity: firebaseAuth.currentUser != null ? 1 : 0.3,
//                     child: InkWell(
//                       onTap: controller.handleGoogleSignIn,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.black, width: 1),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SvgPicture.asset(
//                               'lib/Images/google (1).svg',
//                               height: 5.h,
//                               fit: BoxFit.fill,
//                             ),
//                             SizedBox(width: 6.w), // Space between the icon and text
//                             const Text(
//                               'SIGN IN WITH GOOGLE',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               // Candid Customer Section
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         'lib/Images/candid1.png',
//                         height: 5.h,
//                         width: 12.w,
//                       ),
//                       SizedBox(height: 1.h),
//                       Text(
//                         'Candid Customer',
//                         style: TextStyle(
//                           fontSize: 10.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Text(
//                         'Version v1.1.0.12',
//                         style: TextStyle(
//                           fontSize: 8.sp,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildOTPFields(VerifyMobileController controller) {
//     final controllers = [
//       controller.otp1Controller,
//       controller.otp2Controller,
//       controller.otp3Controller,
//       controller.otp4Controller,
//       controller.otp5Controller,
//       controller.otp6Controller,
//     ];
//
//     final focusNodes = [
//       controller.focus1,
//       controller.focus2,
//       controller.focus3,
//       controller.focus4,
//       controller.focus5,
//       controller.focus6,
//     ];
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(
//         6,
//         (index) => Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: TextFormField(
//               controller: controllers[index],
//               focusNode: focusNodes[index],
//               enabled: firebaseAuth.currentUser == null,
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.number,
//               maxLength: 1,
//               autofocus: index == 0,
//               showCursor: true,
//               style: const TextStyle(
//                 fontSize: 24,
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//               ),
//               decoration: InputDecoration(
//                 counterText: '',
//                 hintText: '0',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//               onChanged: (value) {
//                 if (value.length == 1 && index < 5) {
//                   focusNodes[index + 1].requestFocus();
//                 } else if (value.isEmpty && index > 0) {
//                   focusNodes[index - 1].requestFocus();
//                 }
//               },
//               textInputAction: index < 5 ? TextInputAction.next : TextInputAction.done,
//               onFieldSubmitted: (value) {
//                 if (index < 5) {
//                   focusNodes[index + 1].requestFocus();
//                 } else {
//                   controller.verifyOTP();
//                 }
//               },
//               validator: (value) => value?.isEmpty == true ? '' : null,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResendSection(VerifyMobileController controller) {
//     if (firebaseAuth.currentUser != null) return const SizedBox();
//
//     return Column(
//       children: [
//         const Text('Enter the 6 Digit code sent on your number'),
//         SizedBox(height: 2.h),
//         Opacity(
//           opacity: controller.enableResend ? 1 : 0.3,
//           child: TextButton(
//             onPressed: controller.enableResend ? controller.sendOTP : null,
//             child: Text(
//               'Resend Code ${controller.secondsRemaining > 0 ? '(${controller.secondsRemaining}s)' : ''}',
//               style: const TextStyle(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVerifyButton(VerifyMobileController controller) {
//     return Center(
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           minimumSize: const Size(335, 50),
//           backgroundColor: Colors.black,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         onPressed: controller.verifyOTP,
//         child: const Text(
//           'VERIFY',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../Controllers/AuthControllers/VerifyMobileController.dart';
import '../../main.dart';

class VerifyNumber extends StatelessWidget {
  final String mobileNumber;
  final bool isSignInProcess;

  const VerifyNumber({
    Key? key,
    required this.mobileNumber,
    required this.isSignInProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          await utils.logOutUser();
          return true;
        } catch (e) {
          return false;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: GetBuilder<VerifyMobileController>(
            init: VerifyMobileController(
              mobileNumber: mobileNumber,
              isSignInProcess: isSignInProcess,
            ),
            builder: (VerifyMobileController controller) {
              return AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMainContent(controller),
              );
            },
          ),
        ),
        persistentFooterButtons: [
          Center(
            child: Text(
              'By Continuing, you agree to Candid offers\nTerms & Conditions and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(VerifyMobileController controller) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Container(
                  height: 26.h,
                  width: 60.w,
                  padding: EdgeInsets.only(top: 6.h),
                  child:  Image.asset(
                    'lib/Images/RealOffers1.png', // Replace with your image asset path
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // OTP Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    _buildOTPFields(controller),
                    SizedBox(height: 2.h),
                    _buildResendSection(controller),
                    SizedBox(height: 3.h),
                    _buildVerifyButton(controller),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Candid Customer Section
              Center(
                child: Container(
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
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Version v1.1.0.12',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPFields(VerifyMobileController controller) {
    final controllers = [
      controller.otp1Controller,
      controller.otp2Controller,
      controller.otp3Controller,
      controller.otp4Controller,
      controller.otp5Controller,
      controller.otp6Controller,
    ];

    final focusNodes = [
      controller.focus1,
      controller.focus2,
      controller.focus3,
      controller.focus4,
      controller.focus5,
      controller.focus6,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextFormField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              autofocus: index == 0,
              showCursor: true,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '0',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              },
              textInputAction:
                  index < 5 ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted: (value) {
                if (index < 5) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  controller.verifyOTP();
                }
              },
              validator: (value) => value?.isEmpty == true ? '' : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection(VerifyMobileController controller) {
    return Column(
      children: [
        const Text('Enter the 6 Digit code sent on your number'),
        SizedBox(height: 2.h),
        Opacity(
          opacity: controller.enableResend ? 1 : 0.3,
          child: TextButton(
            onPressed: controller.enableResend ? controller.sendOTP : null,
            child: Text(
              'Resend Code ${controller.secondsRemaining > 0 ? '(${controller.secondsRemaining}s)' : ''}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton(VerifyMobileController controller) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(335, 50),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: controller.verifyOTP,
        child: const Text(
          'VERIFY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
