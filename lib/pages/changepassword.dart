// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, deprecated_member_use, avoid_print, unused_field

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/changepassword.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/notification.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangePassword extends StatefulWidget {
  final bool darkMode;
  const ChangePassword({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();
  bool _isHiddenOld = true;
  bool _isHiddenNew = true;
  bool _isHiddenConfirm = true;
  bool isCheck = false;
  String oldPass = '';
  String newPass = '';
  String confirmNewPass = '';
  bool oldPassCorrect = false;
  bool newPassCorrect = false;
  bool _isError = false;
  String _errCode = '';
  late FirebaseBackground firebase;

  @override
  void initState() {
    super.initState();
    firebase = FirebaseBackground();
    getLocal();
  }

  @override
  void dispose() {
    // cardNumber.dispose();
    // cvvcvnNumber.dispose();
    // expdate.dispose();
    super.dispose();
  }

  getLocal() async {
    LocalData getLocal = await GeneralService().readLocalUserStorage();
    setState(() {
      oldPass = getLocal.Password;
    });
    print(oldPass);
  }

  doChangePassword(String oldPass, String newPass) async {
    // print(showInfoAlert(context, 'new: $newPass old: $oldPass'));
    await Dialogs().loadingDialog(context);
    final result = await APIService().doChangePassword(oldPass, newPass);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '7897changepass';
      });
      Navigator.of(context).pop();
      showInfoAlert(context, 'Change password failed, please try again', '');
    } else {
      if (result is ChangePasswordModel) {
        if (result.status) {
          Navigator.of(context).pop();
          showSuccessChangePass(context, result.message);
        } else {
          Navigator.of(context).pop();
          showSuccess(context, result.message);
        }
      }
    }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.changePass,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      body: Container(
        color: whiteColor,
        // height: MediaQuery.of(context).size.height * (80 / 100),
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
                        Text(AppLocalizations.of(context)!.oldPassword,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        Visibility(
                            visible: oldPassCorrect,
                            child: Icon(
                              Icons.check_circle_outline_outlined,
                              size: 20,
                              color: greenPrimary,
                            ))
                      ],
                    ),
                    // Text(AppLocalizations.of(context)!.oldPassword,
                    //     style: bold.copyWith(
                    //       fontSize: 14,
                    //       color: blackPrimary,
                    //     )),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * (95 / 100),
                      child: TextFormField(
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.digitsOnly,
                        //   CardNumberFormatter()
                        // ],
                        // onChanged: (value) {
                        //   oldPass = value;
                        // },
                        controller: oldPassword,
                        onChanged: (value) {
                          value != oldPass
                              ? setState(
                                  () {
                                    oldPassCorrect = false;
                                  },
                                )
                              : setState(
                                  () {
                                    oldPassCorrect = true;
                                  },
                                );
                        },
                        obscureText: _isHiddenOld,
                        obscuringCharacter: '*',
                        // controller: cardNumber,
                        style: reguler.copyWith(
                          fontSize: 13,
                          color: blackPrimary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteCardColor,
                          hintText:
                              AppLocalizations.of(context)!.insertOldPassword,
                          // counterText: 'Lupa kata sandi?',
                          counter: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .forgotPassword,
                                style: TextStyle(
                                    color: blackPrimary,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    String url =
                                        "https://forgot.gps.id/password";
                                    var urllaunchable = await canLaunch(
                                        url); //canLaunch is from url_launcher package
                                    if (urllaunchable) {
                                      await launch(
                                          url); //launch is from url_launcher package to launch URL
                                    } else {
                                      print("URL can't be launched.");
                                    }
                                  })
                          ])),
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
                          suffixIcon: InkWell(
                            onTap: _togglePasswordOld,
                            child: Icon(
                              _isHiddenOld
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  widget.darkMode ? whiteColorDarkMode : null,
                            ),
                          ),
                        ),
                      ),
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
                    Text(AppLocalizations.of(context)!.newPassword,
                        style: bold.copyWith(
                          fontSize: 14,
                          color: blackPrimary,
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * (95 / 100),
                      child: TextFormField(
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.digitsOnly,
                        //   CardNumberFormatter()
                        // ],
                        controller: newPassword,
                        onChanged: (value) {
                          setState(() {
                            newPass = value;
                          });
                        },
                        obscureText: _isHiddenNew,
                        obscuringCharacter: '*',
                        // controller: cardNumber,
                        style: reguler.copyWith(
                          fontSize: 13,
                          color: blackPrimary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteCardColor,
                          hintText:
                              AppLocalizations.of(context)!.insertNewPassword,
                          // counterText: 'Lupa kata sandi?',

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
                          suffixIcon: InkWell(
                            onTap: _togglePasswordNew,
                            child: Icon(
                              _isHiddenNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  widget.darkMode ? whiteColorDarkMode : null,
                            ),
                          ),
                        ),
                      ),
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
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.confirmNewPassword,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        Visibility(
                            visible: newPassCorrect,
                            child: Icon(
                              Icons.check_circle_outline_outlined,
                              size: 20,
                              color: greenPrimary,
                            ))
                      ],
                    ),
                    // Text(AppLocalizations.of(context)!.confirmNewPassword,
                    //     style: bold.copyWith(
                    //       fontSize: 14,
                    //       color: blackPrimary,
                    //     )),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * (95 / 100),
                      child: TextFormField(
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.digitsOnly,
                        //   CardNumberFormatter()
                        // ],
                        controller: confirmNewPassword,
                        onChanged: (value) {
                          value != newPass
                              ? setState(
                                  () {
                                    newPassCorrect = false;
                                  },
                                )
                              : setState(
                                  () {
                                    confirmNewPass = value;
                                    newPassCorrect = true;
                                  },
                                );
                        },
                        obscureText: _isHiddenConfirm,
                        obscuringCharacter: '*',
                        // controller: cardNumber,
                        style: reguler.copyWith(
                          fontSize: 13,
                          color: blackPrimary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteCardColor,
                          hintText:
                              AppLocalizations.of(context)!.confirmNewPassword,
                          // counterText: 'Lupa kata sandi?',

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
                          suffixIcon: InkWell(
                            onTap: _togglePasswordConfirm,
                            child: Icon(
                              _isHiddenConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  widget.darkMode ? whiteColorDarkMode : null,
                            ),
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
      ),
      bottomNavigationBar: Container(
          color: widget.darkMode ? whiteCardColor : whiteColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          width: double.infinity,
          height: 70,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * (90 / 100),
                      child: ElevatedButton(
                        onPressed: () {
                          // _doSubmit(_portalProfileModel.id);
                          // if (_formEdit.currentState.validate()) {
                          //   _doSubmit(_portalProfileModel.id);
                          // }
                          if (oldPassword.text == '') {
                            showInfoAlert(context, 'Must not be null', '');
                          } else {
                            if (!oldPassCorrect) {
                              showInfoAlert(
                                  context, 'Check your old password', '');
                            } else {
                              if (!newPassCorrect) {
                                showInfoAlert(
                                    context,
                                    'Your password confirmation is incorrect',
                                    '');
                              } else {
                                if (newPass != confirmNewPass) {
                                  showInfoAlert(
                                      context,
                                      'Your password confirmation is incorrect',
                                      '');
                                } else {
                                  doChangePassword(oldPassword.text.trim(),
                                      newPassword.text.trim());
                                }
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: greenPrimary,
                              ),
                            ),
                            backgroundColor: greenPrimary,
                            // disabledBackgroundColor: greyColor,
                            // backgroundColor: Theme.of(context).accentColor,
                            textStyle: const TextStyle(
                              color: Colors.white,
                            )),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(10.0),
                        //   side: BorderSide(
                        //     color: Theme.of(context).accentColor,
                        //   ),
                        // ),
                        // color: Theme.of(context).accentColor,
                        // textColor: Colors.white,
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  _togglePasswordOld() {
    setState(() {
      _isHiddenOld = !_isHiddenOld;
    });
  }

  _togglePasswordNew() {
    setState(() {
      _isHiddenNew = !_isHiddenNew;
    });
  }

  _togglePasswordConfirm() {
    setState(() {
      _isHiddenConfirm = !_isHiddenConfirm;
    });
  }

  showSuccessChangePass(BuildContext context, String msg) {
    AlertDialog alert = AlertDialog(
      title: const Icon(
        Icons.check_circle_outlined,
        size: 64.0,
        color: Colors.green,
      ),
      content: Text(
        msg,
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 1,
              child: _closePopButtonSuccessChangePass(context),
            ),
            // SizedBox(
            //   width: 10.0,
            // ),
            // Flexible(
            //   flex: 1,
            //   child: _closeButton(context),
            // ),
          ],
        ),
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _closePopButtonSuccessChangePass(BuildContext context) {
    return SizedBox(
      width: 240.0,
      child: ElevatedButton(
          child: const Text(
            'Close',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            await Dialogs().loadingDialog(context);
            final result = await APIService().doLogout();
            if (result is ErrorTrapModel) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  content: Text(
                    'Change password failed',
                    style: reguler.copyWith(
                      fontSize: 12,
                      color: whiteColor,
                    ),
                  ),
                ),
              );
            } else {
              await firebase.deleteToken();
              await GeneralService().deleteLocalAlarmStorage();
              await GeneralService().deleteLocalAlarmTypeID();
              await GeneralService().deleteLocalUserStorage();
              await GeneralService().deleteLocalURL();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/login");
            }
            // Navigator.of(_context).pop();
            // Navigator.pop(context);
            // Navigator.pop(context);
            // Navigator.pop(context);
            // Navigator.pop(context);
          }),
    );
  }
}
