// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/topuphistdetailmodel.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/pages/taxinvoiceview.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';

class TopupHistoryDetail extends StatefulWidget {
  final String orderID;
  final bool darkMode;
  const TopupHistoryDetail(
      {Key? key, required this.orderID, required this.darkMode})
      : super(key: key);

  @override
  State<TopupHistoryDetail> createState() => _TopupHistoryDetailState();
}

class _TopupHistoryDetailState extends State<TopupHistoryDetail> {
  late TopUpHistDetailModel topUpHistDetailModel;
  late Future<dynamic> _getTopupHistDetail;
  bool isPending = false;
  var maskFormatterNPWP = MaskTextInputFormatter(
      mask: '##.###.###.#-###.###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getTopupHistDetail = getTopupHistDetail();
  }

  Future<dynamic> getTopupHistDetail() async {
    String status = '';
    final result = await APIService().getTopupHistDetail(widget.orderID);
    status = result.data.result.status;
    if (status.toLowerCase() == 'pending') {
      setState(() {
        isPending = true;
      });
    } else {
      setState(() {
        isPending = false;
      });
    }
    // result.data.result.status.toLowerCase() == 'pending'
    //     ? isPending = true
    //     : isPending = false;
    return result;
  }

  cancel() async {
    Dialogs().loadingDialog(context);
    final result = await APIService().cancelTransaction(widget.orderID);
    if (result is MessageModel) {
      // Navigator.pop(context);
      // Navigator.pop(context);
      // Navigator.pop(context);
      late bool darkMode;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
      final bool? darkmode = prefs.getBool('darkmode');
      darkMode = darkmode!;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  selected: 3,
                  darkMode: darkMode,
                  secondAccess: false,
                )),
      );
      showInfoAlert(context, result.message, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  widget.darkMode ? whiteCardColor : blueGradientSecondary2,
                  widget.darkMode ? whiteCardColor : blueGradientSecondary1,
                ])),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                // onTap: () {
                //   Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => HomePage(
                //           selected: 3,
                //         ),
                //       ));
                // },
                child: const Icon(
                  Icons.arrow_back,
                  size: 26,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.detailtopup,
                style: bold.copyWith(
                  fontSize: 14,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
              Container(
                width: 10,
              )
            ],
          ),
        ),
        backgroundColor: whiteColor,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FutureBuilder(
                  future: _getTopupHistDetail,
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
                        topUpHistDetailModel = snapshot.data;
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.orderInfo,
                                  style: bold.copyWith(
                                    fontSize: 12,
                                    color: bluePrimary,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration:
                                      BoxDecoration(color: whiteCardColor),
                                  width: double.infinity,
                                  height:
                                      topUpHistDetailModel.data.result.npwpNo ==
                                              ''
                                          ? 80
                                          : 110,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order ID',
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(
                                                          text:
                                                              topUpHistDetailModel
                                                                  .data
                                                                  .result
                                                                  .orderId))
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    "Copied")));
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.copy_outlined,
                                                  color: greenPrimary,
                                                  size: 12,
                                                ),
                                              ),
                                              Text(
                                                topUpHistDetailModel
                                                    .data.result.orderId,
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: blackPrimary,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .transactionDate,
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            '${topUpHistDetailModel.data.result.trxDate}, ${topUpHistDetailModel.data.result.trxTime} WIB',
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: blackPrimary,
                                            ),
                                          )
                                        ],
                                      ),
                                      Visibility(
                                          visible: topUpHistDetailModel
                                                      .data.result.npwpNo ==
                                                  ''
                                              ? false
                                              : true,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .taxNumber,
                                                style: reguler.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary3,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    maskFormatterNPWP.maskText(
                                                        topUpHistDetailModel
                                                            .data
                                                            .result
                                                            .npwpNo),
                                                    style: reguler.copyWith(
                                                      fontSize: 10,
                                                      color: blackPrimary,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => TaxInvoiceView(
                                                                    npwpno: topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .npwpNo,
                                                                    npwpname: topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .npwpName,
                                                                    npwpaddr: topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .npwpAddr,
                                                                    npwpemail: topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .npwpEmail,
                                                                    npwpwa: topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .npwpWA,
                                                                    npwpstatus: topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .statusNpwp)));
                                                      },
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .seeDetails,
                                                        style: reguler.copyWith(
                                                            fontSize: 10,
                                                            color: bluePrimary,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.paymentDetail,
                                  style: bold.copyWith(
                                    fontSize: 12,
                                    color: bluePrimary,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration:
                                      BoxDecoration(color: whiteCardColor),
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  height: 155,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .paymentMethod,
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Text(
                                            topUpHistDetailModel
                                                .data.result.paymentType,
                                            style: bold.copyWith(
                                              fontSize: 10,
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
                                                .virtualAccount,
                                            style: reguler.copyWith(
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(
                                                          text: topUpHistDetailModel
                                                              .data
                                                              .result
                                                              .virtualAccount))
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    "Copied")));
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.copy_outlined,
                                                  color: greenPrimary,
                                                  size: 12,
                                                ),
                                              ),
                                              Text(
                                                topUpHistDetailModel
                                                    .data.result.virtualAccount,
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: blackPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        endIndent: 0,
                                        indent: 0,
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
                                                ).format(topUpHistDetailModel
                                                    .data.result.totalPrice),
                                                style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: blackPrimary,
                                                ),
                                              )
                                              // Text(
                                              //   topUpHistDetailModel
                                              //       .data.result.totalPrice
                                              //       .toString(),
                                              //   style: bold.copyWith(
                                              //     fontSize: 12,
                                              //     color: blackPrimary,
                                              //   ),
                                              // ),
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
                                                '${topUpHistDetailModel.data.result.totalUnit} Unit',
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
                                              color: topUpHistDetailModel
                                                          .data.result.status
                                                          .toLowerCase() ==
                                                      'cancel'
                                                  ? yellowSecondary
                                                  : topUpHistDetailModel.data
                                                              .result.status
                                                              .toLowerCase() ==
                                                          'pending'
                                                      ? greyColor
                                                      : topUpHistDetailModel
                                                                  .data
                                                                  .result
                                                                  .status
                                                                  .toLowerCase() ==
                                                              'success'
                                                          ? greenSecondary
                                                          : topUpHistDetailModel
                                                                      .data
                                                                      .result
                                                                      .status
                                                                      .toLowerCase() ==
                                                                  'expire'
                                                              ? greyColor
                                                              : greyColor,
                                            ),
                                            child: Text(
                                              topUpHistDetailModel
                                                  .data.result.status
                                                  .toUpperCase(),
                                              style: reguler.copyWith(
                                                fontSize: 10,
                                                color: topUpHistDetailModel
                                                            .data.result.status
                                                            .toLowerCase() ==
                                                        'cancel'
                                                    ? yellowPrimary
                                                    : topUpHistDetailModel.data
                                                                .result.status
                                                                .toLowerCase() ==
                                                            'pending'
                                                        ? blackSecondary1
                                                        : topUpHistDetailModel
                                                                    .data
                                                                    .result
                                                                    .status
                                                                    .toLowerCase() ==
                                                                'success'
                                                            ? greenPrimary
                                                            : topUpHistDetailModel
                                                                        .data
                                                                        .result
                                                                        .status
                                                                        .toLowerCase() ==
                                                                    'expire'
                                                                ? blackSecondary1
                                                                : blackSecondary1,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.detailUnit,
                                      style: bold.copyWith(
                                        fontSize: 12,
                                        color: bluePrimary,
                                      ),
                                    ),
                                    Text(
                                      '${topUpHistDetailModel.data.result.totalUnit} Unit',
                                      style: reguler.copyWith(
                                        fontSize: 12,
                                        color: blackPrimary,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height / 2.2,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: topUpHistDetailModel
                                          .data.result.cartDetail.length,
                                      padding:
                                          const EdgeInsets.only(bottom: 70),
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              // Navigator.pushNamed(context,
                                                              //     '/recurringstatusdetail');
                                                            },
                                                            child: Card(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10),
                                                              color:
                                                                  whiteCardColor,
                                                              shape: RoundedRectangleBorder(
                                                                  // side: BorderSide(
                                                                  //     color:
                                                                  //         greyColor),
                                                                  borderRadius: BorderRadius.circular(12)),
                                                              child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    physics:
                                                                        const BouncingScrollPhysics(),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              AppLocalizations.of(context)!.licensePlate,
                                                                              style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                            ),
                                                                            Text(
                                                                              topUpHistDetailModel.data.result.cartDetail[index].platNomor,
                                                                              style: reguler.copyWith(fontSize: 12, color: blackPrimary),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              AppLocalizations.of(context)!.gsmNumber,
                                                                              style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                            ),
                                                                            Text(
                                                                              topUpHistDetailModel.data.result.cartDetail[index].nomorGsm,
                                                                              style: reguler.copyWith(fontSize: 12, color: blackPrimary),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              AppLocalizations.of(context)!.package,
                                                                              style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                            ),
                                                                            Text(
                                                                              topUpHistDetailModel.data.result.cartDetail[index].paket,
                                                                              style: reguler.copyWith(fontSize: 12, color: blackPrimary),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              AppLocalizations.of(context)!.price,
                                                                              style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                            ),
                                                                            Text(
                                                                              NumberFormat.currency(
                                                                                locale: 'id',
                                                                                decimalDigits: 0,
                                                                                symbol: 'Rp. ',
                                                                              ).format(topUpHistDetailModel.data.result.cartDetail[index].harga),
                                                                              style: reguler.copyWith(fontSize: 12, color: blackPrimary),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Divider(
                                                                          height:
                                                                              2,
                                                                          thickness:
                                                                              1,
                                                                          indent:
                                                                              0,
                                                                          endIndent:
                                                                              0,
                                                                          color:
                                                                              greyColor,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  AppLocalizations.of(context)!.expire,
                                                                                  style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Text(
                                                                                  topUpHistDetailModel.data.result.cartDetail[index].expired,
                                                                                  style: bold.copyWith(fontSize: 12, color: blackPrimary),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  AppLocalizations.of(context)!.nextExpire,
                                                                                  style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Text(
                                                                                  topUpHistDetailModel.data.result.cartDetail[index].nextExpired,
                                                                                  style: bold.copyWith(fontSize: 12, color: blackPrimary),
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
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }),
                                ),
                                // Expanded(
                                //     flex: 1,
                                //     child: SizedBox(
                                //       height: 200,
                                //       width: double.infinity,
                                //       child: ListView.builder(
                                //         itemCount: topUpHistDetailModel
                                //             .data.result.cartDetail.length,
                                //         itemBuilder: (context, index) {
                                //           return Card(
                                //             child: Column(
                                //               children: [
                                //                 Text(topUpHistDetailModel
                                //                     .data
                                //                     .result
                                //                     .cartDetail[index]
                                //                     .platNomor)
                                //               ],
                                //             ),
                                //           );
                                //         },
                                //       ),
                                //     ))
                                // for (var i = 0; i < 4; i++) ...[
                                //   unitModal(context),
                                //   const SizedBox(
                                //     height: 16,
                                //   ),
                                // ]
                              ],
                            ),
                          ),
                        );
                      }
                    }
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: 110,
                                  height: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: double.infinity,
                                  height: 80,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: 95,
                                  height: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: double.infinity,
                                  height: 155,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: double.infinity,
                                  height: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 2.2,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: 3,
                                  padding: const EdgeInsets.only(bottom: 70),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SkeletonTheme(
                                          themeMode: widget.darkMode
                                              ? ThemeMode.dark
                                              : ThemeMode.light,
                                          child: const SkeletonAvatar(
                                            style: SkeletonAvatarStyle(
                                                width: double.infinity,
                                                height: 180,
                                                padding: EdgeInsets.only(
                                                    bottom: 10)),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Visibility(
                visible: isPending,
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
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: yellowPrimary,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  side: BorderSide(
                                      width: 1, color: yellowPrimary)),
                              onPressed: () async {
                                cancel();
                                // loadMore();
                                // LocalData localData =
                                //     await GeneralService()
                                //         .readLocalUserStorage();
                                // stopRecurring(
                                //     localData.Username,
                                //     statusDetail.data.orderId,
                                //     'portal');
                              },
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: reguler.copyWith(
                                      fontSize: 12, color: yellowSecondary),
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
        ));
  }
}
