// // import 'dart:async'; // 💡 Timer के लिए
// // import 'dart:io';
// // import 'package:candid_customer/Services/API/AuthServices/AuthConnect.dart';
// // import 'package:candid_customer/main.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../../Utils/Utils.dart';
// //
// // class CreateProfileController extends GetxController {
// //   final formKey = GlobalKey<FormState>();
// //   bool isLoading = false;
// //   bool isEmailVerified = false;
// //   bool isSendingVerification = false;
// //
// //   // 💡 Email verification status check timer
// //   Timer? timer;
// //
// //   final firstNameController = TextEditingController(),
// //       lastNameController = TextEditingController(),
// //       emailController = TextEditingController(),
// //       addressController = TextEditingController();
// //   final addressLine1Controller = TextEditingController();
// //   final addressLine2Controller = TextEditingController();
// //   final pinCodeController = TextEditingController();
// //   final landmarkController = TextEditingController();
// //
// //   List<String> genderList = ['Male', 'Female', 'Other'];
// //   String selectedGender = 'Male';
// //   String selectedDay = '1', selectedMonth = '1', selectedYear = '2000', startYear = '1920';
// //
// //   late String mobileNumber;
// //   XFile? selectedProfilePic;
// //   final User user;
// //   final AdditionalUserInfo additionalUserInfo;
// //
// //   CreateProfileController({
// //     required this.mobileNumber,
// //     required this.user,
// //     required this.additionalUserInfo
// //   });
// //
// //   /// ✅ Function to send verification email
// //   Future<void> sendEmailVerification() async {
// //     try {
// //       if (emailController.text.trim().isEmpty) {
// //         Utils().showSnackBar('Please enter a valid email first!');
// //         return;
// //       }
// //
// //       isSendingVerification = true;
// //       update();
// //
// //       // 💡 1. Update user's email in Firebase (Important before sending link)
// //       await user.updateEmail(emailController.text.trim());
// //       await user.sendEmailVerification();
// //
// //       Utils().showSnackBar('Verification email sent! Please check your inbox.');
// //
// //       // 💡 2. Start checking verification status automatically
// //       startEmailVerificationCheck();
// //
// //     } catch (e) {
// //       Utils().showSnackBar('Error sending verification email: $e');
// //       debugPrint('Email verification error: $e');
// //     } finally {
// //       isSendingVerification = false;
// //       update();
// //     }
// //   }
// //
// //   /// 💡 NEW: Function to start the automatic verification check timer
// //   void startEmailVerificationCheck() {
// //     // अगर timer पहले से चल रहा है तो उसे रोक दें
// //     timer?.cancel();
// //
// //     // हर 3 सेकंड में Firebase से status चेक करें
// //     timer = Timer.periodic(const Duration(seconds: 3), (_) async {
// //       await user.reload(); // Firebase से latest data लाएँ
// //       isEmailVerified = user.emailVerified;
// //
// //       if (isEmailVerified) {
// //         Utils().showSnackBar('Email verified successfully!');
// //         timer?.cancel(); // Verification सफल होने पर timer रोक दें
// //         update(); // UI अपडेट करें
// //       }
// //     });
// //
// //     // UI अपडेट करें ताकि 'Check Verification' बटन 'Checking...' या कुछ और दिखा सके
// //     update();
// //   }
// //
// //   /// 💡 MODIFIED: checkEmailVerified को अब केवल manually reload और SnackBar दिखाने के लिए रखें।
// //   ///   Verification check का मुख्य काम अब timer करेगा।
// //   Future<void> checkEmailVerified() async {
// //     await user.reload();
// //     isEmailVerified = user.emailVerified;
// //     if (isEmailVerified) {
// //       Utils().showSnackBar('Email verified successfully!');
// //       timer?.cancel(); // अगर manual check सफल होता है तो timer रोक दें
// //     } else {
// //       Utils().showSnackBar('Email not yet verified! Keep checking...');
// //       // अगर वेरीफाई नहीं है, तो timer शुरू करें ताकि यह अपने आप चेक होता रहे
// //       startEmailVerificationCheck();
// //     }
// //     update();
// //   }
// //
// //
// //   /// ✅ Modified createProfile: only proceed if verified
// //   Future<void> createProfile() async {
// //     try {
// //       if (formKey.currentState == null || !formKey.currentState!.validate()) {
// //         Utils().showSnackBar('All details must be filled!');
// //         return;
// //       }
// //
// //       if (!isEmailVerified) {
// //         Utils().showSnackBar('Please verify your email before signing up!');
// //         return;
// //       }
// //
// //       // Verification सफल होने पर Timer को बंद कर दें
// //       timer?.cancel();
// //
// //       isLoading = true;
// //       update();
// //
// //       String formattedDOB =
// //           "${selectedYear.padLeft(4, '0')}-${selectedMonth.padLeft(2, '0')}-${selectedDay.padLeft(2, '0')}";
// //
// //       Map<String, dynamic> userData = {
// //         'userFirstName': firstNameController.text.trim(),
// //         // ... (other user data fields)
// //         'userLastName': lastNameController.text.trim(),
// //         'userEmail': emailController.text.trim(),
// //         'userAddress': addressController.text.trim(),
// //         'userMobileNumber': mobileNumber,
// //         'addressLine1': addressLine1Controller.text.trim(),
// //         'addressLine2': addressLine2Controller.text.trim(),
// //         'pinCode': pinCodeController.text.trim(),
// //         'landmark': landmarkController.text.trim(),
// //         'userGender': selectedGender,
// //         'userEmailIsVerified': true, // ✅ verified
// //         'isUserPrimeMember': false,
// //         'userProfileImg': '',
// //         'userDOB': formattedDOB,
// //         'userUid': user.uid,
// //       };
// //
// //       if (selectedProfilePic != null) {
// //         var uploadedFileRef = firebaseStorage.ref().child(
// //             'candidCustomers/${user.uid}/profilePicture.${selectedProfilePic!.path.split('.').last}');
// //         await uploadedFileRef.putFile(File(selectedProfilePic!.path));
// //         userData['userProfileImg'] = await uploadedFileRef.getDownloadURL();
// //       } else {
// //         userData['userProfileImg'] = user.photoURL ??
// //             additionalUserInfo.profile?['picture'] ?? "";
// //       }
// //
// //       await AuthConnect().loginRegisterAccount(
// //         mobileNumber: mobileNumber,
// //         isSignUp: true,
// //         userData: userData,
// //         user: user,
// //         additionalUserInfo: additionalUserInfo,
// //       );
// //
// //       isLoading = false;
// //       update();
// //       await Utils().runWhenLogin(shouldAskForPrimeRecharge: true);
// //     } catch (e) {
// //       isLoading = false;
// //       update();
// //       debugPrint('customer: createProfile | CATCH | e: $e');
// //       Utils().showSnackBar('An error occurred during profile creation.');
// //       rethrow;
// //     }
// //   }
// //
// //   clickProfileImg() async {
// //     selectedProfilePic =
// //     await ImagePicker().pickImage(source: ImageSource.camera);
// //     update();
// //   }
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     if (kDebugMode) {
// //       addressController.text = 'abc, xyz, india';
// //     }
// //
// //     if (additionalUserInfo.providerId == 'google.com') {
// //       var userProfile = additionalUserInfo.profile;
// //       firstNameController.text = userProfile?['given_name'] ?? "";
// //       lastNameController.text = userProfile?['family_name'] ?? "";
// //       emailController.text = userProfile?['email'] ?? "";
// //       // 💡 If user is already verified via social login, set the status
// //       if(user.emailVerified) {
// //         isEmailVerified = true;
// //       }
// //     } else if (user.email != null && user.email!.isNotEmpty) {
// //       emailController.text = user.email!;
// //       // 💡 If user is already verified via email, set the status
// //       if(user.emailVerified) {
// //         isEmailVerified = true;
// //       }
// //     }
// //
// //     update();
// //   }
// //
// //   // 💡 NEW: Dispose the timer when controller is removed
// //   @override
// //   void onClose() {
// //     timer?.cancel();
// //     super.onClose();
// //   }
// //
// //   onChangedYear(String year) => {selectedYear = year, update()};
// //   onChangedMonth(String month) => {selectedMonth = month, update()};
// //   onChangedDay(String day) => {selectedDay = day, update()};
// //
// //   changeSelectedGender(String gender) {
// //     selectedGender = gender;
// //     update();
// //   }
// // }
// //
// //
// //
// //
// //
// //
// // import 'dart:io';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:candid_customer/Controllers/AuthControllers/CreateProfileController.dart';
// // import 'package:datepicker_dropdown/datepicker_dropdown.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/svg.dart';
// // import 'package:get/get.dart';
// // import 'package:sizer/sizer.dart';
// // import '../../Utils/MyWidgets.dart';
// // import '../../main.dart';
// //
// // class CreateProfile extends StatelessWidget {
// //   final String mobileNumber;
// //   final User user;
// //   final AdditionalUserInfo additionalUserInfo;
// //
// //   const CreateProfile({
// //     super.key,
// //     required this.mobileNumber,
// //     required this.user,
// //     required this.additionalUserInfo,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Define a consistent horizontal padding value
// //     const double horizontalPadding = 20.0;
// //
// //     return SafeArea(
// //       child: Scaffold(
// //         body: GetBuilder<CreateProfileController>(
// //           init: CreateProfileController(
// //             mobileNumber: mobileNumber,
// //             user: user,
// //             additionalUserInfo: additionalUserInfo,
// //           ),
// //           builder: (controller) {
// //             // 💡 Check if the timer is currently running for better UI indication
// //             final bool isCheckingAutomatically = controller.timer?.isActive ?? false;
// //
// //             return AnimatedSwitcher(
// //               duration: const Duration(seconds: 1),
// //               child: controller.isLoading
// //                   ? const Center(child: CircularProgressIndicator())
// //                   : SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Container(
// //                       height: 25.h,
// //                       width: 60.w,
// //                       padding: EdgeInsets.only(top: 6.h),
// //                       child: SvgPicture.asset(
// //                         'lib/Images/Group 366.svg',
// //                         fit: BoxFit.fill,
// //                       ),
// //                     ),
// //                     Padding(
// //                       padding: EdgeInsets.only(top: 3.h),
// //                       child: Text(
// //                         'Create Account',
// //                         style: TextStyle(
// //                           fontSize: 20.sp,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(height: 5.h),
// //                     Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
// //                       child: Form(
// //                         key: controller.formKey,
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             _buildTextField(
// //                               controller: controller.firstNameController,
// //                               label: 'Full Name',
// //                               hint: 'Enter full name',
// //                               validator: (value) {
// //                                 if (value == null || value.isEmpty) {
// //                                   return 'Please enter your full name';
// //                                 } else if (value.length < 3) {
// //                                   return 'Min 3 letters required';
// //                                 }
// //                                 return null;
// //                               },
// //                             ),
// //
// //                             // 🔹 EMAIL + VERIFY SECTION
// //                             Column(
// //                               crossAxisAlignment:
// //                               CrossAxisAlignment.start,
// //                               children: [
// //                                 _buildTextField(
// //                                   controller:
// //                                   controller.emailController,
// //                                   label: 'Email',
// //                                   hint: 'Enter email address',
// //                                   enabled: true,
// //                                   keyboardType:
// //                                   TextInputType.emailAddress,
// //                                   validator: (value) {
// //                                     if (value == null ||
// //                                         value.isEmpty) {
// //                                       return 'Please enter your email';
// //                                     }
// //                                     final emailRegExp = RegExp(
// //                                         r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
// //                                     if (!emailRegExp.hasMatch(value)) {
// //                                       return 'Please enter a valid email';
// //                                     }
// //                                     return null;
// //                                   },
// //                                 ),
// //                                 const SizedBox(height: 10),
// //                                 // Need to wrap the Row in Padding if you want it aligned
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(bottom: 16),
// //                                   child: Row(
// //                                     mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       ElevatedButton(
// //                                         onPressed: controller
// //                                             .isSendingVerification || controller.isEmailVerified
// //                                             ? null // 💡 Don't allow re-send if already verified or sending
// //                                             : controller
// //                                             .sendEmailVerification,
// //                                         style: ElevatedButton.styleFrom(
// //                                           backgroundColor:
// //                                           controller.isEmailVerified ? Colors.grey : Colors.black, // 💡 Change color if verified
// //                                         ),
// //                                         child: controller.isEmailVerified
// //                                             ? const Text(
// //                                           'Verified Email',
// //                                           style: TextStyle(color: Colors.white),
// //                                         )
// //                                             : controller
// //                                             .isSendingVerification
// //                                             ? const SizedBox(
// //                                           height: 18,
// //                                           width: 18,
// //                                           child:
// //                                           CircularProgressIndicator(
// //                                             strokeWidth: 2,
// //                                             color: Colors.white,
// //                                           ),
// //                                         )
// //                                             : const Text(
// //                                           'Send Verification Link', // 💡 Updated text for clarity
// //                                           style: TextStyle(color: Colors.white),
// //                                         ),
// //                                       ),
// //
// //                                       // 💡 Check Verification Button
// //                                       ElevatedButton(
// //                                         // 💡 Button is disabled if already verified
// //                                         onPressed: controller.isEmailVerified
// //                                             ? null
// //                                             : controller.checkEmailVerified,
// //                                         style: ElevatedButton.styleFrom(
// //                                           backgroundColor:
// //                                           controller.isEmailVerified
// //                                               ? Colors.green
// //                                               : isCheckingAutomatically // 💡 Show a different color if timer is running
// //                                               ? Colors.blueGrey
// //                                               : Colors.black,
// //                                         ),
// //                                         child: Text(
// //                                           controller.isEmailVerified
// //                                               ? 'Verified ✅'
// //                                               : isCheckingAutomatically
// //                                               ? 'Checking... 🔄' // 💡 Show status while timer is running
// //                                               : 'Check Verification',
// //                                           style: TextStyle(color: Colors.white),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //
// //                               ],
// //                             ),
// //
// //                             _buildTextField(
// //                               controller:
// //                               controller.addressController,
// //                               label: 'Shipping Address',
// //                               hint: 'Enter address',
// //                               keyboardType:
// //                               TextInputType.streetAddress,
// //                               maxLines: 2,
// //                               validator: (address) {
// //                                 if (address == null ||
// //                                     address.isEmpty) {
// //                                   return 'Address should not be empty!';
// //                                 } else if (address.length < 10) {
// //                                   return 'Min 10 characters are required!';
// //                                 }
// //                                 return null;
// //                               },
// //                             ),
// //                             _buildTextField(
// //                               controller:
// //                               controller.addressLine1Controller,
// //                               label: 'Address line 1',
// //                               hint: 'Enter address',
// //                               keyboardType:
// //                               TextInputType.streetAddress,
// //                               maxLines: 2,
// //                               validator: (address) {
// //                                 if (address == null ||
// //                                     address.isEmpty) {
// //                                   return 'Address should not be empty!';
// //                                 } else if (address.length < 10) {
// //                                   return 'Min 10 characters are required!';
// //                                 }
// //                                 return null;
// //                               },
// //                             ),
// //                             _buildTextField(
// //                               controller:
// //                               controller.addressLine2Controller,
// //                               label: 'Address line 2',
// //                               hint: 'Enter address',
// //                               keyboardType:
// //                               TextInputType.streetAddress,
// //                               maxLines: 2,
// //                               validator: (address) {
// //                                 if (address == null ||
// //                                     address.isEmpty) {
// //                                   return 'Address should not be empty!';
// //                                 } else if (address.length < 10) {
// //                                   return 'Min 10 characters are required!';
// //                                 }
// //                                 return null;
// //                               },
// //                             ),
// //                             _buildTextField(
// //                               controller:
// //                               controller.landmarkController,
// //                               label: 'Near landmark',
// //                               hint: 'Enter landmark',
// //                               keyboardType:
// //                               TextInputType.streetAddress,
// //                               validator: (address) {
// //                                 if (address == null ||
// //                                     address.isEmpty) {
// //                                   return 'Please enter a landmark';
// //                                 }
// //                                 return null;
// //                               },
// //                             ),
// //                             _buildTextField(
// //                               controller:
// //                               controller.pinCodeController,
// //                               label: 'Pincode',
// //                               hint: 'Enter pincode',
// //                               keyboardType: TextInputType.number,
// //                               validator: (pincode) {
// //                                 if (pincode == null ||
// //                                     pincode.isEmpty) {
// //                                   return 'Pincode should not be empty!';
// //                                 } else if (pincode.length != 6) {
// //                                   return 'Pincode must be 6 digits!';
// //                                 }
// //                                 return null;
// //                               },
// //                             ),
// //
// //                             // 🔹 Gender Dropdown
// //                             Column(
// //                               crossAxisAlignment:
// //                               CrossAxisAlignment.start,
// //                               children: [
// //                                 const Text(
// //                                   'Gender',
// //                                   style: TextStyle(
// //                                       color: Color(0xFF0D0140),
// //                                       fontWeight: FontWeight.bold),
// //                                 ),
// //                                 const SizedBox(height: 8),
// //                                 _buildDropdownField(
// //                                   value: controller.selectedGender,
// //                                   items: controller.genderList,
// //                                   onChanged: (String? gender) =>
// //                                       controller
// //                                           .changeSelectedGender(
// //                                           gender!),
// //                                 ),
// //                               ],
// //                             ),
// //
// //                             // 🔹 DOB Picker
// //                             Column(
// //                               crossAxisAlignment:
// //                               CrossAxisAlignment.start,
// //                               children: [
// //                                 const Text(
// //                                   'Date Of Birth',
// //                                   style: TextStyle(
// //                                     color: Color(0xFF0D0140),
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 8),
// //                                 Container(
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius:
// //                                     BorderRadius.circular(10),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.grey
// //                                             .withOpacity(0.4),
// //                                         spreadRadius: 1,
// //                                         blurRadius: 8,
// //                                         offset: const Offset(0, 2),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: Material(
// //                                     color: Colors.white,
// //                                     child: DropdownDatePicker(
// //                                       isExpanded: true,
// //                                       isFormValidator: true,
// //                                       startYear: int.parse(
// //                                           controller.startYear),
// //                                       endYear:
// //                                       DateTime.now().year,
// //                                       width: 10,
// //                                       isDropdownHideUnderline: true,
// //                                       onChangedDay: (day) =>
// //                                           controller.onChangedDay(
// //                                               day!),
// //                                       onChangedMonth: (month) =>
// //                                           controller.onChangedMonth(
// //                                               month!),
// //                                       onChangedYear: (year) =>
// //                                           controller.onChangedYear(
// //                                               year!),
// //                                       dayFlex: 2,
// //                                       monthFlex: 3,
// //                                       boxDecoration: BoxDecoration(
// //                                         color: Colors.white,
// //                                         borderRadius:
// //                                         BorderRadius.circular(
// //                                             10),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //
// //                             // 🔹 SIGN UP BUTTON (Enabled only if verified)
// //                             Center(
// //                               child: ElevatedButton(
// //                                 style: ElevatedButton.styleFrom(
// //                                   minimumSize:
// //                                   Size(MediaQuery.of(context).size.width - (2 * horizontalPadding), 50),
// //                                   backgroundColor:
// //                                   controller.isEmailVerified
// //                                       ? Colors.black
// //                                       : Colors.grey,
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius:
// //                                     BorderRadius.circular(10),
// //                                   ),
// //                                 ),
// //                                 onPressed: controller.isEmailVerified
// //                                     ? controller.createProfile
// //                                     : null,
// //                                 child: const Text(
// //                                   'SIGN UP',
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ]
// //                           // Apply bottom padding to all elements
// //                               .map((e) => Padding(
// //                             padding: const EdgeInsets.only(
// //                                 bottom: 16),
// //                             child: e,
// //                           ))
// //                               .toList(),
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(height: 8.h),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // 🔹 Reusable Widgets (Modified)
// //
// // Widget _buildTextField({
// //   required TextEditingController controller,
// //   required String label,
// //   required String hint,
// //   bool enabled = true,
// //   TextInputType keyboardType = TextInputType.text,
// //   int maxLines = 1,
// //   required String? Function(String?) validator,
// // }) {
// //   return Column(
// //     // 💡 CHANGE 4: Ensure alignment is start within the padded area
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       Text(
// //         label,
// //         style: const TextStyle(
// //             color: Color(0xFF0D0140), fontWeight: FontWeight.bold),
// //       ),
// //       const SizedBox(height: 8),
// //       Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(10),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.2),
// //               spreadRadius: 1,
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: TextFormField(
// //           controller: controller,
// //           enabled: enabled,
// //           autovalidateMode: AutovalidateMode.onUserInteraction,
// //           decoration: InputDecoration(
// //             hintText: hint,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //               borderSide: BorderSide.none,
// //             ),
// //             filled: true,
// //             fillColor: Colors.white,
// //             contentPadding: const EdgeInsets.symmetric(
// //               vertical: 15.0,
// //               horizontal: 10.0,
// //             ),
// //           ),
// //           keyboardType: keyboardType,
// //           maxLines: maxLines,
// //           validator: validator,
// //         ),
// //       ),
// //     ],
// //   );
// // }
// //
// // Widget _buildDropdownField({
// //   required String? value,
// //   required List<String> items,
// //   required void Function(String?) onChanged,
// // }) {
// //   return Container(
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(10),
// //       boxShadow: [
// //         BoxShadow(
// //           color: Colors.grey.withOpacity(0.2),
// //           spreadRadius: 1,
// //           blurRadius: 8,
// //           offset: const Offset(0, 2),
// //         ),
// //       ],
// //     ),
// //     child: DropdownButtonFormField<String>(
// //       value: value,
// //       decoration: InputDecoration(
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(10),
// //           borderSide: BorderSide.none,
// //         ),
// //         filled: true,
// //         fillColor: Colors.white,
// //         contentPadding: const EdgeInsets.symmetric(
// //           vertical: 15.0,
// //           horizontal: 10.0,
// //         ),
// //       ),
// //       icon: const Icon(Icons.keyboard_arrow_down_rounded),
// //       elevation: 16,
// //       dropdownColor: Colors.white,
// //       onChanged: onChanged,
// //       items: items.map<DropdownMenuItem<String>>((String value) {
// //         return DropdownMenuItem<String>(
// //           value: value,
// //           child: Text(value),
// //         );
// //       }).toList(),
// //     ),
// //   );
// // }
//
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:sizer/sizer.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:firebase_auth/firebase_auth.dart';
//
// // Import local dependencies needed for referral logic (adjust paths as needed)
// import 'package:candid_customer/Controllers/ChampionController.dart';
//
//
// // --------------------------- ENUM FOR REFERRAL TYPE ---------------------------
// enum ReferrerType { champion, seller, customer }
//
// // --- Interface for the Referral ID Display Name ---
// // Assuming you have a way to access the current user's UID (e.g., via FirebaseAuth)
//
// class ReferralEntryScreen extends StatefulWidget {
//   const ReferralEntryScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ReferralEntryScreen> createState() => _ReferralEntryScreenState();
// }
//
// class _ReferralEntryScreenState extends State<ReferralEntryScreen> {
//   final TextEditingController referralController = TextEditingController();
//   final ChampionController championController = Get.put(ChampionController());
//   RxBool isReferredBySomeone = false.obs;
//   bool isReferralVerified = false;
//   bool isLoading = false;
//
//   // State variables for Seller and Customer data
//   List<Map<String, dynamic>> sellerList = [];
//   List<Map<String, dynamic>> customerList = [];
//
//   // State to track selected referrer type
//   ReferrerType? selectedReferrerType;
//
//   // Speech-to-Text Variables
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadReferrerData();
//   }
//
//   @override
//   void dispose() {
//     referralController.dispose();
//     _searchController.dispose();
//     _speech.stop();
//     super.dispose();
//   }
//
//   // --- Utility method to format display name (Name and Address/City) ---
//   String _getDisplayName(Map<String, dynamic> data) {
//     final name = data['name'] ?? 'Unknown Name';
//     final address = data['city'];
//
//     if (address != null && address.isNotEmpty && address != 'Address not provided') {
//       return '$name ($address)';
//     }
//     return name;
//   }
//
//   // --- Data Fetching Methods (Copied from original) ---
//   Future<void> _fetchSellers() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('candidVendors')
//           .where('isActive', isEqualTo: true)
//           .get();
//       sellerList = snapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'id': data['vendorId'] ?? doc.id,
//           'name': data['userFullName'] ?? data['vendorName'] ?? 'No Name',
//           'city': data['userAddressCity'] ?? data['city'] ?? 'Address not provided',
//         };
//       }).toList();
//     } catch (e) {
//       debugPrint('Error fetching sellers: $e');
//     }
//   }
//
//   Future<void> _fetchCustomers() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('candidCustomers')
//           .where('isUserPrimeMember', isEqualTo: true)
//           .get();
//       customerList = snapshot.docs.map((doc) {
//         final data = doc.data();
//         final fullName =
//         '${data['userFirstName'] ?? ''} ${data['userLastName'] ?? ''}'.trim();
//         return {
//           'id': data['userUid'] ?? doc.id,
//           'name': fullName.isNotEmpty ? fullName : 'No Name',
//           'city': data['userAddress'] ?? 'Address not provided',
//         };
//       }).toList();
//     } catch (e) {
//       debugPrint('Error fetching customers: $e');
//     }
//   }
//
//   Future<void> _loadReferrerData() async {
//     // Initial fetch for Champions (via controller), Sellers, and Customers
//     championController.getChampionsList(); // Assuming this is asynchronous or handles its own state
//     await _fetchSellers();
//     await _fetchCustomers();
//     if (mounted) setState(() {});
//   }
//
//   // Method to start/stop listening for voice input (Copied from original)
//   void _startStopListening(Function(String) onResult) async {
//     // ... (Your implementation of _startStopListening remains the same)
//     if (_isListening) {
//       _speech.stop();
//       setState(() => _isListening = false);
//       return;
//     }
//
//     bool available = await _speech.initialize(
//       onError: (val) => debugPrint('STT Error: $val'),
//       onStatus: (val) {
//         if (val == 'done' || val == 'notListening') {
//           setState(() => _isListening = false);
//         }
//       },
//     );
//
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         onResult: (result) {
//           String recognizedWords = result.recognizedWords;
//           onResult(recognizedWords);
//
//           if (result.finalResult) {
//             _speech.stop();
//             setState(() => _isListening = false);
//           }
//         },
//         listenFor: const Duration(seconds: 10),
//         pauseFor: const Duration(seconds: 3),
//       );
//     } else {
//       setState(() => _isListening = false);
//       Fluttertoast.showToast(
//         msg: "Speech recognition not available or permission denied.",
//         backgroundColor: Colors.red,
//       );
//     }
//   }
//
//   // --- Referral Verification Logic (Copied from original) ---
//   Future<void> verifyReferral(BuildContext context) async {
//     if (referralController.text.trim().isEmpty || selectedReferrerType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please select a referrer and ensure the ID is set."),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       String referrerTypeString = selectedReferrerType == ReferrerType.champion
//           ? 'champion'
//           : selectedReferrerType == ReferrerType.seller
//           ? 'vendor'
//           : 'customer';
//
//       final response = await http.post(
//         Uri.parse(
//             'https://candidoffers.com:3636/api/firebase/prime-customer/referral-transaction'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'userUid': FirebaseAuth.instance.currentUser?.uid ?? '',
//           'referralId': referralController.text.trim(),
//           'referrerType': referrerTypeString,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {
//           isReferralVerified = true;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Referral verified successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         final errorResponse = jsonDecode(response.body);
//         String errorMessage = errorResponse['message'] ?? 'Verification failed';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("An error occurred while verifying the referral. Please try again."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --- Build Widgets (Copied and adapted from original) ---
//
//   // --- Referrer Type Selector Widget ---
//   Widget _buildReferrerTypeSelector() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Who referred you?',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.black54,
//             ),
//           ),
//           SizedBox(height: 1.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: ReferrerType.values.map((type) {
//               return Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: ChoiceChip(
//                     label: Text(
//                       type.name.capitalizeFirst!,
//                       style: TextStyle(
//                         color: selectedReferrerType == type
//                             ? Colors.white
//                             : Colors.blue[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     selected: selectedReferrerType == type,
//                     selectedColor: Colors.blue[700],
//                     backgroundColor: Colors.white,
//                     side: BorderSide(
//                       color: selectedReferrerType == type
//                           ? Colors.blue[700]!
//                           : Colors.grey[300]!,
//                     ),
//                     onSelected: (bool selected) {
//                       if (selected) {
//                         championController.selectedChampionId.value = '';
//                         referralController.clear();
//                         setState(() {
//                           selectedReferrerType = type;
//                           isReferralVerified = false;
//                         });
//                       }
//                     },
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- Dropdown Widget to handle all types (Name and City/Address) ---
//   Widget _buildReferrerDropdown() {
//     if (selectedReferrerType == null) {
//       return const SizedBox.shrink();
//     }
//
//     List<Map<String, dynamic>> itemsList = [];
//     String hintText = '';
//     String searchHint = '';
//
//     // Use championController.championList for Champion, and local lists for others
//     if (selectedReferrerType == ReferrerType.champion) {
//       itemsList = championController.championList.toList();
//       hintText = 'Select a Champion (Name/City)';
//       searchHint = "Search Champion by Name or City";
//     } else if (selectedReferrerType == ReferrerType.seller) {
//       itemsList = sellerList;
//       hintText = 'Select a Seller (Name/Address)';
//       searchHint = "Search Seller by Name or Address";
//     } else if (selectedReferrerType == ReferrerType.customer) {
//       itemsList = customerList;
//       hintText = 'Select a Prime Customer (Name/Address)';
//       searchHint = "Search Customer by Name or Address";
//     }
//
//     Map<String, dynamic>? selectedItem;
//     // Find the currently selected item if the ID is set
//     if (championController.selectedChampionId.value.isNotEmpty) {
//       selectedItem = itemsList.firstWhereOrNull(
//             (item) => item['id'] == championController.selectedChampionId.value,
//       );
//     }
//
//     return DropdownSearch<Map<String, dynamic>>(
//       items: itemsList,
//       selectedItem: selectedItem,
//       itemAsString: _getDisplayName,
//       onChanged: (Map<String, dynamic>? referrer) {
//         if (referrer != null) {
//           // Update the GetX controller and local text field
//           championController.selectedChampionId.value = referrer['id'];
//           referralController.text = referrer['id'];
//           setState(() {
//             isReferralVerified = false;
//           });
//         }
//       },
//       compareFn: (item1, item2) => item1['id'] == item2['id'],
//       dropdownDecoratorProps: DropDownDecoratorProps(
//         dropdownSearchDecoration: InputDecoration(
//           hintText: hintText,
//           filled: true,
//           fillColor: Colors.grey[50],
//           contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//       popupProps: PopupProps.modalBottomSheet(
//         showSelectedItems: true,
//         showSearchBox: true,
//         searchFieldProps: TextFieldProps(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: searchHint,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _isListening ? Icons.mic : Icons.mic_none,
//                 color: _isListening ? Colors.red : Colors.grey[600],
//               ),
//               onPressed: () {
//                 // Toggle listening state
//                 _startStopListening((recognizedWords) {
//                   _searchController.text = recognizedWords;
//                 });
//               },
//             ),
//           ),
//         ),
//         // Item Filter is commented out in your original, but included here for completeness:
//         // itemFilter: (item, search) {
//         //   final query = search.toLowerCase();
//         //   final name = item['name']?.toLowerCase() ?? '';
//         //   final city = item['city']?.toLowerCase() ?? '';
//         //   return name.contains(query) || city.contains(query);
//         // },
//       ),
//     );
//   }
//
//   Widget _buildVerifyButton() {
//     if (isReferralVerified) {
//       return Container(
//         padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
//         decoration: BoxDecoration(
//           color: Colors.green[50],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.green, width: 1.5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 20),
//             SizedBox(width: 2.w),
//             const Text(
//               'Referral Verified',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (selectedReferrerType == null || referralController.text.isEmpty) {
//       return SizedBox(
//         height: 5.h,
//         child: ElevatedButton.icon(
//           onPressed: null,
//           icon: const Icon(Icons.verified_outlined, size: 18),
//           label: const Text(
//             'Verify Code',
//             style: TextStyle(fontSize: 14),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.grey[400],
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       );
//     }
//     return SizedBox(
//       height: 5.h,
//       child: ElevatedButton.icon(
//         onPressed: isLoading ? null : () => verifyReferral(context),
//         icon: isLoading
//             ? const SizedBox(
//           width: 15,
//           height: 15,
//           child: CircularProgressIndicator(
//             color: Colors.white,
//             strokeWidth: 2,
//           ),
//         )
//             : const Icon(Icons.verified_outlined, size: 18),
//         label: const Text(
//           'Verify Code',
//           style: TextStyle(fontSize: 14),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue[700],
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Container(
//       padding: EdgeInsets.all(3.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Obx(() => Checkbox(
//                 value: isReferredBySomeone.value,
//                 onChanged: (bool? value) {
//                   isReferredBySomeone.value = value ?? false;
//                   if (!isReferredBySomeone.value) {
//                     selectedReferrerType = null;
//                     championController.selectedChampionId.value = '';
//                     referralController.clear();
//                     setState(() {
//                       isReferralVerified = false;
//                     });
//                   } else {
//                     selectedReferrerType = ReferrerType.champion;
//                   }
//                 },
//                 activeColor: Colors.blue[700],
//               )),
//               const Text(
//                 'Referred by someone?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           Obx(() => isReferredBySomeone.value
//               ? Column(
//             children: [
//               SizedBox(height: 2.h),
//               _buildReferrerTypeSelector(),
//               SizedBox(height: 2.h),
//               _buildReferrerDropdown(),
//               if (!isReferralVerified) ...[
//                 SizedBox(height: 2.h),
//                 TextField(
//                   controller: referralController,
//                   enabled: !isReferralVerified,
//                   readOnly: true, // ID is selected via dropdown
//                   decoration: InputDecoration(
//                     hintText: 'Referral ID (Selected automatically)',
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 1.h),
//                 _buildVerifyButton(),
//               ],
//               SizedBox(height: 1.h),
//             ],
//           )
//               : const SizedBox.shrink()),
//         ],
//       ),
//     );
//   }
// }


