// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_constructors, unused_field

import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/deleteaccount.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/profile.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/pages/deleteAccount.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/notification.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:skeletons/skeletons.dart';

class EditProfile extends StatefulWidget {
  final bool darkMode;
  const EditProfile({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var inputText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write('-');
      }
    }

    var string = bufferString.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class CVVNumberFormater extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var inputText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 2 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write('/');
      }
    }

    var string = bufferString.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class _EditProfileState extends State<EditProfile> {
  var size, height, width;
  final TextEditingController fullName = TextEditingController();
  final TextEditingController userName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController companyName = TextEditingController();
  final TextEditingController address = TextEditingController();
  bool isCheck = false;
  bool _isError = true;
  String _errCode = '';

  late Future<dynamic> _getProfile;
  late ProfileModel profile;
  FirebaseBackground firebase = FirebaseBackground();
  int callPreference = 0;
  bool completeProfile = false;
  int progressCount = 0;
  ScrollController scrollController = ScrollController();
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  GoogleSignInAccount? _currentUser;
  bool googleIsConnected = false;
  bool appleIsConnected = false;

  @override
  void dispose() {
    // cardNumber.dispose();
    // cvvcvnNumber.dispose();
    // expdate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getProfile = getProfile();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      print(_currentUser);
    });
  }

  Future<dynamic> getProfile() async {
    localData = await GeneralService().readLocalUserStorage();
    final result = await APIService().getProfile();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853GetProfile';
      });
    } else {
      late ProfileModel getProfile;
      getProfile = result;
      if (getProfile.data.result.preferensi.isNotEmpty) {
        setState(() {
          progressCount++;
        });
      }
      if (getProfile.data.result.fullname.isNotEmpty) {
        setState(() {
          progressCount++;
        });
      }
      if (getProfile.data.result.address.isNotEmpty) {
        setState(() {
          progressCount++;
        });
      }
      if (getProfile.data.result.isVerifiedEmail) {
        setState(() {
          progressCount++;
        });
      }
      if (getProfile.data.result.isVerifiedPhone) {
        setState(() {
          progressCount++;
        });
      }
      if (progressCount != 5) {
        setState(() {
          completeProfile = true;
        });
      }
      setState(() {
        _isError = false;
        _errCode = '';
        fullName.text = getProfile.data.result.fullname;
        userName.text = getProfile.data.result.username;
        email.text = getProfile.data.result.email;
        phoneNumber.text = getProfile.data.result.phone == ''
            ? ''
            : getProfile.data.result.phone.substring(0, 2).contains('62')
                ? getProfile.data.result.phone.replaceRange(0, 2, '')
                : getProfile.data.result.phone[0] == '+'
                    ? getProfile.data.result.phone.replaceRange(0, 3, '')
                    : getProfile.data.result.phone[1] == '0'
                        ? getProfile.data.result.phone.replaceRange(0, 1, '')
                        : getProfile.data.result.phone
                                .substring(0, 2)
                                .contains('620')
                            ? getProfile.data.result.phone
                                .replaceRange(0, 2, '')
                            : getProfile.data.result.phone;
        companyName.text = getProfile.data.result.companyName;
        address.text = getProfile.data.result.address;
        callPreference = getProfile.data.result.preferensiCode;
        // callPreference = getProfile.data.result.preferensi ==
        googleIsConnected = localData.IsGoogle;
        appleIsConnected = localData.IsApple;
      });
    }
    return result;
  }

  connectToGoogle() async {
    // _googleSignIn.isSignedIn() ? _googleSignIn.lo
    if (localData.IsGoogle) {
      Dialogs().loadingDialog(context);
      // _googleSignIn.currentUser != null ? _googleSignIn.signOut() : {};
      _googleSignIn.disconnect();
      final result = await APIService().editProfile(
          fullName.text.trim(),
          userName.text.trim(),
          address.text.trim(),
          companyName.text.trim(),
          callPreference,
          '',
          '',
          AppLocalizations.of(context)!.emailAlreadyUsed);
      if (result is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.statusError, '');
      } else {
        if (result is MessageModel) {
          if (result.status) {
            await firebase.deleteToken();
            await GeneralService().deleteLocalUserStorage();
            await GeneralService().deleteAlarmStorage();
            await GeneralService().deleteLocalAsset();
            await GeneralService().deleteLocalURL();
            await GeneralService().deleteRememberMe();
            Dialogs().hideLoaderDialog(context);
            // Navigator.of(context).pushReplacementNamed("/login");
            await Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
            if (result.message.contains('email sudah digunakan')) {
              Dialogs().hideLoaderDialog(context);
              showInfoAlert(context, result.message, '');
            } else {
              Dialogs().hideLoaderDialog(context);
              showInfoAlert(context, result.message, '');
            }
          }
        }
      }
    } else {
      // _googleSignIn.currentUser != null ? _googleSignIn.signOut() : {};
      _googleSignIn.disconnect();
      Dialogs().loadingDialog(context);
      try {
        await _googleSignIn.signIn();
        if (_googleSignIn.currentUser!.email.isNotEmpty) {
          if (_googleSignIn.currentUser!.email != email.text) {
            Dialogs().hideLoaderDialog(context);
            showInfoAlert(
                context, AppLocalizations.of(context)!.differentEmail, '');
          } else {
            final result = await APIService().editProfile(
                fullName.text.trim(),
                userName.text.trim(),
                address.text.trim(),
                companyName.text.trim(),
                callPreference,
                _googleSignIn.currentUser!.id,
                '',
                AppLocalizations.of(context)!.emailAlreadyUsed);
            if (result is ErrorTrapModel) {
              Dialogs().hideLoaderDialog(context);
              showInfoAlert(context, result.statusError, '');
            } else {
              if (result is MessageModel) {
                LocalData data = LocalData(
                    ID: localData.ID,
                    SeenId: localData.SeenId,
                    Username: localData.Username,
                    Password: _googleSignIn.currentUser!.id,
                    Fullname: localData.Fullname,
                    Phone: localData.Phone,
                    Email: localData.Email,
                    Addres: localData.Addres,
                    CompanyName: localData.CompanyName,
                    BranchId: localData.BranchId,
                    Privilage: localData.Privilage,
                    Token: localData.Token,
                    IsGoogle: true,
                    IsApple: false,
                    IsGenerated: localData.IsGenerated,
                    createdAt: localData.createdAt);
                await GeneralService().writeLocalUserStorage(data);
                Dialogs().hideLoaderDialog(context);
                setState(() {
                  googleIsConnected = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: greenPrimary,
                    content: Text(
                      AppLocalizations.of(context)!.accountConnectedWithGoogle,
                      style: reguler.copyWith(
                        fontSize: 12,
                        color: whiteColorDarkMode,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
                Navigator.of(context).pushReplacementNamed("/");
                // await Navigator.of(context)
                //     .pushNamedAndRemoveUntil('/', (route) => false);
              }
            }
          }
        }
      } catch (error) {
        Dialogs().hideLoaderDialog(context);
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }

  connectToApple() async {
    // _googleSignIn.isSignedIn() ? _googleSignIn.lo
    if (localData.IsApple) {
      Dialogs().loadingDialog(context);
      final result = await APIService().editProfile(
          fullName.text.trim(),
          userName.text.trim(),
          address.text.trim(),
          companyName.text.trim(),
          callPreference,
          '',
          '',
          AppLocalizations.of(context)!.emailAlreadyUsed);
      if (result is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.statusError, '');
      } else {
        if (result is MessageModel) {
          if (result.status) {
            await firebase.deleteToken();
            await GeneralService().deleteLocalUserStorage();
            await GeneralService().deleteAlarmStorage();
            await GeneralService().deleteLocalAsset();
            await GeneralService().deleteLocalURL();
            await GeneralService().deleteRememberMe();
            Dialogs().hideLoaderDialog(context);
            // Navigator.of(context).pushReplacementNamed("/login");
            await Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
            if (result.message.contains('email sudah digunakan')) {
              Dialogs().hideLoaderDialog(context);
              showInfoAlert(context, result.message, '');
            } else {
              Dialogs().hideLoaderDialog(context);
              showInfoAlert(context, result.message, '');
            }
          }
        }
      }
    } else {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.userIdentifier!.isNotEmpty) {
        Dialogs().loadingDialog(context);
        final result = await APIService().editProfile(
            fullName.text.trim(),
            userName.text.trim(),
            address.text.trim(),
            companyName.text.trim(),
            callPreference,
            '',
            credential.userIdentifier.toString(),
            AppLocalizations.of(context)!.emailAlreadyUsed);
        if (result is ErrorTrapModel) {
          Dialogs().hideLoaderDialog(context);
          showInfoAlert(context, result.statusError, '');
        } else {
          if (result is MessageModel) {
            LocalData data = LocalData(
                ID: localData.ID,
                SeenId: localData.SeenId,
                Username: localData.Username,
                Password: credential.userIdentifier.toString(),
                Fullname: localData.Fullname,
                Phone: localData.Phone,
                Email: localData.Email,
                Addres: localData.Addres,
                CompanyName: localData.CompanyName,
                BranchId: localData.BranchId,
                Privilage: localData.Privilage,
                Token: localData.Token,
                IsGoogle: false,
                IsApple: true,
                IsGenerated: localData.IsGenerated,
                createdAt: localData.createdAt);
            await GeneralService().writeLocalUserStorage(data);
            Dialogs().hideLoaderDialog(context);
            setState(() {
              appleIsConnected = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: greenPrimary,
                content: Text(
                  AppLocalizations.of(context)!.accountConnectedWithApple,
                  style: reguler.copyWith(
                    fontSize: 12,
                    color: whiteColorDarkMode,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
            Navigator.of(context).pushReplacementNamed("/");
            // await Navigator.of(context)
            //     .pushNamedAndRemoveUntil('/', (route) => false);
          }
        }
      }
    }
  }

  doEditProfile() async {
    Dialogs().loadingDialog(context);
    final result = await APIService().editProfile(
        fullName.text.trim(),
        userName.text.trim(),
        address.text.trim(),
        companyName.text.trim(),
        callPreference,
        localData.IsGoogle ? localData.Password : '',
        localData.IsApple ? localData.Password : '',
        AppLocalizations.of(context)!.emailAlreadyUsed);
    if (result is ErrorTrapModel) {
      Navigator.pop(context);
      setState(() {
        _isError = true;
        _errCode = '76845editprofile';
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
      });
      return Timer.run(() async {
        await GeneralService().deleteLocalAlarmStorage();
        await GeneralService().deleteLocalAlarmTypeID();
        Navigator.pop(context);
        showSuccessEditProfile(context, result.message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
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
          color: yellowSecondary,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );

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
          AppLocalizations.of(context)!.editProfile,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      body: Container(
        color: whiteColor,
        child: FutureBuilder(
            future: _getProfile,
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
                  profile = snapshot.data;
                  return SingleChildScrollView(
                    controller: scrollController,
                    physics:
                        const ScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: progressCount == 5 ? false : true,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!
                                                .completeProfile,
                                            style: bold.copyWith(
                                              fontSize: 14,
                                              color: blackPrimary,
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: progressCount == 1
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
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
                                                : progressCount == 2
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
                                                    : progressCount == 3
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
                                                        : progressCount == 4
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
                                                                          progressComplete),
                                                                  Expanded(
                                                                      child:
                                                                          progressIncomplete)
                                                                ],
                                                              )
                                                            : progressCount == 0
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
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
                                                                              progressIncomplete),
                                                                      Expanded(
                                                                          child:
                                                                              progressIncomplete)
                                                                    ],
                                                                  )
                                                                : Container()),
                                        Text(
                                            '${AppLocalizations.of(context)!.done} $progressCount ${AppLocalizations.of(context)!.ofs} 5',
                                            style: reguler.copyWith(
                                              fontSize: 14,
                                              color: blackPrimary,
                                            )),
                                        SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    progressCount = 0;
                                                  });
                                                  await Navigator.pushNamed(
                                                      context,
                                                      '/verifEmailNow');
                                                  _getProfile = getProfile();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 5),
                                                  child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: whiteCardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  4)),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .verifEmailButton,
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 14,
                                                            color: blackPrimary,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: profile
                                                                  .data
                                                                  .result
                                                                  .isVerifiedEmail
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  color:
                                                                      greenPrimary,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .add_circle_outline_outlined,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    progressCount = 0;
                                                  });
                                                  await Navigator.pushNamed(
                                                      context,
                                                      '/verifyPhoneNumber');
                                                  _getProfile = getProfile();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 5),
                                                  child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: whiteCardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  4)),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .verifyPhone,
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 14,
                                                            color: blackPrimary,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: profile
                                                                  .data
                                                                  .result
                                                                  .isVerifiedPhone
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  color:
                                                                      greenPrimary,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .add_circle_outline_outlined,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  scrollController.animateTo(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          2,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      curve: Curves.easeIn);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 5),
                                                  child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: whiteCardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  4)),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Preffered contact',
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 14,
                                                            color: blackPrimary,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: profile
                                                                      .data
                                                                      .result
                                                                      .preferensiCode !=
                                                                  0
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  color:
                                                                      greenPrimary,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .add_circle_outline_outlined,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  scrollController.animateTo(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          2,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      curve: Curves.easeIn);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 5),
                                                  child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: whiteCardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  4)),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .fullName,
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 14,
                                                            color: blackPrimary,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: profile
                                                                  .data
                                                                  .result
                                                                  .fullname
                                                                  .isNotEmpty
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  color:
                                                                      greenPrimary,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .add_circle_outline_outlined,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  scrollController.animateTo(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          2,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      curve: Curves.easeIn);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 5),
                                                  child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: whiteCardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  4)),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .address,
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 14,
                                                            color: blackPrimary,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: profile
                                                                  .data
                                                                  .result
                                                                  .address
                                                                  .isNotEmpty
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  color:
                                                                      greenPrimary,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .add_circle_outline_outlined,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:

                                      // localData.Privilage == 4 &&
                                      profile.data.result
                                                      .isVerifiedEmail ==
                                                  true &&
                                              !profile.data.result
                                                  .registerByGoogle &&
                                              !profile.data.result
                                                  .registerByApple &&
                                              !localData.IsGoogle &&
                                              Platform.isIOS
                                          // localData.Email.contains('@gmail') &&
                                          //         localData.Privilage == 4
                                          ? true
                                          : false,
                                  child: GestureDetector(
                                    onTap: () {
                                      // !localData.IsGoogle
                                      //     ? connectToGoogle()
                                      //     : {};
                                      localData.IsApple
                                          ? profile.data.result.registerByApple
                                              ? {}
                                              : showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor:
                                                      widget.darkMode
                                                          ? whiteCardColor
                                                          : whiteColor,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context,
                                                          setStateModal) {
                                                        return Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 100,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                connectToApple(),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              redPrimary)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        35,
                                                                    vertical:
                                                                        5),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .disconnectApple,
                                                                  style: reguler
                                                                      .copyWith(
                                                                          color:
                                                                              redPrimary,
                                                                          fontSize:
                                                                              16),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                )
                                          : connectToApple();
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: widget.darkMode
                                                ? whiteColor
                                                : blackPrimary,
                                            border: Border.all(
                                                width: 1,
                                                color: widget.darkMode
                                                    ? bluePrimary
                                                    : whiteColor),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.apple,
                                              size: 24,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : whiteColor,
                                            ),
                                            // 112371509314790906011
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AutoSizeText(
                                                    appleIsConnected
                                                        ? '${AppLocalizations.of(context)!.connectedWithApple}${profile.data.result.email}'
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .connectToApple,
                                                    maxFontSize: 14,
                                                    minFontSize: 14,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: bold.copyWith(
                                                      fontSize: 14,
                                                      color: widget.darkMode
                                                          ? bluePrimary
                                                          : whiteColor,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:

                                      // localData.Privilage == 4 &&
                                      profile.data.result
                                                      .isVerifiedEmail ==
                                                  true &&
                                              !profile.data.result
                                                  .registerByGoogle &&
                                              !profile.data.result
                                                  .registerByApple &&
                                              !localData.IsApple
                                          // localData.Email.contains('@gmail') &&
                                          //         localData.Privilage == 4
                                          ? true
                                          : false,
                                  child: GestureDetector(
                                    onTap: () {
                                      // !localData.IsGoogle
                                      //     ? connectToGoogle()
                                      //     : {};
                                      localData.IsGoogle
                                          ? profile.data.result.registerByGoogle
                                              ? {}
                                              : showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor:
                                                      widget.darkMode
                                                          ? whiteCardColor
                                                          : whiteColor,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context,
                                                          setStateModal) {
                                                        return Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 100,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                connectToGoogle(),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              redPrimary)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        35,
                                                                    vertical:
                                                                        5),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .disconnectGoogle,
                                                                  style: reguler
                                                                      .copyWith(
                                                                          color:
                                                                              redPrimary,
                                                                          fontSize:
                                                                              16),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                )
                                          : connectToGoogle();
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1, color: bluePrimary),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/icon/google.png',
                                              width: 20,
                                              height: 20,
                                            ),
                                            // 112371509314790906011
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AutoSizeText(
                                                    googleIsConnected
                                                        ? '${AppLocalizations.of(context)!.connectedWithGoogle}${profile.data.result.email}'
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .connectToGoogle,
                                                    maxFontSize: 14,
                                                    minFontSize: 14,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: bold.copyWith(
                                                      fontSize: 14,
                                                      color: bluePrimary,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(AppLocalizations.of(context)!.email,
                                    style: bold.copyWith(
                                      fontSize: 14,
                                      color: blackPrimary,
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  //   CardNumberFormatter()
                                  // ],
                                  readOnly: true,
                                  controller: email,
                                  keyboardType: TextInputType.name,
                                  // controller: cardNumber,
                                  // maxLength: 19,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    suffixIcon: Visibility(
                                      visible:
                                          localData.IsGoogle ? false : true,
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            progressCount = 0;
                                          });
                                          await Navigator.pushNamed(
                                              context, '/verifEmailNow');
                                          _getProfile = getProfile();
                                        },
                                        child: Image.asset(
                                          widget.darkMode
                                              ? 'assets/icon/editdark.png'
                                              : 'assets/icon/editlight.png',
                                          scale: 3.5,
                                        ),
                                      ),
                                    ),
                                    filled: true,
                                    hintText: AppLocalizations.of(context)!
                                        .insertEmail,
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
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                profile.data.result.isVerifiedEmail
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 10,
                                            color: greenPrimary,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .emailHasVerified,
                                              style: reguler.copyWith(
                                                fontSize: 9,
                                                color: greenPrimary,
                                              )),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Icon(
                                            Icons.cancel_rounded,
                                            size: 10,
                                            color: redPrimary,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .emailHasNotVerified,
                                              style: reguler.copyWith(
                                                fontSize: 9,
                                                color: redPrimary,
                                              )),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!
                                            .countryCode,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: blackPrimary,
                                        )),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    TextFormField(
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter.digitsOnly,
                                      //   CVVNumberFormater()
                                      // ],
                                      // maxLength: 5,
                                      // controller: expdate,
                                      style: reguler.copyWith(
                                        fontSize: 13,
                                        color: blackPrimary,
                                      ),
                                      readOnly: true,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        fillColor: widget.darkMode
                                            ? whiteCardColor
                                            : null,
                                        // icon: Image.asset(
                                        //   'assets/indonesiaflag.png',
                                        //   width: 25,
                                        // ),
                                        prefixIcon: Image.asset(
                                          'assets/indonesiaflag.png',
                                        ),
                                        filled: true,
                                        hintText: '+62',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!
                                            .phoneNumber,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: blackPrimary,
                                        )),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    TextFormField(
                                      readOnly: true,
                                      // maxLength: 3,
                                      controller: phoneNumber,
                                      keyboardType: TextInputType.number,
                                      // controller: cvvcvnNumber,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      style: reguler.copyWith(
                                        fontSize: 13,
                                        color: blackPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        fillColor: widget.darkMode
                                            ? whiteCardColor
                                            : null,
                                        suffixIcon: Visibility(
                                            visible: true,
                                            child: InkWell(
                                              onTap: () async {
                                                // phoneNumber.clear();
                                                setState(() {
                                                  progressCount = 0;
                                                });
                                                await Navigator.pushNamed(
                                                    context,
                                                    '/verifyPhoneNumber');
                                                _getProfile = getProfile();
                                              },
                                              child: Image.asset(
                                                widget.darkMode
                                                    ? 'assets/icon/editdark.png'
                                                    : 'assets/icon/editlight.png',
                                                scale: 3.5,
                                                // width: 8,
                                                // height: 8,
                                              ),
                                            )),
                                        filled: true,
                                        hintText: AppLocalizations.of(context)!
                                            .insertYourPhoneNumber,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                          color: blackSecondary3,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10),
                          child: Column(
                            children: [
                              profile.data.result.isVerifiedPhone
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 10,
                                          color: greenPrimary,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .phoneNumberHasVerified,
                                            style: reguler.copyWith(
                                              fontSize: 9,
                                              color: greenPrimary,
                                            )),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Icon(
                                          Icons.cancel_rounded,
                                          size: 10,
                                          color: redPrimary,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .phoneNumberHasNotVerified,
                                            style: reguler.copyWith(
                                              fontSize: 9,
                                              color: redPrimary,
                                            )),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .howToCallYou,
                                      // 1 = telepon, 2 = whatsapp, 3 = email, 4 = tidak mau dihubungi
                                      style: bold.copyWith(
                                        fontSize: 14,
                                        color: blackPrimary,
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      backgroundColor: whiteCardColor,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12)),
                                      ),
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return SingleChildScrollView(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 15),
                                                child: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          callPreference = 1;
                                                          Navigator.pop(
                                                              context);
                                                        }); // await prefs.setBool(
                                                        //     'darkmode', false);
                                                        // Restart.restartApp();
                                                      },
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(18.0),
                                                          child: Text(
                                                            'Phone',
                                                            style: reguler.copyWith(
                                                                color:
                                                                    blackPrimary),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                        setState(() {
                                                          callPreference = 2;
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                        // await prefs.setBool(
                                                        //     'darkmode', false);
                                                        // Restart.restartApp();
                                                      },
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(18.0),
                                                          child: Text(
                                                            'WhatsApp',
                                                            style: reguler.copyWith(
                                                                color:
                                                                    blackPrimary),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                        setState(() {
                                                          callPreference = 3;
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                        // await prefs.setBool(
                                                        //     'darkmode', false);
                                                        // Restart.restartApp();
                                                      },
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(18.0),
                                                          child: Text(
                                                            'Email',
                                                            style: reguler.copyWith(
                                                                color:
                                                                    blackPrimary),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        color: whiteCardColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 15),
                                              child: callPreference != 0
                                                  ? Text(
                                                      callPreference == 1
                                                          ? 'Phone'
                                                          : callPreference == 2
                                                              ? 'WhatsApp'
                                                              : callPreference ==
                                                                      3
                                                                  ? 'Email'
                                                                  : '',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: callPreference ==
                                                                  0
                                                              ? redPrimary
                                                              : widget.darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackPrimary),
                                                    )
                                                  : Text(
                                                      profile.data.result
                                                                  .preferensi ==
                                                              ''
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .howToCallYouEmpty
                                                          : profile.data.result
                                                              .preferensi,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: profile
                                                                      .data
                                                                      .result
                                                                      .preferensi ==
                                                                  ''
                                                              ? redPrimary
                                                              : widget.darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackPrimary),
                                                    )

                                              // Column(
                                              //   children: [
                                              //     Visibility(
                                              //       visible: callPreference != 0
                                              //           ? true
                                              //           : false,
                                              //       child: Text(
                                              //         callPreference == 1
                                              //             ? 'Telepon'
                                              //             : callPreference == 2
                                              //                 ? 'WhatsApp'
                                              //                 : callPreference ==
                                              //                         3
                                              //                     ? 'Email'
                                              //                     : '',
                                              //         textAlign: TextAlign.start,
                                              //         style: reguler.copyWith(
                                              //             fontSize: 12,
                                              //             color: callPreference ==
                                              //                     0
                                              //                 ? redPrimary
                                              //                 : widget.darkMode
                                              //                     ? whiteColorDarkMode
                                              //                     : blackPrimary),
                                              //       ),
                                              //     ),
                                              //     Visibility(
                                              //       visible: callPreference == 0
                                              //           ? true
                                              //           : false,
                                              //       child: Text(
                                              //         profile.data.result
                                              //                     .preferensi ==
                                              //                 ''
                                              //             ? 'Anda belum memilih melalui platform apa agar kami dapat menghubungi Anda'
                                              //             : profile.data.result
                                              //                 .preferensi,
                                              //         textAlign: TextAlign.start,
                                              //         style: reguler.copyWith(
                                              //             fontSize: 12,
                                              //             color: profile
                                              //                         .data
                                              //                         .result
                                              //                         .preferensi ==
                                              //                     ''
                                              //                 ? redPrimary
                                              //                 : widget.darkMode
                                              //                     ? whiteColorDarkMode
                                              //                     : blackPrimary),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
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
                                ),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    AppLocalizations.of(context)!
                                        .accountOwnerData,
                                    style: bold.copyWith(
                                      fontSize: 16,
                                      color: blueGradient,
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(AppLocalizations.of(context)!.fullName,
                                    style: bold.copyWith(
                                      fontSize: 14,
                                      color: blackPrimary,
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  //   CardNumberFormatter()
                                  // ],
                                  controller: fullName,
                                  keyboardType: TextInputType.name,
                                  // controller: cardNumber,
                                  // maxLength: 19,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    suffixIcon: Visibility(
                                        visible: fullName.text.isEmpty
                                            ? false
                                            : true,
                                        child: InkWell(
                                          onTap: () {
                                            fullName.clear();
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: blackPrimary,
                                            size: 15,
                                          ),
                                        )),
                                    filled: true,
                                    hintText: AppLocalizations.of(context)!
                                        .insertFullName,
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
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.username,
                                    style: bold.copyWith(
                                      fontSize: 14,
                                      color: blackPrimary,
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  controller: userName,
                                  keyboardType: TextInputType.name,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackSecondary3,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    filled: true,
                                    hintText: AppLocalizations.of(context)!
                                        .insertUsername,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: greyColor,
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
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              profile.data.result.custType == 1 ? false : true,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 40),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.companyInfo,
                                      style: bold.copyWith(
                                        fontSize: 16,
                                        color: blueGradient,
                                      )),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!.companyName,
                                      style: bold.copyWith(
                                        fontSize: 14,
                                        color: blackPrimary,
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.digitsOnly,
                                    //   CardNumberFormatter()
                                    // ],
                                    controller: companyName,
                                    keyboardType: TextInputType.name,
                                    // controller: cardNumber,
                                    // maxLength: 19,
                                    style: reguler.copyWith(
                                      fontSize: 13,
                                      color: blackPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      fillColor: widget.darkMode
                                          ? whiteCardColor
                                          : null,
                                      suffixIcon: Visibility(
                                          visible: companyName.text.isEmpty
                                              ? false
                                              : true,
                                          child: InkWell(
                                            onTap: () {
                                              companyName.clear();
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              color: blackPrimary,
                                              size: 15,
                                            ),
                                          )),
                                      filled: true,
                                      hintText: AppLocalizations.of(context)!
                                          .insertCompanyName,
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
                                        color: blackSecondary3,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.address,
                                    style: bold.copyWith(
                                      fontSize: 14,
                                      color: blackPrimary,
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  //   CardNumberFormatter()
                                  // ],
                                  controller: address,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  // keyboardType: TextInputType.name,
                                  // controller: cardNumber,
                                  // maxLength: 19,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    suffixIcon: Visibility(
                                        visible:
                                            address.text.isEmpty ? false : true,
                                        child: InkWell(
                                          onTap: () {
                                            address.clear();
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: blackPrimary,
                                            size: 15,
                                          ),
                                        )),
                                    filled: true,
                                    hintText: AppLocalizations.of(context)!
                                        .insertCompanyAddress,
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
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 30, bottom: 30),
                          child: SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () async {
                                final TextEditingController email =
                                    TextEditingController();
                                bool emailCorrect = false;
                                showModalBottomSheet(
                                    backgroundColor: widget.darkMode
                                        ? whiteCardColor
                                        : whiteColor,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                    ),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setStateModal) {
                                        return SingleChildScrollView(
                                          child: Container(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 30,
                                                          color: blackPrimary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 20),
                                                        child: Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color: bluePrimary,
                                                          size: 50,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .doYouWantToDeleteAccount,
                                                          style: bold.copyWith(
                                                            fontSize: 16,
                                                            color: blackPrimary,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .insertEmail,
                                                          style: reguler.copyWith(
                                                              fontSize: 14,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 20),
                                                        child: SizedBox(
                                                          width: width,
                                                          height: 40,
                                                          child: TextFormField(
                                                            onChanged: (value) {
                                                              if (value ==
                                                                  localData
                                                                      .Email) {
                                                                setStateModal(
                                                                    () {
                                                                  emailCorrect =
                                                                      true;
                                                                });
                                                              } else {
                                                                setStateModal(
                                                                    () {
                                                                  emailCorrect =
                                                                      false;
                                                                });
                                                              }
                                                            },
                                                            controller: email,
                                                            keyboardType:
                                                                TextInputType
                                                                    .emailAddress,
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 13,
                                                              color:
                                                                  blackPrimary,
                                                            ),
                                                            decoration:
                                                                InputDecoration(
                                                              fillColor: widget
                                                                      .darkMode
                                                                  ? whiteCardColor
                                                                  : null,
                                                              filled: true,
                                                              hintText: AppLocalizations
                                                                      .of(context)!
                                                                  .insertEmail,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              enabledBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                              ),
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 3,
                                                                  color: emailCorrect
                                                                      ? greenPrimary
                                                                      : redPrimary,
                                                                ),
                                                              ),
                                                              hintStyle: reguler
                                                                  .copyWith(
                                                                fontSize: 12,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary3,
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (email
                                                              .text.isEmpty) {
                                                            showInfoAlert(
                                                                context,
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .emptyEmail,
                                                                '');
                                                          } else {
                                                            if (!emailCorrect) {
                                                              showInfoAlert(
                                                                  context,
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .wrongEmail,
                                                                  '');
                                                            } else {
                                                              Dialogs()
                                                                  .loadingDialog(
                                                                      context);
                                                              final result =
                                                                  await APIService()
                                                                      .deleteAccount(
                                                                          localData
                                                                              .ID);
                                                              if (result
                                                                  is ErrorTrapModel) {
                                                                Dialogs()
                                                                    .hideLoaderDialog(
                                                                        context);
                                                                showInfoAlert(
                                                                    context,
                                                                    result
                                                                        .bodyError,
                                                                    '');
                                                              } else {
                                                                if (result
                                                                    is DeleteAccountModel) {
                                                                  if (result
                                                                      .status) {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                    // showInfoAlert(
                                                                    //     context,
                                                                    //     result
                                                                    //         .message,
                                                                    //     '');
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              DeleteAccount(
                                                                            darkMode:
                                                                                widget.darkMode,
                                                                            email:
                                                                                email.text,
                                                                            token:
                                                                                result.token,
                                                                          ),
                                                                        ));
                                                                  } else {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                    showInfoAlert(
                                                                        context,
                                                                        result
                                                                            .message,
                                                                        '');
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        },
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 80),
                                                            child: Container(
                                                              width: width,
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      redPrimary,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              redPrimary)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .deleteAccount,
                                                                  style: reguler
                                                                      .copyWith(
                                                                          color:
                                                                              whiteColorDarkMode,
                                                                          fontSize:
                                                                              14),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    });

                                //CHECK ACCOUNT

                                // Dialogs().loadingDialog(context);
                                // final result = await APIService()
                                //     .checkAccount(localData.ID);
                                // if (result is ErrorTrapModel) {
                                //   Dialogs().hideLoaderDialog(context);
                                //   showInfoAlert(
                                //       context, result.statusError, '');
                                // } else {
                                //   if (result is MessageModel) {
                                //     Dialogs().hideLoaderDialog(context);
                                //     showInfoAlert(context, result.message, '');
                                //   }
                                // }

                                // Dialogs().loadingDialog(context);
                                // final result = await APIService()
                                //     .deleteAccount(localData.ID);
                                // if (result is ErrorTrapModel) {
                                //   Dialogs().hideLoaderDialog(context);
                                //   showInfoAlert(context, result.bodyError, '');
                                // } else {
                                //   if (result is MessageModel) {
                                //     Dialogs().hideLoaderDialog(context);
                                //     showInfoAlert(context, result.message, '');
                                //   }
                                // }
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.deleteAccount,
                                  style: reguler.copyWith(
                                    fontSize: 16,
                                    color: redPrimary,
                                  ),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              return SingleChildScrollView(
                physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 80, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: double.infinity),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                    width: double.infinity, height: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonTheme(
                                  themeMode: widget.darkMode
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                  child: SkeletonAvatar(
                                    style: SkeletonAvatarStyle(
                                        width: 95, height: 20),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SkeletonTheme(
                                  themeMode: widget.darkMode
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                  child: SkeletonAvatar(
                                    style: SkeletonAvatarStyle(
                                        width: 120, height: 45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonTheme(
                                  themeMode: widget.darkMode
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                  child: SkeletonAvatar(
                                    style: SkeletonAvatarStyle(
                                        width: 95, height: 20),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SkeletonTheme(
                                  themeMode: widget.darkMode
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                  child: SkeletonAvatar(
                                    style: SkeletonAvatarStyle(
                                        width: double.infinity, height: 45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: SkeletonTheme(
                        themeMode:
                            widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                        child: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                              width: double.infinity, height: 15),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 165, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 70, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                    width: double.infinity, height: 45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 165, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 70, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                    width: double.infinity, height: 45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 115, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 115, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                    width: double.infinity, height: 45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style:
                                    SkeletonAvatarStyle(width: 60, height: 20),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            SkeletonTheme(
                              themeMode: widget.darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                              child: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                    width: double.infinity, height: 95),
                              ),
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
      bottomNavigationBar: Visibility(
          visible: _isError ? false : true,
          child: Container(
              color: whiteCardColor,
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
                    // const SizedBox(
                    //   height: 5,
                    // ),
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
                              callPreference == 0 &&
                                      profile.data.result.preferensi.isEmpty
                                  ? showInfoAlert(
                                      context,
                                      AppLocalizations.of(context)!
                                          .howToCallYouEmpty,
                                      '')
                                  : doEditProfile();
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
              ))),
    );
  }
}
