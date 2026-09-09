// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:candid_customer/Controllers/AuthControllers/CreateProfileController.dart';
// import 'package:datepicker_dropdown/datepicker_dropdown.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../Utils/MyWidgets.dart';
// import '../../main.dart';
//
// class CreateProfile extends StatelessWidget {
//   final String mobileNumber;
//   final User user;
//   final AdditionalUserInfo additionalUserInfo;
//
//   const CreateProfile({super.key,
//     required this.mobileNumber,
//     required this.user,
//     required this.additionalUserInfo});
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//
//         body: GetBuilder(
//           init: CreateProfileController(
//             mobileNumber: mobileNumber,
//             user: user,
//             additionalUserInfo: additionalUserInfo,
//           ),
//           builder: (controller) {
//             return AnimatedSwitcher(
//               duration: const Duration(seconds: 1),
//               child: controller.isLoading
//                   ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//                   : SingleChildScrollView(
//                 child:  Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                   Container(
//                   height: 25.h,
//                   width: 60.w,
//                   padding: EdgeInsets.only(top: 6.h),
//                   child: SvgPicture.asset(
//                     'lib/Images/Group 366.svg', // Path to your SVG asset
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                     Center(
//                       child: Padding(
//                         padding: EdgeInsets.only(top: 3.h),
//                         child: Column(children: [
//                           Text(
//                             'Create Account',
//                             style: TextStyle(
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ]
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 5.h,),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Form(
//                         key: controller.formKey,
//                         child: SizedBox(
//                           width: 90.w,
//                           child: Column(
//                             children: [
//                               _buildTextField(
//                                 controller: controller.firstNameController,
//                                 label: 'Full Name',
//                                 hint: 'Enter full name',
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter some text';
//                                   } else if (value.length < 3) {
//                                     return 'Min 3 letters required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               _buildTextField(
//                                 controller: controller.emailController,
//                                 label: 'Email',
//                                 hint: 'Enter email',
//                                 enabled: false,
//                                 keyboardType: TextInputType.emailAddress,
//                                 validator: (email) => utils.validateEmail(email!),
//                               ),
//                               _buildTextField(
//                                 controller: controller.addressController,
//                                 label: 'Shipping Address',
//                                 hint: 'Enter address',
//                                 keyboardType: TextInputType.streetAddress,
//                                 maxLines: 2,
//                                 validator: (address) {
//                                   if (address!.isEmpty) {
//                                     return 'Address should not be empty!';
//                                   } else if (address.length < 10) {
//                                     return 'Min 10 characters are required!';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               _buildTextField(
//                                 controller: controller.addressLine1Controller,
//                                 label: 'Address line 1 ',
//                                 hint: 'Enter address',
//                                 keyboardType: TextInputType.streetAddress,
//                                 maxLines: 2,
//                                 validator: (address) {
//                                   if (address!.isEmpty) {
//                                     return 'Address should not be empty!';
//                                   } else if (address.length < 10) {
//                                     return 'Min 10 characters are required!';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               _buildTextField(
//                                 controller: controller.addressLine2Controller,
//                                 label: 'Address line 2',
//                                 hint: 'Enter address',
//                                 keyboardType: TextInputType.streetAddress,
//                                 maxLines: 2,
//                                 validator: (address) {
//                                   if (address!.isEmpty) {
//                                     return 'Address should not be empty!';
//                                   } else if (address.length < 10) {
//                                     return 'Min 10 characters are required!';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               _buildTextField(
//                                 controller: controller.landmarkController,
//                                 label: 'Near landmark',
//                                 hint: 'Enter address',
//                                 keyboardType: TextInputType.streetAddress,
//                                 maxLines: 2,
//                                 validator: (address) {
//                                   if (address!.isEmpty) {
//                                     return 'Address should not be empty!';
//                                   } else if (address.length < 10) {
//                                     return 'Min 10 characters are required!';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               _buildTextField(
//                                 controller: controller.pinCodeController,
//                                 label: 'Pincode',
//                                 hint: 'Enter pincode',
//                                 keyboardType: TextInputType.streetAddress,
//                                 maxLines: 2,
//                                 validator: (address) {
//                                   if (address!.isEmpty) {
//                                     return 'pincode should not be empty!';
//                                   } else if (address.length < 6) {
//                                     return 'Min 6 characters are required!';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Gender',
//                                     style: TextStyle(color: Color(0xFF0D0140),fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   _buildDropdownField(
//                                     value: controller.selectedGender,
//                                     items: controller.genderList,
//                                     onChanged: (String? gender) =>
//                                         controller.changeSelectedGender(gender!),
//                                   ),
//                                 ],
//                               ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Date Of Birth',
//                                   style: TextStyle(
//                                     color: Color(0xFF0D0140),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white, // Container background color
//                                     borderRadius: BorderRadius.circular(10), // Rounded corners
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.4), // Shadow color
//                                         spreadRadius: 1,
//                                         blurRadius: 8,
//                                         offset: const Offset(0, 2), // Shadow offset
//                                       ),
//                                     ],
//                                   ),
//                                   child: Material(
//                                     color: Colors.white, // Force white background for dropdown
//                                     child: DropdownDatePicker(
//                                       isExpanded: true,
//                                       isFormValidator: true,
//                                       startYear: int.parse(controller.startYear),
//                                       endYear: DateTime.now().year,
//                                       width: 10,
//                                       isDropdownHideUnderline: true,
//                                       onChangedDay: (day) => controller.onChangedDay(day!),
//                                       onChangedMonth: (month) => controller.onChangedMonth(month!),
//                                       onChangedYear: (year) => controller.onChangedYear(year!),
//                                       dayFlex: 2,
//                                       monthFlex: 3,
//                                       boxDecoration: BoxDecoration(
//                                         color: Colors.white, // Ensure dropdown background is white
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                               Center(
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     minimumSize: const Size(340, 50), // Set your custom width and height
//                                     backgroundColor: Colors.black,   // Background color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: controller.createProfile,
//                                   child: const Text(
//                                     'SIGN UP',
//                                     style: TextStyle(
//                                       color: Colors.white, // Text color
//                                       fontSize: 16,        // Text size
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ].map((e) => Padding(
//                               padding: const EdgeInsets.only(bottom: 16),
//                               child: e,
//                             )).toList(),
//                           )
//                           ,
//                         ),
//                       ),
//
//                     ),
//                      SizedBox(height: 8.h),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// Widget _buildTextField({
//   required TextEditingController controller,
//   required String label,
//   required String hint,
//   bool enabled = true,
//   TextInputType keyboardType = TextInputType.text,
//   int maxLines = 1,
//   required String? Function(String?) validator,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(color: Color(0xFF0D0140),fontWeight: FontWeight.bold
//         ),
//       ),
//       const SizedBox(height: 8),
//       Container(
//         decoration: BoxDecoration(
//           color: Colors.white, // White background
//           borderRadius: BorderRadius.circular(10), // Rounded corners
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2), // Shadow color
//               spreadRadius: 1,
//               blurRadius: 8,
//               offset: const Offset(0, 2), // Offset of the shadow
//             ),
//           ],
//         ),
//         child: TextFormField(
//           controller: controller,
//           enabled: enabled,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 15.0,
//               horizontal: 10.0,
//             ),
//           ),
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           validator: validator,
//         ),
//       ),
//     ],
//   );
// }
//
// // Helper method to build dropdown fields
// Widget _buildDropdownField({
//   required String? value,
//   required List<String> items,
//   required void Function(String?) onChanged,
// }) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.white, // White background
//       borderRadius: BorderRadius.circular(10), // Rounded corners
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.2), // Shadow color
//           spreadRadius: 1,
//           blurRadius: 8,
//           offset: const Offset(0, 2), // Offset of the shadow
//         ),
//       ],
//     ),
//     child: DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 15.0,
//           horizontal: 10.0,
//         ),
//       ),
//       icon: const Icon(Icons.keyboard_arrow_down_rounded),
//       elevation: 16,
//       dropdownColor: Colors.white,
//       onChanged: onChanged,
//       items: items.map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     ),
//   );
// }
// Widget _buildAddressFields(CreateProfileController controller) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _buildTextField(
//         controller: controller.addressLine1Controller,
//         label: 'Address Line 1',
//         hint: 'Enter street address',
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter address line 1';
//           }
//           return null;
//         },
//       ),
//       _buildTextField(
//         controller: controller.addressLine2Controller,
//         label: 'Address Line 2 (Optional)',
//         hint: 'Enter apartment, suite, etc.',
//         validator: (value) => null, // Optional field
//       ),
//       _buildTextField(
//         controller: controller.pinCodeController,
//         label: 'PIN Code',
//         hint: 'Enter PIN code',
//         keyboardType: TextInputType.number,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter PIN code';
//           }
//           if (value.length != 6) {
//             return 'PIN code must be 6 digits';
//           }
//           return null;
//         },
//       ),
//       _buildTextField(
//         controller: controller.landmarkController,
//         label: 'Landmark (Optional)',
//         hint: 'Enter nearby landmark',
//         validator: (value) => null, // Optional field
//       ),
//     ],
//   );
// }

// // Column(
// //   children: [
// //     Row(
// //       mainAxisAlignment:
// //           MainAxisAlignment.center,
// //       children: [
// //         InkWell(
// //           onTap: controller.clickProfileImg,
// //           child: const Text('Change',
// //               textScaleFactor: 1.1,
// //               style: TextStyle(
// //                   color: Colors.pink)),
// //         ),
// //         Visibility(
// //           visible:
// //               controller.selectedProfilePic !=
// //                   null,
// //           child: Row(
// //             children: [
// //               const Text('|',
// //                   textScaleFactor: 1.1,
// //                   style: TextStyle(
// //                       color: Colors.pink)),
// //               InkWell(
// //                 onTap: () {
// //                   controller
// //                           .selectedProfilePic =
// //                       null;
// //                   controller.update();
// //                 },
// //                 child: const Text('Remove',
// //                     textScaleFactor: 1.1,
// //                     style: TextStyle(
// //                         color: Colors.pink)),
// //               ),
// //             ],
// //           ),
// //         )
// //       ]
// //           .map((e) => Padding(
// //                 padding:
// //                     const EdgeInsets.only(
// //                         right: 8),
// //                 child: e,
// //               ))
// //           .toList(),
// //     ),
// //   ],
// // )
// // CircleAvatar(
// //   radius: 56,
// //   backgroundColor: Colors.white,
// //   child: Padding(
// //     padding: const EdgeInsets.all(5.0),
// //     child: ClipOval(
// //       child: controller.selectedProfilePic !=
// //               null
// //           ? Image.file(
// //               File(controller
// //                   .selectedProfilePic!.path),
// //               fit: BoxFit.fill,
// //               height: 20.h,
// //               width: 40.w,
// //             )
// //           : CachedNetworkImage(
// //               fit: BoxFit.contain,
// //               height: 20.h,
// //               width: 40.w,
// //               imageUrl: user.photoURL ??
// //                   additionalUserInfo
// //                       .profile?['picture'] ??
// //                   'https://png.pngtree.com/png-vector/20190710/ourmid/pngtree-user-vector-avatar-png-image_1541962.jpg'),
// //     ),
// //   ),
// // ),
// // Align(
// //     alignment: Alignment.centerRight,
// //     child: Text(
// //       user.emailVerified
// //           ? "Verified"
// //           : 'Not Verified',
// //       style: const TextStyle(
// //           color: Colors.blue),
// //     )),

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Controllers/AuthControllers/CreateProfileController.dart';
import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

class CreateProfile extends StatelessWidget {
  final String mobileNumber;
  final User user;
  final AdditionalUserInfo additionalUserInfo;

  const CreateProfile(
      {super.key,
        required this.mobileNumber,
        required this.user,
        required this.additionalUserInfo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GetBuilder(
          init: CreateProfileController(
            mobileNumber: mobileNumber,
            user: user,
            additionalUserInfo: additionalUserInfo,
          ),
          builder: (controller) {
            return AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: controller.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 25.h,
                      width: 60.w,
                      padding: EdgeInsets.only(top: 6.h),
                      child: SvgPicture.asset(
                        'lib/Images/Group 366.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 3.h),
                        child: Column(children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Form(
                        key: controller.formKey,
                        child: SizedBox(
                          width: 90.w,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller:
                                controller.firstNameController,
                                label: 'Full Name',
                                hint: 'Enter full name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  } else if (value.length < 3) {
                                    return 'Min 3 letters required';
                                  }
                                  return null;
                                },
                              ),
                              // Email field - always enabled for user input
                              _buildTextField(
                                controller: controller.emailController,
                                label: 'Email',
                                hint: 'Enter email address',
                                enabled: true, // Always enabled
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  // Direct regex check
                                  final emailRegExp = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                  if (!emailRegExp.hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: controller.addressController,
                                label: 'Shipping Address',
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
                              ),
                              _buildTextField(
                                controller:
                                controller.addressLine1Controller,
                                label: 'Address line 1',
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
                              ),
                              _buildTextField(
                                controller:
                                controller.addressLine2Controller,
                                label: 'Address line 2',
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
                              ),
                              _buildTextField(
                                controller: controller.pinCodeController,
                                label: 'Pincode',
                                hint: 'Enter pincode',
                                keyboardType: TextInputType.number,
                                validator: (pincode) {
                                  if (pincode!.isEmpty) {
                                    return 'Pincode should not be empty!';
                                  } else if (pincode.length != 6) {
                                    return 'Pincode must be 6 digits!';
                                  }
                                  return null;
                                },
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gender',
                                    style: TextStyle(
                                        color: Color(0xFF0D0140),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDropdownField(
                                    value: controller.selectedGender,
                                    items: controller.genderList,
                                    onChanged: (String? gender) =>
                                        controller.changeSelectedGender(
                                            gender!),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date Of Birth',
                                    style: TextStyle(
                                      color: Color(0xFF0D0140),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey
                                              .withOpacity(0.4),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.white,
                                      child: DropdownDatePicker(
                                        isExpanded: true,
                                        isFormValidator: true,
                                        startYear: int.parse(
                                            controller.startYear),
                                        endYear: DateTime.now().year,
                                        width: 10,
                                        isDropdownHideUnderline: true,
                                        onChangedDay: (day) =>
                                            controller.onChangedDay(day!),
                                        onChangedMonth: (month) =>
                                            controller
                                                .onChangedMonth(month!),
                                        onChangedYear: (year) =>
                                            controller
                                                .onChangedYear(year!),
                                        dayFlex: 2,
                                        monthFlex: 3,
                                        boxDecoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(340, 50),
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: controller.createProfile,
                                  child: const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                                .map((e) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16),
                              child: e,
                            ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            );
          },
        ),
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
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
            color: Color(0xFF0D0140), fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 10.0,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ),
    ],
  );
}

Widget _buildDropdownField({
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      elevation: 16,
      dropdownColor: Colors.white,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ),
  );
}
