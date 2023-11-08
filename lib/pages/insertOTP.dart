// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class InsertOTP extends StatefulWidget {
  const InsertOTP({Key? key}) : super(key: key);

  @override
  State<InsertOTP> createState() => _InsertOTPState();
}

class _InsertOTPState extends State<InsertOTP> {
  final TextEditingController taxNumber = TextEditingController();
  final TextEditingController taxOwner = TextEditingController();
  final TextEditingController taxAddress = TextEditingController();
  final TextEditingController whatsAppNum = TextEditingController();
  final TextEditingController email = TextEditingController();
  final _formPhoneOtp = GlobalKey<FormState>();
  late Timer _timer;
  String _refreshLabel = '05:00';
  int _refreshTime = 300;
  bool _isEnabled = false;

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
    _startTimer();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _refreshLabel = _printDuration(Duration(seconds: _refreshTime));
        _refreshTime--;
      });
      if (_refreshTime < 0) {
        timer.cancel();
        _isEnabled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
          leading: IconButton(
            iconSize: 32,
            // padding: const EdgeInsets.only(top: 20),
            icon: const Icon(Icons.arrow_back_outlined),
            color: Colors.white,
            // onPressed: () => Navigator.of(context).pop(),
            onPressed: () {
              _timer.cancel();
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.verifyPhone,
            style: bold.copyWith(
              fontSize: 16,
              color: whiteColor,
            ),
          ),
        ),
        body: Form(
          key: _formPhoneOtp,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10.0,
                ),
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        AppLocalizations.of(context)!.insertOTP,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.otpInfo1} 081331234975, ${AppLocalizations.of(context)!.otpInfo2}',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          // children: <TextSpan>[
                          //   TextSpan(
                          //     text: _refreshLabel,
                          //     style:
                          //         TextStyle(fontWeight: FontWeight.bold),
                          //   ),
                          //   TextSpan(
                          //     text: '.',
                          //   ),
                          // ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      PinCodeTextField(
                        appContext: context,
                        keyboardType: TextInputType.number,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            activeColor: Colors.black,
                            selectedFillColor: Colors.black,
                            inactiveColor: Colors.black
                            // fieldHeight: 50,
                            // fieldWidth: 40,
                            // activeFillColor: Colors.white,
                            ),
                        animationDuration: const Duration(milliseconds: 300),
                        cursorColor: Colors.black,
                        // backgroundColor: Colors.blue.shade50,
                        // enableActiveFill: true,
                        // errorAnimationController: errorController,
                        // controller: textEditingController,
                        onCompleted: (v) {
                          print("Completed");
                          // _doSubmitOTP(v);
                        },
                        onChanged: (value) {
                          print(value);
                          // setState(() {
                          //   currentText = value;
                          //   _doSubmitOTP(value);
                          // });
                        },
                        beforeTextPaste: (text) {
                          print("Allowing to paste $text");
                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                          return false;
                        },
                      ),
                      // PinFieldAutoFill(
                      //   decoration: UnderlineDecoration(
                      //     textStyle: TextStyle(
                      //         fontSize: 20, color: Colors.black),
                      //     colorBuilder: FixedColorBuilder(
                      //       Colors.black.withOpacity(0.3),
                      //     ),
                      //   ),
                      //   cursor: Cursor(
                      //       color: Colors.black, enabled: true, width: 1),
                      //   codeLength: 6,
                      //   autoFocus: true,
                      //   onCodeSubmitted: (code) {
                      //     _doSubmitOTP(code);
                      //   },
                      //   onCodeChanged: (code) {
                      //     if (code.length == 6) {
                      //       _doSubmitOTP(code);
                      //     }
                      //   },
                      // ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: _isEnabled,
                            child: IgnorePointer(
                              ignoring: false,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  AppLocalizations.of(context)!.changePhone,
                                  style: TextStyle(
                                    color:
                                        _isEnabled ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Visibility(
                            visible: !_isEnabled ? true : false,
                            child: Text(
                              _refreshLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Visibility(
                            visible: _isEnabled,
                            child: TextButton(
                              // onPressed: () => _doSendOTP(),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                AppLocalizations.of(context)!.resendOTP,
                                style: TextStyle(
                                  color:
                                      _isEnabled ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 60.0,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
