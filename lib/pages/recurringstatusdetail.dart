// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/recurringstatusdetail.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class RecurringStatusDetail extends StatefulWidget {
  final String orderID;
  final String status;
  final bool darkMode;
  const RecurringStatusDetail(
      {Key? key,
      required this.orderID,
      required this.status,
      required this.darkMode})
      : super(key: key);

  @override
  State<RecurringStatusDetail> createState() => _RecurringStatusDetailState();
}

class _RecurringStatusDetailState extends State<RecurringStatusDetail> {
  late RecurringStatusDetailModel statusDetail;
  late Future<dynamic> _getRecurringStatusDetail;
  bool showStop = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getRecurringStatusDetail = getRecurringStatusDetail();
  }

  Future<dynamic> getRecurringStatusDetail() async {
    final result = await APIService().getRecurringStatusDetail(widget.orderID);
    return result;
  }

  stopRecurring(String username, String orderID, String domain) async {
    await Dialogs().loadingDialog(context);
    final res = await APIService().stopRecurring(username, orderID, domain);
    if (res is ErrorTrapModel) {
      Navigator.of(context).pop();
      showInfoAlert(context, res.statusError, res.bodyError);
    } else {
      if (res is MessageModel) {
        Navigator.of(context).pop();
        showInfoAlert(context, res.message, '');
      }
    }
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
                widget.darkMode ? whiteCardColor : blueGradientSecondary1,
                widget.darkMode ? whiteCardColor : blueGradientSecondary2,
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
          AppLocalizations.of(context)!.detailRecurringStatus,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getRecurringStatusDetail,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              showStop = false;
              if (snapshot.data is ErrorTrapModel) {
                showStop = false;
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
                statusDetail = snapshot.data;
                widget.status.toLowerCase() != 'stopped'
                    ? showStop = true
                    : showStop = false;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!
                                            .paymentInfo,
                                        style: bold.copyWith(
                                          fontSize: 16,
                                          color: blueGradient,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Card(
                              color: whiteCardColor,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: whiteCardColor),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
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
                                              statusDetail.data.orderId,
                                              style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
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
                                                      : blackSecondary3),
                                            ),
                                            Text(
                                              '${statusDetail.data.detailUnit.length} ${AppLocalizations.of(context)!.unitCart}',
                                              style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
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
                                                      : blackSecondary3),
                                            ),
                                            Text(
                                              NumberFormat.currency(
                                                locale: 'id',
                                                decimalDigits: 0,
                                                symbol: 'Rp. ',
                                              ).format(
                                                  statusDetail.data.totalPrice),
                                              style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: greenSecondary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  child: SizedBox(
                                                    width: 80,
                                                    height: 24,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            statusDetail
                                                                .data.status,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color:
                                                                    greenPrimary)),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.unitDetail,
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blueGradient,
                                    )),
                                Text(
                                  '${statusDetail.data.detailUnit.length} ${AppLocalizations.of(context)!.unitCart}',
                                  style: bold.copyWith(
                                      fontSize: 12, color: blackPrimary),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 2.2,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: statusDetail.data.detailUnit.length,
                                padding: const EdgeInsets.only(bottom: 70),
                                itemBuilder: (context, index) {
                                  DateTime? getExp = DateTime.parse(statusDetail
                                          .data.detailUnit[index].expired)
                                      .toLocal();
                                  String setExp =
                                      DateFormat('dd MMMM yyyy').format(getExp);
                                  DateTime? getNextExp = DateTime.parse(
                                          statusDetail.data.detailUnit[index]
                                              .nextExpired)
                                      .toLocal();
                                  String setNextExp = DateFormat('dd MMMM yyyy')
                                      .format(getNextExp);
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
                                                      },
                                                      child: Card(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10),
                                                        color: whiteCardColor,
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: widget
                                                                        .darkMode
                                                                    ? Colors
                                                                        .transparent
                                                                    : greyColor),
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
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .licensePlate,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3),
                                                                      ),
                                                                      Text(
                                                                        statusDetail
                                                                            .data
                                                                            .detailUnit[index]
                                                                            .plate,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                blackPrimary),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .gsmNumber,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3),
                                                                      ),
                                                                      Text(
                                                                        statusDetail
                                                                            .data
                                                                            .detailUnit[index]
                                                                            .noGsm,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                blackPrimary),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .package,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3),
                                                                      ),
                                                                      Text(
                                                                        statusDetail
                                                                            .data
                                                                            .detailUnit[index]
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
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .price,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3),
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
                                                                        ).format(statusDetail
                                                                            .data
                                                                            .detailUnit[index]
                                                                            .price),
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                blackPrimary),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Divider(
                                                                    height: 2,
                                                                    thickness:
                                                                        1,
                                                                    indent: 0,
                                                                    endIndent:
                                                                        0,
                                                                    color:
                                                                        greyColor,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            AppLocalizations.of(context)!.expire,
                                                                            style:
                                                                                reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            setExp,
                                                                            style:
                                                                                bold.copyWith(fontSize: 12, color: blackPrimary),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          Text(
                                                                            AppLocalizations.of(context)!.nextExpire,
                                                                            style:
                                                                                reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            setNextExp,
                                                                            style:
                                                                                bold.copyWith(fontSize: 12, color: blackPrimary),
                                                                          ),
                                                                        ],
                                                                      ),
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
                                }),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                        visible: showStop,
                        child: Positioned(
                          bottom: 20,
                          right: 0,
                          left: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: OutlinedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: whiteColor,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          side: BorderSide(
                                              width: 1, color: redPrimary)),
                                      onPressed: () async {
                                        // loadMore();
                                        LocalData localData =
                                            await GeneralService()
                                                .readLocalUserStorage();
                                        stopRecurring(
                                            localData.Username,
                                            statusDetail.data.orderId,
                                            'portal');
                                      },
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .stopRecurring,
                                          style: reguler.copyWith(
                                              fontSize: 12, color: redPrimary),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                            ],
                          ),
                        ))
                  ],
                );
              }
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 110,
                          height: 25,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 95,
                          height: 25,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
