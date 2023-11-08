// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/recurringhistorylist.model.dart';
import 'package:gpsid/model/recurringstatuslist.model.dart';
import 'package:gpsid/model/topuphistlist.model.dart';
import 'package:gpsid/pages/recurringhisdetail.dart';
import 'package:gpsid/pages/recurringstatusdetail.dart';
import 'package:gpsid/pages/topuphisdetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class Transaction extends StatefulWidget {
  final bool darkMode;
  const Transaction({
    super.key,
    required this.darkMode,
  });

  @override
  State<Transaction> createState() => TransactionState();
}

class TransactionState extends State<Transaction>
    with TickerProviderStateMixin {
  int current = 0;
  int page = 1;
  int perPage = 25;
  bool loadmoreBtn = false;
  bool loadmoreBtnPressed = false;
  int totalData = 0;
  int currentData = 0;
  late LocalData localData;
  List<String> sort = [];
  dynamic appDir;
  // int selected = 0;
  int selectAll = 0;
  bool showSelectAll = false;
  int totalUnit = 0;
  late Future<dynamic> _getTransaction;
  late List<ResultTopUpHistList> initTopupList;
  late List<ResultRecurringStatusList> initRecurringStatusList;
  late List<ResultRecurringHistList> initRecurringHistList;
  List<dynamic> status = [];
  int selected = 0;

  @override
  void initState() {
    super.initState();
    _getTransaction = getTransaction(0, '');
  }

  Future<dynamic> getTransaction(int index, String sort) async {
    index != 0 ? Dialogs().loadingDialog(context) : {};
    var res = index == 0
        ? await APIService().getTopupHistoryList()
        : index == 1
            ? await APIService().getTopupHistoryList()
            : index == 2
                ? await APIService().getRecurringHistList()
                : await APIService().getRecurringStatusList();
    if (res is ErrorTrapModel) {
      showInfoAlert(context, res.statusError, '');
    }
    if (res is TopupHistModel) {
      status = [
        AppLocalizations.of(context)!.all.replaceAll('unit', ''),
        'Success',
        'Cancel',
        'Pending',
        'Expire'
      ];
    }
    if (res is RecHistList) {
      status = [
        AppLocalizations.of(context)!.all.replaceAll('unit', ''),
        'Paid',
        'Stop'
      ];
    }
    if (res is RecStatusList) {
      status = [
        AppLocalizations.of(context)!.all.replaceAll('unit', ''),
        'Active',
        'Stopped'
      ];
    }
    setState(() {
      selected = 0;
    });
    index != 0 ? Navigator.pop(context) : {};
    return res;
  }

  @override
  Widget build(BuildContext context) {
    sort = [
      AppLocalizations.of(context)!.topupHist,
      AppLocalizations.of(context)!.recurringHistory,
      AppLocalizations.of(context)!.recurringStatus
    ];
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  widget.darkMode ? whiteCardColor : blueGradientSecondary1,
                  widget.darkMode ? whiteCardColor : blueGradientSecondary2,
                ],
              ),
            ),
          ),
          title: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 32,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.transaction,
                    textAlign: TextAlign.center,
                    style: bold.copyWith(
                      fontSize: 16,
                      color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Container(
                width: double.infinity,
                height: sort.isEmpty ? 10 : 55,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  // horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child: ListView.builder(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    physics: const BouncingScrollPhysics(),
                    itemCount: sort.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            current = index;
                            print(current);
                          });
                          _getTransaction = getTransaction(index + 1, '');
                        },
                        child: Container(
                          // width: 120,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          margin: const EdgeInsets.only(
                            right: 8,
                          ),
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                current == index ? bluePrimary : whiteCardColor,
                            border: Border.all(
                                width: 1,
                                color: current == index
                                    ? bluePrimary
                                    : widget.darkMode
                                        ? Colors.transparent
                                        : greyColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Image.asset(
                                    index == 0
                                        ? 'assets/icon/otherpage/topuphistory.png'
                                        : index == 1
                                            ? 'assets/icon/otherpage/recurringhistory.png'
                                            : 'assets/icon/otherpage/recurringstatus.png',
                                    height: 20,
                                    color: current == index
                                        ? widget.darkMode
                                            ? whiteColorDarkMode
                                            : whiteColor
                                        : widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary3,
                                  ),
                                ),
                                Text(
                                  sort[index],
                                  style: reguler.copyWith(
                                      fontSize: 12,
                                      color: current == index
                                          ? widget.darkMode
                                              ? whiteColorDarkMode
                                              : whiteColor
                                          : widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary3
                                      // color: current == index
                                      //     ? index == 0
                                      //         ? blueGradient
                                      //         : index == 1
                                      //             ? yellowPrimary
                                      //             : index == 2
                                      //                 ? redPrimary
                                      //                 : whiteColor
                                      //     : blackSecondary3,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Divider(
              height: 2,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: greyColorSecondary,
            ),
          ),
          GestureDetector(
            onTap: () {
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
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter setStateModal) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: status.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selected = index;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                status[index],
                                                textAlign: TextAlign.center,
                                                style: reguler.copyWith(
                                                    fontSize: 14,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary2),
                                              ),
                                            )),
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          indent: 0,
                                          endIndent: 0,
                                          color: greyColorSecondary,
                                        ),
                                      ],
                                    ),
                                  ));
                            },
                          ),
                        ),
                      );
                    });
                  });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Container(
                // width: double.infinity,
                height: sort.isEmpty ? 10 : 55,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  // horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(
                    right: 8,
                  ),
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: greyColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sortStatus,
                          style: reguler.copyWith(
                            fontSize: 12,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : blackSecondary3,
                          ),
                        ),
                        Icon(
                          Icons.arrow_downward_outlined,
                          size: 15,
                          color: widget.darkMode
                              ? whiteColorDarkMode
                              : blackSecondary3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getTransaction,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                List<ResultTopUpHistList> topuphistlist;
                List<ResultRecurringStatusList> recurringStatusList;
                List<ResultRecurringHistList> recHistList;
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
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary2,
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
                    if (snapshot.data is TopupHistModel) {
                      initTopupList = snapshot.data.data.result;
                      topuphistlist = initTopupList;
                      if (selected == 0) {
                        topuphistlist = initTopupList;
                      }
                      if (selected == 1) {
                        List<ResultTopUpHistList> result = [];
                        for (var el in topuphistlist) {
                          if (el.status.toLowerCase() == 'success') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        topuphistlist = result;
                      }
                      if (selected == 2) {
                        List<ResultTopUpHistList> result = [];
                        for (var el in topuphistlist) {
                          if (el.status.toLowerCase() == 'cancel') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        topuphistlist = result;
                      }
                      if (selected == 3) {
                        List<ResultTopUpHistList> result = [];
                        for (var el in topuphistlist) {
                          if (el.status.toLowerCase() == 'pending') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        topuphistlist = result;
                      }
                      if (selected == 4) {
                        List<ResultTopUpHistList> result = [];
                        for (var el in topuphistlist) {
                          if (el.status.toLowerCase() == 'expire') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        topuphistlist = result;
                      }
                      if (topuphistlist.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/handling/search_empty.png',
                                height: 250,
                                width: 250,
                              ),
                              Text(
                                AppLocalizations.of(context)!.reportEmpty,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary2,
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
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: topuphistlist.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TopupHistoryDetail(
                                                  orderID: topuphistlist[index]
                                                      .orderId,
                                                  darkMode: widget.darkMode,
                                                )));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: whiteCardColor,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: widget.darkMode
                                            ? Colors.transparent
                                            : greyColor,
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
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                              ),
                                            ),
                                            Text(
                                              topuphistlist[index].orderId,
                                              style: reguler.copyWith(
                                                fontSize: 12,
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
                                              AppLocalizations.of(context)!
                                                  .transactionDate,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                              ),
                                            ),
                                            Text(
                                              '${topuphistlist[index].trxDate}, ${topuphistlist[index].trxTime}',
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
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .totalPrice,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
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
                                                      topuphistlist[index]
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
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '${topuphistlist[index].totalUnit.toString()} Unit',
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
                                                color: topuphistlist[index]
                                                            .status
                                                            .toUpperCase() ==
                                                        'SUCCESS'
                                                    ? greenPrimary
                                                    : topuphistlist[index]
                                                                .status
                                                                .toUpperCase() ==
                                                            'PAID'
                                                        ? greenPrimary
                                                        : topuphistlist[index]
                                                                    .status
                                                                    .toUpperCase() ==
                                                                'CANCEL'
                                                            ? yellowPrimary
                                                            : topuphistlist[index]
                                                                        .status
                                                                        .toUpperCase() ==
                                                                    'EXPIRE'
                                                                ? widget.darkMode
                                                                    ? whiteColor
                                                                    : blackPrimary
                                                                : widget.darkMode
                                                                    ? whiteColor
                                                                    : blackPrimary,
                                              ),
                                              child: Text(
                                                topuphistlist[index]
                                                            .status
                                                            .toUpperCase() ==
                                                        ''
                                                    ? '???'
                                                    : topuphistlist[index]
                                                        .status
                                                        .toUpperCase(),
                                                style: reguler.copyWith(
                                                  fontSize: 12,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : whiteColor,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        );
                      }
                    }
                    if (snapshot.data is RecHistList) {
                      initRecurringHistList = snapshot.data.data.result;
                      recHistList = initRecurringHistList;
                      if (selected == 0) {
                        recHistList = initRecurringHistList;
                      }
                      if (selected == 1) {
                        List<ResultRecurringHistList> result = [];
                        for (var el in recHistList) {
                          if (el.status.toLowerCase() == 'paid') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        recHistList = result;
                      }
                      if (selected == 2) {
                        List<ResultRecurringHistList> result = [];
                        for (var el in recHistList) {
                          if (el.status.toLowerCase() == 'etc') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        recHistList = result;
                      }
                      if (recHistList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/handling/search_empty.png',
                                height: 250,
                                width: 250,
                              ),
                              Text(
                                AppLocalizations.of(context)!.reportEmpty,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary2,
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
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: recHistList.length,
                            itemBuilder: (context, index) {
                              DateTime? trxDate = DateTime.parse(
                                      recHistList[index].transactionDate)
                                  .toLocal();
                              String setTrxDate =
                                  DateFormat('dd MMM yyyy').format(trxDate);
                              DateTime? nextTrx =
                                  DateTime.parse(recHistList[index].nextExpired)
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
                                          recurringNo:
                                              recHistList[index].orderId,
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
                                    color:
                                        widget.darkMode ? whiteCardColor : null,
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                    border: Border.all(
                                      width: 1,
                                      color: widget.darkMode
                                          ? Colors.transparent
                                          : greyColor,
                                    ),
                                  ),
                                  width: double.infinity,
                                  // height: 215,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              recHistList[index].orderId,
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
                                            AppLocalizations.of(context)!
                                                .package,
                                            style: reguler.copyWith(
                                              fontSize: 12,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            recHistList[index].packNmame,
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
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            // '${recHistList.data.result[index].totalUnit} Unit',
                                            recHistList[index]
                                                .totalUnit
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
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'id',
                                              decimalDigits: 0,
                                              symbol: 'Rp. ',
                                            ).format(double.parse(
                                                recHistList[index]
                                                    .totalPrice
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .transaction,
                                                        style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3,
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
                                                // Expanded(
                                                //   child: Padding(
                                                //     padding:
                                                //         const EdgeInsets.only(
                                                //             left: 5, right: 5),
                                                //     child: DottedLine(
                                                //       direction: Axis.horizontal,
                                                //       lineLength: 55,
                                                //       lineThickness: 3,
                                                //       dashLength: 2,
                                                //       dashColor: greyColor,
                                                //       dashGapLength: 2,
                                                //     ),
                                                //   ),
                                                // ),
                                                // const SizedBox(
                                                //   width: 5,
                                                // ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .nextPayment,
                                                        style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3,
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
                                              color: recHistList[index]
                                                          .status ==
                                                      'ACTIVE'
                                                  ? greenPrimary
                                                  : recHistList[index]
                                                              .status
                                                              .toLowerCase() ==
                                                          'paid'
                                                      ? greenPrimary
                                                      : redPrimary,
                                            ),
                                            child: Text(
                                              recHistList[index]
                                                  .status
                                                  .toUpperCase(),
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : whiteColor,
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
                          ),
                        );
                      }
                    }
                    if (snapshot.data is RecStatusList) {
                      initRecurringStatusList = snapshot.data.data.result;
                      recurringStatusList = initRecurringStatusList;
                      if (selected == 0) {
                        recurringStatusList = initRecurringStatusList;
                      }
                      if (selected == 1) {
                        List<ResultRecurringStatusList> result = [];
                        for (var el in recurringStatusList) {
                          if (el.status.toLowerCase() == 'active') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        recurringStatusList = result;
                      }
                      if (selected == 2) {
                        List<ResultRecurringStatusList> result = [];
                        for (var el in recurringStatusList) {
                          if (el.status.toLowerCase() == 'stopped') {
                            result.add(el);
                          }
                        }
                        // topuphistlist.clear();
                        recurringStatusList = result;
                      }
                      if (recurringStatusList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/handling/search_empty.png',
                                height: 250,
                                width: 250,
                              ),
                              Text(
                                AppLocalizations.of(context)!.reportEmpty,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary2,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: recurringStatusList.length,
                              itemBuilder: (context, index) {
                                DateTime? trxDate = DateTime.parse(
                                        recurringStatusList[index]
                                            .transactionDate)
                                    .toLocal();
                                String setTrxDate =
                                    DateFormat('dd MMMM yyyy').format(trxDate);
                                DateTime? nextTrxDate = DateTime.parse(
                                        recurringStatusList[index]
                                            .nextTransaction)
                                    .toLocal();
                                String setNextTrxDate =
                                    DateFormat('dd MMMM yyyy')
                                        .format(nextTrxDate);
                                return GestureDetector(
                                  onTap: () {
                                    // Navigator.pushNamed(context,
                                    //     '/recurringstatusdetail');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecurringStatusDetail(
                                            status: recurringStatusList[index]
                                                .status,
                                            orderID: recurringStatusList[index]
                                                .orderId,
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
                                        12,
                                      ),
                                      color: widget.darkMode
                                          ? whiteCardColor
                                          : null,
                                      border: Border.all(
                                        width: 1,
                                        color: widget.darkMode
                                            ? Colors.transparent
                                            : greyColor,
                                      ),
                                    ),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // const SizedBox(
                                        //   height: 10,
                                        // ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .recurringPaymentNumber,
                                                style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3),
                                              ),
                                            ),
                                            Text(
                                              recurringStatusList[index]
                                                  .orderId,
                                              style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackPrimary),
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
                                              AppLocalizations.of(context)!
                                                  .package,
                                              style: reguler.copyWith(
                                                  fontSize: 12,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary3),
                                            ),
                                            Text(
                                              recurringStatusList[index]
                                                  .package,
                                              style: reguler.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                    'assets/startfinishdate.png'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .transactionDate,
                                                      style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .nextPayment,
                                                      style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  setTrxDate,
                                                  style: reguler.copyWith(
                                                      fontSize: 12,
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackPrimary),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  setNextTrxDate,
                                                  style: reguler.copyWith(
                                                      fontSize: 12,
                                                      color: blackPrimary),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Divider(
                                          height: 2,
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
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary3),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  NumberFormat.currency(
                                                    locale: 'id',
                                                    decimalDigits: 0,
                                                    symbol: 'Rp. ',
                                                  ).format(double.parse(
                                                      recurringStatusList[index]
                                                          .totalPrice
                                                          .toString())),
                                                  style: bold.copyWith(
                                                      fontSize: 12,
                                                      color: blackPrimary),
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
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary3),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  '${recurringStatusList[index].totalUnit} ${AppLocalizations.of(context)!.unitCart}',
                                                  style: bold.copyWith(
                                                      fontSize: 12,
                                                      color: blackPrimary),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: recurringStatusList[
                                                                      index]
                                                                  .status
                                                                  .toLowerCase() ==
                                                              'stopped'
                                                          ? redPrimary
                                                          : greenPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: 85,
                                                    height: 25,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            recurringStatusList[
                                                                    index]
                                                                .status,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: reguler.copyWith(
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : whiteColor,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        );
                      }
                    }
                  }
                } else {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Card(
                            margin: const EdgeInsets.all(15),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: SkeletonTheme(
                                  themeMode: widget.darkMode
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                  child: const SkeletonAvatar(
                                    style: SkeletonAvatarStyle(
                                        shape: BoxShape.rectangle,
                                        width: 140,
                                        height: 30),
                                  )),
                            ));
                      });
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
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: SkeletonTheme(
                                themeMode: widget.darkMode
                                    ? ThemeMode.dark
                                    : ThemeMode.light,
                                child: const SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      shape: BoxShape.rectangle,
                                      width: 140,
                                      height: 30),
                                )),
                          ));
                    });
              },
            ),
          )
        ]));
  }
}
