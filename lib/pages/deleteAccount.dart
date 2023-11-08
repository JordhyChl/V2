// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/notification.dart';

class DeleteAccount extends StatefulWidget {
  final bool darkMode;
  final String email;
  final String token;
  const DeleteAccount(
      {super.key,
      required this.darkMode,
      required this.email,
      required this.token});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  late FirebaseBackground firebase;
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
    firebase = FirebaseBackground();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      print(_currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        color: widget.darkMode ? whiteCardColor : whiteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_outlined,
              color: bluePrimary,
              size: 100,
            ),
            Text(AppLocalizations.of(context)!.checkEmailToDelete,
                style: bold.copyWith(
                  fontSize: 16,
                  color: widget.darkMode ? whiteColorDarkMode : blackPrimary,
                ),
                textAlign: TextAlign.center),
            GestureDetector(
              onTap: () async {
                LocalData localData =
                    await GeneralService().readLocalUserStorage();
                Dialogs().loadingDialog(context);
                final result = await APIService().checkAccount(widget.token);
                if (result is ErrorTrapModel) {
                  Dialogs().hideLoaderDialog(context);
                  showInfoAlert(context, result.bodyError, '');
                } else {
                  if (result is MessageModel) {
                    Dialogs().hideLoaderDialog(context);
                    if (result.status) {
                      await Dialogs().loadingDialog(context);
                      localData.IsGoogle
                          ? _currentUser != null
                              ? _googleSignIn.signOut()
                              : {}
                          : {};
                      final result = await APIService().doLogout();
                      if (result is ErrorTrapModel) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
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
                        await GeneralService().deleteLocalAlarmStorage();
                        await GeneralService().deleteLocalAlarmTypeID();
                        await GeneralService().deleteLocalUserStorage();
                        await GeneralService().deleteLocalURL();
                        Navigator.of(context).pop();
                        await Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: greenPrimary,
                            content: Text(
                              AppLocalizations.of(context)!
                                  .deleteYourAccountSuccess,
                              style: reguler.copyWith(
                                fontSize: 12,
                                color: whiteColorDarkMode,
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      // Dialogs().hideLoaderDialog(context);
                      // showInfoAlert(context, result.message, '');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: redPrimary,
                          content: Text(
                            AppLocalizations.of(context)!
                                .notYetDeleteAccountVerif,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: whiteColorDarkMode,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: widget.darkMode ? whiteCardColor : whiteColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: bluePrimary)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      AppLocalizations.of(context)!
                          .checkDeleteVerificationStatus,
                      style: reguler.copyWith(color: bluePrimary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
