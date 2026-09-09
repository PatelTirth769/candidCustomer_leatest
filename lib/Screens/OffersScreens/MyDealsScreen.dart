import 'package:candid_customer/Controllers/HomeScreenController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../Controllers/OffersController/OffersAvailedController.dart';
import '../../Services/Collections/Offers/AvailedOffers/AvailedOffersColl.dart';
import '../../main.dart';
import '../PrimeMembership/PrimeMembershipScreen.dart';
import 'OfferEnCashScreen.dart';

class MyDealsScreen extends StatelessWidget {
  const MyDealsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Activated Offers',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
      Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              //  myWidgets.getCandidBranding(),
              // Prime Membership Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   'Unlock Premium Benefits',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      Text(
                        localUser?.isUserPrimeMember == true
                            ? 'Prime Membership Activated'
                            : 'Unlock Premium Benefits',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // const Text(
                      //   'Get exclusive deals and higher discounts',
                      //   style: TextStyle(
                      //     color: Colors.white70,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      Text(
                        localUser?.isUserPrimeMember == true
                            ? 'Thank you for your purchase. Enjoy exclusive benefits!'
                            : 'Get exclusive deals and higher discounts',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GetBuilder<HomeScreenController>(
                          builder: (controller) {
                           // debugPrint('MyDealsScreen - Prime Status: ${localUser?.isUserPrimeMember}');
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PrimeMembership(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                localUser?.isUserPrimeMember == true
                                    ? 'PRIME MEMBER'
                                    : 'BECOME A PRIME MEMBER',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              //  myWidgets.getCandidBranding(),
              // Deals List
              GetBuilder(
                init: OffersAvailedController(),
                builder: (controller) {
                  if (controller.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    );
                  }

                  return StreamBuilder<List<AvailedOffersColl>>(
                    stream: isar.availedOffersColls
                        .filter()
                        .offerNameIsNotEmpty()
                        .sortByOfferAvailedDateDesc()
                        .watch(fireImmediately: true),
                    builder: (context, snapshot) {
                      List<AvailedOffersColl>? availedOfferList = snapshot.data;

                      if (snapshot.hasError) {
                        return _buildErrorState();
                      }

                      if (availedOfferList == null || availedOfferList.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availedOfferList.length,
                        itemBuilder: (context, index) {
                          final offer = availedOfferList[index];
                          final offerList = controller.offersList;

                          if (offerList.isEmpty) {
                            return _buildEmptyState();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildOfferCard(context, offer, offerList, controller),
                          );

                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildOfferCard(BuildContext context, AvailedOffersColl offer, List offerList, controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          final offerDetails = offerList.where((element) => element.offerID == offer.offerID).first;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OfferEnCashScreen(
                ele: offerDetails,
                shouldEnCash: false,
                isActive: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFDB2020), Color(0xFFFF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMMd().format(offer.offerAvailedDate),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              offer.offerAddress,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'PRIME',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Extra ${int.parse(offer.discountNoPrime) - int.parse(offer.discountNo)}${controller.offersList.where((element) => element.offerID == offer.offerID).first.discountUoM}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 160,
                    child: CachedNetworkImage(
                      imageUrl: offer.offerImg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No offers available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new deals',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

