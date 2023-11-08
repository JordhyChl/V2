// ignore_for_file: unnecessary_string_interpolations, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_import, avoid_print, unrelated_type_equality_checks, unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/bodygooglelogin.model.dart';
import 'package:gpsid/model/bodylogin.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/login.model.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/widgets/notification.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
// import 'dart:html';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class _AuthPageState extends State<AuthPage> {
  late String _loadingStatus;
  String _takeAWhile = '';
  bool goToLogin = false;
  FirebaseBackground firebase = FirebaseBackground();
  int route = 0;
  bool dm = false;
  // late Future<dynamic> _getReadAlarm;
  // int _firebaseResult = 0;
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadingStatus = '';
    // Future.delayed(const Duration(seconds: 1), () {
    //   checkTheme();
    //   // _getReadAlarm = getReadAlarm();
    // });
    checkTheme();
    Future.delayed(const Duration(seconds: 1), () {
      authProcess();
      // _getReadAlarm = getReadAlarm();
    });
    // setupInteractedMessage();
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
        showInfoAlert(context, 'Error - ${e.message}', '');
        Navigator.of(context).pushReplacementNamed("/login");
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
    String fcm = '';
    fcm = await GeneralService().getFCMToken();
    final data = await GeneralService().readLocalUserStorage();
    if (authenticated) {
      if (fcm != '') {
        if (data is LocalData) {
          if (data.IsGoogle) {
            _googleSignIn.signInSilently();
            print(_googleSignIn);
            if (_googleSignIn.currentUser == null) {
              await _googleSignIn.signIn();
              final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
                  email: data.Email,
                  googleid: _googleSignIn.currentUser!.id,
                  fcmToken: fcm);
              final result = await APIService().doLoginGoogle(bodyLoginGoogle);
              if (result is LoginModel) {
                setState(() {
                  _loadingStatus =
                      AppLocalizations.of(context)!.gettingAccountData;
                  _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                });
                LocalData localData = LocalData(
                    ID: result.data.ID,
                    Username: result.data.Username,
                    Password: data.Password,
                    Fullname: result.data.Fullname,
                    Phone: result.data.Phone,
                    Email: result.data.Email,
                    Addres: result.data.Addres,
                    CompanyName: result.data.CompanyName,
                    BranchId: result.data.BranchId,
                    Privilage: result.data.Privilage,
                    Token: result.data.Token,
                    SeenId: result.data.SeenId,
                    IsGenerated: result.data.isGenerated,
                    IsGoogle: result.data.IsGoogle,
                    IsApple: result.data.IsApple,
                    createdAt: result.data.createdAt);
                await GeneralService().deleteLocalUserStorage();
                await GeneralService().writeLocalUserStorage(localData);
                final resultURL = await APIService().getURL();
                if (resultURL is LinkModel) {
                  await GeneralService().writeLocalURL(resultURL);
                } else {
                  await GeneralService().writeLocalURL(resultURL);
                }
                return Timer.run(() async {
                  setState(() {
                    _loadingStatus =
                        AppLocalizations.of(context)!.redirectToHome;
                    _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                  });
                  late bool darkMode;
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final bool? darkmode = prefs.getBool('darkmode');
                  darkMode = darkmode!;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          selected: route,
                          darkMode: darkMode,
                          secondAccess: false,
                        ),
                      ));
                });
              } else {
                if (result is ErrorTrapModel) {
                  goToLogin = true;
                  await firebase.deleteToken();
                  await GeneralService().deleteLocalUserStorage();
                  await GeneralService().deleteAlarmStorage();
                  await GeneralService().deleteLocalAsset();
                  await GeneralService().deleteLocalURL();
                  await GeneralService().deleteRememberMe();
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _loadingStatus =
                          AppLocalizations.of(context)!.redirectToLogin;
                      _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                    });
                    Navigator.of(context).pushReplacementNamed("/login");
                  });
                } else {
                  goToLogin = true;
                  await GeneralService().deleteLocalUserStorage();
                  await firebase.deleteToken();
                  await GeneralService().deleteAlarmStorage();
                  await GeneralService().deleteLocalAsset();
                  await GeneralService().deleteLocalURL();
                  await GeneralService().deleteRememberMe();
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _loadingStatus =
                          AppLocalizations.of(context)!.redirectToLogin;
                      _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                    });
                    Navigator.of(context).pushReplacementNamed("/login");
                  });
                }
              }
            } else {
              final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
                  email: data.Email,
                  googleid: _googleSignIn.currentUser!.id,
                  fcmToken: fcm);
              final result = await APIService().doLoginGoogle(bodyLoginGoogle);
              if (result is LoginModel) {
                setState(() {
                  _loadingStatus =
                      AppLocalizations.of(context)!.gettingAccountData;
                  _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                });
                LocalData localData = LocalData(
                    ID: result.data.ID,
                    Username: result.data.Username,
                    Password: data.Password,
                    Fullname: result.data.Fullname,
                    Phone: result.data.Phone,
                    Email: result.data.Email,
                    Addres: result.data.Addres,
                    CompanyName: result.data.CompanyName,
                    BranchId: result.data.BranchId,
                    Privilage: result.data.Privilage,
                    Token: result.data.Token,
                    SeenId: result.data.SeenId,
                    IsGenerated: result.data.isGenerated,
                    IsGoogle: result.data.IsGoogle,
                    IsApple: result.data.IsApple,
                    createdAt: result.data.createdAt);
                await GeneralService().deleteLocalUserStorage();
                await GeneralService().writeLocalUserStorage(localData);
                final resultURL = await APIService().getURL();
                if (resultURL is LinkModel) {
                  await GeneralService().writeLocalURL(resultURL);
                } else {
                  await GeneralService().writeLocalURL(resultURL);
                }
                return Timer.run(() async {
                  setState(() {
                    _loadingStatus =
                        AppLocalizations.of(context)!.redirectToHome;
                    _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                  });
                  late bool darkMode;
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final bool? darkmode = prefs.getBool('darkmode');
                  darkMode = darkmode!;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          selected: route,
                          darkMode: darkMode,
                          secondAccess: false,
                        ),
                      ));
                });
              } else {
                if (result is ErrorTrapModel) {
                  goToLogin = true;
                  await firebase.deleteToken();
                  await GeneralService().deleteLocalUserStorage();
                  await GeneralService().deleteAlarmStorage();
                  await GeneralService().deleteLocalAsset();
                  await GeneralService().deleteLocalURL();
                  await GeneralService().deleteRememberMe();
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _loadingStatus =
                          AppLocalizations.of(context)!.redirectToLogin;
                      _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                    });
                    Navigator.of(context).pushReplacementNamed("/login");
                  });
                } else {
                  goToLogin = true;
                  await GeneralService().deleteLocalUserStorage();
                  await firebase.deleteToken();
                  await GeneralService().deleteAlarmStorage();
                  await GeneralService().deleteLocalAsset();
                  await GeneralService().deleteLocalURL();
                  await GeneralService().deleteRememberMe();
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _loadingStatus =
                          AppLocalizations.of(context)!.redirectToLogin;
                      _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                    });
                    Navigator.of(context).pushReplacementNamed("/login");
                  });
                }
              }
            }
          } else if (data.IsApple) {
            final result = await APIService().doLoginApple(data.Password, fcm);
            if (result is LoginModel) {
              setState(() {
                _loadingStatus =
                    AppLocalizations.of(context)!.gettingAccountData;
                _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
              });
              LocalData localData = LocalData(
                  ID: result.data.ID,
                  Username: result.data.Username,
                  Password: data.Password,
                  Fullname: result.data.Fullname,
                  Phone: result.data.Phone,
                  Email: result.data.Email,
                  Addres: result.data.Addres,
                  CompanyName: result.data.CompanyName,
                  BranchId: result.data.BranchId,
                  Privilage: result.data.Privilage,
                  Token: result.data.Token,
                  SeenId: result.data.SeenId,
                  IsGenerated: result.data.isGenerated,
                  IsGoogle: result.data.IsGoogle,
                  IsApple: result.data.IsApple,
                  createdAt: result.data.createdAt);
              await GeneralService().deleteLocalUserStorage();
              await GeneralService().writeLocalUserStorage(localData);
              final resultURL = await APIService().getURL();
              if (resultURL is LinkModel) {
                await GeneralService().writeLocalURL(resultURL);
              } else {
                await GeneralService().writeLocalURL(resultURL);
              }
              return Timer.run(() async {
                setState(() {
                  _loadingStatus = AppLocalizations.of(context)!.redirectToHome;
                  _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                });
                late bool darkMode;
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final bool? darkmode = prefs.getBool('darkmode');
                darkMode = darkmode!;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        selected: route,
                        darkMode: darkMode,
                        secondAccess: false,
                      ),
                    ));
              });
            } else {
              if (result is ErrorTrapModel) {
                goToLogin = true;
                await firebase.deleteToken();
                await GeneralService().deleteLocalUserStorage();
                await GeneralService().deleteAlarmStorage();
                await GeneralService().deleteLocalAsset();
                await GeneralService().deleteLocalURL();
                await GeneralService().deleteRememberMe();
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _loadingStatus =
                        AppLocalizations.of(context)!.redirectToLogin;
                    _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                  });
                  Navigator.of(context).pushReplacementNamed("/login");
                });
              } else {
                goToLogin = true;
                await GeneralService().deleteLocalUserStorage();
                await firebase.deleteToken();
                await GeneralService().deleteAlarmStorage();
                await GeneralService().deleteLocalAsset();
                await GeneralService().deleteLocalURL();
                await GeneralService().deleteRememberMe();
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _loadingStatus =
                        AppLocalizations.of(context)!.redirectToLogin;
                    _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                  });
                  Navigator.of(context).pushReplacementNamed("/login");
                });
              }
            }
          } else {
            final BodyLogin bodyLogin = BodyLogin(
                username: data.Username,
                password: data.Password,
                fcmToken: fcm);
            final result = await APIService().doLogin(bodyLogin);
            if (result is LoginModel) {
              setState(() {
                _loadingStatus =
                    AppLocalizations.of(context)!.gettingAccountData;
                _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
              });
              LocalData localData = LocalData(
                  ID: result.data.ID,
                  Username: result.data.Username,
                  Password: data.Password,
                  Fullname: result.data.Fullname,
                  Phone: result.data.Phone,
                  Email: result.data.Email,
                  Addres: result.data.Addres,
                  CompanyName: result.data.CompanyName,
                  BranchId: result.data.BranchId,
                  Privilage: result.data.Privilage,
                  Token: result.data.Token,
                  SeenId: result.data.SeenId,
                  IsGenerated: result.data.isGenerated,
                  IsGoogle: result.data.IsGoogle,
                  IsApple: result.data.IsApple,
                  createdAt: result.data.createdAt);
              await GeneralService().deleteLocalUserStorage();
              await GeneralService().writeLocalUserStorage(localData);
              final resultURL = await APIService().getURL();
              if (resultURL is LinkModel) {
                await GeneralService().writeLocalURL(resultURL);
              } else {
                await GeneralService().writeLocalURL(resultURL);
              }
              return Timer.run(() async {
                setState(() {
                  _loadingStatus = AppLocalizations.of(context)!.redirectToHome;
                  _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                });
                late bool darkMode;
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final bool? darkmode = prefs.getBool('darkmode');
                darkMode = darkmode!;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        selected: route,
                        darkMode: darkMode,
                        secondAccess: false,
                      ),
                    ));
              });
            } else {
              if (result is ErrorTrapModel) {
                goToLogin = true;
                await firebase.deleteToken();
                await GeneralService().deleteLocalUserStorage();
                await GeneralService().deleteAlarmStorage();
                await GeneralService().deleteLocalAsset();
                await GeneralService().deleteLocalURL();
                await GeneralService().deleteRememberMe();
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _loadingStatus =
                        AppLocalizations.of(context)!.redirectToLogin;
                    _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                  });
                  Navigator.of(context).pushReplacementNamed("/login");
                });
              } else {
                goToLogin = true;
                await firebase.deleteToken();
                await GeneralService().deleteLocalUserStorage();
                await GeneralService().deleteAlarmStorage();
                await GeneralService().deleteLocalAsset();
                await GeneralService().deleteLocalURL();
                await GeneralService().deleteRememberMe();
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _loadingStatus =
                        AppLocalizations.of(context)!.redirectToLogin;
                    _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                  });
                  Navigator.of(context).pushReplacementNamed("/login");
                });
              }
            }
          }
        }
      }
    } else {
      if (data is LocalData) {}
      Navigator.of(context).pushReplacementNamed("/login");
    }
  }

  checkTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool darkmode = prefs.getBool('darkmode') ?? false;
    dm = darkmode;
  }

  authProcess() async {
    String fcm = '';
    fcm = await GeneralService().getFCMToken();
    // final fcm = '';

    if (fcm != '') {
      setState(() {
        _loadingStatus = AppLocalizations.of(context)!.gettingLocalData;
        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
      });
      final data = await GeneralService().readLocalUserStorage();
      print(data);
      if (data is LocalData) {
        if (data.Username.toLowerCase() == 'demo') {
          goToLogin = true;
          await firebase.deleteToken();
          await GeneralService().deleteLocalUserStorage();
          await GeneralService().deleteAlarmStorage();
          await GeneralService().deleteLocalAsset();
          await GeneralService().deleteLocalURL();
          await GeneralService().deleteRememberMe();
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _loadingStatus = AppLocalizations.of(context)!.redirectToLogin;
              _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
            });
            Navigator.of(context).pushReplacementNamed("/login");
          });
        } else {
          auth.isDeviceSupported().then(
            (bool isSupported) async {
              setState(() {
                _supportState = isSupported
                    ? _SupportState.supported
                    : _SupportState.unsupported;
              });
              if (isSupported) {
                late bool bml;
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final bool? get = prefs.getBool('biometricLogin');
                bml = get!;
                if (bml) {
                  _authenticateWithBiometrics();
                } else {
                  if (data.IsGoogle) {
                    _googleSignIn.signInSilently();
                    print(_googleSignIn);
                    if (_googleSignIn.currentUser == null) {
                      await _googleSignIn.signIn();
                      final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
                          email: data.Email,
                          googleid: _googleSignIn.currentUser!.id,
                          fcmToken: fcm);
                      final result =
                          await APIService().doLoginGoogle(bodyLoginGoogle);
                      if (result is LoginModel) {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.gettingAccountData;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        LocalData localData = LocalData(
                            ID: result.data.ID,
                            Username: result.data.Username,
                            Password: data.Password,
                            Fullname: result.data.Fullname,
                            Phone: result.data.Phone,
                            Email: result.data.Email,
                            Addres: result.data.Addres,
                            CompanyName: result.data.CompanyName,
                            BranchId: result.data.BranchId,
                            Privilage: result.data.Privilage,
                            Token: result.data.Token,
                            SeenId: result.data.SeenId,
                            IsGenerated: result.data.isGenerated,
                            IsGoogle: result.data.IsGoogle,
                            IsApple: result.data.IsApple,
                            createdAt: result.data.createdAt);
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().writeLocalUserStorage(localData);
                        final resultURL = await APIService().getURL();
                        if (resultURL is LinkModel) {
                          await GeneralService().writeLocalURL(resultURL);
                        } else {
                          await GeneralService().writeLocalURL(resultURL);
                        }
                        return Timer.run(() async {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToHome;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          late bool darkMode;
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final bool? darkmode = prefs.getBool('darkmode');
                          darkMode = darkmode!;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  selected: route,
                                  darkMode: darkMode,
                                  secondAccess: false,
                                ),
                              ));
                        });
                      } else {
                        if (result is ErrorTrapModel) {
                          goToLogin = true;
                          await firebase.deleteToken();
                          await GeneralService().deleteLocalUserStorage();
                          await GeneralService().deleteAlarmStorage();
                          await GeneralService().deleteLocalAsset();
                          await GeneralService().deleteLocalURL();
                          await GeneralService().deleteRememberMe();
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              _loadingStatus =
                                  AppLocalizations.of(context)!.redirectToLogin;
                              _takeAWhile =
                                  AppLocalizations.of(context)!.takeAWhile;
                            });
                            Navigator.of(context)
                                .pushReplacementNamed("/login");
                          });
                        } else {
                          goToLogin = true;
                          await GeneralService().deleteLocalUserStorage();
                          await firebase.deleteToken();
                          await GeneralService().deleteAlarmStorage();
                          await GeneralService().deleteLocalAsset();
                          await GeneralService().deleteLocalURL();
                          await GeneralService().deleteRememberMe();
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              _loadingStatus =
                                  AppLocalizations.of(context)!.redirectToLogin;
                              _takeAWhile =
                                  AppLocalizations.of(context)!.takeAWhile;
                            });
                            Navigator.of(context)
                                .pushReplacementNamed("/login");
                          });
                        }
                      }
                    } else {
                      final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
                          email: data.Email,
                          googleid: _googleSignIn.currentUser!.id,
                          fcmToken: fcm);
                      final result =
                          await APIService().doLoginGoogle(bodyLoginGoogle);
                      if (result is LoginModel) {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.gettingAccountData;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        LocalData localData = LocalData(
                            ID: result.data.ID,
                            Username: result.data.Username,
                            Password: data.Password,
                            Fullname: result.data.Fullname,
                            Phone: result.data.Phone,
                            Email: result.data.Email,
                            Addres: result.data.Addres,
                            CompanyName: result.data.CompanyName,
                            BranchId: result.data.BranchId,
                            Privilage: result.data.Privilage,
                            Token: result.data.Token,
                            SeenId: result.data.SeenId,
                            IsGenerated: result.data.isGenerated,
                            IsGoogle: result.data.IsGoogle,
                            IsApple: result.data.IsApple,
                            createdAt: result.data.createdAt);
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().writeLocalUserStorage(localData);
                        final resultURL = await APIService().getURL();
                        if (resultURL is LinkModel) {
                          await GeneralService().writeLocalURL(resultURL);
                        } else {
                          await GeneralService().writeLocalURL(resultURL);
                        }
                        return Timer.run(() async {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToHome;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          late bool darkMode;
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final bool? darkmode = prefs.getBool('darkmode');
                          darkMode = darkmode!;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  selected: route,
                                  darkMode: darkMode,
                                  secondAccess: false,
                                ),
                              ));
                        });
                      } else {
                        if (result is ErrorTrapModel) {
                          goToLogin = true;
                          await firebase.deleteToken();
                          await GeneralService().deleteLocalUserStorage();
                          await GeneralService().deleteAlarmStorage();
                          await GeneralService().deleteLocalAsset();
                          await GeneralService().deleteLocalURL();
                          await GeneralService().deleteRememberMe();
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              _loadingStatus =
                                  AppLocalizations.of(context)!.redirectToLogin;
                              _takeAWhile =
                                  AppLocalizations.of(context)!.takeAWhile;
                            });
                            Navigator.of(context)
                                .pushReplacementNamed("/login");
                          });
                        } else {
                          goToLogin = true;
                          await GeneralService().deleteLocalUserStorage();
                          await firebase.deleteToken();
                          await GeneralService().deleteAlarmStorage();
                          await GeneralService().deleteLocalAsset();
                          await GeneralService().deleteLocalURL();
                          await GeneralService().deleteRememberMe();
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              _loadingStatus =
                                  AppLocalizations.of(context)!.redirectToLogin;
                              _takeAWhile =
                                  AppLocalizations.of(context)!.takeAWhile;
                            });
                            Navigator.of(context)
                                .pushReplacementNamed("/login");
                          });
                        }
                      }
                    }
                  } else if (data.IsApple) {
                    final result =
                        await APIService().doLoginApple(data.Password, fcm);
                    if (result is LoginModel) {
                      setState(() {
                        _loadingStatus =
                            AppLocalizations.of(context)!.gettingAccountData;
                        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                      });
                      LocalData localData = LocalData(
                          ID: result.data.ID,
                          Username: result.data.Username,
                          Password: data.Password,
                          Fullname: result.data.Fullname,
                          Phone: result.data.Phone,
                          Email: result.data.Email,
                          Addres: result.data.Addres,
                          CompanyName: result.data.CompanyName,
                          BranchId: result.data.BranchId,
                          Privilage: result.data.Privilage,
                          Token: result.data.Token,
                          SeenId: result.data.SeenId,
                          IsGenerated: result.data.isGenerated,
                          IsGoogle: result.data.IsGoogle,
                          IsApple: result.data.IsApple,
                          createdAt: result.data.createdAt);
                      await GeneralService().deleteLocalUserStorage();
                      await GeneralService().writeLocalUserStorage(localData);
                      final resultURL = await APIService().getURL();
                      if (resultURL is LinkModel) {
                        await GeneralService().writeLocalURL(resultURL);
                      } else {
                        await GeneralService().writeLocalURL(resultURL);
                      }
                      return Timer.run(() async {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToHome;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        late bool darkMode;
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final bool? darkmode = prefs.getBool('darkmode');
                        darkMode = darkmode!;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                selected: route,
                                darkMode: darkMode,
                                secondAccess: false,
                              ),
                            ));
                      });
                    } else {
                      if (result is ErrorTrapModel) {
                        goToLogin = true;
                        await firebase.deleteToken();
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      } else {
                        goToLogin = true;
                        await GeneralService().deleteLocalUserStorage();
                        await firebase.deleteToken();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      }
                    }
                  } else {
                    final BodyLogin bodyLogin = BodyLogin(
                        username: data.Username,
                        password: data.Password,
                        fcmToken: fcm);
                    final result = await APIService().doLogin(bodyLogin);
                    if (result is LoginModel) {
                      setState(() {
                        _loadingStatus =
                            AppLocalizations.of(context)!.gettingAccountData;
                        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                      });
                      LocalData localData = LocalData(
                          ID: result.data.ID,
                          Username: result.data.Username,
                          Password: data.Password,
                          Fullname: result.data.Fullname,
                          Phone: result.data.Phone,
                          Email: result.data.Email,
                          Addres: result.data.Addres,
                          CompanyName: result.data.CompanyName,
                          BranchId: result.data.BranchId,
                          Privilage: result.data.Privilage,
                          Token: result.data.Token,
                          SeenId: result.data.SeenId,
                          IsGenerated: result.data.isGenerated,
                          IsGoogle: result.data.IsGoogle,
                          IsApple: result.data.IsApple,
                          createdAt: result.data.createdAt);
                      await GeneralService().deleteLocalUserStorage();
                      await GeneralService().writeLocalUserStorage(localData);
                      final resultURL = await APIService().getURL();
                      if (resultURL is LinkModel) {
                        await GeneralService().writeLocalURL(resultURL);
                      } else {
                        await GeneralService().writeLocalURL(resultURL);
                      }
                      return Timer.run(() async {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToHome;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        late bool darkMode;
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final bool? darkmode = prefs.getBool('darkmode');
                        darkMode = darkmode!;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                selected: route,
                                darkMode: darkMode,
                                secondAccess: false,
                              ),
                            ));
                      });
                    } else {
                      if (result is ErrorTrapModel) {
                        goToLogin = true;
                        await firebase.deleteToken();
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      } else {
                        goToLogin = true;
                        await GeneralService().deleteLocalUserStorage();
                        await firebase.deleteToken();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      }
                    }
                  }
                }
              } else {
                if (data.IsGoogle) {
                  _googleSignIn.signInSilently();
                  print(_googleSignIn);
                  if (_googleSignIn.currentUser == null) {
                    await _googleSignIn.signIn();
                    final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
                        email: data.Email,
                        googleid: _googleSignIn.currentUser!.id,
                        fcmToken: fcm);
                    final result =
                        await APIService().doLoginGoogle(bodyLoginGoogle);
                    if (result is LoginModel) {
                      setState(() {
                        _loadingStatus =
                            AppLocalizations.of(context)!.gettingAccountData;
                        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                      });
                      LocalData localData = LocalData(
                          ID: result.data.ID,
                          Username: result.data.Username,
                          Password: data.Password,
                          Fullname: result.data.Fullname,
                          Phone: result.data.Phone,
                          Email: result.data.Email,
                          Addres: result.data.Addres,
                          CompanyName: result.data.CompanyName,
                          BranchId: result.data.BranchId,
                          Privilage: result.data.Privilage,
                          Token: result.data.Token,
                          SeenId: result.data.SeenId,
                          IsGenerated: result.data.isGenerated,
                          IsGoogle: result.data.IsGoogle,
                          IsApple: result.data.IsApple,
                          createdAt: result.data.createdAt);
                      await GeneralService().deleteLocalUserStorage();
                      await GeneralService().writeLocalUserStorage(localData);
                      final resultURL = await APIService().getURL();
                      if (resultURL is LinkModel) {
                        await GeneralService().writeLocalURL(resultURL);
                      } else {
                        await GeneralService().writeLocalURL(resultURL);
                      }
                      return Timer.run(() async {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToHome;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        late bool darkMode;
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final bool? darkmode = prefs.getBool('darkmode');
                        darkMode = darkmode!;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                selected: route,
                                darkMode: darkMode,
                                secondAccess: false,
                              ),
                            ));
                      });
                    } else {
                      if (result is ErrorTrapModel) {
                        goToLogin = true;
                        await firebase.deleteToken();
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      } else {
                        goToLogin = true;
                        await GeneralService().deleteLocalUserStorage();
                        await firebase.deleteToken();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      }
                    }
                  } else {
                    final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
                        email: data.Email,
                        googleid: _googleSignIn.currentUser!.id,
                        fcmToken: fcm);
                    final result =
                        await APIService().doLoginGoogle(bodyLoginGoogle);
                    if (result is LoginModel) {
                      setState(() {
                        _loadingStatus =
                            AppLocalizations.of(context)!.gettingAccountData;
                        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                      });
                      LocalData localData = LocalData(
                          ID: result.data.ID,
                          Username: result.data.Username,
                          Password: data.Password,
                          Fullname: result.data.Fullname,
                          Phone: result.data.Phone,
                          Email: result.data.Email,
                          Addres: result.data.Addres,
                          CompanyName: result.data.CompanyName,
                          BranchId: result.data.BranchId,
                          Privilage: result.data.Privilage,
                          Token: result.data.Token,
                          SeenId: result.data.SeenId,
                          IsGenerated: result.data.isGenerated,
                          IsGoogle: result.data.IsGoogle,
                          IsApple: result.data.IsApple,
                          createdAt: result.data.createdAt);
                      await GeneralService().deleteLocalUserStorage();
                      await GeneralService().writeLocalUserStorage(localData);
                      final resultURL = await APIService().getURL();
                      if (resultURL is LinkModel) {
                        await GeneralService().writeLocalURL(resultURL);
                      } else {
                        await GeneralService().writeLocalURL(resultURL);
                      }
                      return Timer.run(() async {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToHome;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        late bool darkMode;
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final bool? darkmode = prefs.getBool('darkmode');
                        darkMode = darkmode!;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                selected: route,
                                darkMode: darkMode,
                                secondAccess: false,
                              ),
                            ));
                      });
                    } else {
                      if (result is ErrorTrapModel) {
                        goToLogin = true;
                        await firebase.deleteToken();
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      } else {
                        goToLogin = true;
                        await GeneralService().deleteLocalUserStorage();
                        await firebase.deleteToken();
                        await GeneralService().deleteAlarmStorage();
                        await GeneralService().deleteLocalAsset();
                        await GeneralService().deleteLocalURL();
                        await GeneralService().deleteRememberMe();
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _loadingStatus =
                                AppLocalizations.of(context)!.redirectToLogin;
                            _takeAWhile =
                                AppLocalizations.of(context)!.takeAWhile;
                          });
                          Navigator.of(context).pushReplacementNamed("/login");
                        });
                      }
                    }
                  }
                } else if (data.IsApple) {
                  final result =
                      await APIService().doLoginApple(data.Password, fcm);
                  if (result is LoginModel) {
                    setState(() {
                      _loadingStatus =
                          AppLocalizations.of(context)!.gettingAccountData;
                      _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                    });
                    LocalData localData = LocalData(
                        ID: result.data.ID,
                        Username: result.data.Username,
                        Password: data.Password,
                        Fullname: result.data.Fullname,
                        Phone: result.data.Phone,
                        Email: result.data.Email,
                        Addres: result.data.Addres,
                        CompanyName: result.data.CompanyName,
                        BranchId: result.data.BranchId,
                        Privilage: result.data.Privilage,
                        Token: result.data.Token,
                        SeenId: result.data.SeenId,
                        IsGenerated: result.data.isGenerated,
                        IsGoogle: result.data.IsGoogle,
                        IsApple: result.data.IsApple,
                        createdAt: result.data.createdAt);
                    await GeneralService().deleteLocalUserStorage();
                    await GeneralService().writeLocalUserStorage(localData);
                    final resultURL = await APIService().getURL();
                    if (resultURL is LinkModel) {
                      await GeneralService().writeLocalURL(resultURL);
                    } else {
                      await GeneralService().writeLocalURL(resultURL);
                    }
                    return Timer.run(() async {
                      setState(() {
                        _loadingStatus =
                            AppLocalizations.of(context)!.redirectToHome;
                        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                      });
                      late bool darkMode;
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final bool? darkmode = prefs.getBool('darkmode');
                      darkMode = darkmode!;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              selected: route,
                              darkMode: darkMode,
                              secondAccess: false,
                            ),
                          ));
                    });
                  } else {
                    if (result is ErrorTrapModel) {
                      goToLogin = true;
                      await firebase.deleteToken();
                      await GeneralService().deleteLocalUserStorage();
                      await GeneralService().deleteAlarmStorage();
                      await GeneralService().deleteLocalAsset();
                      await GeneralService().deleteLocalURL();
                      await GeneralService().deleteRememberMe();
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToLogin;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        Navigator.of(context).pushReplacementNamed("/login");
                      });
                    } else {
                      goToLogin = true;
                      await GeneralService().deleteLocalUserStorage();
                      await firebase.deleteToken();
                      await GeneralService().deleteAlarmStorage();
                      await GeneralService().deleteLocalAsset();
                      await GeneralService().deleteLocalURL();
                      await GeneralService().deleteRememberMe();
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToLogin;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        Navigator.of(context).pushReplacementNamed("/login");
                      });
                    }
                  }
                } else {
                  final BodyLogin bodyLogin = BodyLogin(
                      username: data.Username,
                      password: data.Password,
                      fcmToken: fcm);
                  final result = await APIService().doLogin(bodyLogin);
                  if (result is LoginModel) {
                    setState(() {
                      _loadingStatus =
                          AppLocalizations.of(context)!.gettingAccountData;
                      _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                    });
                    LocalData localData = LocalData(
                        ID: result.data.ID,
                        Username: result.data.Username,
                        Password: data.Password,
                        Fullname: result.data.Fullname,
                        Phone: result.data.Phone,
                        Email: result.data.Email,
                        Addres: result.data.Addres,
                        CompanyName: result.data.CompanyName,
                        BranchId: result.data.BranchId,
                        Privilage: result.data.Privilage,
                        Token: result.data.Token,
                        SeenId: result.data.SeenId,
                        IsGenerated: result.data.isGenerated,
                        IsGoogle: result.data.IsGoogle,
                        IsApple: result.data.IsApple,
                        createdAt: result.data.createdAt);
                    await GeneralService().deleteLocalUserStorage();
                    await GeneralService().writeLocalUserStorage(localData);
                    final resultURL = await APIService().getURL();
                    if (resultURL is LinkModel) {
                      await GeneralService().writeLocalURL(resultURL);
                    } else {
                      await GeneralService().writeLocalURL(resultURL);
                    }
                    return Timer.run(() async {
                      setState(() {
                        _loadingStatus =
                            AppLocalizations.of(context)!.redirectToHome;
                        _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
                      });
                      late bool darkMode;
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final bool? darkmode = prefs.getBool('darkmode');
                      darkMode = darkmode!;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              selected: route,
                              darkMode: darkMode,
                              secondAccess: false,
                            ),
                          ));
                    });
                  } else {
                    if (result is ErrorTrapModel) {
                      goToLogin = true;
                      await firebase.deleteToken();
                      await GeneralService().deleteLocalUserStorage();
                      await GeneralService().deleteAlarmStorage();
                      await GeneralService().deleteLocalAsset();
                      await GeneralService().deleteLocalURL();
                      await GeneralService().deleteRememberMe();
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToLogin;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        Navigator.of(context).pushReplacementNamed("/login");
                      });
                    } else {
                      goToLogin = true;
                      await GeneralService().deleteLocalUserStorage();
                      await firebase.deleteToken();
                      await GeneralService().deleteAlarmStorage();
                      await GeneralService().deleteLocalAsset();
                      await GeneralService().deleteLocalURL();
                      await GeneralService().deleteRememberMe();
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _loadingStatus =
                              AppLocalizations.of(context)!.redirectToLogin;
                          _takeAWhile =
                              AppLocalizations.of(context)!.takeAWhile;
                        });
                        Navigator.of(context).pushReplacementNamed("/login");
                      });
                    }
                  }
                }
              }
            },
          );
        }
      } else {
        setState(() {
          _loadingStatus = AppLocalizations.of(context)!.redirectToLogin;
          _takeAWhile = AppLocalizations.of(context)!.takeAWhile;
          goToLogin = true;
        });
        Navigator.of(context).pushReplacementNamed("/login");
      }
    } else {
      await firebase.deleteToken();
      await GeneralService().deleteLocalUserStorage();
      await GeneralService().deleteAlarmStorage();
      await GeneralService().deleteLocalAsset();
      await GeneralService().deleteLocalURL();
      await GeneralService().deleteRememberMe();
      Navigator.of(context).pushReplacementNamed("/login");
    }
    setState(() {
      route = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color(LinearGradient(colors: [blueGradientSecondary1, blueGradientSecondary2])),
        body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: dm ? whiteCardColor : bluePrimary),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logogpsid.png',
                    height: 60,
                  ),
                  Image.asset('assets/superspring.png', height: 52),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Image.asset(
            'assets/pojokkiriatas.png',
            // fit: BoxFit.contain,
            height: 180,
            // width: double.infinity,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Image.asset(
            'assets/pojokkananbawah.png',
            // fit: BoxFit.contain,
            height: 180,
            // width: double.infinity,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
              visible: goToLogin,
              child: Padding(
                padding: const EdgeInsets.all(45.0),
                child: InkWell(
                  onTap: () async {
                    await GeneralService().deleteLocalUserStorage();
                    Navigator.of(context).pushReplacementNamed("/login");
                  },
                  child: Container(
                    height: 27,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: [
                            blueGradientSecondary2,
                            blueGradientSecondary1
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )),
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.goToLogin,
                          style: bold.copyWith(
                            fontSize: 14,
                            color: whiteColor,
                          )),
                    ),
                  ),
                ),
              )),
        ),
      ],
    )

        // Provider.of<InternetConnectionStatus>(context) ==
        //         InternetConnectionStatus.disconnected
        //     ? Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Image.asset(
        //             'assets/handling/noConnection.png',
        //             height: 240,
        //             width: 240,
        //           ),
        //           Padding(
        //             padding:
        //                 const EdgeInsets.only(left: 50, right: 50, top: 10),
        //             child: Text(
        //               AppLocalizations.of(context)!.noConnection,
        //               textAlign: TextAlign.center,
        //               style: bold.copyWith(
        //                 fontSize: 14,
        //                 color: blackSecondary2,
        //               ),
        //             ),
        //           ),
        //           Padding(
        //             padding:
        //                 const EdgeInsets.only(left: 30, right: 30, top: 10),
        //             child: Text(
        //               AppLocalizations.of(context)!.noConnectionSub,
        //               textAlign: TextAlign.center,
        //               style: reguler.copyWith(
        //                 fontSize: 12,
        //                 color: blackSecondary2,
        //               ),
        //             ),
        //           ),
        //           Align(
        //             alignment: Alignment.bottomCenter,
        //             child: Visibility(
        //                 visible: true,
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(45.0),
        //                   child: InkWell(
        //                     onTap: () async {
        //                       authProcess();
        //                     },
        //                     child: Container(
        //                       height: 27,
        //                       width: 120,
        //                       decoration: BoxDecoration(
        //                           borderRadius: const BorderRadius.all(
        //                               Radius.circular(8)),
        //                           gradient: LinearGradient(
        //                             colors: [
        //                               blueGradientSecondary2,
        //                               blueGradientSecondary1
        //                             ],
        //                             begin: Alignment.topRight,
        //                             end: Alignment.bottomLeft,
        //                           )),
        //                       child: Center(
        //                         child:
        //                             Text(AppLocalizations.of(context)!.tryAgain,
        //                                 style: bold.copyWith(
        //                                   fontSize: 14,
        //                                   color: whiteColor,
        //                                 )),
        //                       ),
        //                     ),
        //                   ),
        //                 )),
        //           ),
        //         ],
        //       )
        //     : Stack(
        //         children: [
        //           Container(
        //             decoration:
        //                 BoxDecoration(color: dm ? whiteCardColor : bluePrimary),
        //           ),
        //           Center(
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Column(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   crossAxisAlignment: CrossAxisAlignment.center,
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [
        //                     Image.asset(
        //                       'assets/logogpsid.png',
        //                       height: 60,
        //                     ),
        //                     Image.asset('assets/superspring.png', height: 52),
        //                   ],
        //                 ),
        //               ],
        //             ),
        //           ),
        //           Align(
        //             alignment: Alignment.topLeft,
        //             child: Image.asset(
        //               'assets/pojokkiriatas.png',
        //               // fit: BoxFit.contain,
        //               height: 180,
        //               // width: double.infinity,
        //             ),
        //           ),
        //           Align(
        //             alignment: Alignment.bottomRight,
        //             child: Image.asset(
        //               'assets/pojokkananbawah.png',
        //               // fit: BoxFit.contain,
        //               height: 180,
        //               // width: double.infinity,
        //             ),
        //           ),
        //           Align(
        //             alignment: Alignment.bottomCenter,
        //             child: Visibility(
        //                 visible: goToLogin,
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(45.0),
        //                   child: InkWell(
        //                     onTap: () async {
        //                       await GeneralService().deleteLocalUserStorage();
        //                       Navigator.of(context)
        //                           .pushReplacementNamed("/login");
        //                     },
        //                     child: Container(
        //                       height: 27,
        //                       width: 120,
        //                       decoration: BoxDecoration(
        //                           borderRadius: const BorderRadius.all(
        //                               Radius.circular(8)),
        //                           gradient: LinearGradient(
        //                             colors: [
        //                               blueGradientSecondary2,
        //                               blueGradientSecondary1
        //                             ],
        //                             begin: Alignment.topRight,
        //                             end: Alignment.bottomLeft,
        //                           )),
        //                       child: Center(
        //                         child: Text(
        //                             AppLocalizations.of(context)!.goToLogin,
        //                             style: bold.copyWith(
        //                               fontSize: 14,
        //                               color: whiteColor,
        //                             )),
        //                       ),
        //                     ),
        //                   ),
        //                 )),
        //           ),
        //         ],
        //       )
        );
  }
}
