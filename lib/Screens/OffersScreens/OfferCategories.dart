// import 'package:candid_customer/Screens/OffersScreens/selectedcatoffers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:isar_community/isar.dart';
// import 'package:sizer/sizer.dart';
// import '../../Controllers/HomeScreenController.dart';
// import '../../Services/Collections/Cat/CatsColl.dart';
// import '../../Utils/MyWidgets.dart';
// import '../../main.dart';
// import '../HomeScreen.dart';
// import '../OtherScreens/Homecopy.dart';
// import 'dart:math';
//
// class OfferCategories extends StatefulWidget {
//   final String? initialTab;
//
//   const OfferCategories({
//     super.key,
//     this.initialTab,
//   });
//
//   @override
//   State<OfferCategories> createState() => _OfferCategoriesState();
// }
//
// class _OfferCategoriesState extends State<OfferCategories> {
//   bool isProductsSelected = true;
//   String selectedCategoryId = '';
//   String? selectedCategoryName;
//   List<CatsColl> allCategories = [];
//   List<CatsColl> filteredCategories = [];
//   TextEditingController searchController = TextEditingController();
//   late HomeScreenController homeScreenController;
//
//   @override
//   void initState() {
//     super.initState();
//     if (!Get.isRegistered<HomeScreenController>()) {
//       Get.put(HomeScreenController());
//     }
//     homeScreenController = Get.find<HomeScreenController>();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       isProductsSelected = !homeScreenController.screenTypeProducts;
//       _loadCategories();
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     HomeScreenController().dispose();
//     super.dispose();
//   }
//
//   void _loadCategories() {
//     isar.catsColls
//         .filter()
//         .catNameIsNotEmpty()
//         .build()
//         .watch(fireImmediately: true)
//         .listen((categories) {
//       if (mounted) {
//         setState(() {
//           allCategories = categories;
//           _filterCategories('');
//         });
//       }
//     });
//   }
//
//   void _filterCategories(String query) {
//     if (mounted) {
//       setState(() {
//         filteredCategories = allCategories
//             .where((cat) =>
//         cat.catType.toLowerCase() ==
//             (isProductsSelected ? 'product' : 'service') &&
//             cat.catName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     }
//   }
//
//   void _handleToggle(bool isProducts) {
//     if (mounted) {
//       setState(() {
//         isProductsSelected = isProducts;
//         homeScreenController.updateScreenType(!isProducts);
//         _filterCategories(searchController.text);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HomeScreenController>(
//       init: homeScreenController,
//       builder: (homeScreenController) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: myWidgets.myAppBar(),
//           drawer: _buildDrawer(context),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         _buildSearchBar(),
//                         SizedBox(height: 2.h),
//                         _buildToggleButtons(),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildCategoriesGrid(),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildToggleButtons() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(4),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildToggleButton(
//               'Products',
//               isProductsSelected,
//                   () => _handleToggle(true),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _buildToggleButton(
//               'Services',
//               !isProductsSelected,
//                   () => _handleToggle(false),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildToggleButton(
//       String title, bool isSelected, VoidCallback onPressed) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           elevation: isSelected ? 1 : 0,
//           backgroundColor: isSelected ? Colors.white : Colors.transparent,
//           foregroundColor: isSelected ? Colors.black : Colors.grey,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(
//               color: title == 'Products'
//                   ? (isSelected ? Colors.red : Colors.transparent)
//                   : (isSelected ? Colors.blue : Colors.transparent),
//               width: 1.0,
//             ),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return TextField(
//       controller: searchController,
//       onChanged: (value) {
//         _filterCategories(value);
//       },
//       decoration: InputDecoration(
//         hintText: 'Search categories',
//         prefixIcon: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Image.asset(
//             'lib/Images/candid1.png',
//             width: 35,
//             height: 45,
//           ),
//         ),
//         suffix: Icon(Icons.mic),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: Colors.grey[100],
//       ),
//     );
//   }
//
//   Widget _buildCategoriesGrid() {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 300),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           key: ValueKey<bool>(isProductsSelected),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 4,
//             childAspectRatio: 0.85,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//           ),
//           itemCount: filteredCategories.length,
//           itemBuilder: (context, index) =>
//               _buildCategoryItem(filteredCategories[index], index),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCategoryItem(CatsColl cat, int index) {
//     // Define product and service colors list
//     List<Color> productColors = [
//       Colors.red,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.brown,
//       Colors.teal,
//       Colors.deepOrange,
//       Colors.pink,
//     ];
//
//     List<Color> serviceColors = [
//       Colors.blue,
//       Colors.indigo,
//       Colors.cyan,
//       Colors.lightBlue,
//       Colors.deepPurple,
//       Colors.blueGrey,
//       Colors.lime,
//       Colors.amber,
//     ];
//
//     // Determine color based on catType and index
//     Color borderColor = cat.catType.toLowerCase() == 'product'
//         ? productColors[index % productColors.length]
//         : serviceColors[index % serviceColors.length];
//
//     return RepaintBoundary(
//       child: InkWell(
//         onTap: () {
//           Get.to(
//                 () => OffersScreen(selectedCatID: cat.catID),
//             arguments: {'selectedCategoryName': cat.catName},
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: borderColor, // dynamic color
//               width: 1.0,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 1,
//                 blurRadius: 2,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   height: 40,
//                   width: 40,
//                   padding: const EdgeInsets.all(4),
//                   child: SvgPicture.network(
//                     cat.catImg,
//                     fit: BoxFit.contain,
//                     placeholderBuilder: (BuildContext context) => const Icon(
//                       Icons.home_repair_service,
//                       size: 30,
//                       color: Colors.grey,
//                     ),
//                     cacheColorFilter: true,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Expanded(
//                   child: Text(
//                     cat.catName,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 9.sp,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: Container(
//         color: Colors.white,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           shrinkWrap: true,
//           children: [
//             MyWidgets().myDrawerHeader(),
//             for (var item in bottomNavController.navDrawerItems)
//               Card(
//                 color: Colors.white,
//                 margin:
//                 const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 elevation: 2,
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   title: Text(
//                     item['title'],
//                     style: TextStyle(
//                       fontFamily: 'Aileron',
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                   trailing: const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 16.0,
//                   ),
//                   onTap: () => Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (BuildContext context) => item['screen'],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:candid_customer/Screens/OffersScreens/productcateogry.dart';
import 'package:candid_customer/Screens/OffersScreens/servicecatogory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../Controllers/HomeScreenController.dart';
import '../../Sumit/Product_Search.dart';
import '../../Sumit/Service_Search.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

class OfferCategories extends StatefulWidget {
  final String? initialTab;

  const OfferCategories({super.key, this.initialTab});

  @override
  State<OfferCategories> createState() => _OfferCategoriesState();
}

class _OfferCategoriesState extends State<OfferCategories> {
  bool isProductsSelected = true;
  late HomeScreenController homeScreenController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HomeScreenController>()) {
      Get.put(HomeScreenController());
    }
    homeScreenController = Get.find<HomeScreenController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isProductsSelected = true;
        homeScreenController.updateScreenType(false);
      });
    });
  }

  void _handleToggle(bool isProducts) {
    setState(() {
      isProductsSelected = isProducts;
      homeScreenController.updateScreenType(!isProducts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: homeScreenController,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Search + Toggle Buttons
              // Body Section
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isProductsSelected
                      ? Productcateogry(key: ValueKey('product'))
                      : ServiceCategory(key: ValueKey('service')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Products',
              isProductsSelected,
                  () => _handleToggle(true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              'Services',
              !isProductsSelected,
                  () => _handleToggle(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String title,
      bool isSelected,
      VoidCallback onPressed,
      ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: isSelected ? 2 : 0,
          backgroundColor: isSelected ? Colors.white : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.black : Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? (title == 'Products' ? Colors.red : Colors.blue)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      readOnly: true,
      onTap: () {
        if (isProductsSelected) {
          Get.to(
                  () => Productcateogry()); // Don't go to ProductHomeScreen again
        } else {
          Get.to(() => ServiceCategory());
        }
      },
      decoration: InputDecoration(
        hintText:
        isProductsSelected ? 'Search for products' : 'Search for services',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'lib/Images/RealOffers1.png',
            width: 35,
            height: 45,
          ),
        ),
        suffixIcon: const Icon(Icons.mic, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
                margin:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => item['screen'],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
