import 'dart:io';
import 'package:candid_customer/Services/API/AuthServices/AuthConnect.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../Services/Collections/User/UserColl.dart';

class ProfileController extends GetxController {
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
      selectedYear = '1920',
      startYear = '1920';
  XFile? selectedProfilePic;

  openModalForPrimeNonPrime({required UserColl user}) {
    showGeneralDialog(
      context: navigatorKey.currentContext!,
      transitionBuilder: (context, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: SafeArea(
            child: Dialog(
                insetPadding: EdgeInsets.zero,
                child: SizedBox(
                  height: 70.h,
                  width: 90.w,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Text(
                            user.isUserPrimeMember
                                ? "Features of prime member will be below"
                                : 'Be prime member',
                            textScaleFactor: 1.5,
                            style: const TextStyle(color: Colors.brown)),
                      ),
                      Positioned(
                        right: 0.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const SizedBox(
                            height: 50,
                            width: 50,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.close,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
    );
  }

  updateProfile() async {
    if (!formKey.currentState!.validate()) {
      utils.showSnackBar('All field should be filled');
      return;
    }
    try {
      isLoading = true;
      update();
      Map<String, dynamic> userData = {
        'userFirstName': firstNameController.text.trim(),
        'userLastName': lastNameController.text.trim(),
        'userAddress': addressController.text.trim(),
        'userEmail': emailController.text.trim(),
        'userGender': selectedGender.trim(),
        'addressLine1': addressLine1Controller.text.trim(),
        'addressLine2': addressLine2Controller.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'landmark': landmarkController.text.trim(),
        'userDOB': DateTime.utc(int.parse(selectedYear),
            int.parse(selectedMonth), int.parse(selectedDay))
            .toString()
      };
      if (selectedProfilePic != null) {
        var uploadedFileRef = firebaseStorage.ref().child(
            'candidCustomers/${firebaseAuth.currentUser!.uid}/profilePicture.${selectedProfilePic!.path.split('.').last}');
        await uploadedFileRef.putFile(File(selectedProfilePic!.path));
        userData['userProfileImg'] = await uploadedFileRef.getDownloadURL();
      }
      debugPrint('updateProfile | userData : $userData');

      await AuthConnect()
          .updateUser(userData: userData, shouldShowMessage: true);
      isLoading = false;
      update();
      Navigator.of(navigatorKey.currentContext!).pop();
    } catch (e) {
      isLoading = false;
      update();
      debugPrint('CATCH : update profile | profile-controller $e');
    }
  }

  Future<void> clickProfileImg(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose Image Source'),
            actions: [
              TextButton(
                child: const Text('Camera'),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              TextButton(
                child: const Text('Gallery'),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          );
        },
      ),
    );
    if (pickedFile != null) {
      selectedProfilePic = XFile(pickedFile.path);
      update();
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    if (kDebugMode) {
      firstNameController.text = 'first name 1';
      lastNameController.text = 'last name 1';
      emailController.text = 'abc@gmail.com';
      addressController.text = 'abc, xyz, india';
    }
    var localUser =
    (await isar.userColls.get((await utils.getUser() as UserColl).id!))!;

    firstNameController.text = localUser.userFirstName;
    lastNameController.text = localUser.userLastName;
    addressController.text = localUser.userAddress;
    emailController.text = localUser.userEmail;
    addressLine1Controller.text = localUser.addressLine1;
    addressLine2Controller.text = localUser.addressLine2;
    pinCodeController.text = localUser.pinCode;
    landmarkController.text = localUser.landmark;
    selectedGender = localUser.userGender;
    selectedMonth = localUser.userDOB.month.toString();
    selectedDay = localUser.userDOB.day.toString();
    selectedYear = localUser.userDOB.year.toString();
    update();
  }

  onChangedYear(String year) => {selectedYear = year, update()};

  onChangedMonth(String month) => {selectedMonth = month, update()};

  onChangedDay(String day) => {selectedDay = day, update()};

  updateSelectedGender(String gender) {
    selectedGender = gender;
    update();
  }
}
