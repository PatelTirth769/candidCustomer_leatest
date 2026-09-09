// // ProductDetailScreen.dart
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ProductDetail extends StatefulWidget {
//   final String productName;
//   final IconData icon;
//
//   const ProductDetail({
//     required this.productName,
//     required this.icon,
//   });
//
//   @override
//   State<ProductDetail> createState() => _ProductDetailState();
// }
//
// class _ProductDetailState extends State<ProductDetail> {
//   int _quantity = 1;
//
//   void _addToCart() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${widget.productName} added to cart ($_quantity)'),
//       ),
//     );
//   }
//
//   void _buyNow() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Purchase Successful'),
//         content:
//         Text('You bought $_quantity x ${widget.productName}!'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           )
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.productName)),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Icon(widget.icon, size: 100, color: Colors.red),
//             SizedBox(height: 20),
//             Text(
//               widget.productName,
//               style: GoogleFonts.workSans(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     if (_quantity > 1) {
//                       setState(() => _quantity--);
//                     }
//                   },
//                   icon: Icon(Icons.remove),
//                 ),
//                 Text(
//                   '$_quantity',
//                   style: TextStyle(fontSize: 20),
//                 ),
//                 IconButton(
//                   onPressed: () => setState(() => _quantity++),
//                   icon: Icon(Icons.add),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             ElevatedButton.icon(
//               icon: Icon(Icons.shopping_cart),
//               label: Text('Add to Cart'),
//               onPressed: _addToCart,
//             ),
//             SizedBox(height: 10),
//             ElevatedButton.icon(
//               icon: Icon(Icons.payment),
//               label: Text('Buy Now'),
//               onPressed: _buyNow,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
