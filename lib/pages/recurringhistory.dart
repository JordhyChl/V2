// ignore_for_file: prefer_typing_uninitialized_variables, library_prefixes

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/recurringhistory.model.dart';
import 'package:gpsid/model/recurringhistorylist.model.dart';
import 'package:gpsid/pages/recurringhisdetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class RecurringHistory extends StatefulWidget {
  final bool darkMode;
  const RecurringHistory({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<RecurringHistory> createState() => RecurringHistoryState();
}

var size, width, height;

int current = 0;

class RecurringHistoryState extends State<RecurringHistory> {
  late Future<dynamic> _getRecHistList;
  late RecHistList recHistList;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getRecHistList = getRecHistList();
  }

  Future<dynamic> getRecHistList() async {
    final result = await APIService().getRecurringHistList();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // List<dynamic> tabs = [
    //   AppLocalizations.of(context)!.allStatus,
    //   AppLocalizations.of(context)!.allDate,
    // ];
    // size = MediaQuery.of(context).size;
    // width = size.width;
    // height = size.height;
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
                'Recurring History',
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
                future: _getRecHistList,
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
                      recHistList = snapshot.data;
                      if (recHistList.data.result.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/handling/search_empty.png',
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
                              // Text(
                              //   AppLocalizations.of(context)!.reportEmptySub,
                              //   style: reguler.copyWith(
                              //     fontSize: 10,
                              //     color: blackSecondary3,
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: recHistList.data.result.length,
                          itemBuilder: (context, index) {
                            DateTime? trxDate = DateTime.parse(recHistList
                                    .data.result[index].transactionDate)
                                .toLocal();
                            String setTrxDate =
                                DateFormat('dd MMM yyyy').format(trxDate);
                            DateTime? nextTrx = DateTime.parse(
                                    recHistList.data.result[index].nextExpired)
                                .toLocal();
                            String setNextTrx =
                                DateFormat('dd MMM yyyy').format(nextTrx);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecurringHistoryDetail(
                                        recurringNo: recHistList
                                            .data.result[index].orderId,
                                        darkMode: widget.darkMode,
                                      ),
                                    ));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                ),
                                padding: const EdgeInsets.all(
                                  8,
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
                                // height: 215,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .repaymentNumber,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blackSecondary3,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            recHistList
                                                .data.result[index].orderId,
                                            textAlign: TextAlign.end,
                                            style: bold.copyWith(
                                              fontSize: 12,
                                              color: blackPrimary,
                                            ),
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
                                          AppLocalizations.of(context)!.package,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blackSecondary3,
                                          ),
                                        ),
                                        Text(
                                          recHistList
                                              .data.result[index].packNmame,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blackPrimary,
                                          ),
                                        )
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
                                          AppLocalizations.of(context)!
                                              .totalUnit,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blackSecondary3,
                                          ),
                                        ),
                                        Text(
                                          // '${recHistList.data.result[index].totalUnit} Unit',
                                          recHistList
                                              .data.result[index].totalUnit
                                              .toString(),
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blackPrimary,
                                          ),
                                        )
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
                                          AppLocalizations.of(context)!
                                              .totalPrice,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blackSecondary3,
                                          ),
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'id',
                                            decimalDigits: 0,
                                            symbol: 'Rp. ',
                                          ).format(double.parse(recHistList
                                              .data.result[index].totalPrice
                                              .toString())),
                                          style: reguler.copyWith(
                                            fontSize: 12,
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
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .transaction,
                                                      style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: blackSecondary3,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      setTrxDate,
                                                      style: bold.copyWith(
                                                        fontSize: 12,
                                                        color: blackPrimary,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              // const SizedBox(
                                              //   width: 13,
                                              // ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: DottedLine(
                                                    direction: Axis.horizontal,
                                                    lineLength: 28,
                                                    lineThickness: 3,
                                                    dashLength: 2,
                                                    dashColor: greyColor,
                                                    dashGapLength: 2,
                                                  ),
                                                ),
                                              ),
                                              // const SizedBox(
                                              //   width: 5,
                                              // ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .nextPayment,
                                                      style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: blackSecondary3,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      setNextTrx,
                                                      style: bold.copyWith(
                                                        fontSize: 12,
                                                        color: blackPrimary,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: 85,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: recHistList.data
                                                        .result[index].status ==
                                                    'ACTIVE'
                                                ? greenSecondary
                                                : recHistList.data.result[index]
                                                            .status
                                                            .toLowerCase() ==
                                                        'paid'
                                                    ? greenSecondary
                                                    : redSecondary,
                                          ),
                                          child: Text(
                                            recHistList
                                                .data.result[index].status
                                                .toUpperCase(),
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: recHistList.data
                                                          .result[index].status
                                                          .toLowerCase() ==
                                                      'active'
                                                  ? greenPrimary
                                                  : recHistList
                                                              .data
                                                              .result[index]
                                                              .status
                                                              .toLowerCase() ==
                                                          'paid'
                                                      ? greenPrimary
                                                      : redPrimary,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
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
                              height: 212,
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
      height: height / 2.3,
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
                chooseModel(AppLocalizations.of(context)!.active, setState, 1),
                const SizedBox(
                  height: 20,
                ),
                chooseModel(AppLocalizations.of(context)!.stop, setState, 2),
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
      height: height / 1.8,
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

  // ignore: non_constant_identifier_names
  Future<List<RecurringHis>> ReadJsonData() async {
    final jsondata =
        await rootBundle.rootBundle.loadString('json/recurringhis.json');
    final list = json.decode(jsondata) as List<dynamic>;
    return list.map((e) => RecurringHis.fromJson(e)).toList();
  }
}
