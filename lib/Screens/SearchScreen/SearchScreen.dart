import 'package:cached_network_image/cached_network_image.dart';
import 'package:candid_customer/Services/Collections/Offers/OffersColl.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';

import '../../Controllers/SearchControllers/SearchScreenController.dart';
import '../../main.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Offers'),
        ),
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
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
              GetBuilder(
                init: SearchScreenController(),
                builder: (controller) => Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          onChanged: (val) => controller.changeSearchStr(val),
                          decoration: const InputDecoration(
                            labelText: 'Search Products',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50.h,
                        width: 95.w,
                        child: StreamBuilder(
                          stream: controller.searchStr.isEmpty
                              ? isar.offersColls
                                  .filter()
                                  .offerNameIsNotEmpty()
                                  .selectedCityEqualTo(
                                      homeScreenController.selectedCity)
                                  .catIdEqualTo(
                                      homeScreenController.selectedCatID)
                                  .watch(fireImmediately: true)
                              : isar.offersColls
                                  .filter()
                                  .offerNameIsNotEmpty()
                                  .selectedCityEqualTo(
                                      homeScreenController.selectedCity)
                                  .and()
                                  .group((q) => q
                                      .offerNameContains(controller.searchStr,
                                          caseSensitive: false)
                                      .or()
                                      .productNameContains(controller.searchStr,
                                          caseSensitive: false)
                                      .or()
                                      .offerAddressContains(
                                          controller.searchStr,
                                          caseSensitive: false))
                                  .catIdEqualTo(
                                      homeScreenController.selectedCatID)
                                  .watch(fireImmediately: true),
                          builder: (context, snapshot) {
                            List<OffersColl> offers = [];
                            if (snapshot.hasData) {
                              offers = snapshot.data ?? [];
                            }
                            return AnimatedSwitcher(
                                duration: const Duration(seconds: 1),
                                child: offers.isNotEmpty
                                    ? ListView.separated(
                                        itemCount: offers.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          var offer = offers[index];
                                          return SizedBox(
                                            height: 15.h,
                                            child: Card(
                                              surfaceTintColor: Colors.white,
                                              elevation: 10,
                                              shadowColor: Colors.pink,
                                              child: Row(children: [
                                                Expanded(
                                                    child: CachedNetworkImage(
                                                        imageUrl: offer
                                                            .offerImages[0])),
                                                Expanded(
                                                    child: Column(
                                                  children: [
                                                    Text(offer.offerName),
                                                    Text(
                                                        offer.offerDescription),
                                                    Text(offer.productName),
                                                    Text(offer
                                                        .productDescription),
                                                  ],
                                                ))
                                              ]),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Divider(),
                                        ),
                                      )
                                    : offers.isEmpty
                                        ? const Text('No data found!')
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
