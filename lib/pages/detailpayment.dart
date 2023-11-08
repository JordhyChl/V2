// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/bank.model.dart';
import 'package:gpsid/model/banktransfer.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/howtopay.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/pages/cancelpayment.dart';
import 'package:gpsid/pages/failedpayment.dart';
import 'package:gpsid/pages/thankspage.dart';
import 'package:gpsid/pages/timeoutpage.dart';
import 'package:gpsid/pages/waitingforpayment.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DetailPayment extends StatefulWidget {
  final String paymentName;
  final int expired;
  final String paymentNumber;
  final String orderID;
  final String totalAmount;
  final String gopay;
  final String mbp;
  final int transactionDate;
  final int totalUnit;
  final String npwpNo;
  final String npwpName;
  final bool darkMode;
  final List<VehicleDetailTransaction> vehicleDetail;
  const DetailPayment(
      {Key? key,
      required this.paymentName,
      required this.expired,
      required this.paymentNumber,
      required this.orderID,
      required this.totalAmount,
      required this.gopay,
      required this.mbp,
      required this.transactionDate,
      required this.totalUnit,
      required this.npwpNo,
      required this.npwpName,
      required this.vehicleDetail,
      required this.darkMode})
      : super(key: key);

  @override
  State<DetailPayment> createState() => _DetailPaymentState();
}

class _DetailPaymentState extends State<DetailPayment> {
  // late Future<dynamic> _getBankList;
  late BankCodeModel bankList;
  late LocalData localData;
  String expireInH = '';
  String expireInM = '';
  String expireInS = '';
  String timeLeftCountdown = '';
  Timer? _timer;
  var maskFormatterNPWP = MaskTextInputFormatter(
      mask: '##.###.###.#-###.###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  dynamic appDir;
  late HowToPayModel howToPay;
  late Future<dynamic> getHowToPay;

  @override
  void dispose() {
    mounted ? _timer!.cancel() : {};
    super.dispose();
  }

  getDir() async {
    appDir = await path_provider.getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    super.initState();
    getHowToPay = howtopay();
    timeLeft();
    getDir();
    // _getBankList = getBankList();
  }

  Future<dynamic> howtopay() async {
    final result = await APIService()
        .howToPay(widget.paymentName.toUpperCase() == 'PERMATA'
            ? 'PER'
            : widget.paymentName == 'mandiri bill payment'
                ? 'MBP'
                : widget.paymentName == 'alfamart'
                    ? 'ALFA'
                    : widget.paymentName == 'indomaret'
                        ? 'INDO'
                        : widget.paymentName.toUpperCase());
    if (result is HowToPayModel) {
      print('success');
    } else {
      print('failed');
    }
    return result;
  }

  timeLeft() {
    int expIn = widget.expired;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        DateTime? getExpIn = DateTime.fromMillisecondsSinceEpoch(
            expIn == 0 ? 0 : expIn-- * 1000);
        expireInH = DateFormat('HH').format(getExpIn.toUtc());
        expireInM = DateFormat('mm').format(getExpIn.toUtc());
        expireInS = DateFormat('ss').format(getExpIn.toUtc());
        timeLeftCountdown =
            '$expireInH ${AppLocalizations.of(context)!.hour} $expireInM ${AppLocalizations.of(context)!.minutes} $expireInS ${AppLocalizations.of(context)!.second}';
      });
    });
  }

  cancel() async {
    Dialogs().loadingDialog(context);
    final result = await APIService().cancelTransaction(widget.orderID);
    if (result is MessageModel) {
      // Navigator.pop(context);
      // Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CancelPayment(
              darkMode: widget.darkMode,
            ),
          ));
      // showInfoAlert(context, result.message, '');
    }
  }

  // getBankList() async {
  //   final result = await APIService().getBankList();
  //   localData = await GeneralService().readLocalUserStorage();
  //   if (result is ErrorTrapModel) {
  //     print(result);
  //   } else {
  //     print(result.status);
  //   }
  //   return result;
  // }

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
            AppLocalizations.of(context)!.paymentDetail,
            style: bold.copyWith(
              fontSize: 16,
              color: widget.darkMode ? whiteColorDarkMode : whiteColor,
            ),
          ),
        ),
        backgroundColor: whiteColor,
        body: SizedBox(
          height: MediaQuery.of(context).size.height / 1,
          child: SingleChildScrollView(
            physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(AppLocalizations.of(context)!.paymentMethod,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              'assets/${widget.paymentName.toLowerCase()}.png',
                              color: widget.paymentName != 'CC' &&
                                      widget.paymentName != 'alfamart' &&
                                      widget.paymentName != 'indomaret'
                                  ? widget.darkMode
                                      ? whiteColorDarkMode
                                      : null
                                  : null,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.finishPaymentIn,
                                  style: bold.copyWith(
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary1,
                                      fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    width: double.infinity,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        4,
                                      ),
                                      color: widget.darkMode
                                          ? whiteCardColor
                                          : greyColorSecondary,
                                      border: Border.all(
                                        width: 1,
                                        color: whiteCardColor,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          timeLeftCountdown,
                                          style: reguler.copyWith(
                                              color: redPrimary, fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 1.1,
                            // height: 270,
                            child: Column(
                              children: [
                                Visibility(
                                  // gopay = true
                                  // hide
                                  visible: widget.paymentName.toLowerCase() ==
                                              'gopay' ||
                                          widget.paymentName.toLowerCase() ==
                                              'qris'
                                      ? false
                                      : true,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // color: blueGradient,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1,
                                        color: widget.darkMode
                                            ? bluePrimary
                                            : whiteCardColor,
                                      ),
                                    ),
                                    // color: whiteCardColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Visibility(
                                            visible: widget.paymentName ==
                                                    'mandiri bill payment'
                                                ? false
                                                : true,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .virtualAccount,
                                                  style: reguler.copyWith(
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary3,
                                                      fontSize: 10),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      widget.paymentNumber,
                                                      style: bold.copyWith(
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary1,
                                                          fontSize: 16),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        width: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                // color: greyColorSecondary,
                                                                border: Border.all(
                                                                    color:
                                                                        bluePrimary)),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                    ClipboardData(
                                                                        text: widget
                                                                            .paymentNumber))
                                                                .then((_) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          backgroundColor:
                                                                              bluePrimary,
                                                                          content:
                                                                              Text(
                                                                            "Copied",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          )));
                                                            });
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .copy,
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color:
                                                                        bluePrimary,
                                                                  )),
                                                              Icon(
                                                                Icons
                                                                    .copy_outlined,
                                                                color:
                                                                    bluePrimary,
                                                                size: 12,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                              visible: widget.paymentName ==
                                                      'mandiri bill payment'
                                                  ? true
                                                  : false,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Biller key',
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                          )),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Container(
                                                          width: 80,
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  // color: greyColorSecondary,
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              bluePrimary)),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              widget.mbp))
                                                                  .then((_) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                            backgroundColor:
                                                                                bluePrimary,
                                                                            content:
                                                                                Text(
                                                                              "Copied",
                                                                              textAlign: TextAlign.center,
                                                                            )));
                                                              });
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .copy,
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                      color:
                                                                          bluePrimary,
                                                                    )),
                                                                Icon(
                                                                  Icons
                                                                      .copy_outlined,
                                                                  color:
                                                                      bluePrimary,
                                                                  size: 12,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(widget.mbp,
                                                      style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: blackPrimary,
                                                      )),
                                                ],
                                              )),
                                          Visibility(
                                              visible: widget.paymentName ==
                                                      'mandiri bill payment'
                                                  ? true
                                                  : false,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Biller code',
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                          )),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Container(
                                                          width: 80,
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  // color: greyColorSecondary,
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              bluePrimary)),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              widget.paymentNumber))
                                                                  .then((_) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                            backgroundColor:
                                                                                bluePrimary,
                                                                            content:
                                                                                Text(
                                                                              "Copied",
                                                                              textAlign: TextAlign.center,
                                                                            )));
                                                              });
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .copy,
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                      color:
                                                                          bluePrimary,
                                                                    )),
                                                                Icon(
                                                                  Icons
                                                                      .copy_outlined,
                                                                  color:
                                                                      bluePrimary,
                                                                  size: 12,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(widget.paymentNumber,
                                                      style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: blackPrimary,
                                                      )),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            height: 2,
                                            thickness: 1,
                                            indent: 0,
                                            endIndent: 0,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : whiteCardColor,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Powered by',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary3,
                                                      )),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Image.asset(
                                                    'assets/midtrans.png',
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .totalPrice,
                                                      style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary3,
                                                      )),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      NumberFormat.currency(
                                                        locale: 'id',
                                                        decimalDigits: 0,
                                                        symbol: 'Rp. ',
                                                      ).format(double.parse(
                                                          widget.totalAmount)),
                                                      style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: blackPrimary,
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: whiteCardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1,
                                        color: whiteCardColor,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Order id',
                                                  style: reguler.copyWith(
                                                    fontSize: 10,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                                  )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(widget.orderID,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: blackPrimary,
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  // color: greyColorSecondary,
                                                  border: Border.all(
                                                      color: bluePrimary)),
                                              child: InkWell(
                                                onTap: () {
                                                  Clipboard.setData(
                                                          ClipboardData(
                                                              text: widget
                                                                  .orderID))
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            backgroundColor:
                                                                bluePrimary,
                                                            content: Text(
                                                              "Copied",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )));
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .copy,
                                                        style: reguler.copyWith(
                                                          fontSize: 10,
                                                          color: bluePrimary,
                                                        )),
                                                    Icon(
                                                      Icons.copy_outlined,
                                                      color: bluePrimary,
                                                      size: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
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
                                                  )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  // '12 Mei 2022, 10:00 WIB',
                                                  DateFormat(
                                                          'dd MMMM yyyy, HH:mm')
                                                      .format(DateTime.parse(
                                                          DateTime.fromMillisecondsSinceEpoch(
                                                                  widget.transactionDate *
                                                                      1000)
                                                              .toString())),
                                                  // DateFormat(
                                                  //         'dd MMM yyyy hh:m WIB')
                                                  //     .format(DateTime.parse(
                                                  //         widget.expired
                                                  //             .toString())),
                                                  style: reguler.copyWith(
                                                    fontSize: 10,
                                                    color: blackPrimary,
                                                  )),
                                            ],
                                          ),
                                          Visibility(
                                            visible: widget.npwpNo == ''
                                                ? false
                                                : true,
                                            child: SizedBox(
                                              height: 10,
                                            ),
                                          ),
                                          Visibility(
                                            visible: widget.npwpNo == ''
                                                ? false
                                                : true,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('NPWP Info',
                                                    style: reguler.copyWith(
                                                      fontSize: 10,
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary3,
                                                    )),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        // '12 Mei 2022, 10:00 WIB',
                                                        maskFormatterNPWP
                                                            .maskText(
                                                                widget.npwpNo),
                                                        // DateFormat(
                                                        //         'dd MMM yyyy hh:m WIB')
                                                        //     .format(DateTime.parse(
                                                        //         widget.expired
                                                        //             .toString())),
                                                        style: reguler.copyWith(
                                                          fontSize: 10,
                                                          color: blackPrimary,
                                                        )),
                                                    Text(
                                                        // '12 Mei 2022, 10:00 WIB',
                                                        widget.npwpName
                                                            .toString(),
                                                        // DateFormat(
                                                        //         'dd MMM yyyy hh:m WIB')
                                                        //     .format(DateTime.parse(
                                                        //         widget.expired
                                                        //             .toString())),
                                                        style: reguler.copyWith(
                                                          fontSize: 10,
                                                          color: blackPrimary,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  AppLocalizations.of(context)!
                                                      .totalUnit,
                                                  style: reguler.copyWith(
                                                    fontSize: 10,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                                  )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  print(widget.vehicleDetail);
                                                  showModalBottomSheet(
                                                    backgroundColor:
                                                        whiteCardColor,
                                                    context: context,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(12),
                                                              topRight: Radius
                                                                  .circular(
                                                                      12)),
                                                    ),
                                                    builder: (context) {
                                                      return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            2.5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          15),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .orderDetail,
                                                                    style: bold.copyWith(
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : blackSecondary1,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary1,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        15),
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount: widget
                                                                      .vehicleDetail
                                                                      .length,
                                                                  physics:
                                                                      BouncingScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Column(
                                                                      children: [
                                                                        Row(
                                                                          // mainAxisAlignment:
                                                                          //     MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              '${index + 1}.',
                                                                              style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1),
                                                                            ),
                                                                            appDir is Directory
                                                                                ? SizedBox(
                                                                                    width: 85,
                                                                                    child: Image.file(
                                                                                      File('${appDir.path}/localAssetType/${widget.vehicleDetail[index].vehicleType.toLowerCase()}_parking.png'),
                                                                                      width: 42,
                                                                                      height: 42,
                                                                                    ),
                                                                                  )
                                                                                : SizedBox(
                                                                                    width: 85,
                                                                                    child: const SkeletonAvatar(
                                                                                      style: SkeletonAvatarStyle(shape: BoxShape.rectangle, width: 42, height: 42),
                                                                                    ),
                                                                                  ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      widget.vehicleDetail[index].plate,
                                                                                      style: bold.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1, fontSize: 10),
                                                                                    ),
                                                                                    Text(
                                                                                      widget.vehicleDetail[index].simcard,
                                                                                      style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 10),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                                  children: [
                                                                                    Text(
                                                                                      NumberFormat.currency(
                                                                                        locale: 'id',
                                                                                        decimalDigits: 0,
                                                                                        symbol: 'Rp. ',
                                                                                      ).format(
                                                                                        int.parse(widget.vehicleDetail[index].amount.toString()),
                                                                                      ),
                                                                                      style: bold.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1, fontSize: 10),
                                                                                    ),
                                                                                    Text(
                                                                                      widget.vehicleDetail[index].package,
                                                                                      style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 10),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Divider(
                                                                          height:
                                                                              1,
                                                                          thickness:
                                                                              0.5,
                                                                          indent:
                                                                              0,
                                                                          endIndent:
                                                                              0,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : greyColorSecondary,
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      // color: whiteColor,
                                                      border: Border.all(
                                                          color: bluePrimary)),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        // vertical: 2,
                                                        horizontal: 25),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            // '12 Mei 2022, 10:00 WIB',
                                                            '${widget.totalUnit.toString()} Unit',
                                                            // DateFormat(
                                                            //         'dd MMM yyyy hh:m WIB')
                                                            //     .format(DateTime.parse(
                                                            //         widget.expired
                                                            //             .toString())),
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color:
                                                                  bluePrimary,
                                                            )),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_up_outlined,
                                                          color: bluePrimary,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                    // gopay = false
                                    // show
                                    visible: widget.paymentName.toLowerCase() !=
                                            'gopay'
                                        ? false
                                        : true,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                            onTap: () {
                                              showQR(context,
                                                  widget.paymentNumber);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color: bluePrimary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  width: 1,
                                                  color: bluePrimary,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'QR Payment',
                                                    style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                            onTap: () async {
                                              launchUrl(Uri.parse(widget.gopay),
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color: bluePrimary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  width: 1,
                                                  color: bluePrimary,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Open Gojek',
                                                    style: reguler.copyWith(
                                                        fontSize: 12,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    // Image.network(widget.paymentNumber),
                                    ),
                                Visibility(
                                  // qris = true
                                  // show
                                  visible:
                                      widget.paymentName.toLowerCase() != 'qris'
                                          ? false
                                          : true,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/${widget.paymentName.toLowerCase()}.png',
                                        ),
                                        Image.network(widget.paymentNumber),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 30),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppLocalizations.of(context)!.howToPay,
                                    textAlign: TextAlign.start,
                                    style: reguler.copyWith(
                                        color: blackPrimary, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  height: 300,
                                  child: FutureBuilder(
                                    future: getHowToPay,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data is ErrorTrapModel) {
                                          return Container();
                                        } else {
                                          howToPay = snapshot.data;
                                          return ListView.builder(
                                            itemCount: howToPay.data.length,
                                            itemBuilder: (context, index) {
                                              Locale myLocale =
                                                  Localizations.localeOf(
                                                      context);
                                              return ExpandablePanel(
                                                  theme: ExpandableThemeData(
                                                      collapseIcon: Icons
                                                          .keyboard_arrow_up_rounded,
                                                      expandIcon: Icons
                                                          .keyboard_arrow_down_rounded),
                                                  header: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Text(
                                                      howToPay
                                                          .data[index].title,
                                                      style: reguler.copyWith(
                                                          color: blackPrimary,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                  collapsed: Container(),
                                                  expanded: SizedBox(
                                                    // width: 100,
                                                    height: 200,
                                                    child: ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount: howToPay
                                                          .data[index]
                                                          .detailsEn
                                                          .length,
                                                      itemBuilder: (context,
                                                          indexDetail) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    '${indexDetail + 1}. ',
                                                                    style: reguler.copyWith(
                                                                        color:
                                                                            blackPrimary,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      myLocale.languageCode ==
                                                                              'en'
                                                                          ? howToPay.data[index].detailsEn[
                                                                              indexDetail]
                                                                          : howToPay
                                                                              .data[index]
                                                                              .detailsId[indexDetail],
                                                                      style: reguler.copyWith(
                                                                          color:
                                                                              blackPrimary,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )

                                                  // Column(
                                                  //   children: [
                                                  //     Text(howToPay.data[index]
                                                  //         .detailsEn[index]),
                                                  //   ],
                                                  // )
                                                  );
                                            },
                                          );
                                        }
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  cancel();
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2.8,
                  decoration: BoxDecoration(
                    // color: greenPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 1,
                      color: bluePrimary,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.cancel,
                        style:
                            reguler.copyWith(fontSize: 12, color: bluePrimary),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (expireInH == '00' &&
                      expireInM == '00' &&
                      expireInS == '00') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimeoutPayment()));
                  } else {
                    Dialogs().loadingDialog(context);
                    String status = '';
                    final result =
                        await APIService().getTopupHistDetail(widget.orderID);
                    status = result.data.result.status;
                    Dialogs().hideLoaderDialog(context);
                    if (status.toLowerCase() == 'success') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ThanksPage(orderId: widget.orderID)));
                    }
                    if (status.toLowerCase() == 'pending') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WaitingForPayment(
                                    darkMode: widget.darkMode,
                                  )));
                    }
                    if (status.toLowerCase() == 'cancel') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CancelPayment(
                                    darkMode: widget.darkMode,
                                  )));
                    }
                    if (status.toLowerCase() == 'expire') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FailedPayment(
                                    darkMode: widget.darkMode,
                                  )));
                    } else {
                      if (result is MessageModel) {
                        showInfoAlert(context, result.message, '');
                      }
                      // else {
                      //   showInfoAlert(context, result, '');
                      // }
                    }
                  }
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             ThanksPage(orderId: widget.orderID)));
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.8,
                  decoration: BoxDecoration(
                    color: greenPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 1,
                      color: greenPrimary,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.confirmPayment,
                        style: reguler.copyWith(
                            fontSize: 12,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : whiteColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
