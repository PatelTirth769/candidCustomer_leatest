// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Product(),
//   ));
// }
//
// class Product extends StatefulWidget {
//   @override
//   _ProductState createState() => _ProductState();
// }
//
// class _ProductState extends State<Product> {
//   final Map<String, List<String>> mainCategories = {
//     'Fruit': ['Apple', 'Banana', 'Orange', 'Grapes'],
//     'Dairy': ['Milk', 'Cheese', 'Butter', 'Curd'],
//     'Grain': ['Rice', 'Wheat', 'Barley', 'Corn'],
//     'Food': ['Pizza', 'Burger', 'Pasta', 'Sushi'],
//   };
//
//   final Map<String, IconData> productIcons = {
//     'Apple': Icons.apple,
//     'Banana': Icons.food_bank,
//     'Orange': Icons.circle,
//     'Grapes': Icons.grain,
//     'Milk': Icons.local_drink,
//     'Cheese': Icons.icecream,
//     'Butter': Icons.breakfast_dining,
//     'Curd': Icons.local_cafe,
//     'Rice': Icons.rice_bowl,
//     'Wheat': Icons.grain,
//     'Barley': Icons.eco,
//     'Corn': Icons.emoji_nature,
//     'Pizza': Icons.local_pizza,
//     'Burger': Icons.fastfood,
//     'Pasta': Icons.set_meal,
//     'Sushi': Icons.ramen_dining,
//   };
//
//   final Map<String, String> multiLangMap = {
//     'Apple': 'સફરજન सेब apple safarjan',
//     'Banana': 'કેળું केला banana kela',
//     'Orange': 'નારંગી संतरा orange narangi',
//     'Grapes': 'દ્રાક્ષ अंगूर grapes draksh',
//     'Milk': 'દૂધ दूध milk dudh',
//     'Cheese': 'ચીઝ पनीर cheese',
//     'Butter': 'માખણ मक्खन butter makhan',
//     'Curd': 'દહીં दही curd dahi',
//     'Rice': 'ચોખા चावल rice chokha',
//     'Wheat': 'ઘઉં गेहूं wheat',
//     'Barley': 'યવ जौ barley',
//     'Corn': 'મકાઈ मकई corn makay',
//     'Pizza': 'પિઝા पिज्जा pizza',
//     'Burger': 'બરગર बर्गर burger',
//     'Pasta': 'પાસ્ટા पास्ता pasta',
//     'Sushi': 'સૂશી सुशी sushi',
//   };
//
//   List<String> _filteredProducts = [];
//   String _searchQuery = '';
//   String? _selectedCategory;
//   late FocusNode _searchFocusNode;
//
//   @override
//   void initState() {
//     super.initState();
//     _searchFocusNode = FocusNode();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _searchFocusNode.requestFocus();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchFocusNode.dispose();
//     super.dispose();
//   }
//
//   void _search(String query) {
//     setState(() {
//       _searchQuery = query;
//       _selectedCategory = null;
//       if (query.isEmpty) {
//         _filteredProducts = [];
//       } else {
//         _filteredProducts = multiLangMap.entries
//             .where((entry) =>
//             entry.value.toLowerCase().contains(query.toLowerCase()))
//             .map((entry) => entry.key)
//             .toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Product Search',
//           style: GoogleFonts.workSans(
//               color: Colors.black, fontWeight: FontWeight.w400, fontSize: 25),
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.network(
//               'https://images.unsplash.com/photo-1612831662146-b3df0d4db4a1?auto=format&fit=crop&w=1400&q=80',
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) =>
//               loadingProgress == null
//                   ? child
//                   : Center(child: CircularProgressIndicator()),
//               errorBuilder: (context, error, stackTrace) =>
//                   Container(color: Colors.grey[300]),
//             ),
//           ),
//           BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: SafeArea(
//               child: Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextField(
//                       focusNode: _searchFocusNode,
//                       decoration: InputDecoration(
//                         hintText: 'Search products...',
//                         prefixIcon: Icon(Icons.search),
//                         filled: true,
//                         fillColor: Colors.white.withOpacity(0.7),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: _search,
//                     ),
//                     SizedBox(height: 10),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: mainCategories.keys.map((category) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _selectedCategory = category;
//                                 _searchQuery = '';
//                                 _filteredProducts =
//                                     mainCategories[category] ?? [];
//                               });
//                             },
//                             child: Padding(
//                               padding:
//                               const EdgeInsets.symmetric(horizontal: 4),
//                               child: Chip(
//                                 label: Text(category),
//                                 backgroundColor: _selectedCategory == category
//                                     ? Colors.greenAccent.withOpacity(0.7)
//                                     : Colors.white.withOpacity(0.6),
//                                 labelStyle: GoogleFonts.workSans(
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     if (_filteredProducts.isNotEmpty)
//                       Expanded(
//                         child: GridView.builder(
//                           itemCount: _filteredProducts.length,
//                           gridDelegate:
//                           SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             childAspectRatio: 0.85,
//                             crossAxisSpacing: 10,
//                             mainAxisSpacing: 10,
//                           ),
//                           itemBuilder: (context, index) {
//                             final product = _filteredProducts[index];
//                             return GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => ProductDetailScreen(
//                                       product: product,
//                                       icon: productIcons[product] ??
//                                           Icons.shopping_bag, productName: '',
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: GlassProductCard(
//                                 icon: productIcons[product] ??
//                                     Icons.shopping_bag,
//                                 title: product,
//                                 subtitle: '',
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     if (_searchQuery.isNotEmpty && _filteredProducts.isEmpty)
//                       Expanded(
//                         child: Center(
//                           child: Text(
//                             'No products found',
//                             style: GoogleFonts.workSans(
//                               fontSize: 18,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class GlassProductCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//
//   const GlassProductCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.black12.withOpacity(0.3)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 offset: Offset(4, 4),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.all(12),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 48, color: Colors.black),
//               SizedBox(height: 12),
//               Text(
//                 title,
//                 style: GoogleFonts.workSans(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               SizedBox(height: 6),
//               if (subtitle.isNotEmpty)
//                 Text(
//                   subtitle,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.workSans(
//                     color: Colors.black,
//                     fontSize: 12,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ProductDetailScreen extends StatelessWidget {
//   final String product;
//   final IconData icon;
//
//   const ProductDetailScreen({
//     required this.product,
//     required this.icon, required String productName,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 120,
//               color: Colors.green.shade700,
//             ),
//             SizedBox(height: 30),
//             Text(
//               product,
//               style: GoogleFonts.workSans(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               onPressed: () => Navigator.pop(context),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 child: Text(
//                   'Go Back',
//                   style:
//                   GoogleFonts.workSans(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // import 'dart:ui';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // class ProductHomeScreen extends StatefulWidget {
// //   @override
// //   _ProductHomeScreenState createState() => _ProductHomeScreenState();
// // }
// //
// // class _ProductHomeScreenState extends State<ProductHomeScreen> {
// //   final Map<String, List<String>> mainCategories = {
// //     'Fruit': ['Apple', 'Banana', 'Orange', 'Grapes'],
// //     'Dairy': ['Milk', 'Cheese', 'Butter', 'Curd'],
// //     'Grain': ['Rice', 'Wheat', 'Barley', 'Corn'],
// //     'Food': ['Pizza', 'Burger', 'Pasta', 'Sushi'],
// //   };
// //
// //   final Map<String, IconData> categoryIcons = {
// //     'Fruit': Icons.apple,
// //     'Dairy': Icons.icecream,
// //     'Grain': Icons.rice_bowl,
// //     'Food': Icons.fastfood,
// //   };
// //
// //   final Map<String, IconData> productIcons = {
// //     'Apple': Icons.apple,
// //     'Banana': Icons.food_bank,
// //     'Orange': Icons.circle,
// //     'Grapes': Icons.grain,
// //     'Milk': Icons.local_drink,
// //     'Cheese': Icons.icecream,
// //     'Butter': Icons.breakfast_dining,
// //     'Curd': Icons.local_cafe,
// //     'Rice': Icons.rice_bowl,
// //     'Wheat': Icons.grain,
// //     'Barley': Icons.eco,
// //     'Corn': Icons.emoji_nature,
// //     'Pizza': Icons.local_pizza,
// //     'Burger': Icons.fastfood,
// //     'Pasta': Icons.set_meal,
// //     'Sushi': Icons.ramen_dining,
// //   };
// //
// //   final Map<String, String> multiLangMap = {
// //     'Apple': 'સફરજન सेब apple safarjan',
// //     'Banana': 'કેળું केला banana kela',
// //     'Orange': 'નારંગી संतरा orange narangi',
// //     'Grapes': 'દ્રાક્ષ अंगूर grapes draksh',
// //     'Milk': 'દૂધ दूध milk dudh',
// //     'Cheese': 'ચીઝ पनीर cheese',
// //     'Butter': 'માખણ मक्खन butter makhan',
// //     'Curd': 'દહીં दही curd dahi',
// //     'Rice': 'ચોખા चावल rice chokha',
// //     'Wheat': 'ઘઉં गेहूं wheat',
// //     'Barley': 'યવ जौ barley',
// //     'Corn': 'મકાઈ मकई corn makay',
// //     'Pizza': 'પિઝા पिज्जा pizza',
// //     'Burger': 'બરગર बर्गर burger',
// //     'Pasta': 'પાસ્ટા पास्ता pasta',
// //     'Sushi': 'સૂશી सुशी sushi',
// //   };
// //
// //   String _selectedCategory = '';
// //   List<String> _filteredProducts = [];
// //   String _searchQuery = '';
// //   late FocusNode _searchFocusNode;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _searchFocusNode = FocusNode();
// //     _searchFocusNode.addListener(() {
// //       setState(() {});
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchFocusNode.dispose();
// //     super.dispose();
// //   }
// //
// //   void _selectCategory(String category) {
// //     setState(() {
// //       if (_selectedCategory == category && _searchQuery.isEmpty) {
// //         _selectedCategory = '';
// //         _filteredProducts = [];
// //       } else {
// //         _selectedCategory = category;
// //         _searchQuery = '';
// //         _filteredProducts = mainCategories[category]!;
// //       }
// //     });
// //   }
// //
// //   void _search(String query) {
// //     setState(() {
// //       _searchQuery = query;
// //       if (query.isEmpty) {
// //         if (_selectedCategory.isNotEmpty) {
// //           _filteredProducts = mainCategories[_selectedCategory]!;
// //         } else {
// //           _filteredProducts = [];
// //         }
// //       } else {
// //         _filteredProducts = multiLangMap.entries
// //             .where((entry) => entry.value.toLowerCase().contains(query.toLowerCase()))
// //             .map((entry) => entry.key)
// //             .toList();
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       extendBodyBehindAppBar: true,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         title: Text('Product Search',
// //             style: GoogleFonts.workSans(
// //                 color: Colors.black, fontWeight: FontWeight.w400, fontSize: 25)),
// //         centerTitle: true,
// //       ),
// //       body: Stack(
// //         children: [
// //           Positioned.fill(
// //             child: Image.network(
// //               'https://images.unsplash.com/photo-1612831662146-b3df0d4db4a1?auto=format&fit=crop&w=1400&q=80',
// //               fit: BoxFit.cover,
// //               loadingBuilder: (context, child, loadingProgress) {
// //                 if (loadingProgress == null) return child;
// //                 return Center(child: CircularProgressIndicator());
// //               },
// //               errorBuilder: (context, error, stackTrace) {
// //                 return Container(color: Colors.grey[300]);
// //               },
// //             ),
// //           ),
// //           BackdropFilter(
// //             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
// //             child: SafeArea(
// //               child: Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     TextField(
// //                       focusNode: _searchFocusNode,
// //                       decoration: InputDecoration(
// //                         hintText: 'Search products...',
// //                         prefixIcon: Icon(Icons.search),
// //                         filled: true,
// //                         fillColor: Colors.white.withOpacity(0.7),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(16),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                       ),
// //                       onChanged: _search,
// //                     ),
// //                     SizedBox(height: 10),
// //                     if (_searchFocusNode.hasFocus || _searchQuery.isNotEmpty) ...[
// //                       SingleChildScrollView(
// //                         scrollDirection: Axis.horizontal,
// //                         child: Row(
// //                           children: mainCategories.keys.map((category) {
// //                             final isSelected =
// //                                 _searchQuery.isEmpty && _selectedCategory == category;
// //                             return Padding(
// //                               padding: const EdgeInsets.symmetric(horizontal: 4),
// //                               child: ChoiceChip(
// //                                 label: Text(category),
// //                                 avatar: Icon(
// //                                   categoryIcons[category],
// //                                   size: 20,
// //                                   color: isSelected ? Colors.white : Colors.black54,
// //                                 ),
// //                                 selected: isSelected,
// //                                 selectedColor: Colors.green.shade600,
// //                                 backgroundColor: Colors.white.withOpacity(0.5),
// //                                 onSelected: (_) => _selectCategory(category),
// //                                 labelStyle: GoogleFonts.workSans(
// //                                   color: isSelected ? Colors.white : Colors.black,
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w400,
// //                                 ),
// //                                 elevation: 3,
// //                                 pressElevation: 5,
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ),
// //                       ),
// //                       SizedBox(height: 12),
// //                       Expanded(
// //                         child: _filteredProducts.isEmpty
// //                             ? Center(
// //                           child: Text(
// //                             'No products found',
// //                             style: GoogleFonts.workSans(
// //                               fontSize: 20,
// //                               color: Colors.black54,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         )
// //                             : GridView.builder(
// //                           itemCount: _filteredProducts.length,
// //                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                             crossAxisCount: 2,
// //                             childAspectRatio: 0.85,
// //                             crossAxisSpacing: 10,
// //                             mainAxisSpacing: 10,
// //                           ),
// //                           itemBuilder: (context, index) {
// //                             final product = _filteredProducts[index];
// //                             return GlassProductCard(
// //                               icon: productIcons[product] ?? Icons.shopping_bag,
// //                               title: product,
// //                               subtitle: '',
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class GlassProductCard extends StatelessWidget {
// //   final IconData icon;
// //   final String title;
// //   final String subtitle;
// //
// //   const GlassProductCard({
// //     required this.icon,
// //     required this.title,
// //     required this.subtitle,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ClipRRect(
// //       borderRadius: BorderRadius.circular(16),
// //       child: BackdropFilter(
// //         filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white.withOpacity(0.3),
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(color: Colors.black12.withOpacity(0.3)),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black12,
// //                 blurRadius: 10,
// //                 offset: Offset(4, 4),
// //               ),
// //             ],
// //           ),
// //           padding: EdgeInsets.all(12),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(icon, size: 48, color: Colors.black),
// //               SizedBox(height: 12),
// //               Text(
// //                 title,
// //                 style: GoogleFonts.workSans(
// //                   color: Colors.black,
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 18,
// //                 ),
// //               ),
// //               SizedBox(height: 6),
// //               if (subtitle.isNotEmpty)
// //                 Text(
// //                   subtitle,
// //                   textAlign: TextAlign.center,
// //                   style: GoogleFonts.workSans(
// //                     color: Colors.black,
// //                     fontSize: 12,
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
