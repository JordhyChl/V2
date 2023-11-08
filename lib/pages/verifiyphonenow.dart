// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_final_fields, avoid_print, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/profile.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyPhoneNow extends StatefulWidget {
  final bool darkMode;
  const VerifyPhoneNow({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<VerifyPhoneNow> createState() => _VerifyPhoneNowState();
}

class _VerifyPhoneNowState extends State<VerifyPhoneNow> {
  final TextEditingController _currentPhoneNumber = TextEditingController();
  bool isCheck = false;

  late ProfileModel profile;
  bool success = false;

  bool successOTP = false;
  bool currentPhoneNumber = false;
  bool newPhoneNumber = false;
  String getCurrPhoneNumber = '';
  String getNewPhoneNumber = '';
  final _formPhoneOtp = GlobalKey<FormState>();
  bool _isEnabled = false;
  String _refreshLabel = '59:59';
  int _refreshTime = 3599;
  late Timer _timer;
  String phone = '';

  @override
  void dispose() {
    if (mounted) {
      if (_isEnabled) {
        _timer.isActive ? _timer.cancel() : {};
      }
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPhoneNum();
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

  getPhoneNum() async {
    final result = await APIService().getProfile();
    if (result is ProfileModel) {
      setState(() {
        getCurrPhoneNumber = result.data.result.phone;
        _currentPhoneNumber.text = getCurrPhoneNumber.isEmpty
            ? ''
            : getCurrPhoneNumber.substring(0, 2).contains('62')
                ? getCurrPhoneNumber.replaceRange(0, 2, '')
                : getCurrPhoneNumber[0] == '+'
                    ? getCurrPhoneNumber.replaceRange(0, 3, '')
                    : getCurrPhoneNumber[1] == '0'
                        ? getCurrPhoneNumber.replaceRange(0, 1, '')
                        : getCurrPhoneNumber.substring(0, 2).contains('620')
                            ? getCurrPhoneNumber.replaceRange(0, 2, '')
                            : getCurrPhoneNumber;
      });
    }
  }

  doGetOTP(String phoneNumber) async {
    phone = phoneNumber;
    print(phone);
    Dialogs().loadingDialog(context);
    final result = await APIService().sendPhoneNumber(phoneNumber);
    if (result is ErrorTrapModel) {
      Navigator.pop(context);
      setState(() {
        showInfoAlert(context, 'Failed verify phone number', '');
      });
    } else {
      if (result is MessageModel) {
        if (result.status) {
          Navigator.pop(context);
          setState(() {
            success = true;
            _startTimer();
          });
        } else {
          Navigator.pop(context);
          showInfoAlert(context, result.message, '');
        }
      }
    }
  }

  doSendOTP(String otp) async {
    Dialogs().loadingDialog(context);
    final result = await APIService().sendOTP(otp);
    if (result is ErrorTrapModel) {
      Navigator.pop(context);
      setState(() {
        showInfoAlert(context, 'Failed verify phone number', '');
      });
    } else {
      Navigator.pop(context);
      setState(() {
        successOTP = true;
      });
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
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.verifyPhone,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      backgroundColor: whiteColor,
      body: success
          ? successOTP
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .phoneVerificationSuccess,
                          style: bold.copyWith(
                            fontSize: 14,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : blackSecondary2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            'assets/verifsuccess.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .phoneVerificationSuccessThanks,
                              style: reguler.copyWith(
                                fontSize: 10,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Navigator.of(context).pushReplacementNamed("/");
                                await Navigator.of(context)
                                    .pushNamedAndRemoveUntil(
                                        '/', (route) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: bluePrimary,
                                    ),
                                  ),
                                  backgroundColor: bluePrimary,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  )),
                              child: Text('Home',
                                  style: reguler.copyWith(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formPhoneOtp,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 50.0,
                        ),
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .phoneVerificationSendSub,
                                    style: reguler.copyWith(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                  ),
                                  TextSpan(
                                    text: phone == ''
                                        ? '+. '
                                        : '+${phone.replaceRange(5, 9, '****')}. ',
                                    style: bold.copyWith(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: AppLocalizations.of(context)!
                                    .phoneVerificationSendSubSub,
                                style: reguler.copyWith(
                                  fontSize: 12,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary3,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            PinCodeTextField(
                              appContext: context,
                              keyboardType: TextInputType.number,
                              length: 6,
                              textStyle: reguler.copyWith(color: blackPrimary),
                              obscureText: false,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.underline,
                                  borderRadius: BorderRadius.circular(5),
                                  activeColor: blueGradient,
                                  selectedFillColor: blueGradient,
                                  inactiveColor: blueGradient,
                                  activeFillColor: redPrimary),
                              cursorColor: blueGradient,
                              onCompleted: (v) {
                                print("Completed");
                                doSendOTP(v);
                              },
                              onChanged: (value) {
                                print(value);
                              },
                              beforeTextPaste: (text) {
                                print("Allowing to paste $text");
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                return false;
                              },
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Visibility(
                                    visible: _isEnabled,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            doGetOTP(phone);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                (90 / 100),
                                            decoration: BoxDecoration(
                                                color: bluePrimary,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 1,
                                                    color: bluePrimary)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .resendOTP,
                                                style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: whiteColorDarkMode),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacementNamed(
                                                context, '/phoneNumber');
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                (90 / 100),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 1,
                                                    color: bluePrimary)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .changePhone,
                                                style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: bluePrimary),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Visibility(
                                      visible: !_isEnabled ? true : false,
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: AppLocalizations.of(context)!
                                                .otpPleaseWait,
                                            style: reguler.copyWith(
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                                fontSize: 12)),
                                        TextSpan(
                                            text: '$_refreshLabel ',
                                            style: bold.copyWith(
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                                fontSize: 12)),
                                        TextSpan(
                                            text: AppLocalizations.of(context)!
                                                .otpForResend,
                                            style: reguler.copyWith(
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                                fontSize: 12)),
                                      ]))),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 60.0,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
          : SingleChildScrollView(
              physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(AppLocalizations.of(context)!.countryCode,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    (30 / 100),
                                child: TextFormField(
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  readOnly: true,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: Image.asset(
                                      'assets/indonesiaflag.png',
                                    ),
                                    filled: true,
                                    fillColor: whiteCardColor,
                                    hintText: '+62',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                  AppLocalizations.of(context)!
                                      .currentPhoneNumber,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    (60 / 100),
                                child: TextFormField(
                                  readOnly: true,
                                  controller: _currentPhoneNumber,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: whiteCardColor,
                                    hintText: AppLocalizations.of(context)!
                                        .insertYourPhoneNumber,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 335,
                        child: Text(
                          AppLocalizations.of(context)!.phoneNumberContent,
                          style: reguler.copyWith(
                            fontSize: 10,
                            color: blackSecondary3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  (90 / 100),
                              child: ElevatedButton(
                                onPressed: () {
                                  doGetOTP(_currentPhoneNumber.text
                                          .substring(0, 3)
                                          .contains('620')
                                      ? _currentPhoneNumber.text
                                          .replaceRange(0, 3, '62')
                                      : _currentPhoneNumber.text[0] == '8'
                                          ? '62${_currentPhoneNumber.text}'
                                          : _currentPhoneNumber.text[0] == '0'
                                              ? _currentPhoneNumber.text
                                                      .substring(0)
                                                      .contains('0')
                                                  ? _currentPhoneNumber.text
                                                      .replaceRange(0, 1, '62')
                                                  : _currentPhoneNumber.text
                                              : _currentPhoneNumber.text[0] ==
                                                      '+'
                                                  ? _currentPhoneNumber.text
                                                      .replaceRange(0, 3, '62')
                                                  : _currentPhoneNumber.text[1] ==
                                                          '0'
                                                      ? _currentPhoneNumber.text
                                                          .replaceRange(
                                                              0, 1, '62')
                                                      : _currentPhoneNumber.text
                                                              .substring(0, 2)
                                                              .contains('62')
                                                          ? _currentPhoneNumber
                                                              .text
                                                              .replaceRange(
                                                                  0, 2, '62')
                                                          : _currentPhoneNumber
                                                              .text);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        color: greenPrimary,
                                      ),
                                    ),
                                    backgroundColor: greenPrimary,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    )),
                                child: Text(
                                    AppLocalizations.of(context)!.verifyPhone,
                                    style: bold.copyWith(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/phoneNumber');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            child: Text(
                                AppLocalizations.of(context)!.changePhoneNumber,
                                style: bold.copyWith(
                                    fontSize: 12, color: bluePrimary)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
