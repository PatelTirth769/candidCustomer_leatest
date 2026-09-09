// import 'dart:io';
// import 'package:candid_customer/Services/API/AuthServices/AuthConnect.dart';
// import 'package:candid_customer/main.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../Utils/Utils.dart';
//
// class CreateProfileController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   final firstNameController = TextEditingController(),
//       lastNameController = TextEditingController(),
//       emailController = TextEditingController(),
//       addressController = TextEditingController();
//   final addressLine1Controller = TextEditingController();
//   final addressLine2Controller = TextEditingController();
//   final pinCodeController = TextEditingController();
//   final landmarkController = TextEditingController();
//   List<String> genderList = ['Male', 'Female', 'Other'];
//   String selectedGender = 'Male';
//   String selectedDay = '1',
//       selectedMonth = '1',
//       selectedYear = '2000',
//       startYear = '1920';
//   late String mobileNumber;
//   XFile? selectedProfilePic;
//   final User user;
//   final AdditionalUserInfo additionalUserInfo;
//
//   CreateProfileController(
//       {required this.mobileNumber,
//         required this.user,
//         required this.additionalUserInfo});
//
//   Future<void> createProfile() async {
//     try {
//       if (formKey.currentState == null || !formKey.currentState!.validate()) {
//         Utils().showSnackBar('All details must be filled!');
//         return;
//       }
//       isLoading = true;
//       update();
//
//       // Format the date as "yyyy-MM-dd"
//       String formattedDOB = "${selectedYear.padLeft(4, '0')}-${selectedMonth.padLeft(2, '0')}-${selectedDay.padLeft(2, '0')}";
//
//       Map<String, dynamic> userData = {
//         'userFirstName': firstNameController.text.trim(),
//         'userLastName': lastNameController.text.trim() ?? "",
//         'userEmail': emailController.text.trim(),
//         'userAddress': addressController.text.trim(),
//         'userMobileNumber': mobileNumber ?? "",
//         'addressLine1': addressLine1Controller.text.trim(),
//         'addressLine2': addressLine2Controller.text.trim(),
//         'pinCode': pinCodeController.text.trim(),
//         'landmark': landmarkController.text.trim(),
//         'userGender': selectedGender ?? "",
//         'userEmailIsVerified': false,
//         'isUserPrimeMember': false,
//         'userProfileImg': '',
//         'userDOB': formattedDOB,
//         'userUid': user.uid,
//       };
//
//       if (selectedProfilePic != null) {
//         var uploadedFileRef = firebaseStorage.ref().child(
//             'candidCustomers/${user.uid}/profilePicture.${selectedProfilePic!.path.split('.').last}');
//         await uploadedFileRef.putFile(File(selectedProfilePic!.path));
//         userData['userProfileImg'] = await uploadedFileRef.getDownloadURL();
//       } else {
//         userData['userProfileImg'] = user.photoURL ?? additionalUserInfo.profile?['picture'] ?? "";
//       }
//
//       await AuthConnect().loginRegisterAccount(
//         mobileNumber: mobileNumber ?? "",
//         isSignUp: true,
//         userData: userData,
//         user: user,
//         additionalUserInfo: additionalUserInfo,
//       );
//
//       isLoading = false;
//       update();
//
//       await Utils().runWhenLogin(shouldAskForPrimeRecharge: true);
//     } catch (e) {
//       isLoading = false;
//       update();
//       debugPrint('customer: createProfile | CATCH | e: $e');
//       Utils().showSnackBar('An error occurred during profile creation.');
//       rethrow;
//     }
//   }
//
//
//   clickProfileImg() async {
//     selectedProfilePic =
//     await ImagePicker().pickImage(source: ImageSource.camera);
//     update();
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     if (kDebugMode) {
//       // firstNameController.text = 'first name 1';
//       // lastNameController.text = 'last name 1';
//       // emailController.text = 'deven.chavda@preeshe.com';
//       addressController.text = 'abc, xyz, india';
//       selectedMonth = "1";
//       selectedDay = "1";
//       selectedYear = "2000";
//     }
//     if (additionalUserInfo.providerId == 'google.com') {
//       var userProfile = additionalUserInfo.profile;
//       firstNameController.text = userProfile?['given_name'] ?? "";
//       lastNameController.text = userProfile?['family_name'] ?? "";
//       emailController.text = userProfile?['email'] ?? "";
//     }
//     update();
//   }
//
//   onChangedYear(String year) =>
//       {selectedYear = year, update(), debugPrint('year: $year')};
//
//   onChangedMonth(String month) =>
//       {selectedMonth = month, update(), debugPrint('month: $month')};
//
//   onChangedDay(String day) =>
//       {selectedDay = day, update(), debugPrint('day: $day')};
//
//   changeSelectedGender(String gender) {
//     selectedGender = gender;
//     update();
//   }
// }
//




import 'dart:io';
import 'package:candid_customer/Services/API/AuthServices/AuthConnect.dart';
import 'package:candid_customer/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../Utils/Utils.dart';

class CreateProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final firstNameController = TextEditingController(),
      lastNameController = TextEditingController(),
      emailController = TextEditingController(),
      addressController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final pinCodeController = TextEditingController();
  final landmarkController = TextEditingController();

  List<String> genderList = ['Male', 'Female', 'Other'];
  String selectedGender = 'Male';
  String selectedDay = '1',
      selectedMonth = '1',
      selectedYear = '2000',
      startYear = '1920';

  late String mobileNumber;
  XFile? selectedProfilePic;
  final User user;
  final AdditionalUserInfo additionalUserInfo;

  CreateProfileController({
    required this.mobileNumber,
    required this.user,
    required this.additionalUserInfo
  });

  Future<void> createProfile() async {
    try {
      if (formKey.currentState == null || !formKey.currentState!.validate()) {
        Utils().showSnackBar('All details must be filled!');
        return;
      }

      // Check if email is provided
      if (emailController.text.trim().isEmpty) {
        Utils().showSnackBar('Email is required!');
        return;
      }

      isLoading = true;
      update();

      // Format the date as "yyyy-MM-dd"
      String formattedDOB = "${selectedYear.padLeft(4, '0')}-${selectedMonth.padLeft(2, '0')}-${selectedDay.padLeft(2, '0')}";

      Map<String, dynamic> userData = {
        'userFirstName': firstNameController.text.trim(),
        'userLastName': lastNameController.text.trim(),
        'userEmail': emailController.text.trim(), // Email will always be saved
        'userAddress': addressController.text.trim(),
        'userMobileNumber': mobileNumber,
        'addressLine1': addressLine1Controller.text.trim(),
        'addressLine2': addressLine2Controller.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'landmark': landmarkController.text.trim(),
        'userGender': selectedGender,
        'userEmailIsVerified': false,
        'isUserPrimeMember': false,
        'userProfileImg': '',
        'userDOB': formattedDOB,
        'userUid': user.uid,
      };

      if (selectedProfilePic != null) {
        var uploadedFileRef = firebaseStorage.ref().child(
            'candidCustomers/${user.uid}/profilePicture.${selectedProfilePic!.path.split('.').last}');
        await uploadedFileRef.putFile(File(selectedProfilePic!.path));
        userData['userProfileImg'] = await uploadedFileRef.getDownloadURL();
      } else {
        userData['userProfileImg'] = user.photoURL ??
            additionalUserInfo.profile?['picture'] ?? "";
      }

      await AuthConnect().loginRegisterAccount(
        mobileNumber: mobileNumber,
        isSignUp: true,
        userData: userData,
        user: user,
        additionalUserInfo: additionalUserInfo,
      );

      isLoading = false;
      update();
      await Utils().runWhenLogin(shouldAskForPrimeRecharge: true);
    } catch (e) {
      isLoading = false;
      update();
      debugPrint('customer: createProfile | CATCH | e: $e');
      Utils().showSnackBar('');
      rethrow;
    }
  }

  clickProfileImg() async {
    selectedProfilePic = await ImagePicker().pickImage(source: ImageSource.camera);
    update();
  }

  @override
  void onInit() {
    super.onInit();

    if (kDebugMode) {
      addressController.text = 'abc, xyz, india';
      selectedMonth = "1";
      selectedDay = "1";
      selectedYear = "2000";
    }

    // Pre-fill email if available from Google sign-in
    if (additionalUserInfo.providerId == 'google.com') {
      var userProfile = additionalUserInfo.profile;
      firstNameController.text = userProfile?['given_name'] ?? "";
      lastNameController.text = userProfile?['family_name'] ?? "";
      emailController.text = userProfile?['email'] ?? "";
    } else if (user.email != null && user.email!.isNotEmpty) {
      // Pre-fill email from Firebase user if available
      emailController.text = user.email!;
    }
    // If no email is pre-filled, user will need to enter it manually

    update();
  }

  onChangedYear(String year) => {
    selectedYear = year,
    update(),
    debugPrint('year: $year')
  };

  onChangedMonth(String month) => {
    selectedMonth = month,
    update(),
    debugPrint('month: $month')
  };

  onChangedDay(String day) => {
    selectedDay = day,
    update(),
    debugPrint('day: $day')
  };

  changeSelectedGender(String gender) {
    selectedGender = gender;
    update();
  }
}
