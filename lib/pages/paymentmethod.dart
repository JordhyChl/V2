// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/bank.model.dart';
import 'package:gpsid/model/banktransfer.model.dart';
import 'package:gpsid/model/cspayment.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/gopay.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/mbp.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/qris.model.dart';
import 'package:gpsid/pages/creditcardPayment.dart';
import 'package:gpsid/pages/detailpayment.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:skeletons/skeletons.dart';

class PaymentMethod extends StatefulWidget {
  final int totalUnit;
  final int totalPrice;
  final int npwp;
  final String npwpNo;
  final String npwpName;
  final String npwpAddress;
  final String npwpWa;
  final String npwpEmail;
  final List<dynamic> idCart;
  final List<dynamic> cart;
  final bool darkMode;
  const PaymentMethod(
      {Key? key,
      required this.totalUnit,
      required this.totalPrice,
      required this.npwp,
      required this.idCart,
      required this.npwpNo,
      required this.npwpName,
      required this.npwpAddress,
      required this.npwpWa,
      required this.npwpEmail,
      required this.cart,
      required this.darkMode})
      : super(key: key);

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final TextEditingController taxNumber = TextEditingController();
  final TextEditingController taxOwner = TextEditingController();
  final TextEditingController taxAddress = TextEditingController();
  final TextEditingController whatsAppNum = TextEditingController();
  final TextEditingController email = TextEditingController();
  late Future<dynamic> _getBankList;
  late BankCodeModel bankList;
  late LocalData localData;
  dynamic appDir;

  @override
  void dispose() {
    taxNumber.dispose();
    taxOwner.dispose();
    taxAddress.dispose();
    whatsAppNum.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getBankList = getBankList();
    getDir();
  }

  getDir() async {
    appDir = await path_provider.getApplicationDocumentsDirectory();
  }

  Future<dynamic> getBankList() async {
    final result = await APIService().getBankList();
    localData = await GeneralService().readLocalUserStorage();
    if (result is ErrorTrapModel) {
      print(result);
    } else {
      print(result.status);
    }
    return result;
  }

  topUp(String paymentVia, List<dynamic> idCart) async {
    await Dialogs().loadingDialog(context);
    print(
        'Testing : $paymentVia, ${widget.npwp}, $idCart, ${widget.npwpNo}, ${widget.npwpName}, ${widget.npwpAddress}, ${widget.npwpWa}, ${widget.npwpEmail},');
    final result = await APIService().topUpV2(
        paymentVia,
        widget.npwp,
        idCart,
        widget.npwpNo,
        widget.npwpName,
        widget.npwpAddress,
        widget.npwpWa,
        widget.npwpEmail);
    if (result is BankTransfer) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPayment(
            paymentName: result.data.detail.bankName,
            expired: result.data.expireIn,
            orderID: result.data.orderId,
            paymentNumber: result.data.detail.vaNumber,
            totalAmount: result.data.grossAmount,
            gopay: '',
            mbp: '',
            transactionDate: result.data.transactionTime,
            totalUnit: result.data.totalUnit,
            npwpNo: result.data.npwpNo,
            npwpName: result.data.npwpName,
            vehicleDetail: result.data.vehicleDetail,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
    if (result is GoPayModel) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPayment(
            paymentName: result.data.paymentType,
            expired: result.data.expireIn,
            orderID: result.data.orderId,
            paymentNumber: result.data.detail.qrcode.url,
            totalAmount: result.data.grossAmount,
            gopay: result.data.detail.deeplink.url,
            mbp: '',
            transactionDate: result.data.transactionTime,
            totalUnit: result.data.totalUnit,
            npwpNo: result.data.npwpNo,
            npwpName: result.data.npwpName,
            vehicleDetail: result.data.vehicleDetail,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
    if (result is QRisModel) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPayment(
            paymentName: result.data.paymentType,
            expired: result.data.expireIn,
            orderID: result.data.orderId,
            paymentNumber: result.data.detail.url,
            totalAmount: result.data.grossAmount,
            gopay: '',
            mbp: '',
            transactionDate: result.data.transactionTime,
            totalUnit: result.data.totalUnit,
            npwpNo: result.data.npwpNo,
            npwpName: result.data.npwpName,
            vehicleDetail: result.data.vehicleDetail,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
    if (result is MandiriBillPaymentModel) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPayment(
            paymentName: 'mandiri bill payment',
            expired: result.data.expireIn,
            orderID: result.data.orderId,
            paymentNumber: result.data.detail.billerCode,
            totalAmount: result.data.grossAmount,
            gopay: '',
            mbp: result.data.detail.billKey,
            transactionDate: result.data.transactionTime,
            totalUnit: result.data.totalUnit,
            npwpNo: result.data.npwpNo,
            npwpName: result.data.npwpName,
            vehicleDetail: result.data.vehicleDetail,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
    if (result is CSPaymentModel) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPayment(
            paymentName: result.data.detail.store,
            expired: result.data.expireIn,
            orderID: result.data.orderId,
            paymentNumber: result.data.detail.paymentCode,
            totalAmount: result.data.grossAmount,
            gopay: '',
            mbp: '',
            transactionDate: result.data.transactionTime,
            totalUnit: result.data.totalUnit,
            npwpNo: result.data.npwpNo,
            npwpName: result.data.npwpName,
            vehicleDetail: result.data.vehicleDetail,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
    if (result is MessageModel) {
      Navigator.pop(context);
      showInfoAlert(context, result.message, '');
    }
    if (result is ErrorTrapModel) {
      Navigator.pop(context);
      showInfoAlert(context, result.statusError, '');
    }
    // else {
    //   Navigator.pop(context);
    //   showInfoAlert(context, result.statusError);
    // }
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
          // onPressed: () => Navigator.of(context).pop(),
          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.choosePaymentMethod,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getBankList,
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
                if (snapshot.data is BankCodeModel) {
                  bankList = snapshot.data;
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 1,
                    child: SingleChildScrollView(
                      physics:
                          const ScrollPhysics(parent: BouncingScrollPhysics()),
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
                                  Text(
                                      '${AppLocalizations.of(context)!.bankTransfer} / ${AppLocalizations.of(context)!.virtualAccount}',
                                      style: bold.copyWith(
                                        fontSize: 14,
                                        color: blackPrimary,
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    height: 270,
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            bankList.data.transferBank.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              topUp(
                                                  bankList
                                                      .data
                                                      .transferBank[index]
                                                      .bankCode,
                                                  widget.idCart);
                                              print(
                                                  'Test payment: Username = ${localData.Username} // Bank code ${bankList.data.transferBank[index].bankName} = ${bankList.data.transferBank[index].bankCode} // Domain = Portal');
                                            },
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: widget.darkMode
                                                      ? whiteCardColor
                                                      : whiteColor,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/${bankList.data.transferBank[index].bankName.toLowerCase()}.png',
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                SizedBox(
                                                                  width: 130,
                                                                  child: Text(
                                                                    bankList
                                                                        .data
                                                                        .transferBank[
                                                                            index]
                                                                        .bankName,
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          blackPrimary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/arrowright.png')
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .instantPayment,
                                      style: bold.copyWith(
                                        fontSize: 14,
                                        color: blackPrimary,
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    height: 270,
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            bankList.data.instantPayment.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              bankList
                                                          .data
                                                          .instantPayment[index]
                                                          .bankCode ==
                                                      'CC'
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CreditCardPayment(
                                                          totalPrice:
                                                              widget.totalPrice,
                                                          totalUnit:
                                                              widget.totalUnit,
                                                          darkMode:
                                                              widget.darkMode,
                                                        ),
                                                      ),
                                                    )
                                                  : topUp(
                                                      bankList
                                                          .data
                                                          .instantPayment[index]
                                                          .bankCode,
                                                      widget.idCart);
                                            },
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: widget.darkMode
                                                      ? whiteCardColor
                                                      : whiteColor,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/${bankList.data.instantPayment[index].bankName.toLowerCase()}.png',
                                                                    color: widget
                                                                            .darkMode
                                                                        ? bankList.data.instantPayment[index].bankCode ==
                                                                                'CC'
                                                                            ? null
                                                                            : whiteColorDarkMode
                                                                        : null,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    // width: 130,
                                                                    child: Text(
                                                                      bankList
                                                                          .data
                                                                          .instantPayment[
                                                                              index]
                                                                          .bankName,
                                                                      style: reguler
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            blackPrimary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Image.asset(
                                                                    'assets/arrowright.png')
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(AppLocalizations.of(context)!.miniMarket,
                                      style: bold.copyWith(
                                        fontSize: 14,
                                        color: blackPrimary,
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    height: 150,
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: bankList
                                            .data.convenienceStore.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              // csPayment();
                                              topUp(
                                                  bankList
                                                      .data
                                                      .convenienceStore[index]
                                                      .bankCode,
                                                  widget.idCart);
                                            },
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: widget.darkMode
                                                      ? whiteCardColor
                                                      : whiteColor,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    bankList.data.convenienceStore[index].bankCode ==
                                                                            'ALFA'
                                                                        ? 'assets/alfamart.png'
                                                                        : 'assets/${bankList.data.convenienceStore[index].bankName.toLowerCase()}.png',
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      bankList
                                                                          .data
                                                                          .convenienceStore[
                                                                              index]
                                                                          .bankName,
                                                                      style: reguler
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            blackPrimary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Image.asset(
                                                                    'assets/arrowright.png')
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
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
      bottomNavigationBar: Container(
        color: blueGradient,
        height: 100,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    print(widget.cart);
                    showModalBottomSheet(
                      backgroundColor: whiteCardColor,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                      ),
                      builder: (context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 2.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.orderDetail,
                                      style: bold.copyWith(
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary1,
                                          fontSize: 14),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary1,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: ListView.builder(
                                    itemCount: widget.cart.length,
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          Row(
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${index + 1}.',
                                                style: reguler.copyWith(
                                                    color: blackPrimary),
                                              ),
                                              appDir is Directory
                                                  ? SizedBox(
                                                      width: 85,
                                                      child: Image.file(
                                                        File(
                                                            '${appDir.path}/localAssetType/${widget.cart[index].vehicleType.toLowerCase()}_parking.png'),
                                                        width: 42,
                                                        height: 42,
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: 85,
                                                      child:
                                                          const SkeletonAvatar(
                                                        style:
                                                            SkeletonAvatarStyle(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                width: 42,
                                                                height: 42),
                                                      ),
                                                    ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        widget.cart[index]
                                                            .information[0],
                                                        style: bold.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                            fontSize: 10),
                                                      ),
                                                      Text(
                                                        widget.cart[index].sim,
                                                        style: reguler.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        NumberFormat.currency(
                                                          locale: 'id',
                                                          decimalDigits: 0,
                                                          symbol: 'Rp. ',
                                                        ).format(
                                                          int.parse(widget
                                                              .cart[index].harga
                                                              .toString()),
                                                        ),
                                                        style: bold.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                            fontSize: 10),
                                                      ),
                                                      Text(
                                                        widget.cart[index]
                                                            .packName,
                                                        style: reguler.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                            fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            indent: 0,
                                            endIndent: 0,
                                            color: greyColorSecondary,
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
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.darkMode ? whiteCardColor : whiteColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          width: 1,
                          color: widget.darkMode ? whiteCardColor : whiteColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(AppLocalizations.of(context)!.orderDetail,
                                style: reguler.copyWith(
                                    fontSize: 12,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : bluePrimary)),
                            Icon(
                              Icons.keyboard_arrow_up_outlined,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : bluePrimary,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width / 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.totalUnit,
                              style: reguler.copyWith(
                                  fontSize: 12,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : whiteColor)),
                          Text(
                            '${widget.totalUnit} ${AppLocalizations.of(context)!.unitCart}',
                            style: bold.copyWith(
                                fontSize: 14,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : whiteColor),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppLocalizations.of(context)!.totalPrice,
                              style: reguler.copyWith(
                                  fontSize: 12,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : whiteColor)),
                          Text(
                              NumberFormat.currency(
                                locale: 'id',
                                decimalDigits: 0,
                                symbol: 'Rp. ',
                              ).format(widget.totalPrice),
                              style: bold.copyWith(
                                  fontSize: 14,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : whiteColor)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        // padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        // width: double.infinity,
        // height: MediaQuery.of(context).size.width / 4.5,
      ),
    );
  }
}
