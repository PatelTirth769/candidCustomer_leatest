// // ProductHomeScreen.dart
//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import '../S/Product_Search.dart';
// import 'Service_Search.dart';
// import '../main.dart';
//
// class ProductHomeScreen extends StatefulWidget {
//   const ProductHomeScreen({Key? key}) : super(key: key);
//   @override
//   _ProductHomeScreenState createState() => _ProductHomeScreenState();
// }
//
// class _ProductHomeScreenState extends State<ProductHomeScreen> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _voiceText = '';
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedCategory = '';
//   List<String> _filteredProducts = [];
//   String _searchQuery = '';
//   bool _showAllCategories = false;
//
//   void _selectCategory(String category) {
//     setState(() {
//       if (_selectedCategory == category && _searchQuery.isEmpty) {
//         _selectedCategory = '';
//         _filteredProducts = [];
//       } else {
//         _selectedCategory = category;
//         _searchQuery = '';
//         _filteredProducts = mainCategories[category]!;
//       }
//     });
//   }
//
//   void _search(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         if (_selectedCategory.isNotEmpty) {
//           _filteredProducts = mainCategories[_selectedCategory]!;
//         } else {
//           _filteredProducts = [];
//         }
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
//   void _startListening() async {
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         if (status == 'done' && _isListening) {
//           _stopListening();
//         }
//       },
//       onError: (error) {
//         print('Speech error: $error');
//         setState(() => _isListening = false);
//       },
//     );
//
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         onResult: (result) {
//           setState(() {
//             _voiceText = result.recognizedWords;
//             _searchController.text = _voiceText;
//             _search(_voiceText);
//           });
//
//           if (result.finalResult) {
//             _stopListening();
//           }
//         },
//         listenMode: stt.ListenMode.dictation,
//         cancelOnError: false,
//         partialResults: true,
//       );
//     }
//   }
//
//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final categoryKeys = _showAllCategories
//         ? mainCategories.keys.toList()
//         : mainCategories.keys.take(12).toList();
//
//     return WillPopScope(
//       onWillPop: () async {
//         if (_selectedCategory.isNotEmpty || _searchQuery.isNotEmpty) {
//           setState(() {
//             _selectedCategory = '';
//             _searchQuery = '';
//             _filteredProducts = [];
//             _searchController.clear();
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         appBar: myWidgets.myAppBar(),
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.orange.shade100, Colors.pink.shade50],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: 'Search products...',
//                             prefixIcon: IconButton(
//                               icon: Icon(
//                                 Icons.mic,
//                                 color: _isListening ? Colors.green : Colors.red,
//                               ),
//                               onPressed: () {
//                                 if (_isListening) {
//                                   _stopListening();
//                                 } else {
//                                   _startListening();
//                                 }
//                               },
//                             ),
//                             suffixIcon: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           ServiceHomeScreen()),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(3.0),
//                                 child: Image.network(
//                                   'https://www.shutterstock.com/image-vector/swipe-icon-screen-scroll-button-260nw-2122832096.jpg',
//                                   height: 30,
//                                 ),
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white.withOpacity(0.85),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                           onChanged: _search,
//                         ),
//                         SizedBox(height: 10),
//                         if (_searchQuery.isEmpty && _selectedCategory.isEmpty)
//                           ...[
//                             GridView.count(
//                               crossAxisCount: 2,
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                               childAspectRatio: 2.5,
//                               children: categoryKeys.map((category) {
//                                 final isSelected =
//                                     _selectedCategory == category;
//                                 return GestureDetector(
//                                   onTap: () => _selectCategory(category),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: isSelected
//                                           ? Colors.red.shade100
//                                           .withOpacity(0.9)
//                                           : Colors.white.withOpacity(0.8),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black12,
//                                           blurRadius: 4,
//                                           offset: Offset(2, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 8),
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           categoryIcons[category],
//                                           size: 28,
//                                           color: Colors.red,
//                                         ),
//                                         SizedBox(width: 10),
//                                         Expanded(
//                                           child: Text(
//                                             category,
//                                             style: GoogleFonts.workSans(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                             if (!_showAllCategories)
//                               Center(
//                                 child: TextButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _showAllCategories = true;
//                                     });
//                                   },
//                                   child: Text(
//                                     'More',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         SizedBox(height: 12),
//                         _searchQuery.isNotEmpty && _filteredProducts.isEmpty
//                             ? Center(
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 40),
//                             child: Text(
//                               'No products found',
//                               style: GoogleFonts.workSans(
//                                 fontSize: 20,
//                                 color: Colors.black54,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         )
//                             : GridView.builder(
//                           itemCount: _filteredProducts.length,
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
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
//                                       productName: product,
//                                       icon: productIcons[product] ??
//                                           Icons.shopping_bag, product: '',
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
//                       ],
//                     ),
//                   ),
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
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white.withOpacity(0.8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(3, 3),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 48, color: Colors.red),
//           SizedBox(height: 12),
//           Text(
//             title,
//             style: GoogleFonts.workSans(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// final Map<String, List<String>> mainCategories = {
//   'Fruit': ['Apple', 'Banana', 'Orange', 'Grapes'],
//   'Dairy': ['Milk', 'Cheese', 'Butter', 'Curd'],
//   'Grain': ['Rice', 'Wheat', 'Barley', 'Corn'],
//   'Food': ['Pizza', 'Burger', 'Pasta', 'Sushi'],
//   'Vegetable': ['Potato', 'Tomato', 'Carrot', 'Spinach'],
//   'Beverage': ['Tea', 'Coffee', 'Juice', 'Soda'],
//   'Snack': ['Chips', 'Cookies', 'Popcorn', 'Nuts'],
//   'Meat': ['Chicken', 'Beef', 'Mutton', 'Fish'],
//   'Bakery': ['Bread', 'Cake', 'Bun', 'Muffin'],
//   'Frozen': ['Ice Cream', 'Frozen Peas', 'Frozen Pizza', 'Frozen Fries'],
//   'Condiment': ['Salt', 'Pepper', 'Ketchup', 'Mayonnaise'],
//   'Spice': ['Turmeric', 'Cumin', 'Coriander', 'Chili'],
//   'Dry Fruit': ['Almonds', 'Cashews', 'Walnuts', 'Raisins'],
//   'Oil': ['Mustard Oil', 'Sunflower Oil', 'Olive Oil', 'Coconut Oil'],
//   'Beauty': ['Lipstick', 'Foundation', 'Face Wash', 'Moisturizer'],
//   'Cleaning': ['Soap', 'Shampoo', 'Detergent', 'Disinfectant'],
//   'Stationery': ['Pen', 'Notebook', 'Pencil', 'Eraser'],
//   'Electronics': ['TV', 'Fan', 'Mobile', 'Laptop'],
//   'Appliances': ['Oven', 'Fridge', 'Mixer', 'Washing Machine'],
//   'Toy': ['Doll', 'Car', 'Puzzle', 'Blocks'],
// };
//
// final Map<String, IconData> categoryIcons = {
//   'Fruit': Icons.apple,
//   'Dairy': Icons.icecream,
//   'Grain': Icons.rice_bowl,
//   'Food': Icons.fastfood,
//   'Vegetable': Icons.eco,
//   'Beverage': Icons.local_cafe,
//   'Snack': Icons.cookie,
//   'Meat': Icons.set_meal,
//   'Bakery': Icons.cake,
//   'Frozen': Icons.ac_unit,
//   'Condiment': Icons.kitchen,
//   'Spice': Icons.fireplace,
//   'Dry Fruit': Icons.spa,
//   'Oil': Icons.oil_barrel,
//   'Beauty': Icons.brush,
//   'Cleaning': Icons.cleaning_services,
//   'Stationery': Icons.edit,
//   'Electronics': Icons.devices,
//   'Appliances': Icons.kitchen,
//   'Toy': Icons.toys,
// };
//
// final Map<String, IconData> productIcons = {
//   'Apple': Icons.apple,
//   'Banana': Icons.food_bank,
//   'Orange': Icons.circle,
//   'Grapes': Icons.grain,
//   'Milk': Icons.local_drink,
//   'Cheese': Icons.icecream,
//   'Butter': Icons.breakfast_dining,
//   'Curd': Icons.local_cafe,
//   'Rice': Icons.rice_bowl,
//   'Wheat': Icons.grain,
//   'Barley': Icons.eco,
//   'Corn': Icons.emoji_nature,
//   'Pizza': Icons.local_pizza,
//   'Burger': Icons.fastfood,
//   'Pasta': Icons.set_meal,
//   'Sushi': Icons.ramen_dining,
//   'Potato': Icons.eco,
//   'Tomato': Icons.local_dining,
//   'Carrot': Icons.nature,
//   'Spinach': Icons.spa,
//   'Tea': Icons.local_drink,
//   'Coffee': Icons.coffee,
//   'Juice': Icons.wine_bar,
//   'Soda': Icons.local_bar,
//   'Chips': Icons.lunch_dining,
//   'Cookies': Icons.cookie,
//   'Popcorn': Icons.theaters,
//   'Nuts': Icons.spa,
//   'Chicken': Icons.set_meal,
//   'Beef': Icons.dining,
//   'Mutton': Icons.restaurant,
//   'Fish': Icons.anchor,
//   'Bread': Icons.bakery_dining,
//   'Cake': Icons.cake,
//   'Bun': Icons.bakery_dining,
//   'Muffin': Icons.cake_outlined,
//   'Ice Cream': Icons.icecream,
//   'Frozen Peas': Icons.ac_unit,
//   'Frozen Pizza': Icons.local_pizza,
//   'Frozen Fries': Icons.fingerprint,
//   'Salt': Icons.spa,
//   'Pepper': Icons.spa_outlined,
//   'Ketchup': Icons.local_dining,
//   'Mayonnaise': Icons.kitchen,
//   'Turmeric': Icons.flare,
//   'Cumin': Icons.filter_vintage,
//   'Coriander': Icons.eco,
//   'Chili': Icons.whatshot,
//   'Almonds': Icons.spa,
//   'Cashews': Icons.spa_outlined,
//   'Walnuts': Icons.grass,
//   'Raisins': Icons.grain,
//   'Mustard Oil': Icons.oil_barrel,
//   'Sunflower Oil': Icons.local_florist,
//   'Olive Oil': Icons.oil_barrel,
//   'Coconut Oil': Icons.eco,
//   'Lipstick': Icons.brush,
//   'Foundation': Icons.face,
//   'Face Wash': Icons.shower,
//   'Moisturizer': Icons.water_drop,
//   'Soap': Icons.soap,
//   'Shampoo': Icons.bubble_chart,
//   'Detergent': Icons.local_laundry_service,
//   'Disinfectant': Icons.cleaning_services,
//   'Pen': Icons.edit,
//   'Notebook': Icons.book,
//   'Pencil': Icons.create,
//   'Eraser': Icons.remove,
//   'TV': Icons.tv,
//   'Fan': Icons.toys,
//   'Mobile': Icons.smartphone,
//   'Laptop': Icons.laptop,
//   'Oven': Icons.microwave,
//   'Fridge': Icons.kitchen,
//   'Mixer': Icons.blender,
//   'Washing Machine': Icons.wash,
//   'Doll': Icons.toys,
//   'Car': Icons.directions_car,
//   'Puzzle': Icons.extension,
//   'Blocks': Icons.view_module,
// };
//
// final Map<String, String> multiLangMap = {
//   // Fruit
//   'Apple': 'સફરજન सेब apple safarjan',
//   'Banana': 'કેળું केला banana kela',
//   'Orange': 'નારંગી संतरा orange narangi',
//   'Grapes': 'દ્રાક્ષ अंगूर grapes draksh',
//
//   // Dairy
//   'Milk': 'દૂધ दूध milk dudh',
//   'Cheese': 'ચીઝ पनीर cheese',
//   'Butter': 'માખણ मक्खन butter makhan',
//   'Curd': 'દહીં दही curd dahi',
//
//   // Grain
//   'Rice': 'ચોખા चावल rice chokha',
//   'Wheat': 'ઘઉં गेहूं wheat gehu',
//   'Barley': 'યવ जौ barley jav',
//   'Corn': 'મકાઈ मकई corn makai',
//
//   // Food
//   'Pizza': 'પિઝા पिज्जा pizza',
//   'Burger': 'બરગર बर्गर burger',
//   'Pasta': 'પાસ્ટા पास्ता pasta',
//   'Sushi': 'સૂશી सुशी sushi',
//
//   // Vegetable
//   'Potato': 'બટાકા आलू potato bataka',
//   'Tomato': 'ટમેટા टमाटर tomato tameta',
//   'Carrot': 'ગાજર गाजर carrot gajar',
//   'Spinach': 'પાલક पालक spinach palak',
//
//   // Beverage
//   'Tea': 'ચા चाय tea chai',
//   'Coffee': 'કૉફી कॉफी coffee',
//   'Juice': 'રશ रस juice rash',
//   'Soda': 'સોડા सोडा soda',
//
//   // Snack
//   'Chips': 'ચિપ્સ चिप्स chips',
//   'Cookies': 'કૂકીઝ कुकीज़ cookies',
//   'Popcorn': 'પોપકોર્ન पॉपकॉर्न popcorn',
//   'Nuts': 'શિંગ ભુના मेवे nuts',
//
//   // Meat
//   'Chicken': 'ચિકન चिकन chicken',
//   'Beef': 'બીફ गोमांस beef',
//   'Mutton': 'મટન मटन mutton',
//   'Fish': 'માછલી मछली fish machhli',
//
//   // Bakery
//   'Bread': 'બરેડ ब्रेड bread',
//   'Cake': 'કેક केक cake',
//   'Bun': 'બન बन bun',
//   'Muffin': 'મફિન मफिन muffin',
//
//   // Frozen
//   'Ice Cream': 'આઇસક્રીમ आइसक्रीम ice cream',
//   'Frozen Peas': 'ફ્રોઝન વટાણા जमी हुई मटर frozen peas',
//   'Frozen Pizza': 'ફ્રોઝન પિઝા फ्रोजन पिज्जा frozen pizza',
//   'Frozen Fries': 'ફ્રોઝન ફ્રાઈસ फ्रोजन फ्राईज frozen fries',
//
//   // Condiment
//   'Salt': 'મીઠું नमक salt mithu',
//   'Pepper': 'મરી मिर्च pepper mari',
//   'Ketchup': 'કેચપ कैचप ketchup',
//   'Mayonnaise': 'મેઓનેઝ मेयोनेज़ mayonnaise',
//
//   // Spice
//   'Turmeric': 'હળદર हल्दी turmeric haldar',
//   'Cumin': 'જીરૂં जीरा cumin jeeru',
//   'Coriander': 'ધાણા धनिया coriander dhana',
//   'Chili': 'મર્ચું मिर्च chili marchu',
//
//   // Dry Fruit
//   'Almonds': 'બાદામ बादाम almonds badam',
//   'Cashews': 'કાજુ काजू cashews kaju',
//   'Walnuts': 'અખરોટ अखरोट walnuts akhrot',
//   'Raisins': 'કિસમિસ किशमिश raisins kismis',
//
//   // Oil
//   'Mustard Oil': 'સરસવ તેલ सरसों का तेल mustard oil',
//   'Sunflower Oil': 'સૂર્યમુખી તેલ सूरजमुखी तेल sunflower oil',
//   'Olive Oil': 'ઓલિવ તેલ जैतून का तेल olive oil',
//   'Coconut Oil': 'નાળિયેર તેલ नारियल तेल coconut oil',
//
//   // Beauty
//   'Lipstick': 'લિપસ્ટિક लिपस्टिक lipstick',
//   'Foundation': 'ફાઉન્ડેશન फाउंडेशन foundation',
//   'Face Wash': 'ફેસ વોશ फेस वॉश face wash',
//   'Moisturizer': 'મોઇસ્ચરાઇઝર मॉइस्चराइज़र moisturizer',
//
//   // Cleaning
//   'Soap': 'સાબુ साबुन soap',
//   'Shampoo': 'શેમ્પૂ शैम्पू shampoo',
//   'Detergent': 'ડિટર્જન્ટ डिटर्जेंट detergent',
//   'Disinfectant': 'જંતુનાશક कीटाणुनाशक disinfectant',
//
//   // Stationery
//   'Pen': 'પેન पेन pen',
//   'Notebook': 'નોટબુક नोटबुक notebook',
//   'Pencil': 'પેન્સિલ पेंसिल pencil',
//   'Eraser': 'રબર रबर eraser',
//
//   // Electronics
//   'TV': 'ટેલિવિઝન टेलीविज़न tv',
//   'Fan': 'પંખો पंखा fan pankho',
//   'Mobile': 'મોબાઇલ मोबाइल mobile',
//   'Laptop': 'લેપટોપ लैपटॉप laptop',
//
//   // Appliances
//   'Oven': 'ઓવન ओवन oven',
//   'Fridge': 'ફ્રિજ फ्रिज fridge',
//   'Mixer': 'મિક્સર मिक्सर mixer',
//   'Washing Machine': 'વોશિંગ મશીન वॉशिंग मशीन washing machine',
//
//   // Toy
//   'Doll': 'ગૂડીયા गुड़िया doll',
//   'Car': 'કાર कार car',
//   'Puzzle': 'પઝલ पहेली puzzle',
//   'Blocks': 'બ્લોક્સ ब्लॉक्स blocks',
// };
//
//
//
//
