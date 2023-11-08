// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, must_be_immutable

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/detailAddCart.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/getpackage.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';

class AddPackage extends StatefulWidget {
  String packageEnds = '';
  String gsmNumber = '';
  String deviceName = '';
  String userName = '';
  String domain = '';
  String fullName = '';
  bool darkMode;
  AddPackage(
      {Key? key,
      required this.packageEnds,
      required this.gsmNumber,
      required this.deviceName,
      required this.userName,
      required this.domain,
      required this.fullName,
      required this.darkMode})
      : super(key: key);

  @override
  State<AddPackage> createState() => _AddPackageState();
}

class _AddPackageState extends State<AddPackage> {
  var size, height, width;
  int selected = 0;
  String gsmNum = '';
  String plate = '';
  int topUpPack = 0;

  // late StoreCart storeCart;
  late Future<dynamic> _getPackage;
  late GetPackageModel getPackageModel;

  @override
  void initState() {
    super.initState();
    // _getPackage = getPackage();
  }

  Future<dynamic> getPackage() async {
    Dialogs().loadingDialog(context);
    // final result = await APIService().getPackage();
    final result = await APIService().getPackage(widget.gsmNumber);
    if (mounted) {
      if (result is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.statusError, '');
      }
      if (result is MessageModel) {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.message, '');
      } else {
        Dialogs().hideLoaderDialog(context);
        print(result);
        showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          backgroundColor: whiteCardColor,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: double.infinity,
                  height: 370,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            width: width / 2,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: greyColor, width: 0.5),
                                bottom: BorderSide(color: greyColor, width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.packageEnds,
                                  style: reguler.copyWith(
                                    fontSize: 10,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackSecondary1,
                                  ),
                                ),
                                Expanded(
                                  child: AutoSizeText(
                                    widget.packageEnds,
                                    style: bold.copyWith(
                                      // fontSize: 16,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackPrimary,
                                    ),
                                    maxFontSize: 16,
                                    minFontSize: 14,
                                    maxLines: 1,
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            width: width / 2,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: greyColor, width: 0.5),
                                bottom: BorderSide(color: greyColor, width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.gsmNumber,
                                  style: reguler.copyWith(
                                    fontSize: 10,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackSecondary1,
                                  ),
                                ),
                                Expanded(
                                  child: AutoSizeText(
                                    widget.deviceName,
                                    style: bold.copyWith(
                                      // fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                    maxFontSize: 16,
                                    minFontSize: 12,
                                    // maxLines: 1,
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        // width: width,
                        // height: height,
                        // padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          children: [
                            FutureBuilder(
                                future: _getPackage,
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data is ErrorTrapModel) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 60),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/handling/500error.png',
                                                height: 240,
                                                width: 240,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 50,
                                                    right: 50,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .error500,
                                                  textAlign: TextAlign.center,
                                                  style: bold.copyWith(
                                                    fontSize: 14,
                                                    color: blackSecondary2,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30,
                                                    right: 30,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .error500Sub,
                                                  textAlign: TextAlign.center,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: blackSecondary2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      getPackageModel = snapshot.data;
                                      return ListView.builder(
                                          itemCount: getPackageModel
                                              .data.results.length,
                                          itemBuilder: (context, index) {
                                            return pricePackage(
                                                index,
                                                getPackageModel
                                                    .data.results[index].id,
                                                getPackageModel.data
                                                    .results[index].topupDays,
                                                getPackageModel.data
                                                    .results[index].packName,
                                                getPackageModel
                                                    .data.results[index].price,
                                                getPackageModel.data
                                                    .results[index].isPromo,
                                                setState);
                                            // return pricePackage(
                                            //     index,
                                            //     getPackageModel.data
                                            //         .results[index].packName,
                                            //     getPackageModel
                                            //         .data.results[index].price,
                                            //     setState);
                                          });
                                    }
                                  }
                                  return const Center(
                                    child: Text('Loading...'),
                                  );
                                })
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20),
                      //   child: Column(
                      //     children: [
                      //       pricePackage(1, '365+30', '600', setState),
                      //       pricePackage(2, '180', '300', setState),
                      //       pricePackage(3, '30', '65', setState),
                      //     ],
                      //   ),
                      // ),
                      // const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: whiteCardColor.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 5,
                              offset: const Offset(
                                0,
                                -2,
                              ),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text(
                            //       AppLocalizations.of(context)!.nextPackage,
                            //       style: reguler.copyWith(
                            //         fontSize: 10,
                            //         color: blackSecondary2,
                            //       ),
                            //     ),
                            //     Text(
                            //       '12 Januari 2024',
                            //       style: bold.copyWith(
                            //         fontSize: 16,
                            //         color: blackPrimary,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Expanded(
                              // width: 160,
                              // height: 40,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  // color: greenPrimary,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(10),
                                  // ),
                                  onPressed: () {
                                    selected == 0
                                        ? addCart(
                                            widget.gsmNumber,
                                            widget.deviceName,
                                            getPackageModel.data.results[0].id)
                                        : addCart(gsmNum, plate, topUpPack);
                                    // showDialog(
                                    //     context: context,
                                    //     builder: (BuildContext context) {
                                    //       return AlertDialog(
                                    //         contentPadding:
                                    //             const EdgeInsets.only(
                                    //           bottom: 36,
                                    //           right: 18,
                                    //           left: 14,
                                    //         ),
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(14),
                                    //         ),
                                    //         title: Stack(
                                    //           alignment: Alignment.topCenter,
                                    //           children: [
                                    //             Image.asset(
                                    //               'assets/cart.png',
                                    //               width: 150,
                                    //             ),
                                    //             Positioned(
                                    //               right: 0,
                                    //               child: InkWell(
                                    //                 onTap: () =>
                                    //                     Navigator.pop(context),
                                    //                 child: Icon(
                                    //                   Icons.close_rounded,
                                    //                   size: 34,
                                    //                   color: blackPrimary,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         content: Text(
                                    //           'Tambahan paket berhasil\n dimasukan ke keranjang',
                                    //           style: reguler.copyWith(
                                    //             fontSize: 12,
                                    //             color: blackSecondary1,
                                    //           ),
                                    //           textAlign: TextAlign.center,
                                    //         ),
                                    //       );
                                    //     });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : whiteColor,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.addCart,
                                        style: bold.copyWith(
                                          fontSize: 12,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : whiteColor,
                                        ),
                                      ),
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    }

    return result;
  }

  addCart(String gsm, String plate, int topUpPackID) async {
    print('Store cart: $gsm, $plate, $topUpPackID');
    Dialogs().loadingDialog(context);
    List<DetailsCart> addToCart = [];
    addToCart.add(DetailsCart(
        vehicle: VehicleAddToCart(plate: plate, sim: gsm),
        topupPack: topUpPackID));
    // final result = await APIService().addCartV2(plate, gsm, topUpPackID);
    final result = await APIService().addCartV2(addToCart);
    setState(() {
      addToCart.clear();
    });

    if (result is ErrorTrapModel) {
      Navigator.pop(context);
      showInfoAlert(context, result.statusError, '');
    } else {
      if (result is MessageModel) {
        if (result.message == 'successfully added to cart') {
          Navigator.pop(context);
          Navigator.pop(context);
          print(result);
          showModalBottomSheet(
              backgroundColor: whiteCardColor,
              isScrollControlled: true,
              isDismissible: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
              ),
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setStateModal) {
                  return SingleChildScrollView(
                    child: Container(
                      padding: MediaQuery.of(context).viewInsets,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 30,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Image.asset(
                                  'assets/cart.png',
                                  width: 120,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: SizedBox(
                                    width: 200,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .addToCartSuccess,
                                      style: bold.copyWith(
                                        fontSize: 12,
                                        color: blackPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1,
                                        color: bluePrimary,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .seeCart,
                                            style: reguler.copyWith(
                                                color: bluePrimary,
                                                fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              });
        } else {
          if (result.status) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamed(context, '/editprofile');
            await showInfoAlert(context, result.message, '');

            print(result);
          } else {
            Navigator.pop(context);
            Navigator.pop(context);
            showInfoAlert(context, result.message, '');

            print(result);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return GestureDetector(
      onTap: () {
        _getPackage = getPackage();
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.29,
        // decoration: BoxDecoration(color: whiteColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color:
                        widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      AppLocalizations.of(context)!.renewSubscription,
                      style: reguler.copyWith(
                        fontSize: 10,
                        color: widget.darkMode
                            ? whiteColorDarkMode
                            : blackSecondary3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(
            //   width: 4,
            // ),
            // Expanded(
            //   child: Text(
            //     AppLocalizations.of(context)!.renewSubscription,
            //     style: reguler.copyWith(
            //       fontSize: 10,
            //       color: blackSecondary3,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Container pricePackage(
    int index,
    int topupPack,
    String topupDay,
    String packageName,
    String price,
    int isPromo,
    StateSetter setState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 15),
      width: width,
      height: 63,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: greyColor, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selected = index;
            plate = widget.deviceName;
            gsmNum = widget.gsmNumber;
            topUpPack = topupPack;
          });
          String localTest = json.encode({
            "user": {
              "username": 'tonih',
              "domain": "portal",
              "fullname": 'TONIHHHHH'
            },
            "vehicle": {"plate": widget.deviceName, "sim": widget.gsmNumber},
            "top_up_pack_id": topupPack,
            "is_mobile": 1
          });
          print(localTest);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      width: 1,
                      color: selected == index ? bluePrimary : blackPrimary,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: selected == index ? bluePrimary : null,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(
                //   width: 12,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    packageName,
                    style: bold.copyWith(
                      fontSize: 12,
                      color: selected == index ? bluePrimary : blackPrimary,
                    ),
                  ),
                ),
                // const SizedBox(
                //   width: 12,
                // ),
                Visibility(
                    visible: isPromo == 1 ? true : false,
                    child: Container(
                      // width: 40,
                      // height: 10,
                      decoration: BoxDecoration(
                        color: blueSecondary,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 3),
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      // width: 40,
                      // height: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Text(
                          'Promo',
                          style: bold.copyWith(color: whiteColor, fontSize: 12),
                        ),
                      ),
                    )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                NumberFormat.currency(
                  locale: 'id',
                  decimalDigits: 0,
                  symbol: 'Rp. ',
                ).format(
                  int.parse(price),
                ),
                style: TextStyle(
                  color: index == selected ? blueGradient : blackPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Text(
            //   'Rp.$price',
            //   style: bold.copyWith(
            //     fontSize: 12,
            //     color: selected == index ? bluePrimary : blackPrimary,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
