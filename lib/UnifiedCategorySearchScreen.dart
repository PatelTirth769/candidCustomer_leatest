// unified_category_search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Screens/OffersScreens/selectedcatoffers.dart';
import '../../Services/Collections/Cat/CatsColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

class UnifiedCategorySearchScreen extends StatefulWidget {
  const UnifiedCategorySearchScreen({super.key});

  @override
  State<UnifiedCategorySearchScreen> createState() =>
      _UnifiedCategorySearchScreenState();
}

class _UnifiedCategorySearchScreenState
    extends State<UnifiedCategorySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _searchController.addListener(_onSearchChanged);

    // Auto focus and auto start listening after frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _searchFocusNode.requestFocus();
      await Future.delayed(const Duration(milliseconds: 400));
      _startListening(); // 👈 auto mic start
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize();
      setState(() {});
    }
  }

  void _startListening() async {
    if (_speechEnabled && !_speechToText.isListening) {
      await _speechToText.listen(
        listenMode: ListenMode.search,
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _searchText = result.recognizedWords.toLowerCase();
          });
          if (result.finalResult) {
            _speechToText.stop();
          }
        },
      );
    }
  }

  void _stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: MyWidgets().myAppBar(),
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildUnifiedCategoriesStream(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Search Products & Services',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Aileron',
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search for products or services...',
        prefixIcon: IconButton(
          icon: Icon(
            _speechToText.isListening ? Icons.mic_off : Icons.mic,
            color: Colors.black,
          ),
          onPressed:
          _speechToText.isListening ? _stopListening : _startListening,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            _searchController.clear();
            setState(() {});
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
            ...bottomNavController.navDrawerItems.map((item) => Card(
              color: Colors.white,
              margin:
              const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0),
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
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedCategoriesStream() {
    return StreamBuilder<List<CatsColl>>(
      stream: isar.catsColls
          .filter()
          .catNameIsNotEmpty()
          .build()
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final allCats = snapshot.data ?? [];

        final filteredCats = allCats.where((cat) {
          return cat.catName.toLowerCase().contains(_searchText);
        }).toList();

        if (filteredCats.isEmpty) {
          return SliverToBoxAdapter(
            child:
            Center(child: Text('No products or services found for "$_searchText"')),
          );
        }

        final productCats = filteredCats
            .where((cat) => cat.catType.toLowerCase() == 'product')
            .toList();
        final serviceCats = filteredCats
            .where((cat) => cat.catType.toLowerCase() == 'service')
            .toList();

        List<Widget> sliverChildren = [];

        if (productCats.isNotEmpty) {
          sliverChildren.addAll([
            _buildSectionHeader('Product Categories (${productCats.length})',
                Colors.blue),
            _buildCategoriesGrid(productCats, 'product'),
          ]);
        }

        if (serviceCats.isNotEmpty) {
          sliverChildren.addAll([
            _buildSectionHeader('Service Categories (${serviceCats.length})',
                Colors.red),
            _buildCategoriesGrid(serviceCats, 'service'),
          ]);
        }

        return SliverList(
          delegate: SliverChildListDelegate(sliverChildren),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(List<CatsColl> cats, String type) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) => _buildCategoryItem(cats[index], type),
    );
  }

  Widget _buildCategoryItem(CatsColl cat, String type) {
    final icon = type == 'product'
        ? Icons.shopping_bag
        : Icons.home_repair_service;
    final borderColor = type == 'product' ? Colors.blue : Colors.red;

    return InkWell(
      onTap: () {
        Get.to(
              () => OffersScreen(selectedCatID: cat.catID),
          arguments: {'selectedCategoryName': cat.catName},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 6.h,
              width: 14.w,
              child: SvgPicture.network(
                cat.catImg,
                fit: BoxFit.contain,
                placeholderBuilder: (BuildContext context) => Icon(
                  icon,
                  size: 50,
                  color: Colors.grey,
                ),
                cacheColorFilter: true,
              ),
            ),
            const SizedBox(height: 3.0),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  cat.catName,
                  textAlign: TextAlign.center,
                  style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:isar_community/isar.dart';
// import 'package:sizer/sizer.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'Screens/OffersScreens/selectedcatoffers.dart';
// import '../../Services/Collections/Cat/CatsColl.dart';
// import '../../Utils/MyWidgets.dart';
// import '../../main.dart';
//
// class UnifiedCategorySearchScreen extends StatefulWidget {
//   const UnifiedCategorySearchScreen({super.key});
//
//   @override
//   State<UnifiedCategorySearchScreen> createState() =>
//       _UnifiedCategorySearchScreenState();
// }
//
// class _UnifiedCategorySearchScreenState
//     extends State<UnifiedCategorySearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//   final SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _searchText = "";
//   String _selectedType = "product"; // 👈 Default tab: Product
//
//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//     _searchController.addListener(_onSearchChanged);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _searchFocusNode.requestFocus();
//       await Future.delayed(const Duration(milliseconds: 400));
//       _startListening(); // auto mic start
//     });
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       _searchText = _searchController.text.toLowerCase();
//     });
//   }
//
//   Future<void> _initSpeech() async {
//     final status = await Permission.microphone.request();
//     if (status.isGranted) {
//       _speechEnabled = await _speechToText.initialize();
//       setState(() {});
//     }
//   }
//
//   void _startListening() async {
//     if (_speechEnabled && !_speechToText.isListening) {
//       await _speechToText.listen(
//         listenMode: ListenMode.search,
//         onResult: (result) {
//           setState(() {
//             _searchController.text = result.recognizedWords;
//             _searchText = result.recognizedWords.toLowerCase();
//           });
//           if (result.finalResult) {
//             _speechToText.stop();
//           }
//         },
//       );
//     }
//   }
//
//   void _stopListening() async {
//     if (_speechToText.isListening) {
//       await _speechToText.stop();
//     }
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     _stopListening();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: MyWidgets().myAppBar(),
//       drawer: _buildDrawer(context),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildHeader(),
//                   const SizedBox(height: 12),
//                   _buildSearchBar(),
//                   const SizedBox(height: 10),
//                   _buildToggleButtons(), // 👈 added toggle buttons
//                 ],
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             sliver: _buildUnifiedCategoriesStream(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Text(
//       'Search Products & Services',
//       style: TextStyle(
//         fontSize: 18.sp,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Aileron',
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return TextField(
//       controller: _searchController,
//       focusNode: _searchFocusNode,
//       decoration: InputDecoration(
//         hintText: 'Search for products or services...',
//         prefixIcon: IconButton(
//           icon: Icon(
//             _speechToText.isListening ? Icons.mic_off : Icons.mic,
//             color: Colors.black,
//           ),
//           onPressed:
//           _speechToText.isListening ? _stopListening : _startListening,
//         ),
//         suffixIcon: _searchController.text.isNotEmpty
//             ? IconButton(
//           icon: const Icon(Icons.clear, color: Colors.black),
//           onPressed: () {
//             _searchController.clear();
//             setState(() {});
//           },
//         )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30.0),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: Colors.grey[200],
//         contentPadding:
//         const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//       ),
//     );
//   }
//
//   /// 🟦 Toggle Buttons (Product / Service)
//   Widget _buildToggleButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildTabButton("Products", "product", Colors.blue),
//         const SizedBox(width: 10),
//         _buildTabButton("Services", "service", Colors.red),
//       ],
//     );
//   }
//
//   Widget _buildTabButton(String label, String type, Color color) {
//     final bool isSelected = _selectedType == type;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedType = type),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isSelected ? color : Colors.grey[300],
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.bold,
//               ),
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
//             ...bottomNavController.navDrawerItems.map((item) => Card(
//               color: Colors.white,
//               margin:
//               const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               elevation: 2,
//               child: ListTile(
//                 contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16.0),
//                 title: Text(
//                   item['title'],
//                   style: TextStyle(
//                     fontFamily: 'Aileron',
//                     fontSize: 12.sp,
//                   ),
//                 ),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16.0,
//                 ),
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => item['screen'],
//                   ),
//                 ),
//               ),
//             )).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// 🔍 Show filtered categories by selected type and search
//   Widget _buildUnifiedCategoriesStream() {
//     return StreamBuilder<List<CatsColl>>(
//       stream: isar.catsColls
//           .filter()
//           .catNameIsNotEmpty()
//           .build()
//           .watch(fireImmediately: true),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const SliverToBoxAdapter(
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         final allCats = snapshot.data ?? [];
//
//         // Apply search filter
//         final filteredCats = allCats.where((cat) {
//           return cat.catName.toLowerCase().contains(_searchText);
//         }).toList();
//
//         // Apply selected type filter
//         final visibleCats = filteredCats
//             .where((cat) => cat.catType.toLowerCase() == _selectedType)
//             .toList();
//
//         if (visibleCats.isEmpty) {
//           return SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 50),
//               child: Center(
//                 child: Text(
//                   'No ${_selectedType}s found for "$_searchText"',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           );
//         }
//
//         return SliverToBoxAdapter(
//           child: _buildCategoriesGrid(visibleCats, _selectedType),
//         );
//       },
//     );
//   }
//
//   Widget _buildCategoriesGrid(List<CatsColl> cats, String type) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         childAspectRatio: 3 / 4,
//         crossAxisSpacing: 5,
//         mainAxisSpacing: 5,
//       ),
//       itemCount: cats.length,
//       itemBuilder: (context, index) => _buildCategoryItem(cats[index], type),
//     );
//   }
//
//   Widget _buildCategoryItem(CatsColl cat, String type) {
//     final icon =
//     type == 'product' ? Icons.shopping_bag : Icons.home_repair_service;
//     final borderColor = type == 'product' ? Colors.blue : Colors.red;
//
//     return InkWell(
//       onTap: () {
//         Get.to(
//               () => OffersScreen(selectedCatID: cat.catID),
//           arguments: {'selectedCategoryName': cat.catName},
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: borderColor, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: 6.h,
//               width: 14.w,
//               child: SvgPicture.network(
//                 cat.catImg,
//                 fit: BoxFit.contain,
//                 placeholderBuilder: (BuildContext context) => Icon(
//                   icon,
//                   size: 50,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 3.0),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: Text(
//                 cat.catName,
//                 textAlign: TextAlign.center,
//                 style:
//                 const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//                 overflow: TextOverflow.visible,
//                 maxLines: 2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
