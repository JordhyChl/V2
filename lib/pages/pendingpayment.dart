// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/banktransfer.model.dart';
import 'package:gpsid/model/cspayment.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/gopay.model.dart';
import 'package:gpsid/model/mbp.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/pendingtransaction.model.dart';
import 'package:gpsid/model/qris.model.dart';
import 'package:gpsid/pages/detailpayment.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';

class PendingPayment extends StatefulWidget {
  final bool darkMode;
  const PendingPayment({super.key, required this.darkMode});

  @override
  State<PendingPayment> createState() => _PendingPaymentState();
}

class _PendingPaymentState extends State<PendingPayment> {
  late Future<dynamic> _getPending;
  late PendingModel listPending;
  // late Timer _timer;

  @override
  void initState() {
    super.initState();
    _getPending = getPending();
  }

  @override
  void dispose() {
    super.dispose();
    if (mounted) {
      // _timer.cancel();
    }
  }

  Future<dynamic> getPending() async {
    final res = await APIService().getPendingList();
    if (res is PendingModel) {
      print('ada data');
      // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //   setState(() {});
      // });
    } else {
      print('tidak ada data');
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        toolbarHeight: 65,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     blueGradientSecondary1,
              //     blueGradientSecondary2,
              //   ],
              // ),
              color: widget.darkMode ? whiteCardColor : blueSecondary),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.waitingForPayment,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getPending,
        builder: (BuildContext contxt, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data is ErrorTrapModel) {
              return const Text('');
            }
            if (snapshot.data is MessageModel) {
              Navigator.pop(context);
            } else {
              listPending = snapshot.data;
              if (listPending.data.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // await doRefresh();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/handling/emptycart.png',
                                height: 240,
                                width: 240,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 10),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .noPendingTransaction,
                                  textAlign: TextAlign.center,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackSecondary2,
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 30, right: 30, top: 10),
                              //   child: Text(
                              //     'There are no pending transaction',
                              //     textAlign: TextAlign.center,
                              //     style: reguler.copyWith(
                              //       fontSize: 12,
                              //       color: blackSecondary2,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: listPending.data.length,
                      itemBuilder: (context, index) {
                        DateTime? getTransactionTime =
                            DateTime.fromMillisecondsSinceEpoch(
                                listPending.data[index].transactionTime * 1000);
                        String transactionTime = DateFormat('dd MMMM y')
                            .format(getTransactionTime.toUtc());
                        DateTime? getExpIn =
                            DateTime.fromMillisecondsSinceEpoch(
                                listPending.data[index].expiryIn-- * 1000);
                        String expireInH =
                            DateFormat('HH').format(getExpIn.toUtc());
                        String expireInM =
                            DateFormat('mm').format(getExpIn.toUtc());
                        // setState(() {});
                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             TopupHistoryDetail(
                            //                 orderID:
                            //                     topuphistlist[index]
                            //                         .orderId)));
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
                              border: Border.all(
                                width: 1,
                                color: greyColor,
                              ),
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .finishPaymentIn,
                                      style: reguler.copyWith(
                                        fontSize: 10,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary3,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: greyColorSecondary,
                                          border: Border.all(
                                              color: greyColorSecondary)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2, vertical: 2),
                                        child: Text(
                                          // '$expireInH ${AppLocalizations.of(context)!.hour} $expireInM ${AppLocalizations.of(context)!.minutes} $expireInS ${AppLocalizations.of(context)!.second}',
                                          '$expireInH ${AppLocalizations.of(context)!.hour} $expireInM ${AppLocalizations.of(context)!.minutes}',
                                          style: bold.copyWith(
                                            fontSize: 10,
                                            color: redPrimary,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
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
                                    Text(
                                      listPending.data[index].orderId,
                                      style: bold.copyWith(
                                        fontSize: 10,
                                        color: blackPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
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
                                      ),
                                    ),
                                    Text(
                                      transactionTime,
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
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
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
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'id',
                                            decimalDigits: 0,
                                            symbol: 'Rp. ',
                                          ).format(double.parse(listPending
                                              .data[index].totalAmount
                                              .toString())),
                                          style: bold.copyWith(
                                            fontSize: 10,
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
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          '${listPending.data[index].totalUnit.toString()} Unit',
                                          style: bold.copyWith(
                                            fontSize: 10,
                                            color: blackPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await Dialogs().loadingDialog(context);
                                        final result = await APIService()
                                            .detailPending(listPending
                                                .data[index].orderId);
                                        if (result is BankTransfer) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPayment(
                                                paymentName:
                                                    result.data.detail.bankName,
                                                expired: result.data.expireIn,
                                                orderID: result.data.orderId,
                                                paymentNumber:
                                                    result.data.detail.vaNumber,
                                                totalAmount:
                                                    result.data.grossAmount,
                                                gopay: '',
                                                mbp: '',
                                                transactionDate:
                                                    result.data.transactionTime,
                                                totalUnit:
                                                    result.data.totalUnit,
                                                npwpNo: result.data.npwpNo,
                                                npwpName: result.data.npwpName,
                                                vehicleDetail:
                                                    result.data.vehicleDetail,
                                                darkMode: widget.darkMode,
                                              ),
                                            ),
                                          );
                                        }
                                        if (result is GoPayModel) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPayment(
                                                paymentName:
                                                    result.data.paymentType,
                                                expired: result.data.expireIn,
                                                orderID: result.data.orderId,
                                                paymentNumber: result
                                                    .data.detail.qrcode.url,
                                                totalAmount:
                                                    result.data.grossAmount,
                                                gopay: result
                                                    .data.detail.deeplink.url,
                                                mbp: '',
                                                transactionDate:
                                                    result.data.transactionTime,
                                                totalUnit:
                                                    result.data.totalUnit,
                                                npwpNo: result.data.npwpNo,
                                                npwpName: result.data.npwpName,
                                                vehicleDetail:
                                                    result.data.vehicleDetail,
                                                darkMode: widget.darkMode,
                                              ),
                                            ),
                                          );
                                        }
                                        if (result is QRisModel) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPayment(
                                                paymentName:
                                                    result.data.paymentType,
                                                expired: result.data.expireIn,
                                                orderID: result.data.orderId,
                                                paymentNumber:
                                                    result.data.detail.url,
                                                totalAmount:
                                                    result.data.grossAmount,
                                                gopay: '',
                                                mbp: '',
                                                transactionDate:
                                                    result.data.transactionTime,
                                                totalUnit:
                                                    result.data.totalUnit,
                                                npwpNo: result.data.npwpNo,
                                                npwpName: result.data.npwpName,
                                                vehicleDetail:
                                                    result.data.vehicleDetail,
                                                darkMode: widget.darkMode,
                                              ),
                                            ),
                                          );
                                        }
                                        if (result is MandiriBillPaymentModel) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPayment(
                                                paymentName:
                                                    'mandiri bill payment',
                                                expired: result.data.expireIn,
                                                orderID: result.data.orderId,
                                                paymentNumber: result
                                                    .data.detail.billerCode,
                                                totalAmount:
                                                    result.data.grossAmount,
                                                gopay: '',
                                                mbp: result.data.detail.billKey,
                                                transactionDate:
                                                    result.data.transactionTime,
                                                totalUnit:
                                                    result.data.totalUnit,
                                                npwpNo: result.data.npwpNo,
                                                npwpName: result.data.npwpName,
                                                vehicleDetail:
                                                    result.data.vehicleDetail,
                                                darkMode: widget.darkMode,
                                              ),
                                            ),
                                          );
                                        }
                                        if (result is CSPaymentModel) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPayment(
                                                paymentName:
                                                    result.data.detail.store,
                                                expired: result.data.expireIn,
                                                orderID: result.data.orderId,
                                                paymentNumber: result
                                                    .data.detail.paymentCode,
                                                totalAmount:
                                                    result.data.grossAmount,
                                                gopay: '',
                                                mbp: '',
                                                transactionDate:
                                                    result.data.transactionTime,
                                                totalUnit:
                                                    result.data.totalUnit,
                                                npwpNo: result.data.npwpNo,
                                                npwpName: result.data.npwpName,
                                                vehicleDetail:
                                                    result.data.vehicleDetail,
                                                darkMode: widget.darkMode,
                                              ),
                                            ),
                                          );
                                        }
                                        if (result is ErrorTrapModel) {
                                          Navigator.pop(context);
                                          showInfoAlert(
                                              context, result.statusError, '');
                                        }
                                        if (result is MessageModel) {
                                          Navigator.pop(context);
                                          showInfoAlert(
                                              context, result.message, '');
                                        }
                                        print(result);
                                        print(result);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: whiteColor,
                                            border:
                                                Border.all(color: bluePrimary)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          child: Row(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .paymentDetail,
                                                style: reguler.copyWith(
                                                  fontSize: 10,
                                                  color: bluePrimary,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 10,
                                                color: bluePrimary,
                                              )
                                            ],
                                          ),
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
          }
          return Container();
        },
      ),
    );
  }
}
