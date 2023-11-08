// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, must_be_immutable, file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/redeemPulsaGetGSM.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RedeemPulsa extends StatefulWidget {
  String gsmNumber = '';
  int rewardId = 0;
  String rewardName = '';
  String rewardDescription = '';
  String rewardImageUrl = '';
  String rewardCategoryName = '';
  int rewardPoint = 0;
  int rewardCategoryId = 0;
  final bool darkMode;
  RedeemPulsa(
      {Key? key,
      required this.gsmNumber,
      required this.rewardId,
      required this.rewardName,
      required this.rewardDescription,
      required this.rewardImageUrl,
      required this.rewardCategoryName,
      required this.rewardPoint,
      required this.rewardCategoryId,
      required this.darkMode})
      : super(key: key);

  @override
  State<RedeemPulsa> createState() => _RedeemPulsaState();
}

class _RedeemPulsaState extends State<RedeemPulsa> {
  var size, height, width;
  int selected = 0;
  String gsmNum = '';
  String plate = '';
  int topUpPack = 0;

  // late StoreCart storeCart;
  late Future<dynamic> _getPackage;
  late RedeemPulsaGetGSMModel getGSM;

  @override
  void initState() {
    super.initState();
    // _getPackage = getPackage();
  }

  Future<dynamic> getPackage() async {
    Dialogs().loadingDialog(context);
    // final result = await APIService().getPackage();
    final result = await APIService().redeemPulsaGetGSM();
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
          context: context,
          backgroundColor: whiteCardColor,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: double.infinity,
                  height: 370,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rewardName,
                              style: reguler.copyWith(
                                fontSize: 16,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary1,
                              ),
                            ),
                            Text(
                              'Pilih kendaraan untuk menerima ${widget.rewardName}',
                              style: reguler.copyWith(
                                fontSize: 10,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary1,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
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
                                                height: 140,
                                                width: 140,
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
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary2,
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
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      getGSM = snapshot.data;
                                      return ListView.builder(
                                          itemCount: getGSM.data.length,
                                          itemBuilder: (context, index) {
                                            return pricePackage(
                                                index,
                                                getGSM.data[index].gsmNo,
                                                getGSM.data[index].imei,
                                                getGSM.data[index].owner,
                                                getGSM.data[index].plate,
                                                getGSM.data[index].status,
                                                widget.rewardId,
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
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/gpsidbaru.png',
                                          width: 130,
                                        ),
                                      ),
                                      LoadingAnimationWidget.waveDots(
                                        size: 50,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : whiteColor,
                                        // secondRingColor: blueGradientSecondary1,
                                        // thirdRingColor: whiteColor,
                                      )
                                    ],
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
                              color: widget.darkMode
                                  ? whiteCardColor
                                  : greyColor.withOpacity(0.5),
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
                            Expanded(
                              // width: 160,
                              // height: 40,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenSecondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  // color: greenPrimary,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(10),
                                  // ),
                                  onPressed: () async {
                                    print(
                                        'Add cart: $gsmNum, ${widget.rewardId}');
                                    Dialogs().loadingDialog(context);
                                    final result = await APIService()
                                        .redeemPoin(widget.rewardId, gsmNum);
                                    if (result is MessageModel) {
                                      if (result.status) {
                                        Dialogs().hideLoaderDialog(context);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        showInfoAlert(
                                            context, result.message, '');
                                      } else {
                                        Dialogs().hideLoaderDialog(context);
                                        Navigator.pop(context);
                                        showInfoAlert(
                                            context, result.message, '');
                                      }
                                    } else {
                                      Dialogs().hideLoaderDialog(context);
                                      Navigator.pop(context);
                                      showInfoAlert(context, result, '');
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                        color: greenPrimary,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .redeemPoin,
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: greenPrimary,
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

  // addCart(String gsm, String plate, int topUpPackID) async {
  //   print('Store cart: $gsm, $plate, $topUpPackID');
  //   Dialogs().loadingDialog(context);
  //   final result = await APIService().addCart(plate, gsm, topUpPackID);

  //   if (result is ErrorTrapModel) {
  //     Navigator.pop(context);
  //     showInfoAlert(context, result.statusError, '');
  //   } else {
  //     if (result is MessageModel) {
  //       if (result.status == false) {
  //         Navigator.pop(context);
  //         showInfoAlert(context, result.message, '');
  //       } else {
  //         Navigator.pop(context);
  //         Navigator.pop(context);
  //         showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 contentPadding: const EdgeInsets.only(
  //                   bottom: 36,
  //                   right: 18,
  //                   left: 14,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(14),
  //                 ),
  //                 title: Stack(
  //                   alignment: Alignment.topCenter,
  //                   children: [
  //                     Image.asset(
  //                       'assets/cart.png',
  //                       width: 150,
  //                     ),
  //                     Positioned(
  //                       right: 0,
  //                       child: InkWell(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                           // Navigator.pop(context);
  //                         },
  //                         child: Icon(
  //                           Icons.close_rounded,
  //                           size: 34,
  //                           color: blackPrimary,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 content: Text(
  //                   '$plate berhasil\n dimasukan ke keranjang',
  //                   style: reguler.copyWith(
  //                     fontSize: 12,
  //                     color: blackSecondary1,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               );
  //             });
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return GestureDetector(
      onTap: () {
        _getPackage = getPackage();
      },
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(
          right: 12,
        ),
        decoration: BoxDecoration(color: whiteColor),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          color: widget.darkMode ? whiteCardColor : whiteColor,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Image.network(
                    widget.rewardImageUrl,
                    // rewardList
                    //     .data.results[index].dataVoucher[idx].rewardImageUrl,
                    fit: BoxFit.cover,
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/sspoint.png',
                            width: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            NumberFormat.decimalPattern()
                                .format(widget.rewardPoint)
                                .replaceAll(',', '.'),
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary1,
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          widget.rewardName,
                          style: bold.copyWith(
                            fontSize: 12,
                            color: blackPrimary,
                          ),
                        ),
                      ),
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

  Container pricePackage(
    int index,
    String gsmNo,
    String imei,
    String owner,
    String plate,
    int rewardId,
    int status,
    StateSetter setState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 19),
      width: width,
      // height: 70,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: greyColor, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selected = index;
            rewardId = widget.rewardId;
            gsmNum = gsmNo;
          });
          String localTest =
              json.encode({"reward_id": widget.rewardId, "note": gsmNo});
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
                const SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plate,
                      style: bold.copyWith(
                        fontSize: 12,
                        color: selected == index ? bluePrimary : blackPrimary,
                      ),
                    ),
                    Text(
                      gsmNo,
                      style: bold.copyWith(
                        fontSize: 10,
                        color: selected == index ? bluePrimary : blackPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 12,
                ),
                Visibility(
                    visible: status == 1 ? true : false,
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
            // Text(
            //   NumberFormat.currency(
            //     locale: 'id',
            //     decimalDigits: 0,
            //     symbol: 'Rp. ',
            //   ).format(
            //     int.parse(gsmNo),
            //   ),
            //   style: TextStyle(
            //     color: index == selected ? blueGradient : blackPrimary,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
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
