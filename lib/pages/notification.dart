// ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_print, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:gpsid/model/alarmnotif.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/infonotif.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/paymentnotif.model.dart';
import 'package:gpsid/model/promonotif.model.dart';
import 'package:gpsid/pages/fullmap.dart';
import 'package:gpsid/pages/notifdetail.dart';
import 'package:gpsid/pages/topuphisdetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:skeletons/skeletons.dart';

import '../common.dart';

class NotificationPage extends StatefulWidget {
  final int id;
  final bool fromNotif;
  bool darkMode;
  NotificationPage(
      {super.key,
      required this.id,
      required this.fromNotif,
      required this.darkMode});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var size, height, width;
  var current = 0;
  List<String> page = [
    'Semua',
    'Alarm',
    'Pembayaran',
    'Info',
    'Promo',
  ];
  List<IconData?> icontab = [
    Icons.taxi_alert,
    Icons.wallet,
  ];
  String iconStatus = '';
  int index = 5;
  bool unread = true;
  late Future<dynamic> _getAlarmNotif;
  late List<ResultAlarmNotif> alarmNotifList;
  late Future<dynamic> _getPaymentNotif;
  late List<DataPaymentNotif> paymentNotifList;
  late Future<dynamic> _getPromoNotif;
  late List<DataPromoNotif> promoNotifList;
  late Future<dynamic> _getInfoNotif;
  late List<DataInfoNotif> infoNotifList;
  bool loading = false;
  late LocalData localData;
  String userName = '';

  @override
  void initState() {
    super.initState();
    getLocal();
    _getAlarmNotif = getAlarmNotif(false);
    _getPaymentNotif = getPaymentNotif(false);
    _getPromoNotif = getPromoNotif(false);
    _getInfoNotif = getInfoNotif(false);
    current = widget.id;
  }

  getLocal() async {
    localData = await GeneralService().readLocalUserStorage();
    setState(() {
      userName = localData.Username;
    });
  }

  Future<dynamic> getAlarmNotif(bool isRefresh) async {
    final result = await APIService().getAlarmNotif();
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      setState(() {
        loading = false;
      });
      // isRefresh ? Dialogs().hideLoaderDialog(context) : {};
      isRefresh
          ? alarmNotifList.isNotEmpty
              ? alarmNotifList.clear()
              : {}
          : {};
    }
    return result;
  }

  Future<dynamic> getPaymentNotif(bool isRefresh) async {
    final result = await APIService().getPaymentNotif();
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      setState(() {
        loading = false;
      });
      // isRefresh ? Dialogs().hideLoaderDialog(context) : {};
      isRefresh
          ? paymentNotifList.isNotEmpty
              ? paymentNotifList.clear()
              : {}
          : {};
    }
    return result;
  }

  Future<dynamic> getPromoNotif(bool isRefresh) async {
    final result = await APIService().getPromoNotif();
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      setState(() {
        loading = false;
      });
      // isRefresh ? Dialogs().hideLoaderDialog(context) : {};
      isRefresh
          ? promoNotifList.isNotEmpty
              ? promoNotifList.clear()
              : {}
          : {};
    }
    return result;
  }

  Future<dynamic> getInfoNotif(bool isRefresh) async {
    LocalData local = await GeneralService().readLocalUserStorage();
    final result = await APIService().getInfoNotif(local.Username);
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      setState(() {
        loading = false;
      });
      // isRefresh ? Dialogs().hideLoaderDialog(context) : {};
      isRefresh
          ? infoNotifList.isNotEmpty
              ? infoNotifList.clear()
              : {}
          : {};
    }
    return result;
  }

  Future doRefreshAlarm() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      // await Dialogs().loadingDialog(context);
      _getAlarmNotif = getAlarmNotif(true);
    }
  }

  Future doRefreshPayment() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      // await Dialogs().loadingDialog(context);
      _getPaymentNotif = getPaymentNotif(true);
    }
  }

  Future doRefreshInfo() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      // await Dialogs().loadingDialog(context);
      _getInfoNotif = getInfoNotif(true);
    }
  }

  Future doRefreshPromo() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      // await Dialogs().loadingDialog(context);
      _getPromoNotif = getPromoNotif(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Visibility(
              visible: widget.fromNotif,
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await GeneralService().deleteLocalNotifAlarm();
                      // _doRefresh();
                    },
                    child: Icon(
                      Icons.close_outlined,
                      size: 32,
                      color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                    )),
              ),
            ),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: widget.darkMode
                  ? LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        whiteCardColor,
                        whiteCardColor,
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        blueGradientSecondary1,
                        blueGradientSecondary2,
                      ],
                    ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Notifications',
            style: bold.copyWith(
              fontSize: 16,
              color: widget.darkMode ? whiteColorDarkMode : whiteColor,
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    alignment: Alignment.center,
                    width: width,
                    height: 50,
                    decoration: BoxDecoration(color: whiteColor),
                    child: ListView.builder(
                      itemCount: 4,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              current = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 5, left: 5),
                            width: userName == 'demo' ? 200 : 120,
                            // padding: const EdgeInsets.symmetric(
                            //   horizontal: 10,
                            // ),
                            height: 24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: current == index
                                    ? index == 0
                                        ? redPrimary
                                        : index == 1
                                            ? purplePrimary
                                            : index == 2
                                                ? yellowPrimary
                                                : index == 3
                                                    ? greenPrimary
                                                    : whiteColor
                                    : widget.darkMode
                                        ? whiteCardColor
                                        : whiteColor,
                                border: Border.all(
                                    width: 1,
                                    color: current == index
                                        ? index == 0
                                            ? redPrimary
                                            : index == 1
                                                ? purplePrimary
                                                : index == 2
                                                    ? yellowPrimary
                                                    : index == 3
                                                        ? greenPrimary
                                                        : whiteColor
                                        : widget.darkMode
                                            ? whiteCardColor
                                            : greyColor)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                index == 0
                                    ? Icon(
                                        Icons.taxi_alert,
                                        size: 16,
                                        color: current == index
                                            ? widget.darkMode
                                                ? whiteColorDarkMode
                                                : whiteColor
                                            : widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackSecondary3,
                                      )
                                    : index == 1
                                        ? Icon(
                                            Icons.wallet,
                                            size: 16,
                                            color: current == index
                                                ? widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : whiteColor
                                                : widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                          )
                                        : index == 2
                                            ? Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: current == index
                                                    ? widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : whiteColor
                                                    : widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                              )
                                            : Icon(
                                                Icons.discount,
                                                size: 16,
                                                color: current == index
                                                    ? widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : whiteColor
                                                    : widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                              ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  index == 0
                                      ? AppLocalizations.of(context)!.alarm
                                      : index == 1
                                          ? AppLocalizations.of(context)!
                                              .payment
                                          : index == 2
                                              ? 'Info'
                                              : 'Promo',
                                  style: reguler.copyWith(
                                    fontSize: 12,
                                    color: current == index
                                        ? widget.darkMode
                                            ? whiteColorDarkMode
                                            : whiteColor
                                        : widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                Expanded(
                  child: Container(
                    color: whiteColor,
                    height: 20,
                    child: FutureBuilder(
                        future: Future.wait([
                          _getAlarmNotif,
                          _getPaymentNotif,
                          _getPromoNotif,
                          _getInfoNotif
                        ]),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (loading) {
                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return Card(
                                      margin: const EdgeInsets.only(
                                          bottom: 20, left: 10, right: 10),
                                      child: SizedBox(
                                        height: 121,
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
                          } else {
                            if (snapshot.hasData) {
                              if (snapshot.data[0] is ErrorTrapModel ||
                                  snapshot.data[1] is ErrorTrapModel ||
                                  snapshot.data[2] is ErrorTrapModel ||
                                  snapshot.data[3] is ErrorTrapModel) {
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
                                              left: 50, right: 50, top: 10),
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
                                              left: 30, right: 30, top: 10),
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
                                alarmNotifList = snapshot.data[0].data.result;
                                paymentNotifList = snapshot.data[1].data;
                                promoNotifList = snapshot.data[2].data;
                                infoNotifList = snapshot.data[3].data;
                                // allData.addAll([
                                //   snapshot.data[1].data.result,
                                //   snapshot.data[2].data.result,
                                //   snapshot.data[0].data.result,
                                //   snapshot.data[3].data.result
                                // ]);

                                // allData.add(paymentNotifList[0]);
                                // allData.add(promoNotifList[0]);
                                // allData.add(infoNotifList[0]);
                                // allData = [
                                //   paymentNotifList,
                                //   promoNotifList,
                                //   alarmNotifList,
                                //   infoNotifList
                                // ];
                                return current == 0
                                    ? alarmNotifList.isEmpty
                                        ? RefreshIndicator(
                                            onRefresh: () async {
                                              await doRefreshAlarm();
                                            },
                                            child: ListView.builder(
                                              itemCount: 1,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 60),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.asset(
                                                          'assets/handling/emptyalarmnotif.png',
                                                          height: 240,
                                                          width: 240,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 50,
                                                                  right: 50,
                                                                  top: 10),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .emptyAlarmNotif,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 14,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary2,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 30,
                                                                  right: 30,
                                                                  top: 10),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .emptyAlarmNotifSub,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 12,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary2,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : RefreshIndicator(
                                            onRefresh: () async {
                                              await doRefreshAlarm();
                                            },
                                            child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              itemCount: alarmNotifList.length,
                                              itemBuilder: (context, index) {
                                                Locale myLocale =
                                                    Localizations.localeOf(
                                                        context);
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FullMapPage(
                                                          pLat: double.parse(
                                                              alarmNotifList[
                                                                      index]
                                                                  .lat),
                                                          pLng: double.parse(
                                                              alarmNotifList[
                                                                      index]
                                                                  .lon),
                                                          plate: alarmNotifList[
                                                                  index]
                                                              .plat,
                                                          darkMode:
                                                              widget.darkMode,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      bottom: 5,
                                                    ),
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        top: 4,
                                                        bottom: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: unread
                                                              ? widget.darkMode
                                                                  ? whiteCardColor
                                                                  : whiteColor
                                                              : whiteCardColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteCardColor
                                                                    : blackPrimary
                                                                        .withOpacity(
                                                                            0.12),
                                                                spreadRadius: 0,
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                        0, 2))
                                                          ],
                                                          border: Border.all(
                                                              width: 1,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteCardColor
                                                                  : const Color
                                                                      .fromARGB(
                                                                      100,
                                                                      242,
                                                                      245,
                                                                      247)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4)),
                                                      // color: unread
                                                      //     ? whiteColor
                                                      //     : whiteCardColor,
                                                      // elevation: unread ? 1 : 0,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 12,
                                                          horizontal: 20,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .taxi_alert,
                                                                      color:
                                                                          redPrimary,
                                                                      size: 16,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      alarmNotifList[
                                                                              index]
                                                                          .code,
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            10,
                                                                        color:
                                                                            redPrimary,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  alarmNotifList[
                                                                          index]
                                                                      .time,
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackPrimary,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 12,
                                                            ),
                                                            Text(
                                                              alarmNotifList[
                                                                      index]
                                                                  .plat,
                                                              style:
                                                                  bold.copyWith(
                                                                fontSize: 12,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary1,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              myLocale.languageCode ==
                                                                      'en'
                                                                  ? alarmNotifList[
                                                                          index]
                                                                      .bodyEn
                                                                  : alarmNotifList[
                                                                          index]
                                                                      .bodyId,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 10,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary3,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ))
                                    : current == 2
                                        ? infoNotifList.isEmpty
                                            ? RefreshIndicator(
                                                onRefresh: () async {
                                                  await doRefreshInfo();
                                                },
                                                child: ListView.builder(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  itemCount: 1,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 60),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Image.asset(
                                                              'assets/handling/emptyinfonotif.png',
                                                              height: 240,
                                                              width: 240,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 50,
                                                                      right: 50,
                                                                      top: 10),
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .emptyInfoNotif,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary2,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 30,
                                                                      right: 30,
                                                                      top: 10),
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .emptyInfoNotifSub,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 12,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary2,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : RefreshIndicator(
                                                onRefresh: () async {
                                                  await doRefreshInfo();
                                                },
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount:
                                                      infoNotifList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    Locale myLocale =
                                                        Localizations.localeOf(
                                                            context);
                                                    return InkWell(
                                                      onTap: () {
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //     builder: (context) =>
                                                        //         VehicleDetail(
                                                        //       imei: vehicleList[index]
                                                        //           .imei,
                                                        //       expDate:
                                                        //           vehicleList[index]
                                                        //               .expiredDate,
                                                        //       deviceName:
                                                        //           vehicleList[index]
                                                        //               .deviceName,
                                                        //       gpsType:
                                                        //           vehicleList[index]
                                                        //               .gpsName,
                                                        //       vehStatus:
                                                        //           vehicleList[index]
                                                        //               .status,
                                                        //     ),
                                                        //   ),
                                                        // );
                                                      },
                                                      child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          NotifDetail(
                                                                            from:
                                                                                'info',
                                                                            title: myLocale.languageCode == 'en'
                                                                                ? infoNotifList[index].titleEn
                                                                                : infoNotifList[index].title,
                                                                            desc: myLocale.languageCode == 'en'
                                                                                ? infoNotifList[index].descriptionEn
                                                                                : infoNotifList[index].description,
                                                                            pic:
                                                                                infoNotifList[index].picture,
                                                                            snk:
                                                                                infoNotifList[index].syaratKetentuan,
                                                                            subtitle:
                                                                                infoNotifList[index].subTitle,
                                                                            darkMode:
                                                                                widget.darkMode,
                                                                          )));
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 10,
                                                            right: 10,
                                                            bottom: 5,
                                                          ),
                                                          child: Card(
                                                            color: unread
                                                                ? widget.darkMode
                                                                    ? whiteCardColor
                                                                    : whiteColor
                                                                : whiteCardColor,
                                                            elevation:
                                                                unread ? 1 : 0,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20,
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.info_outline,
                                                                            color:
                                                                                yellowPrimary,
                                                                            size:
                                                                                16,
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            myLocale.languageCode == 'en'
                                                                                ? infoNotifList[index].titleEn
                                                                                : infoNotifList[index].title,
                                                                            style:
                                                                                bold.copyWith(
                                                                              fontSize: 10,
                                                                              color: yellowPrimary,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        infoNotifList[index]
                                                                            .startPublish,
                                                                        style: reguler
                                                                            .copyWith(
                                                                          fontSize:
                                                                              10,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackPrimary,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  Text(
                                                                    myLocale.languageCode ==
                                                                            'en'
                                                                        ? infoNotifList[index]
                                                                            .descriptionEn
                                                                        : infoNotifList[index]
                                                                            .description,
                                                                    style: bold
                                                                        .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary1,
                                                                    ),
                                                                  ),
                                                                  // const SizedBox(
                                                                  //   height: 4,
                                                                  // ),
                                                                  // Text(
                                                                  //   alarmNotifList[index]
                                                                  //       .bodyEn,
                                                                  //   style: reguler.copyWith(
                                                                  //     fontSize: 10,
                                                                  //     color: blackSecondary3,
                                                                  //   ),
                                                                  // )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                        : current == 3
                                            ? promoNotifList.isEmpty
                                                ? RefreshIndicator(
                                                    onRefresh: () async {
                                                      await doRefreshPromo();
                                                    },
                                                    child: ListView.builder(
                                                      itemCount: 1,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 60),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Image.asset(
                                                                  'assets/handling/emptypromonotif.png',
                                                                  height: 240,
                                                                  width: 240,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              50,
                                                                          right:
                                                                              50,
                                                                          top:
                                                                              10),
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .emptyPromoNotif,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: bold
                                                                        .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary2,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              30,
                                                                          right:
                                                                              30,
                                                                          top:
                                                                              10),
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .emptyPromoNotifSub,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : RefreshIndicator(
                                                    onRefresh: () async {
                                                      await doRefreshPromo();
                                                    },
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          promoNotifList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            NotifDetail(
                                                                              from: 'promo',
                                                                              title: promoNotifList[index].title,
                                                                              desc: promoNotifList[index].description,
                                                                              pic: promoNotifList[index].picture,
                                                                              snk: promoNotifList[index].syaratKetentuan,
                                                                              subtitle: promoNotifList[index].subTitle,
                                                                              darkMode: widget.darkMode,
                                                                            )));
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 10,
                                                              right: 10,
                                                              bottom: 5,
                                                            ),
                                                            child: Card(
                                                              color: unread
                                                                  ? whiteColor
                                                                  : whiteCardColor,
                                                              elevation: unread
                                                                  ? 1
                                                                  : 0,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.discount,
                                                                              color: greenPrimary,
                                                                              size: 16,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            Text(
                                                                              promoNotifList[index].title,
                                                                              style: bold.copyWith(
                                                                                fontSize: 10,
                                                                                color: greenPrimary,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        // Text(
                                                                        //   promoNotifList[
                                                                        //           index]
                                                                        //       .title,
                                                                        //   style: reguler
                                                                        //       .copyWith(
                                                                        //     fontSize:
                                                                        //         10,
                                                                        //     color:
                                                                        //         blackPrimary,
                                                                        //   ),
                                                                        // )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    Text(
                                                                      promoNotifList[
                                                                              index]
                                                                          .subTitle,
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : blackSecondary1,
                                                                      ),
                                                                    ),
                                                                    // const SizedBox(
                                                                    //   height: 4,
                                                                    // ),
                                                                    // Text(
                                                                    //   promoNotifList[index]
                                                                    //       .content,
                                                                    //   style: reguler.copyWith(
                                                                    //     fontSize: 10,
                                                                    //     color:
                                                                    //         blackSecondary3,
                                                                    //   ),
                                                                    // )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                            : paymentNotifList.isEmpty
                                                ? RefreshIndicator(
                                                    onRefresh: () async {
                                                      await doRefreshPayment();
                                                    },
                                                    child: ListView.builder(
                                                      physics:
                                                          const AlwaysScrollableScrollPhysics(),
                                                      itemCount: 1,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 60),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Image.asset(
                                                                  'assets/handling/emptypaymentnotif.png',
                                                                  height: 240,
                                                                  width: 240,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              50,
                                                                          right:
                                                                              50,
                                                                          top:
                                                                              10),
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .emptyPaymentNotif,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: bold
                                                                        .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary2,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              30,
                                                                          right:
                                                                              30,
                                                                          top:
                                                                              10),
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .emptyPaymentNotifSub,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : RefreshIndicator(
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          paymentNotifList
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            TopupHistoryDetail(
                                                                              orderID: paymentNotifList[index].orderId,
                                                                              darkMode: widget.darkMode,
                                                                            )));
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 10,
                                                              right: 10,
                                                              bottom: 5,
                                                            ),
                                                            child: Card(
                                                              color: unread
                                                                  ? widget.darkMode
                                                                      ? whiteCardColor
                                                                      : whiteColor
                                                                  : whiteCardColor,
                                                              elevation: unread
                                                                  ? 1
                                                                  : 0,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.wallet,
                                                                              color: purplePrimary,
                                                                              size: 16,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            Text(
                                                                              'Payment',
                                                                              style: bold.copyWith(
                                                                                fontSize: 10,
                                                                                color: purplePrimary,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          paymentNotifList[index]
                                                                              .dateInserted,
                                                                          style:
                                                                              reguler.copyWith(
                                                                            fontSize:
                                                                                10,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackPrimary,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    Text(
                                                                      paymentNotifList[
                                                                              index]
                                                                          .description,
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : blackSecondary1,
                                                                      ),
                                                                    ),
                                                                    // const SizedBox(
                                                                    //   height: 4,
                                                                    // ),
                                                                    // Text(
                                                                    //   alarmNotifList[index]
                                                                    //       .bodyEn,
                                                                    //   style: reguler.copyWith(
                                                                    //     fontSize: 10,
                                                                    //     color: blackSecondary3,
                                                                    //   ),
                                                                    // )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    onRefresh: () async {
                                                      await doRefreshPayment();
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
                                    margin: const EdgeInsets.only(
                                        bottom: 20, left: 10, right: 10),
                                    child: SizedBox(
                                      height: 121,
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
                        }),
                  ),
                )
              ],
            )
          ],
        ));
  }

  //TabBar Widget
  tabBar(
      bool all, dynamic txt, Color activeColor, IconData iconData, int index) {
    if (all) {
      return GestureDetector(
        onTap: () {
          setState(() {
            current = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 20, left: 20),
          // padding: const EdgeInsets.symmetric(
          //   horizontal: 20,
          //   vertical: 6,
          // ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: current == index ? activeColor : whiteColor,
            border: Border.all(
              width: 1.5,
              color: current == index ? activeColor : blackSecondary3,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.all,
            style: reguler.copyWith(
              fontSize: 12,
              color: current == index ? whiteColor : blackSecondary3,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            current = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 5, left: 5),
          width: userName == 'demo' ? 200 : 120,
          // padding: const EdgeInsets.symmetric(
          //   horizontal: 10,
          // ),
          height: 24,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: current == index ? activeColor : whiteColor,
              border: Border.all(
                width: 1,
                color: current == index ? activeColor : greyColor,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 16,
                color: current == index ? whiteColor : blackSecondary3,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                txt,
                style: reguler.copyWith(
                  fontSize: 12,
                  color: current == index ? whiteColor : blackSecondary3,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

// cardNotif Widget
  cardNotif(
    String status,
    String content,
    String subcontent,
    Color clr,
    IconData iconData,
    bool unread,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          unread = !unread;
          print(unread);
        });
      },
      child: SizedBox(
        width: double.infinity,
        height: 115,
        child: Card(
          color: unread ? whiteColor : whiteCardColor,
          elevation: unread ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          iconData,
                          color: clr,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          status,
                          style: bold.copyWith(
                            fontSize: 10,
                            color: clr,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '12 Januari 2022, 12:00',
                      style: reguler.copyWith(
                        fontSize: 10,
                        color: blackPrimary,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  content,
                  style: bold.copyWith(
                    fontSize: 12,
                    color: blackSecondary1,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subcontent,
                  style: reguler.copyWith(
                    fontSize: 10,
                    color: blackSecondary3,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _timer.isActive ? _timer.cancel() : {};
    super.dispose();
  }
}
