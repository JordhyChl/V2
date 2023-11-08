// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancelPayment extends StatefulWidget {
  final bool darkMode;
  const CancelPayment({super.key, required this.darkMode});

  @override
  State<CancelPayment> createState() => _CancelPaymentState();
}

class _CancelPaymentState extends State<CancelPayment> {
  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.cancelPaymentTitle,
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
              'assets/cancelandfailedpayment.png',
              width: 250,
              height: 250,
              // fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.cancelPayment,
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
              AppLocalizations.of(context)!.cancelPaymentSub,
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
              onTap: () async {
                // late bool darkMode;
                // final SharedPreferences prefs =
                //     await SharedPreferences.getInstance();
                // // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
                // final bool? darkmode = prefs.getBool('darkmode');
                // darkMode = darkmode!;

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              selected: 3,
                              darkMode: widget.darkMode,
                              secondAccess: true,
                            )));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                  child: Text(AppLocalizations.of(context)!.backToTopup,
                      textAlign: TextAlign.center,
                      style: bold.copyWith(
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                          fontSize: 14)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                late bool darkMode;
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
                final bool? darkmode = prefs.getBool('darkmode');
                darkMode = darkmode!;

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              selected: 0,
                              darkMode: darkMode,
                              secondAccess: true,
                            )));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 1,
                      color: bluePrimary,
                    ),
                  ),
                  child: Text('Home',
                      textAlign: TextAlign.center,
                      style: bold.copyWith(color: bluePrimary, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
