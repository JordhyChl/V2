// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeoutPayment extends StatefulWidget {
  const TimeoutPayment({super.key});

  @override
  State<TimeoutPayment> createState() => _TimeoutPaymentState();
}

class _TimeoutPaymentState extends State<TimeoutPayment> {
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
                blueGradientSecondary1,
                blueGradientSecondary2,
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.timeoutPayment,
          style: bold.copyWith(
            fontSize: 16,
            color: whiteColor,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/timeoutTopup.png',
              width: 250,
              height: 250,
              // fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.timeoutPayment,
              textAlign: TextAlign.center,
              style: bold.copyWith(fontSize: 14, color: blackSecondary2),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.timeoutPaymentSub,
              textAlign: TextAlign.center,
              maxLines: 5,
              style: reguler.copyWith(fontSize: 12, color: blackSecondary3),
            ),
            const SizedBox(
              height: 20.0,
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
                              selected: 3,
                              darkMode: darkMode,
                              secondAccess: false,
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
                      style: bold.copyWith(color: whiteColor, fontSize: 14)),
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
                              secondAccess: false,
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
