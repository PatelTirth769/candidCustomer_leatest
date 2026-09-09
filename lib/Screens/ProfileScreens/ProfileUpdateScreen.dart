import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../../Controllers/ProfileController.dart';
import '../../Services/Collections/User/UserColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:   Text(
          'Your Profile',
          style: GoogleFonts.workSans(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder(
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => controller.clickProfileImg(context),
                          child: CircleAvatar(
                            radius: 86,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipOval(
                                child: controller.selectedProfilePic != null
                                    ? Image.file(
                                  File(controller.selectedProfilePic!.path),
                                  fit: BoxFit.fill,
                                  height: 172, // Adjusted to match radius
                                  width: 172,
                                )
                                    : CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  height: 172, // Adjusted to match radius
                                  width: 172,
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                                  imageUrl: user.userProfileImg.isNotEmpty
                                      ? user.userProfileImg
                                      : 'https://png.pngtree.com/png-vector/20190710/ourmid/pngtree-user-vector-avatar-png-image_1541962.jpg',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Form(
                            key: controller.formKey,
                            child: SizedBox(
                              width: 90.w,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: controller.firstNameController,
                                    label: 'Name',
                                    hint: 'Enter your name',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      } else if (value.length < 3) {
                                        return 'Min 3 letters required';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey),
                                      onPressed: () {
                                        // Handle pencil icon click if needed
                                      },
                                    ),
                                  ),
                                  _buildTextField(
                                    controller: controller.addressController,
                                    label: 'Shipping Address',
                                    hint: 'Enter your address',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      } else if (value.length < 3) {
                                        return 'Min 3 letters required';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey),
                                      onPressed: () {
                                        // Handle pencil icon click if needed
                                      },
                                    ),
                                  ),
                                  _buildTextField(
                                    controller: controller.addressLine1Controller,
                                    label: 'Address 1 ',
                                    hint: 'Enter address',
                                    keyboardType: TextInputType.streetAddress,
                                    maxLines: 2,
                                    validator: (address) {
                                      if (address!.isEmpty) {
                                        return 'Address should not be empty!';
                                      } else if (address.length < 10) {
                                        return 'Min 10 characters are required!';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey),
                                      onPressed: () {
                                        // Handle pencil icon click if needed
                                      },
                                    ),
                                  ),
                                  _buildTextField(
                                    controller: controller.addressLine2Controller,
                                    label: 'Address 2',
                                    hint: 'Enter address',
                                    keyboardType: TextInputType.streetAddress,
                                    maxLines: 2,
                                    validator: (address) {
                                      if (address!.isEmpty) {
                                        return 'Address should not be empty!';
                                      } else if (address.length < 10) {
                                        return 'Min 10 characters are required!';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey),
                                      onPressed: () {
                                        // Handle pencil icon click if needed
                                      },
                                    ),
                                  ),
                                  _buildTextField(
                                    controller: controller.landmarkController,
                                    label: 'Near landmark',
                                    hint: 'Enter address',
                                    keyboardType: TextInputType.streetAddress,
                                    maxLines: 2,
                                    validator: (address) {
                                      if (address!.isEmpty) {
                                        return 'Address should not be empty!';
                                      } else if (address.length < 10) {
                                        return 'Min 10 characters are required!';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey),
                                      onPressed: () {
                                        // Handle pencil icon click if needed
                                      },
                                    ),
                                  ),
                                  _buildTextField(
                                    controller: controller.pinCodeController,
                                    label: 'Pincode',
                                    hint: 'Enter pincode',
                                    keyboardType: TextInputType.streetAddress,
                                    maxLines: 2,
                                    validator: (address) {
                                      if (address!.isEmpty) {
                                        return 'pincode should not be empty!';
                                      } else if (address.length < 6) {
                                        return 'Min 6 characters are required!';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey),
                                      onPressed: () {
                                        // Handle pencil icon click if needed
                                      },
                                    ),
                                  ),
                                  _buildTextField(
                                    controller: controller.emailController,
                                    label: 'Email',
                                    hint: 'Enter your email',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      // Direct regex check
                                      final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                      if (!emailRegExp.hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },

                                    enabled: false, // Make email field non-editable
                                  ),
                                  SizedBox(height: 1.h),
                                  MyWidgets().getLargeButton(
                                    title: 'Update Profile',
                                    onPress: controller.updateProfile,
                                    bgColor: const Color(0xFFF01717),
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 1.h),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'lib/Images/RealOffers1.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Candid Customer',
                                          style: TextStyle(
                                            fontFamily: 'Aileron',
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        // Text(
                                        //   ' • v1.0.12',
                                        //   style: TextStyle(
                                        //     fontFamily: 'Aileron',
                                        //     fontSize: 12.sp,
                                        //     color: Colors.grey,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ].map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: e,
                                )).toList(),


                              ),
                            ),
                          ),

                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),

                ),

              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool enabled = true,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  required String? Function(String?) validator,
  Widget? suffixIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style:   GoogleFonts.workSans(
          color: Color(0xFF0D0140),
          fontWeight: FontWeight.bold, // Optional: make label bold
        ),
      ),
      const SizedBox(height: 8), // Space between label and text field
      TextFormField(
        controller: controller,
        enabled: enabled,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding as needed
          suffixIcon: suffixIcon, // Add the pencil icon here
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        readOnly: !enabled, // Make the field read-only when not enabled
      ),
    ],
  );
}
