// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/recurringstatuslist.model.dart';
import 'package:gpsid/pages/recurringstatusdetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class RecurringStatusList extends StatefulWidget {
  final bool darkMode;
  const RecurringStatusList({Key? key, required this.darkMode})
      : super(key: key);

  @override
  State<RecurringStatusList> createState() => _RecurringStatusListState();
}

class _RecurringStatusListState extends State<RecurringStatusList> {
  // @override
  // void dispose() {
  //   super.dispose();
  // }
  late RecStatusList recurringStatusList;
  late Future<dynamic> _getRecurringStatusList;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getRecurringStatusList = getRecurringStatusList();
  }

  Future<dynamic> getRecurringStatusList() async {
    final result = await APIService().getRecurringStatusList();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // size = MediaQuery.of(context).size;
    // width = size.width;
    // height = size.height;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  blueGradientSecondary1,
                  blueGradientSecondary2,
                ],
              ),
            ),
          ),
          leading: IconButton(
            iconSize: 32,
            // padding: const EdgeInsets.only(top: 20),
            icon: const Icon(Icons.arrow_back_outlined),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.recurringStatusPage,
            style: bold.copyWith(
              fontSize: 16,
              color: whiteColor,
            ),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FutureBuilder(
                  future: _getRecurringStatusList,
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
                        recurringStatusList = snapshot.data;
                        if (recurringStatusList.data.result.isEmpty) {
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
                              itemCount: recurringStatusList.data.result.length,
                              itemBuilder: (context, index) {
                                DateTime? trxDate = DateTime.parse(
                                        recurringStatusList
                                            .data.result[index].transactionDate)
                                    .toLocal();
                                String setTrxDate =
                                    DateFormat('dd MMMM yyyy').format(trxDate);
                                DateTime? nextTrxDate = DateTime.parse(
                                        recurringStatusList
                                            .data.result[index].nextTransaction)
                                    .toLocal();
                                String setNextTrxDate =
                                    DateFormat('dd MMMM yyyy')
                                        .format(nextTrxDate);
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.90,
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      // Navigator.pushNamed(context,
                                                      //     '/recurringstatusdetail');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RecurringStatusDetail(
                                                              status:
                                                                  recurringStatusList
                                                                      .data
                                                                      .result[
                                                                          index]
                                                                      .status,
                                                              orderID:
                                                                  recurringStatusList
                                                                      .data
                                                                      .result[
                                                                          index]
                                                                      .orderId,
                                                              darkMode: widget
                                                                  .darkMode,
                                                            ),
                                                          ));
                                                    },
                                                    child: Card(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color:
                                                                      greyColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child:
                                                              SingleChildScrollView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.of(context)!
                                                                            .recurringPaymentNumber,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                blackSecondary3),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      recurringStatusList
                                                                          .data
                                                                          .result[
                                                                              index]
                                                                          .orderId,
                                                                      style: bold.copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              blackPrimary),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .package,
                                                                      style: reguler.copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              blackSecondary3),
                                                                    ),
                                                                    Text(
                                                                      recurringStatusList
                                                                          .data
                                                                          .result[
                                                                              index]
                                                                          .package,
                                                                      style: reguler.copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              blackPrimary),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          130,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Image.asset(
                                                                              'assets/startfinishdate.png'),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                AppLocalizations.of(context)!.transactionDate,
                                                                                style: reguler.copyWith(fontSize: 12, color: blackSecondary3),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Text(
                                                                                AppLocalizations.of(context)!.nextPayment,
                                                                                style: reguler.copyWith(fontSize: 12, color: blackSecondary3),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          setTrxDate,
                                                                          style: reguler.copyWith(
                                                                              fontSize: 12,
                                                                              color: blackPrimary),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
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
                                                                  height: 20,
                                                                ),
                                                                Divider(
                                                                  height: 2,
                                                                  thickness: 1,
                                                                  indent: 0,
                                                                  endIndent: 0,
                                                                  color:
                                                                      greyColor,
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          AppLocalizations.of(context)!
                                                                              .totalPrice,
                                                                          style: reguler.copyWith(
                                                                              fontSize: 12,
                                                                              color: blackSecondary3),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          NumberFormat
                                                                              .currency(
                                                                            locale:
                                                                                'id',
                                                                            decimalDigits:
                                                                                0,
                                                                            symbol:
                                                                                'Rp. ',
                                                                          ).format(double.parse(recurringStatusList
                                                                              .data
                                                                              .result[index]
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          AppLocalizations.of(context)!
                                                                              .totalUnit,
                                                                          style: reguler.copyWith(
                                                                              fontSize: 12,
                                                                              color: blackSecondary3),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          '${recurringStatusList.data.result[index].totalUnit} ${AppLocalizations.of(context)!.unitCart}',
                                                                          style: bold.copyWith(
                                                                              fontSize: 12,
                                                                              color: blackPrimary),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              color: recurringStatusList.data.result[index].status.toLowerCase() == 'stopped' ? redSecondary : greenSecondary,
                                                                              borderRadius: BorderRadius.circular(4)),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                80,
                                                                            height:
                                                                                24,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(recurringStatusList.data.result[index].status, textAlign: TextAlign.center, style: TextStyle(color: recurringStatusList.data.result[index].status.toLowerCase() == 'stopped' ? redPrimary : greenPrimary)),
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
                                                          )),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              });
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
                  }),
            )
          ],
        ));
  }
}
