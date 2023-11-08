// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, must_be_immutable, avoid_print

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/getnotificationsetting.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/notification.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherPage extends StatefulWidget {
  bool darkMode;
  int progressCount;
  bool completeProfile;
  OtherPage(
      {Key? key,
      required this.darkMode,
      required this.progressCount,
      required this.completeProfile})
      : super(key: key);
  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  late FirebaseBackground firebase;
  LocalData localData = LocalData(
      ID: 0,
      SeenId: 0,
      Username: '',
      Password: '',
      Fullname: '',
      Phone: '',
      Email: '',
      Addres: '',
      CompanyName: '',
      BranchId: 0,
      Privilage: 0,
      Token: '',
      IsGenerated: false,
      IsGoogle: false,
      IsApple: false,
      createdAt: '');
  String fullName = 'Loading...';
  String userName = 'Loading...';
  late LinkModel url;
  late String appVersion = '';
  late String buildNumber = '';
  late String appName = '';
  bool biometricLogin = false;
  late bool bml;
  bool selectAll = false;
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  String imeiDemo = '';

  @override
  void initState() {
    super.initState();
    getVehicleList();
    firebase = FirebaseBackground();
    getLocal();
    readPrefs();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      print(_currentUser);
    });
  }

  getVehicleList() async {
    final result = await APIService().getVehicleList(0, 0);
    if (result is VehicleListModel) {
      result.data.result.forEach((el) {
        if (el.imei == '123456') {
          setState(() {
            imeiDemo = el.imei;
          });
        }
      });
    }
  }

  readPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? get = prefs.getBool('biometricLogin');
    bml = get!;
    print('Biometric: $bml');
    setState(() {
      biometricLogin = bml;
    });
  }

  getLocal() async {
    final version = await PackageInfo.fromPlatform();
    appVersion = version.version;
    buildNumber = version.buildNumber;
    appName = version.appName;
    localData = await GeneralService().readLocalUserStorage();
    url = await GeneralService().readLocalUrl();
    setState(() {
      fullName = localData.Fullname;
      userName = localData.Username;
    });
  }

  @override
  Widget build(BuildContext context) {
    Padding progressComplete = Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Container(
        // width: width / 7,
        height: 8,
        decoration: BoxDecoration(
          color: yellowPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );

    Padding progressIncomplete = Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Container(
        // width: width / 7,
        height: 8,
        decoration: BoxDecoration(
          color: whiteColorDarkMode,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
    return Scaffold(
      body:
          //     ListView(padding: const EdgeInsets.only(top: 30), children: <Widget>[
          //   Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       if (_supportState == _SupportState.unknown)
          //         const CircularProgressIndicator()
          //       else if (_supportState == _SupportState.supported)
          //         const Text('This device is supported')
          //       else
          //         const Text('This device is not supported'),
          //       const Divider(height: 100),
          //       Text('Can check biometrics: $_canCheckBiometrics\n'),
          //       ElevatedButton(
          //         onPressed: _checkBiometrics,
          //         child: const Text('Check biometrics'),
          //       ),
          //       const Divider(height: 100),
          //       Text('Available biometrics: $_availableBiometrics\n'),
          //       ElevatedButton(
          //         onPressed: _getAvailableBiometrics,
          //         child: const Text('Get available biometrics'),
          //       ),
          //       const Divider(height: 100),
          //       Text('Current State: $_authorized\n'),
          //       if (_isAuthenticating)
          //         ElevatedButton(
          //           onPressed: _cancelAuthentication,
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: <Widget>[
          //               Text('Cancel Authentication'),
          //               Icon(Icons.cancel),
          //             ],
          //           ),
          //         )
          //       else
          //         Column(
          //           children: <Widget>[
          //             ElevatedButton(
          //               onPressed: _authenticate,
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: <Widget>[
          //                   Text('Authenticate'),
          //                   Icon(Icons.perm_device_information),
          //                 ],
          //               ),
          //             ),
          //             ElevatedButton(
          //               onPressed: _authenticateWithBiometrics,
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: <Widget>[
          //                   Text(_isAuthenticating
          //                       ? 'Cancel'
          //                       : 'Authenticate: biometrics only'),
          //                   const Icon(Icons.fingerprint),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         ),
          //     ],
          //   ),
          // ]),
          Container(
        decoration: BoxDecoration(
            color: widget.darkMode ? whiteCardColor : blueGradient),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color:
                                widget.darkMode ? whiteColor : whiteCardColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/user.png',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(fullName,
                                  maxLines: 3,
                                  minFontSize: 14,
                                  maxFontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  style: bold.copyWith(
                                    // fontSize: 16,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : whiteColor,
                                  )),
                              Text(userName,
                                  style: reguler.copyWith(
                                    fontSize: 14,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : whiteColor,
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  // height: 500,
                  child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: whiteColor,
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: whiteColor,
                  //     offset: const Offset(0.0, 1.0),
                  //     blurRadius: 9.0,
                  //   ),
                  // ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Visibility(
                          visible: userName == 'demo' ? false : true,
                          child: SizedBox(
                            // width: MediaQuery.of(context).size.width * (95 / 100),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/editprofile');
                                    },
                                    child: Visibility(
                                      visible: localData.Privilage != 4
                                          ? false
                                          : widget.completeProfile,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 32, left: 16),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.2,
                                          height: 120,
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              gradient: SweepGradient(
                                                  startAngle: 5.0,
                                                  endAngle: 5.8,
                                                  stops: [1.2, 2.5, 3.1],
                                                  center: Alignment.bottomLeft,
                                                  transform:
                                                      GradientRotation(-0.4),
                                                  colors: [
                                                    Color(0xFFF4882A),
                                                    Color(0xFFFFC717),
                                                    Color.fromARGB(
                                                        255, 255, 155, 41),
                                                  ])),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 25, horizontal: 15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .completeProfile,
                                                    style: bold.copyWith(
                                                        color:
                                                            whiteColorDarkMode,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    child: widget
                                                                .progressCount ==
                                                            1
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                  child:
                                                                      progressComplete),
                                                              Expanded(
                                                                  child:
                                                                      progressIncomplete),
                                                              Expanded(
                                                                  child:
                                                                      progressIncomplete),
                                                              Expanded(
                                                                  child:
                                                                      progressIncomplete),
                                                              Expanded(
                                                                  child:
                                                                      progressIncomplete)
                                                            ],
                                                          )
                                                        : widget.progressCount ==
                                                                2
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          progressComplete),
                                                                  Expanded(
                                                                      child:
                                                                          progressComplete),
                                                                  Expanded(
                                                                      child:
                                                                          progressIncomplete),
                                                                  Expanded(
                                                                      child:
                                                                          progressIncomplete),
                                                                  Expanded(
                                                                      child:
                                                                          progressIncomplete)
                                                                ],
                                                              )
                                                            : widget.progressCount ==
                                                                    3
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              progressComplete),
                                                                      Expanded(
                                                                          child:
                                                                              progressComplete),
                                                                      Expanded(
                                                                          child:
                                                                              progressComplete),
                                                                      Expanded(
                                                                          child:
                                                                              progressIncomplete),
                                                                      Expanded(
                                                                          child:
                                                                              progressIncomplete)
                                                                    ],
                                                                  )
                                                                : widget.progressCount ==
                                                                        4
                                                                    ? Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                              child: progressComplete),
                                                                          Expanded(
                                                                              child: progressComplete),
                                                                          Expanded(
                                                                              child: progressComplete),
                                                                          Expanded(
                                                                              child: progressComplete),
                                                                          Expanded(
                                                                              child: progressIncomplete)
                                                                        ],
                                                                      )
                                                                    : widget.progressCount ==
                                                                            0
                                                                        ? Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Expanded(child: progressIncomplete),
                                                                              Expanded(child: progressIncomplete),
                                                                              Expanded(child: progressIncomplete),
                                                                              Expanded(child: progressIncomplete),
                                                                              Expanded(child: progressIncomplete)
                                                                            ],
                                                                          )
                                                                        : Container()),
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    child: RichText(
                                                        text:
                                                            TextSpan(children: [
                                                      TextSpan(
                                                        text:
                                                            '${AppLocalizations.of(context)!.done} ',
                                                        style: reguler.copyWith(
                                                            color:
                                                                whiteColorDarkMode,
                                                            fontSize: 10),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '${widget.progressCount} ${AppLocalizations.of(context)!.ofs} 5. ',
                                                        style: reguler.copyWith(
                                                            color:
                                                                whiteColorDarkMode,
                                                            fontSize: 10),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '${AppLocalizations.of(context)!.completeProfileSub} ',
                                                        style: reguler.copyWith(
                                                            color:
                                                                whiteColorDarkMode,
                                                            fontSize: 10),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .updateProfile,
                                                        style: bold.copyWith(
                                                            color:
                                                                whiteColorDarkMode,
                                                            fontSize: 10,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                whiteColorDarkMode),
                                                      )
                                                    ]))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    // onTap: () async {
                                    //   var result;
                                    //   final res = await APIService()
                                    //       .getAddressII(
                                    //           '-6.1779716', '106.8126492');
                                    //   result = parse(res);

                                    //   print(result.outerHTML);
                                    // },
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .accountInfo,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackPrimary,
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/editprofile');
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: 50,
                                            child: Image.asset(
                                              'assets/icon/otherpage/profile.png',
                                              height: 30,
                                            )),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .profile,
                                            style: reguler.copyWith(
                                              fontSize: 12,
                                              color: blackPrimary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 50,
                                            child: Image.asset(
                                              'assets/arrowright.png',
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : null,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 2,
                                    thickness: 1,
                                    indent: 0,
                                    endIndent: 0,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : greyColor,
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Visibility(
                        visible: userName == 'demo' ||
                                localData.IsGoogle ||
                                localData.IsApple
                            ? false
                            : true,
                        child: SizedBox(
                          // width: MediaQuery.of(context).size.width * (95 / 100),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/changepass');
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: 50,
                                            child: Image.asset(
                                              'assets/icon/otherpage/changepassword.png',
                                              height: 30,
                                            )),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .changePass,
                                            style: reguler.copyWith(
                                              fontSize: 12,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackPrimary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 50,
                                            child: Image.asset(
                                              'assets/arrowright.png',
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : null,
                                            )),
                                      ],
                                    )),
                                Divider(
                                  height: 2,
                                  thickness: 1,
                                  indent: 0,
                                  endIndent: 0,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : greyColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    await Dialogs().loadingDialog(context);
                                    localData.IsGoogle
                                        ? _currentUser != null
                                            ? _googleSignIn.signOut()
                                            : {}
                                        : {};
                                    final result =
                                        await APIService().doLogout();
                                    if (result is ErrorTrapModel) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          content: Text(
                                            'Logout failed',
                                            style: reguler.copyWith(
                                              fontSize: 12,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : whiteColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      await firebase.deleteToken();
                                      await GeneralService()
                                          .deleteLocalAlarmStorage();
                                      await GeneralService()
                                          .deleteLocalAlarmTypeID();
                                      await GeneralService()
                                          .deleteLocalUserStorage();
                                      await GeneralService().deleteLocalURL();
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              '/login', (route) => false);
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/icon/otherpage/logout.png',
                                            height: 30,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.logout,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/arrowright.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : null,
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!
                                      .generalInformation,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackPrimary,
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                  onTap: () async {
                                    launchUrl(Uri.parse(url.data.head.aboutUs),
                                        mode: LaunchMode.externalApplication);
                                    // print(url.data.results.aboutUs);
                                    // Navigator.pushNamed(context, '/insertOTP');
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/icon/otherpage/aboutus.png',
                                            height: 30,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.aboutUs,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/arrowright.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : null,
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        'tel://${url.data.head.callUs}'));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/icon/otherpage/callus.png',
                                            height: 30,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.callUs,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/arrowright.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : null,
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse(url.data.head.terms),
                                        mode: LaunchMode.externalApplication);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/icon/otherpage/licenseandagreement.png',
                                            height: 30,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .licenseAndAgreement,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/arrowright.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : null,
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Apps',
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackPrimary,
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                  onTap: () async {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    // final bool? darkmode =
                                    //     prefs.getBool('darkmode');
                                    showModalBottomSheet(
                                      backgroundColor: whiteCardColor,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12)),
                                      ),
                                      context: context,
                                      builder: (context) {
                                        return SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 15),
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    await prefs.setBool(
                                                        'darkmode', false);
                                                    Restart.restartApp();
                                                  },
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18.0),
                                                      child: Text(
                                                        'Light',
                                                        style: reguler.copyWith(
                                                            color: !widget
                                                                    .darkMode
                                                                ? bluePrimary
                                                                : blackPrimary),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  indent: 0,
                                                  endIndent: 0,
                                                  color: greyColorSecondary,
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    await prefs.setBool(
                                                        'darkmode', true);
                                                    Restart.restartApp();
                                                  },
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18.0),
                                                      child: Text(
                                                        'Dark',
                                                        style: reguler.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? bluePrimary
                                                                : blackPrimary),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Icon(
                                            Icons.color_lens_outlined,
                                            color: blueGradient,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .changeTheme,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/arrowright.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : null,
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                              InkWell(
                                  onTap: () async {
                                    //get notif setting
                                    Dialogs().loadingDialog(context);
                                    final result = await APIService()
                                        .getNotificationSetting();
                                    print(result);
                                    if (result is GetNotificationSettingModel) {
                                      Dialogs().hideLoaderDialog(context);
                                      showModalBottomSheet(
                                        backgroundColor: whiteCardColor,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                        ),
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState1) {
                                              return SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .notificationSetting,
                                                            style: bold.copyWith(
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary1,
                                                                fontSize: 14),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        Dialogs().loadingDialog(
                                                            context);
                                                        List<dynamic>
                                                            setAllNotif = [];

                                                        selectAll = !selectAll;
                                                        for (var el in result
                                                            .message
                                                            .dataNotificationSetting) {
                                                          if (selectAll) {
                                                            el.isActive = true;
                                                          } else {
                                                            el.isActive = false;
                                                          }

                                                          setAllNotif.addAll([
                                                            {
                                                              "alert_no":
                                                                  el.alertNo,
                                                              "is_active":
                                                                  el.isActive
                                                                      ? 0
                                                                      : 1
                                                            }
                                                            // el.alertNo,
                                                            // el.isActive == 0 ? 1 : 0
                                                          ]);
                                                        }
                                                        print(jsonEncode(
                                                            setAllNotif));
                                                        final setNotif =
                                                            await APIService()
                                                                .setAllNotification(
                                                                    setAllNotif);
                                                        print(setNotif);
                                                        if (setNotif
                                                            is MessageModel) {
                                                          if (setNotif.status) {
                                                            setState1(() {
                                                              result.message
                                                                  .dataNotificationSetting
                                                                  .forEach(
                                                                      (el) {
                                                                el.isActive =
                                                                    !el.isActive;
                                                              });
                                                            });
                                                          } else {
                                                            setState1(() {});
                                                          }
                                                        } else {
                                                          Dialogs()
                                                              .hideLoaderDialog(
                                                                  context);
                                                          showInfoAlert(
                                                              context,
                                                              'Something happend',
                                                              '');
                                                        }
                                                        // setState(() {});
                                                        Dialogs()
                                                            .hideLoaderDialog(
                                                                context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 5,
                                                                horizontal: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .selectAll,
                                                              style: reguler.copyWith(
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary1,
                                                                  fontSize: 14),
                                                            ),
                                                            SizedBox(
                                                                width: 50,
                                                                child: Switch(
                                                                  inactiveTrackColor:
                                                                      widget.darkMode
                                                                          ? greyColor
                                                                          : null,
                                                                  value:
                                                                      !selectAll,
                                                                  onChanged:
                                                                      (value) async {
                                                                    Dialogs()
                                                                        .loadingDialog(
                                                                            context);
                                                                    List<dynamic>
                                                                        setAllNotif =
                                                                        [];

                                                                    selectAll =
                                                                        !selectAll;
                                                                    for (var el in result
                                                                        .message
                                                                        .dataNotificationSetting) {
                                                                      if (selectAll) {
                                                                        el.isActive =
                                                                            true;
                                                                      } else {
                                                                        el.isActive =
                                                                            false;
                                                                      }

                                                                      setAllNotif
                                                                          .addAll([
                                                                        {
                                                                          "alert_no":
                                                                              el.alertNo,
                                                                          "is_active": el.isActive
                                                                              ? 0
                                                                              : 1
                                                                        }
                                                                        // el.alertNo,
                                                                        // el.isActive == 0 ? 1 : 0
                                                                      ]);
                                                                    }
                                                                    print(jsonEncode(
                                                                        setAllNotif));
                                                                    final setNotif =
                                                                        await APIService()
                                                                            .setAllNotification(setAllNotif);
                                                                    print(
                                                                        setNotif);
                                                                    if (setNotif
                                                                        is MessageModel) {
                                                                      if (setNotif
                                                                          .status) {
                                                                        setState1(
                                                                            () {
                                                                          result
                                                                              .message
                                                                              .dataNotificationSetting
                                                                              .forEach((el) {
                                                                            el.isActive =
                                                                                !el.isActive;
                                                                          });
                                                                        });
                                                                      } else {
                                                                        setState1(
                                                                            () {});
                                                                      }
                                                                    } else {
                                                                      Dialogs()
                                                                          .hideLoaderDialog(
                                                                              context);
                                                                      showInfoAlert(
                                                                          context,
                                                                          'Something happend',
                                                                          '');
                                                                    }
                                                                    // setState(() {});
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                  },
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      15),
                                                          child:
                                                              ListView.builder(
                                                            itemCount: result
                                                                .message
                                                                .dataNotificationSetting
                                                                .length,
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                                  return InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Dialogs()
                                                                          .loadingDialog(
                                                                              context);
                                                                      final setNotif = await APIService().setNotification(
                                                                          result
                                                                              .message
                                                                              .dataNotificationSetting[
                                                                                  index]
                                                                              .alertNo,
                                                                          result.message.dataNotificationSetting[index].isActive
                                                                              ? 0
                                                                              : 1,
                                                                          result
                                                                              .message
                                                                              .dataNotificationSetting[index]
                                                                              .code);
                                                                      if (setNotif
                                                                          is MessageModel) {
                                                                        setState(
                                                                            () {
                                                                          setState1(
                                                                              () {
                                                                            !selectAll
                                                                                ? selectAll = !selectAll
                                                                                : {};
                                                                          });

                                                                          result
                                                                              .message
                                                                              .dataNotificationSetting[index]
                                                                              .isActive = !result.message.dataNotificationSetting[index].isActive;
                                                                        });
                                                                        Dialogs()
                                                                            .hideLoaderDialog(context);
                                                                      } else {
                                                                        Dialogs()
                                                                            .hideLoaderDialog(context);
                                                                        showInfoAlert(
                                                                            context,
                                                                            'Something happend',
                                                                            '');
                                                                      }
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                // Text(
                                                                                //     '${index + 1}'),
                                                                                Text(result.message.dataNotificationSetting[index].code, style: reguler.copyWith(color: blackPrimary, fontSize: 12)),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                                width: 50,
                                                                                child: Switch(
                                                                                  inactiveTrackColor: widget.darkMode ? greyColor : null,
                                                                                  value: result.message.dataNotificationSetting[index].isActive,
                                                                                  onChanged: (value) async {
                                                                                    Dialogs().loadingDialog(context);
                                                                                    final setNotif = await APIService().setNotification(result.message.dataNotificationSetting[index].alertNo, result.message.dataNotificationSetting[index].isActive ? 0 : 1, result.message.dataNotificationSetting[index].code);
                                                                                    if (setNotif is MessageModel) {
                                                                                      setState(() {
                                                                                        setState1(() {
                                                                                          !selectAll ? selectAll = !selectAll : {};
                                                                                        });
                                                                                        result.message.dataNotificationSetting[index].isActive = !result.message.dataNotificationSetting[index].isActive;
                                                                                      });
                                                                                      Dialogs().hideLoaderDialog(context);
                                                                                    } else {
                                                                                      Dialogs().hideLoaderDialog(context);
                                                                                      showInfoAlert(context, 'Something happend', '');
                                                                                    }
                                                                                  },
                                                                                )),
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
                                                                          color:
                                                                              greyColorSecondary,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }

                                    // Dialogs().hideLoaderDialog(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Icon(
                                            Icons.notifications_on_outlined,
                                            color: blueGradient,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .notificationSetting,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/arrowright.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : null,
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    setState(() {
                                      biometricLogin = !biometricLogin;
                                    });
                                    print('Status biometric: $biometricLogin');
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'biometricLogin', biometricLogin);
                                    // launchUrl(Uri.parse(
                                    //     'tel://${url.data.head.callUs}'));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Icon(
                                            Icons.fingerprint_outlined,
                                            color: blueGradient,
                                          )),
                                      Expanded(
                                        child: Text(
                                          'Biometric login',
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Switch(
                                            inactiveTrackColor: widget.darkMode
                                                ? greyColor
                                                : null,
                                            value: biometricLogin,
                                            onChanged: (value) async {
                                              setState(() {
                                                biometricLogin =
                                                    !biometricLogin;
                                              });
                                              print(
                                                  'Status biometric: $biometricLogin');
                                              final SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setBool(
                                                  'biometricLogin',
                                                  biometricLogin);
                                            },
                                          )),
                                    ],
                                  )),
                              Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * (95 / 100),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    final version =
                                        await PackageInfo.fromPlatform();
                                    setState(() {
                                      appVersion == version.version
                                          ? appVersion = version.buildNumber
                                          : appVersion = version.version;
                                    });
                                  },
                                  onLongPress: () async {
                                    String fcmToken = await firebase.getToken();
                                    // await GeneralService().deleteLocalIAP();

                                    await Clipboard.setData(
                                            ClipboardData(text: fcmToken))
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor: blueGradient,
                                              content:
                                                  const Text("FCM Copied")));
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Image.asset(
                                            'assets/logogpsid.png',
                                            height: 30,
                                            color: blueGradient,
                                          )),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .appVersion,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(appVersion,
                                          textAlign: TextAlign.end,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackPrimary,
                                          ))
                                    ],
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  height: 2,
                                  thickness: 1,
                                  indent: 0,
                                  endIndent: 0,
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // SizedBox(
                      //   // width: MediaQuery.of(context).size.width * (95 / 100),
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(
                      //         left: 16, right: 16, bottom: 10),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         InkWell(
                      //             onTap: () async {
                      //               final version =
                      //                   await PackageInfo.fromPlatform();
                      //               setState(() {
                      //                 appVersion == version.version
                      //                     ? appVersion = version.buildNumber
                      //                     : appVersion = version.version;
                      //               });
                      //             },
                      //             onLongPress: () async {
                      //               String fcmToken = await firebase.getToken();
                      //               // await GeneralService().deleteLocalIAP();

                      //               await Clipboard.setData(
                      //                       ClipboardData(text: fcmToken))
                      //                   .then((_) {
                      //                 ScaffoldMessenger.of(context)
                      //                     .showSnackBar(SnackBar(
                      //                         backgroundColor: blueGradient,
                      //                         content:
                      //                             const Text("FCM Copied")));
                      //               });
                      //             },
                      //             // onTap: () async {
                      //             //   final version =
                      //             //       await PackageInfo.fromPlatform();
                      //             //   setState(() {
                      //             //     appVersion = version.version;
                      //             //   });
                      //             // },
                      //             child: Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 SizedBox(
                      //                     width: 50,
                      //                     child: Image.asset(
                      //                       'assets/logogpsid.png',
                      //                       color: blueGradient,
                      //                     )),
                      //                 Expanded(
                      //                   child: Text(
                      //                     AppLocalizations.of(context)!
                      //                         .appVersion,
                      //                     style: reguler.copyWith(
                      //                       fontSize: 12,
                      //                       color: widget.darkMode
                      //                           ? whiteColorDarkMode
                      //                           : blackPrimary,
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 Text(appVersion,
                      //                     textAlign: TextAlign.end,
                      //                     style: reguler.copyWith(
                      //                       fontSize: 12,
                      //                       color: widget.darkMode
                      //                           ? whiteColorDarkMode
                      //                           : blackPrimary,
                      //                     ))
                      //               ],
                      //             )),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   // width: MediaQuery.of(context).size.width * (95 / 100),
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(
                      //         left: 16, right: 16, bottom: 10),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         InkWell(
                      //           onTap: () async {
                      //             final SharedPreferences prefs =
                      //                 await SharedPreferences.getInstance();
                      //             final bool? darkmode =
                      //                 prefs.getBool('darkmode');
                      //             showModalBottomSheet(
                      //               backgroundColor: whiteCardColor,
                      //               shape: const RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.only(
                      //                     topLeft: Radius.circular(12),
                      //                     topRight: Radius.circular(12)),
                      //               ),
                      //               context: context,
                      //               builder: (context) {
                      //                 return SingleChildScrollView(
                      //                   child: Padding(
                      //                     padding: const EdgeInsets.symmetric(
                      //                         vertical: 5, horizontal: 15),
                      //                     child: Column(
                      //                       children: [
                      //                         InkWell(
                      //                           onTap: () async {
                      //                             await prefs.setBool(
                      //                                 'darkmode', false);
                      //                             Restart.restartApp();
                      //                           },
                      //                           child: SizedBox(
                      //                             width: MediaQuery.of(context)
                      //                                 .size
                      //                                 .width,
                      //                             child: Padding(
                      //                               padding:
                      //                                   const EdgeInsets.all(
                      //                                       18.0),
                      //                               child: Text(
                      //                                 'Light',
                      //                                 style: reguler.copyWith(
                      //                                     color: !widget
                      //                                             .darkMode
                      //                                         ? bluePrimary
                      //                                         : blackPrimary),
                      //                                 textAlign:
                      //                                     TextAlign.center,
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         ),
                      //                         Divider(
                      //                           height: 1,
                      //                           thickness: 1,
                      //                           indent: 0,
                      //                           endIndent: 0,
                      //                           color: greyColorSecondary,
                      //                         ),
                      //                         InkWell(
                      //                           onTap: () async {
                      //                             await prefs.setBool(
                      //                                 'darkmode', true);
                      //                             Restart.restartApp();
                      //                           },
                      //                           child: SizedBox(
                      //                             width: MediaQuery.of(context)
                      //                                 .size
                      //                                 .width,
                      //                             child: Padding(
                      //                               padding:
                      //                                   const EdgeInsets.all(
                      //                                       18.0),
                      //                               child: Text(
                      //                                 'Dark',
                      //                                 style: reguler.copyWith(
                      //                                     color: widget.darkMode
                      //                                         ? bluePrimary
                      //                                         : blackPrimary),
                      //                                 textAlign:
                      //                                     TextAlign.center,
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             );
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             children: [
                      //               Text(
                      //                 'Change theme',
                      //                 style: reguler.copyWith(
                      //                     color: widget.darkMode
                      //                         ? whiteColorDarkMode
                      //                         : blackSecondary2,
                      //                     fontSize: 14),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //         // Divider(
                      //         //   height: 2,
                      //         //   thickness: 1,
                      //         //   indent: 0,
                      //         //   endIndent: 0,
                      //         //   color: greyColor,
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   // width: MediaQuery.of(context).size.width * (95 / 100),
                      //   child: Padding(
                      //       padding: const EdgeInsets.only(
                      //           left: 16, right: 16, bottom: 10),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Text(
                      //             'Biometric login',
                      //             style: reguler.copyWith(
                      //                 color: widget.darkMode
                      //                     ? whiteColorDarkMode
                      //                     : blackSecondary2,
                      //                 fontSize: 14),
                      //           ),
                      //           Switch(
                      //             value: biometricLogin,
                      //             // activeColor: blackPrimary,
                      //             // activeThumbImage:
                      //             //     const AssetImage(
                      //             //         'assets/mapcenter.png'),
                      //             // inactiveThumbImage:
                      //             //     const AssetImage(
                      //             //         'assets/mapcenter.png'),
                      //             onChanged: (value) {
                      //               setState(() {
                      //                 biometricLogin = !biometricLogin;
                      //               });
                      //               print('Status biometric: $biometricLogin');
                      //             },
                      //           )
                      //           // Text(
                      //           //   'Biometric login',
                      //           //   style: reguler.copyWith(
                      //           //       color: widget.darkMode
                      //           //           ? whiteColorDarkMode
                      //           //           : blackSecondary2,
                      //           //       fontSize: 14),
                      //           // ),
                      //         ],
                      //       )),
                      // ),
                      // SizedBox(
                      //   width: 350,
                      //   child: Padding(
                      //       padding: const EdgeInsets.all(15),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           SizedBox(
                      //               width: 50,
                      //               child: Image.asset(
                      //                 'assets/logogpsid.png',
                      //                 color: blueGradient,
                      //               )),
                      //           Expanded(
                      //             child: Text(
                      //               AppLocalizations.of(context)!.appVersion,
                      //               style: reguler.copyWith(
                      //                 fontSize: 12,
                      //                 color: blackPrimary,
                      //               ),
                      //             ),
                      //           ),
                      //           SizedBox(
                      //               width: 50,
                      //               child: Text(
                      //                 '4.0',
                      //                 textAlign: TextAlign.end,
                      //                 style: reguler.copyWith(
                      //                   fontSize: 12,
                      //                   color: blackPrimary,
                      //                 ),
                      //               )),
                      //         ],
                      //       )
                      //       // Row(
                      //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       //   children: [
                      //       //     Text(
                      //       //       AppLocalizations.of(context)!.appVersion,
                      //       //       style: reguler.copyWith(
                      //       //         fontSize: 12,
                      //       //         color: blackPrimary,
                      //       //       ),
                      //       //     ),
                      //       //     Text(
                      //       //       '4.0',
                      //       //       textAlign: TextAlign.end,
                      //       //       style: reguler.copyWith(
                      //       //         fontSize: 12,
                      //       //         color: blackPrimary,
                      //       //       ),
                      //       //     ),
                      //       //     // SizedBox(
                      //       //     //   width:
                      //       //     //       MediaQuery.of(context).size.width * 0.60,
                      //       //     //   child: Text(
                      //       //     //     AppLocalizations.of(context)!.appVersion,
                      //       //     //     style: reguler.copyWith(
                      //       //     //       fontSize: 12,
                      //       //     //       color: blackPrimary,
                      //       //     //     ),
                      //       //     //   ),
                      //       //     // ),
                      //       //     // SizedBox(
                      //       //     //   width: 50,
                      //       //     //   child: Text(
                      //       //     //     '4.0',
                      //       //     //     textAlign: TextAlign.end,
                      //       //     //     style: reguler.copyWith(
                      //       //     //       fontSize: 12,
                      //       //     //       color: blackPrimary,
                      //       //     //     ),
                      //       //     //   ),
                      //       //     // ),
                      //       //   ],
                      //       // ),
                      //       ),
                      // ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
