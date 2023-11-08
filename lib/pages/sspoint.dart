// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/currentpoin.sspoin.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/pointhistory.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

class SSPoint extends StatefulWidget {
  final bool darkMode;
  const SSPoint({super.key, required this.darkMode});

  @override
  State<SSPoint> createState() => _SSPointState();
}

var size, width, height;

class _SSPointState extends State<SSPoint> {
  late SSPOINCurrentPoinModel currentPoint;
  late Future<dynamic> _getCurrentPoint;
  late LocalData localData;
  late Future<dynamic> _getPointHist;
  late PointHistoryModel pointHist;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getCurrentPoint = getCurrentPoint();
    _getPointHist = getPointHist();
  }

  refresh() async {
    Dialogs().loadingDialog(context);
    _getCurrentPoint = getCurrentPoint();
    _getPointHist = getPointHist();
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        Dialogs().hideLoaderDialog(context);
      },
    );
  }

  Future<dynamic> getCurrentPoint() async {
    final result = await APIService().getCurrentPoin();
    localData = await GeneralService().readLocalUserStorage();
    // setState(() {});
    return result;
  }

  Future<dynamic> getPointHist() async {
    var dateFrom = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);
    var dateTo = DateTime.now();
    var getDateFrom = DateFormat('yyyy-MM-dd').format(dateFrom.toLocal());
    var getDateTo = DateFormat('yyyy-MM-dd').format(dateTo.toLocal());
    print('$getDateFrom / $getDateTo');
    final result = await APIService().getPointHistory(getDateFrom, getDateTo);
    if (result is! PointHistoryModel) {
      showInfoAlert(context, result.status, '');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: widget.darkMode ? whiteCardColor : bluePrimary,
          automaticallyImplyLeading: false,
          title: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SSPoin',
                    // style: const TextStyle(fontSize: 16),
                    style: bold.copyWith(
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/redeemStatus');
                    },
                    child: const Icon(Icons.notifications_none),
                  )
                ],
              )
            ],
          )),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getCurrentPoint,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                currentPoint = snapshot.data;
                return SizedBox(
                  // decoration: BoxDecoration(
                  //   color: redPrimary,
                  // ),
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: widget.darkMode ? whiteCardColor : bluePrimary,
                        ),
                        width: width,
                        height: 170,
                        child: Text(
                          '${AppLocalizations.of(context)!.collectPoin}'
                          '\n'
                          '${AppLocalizations.of(context)!.getPrize}',
                          style: bold.copyWith(
                            fontSize: 24,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : whiteColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 155,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: whiteColor,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const SizedBox(
                                  //   height: 76,
                                  // ),
                                  Text(
                                    AppLocalizations.of(context)!.referralCode,
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    width: double.infinity,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: whiteCardColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(),
                                        Text(
                                          localData.Username,
                                          style: reguler.copyWith(
                                            fontSize: 14,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackSecondary3,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: localData.Username))
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      backgroundColor:
                                                          blueGradient,
                                                      content: const Text(
                                                        "Copied",
                                                        textAlign:
                                                            TextAlign.center,
                                                      )));
                                            });
                                            var dateFrom = DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month - 1,
                                                DateTime.now().day);
                                            var dateTo = DateTime.now();
                                            var getDateFrom =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(dateFrom.toLocal());
                                            var getDateTo =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(dateTo.toLocal());
                                            print('$getDateFrom / $getDateTo');
                                          },
                                          child: Icon(
                                            Icons.copy_outlined,
                                            color: bluePrimary,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.getPoints,
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blackPrimary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 300,
                                    child: TitleScrollNavigation(
                                      barStyle: TitleNavigationBarStyle(
                                          activeColor: bluePrimary,
                                          background: whiteColor,
                                          deactiveColor: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary3,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          style: bold.copyWith(
                                            fontSize: 14,
                                          ),
                                          spaceBetween: 50,
                                          elevation: 0),
                                      titles: const [
                                        "Referral",
                                        "Top Up",
                                        "Add Unit",
                                        // "Trade In",
                                        "Verification",
                                      ],
                                      pages: [
                                        //Refferal
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 25,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/referral_invite.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Undang Temanmu',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Sebarkan & berikan kode referalmu kepada teman-temanmu.',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                ),
                                                child: Image.asset(
                                                  'assets/line.png',
                                                  width: 2,
                                                  color: yellowPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/referral_regis.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Temanmu Lakukan Registrasi',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Setelah mendaftarkan akun. Temanmu harus menggunakan kode referalmu ketika verifikasi email.',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                ),
                                                child: Image.asset(
                                                  'assets/line.png',
                                                  width: 2,
                                                  color: yellowPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/referral_done.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Selamat, Kamu & Temanmu Dapat Poin',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Kamu akan mendapatkan SSPoin ketika temanmu menambahkan unit kendaraan.',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Top up
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 25,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/topup_choose.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Pilih Unit Dan Jumlah Pulsa',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Pilih unit kendaraan dan Jumlah pulsa yang ingin kamu top up. Kami menyediakan berbagai pilihan jumlah pulsa.',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                ),
                                                child: Image.asset(
                                                  'assets/line.png',
                                                  width: 2,
                                                  color: yellowPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/topup_trans.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Selesaikan Transaksi Pembayaran ',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Kami menyediakan berbagai pilihan metode pembayaran yang mudah dan aman, seperti transfer bank, kartu kredit, atau e-wallet. ',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                ),
                                                child: Image.asset(
                                                  'assets/line.png',
                                                  width: 2,
                                                  color: yellowPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/topup_done.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Selamat, Kamu Mendapatkan SSPoin',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Selamat! Kamu telah berhasil mendapatkan poin melalui fitur top up. Poin yang kamu dapatkan dapat ditukarkan dengan hadiah spesial yang telah kami sediakan. ',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Add unit
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 25,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/unit_buy.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Beli Unit GPS Dari Superspring',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Kamu dapat membeli produk GPS SUPERSPRING melalui kantor pusat, cabang, agen, dan juga melalui e-commerce kami.',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                ),
                                                child: Image.asset(
                                                  'assets/line.png',
                                                  width: 2,
                                                  color: yellowPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/unit_regis.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Registrasi Kendaraan Anda',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Setelah unit terpasang pada kendaraanmu, admin kami akan membantu meregistrasikan kendaraanmu.',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                ),
                                                child: Image.asset(
                                                  'assets/line.png',
                                                  width: 2,
                                                  color: yellowPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 52,
                                                    child: Image.asset(
                                                      'assets/unit_done.png',
                                                      width: 52,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Selamat, Kamu Mendapatkan SSPoin',
                                                          style: bold.copyWith(
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
                                                        SizedBox(
                                                          width: 285,
                                                          child: Text(
                                                            'Selamat! Kamu telah berhasil mendapatkan poin dengan menambahkan unit GPS. Poin yang kamu dapatkan dapat ditukarkan dengan hadiah spesial yang telah kami sediakan. ',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Trade In
                                        // SingleChildScrollView(
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     children: [
                                        //       const SizedBox(
                                        //         height: 25,
                                        //       ),
                                        //       Row(
                                        //         children: [
                                        //           SizedBox(
                                        //             width: 52,
                                        //             child: Image.asset(
                                        //               'assets/trade_unit.png',
                                        //               width: 52,
                                        //             ),
                                        //           ),
                                        //           const SizedBox(
                                        //             width: 12,
                                        //           ),
                                        //           Expanded(
                                        //             child: Column(
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment
                                        //                       .start,
                                        //               children: [
                                        //                 Text(
                                        //                   'Ganti Unit GPS Superspring Lainnya',
                                        //                   style: bold.copyWith(
                                        //                     fontSize: 12,
                                        //                     color:
                                        //                         blackSecondary1,
                                        //                   ),
                                        //                 ),
                                        //                 const SizedBox(
                                        //                   height: 4,
                                        //                 ),
                                        //                 SizedBox(
                                        //                   width: 285,
                                        //                   child: Text(
                                        //                     'Kamu dapat tukar produk GPS SUPERSPRING melalui kantor pusat kami, agen-agen kami, dan juga melalui e-commerce.',
                                        //                     style: reguler
                                        //                         .copyWith(
                                        //                       fontSize: 10,
                                        //                       color:
                                        //                           blackSecondary3,
                                        //                     ),
                                        //                   ),
                                        //                 )
                                        //               ],
                                        //             ),
                                        //           )
                                        //         ],
                                        //       ),
                                        //       Padding(
                                        //         padding: const EdgeInsets.only(
                                        //           left: 25,
                                        //         ),
                                        //         child: Image.asset(
                                        //           'assets/line.png',
                                        //           width: 2,
                                        //           color: yellowPrimary,
                                        //         ),
                                        //       ),
                                        //       Row(
                                        //         children: [
                                        //           SizedBox(
                                        //             width: 52,
                                        //             child: Image.asset(
                                        //               'assets/trade_regis.png',
                                        //               width: 52,
                                        //             ),
                                        //           ),
                                        //           const SizedBox(
                                        //             width: 12,
                                        //           ),
                                        //           Expanded(
                                        //             child: Column(
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment
                                        //                       .start,
                                        //               children: [
                                        //                 Text(
                                        //                   'Registrasi Kendaraan Anda',
                                        //                   style: bold.copyWith(
                                        //                     fontSize: 12,
                                        //                     color:
                                        //                         blackSecondary1,
                                        //                   ),
                                        //                 ),
                                        //                 const SizedBox(
                                        //                   height: 4,
                                        //                 ),
                                        //                 SizedBox(
                                        //                   width: 285,
                                        //                   child: Text(
                                        //                     'Setelah unit baru terpasang pada kendaraanmu, teknisi kami akan membantu meregistrasikan kendaraanmu.',
                                        //                     style: reguler
                                        //                         .copyWith(
                                        //                       fontSize: 10,
                                        //                       color:
                                        //                           blackSecondary3,
                                        //                     ),
                                        //                   ),
                                        //                 )
                                        //               ],
                                        //             ),
                                        //           )
                                        //         ],
                                        //       ),
                                        //       Padding(
                                        //         padding: const EdgeInsets.only(
                                        //           left: 25,
                                        //         ),
                                        //         child: Image.asset(
                                        //           'assets/line.png',
                                        //           width: 2,
                                        //           color: yellowPrimary,
                                        //         ),
                                        //       ),
                                        //       Row(
                                        //         children: [
                                        //           SizedBox(
                                        //             width: 52,
                                        //             child: Image.asset(
                                        //               'assets/trade_done.png',
                                        //               width: 52,
                                        //             ),
                                        //           ),
                                        //           const SizedBox(
                                        //             width: 12,
                                        //           ),
                                        //           Expanded(
                                        //             child: Column(
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment
                                        //                       .start,
                                        //               children: [
                                        //                 Text(
                                        //                   'Selamat, Kamu Mendapatkan SSPoin',
                                        //                   style: bold.copyWith(
                                        //                     fontSize: 12,
                                        //                     color:
                                        //                         blackSecondary1,
                                        //                   ),
                                        //                 ),
                                        //                 const SizedBox(
                                        //                   height: 4,
                                        //                 ),
                                        //                 SizedBox(
                                        //                   width: 285,
                                        //                   child: Text(
                                        //                     'Selamat! Kamu telah berhasil mendapatkan poin dengan penukaran unit GPS. Poin yang kamu dapatkan dapat ditukarkan dengan hadiah spesial yang telah kami sediakan. ',
                                        //                     style: reguler
                                        //                         .copyWith(
                                        //                       fontSize: 10,
                                        //                       color:
                                        //                           blackSecondary3,
                                        //                     ),
                                        //                   ),
                                        //                 )
                                        //               ],
                                        //             ),
                                        //           )
                                        //         ],
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        //Verifikasi
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 52,
                                                  child: Image.asset(
                                                    'assets/verif_1.png',
                                                    width: 52,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Verfikasi Email',
                                                        style: bold.copyWith(
                                                          fontSize: 12,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary1,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      SizedBox(
                                                        width: 285,
                                                        child: Text(
                                                          'Lakukan verifikasi email untuk mendapatkan tambahan SSPoin.',
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 25,
                                              ),
                                              child: Image.asset(
                                                'assets/line.png',
                                                width: 2,
                                                color: yellowPrimary,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 52,
                                                  child: Image.asset(
                                                    'assets/verif_2.png',
                                                    width: 52,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Verifikasi No Handphone',
                                                        style: bold.copyWith(
                                                          fontSize: 12,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary1,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      SizedBox(
                                                        width: 285,
                                                        child: Text(
                                                          'Lakukan verifikasi no handphone anda untuk mendapatkan tambahan SSPoin.',
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 10,
                                    thickness: 3,
                                    endIndent: 0,
                                    indent: 0,
                                    color: whiteCardColor,
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
                                            .lastPointHistory,
                                        style: bold.copyWith(
                                          fontSize: 16,
                                          color: blackPrimary,
                                        ),
                                      ),
                                      // Text(
                                      //   AppLocalizations.of(context)!.seeAll,
                                      //   style: reguler.copyWith(
                                      //       fontSize: 10,
                                      //       color: bluePrimary,
                                      //       decoration:
                                      //           TextDecoration.underline),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      height: 350,
                                      decoration:
                                          BoxDecoration(color: whiteCardColor),
                                      child: FutureBuilder(
                                        future: _getPointHist,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<dynamic> snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data
                                                is ErrorTrapModel) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 60),
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
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
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 50,
                                                                right: 50,
                                                                top: 10),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .error500,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: bold.copyWith(
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
                                                              .error500Sub,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              reguler.copyWith(
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
                                            } else {
                                              pointHist = snapshot.data;
                                              return pointHist
                                                      .data.result.isNotEmpty
                                                  ? ListView.builder(
                                                      itemCount: pointHist
                                                                  .data
                                                                  .result
                                                                  .length >=
                                                              5
                                                          ? 5
                                                          : pointHist.data
                                                              .result.length,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  '${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.parse(pointHist.data.result[index].trxDate).toLocal())} WIB',
                                                                  // DateFormat(pointHist.data.result[index].trxDate).toString(),
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  pointHist
                                                                          .data
                                                                          .result[
                                                                              index]
                                                                          .ssPointTrx
                                                                          .toString()
                                                                          .contains(
                                                                              '-')
                                                                      ? pointHist
                                                                          .data
                                                                          .result[
                                                                              index]
                                                                          .ssPointTrx
                                                                          .toString()
                                                                      : '+${pointHist.data.result[index].ssPointTrx.toString()}',
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: pointHist
                                                                            .data
                                                                            .result[index]
                                                                            .ssPointTrx
                                                                            .toString()
                                                                            .contains('-')
                                                                        ? redPrimary
                                                                        : greenPrimary,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  // 'Referral : ${pointHist.data.result[index].trxName}',
                                                                  pointHist
                                                                      .data
                                                                      .result[
                                                                          index]
                                                                      .trxName,
                                                                  style: bold
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        blackPrimary,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '• Berhasil',
                                                                  style: bold
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        blackPrimary,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Divider(
                                                              height: 1,
                                                              thickness: 1,
                                                              endIndent: 0,
                                                              indent: 0,
                                                              color: greyColor,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Center(
                                                          child: Image.asset(
                                                            'assets/topup_done.png',
                                                            width: 130,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .noPoinTransaction,
                                                            style: reguler.copyWith(
                                                                color:
                                                                    blackPrimary),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                            }
                                          }
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                        },
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 115,
                        left: 20,
                        right: 20,
                        child: SizedBox(
                          width: width,
                          height: 80,
                          child: Card(
                            color:
                                widget.darkMode ? whiteColor : whiteCardColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/sspoint.png',
                                        width: 40,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${currentPoint.data.currentPoint} SSPoin',
                                        style: bold.copyWith(
                                          fontSize: 16,
                                          color: bluePrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Navigator.pushNamed(
                                          context, '/redeempoint');
                                      refresh();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: yellowPrimary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .redeemPoin,
                                            style: bold.copyWith(
                                              fontSize: 8,
                                              color: blackPrimary,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 12,
                                            color: blackPrimary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
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
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                  // secondRingColor: blueGradientSecondary1,
                  // thirdRingColor: whiteColor,
                )
              ],
            );
          }),
    );
  }

  historyPoint() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '10/10/2022 , 20:00',
              style: reguler.copyWith(
                fontSize: 10,
                color: blackSecondary3,
              ),
            ),
            Text(
              '+25 SSPoin',
              style: reguler.copyWith(
                fontSize: 10,
                color: greenPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Referral : Nama',
              style: bold.copyWith(
                fontSize: 12,
                color: blackPrimary,
              ),
            ),
            Text(
              '• Berhasil',
              style: bold.copyWith(
                fontSize: 12,
                color: blackPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          height: 1,
          thickness: 1,
          endIndent: 0,
          indent: 0,
          color: greyColor,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
