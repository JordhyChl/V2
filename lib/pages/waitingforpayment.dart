import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/theme.dart';

class WaitingForPayment extends StatefulWidget {
  final bool darkMode;
  const WaitingForPayment({super.key, required this.darkMode});

  @override
  State<WaitingForPayment> createState() => _WaitingForPaymentState();
}

class _WaitingForPaymentState extends State<WaitingForPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
      backgroundColor: whiteColor,
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/waitingforpayment.png',
              width: 250,
              height: 250,
              // fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.notRecievePayment,
              textAlign: TextAlign.center,
              style: bold.copyWith(
                  fontSize: 14,
                  color:
                      widget.darkMode ? whiteColorDarkMode : blackSecondary2),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.notRecievePaymentSub,
              textAlign: TextAlign.center,
              maxLines: 5,
              style: reguler.copyWith(
                  fontSize: 12,
                  color:
                      widget.darkMode ? whiteColorDarkMode : blackSecondary3),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: bluePrimary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 1,
                      color: bluePrimary,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.seePaymentDetail,
                      textAlign: TextAlign.center,
                      style: bold.copyWith(
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                          fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
