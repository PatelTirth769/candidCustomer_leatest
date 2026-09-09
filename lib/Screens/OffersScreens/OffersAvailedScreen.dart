import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Controllers/OffersController/OffersAvailedController.dart';
import 'package:candid_customer/Screens/OffersScreens/OfferEnCashScreen.dart';
import 'package:candid_customer/Services/Collections/Offers/AvailedOffers/AvailedOffersColl.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';

class OffersAvailedScreen extends StatelessWidget {
  const OffersAvailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: homeScreenController,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                'My Activated Offers',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontFamily: 'Aileron',
                  fontWeight: FontWeight.w700,
                  height: 0.03,
                ),
              ),
            ),
          ),
          body: GetBuilder(
            init: OffersAvailedController(),
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: TextField(
                  //     onChanged: (val) => controller.changeSearchStr(val),
                  //     style: const TextStyle(color: Colors.black), // Text color
                  //     decoration: InputDecoration(
                  //       hintText: 'Search with product or service name', // Hint text
                  //       hintStyle: const TextStyle(color: Colors.black), // Hint text color
                  //       prefixIcon: const Icon(Icons.search, color: Colors.black), // Search icon color
                  //      suffixIcon: const Icon(Icons.filter_alt_outlined, color: Colors.black), // Filter icon color
                  //       contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: const BorderSide(color: Colors.black),
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: const BorderSide(color: Colors.black),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: const BorderSide(color: Colors.black),
                  //       ),
                  //       filled: true, // Enable background color
                  //       fillColor: Colors.white, // Background color
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: StreamBuilder<List<AvailedOffersColl>>(
                      stream: isar.availedOffersColls
                          .filter()
                          .offerNameIsNotEmpty()
                          .sortByOfferAvailedDateDesc()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('An error occurred'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Card(
                              color: Colors.black,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No offers found',
                                  textScaleFactor: 1.2,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        List<AvailedOffersColl>? availedOfferList = snapshot.data;
                        List<AvailedOffersColl> filteredOffers = controller.searchStr.isNotEmpty
                            ? availedOfferList!.where((offer) =>
                            offer.offerName.toLowerCase().startsWith(controller.searchStr.toLowerCase())).toList()
                            : availedOfferList!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView(
                            children: filteredOffers.map((offer) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => OfferEnCashScreen(
                                          ele: controller.offersList
                                              .where((element) => element.offerID == offer.offerID)
                                              .first,
                                          shouldEnCash: false,
                                          isActive: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 25.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFDB2020),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormat.yMMMMEEEEd().format(offer.offerAvailedDate),
                                                  style: const TextStyle(color: Colors.black),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  offer.productName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  offer.offerAddress,
                                                  style: const TextStyle(color: Colors.white),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  offer.offerName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4.0),
                                                Row(
                                                  children: [
                                                    const Text('PRIME', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      margin: const EdgeInsets.only(left: 8),
                                                      child: Text(
                                                        'Extra ${int.parse(offer.discountNoPrime) - int.parse(offer.discountNo)}${controller.offersList.where((element) => element.offerID == offer.offerID).first.discountUoM}',
                                                        style: const TextStyle(color: Colors.white, fontSize: 10.0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: offer.offerImg,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

}




