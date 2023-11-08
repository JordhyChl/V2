// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/topuphistlist.model.dart';
import 'package:gpsid/model/topuphistory.model.dart';
import 'package:gpsid/pages/topuphisdetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
// ignore: library_prefixes
import 'package:flutter/services.dart' as rootBundle;
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class TopupHistory extends StatefulWidget {
  final bool darkMode;
  const TopupHistory({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<TopupHistory> createState() => _TopupHistoryState();
}

var size, width, height;

int current = 0;

class _TopupHistoryState extends State<TopupHistory> {
  late TopupHistModel topuphistlist;
  late Future<dynamic> _getTopUpHistList;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getTopUpHistList = getTopUpHistList();
  }

  Future<dynamic> getTopUpHistList() async {
    final result = await APIService().getTopupHistoryList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  blueGradientSecondary2,
                  blueGradientSecondary1,
                ])),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  size: 28,
                ),
              ),
              Text(
                'Top Up History',
                style: bold.copyWith(
                  fontSize: 14,
                  color: whiteColor,
                ),
              ),
              Container(
                width: 10,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   width: double.infinity,
            //   height: 70,
            //   child: ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: tabs.length,
            //       itemBuilder: (context, index) {
            //         return GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               current = index;
            //             });
            //             showModalBottomSheet(
            //                 isDismissible: false,
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(12),
            //                 ),
            //                 context: context,
            //                 builder: (context) {
            //                   return StatefulBuilder(
            //                       builder: (context, setState) {
            //                     return index == 0
            //                         ? statusModal(setState, index)
            //                         : dateModel(setState, index);
            //                   });
            //                 });
            //           },
            //           child: Container(
            //             margin: const EdgeInsets.only(
            //               right: 12,
            //             ),
            //             decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(4),
            //                 border: Border.all(
            //                   width: 2,
            //                   color: current == index ? bluePrimary : greyColor,
            //                 )),
            //             width: 120,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Text(
            //                   tabs[index],
            //                   style: reguler.copyWith(
            //                     fontSize: 10,
            //                     color:
            //                         current == index ? bluePrimary : greyColor,
            //                   ),
            //                 ),
            //                 const SizedBox(
            //                   width: 4,
            //                 ),
            //                 Icon(
            //                   Icons.arrow_downward,
            //                   size: 12,
            //                   color: current == index ? bluePrimary : greyColor,
            //                 )
            //               ],
            //             ),
            //           ),
            //         );
            //       }),
            // ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FutureBuilder(
                future: _getTopUpHistList,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data is ErrorTrapModel) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/handling/500error.png',
                                height: 240,
                                width: 240,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 10),
                                child: Text(
                                  AppLocalizations.of(context)!.error500,
                                  textAlign: TextAlign.center,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackSecondary2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 30, top: 10),
                                child: Text(
                                  AppLocalizations.of(context)!.error500Sub,
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
                      topuphistlist = snapshot.data;
                      if (topuphistlist.data.result.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/noData.png',
                                height: 335,
                                width: 335,
                              ),
                              Text(
                                AppLocalizations.of(context)!.reportEmpty,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackSecondary2,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.reportEmptySub,
                                style: reguler.copyWith(
                                  fontSize: 10,
                                  color: blackSecondary3,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: topuphistlist.data.result.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TopupHistoryDetail(
                                                orderID: topuphistlist
                                                    .data.result[index].orderId,
                                                darkMode: widget.darkMode,
                                              )));
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
                                  ),
                                  padding: const EdgeInsets.all(
                                    16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    border: Border.all(
                                      width: 1.5,
                                      color: greyColor,
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 158,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order ID',
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            topuphistlist
                                                .data.result[index].orderId,
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: blackPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tanggal Transaksi',
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            '${topuphistlist.data.result[index].trxDate}, ${topuphistlist.data.result[index].trxTime} WIB',
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: blackPrimary,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        indent: 0,
                                        endIndent: 0,
                                        color: greyColor,
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .totalPrice,
                                                style: reguler.copyWith(
                                                  fontSize: 12,
                                                  color: blackSecondary3,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                NumberFormat.currency(
                                                  locale: 'id',
                                                  decimalDigits: 0,
                                                  symbol: 'Rp. ',
                                                ).format(double.parse(
                                                    topuphistlist
                                                        .data
                                                        .result[index]
                                                        .totalPrice
                                                        .toString())),
                                                style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .totalUnit,
                                                style: reguler.copyWith(
                                                  fontSize: 12,
                                                  color: blackSecondary3,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                topuphistlist.data.result[index]
                                                    .totalUnit
                                                    .toString(),
                                                style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: 80,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: topuphistlist.data
                                                          .result[index].status
                                                          .toUpperCase() ==
                                                      'SUCCESS'
                                                  ? greenSecondary
                                                  : topuphistlist
                                                              .data
                                                              .result[index]
                                                              .status
                                                              .toUpperCase() ==
                                                          'PAID'
                                                      ? greenSecondary
                                                      : topuphistlist
                                                                  .data
                                                                  .result[index]
                                                                  .status
                                                                  .toUpperCase() ==
                                                              'CANCEL'
                                                          ? yellowSecondary
                                                          : topuphistlist
                                                                      .data
                                                                      .result[
                                                                          index]
                                                                      .status
                                                                      .toUpperCase() ==
                                                                  'EXPIRE'
                                                              ? greyColor
                                                              : greyColor,
                                            ),
                                            child: Text(
                                              topuphistlist.data.result[index]
                                                          .status
                                                          .toUpperCase() ==
                                                      ''
                                                  ? '???'
                                                  : topuphistlist
                                                      .data.result[index].status
                                                      .toUpperCase(),
                                              style: reguler.copyWith(
                                                fontSize: 10,
                                                color: topuphistlist
                                                            .data
                                                            .result[index]
                                                            .status
                                                            .toUpperCase() ==
                                                        'SUCCESS'
                                                    ? greenPrimary
                                                    : topuphistlist
                                                                .data
                                                                .result[index]
                                                                .status
                                                                .toUpperCase() ==
                                                            'PAID'
                                                        ? greenPrimary
                                                        : topuphistlist
                                                                    .data
                                                                    .result[
                                                                        index]
                                                                    .status
                                                                    .toUpperCase() ==
                                                                'CANCEL'
                                                            ? yellowPrimary
                                                            : topuphistlist
                                                                        .data
                                                                        .result[
                                                                            index]
                                                                        .status
                                                                        .toUpperCase() ==
                                                                    'EXPIRE'
                                                                ? blackSecondary1
                                                                : blackPrimary,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      }

                      // return GestureDetector(
                      //       onTap: () {
                      //         // Navigator.pushNamed(
                      //         //     context, '/topuphistorydetail');
                      //       },
                      //       child: Container(
                      //         margin: const EdgeInsets.only(
                      //           bottom: 20,
                      //         ),
                      //         padding: const EdgeInsets.all(
                      //           16,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(
                      //             10,
                      //           ),
                      //           border: Border.all(
                      //             width: 1.5,
                      //             color: greyColor,
                      //           ),
                      //         ),
                      //         width: double.infinity,
                      //         height: 158,
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Text(
                      //                   'Order ID',
                      //                   style: reguler.copyWith(
                      //                     fontSize: 10,
                      //                     color: blackSecondary3,
                      //                   ),
                      //                 ),
                      //                 Text(
                      //                   item.orderid.toString(),
                      //                   style: reguler.copyWith(
                      //                     fontSize: 10,
                      //                     color: blackPrimary,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             const SizedBox(
                      //               height: 16,
                      //             ),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Text(
                      //                   'Tanggal Transaksi',
                      //                   style: reguler.copyWith(
                      //                     fontSize: 10,
                      //                     color: blackSecondary3,
                      //                   ),
                      //                 ),
                      //                 Text(
                      //                   item.date.toString(),
                      //                   style: reguler.copyWith(
                      //                     fontSize: 10,
                      //                     color: blackPrimary,
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //             const SizedBox(
                      //               height: 16,
                      //             ),
                      //             Divider(
                      //               height: 1,
                      //               thickness: 1,
                      //               indent: 0,
                      //               endIndent: 0,
                      //               color: greyColor,
                      //             ),
                      //             const SizedBox(
                      //               height: 16,
                      //             ),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     Text(
                      //                       AppLocalizations.of(context)!
                      //                           .totalPrice,
                      //                       style: reguler.copyWith(
                      //                         fontSize: 12,
                      //                         color: blackSecondary3,
                      //                       ),
                      //                     ),
                      //                     const SizedBox(
                      //                       height: 4,
                      //                     ),
                      //                     Text(
                      //                       item.price.toString(),
                      //                       style: bold.copyWith(
                      //                         fontSize: 12,
                      //                         color: blackPrimary,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     Text(
                      //                       AppLocalizations.of(context)!
                      //                           .totalUnit,
                      //                       style: reguler.copyWith(
                      //                         fontSize: 12,
                      //                         color: blackSecondary3,
                      //                       ),
                      //                     ),
                      //                     const SizedBox(
                      //                       height: 4,
                      //                     ),
                      //                     Text(
                      //                       '${item.unit}',
                      //                       style: bold.copyWith(
                      //                         fontSize: 12,
                      //                         color: blackPrimary,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 Container(
                      //                   alignment: Alignment.center,
                      //                   width: 80,
                      //                   height: 25,
                      //                   decoration: BoxDecoration(
                      //                     borderRadius:
                      //                         BorderRadius.circular(4),
                      //                     color: bgCondition(item.status
                      //                         .toString()
                      //                         .toLowerCase()),
                      //                   ),
                      //                   child: Text(
                      //                     statusCondition(item.status
                      //                         .toString()
                      //                         .toLowerCase()),
                      //                     style: reguler.copyWith(
                      //                       fontSize: 10,
                      //                       color: colorCondition(item.status
                      //                           .toString()
                      //                           .toLowerCase()),
                      //                     ),
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                    }
                  }
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Card(
                            margin: const EdgeInsets.all(15),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: greyColor,
                                width: 1,
                              ),
                            ),
                            child: const SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                    shape: BoxShape.rectangle,
                                    width: 140,
                                    height: 30),
                              ),
                            ));
                      });
                },
              ),
            )
          ],
        ));
  }

  statusModal(StateSetter setState, int index) {
    return SizedBox(
      width: width,
      height: height / 2.2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Text(
                      AppLocalizations.of(context)!.sortStatus,
                      style: bold.copyWith(
                        fontSize: 16,
                        color: blackPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: blackPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 38,
                ),
                chooseModel(
                    AppLocalizations.of(context)!.allStatus, setState, 0),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(AppLocalizations.of(context)!.success, setState, 1),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(AppLocalizations.of(context)!.pending, setState, 2),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(AppLocalizations.of(context)!.expire, setState, 3),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(AppLocalizations.of(context)!.cancel, setState, 4),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1, color: greyColor),
              ),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 80,
            child: SizedBox(
              width: double.infinity,
              height: 39,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: bluePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                onPressed: () {},
                child: Text(
                  AppLocalizations.of(context)!.search,
                  style: bold.copyWith(
                    fontSize: 16,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  chooseModel(String text, StateSetter setState, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          current = index;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: current == index
                ? bold.copyWith(
                    fontSize: 14,
                    color: bluePrimary,
                  )
                : reguler.copyWith(fontSize: 14, color: blackSecondary3),
          ),
          Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  width: 1,
                  color: current == index ? bluePrimary : blackSecondary3),
            ),
            child: current == index
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: bluePrimary),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  dateModel(StateSetter setState, int index) {
    return SizedBox(
      width: width,
      height: height / 2.2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Text(
                      AppLocalizations.of(context)!.sortDate,
                      style: bold.copyWith(
                        fontSize: 16,
                        color: blackPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: blackPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 38,
                ),
                chooseModel(
                    AppLocalizations.of(context)!.allDateTopup, setState, 0),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(
                    '30 ${AppLocalizations.of(context)!.lastDay}', setState, 1),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(
                    '90 ${AppLocalizations.of(context)!.lastDay}', setState, 2),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(
                    AppLocalizations.of(context)!.chooseDate, setState, 3),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.from,
                          style: reguler.copyWith(
                            fontSize: 12,
                            color: greyColor,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 35,
                          child: TextField(
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: greyColor),
                                ),
                                hintText: '01 Januari 2022',
                                hintStyle: reguler.copyWith(
                                  fontSize: 12,
                                  color: greyColor,
                                )),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.to,
                          style: reguler.copyWith(
                            fontSize: 12,
                            color: greyColor,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 35,
                          child: TextField(
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: greyColor),
                                ),
                                hintText: '01 Januari 2022',
                                hintStyle: reguler.copyWith(
                                  fontSize: 12,
                                  color: greyColor,
                                )),
                          ),
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1, color: greyColor),
              ),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 80,
            child: SizedBox(
              width: double.infinity,
              height: 39,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: bluePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                onPressed: () {},
                child: Text(
                  AppLocalizations.of(context)!.search,
                  style: bold.copyWith(
                    fontSize: 16,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  statusCondition(String status) {
    if (status == 'berhasil') {
      return AppLocalizations.of(context)!.success;
    } else if (status == 'pending') {
      return AppLocalizations.of(context)!.pending;
    } else if (status == 'gagal') {
      return AppLocalizations.of(context)!.failed;
    } else {
      return AppLocalizations.of(context)!.expire;
    }
  }

  colorCondition(String status) {
    if (status == 'berhasil') {
      return greenPrimary;
    } else if (status == 'pending') {
      return yellowPrimary;
    } else if (status == 'gagal') {
      return redPrimary;
    } else {
      return blackSecondary1;
    }
  }

  // bgCondition(String status) {
  //   if (status == 'berhasil') {
  //     return greenSecondary;
  //   } else if (status == 'pending') {
  //     return yellowSecondary;
  //   } else if (status == 'gagal') {
  //     return redSecondary;
  //   } else {
  //     return greyColor;
  //   }
  // }

  // ignore: non_constant_identifier_names
  Future<List<TopupHis>> ReadJsonData() async {
    final jsondata =
        await rootBundle.rootBundle.loadString('json/topuphis.json');
    final list = json.decode(jsondata) as List<dynamic>;
    return list.map((e) => TopupHis.fromJson(e)).toList();
  }
}
