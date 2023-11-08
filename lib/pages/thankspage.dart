// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/pages/topuphisdetail.dart';
import 'package:gpsid/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThanksPage extends StatefulWidget {
  final String orderId;

  const ThanksPage({Key? key, required this.orderId}) : super(key: key);
  @override
  _ThanksPageState createState() => _ThanksPageState();
}

class _ThanksPageState extends State<ThanksPage> {
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
          '${AppLocalizations.of(context)!.transaction} ${AppLocalizations.of(context)!.success}',
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
              'assets/topupsuccess.png',
              width: 250,
              height: 250,
              // fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.topupSuccess,
              textAlign: TextAlign.center,
              style: bold.copyWith(fontSize: 14, color: blackSecondary2),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)!.topupSuccessSub,
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
                widget.orderId != ''
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TopupHistoryDetail(
                                  orderID: widget.orderId,
                                  darkMode: darkMode,
                                )))
                    : {};
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.orderId != '' ? bluePrimary : greyColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 1,
                      color: widget.orderId != '' ? bluePrimary : greyColor,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.seeInvoice,
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
                              selected: 3,
                              darkMode: darkMode,
                              secondAccess: false,
                            )));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
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
                  child: Text(AppLocalizations.of(context)!.backToTopup,
                      textAlign: TextAlign.center,
                      style: bold.copyWith(color: bluePrimary, fontSize: 14)),
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
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_outlined,
                      color: bluePrimary,
                    ),
                    Text('Home',
                        textAlign: TextAlign.center,
                        style: bold.copyWith(color: bluePrimary, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
