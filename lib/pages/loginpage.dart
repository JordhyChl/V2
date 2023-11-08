// LOGIN NEW
// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print, unused_import, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/assetmarker.model.dart';
import 'package:gpsid/model/bodygooglelogin.model.dart';
import 'package:gpsid/model/bodylogin.model.dart';
import 'package:gpsid/model/checkemail.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/login.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/registerwithapple.model.dart';
import 'package:gpsid/model/registerwithgoogle.model.dart';
import 'package:gpsid/model/rememberme.model.dart';
import 'package:gpsid/pages/addUnit.dart';
import 'package:gpsid/pages/geometry.model.dart';
import 'package:gpsid/pages/googlelogin.dart';
import 'package:gpsid/pages/recurringhistory.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final bool darkMode;
  const LoginPage({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController emailRegisterController = TextEditingController();
  final TextEditingController passwordRegisterController =
      TextEditingController();
  final TextEditingController passwordConfirmRegisterController =
      TextEditingController();
  bool _isHidden = true;
  bool hiddenPassRegister = true;
  bool hiddenConfirmPassRegister = true;
  bool wrongUsernamePassword = false;
  bool rememberMe = false;
  bool signin = true;
  bool sendEmailVerif = false;
  bool emailVerifSuccess = false;
  bool passMatch = false;
  String token = '';
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  String ownerName = '';

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    checkPermission();
    checkRememberMe();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      print(_currentUser);
    });
    // _googleSignIn.signInSilently();
  }

  Future<void> registerWithGoogle() async {
    // _currentUser != null ? _googleSignIn.signOut() : {};
    _googleSignIn.disconnect();
    try {
      await _googleSignIn.signIn();
      print(_googleSignIn);
      if (_googleSignIn.currentUser!.email.isNotEmpty) {
        Dialogs().loadingDialog(context);
        final result = await APIService().registerWithGoogle(
            _googleSignIn.currentUser!.email, _googleSignIn.currentUser!.id);
        if (result is RegisterWithGoogleModel) {
          if (result.status) {
            Dialogs().hideLoaderDialog(context);
            showInfoAlert(context, 'Success register with Google', '');
            setState(() {
              ownerName = _googleSignIn.currentUser!.displayName.toString();
              token = result.data;
              sendEmailVerif = true;
              emailVerifSuccess = true;
            });
          } else {
            Dialogs().hideLoaderDialog(context);
            showInfoAlert(context, result.message, '');
          }
        } else {
          if (result is MessageModel) {
            Dialogs().hideLoaderDialog(context);
            showInfoAlert(context, result.message, '');
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> registerWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    if (credential.email!.isNotEmpty) {
      Dialogs().loadingDialog(context);
      final result = await APIService().registerWithApple(
          credential.email.toString(), credential.userIdentifier.toString());
      // final result = await APIService().registerWithApple(
      //     'superspring@icloud.com', credential.userIdentifier.toString());
      if (result is RegisterWithAppleModel) {
        if (result.status) {
          Dialogs().hideLoaderDialog(context);
          showInfoAlert(context, 'Success register with Apple', '');
          setState(() {
            ownerName = credential.givenName.toString();
            token = result.data;
            sendEmailVerif = true;
            emailVerifSuccess = true;
          });
        } else {
          Dialogs().hideLoaderDialog(context);
          showInfoAlert(context, result.message, '');
        }
      } else {
        if (result is MessageModel) {
          Dialogs().hideLoaderDialog(context);
          showInfoAlert(context, result.message, '');
        }
      }
    }
  }

  Future<void> googleLogin() async {
    // _currentUser != null ? _googleSignIn.signOut() : {};
    _googleSignIn.disconnect();
    try {
      await _googleSignIn.signIn();
      print(_googleSignIn);
      if (_googleSignIn.currentUser!.email.isNotEmpty) {
        await Dialogs().loadingDialog(context);
        String fcm = '';
        fcm = await GeneralService().getFCMToken();
        final BodyLoginGoogle bodyLoginGoogle = BodyLoginGoogle(
            email: _googleSignIn.currentUser!.email,
            googleid: _googleSignIn.currentUser!.id,
            fcmToken: fcm);
        final _result = await APIService().doLoginGoogle(bodyLoginGoogle);
        if (_result is LoginModel) {
          LocalData _data = LocalData(
              ID: _result.data.ID,
              Username: _result.data.Username,
              Password: _googleSignIn.currentUser!.id,
              Fullname: _result.data.Fullname,
              Phone: _result.data.Phone,
              Email: _result.data.Email,
              Addres: _result.data.Addres,
              CompanyName: _result.data.CompanyName,
              BranchId: _result.data.BranchId,
              Privilage: _result.data.Privilage,
              Token: _result.data.Token,
              SeenId: _result.data.SeenId,
              IsGenerated: _result.data.isGenerated,
              IsGoogle: _result.data.IsGoogle,
              IsApple: _result.data.IsApple,
              createdAt: _result.data.createdAt);
          rememberMe
              ? await GeneralService().writeRememberMe(RememberMe(
                  Username: _userNameController.text,
                  Password: _passwordController.text))
              : await GeneralService().deleteRememberMe();

          final res = await GeneralService().readRememberMe();
          print(json.encode(res));
          await GeneralService().writeLocalUserStorage(_data);

          final resultURL = await APIService().getURL();
          if (resultURL is LinkModel) {
            await GeneralService().writeLocalURL(resultURL);
          } else {
            await GeneralService().writeLocalURL(resultURL);
          }
          await Dialogs().hideLoaderDialog(context);
          Timer.run(() {
            Navigator.of(context).pushReplacementNamed("/homepage");
          });
        }
        if (_result is ErrorTrapModel) {
          await Dialogs().hideLoaderDialog(context);
          showInfoAlert(context, AppLocalizations.of(context)!.noConnection,
              AppLocalizations.of(context)!.noConnectionSub);
          // showInfoAlert(context, AppLocalizations.of(context)!.noConnection, '');
        } else {
          if (_result is MessageModel) {
            if (_result.message == '999') {
              await Dialogs().hideLoaderDialog(context);
              showInfoAlert(
                  context,
                  AppLocalizations.of(context)!.notRegisteredYet,
                  AppLocalizations.of(context)!.notRegisteredYetSub);
            } else {
              await Dialogs().hideLoaderDialog(context);
              if (_result.message.toLowerCase().contains('deleted')) {
                showInfoAlert(context,
                    AppLocalizations.of(context)!.accountAlreadyDeleted, '');
              } else {
                showInfoAlert(context, _result.message, '');
              }
            }
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> appleLogin() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);
    if (credential.userIdentifier!.isNotEmpty) {
      Dialogs().loadingDialog(context);
      String fcm = '';
      fcm = await GeneralService().getFCMToken();
      final result = await APIService()
          .doLoginApple(credential.userIdentifier!.toString(), fcm);
      if (result is LoginModel) {
        LocalData _data = LocalData(
            ID: result.data.ID,
            Username: result.data.Username,
            Password: credential.userIdentifier!,
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
        rememberMe
            ? await GeneralService().writeRememberMe(RememberMe(
                Username: _userNameController.text,
                Password: _passwordController.text))
            : await GeneralService().deleteRememberMe();

        final res = await GeneralService().readRememberMe();
        print(json.encode(res));
        await GeneralService().writeLocalUserStorage(_data);

        final resultURL = await APIService().getURL();
        if (resultURL is LinkModel) {
          await GeneralService().writeLocalURL(resultURL);
        } else {
          await GeneralService().writeLocalURL(resultURL);
        }
        await Dialogs().hideLoaderDialog(context);
        Timer.run(() {
          Navigator.of(context).pushReplacementNamed("/homepage");
        });
      }
      if (result is ErrorTrapModel) {
        await Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, AppLocalizations.of(context)!.noConnection,
            AppLocalizations.of(context)!.noConnectionSub);
        // showInfoAlert(context, AppLocalizations.of(context)!.noConnection, '');
      } else {
        if (result is MessageModel) {
          if (result.message == '999') {
            await Dialogs().hideLoaderDialog(context);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.notRegisteredYet,
                AppLocalizations.of(context)!.notRegisteredYetSub);
          } else {
            await Dialogs().hideLoaderDialog(context);
            if (result.message.toLowerCase().contains('deleted')) {
              showInfoAlert(context,
                  AppLocalizations.of(context)!.accountAlreadyDeleted, '');
            } else {
              showInfoAlert(context, result.message, '');
            }
          }
        }
      }
    }
  }

  checkRememberMe() async {
    final res = await GeneralService().readRememberMe();
    if (res is RememberMe) {
      rememberMe = true;
      setState(() {
        _userNameController.text = res.Username;
        _passwordController.text = res.Password;
      });
    }
  }

  checkPermission() async {
    var status = await Permission.storage.status;
    var statusLocation = await Permission.location.status;
    var statusNotif = await Permission.notification.status;
    // var location = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if (!statusLocation.isGranted) {
      await Permission.location.request();
    }
    if (!statusNotif.isGranted) {
      await Permission.notification.request();
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  doLogin() async {
    setState(() {
      wrongUsernamePassword = false;
    });
    await Dialogs().loadingDialog(context);
    String fcm = '';
    fcm = await GeneralService().getFCMToken();
    final BodyLogin bodyLogin = BodyLogin(
        username: _userNameController.text.trim(),
        password: _passwordController.text.trim(),
        fcmToken: fcm);
    final _result = await APIService().doLogin(bodyLogin);
    if (_result is LoginModel) {
      LocalData _data = LocalData(
          ID: _result.data.ID,
          Username: _result.data.Username,
          Password: _passwordController.text,
          Fullname: _result.data.Fullname,
          Phone: _result.data.Phone,
          Email: _result.data.Email,
          Addres: _result.data.Addres,
          CompanyName: _result.data.CompanyName,
          BranchId: _result.data.BranchId,
          Privilage: _result.data.Privilage,
          Token: _result.data.Token,
          SeenId: _result.data.SeenId,
          IsGenerated: _result.data.isGenerated,
          IsGoogle: _result.data.IsGoogle,
          IsApple: _result.data.IsApple,
          createdAt: _result.data.createdAt);
      rememberMe
          ? await GeneralService().writeRememberMe(RememberMe(
              Username: _userNameController.text,
              Password: _passwordController.text))
          : await GeneralService().deleteRememberMe();

      final res = await GeneralService().readRememberMe();
      print(json.encode(res));
      await GeneralService().writeLocalUserStorage(_data);

      final resultURL = await APIService().getURL();
      if (resultURL is LinkModel) {
        await GeneralService().writeLocalURL(resultURL);
      } else {
        await GeneralService().writeLocalURL(resultURL);
      }
      await Dialogs().hideLoaderDialog(context);
      Timer.run(() {
        Navigator.of(context).pushReplacementNamed("/homepage");
      });
    }
    if (_result is ErrorTrapModel) {
      await Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, AppLocalizations.of(context)!.noConnection,
          AppLocalizations.of(context)!.noConnectionSub);
      // showInfoAlert(context, AppLocalizations.of(context)!.noConnection, '');
    } else {
      if (_result is MessageModel) {
        if (_result.message == '999') {
          await Dialogs().hideLoaderDialog(context);
          setState(() {
            wrongUsernamePassword = true;
          });
        } else {
          await Dialogs().hideLoaderDialog(context);
          if (_result.message.toLowerCase().contains('deleted')) {
            accountDeletedAlert(context,
                AppLocalizations.of(context)!.accountAlreadyDeleted, '');
          } else {
            showInfoAlert(context, _result.message, '');
          }
        }
      }
    }
  }

  doLoginDemo() async {
    await Dialogs().loadingDialog(context);
    String fcm = '';
    fcm = await GeneralService().getFCMToken();
    final BodyLogin bodyLogin =
        BodyLogin(username: 'demo', password: 'superspring', fcmToken: fcm);
    final _result = await APIService().doLogin(bodyLogin);
    if (_result is LoginModel) {
      LocalData _data = LocalData(
          ID: _result.data.ID,
          Username: _result.data.Username,
          Password: bodyLogin.password,
          Fullname: _result.data.Fullname,
          Phone: _result.data.Phone,
          Email: _result.data.Email,
          Addres: _result.data.Addres,
          CompanyName: _result.data.CompanyName,
          BranchId: _result.data.BranchId,
          Privilage: _result.data.Privilage,
          Token: _result.data.Token,
          SeenId: _result.data.SeenId,
          IsGenerated: _result.data.isGenerated,
          IsGoogle: _result.data.IsGoogle,
          IsApple: _result.data.IsApple,
          createdAt: _result.data.createdAt);
      await GeneralService().writeLocalUserStorage(_data);
      final resultURL = await APIService().getURL();
      if (resultURL is LinkModel) {
        await GeneralService().writeLocalURL(resultURL);
      } else {
        await GeneralService().writeLocalURL(resultURL);
      }
      await Dialogs().hideLoaderDialog(context);
      Timer.run(() {
        Navigator.of(context).pushReplacementNamed("/homepage");
      });
    }
    if (_result is ErrorTrapModel) {
      await Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, '${_result.statusError} ${_result.bodyError}', '');
    } else {
      await Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, _result.message, '');
    }
  }

  registerEmail() async {
    Dialogs().loadingDialog(context);
    final result = await APIService().registerEmail(
        emailRegisterController.text, passwordConfirmRegisterController.text);
    if (result is MessageModel) {
      if (result.status) {
        Dialogs().hideLoaderDialog(context);
        // checkEmail();
        setState(() {
          sendEmailVerif = true;
        });
      } else {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.message, '');
      }
    } else {
      if (result is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.bodyError, '');
      }
    }
  }

  checkEmail() async {
    Dialogs().loadingDialog(context);
    final result = await APIService().checkEmail(emailRegisterController.text);
    if (result is CheckEmailModel) {
      if (result.message[0].isVerifiedEmail) {
        Dialogs().hideLoaderDialog(context);
        setState(() {
          emailVerifSuccess = true;
          token = result.message[0].emailVerification;
        });
      } else {
        Dialogs().hideLoaderDialog(context);
        // checkEmail();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: redPrimary,
            content: Text(
              '${AppLocalizations.of(context)!.emailHasNotVerified}. ${AppLocalizations.of(context)!.emailVerificationSendSubSub}',
              style: reguler.copyWith(
                fontSize: 12,
                color: whiteColorDarkMode,
              ),
            ),
          ),
        );
      }
    } else {
      if (result is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.bodyError, '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget login = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GradientText('Welcome back!', colors: [blueGradientSecondary1, blueGradientSecondary2], gradientDirection: LinearGradient(colors: []),)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(AppLocalizations.of(context)!.welcomeBack,
                    style: bold.copyWith(
                      fontSize: 24,
                    ),
                    gradientType: GradientType.linear,
                    colors: [blueGradientSecondary2, blueGradientSecondary1]),
                Text(
                  AppLocalizations.of(context)!.signinToContinue,
                  style: reguler.copyWith(
                    fontSize: 14,
                    color:
                        widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                  ),
                ),
              ],
            ),
          ),
          Text(AppLocalizations.of(context)!.username,
              style: bold.copyWith(
                fontSize: 14,
                color: wrongUsernamePassword ? redPrimary : blackPrimary,
              )),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _userNameController,
              style: reguler.copyWith(
                fontSize: 13,
                color: blackPrimary,
              ),
              decoration: InputDecoration(
                fillColor: whiteCardColor,
                filled: true,
                hintText: AppLocalizations.of(context)!.insertUsername,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: wrongUsernamePassword ? redPrimary : blackSecondary3,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: wrongUsernamePassword ? redPrimary : bluePrimary,
                  ),
                ),
                hintStyle: reguler.copyWith(
                  fontSize: 12,
                  color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppLocalizations.of(context)!.password,
            style: bold.copyWith(
              fontSize: 14,
              color: wrongUsernamePassword ? redPrimary : blackPrimary,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _passwordController,
              style: reguler.copyWith(
                fontSize: 13,
                color: blackPrimary,
              ),
              onFieldSubmitted: (value) {
                doLogin();
              },
              obscureText: _isHidden,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                fillColor: whiteCardColor,
                // errorText: wrongUsernamePassword
                //     ? 'Username or password not registered'
                //     : '',
                filled: true,
                hintText: AppLocalizations.of(context)!.insertPassword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: wrongUsernamePassword ? redPrimary : blackSecondary3,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: wrongUsernamePassword ? redPrimary : bluePrimary,
                  ),
                ),
                hintStyle: reguler.copyWith(
                  fontSize: 12,
                  color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                suffixIcon: InkWell(
                  onTap: _togglePassword,
                  child: Icon(
                    _isHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color:
                        widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              wrongUsernamePassword
                  ? AppLocalizations.of(context)!.wrongUsernamePassword
                  : '',
              style: bold.copyWith(
                fontSize: 10,
                color: wrongUsernamePassword ? redPrimary : blackPrimary,
              ),
            ),
          ),
          Padding(
            padding: wrongUsernamePassword
                ? const EdgeInsets.only(top: 16)
                : const EdgeInsets.only(top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // width: 150,
                  child: Transform.translate(
                    offset: const Offset(-10, 0),
                    child: Theme(
                      data: ThemeData(unselectedWidgetColor: blackPrimary),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Transform.translate(
                          offset: const Offset(-20, 0),
                          child: Text(
                            AppLocalizations.of(context)!.rememberMe,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                              // decoration:
                              //     TextDecoration.underline,
                            ),
                          ),
                        ),
                        value: rememberMe,
                        onChanged: (value) async {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: InkWell(
                    onTap: () => launchUrl(
                        Uri.parse('https://forgot.gps.id/password'),
                        mode: LaunchMode.externalApplication),
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: reguler.copyWith(
                        fontSize: 12,
                        color: blackPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Align(
          //   alignment: Alignment.topRight,
          //   child: Text(
          //     AppLocalizations.of(context)!.forgotPassword,
          //     style: reguler.copyWith(
          //       fontSize: 12,
          //       color: blackPrimary,
          //       decoration: TextDecoration.underline,
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(12),
              // ),
              // color: greenPrimary,
              onPressed: () {
                doLogin();
              },
              child: Text(
                AppLocalizations.of(context)!.login,
                style: bold.copyWith(
                  fontSize: 14,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Divider(
                  height: 2,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: widget.darkMode ? whiteColorDarkMode : greyColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppLocalizations.of(context)!.orLoginWith,
                  style: reguler.copyWith(
                      fontSize: 14,
                      color: widget.darkMode
                          ? whiteColorDarkMode
                          : blackSecondary3),
                ),
              ),
              Expanded(
                child: Divider(
                  height: 2,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: widget.darkMode ? whiteColorDarkMode : greyColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 1,
                      color: bluePrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    doLoginDemo();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        AppLocalizations.of(context)!.demo,
                        minFontSize: 10,
                        maxFontSize: 14,
                        maxLines: 1,
                        style: reguler.copyWith(
                          color: bluePrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: Platform.isIOS,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1,
                        color: widget.darkMode ? bluePrimary : whiteColor,
                      ),
                      backgroundColor:
                          widget.darkMode ? whiteColor : blackPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () async {
                      appleLogin();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.apple,
                              color: whiteColorDarkMode,
                              size: 24,
                            )),
                        AutoSizeText(
                          AppLocalizations.of(context)!.logInWithApple,
                          minFontSize: 10,
                          maxFontSize: 14,
                          maxLines: 1,
                          style: reguler.copyWith(
                            color: widget.darkMode ? bluePrimary : whiteColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 1,
                      color: bluePrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    // doLoginDemo();
                    googleLogin();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Image.asset(
                          'assets/icon/google.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      AutoSizeText(
                        AppLocalizations.of(context)!.logInWithGoogle,
                        minFontSize: 10,
                        maxFontSize: 14,
                        maxLines: 1,
                        style: reguler.copyWith(
                          color: bluePrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    Widget register = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: Platform.isIOS,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  width: 1,
                  color: widget.darkMode ? bluePrimary : whiteColor,
                ),
                backgroundColor: widget.darkMode ? whiteColor : blackPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () async {
                // doLoginDemo();
                // await registerWithGoogle();
                await registerWithApple();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.apple,
                        color: whiteColorDarkMode,
                        size: 24,
                      )),
                  AutoSizeText(
                    AppLocalizations.of(context)!.registerWithApple,
                    minFontSize: 10,
                    maxFontSize: 14,
                    maxLines: 1,
                    style: reguler.copyWith(
                      color: widget.darkMode ? bluePrimary : whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                width: 1,
                color: bluePrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () async {
              // doLoginDemo();
              await registerWithGoogle();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Image.asset(
                    'assets/icon/google.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.registerWithGoogle,
                  minFontSize: 10,
                  maxFontSize: 14,
                  maxLines: 1,
                  style: reguler.copyWith(
                    color: bluePrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Divider(
                  height: 2,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: widget.darkMode ? whiteColorDarkMode : greyColor,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text(
                  AppLocalizations.of(context)!.or,
                  style: reguler.copyWith(
                      fontSize: 14,
                      color: widget.darkMode
                          ? whiteColorDarkMode
                          : blackSecondary3),
                ),
              ),
              Expanded(
                child: Divider(
                  height: 2,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: widget.darkMode ? whiteColorDarkMode : greyColor,
                ),
              ),
            ],
          ),
          Text(AppLocalizations.of(context)!.email,
              style: bold.copyWith(
                fontSize: 14,
                color: blackPrimary,
              )),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: emailRegisterController,
              style: reguler.copyWith(
                fontSize: 13,
                color: blackPrimary,
              ),
              decoration: InputDecoration(
                fillColor: whiteCardColor,
                filled: true,
                hintText: AppLocalizations.of(context)!.insertEmail,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: blackSecondary3,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: bluePrimary,
                  ),
                ),
                hintStyle: reguler.copyWith(
                  fontSize: 12,
                  color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            AppLocalizations.of(context)!.emailRegistTitle,
            style: reguler.copyWith(
                color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                fontSize: 10),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppLocalizations.of(context)!.password,
            style: bold.copyWith(
              fontSize: 14,
              color: blackPrimary,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: passwordRegisterController,
              style: reguler.copyWith(
                fontSize: 13,
                color: blackPrimary,
              ),
              onFieldSubmitted: (value) {
                // doLogin();
              },
              obscureText: hiddenPassRegister,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                fillColor: whiteCardColor,
                // errorText: wrongUsernamePassword
                //     ? 'Username or password not registered'
                //     : '',
                filled: true,
                hintText: AppLocalizations.of(context)!.insertPassword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: blackSecondary3,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: bluePrimary,
                  ),
                ),
                hintStyle: reguler.copyWith(
                  fontSize: 12,
                  color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                suffixIcon: InkWell(
                  onTap: togglePasswordRegist,
                  child: Icon(
                    hiddenPassRegister
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color:
                        widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.confirmPasswordRegist,
                style: bold.copyWith(
                  fontSize: 14,
                  color: blackPrimary,
                ),
              ),
              Visibility(
                  visible: passMatch,
                  child: Icon(
                    Icons.check_circle_outline_outlined,
                    size: 20,
                    color: greenPrimary,
                  ))
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: passwordConfirmRegisterController,
              style: reguler.copyWith(
                fontSize: 13,
                color: blackPrimary,
              ),
              onFieldSubmitted: (value) {
                // doLogin();
              },
              onChanged: (value) {
                if (value != passwordRegisterController.text) {
                  setState(() {
                    passMatch = false;
                  });
                } else {
                  setState(() {
                    passMatch = true;
                  });
                }
              },
              obscureText: hiddenConfirmPassRegister,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                fillColor: whiteCardColor,
                // errorText: wrongUsernamePassword
                //     ? 'Username or password not registered'
                //     : '',
                filled: true,
                hintText: AppLocalizations.of(context)!.confirmPasswordRegist,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: blackSecondary3,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: bluePrimary,
                  ),
                ),
                hintStyle: reguler.copyWith(
                  fontSize: 12,
                  color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                suffixIcon: InkWell(
                  onTap: toggleConfirmPasswordRegist,
                  child: Icon(
                    hiddenConfirmPassRegister
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color:
                        widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(12),
              // ),
              // color: greenPrimary,
              onPressed: () {
                // setState(() {
                //   sendEmailVerif = true;
                // });
                if (emailRegisterController.text.isEmpty ||
                    passwordConfirmRegisterController.text.isEmpty ||
                    passwordRegisterController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: redPrimary,
                      content: Text(
                        AppLocalizations.of(context)!.checkPass,
                        style: reguler.copyWith(
                          fontSize: 12,
                          color: whiteColorDarkMode,
                        ),
                      ),
                    ),
                  );
                } else {
                  if (passwordConfirmRegisterController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: redPrimary,
                        content: Text(
                          AppLocalizations.of(context)!.passMustBe6,
                          style: reguler.copyWith(
                            fontSize: 12,
                            color: whiteColorDarkMode,
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (passwordRegisterController.text ==
                        passwordConfirmRegisterController.text) {
                      registerEmail();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: redPrimary,
                          content: Text(
                            AppLocalizations.of(context)!.checkPass,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: whiteColorDarkMode,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.register,
                style: bold.copyWith(
                  fontSize: 14,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: widget.darkMode ? whiteColor : const Color(0xFF0383D0),
      body: sendEmailVerif
          ? emailVerifSuccess
              ?
              // Email verif success
              Container(
                  width: double.infinity,
                  color: whiteColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text(
                          AppLocalizations.of(context)!
                              .emailVerificationSuccess,
                          textAlign: TextAlign.center,
                          style:
                              bold.copyWith(fontSize: 20, color: blackPrimary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Image.asset(
                          'assets/verifsuccess.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text(
                          AppLocalizations.of(context)!
                              .emailRegistVerificationSuccessThanks,
                          textAlign: TextAlign.center,
                          style: reguler.copyWith(
                              fontSize: 14,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(12),
                            // ),
                            // color: greenPrimary,
                            onPressed: () {
                              // doLogin();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddUnit(
                                      darkMode: widget.darkMode,
                                      token: token,
                                      ownerName: ownerName,
                                    ),
                                  ));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.next,
                              style: bold.copyWith(
                                fontSize: 14,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              :
              //Email verif send
              Container(
                  width: double.infinity,
                  color: whiteColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text(
                          AppLocalizations.of(context)!.verifYourEmail,
                          textAlign: TextAlign.center,
                          style:
                              bold.copyWith(fontSize: 20, color: blackPrimary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text(
                          AppLocalizations.of(context)!.verifYourEmailSub,
                          textAlign: TextAlign.center,
                          style: reguler.copyWith(
                              fontSize: 14,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary2),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .verifYourEmailSubSub,
                                    style: reguler.copyWith(
                                        fontSize: 14,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary2)),
                                TextSpan(
                                    text:
                                        '${emailRegisterController.text.isEmpty ? 'email@gmail.com' : emailRegisterController.text}. ',
                                    style: bold.copyWith(
                                        fontSize: 14,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary2)),
                                TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .verifYourEmailSubSubSub,
                                    style: reguler.copyWith(
                                        fontSize: 14,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary2))
                              ]))),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Image.asset(
                          'assets/verificationemail.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text(
                          AppLocalizations.of(context)!
                              .verifYourEmailSubSubSubSub,
                          textAlign: TextAlign.center,
                          style: reguler.copyWith(
                              fontSize: 14,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary2),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sendEmailVerif = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(AppLocalizations.of(context)!.changeEmail,
                              textAlign: TextAlign.center,
                              style: bold.copyWith(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  color: bluePrimary)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          registerEmail();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(AppLocalizations.of(context)!.resendEmail,
                              textAlign: TextAlign.center,
                              style: bold.copyWith(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  color: bluePrimary)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          checkEmail();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(AppLocalizations.of(context)!.verifDone,
                              textAlign: TextAlign.center,
                              style: bold.copyWith(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  color: bluePrimary)),
                        ),
                      ),
                    ],
                  ),
                )
          : SafeArea(
              bottom: false,
              top: false,
              child: SingleChildScrollView(
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: RadialGradient(
                      colors: [
                        widget.darkMode
                            ? whiteCardColor
                            : const Color(0xFF77BBE4),
                        widget.darkMode
                            ? whiteCardColor
                            : const Color(0xFF45A4DD),
                        widget.darkMode ? whiteColor : const Color(0xFF0383D0)
                      ],
                      center: const Alignment(0.0, -0.55),
                      // stops: [0.4, 1.0],
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          // padding: const EdgeInsets.only(bottom: 50),
                          width: double.infinity,
                          // height: 230,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 70),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/logogpsid.png',
                                    height: 60,
                                  ),
                                  Image.asset(
                                    'assets/superspring.png',
                                    height: 60,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      height: 48,
                                      width:
                                          MediaQuery.of(context).size.width / 1,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: whiteColor,
                                        border: Border.all(
                                          width: 1,
                                          color: whiteColor,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  signin == false
                                                      ? signin = true
                                                      : {};
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      color: signin
                                                          ? bluePrimary
                                                          : whiteColor,
                                                      border: Border.all(
                                                        width: 1,
                                                        color: signin
                                                            ? bluePrimary
                                                            : whiteColor,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 6,
                                                        // horizontal: 50
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .login,
                                                        style: reguler.copyWith(
                                                            fontSize: 14,
                                                            color: !signin
                                                                ? bluePrimary
                                                                : whiteColor),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  signin == true
                                                      ? signin = false
                                                      : {};
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      color: !signin
                                                          ? bluePrimary
                                                          : whiteColor,
                                                      border: Border.all(
                                                        width: 1,
                                                        color: !signin
                                                            ? bluePrimary
                                                            : whiteColor,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 6,
                                                        // horizontal: 50
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .register,
                                                        style: reguler.copyWith(
                                                            fontSize: 14,
                                                            color: signin
                                                                ? bluePrimary
                                                                : whiteColor),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12))),
                            child: signin ? login : register)
                      ],
                    )),
              ),
            ),
    );
    // return Scaffold(
    //   body: SignInDemo(),
    // );
  }

  _togglePassword() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  togglePasswordRegist() {
    setState(() {
      hiddenPassRegister = !hiddenPassRegister;
    });
  }

  toggleConfirmPasswordRegist() {
    setState(() {
      hiddenConfirmPassRegister = !hiddenConfirmPassRegister;
    });
  }
}
