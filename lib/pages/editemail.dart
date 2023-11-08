// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/profile.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EditEmail extends StatefulWidget {
  final bool darkMode;
  const EditEmail({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<EditEmail> createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  final TextEditingController _oldEmail = TextEditingController();
  final TextEditingController _newEmail = TextEditingController();
  final TextEditingController _confirmNewEmail = TextEditingController();
  bool isCheck = false;
  late ProfileModel profile;
  bool success = false;
  bool currentEmail = false;
  bool newEmail = false;
  String currEmail = '';
  String getNewEmail = '';
  late Future<dynamic> _getProfile;
  late ProfileModel profileData;
  late LinkModel url;
  bool successVerif = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getProfile = getProfile();
  }

  emailVerifCheck() async {
    Dialogs().loadingDialog(context);
    final result = await APIService().getProfile();
    if (result is ErrorTrapModel) {
      Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, result.statusError, '');
    } else {
      if (result is ProfileModel) {
        Dialogs().hideLoaderDialog(context);
        if (result.data.result.isVerifiedEmail) {
          setState(() {
            successVerif = true;
          });
        } else {
          showInfoAlert(context,
              AppLocalizations.of(context)!.yourEmailHasNotBeenVerified, '');
        }
      }
    }
  }

  Future<dynamic> getProfile() async {
    final result = await APIService().getProfile();
    url = await GeneralService().readLocalUrl();
    if (result is ProfileModel) {
      setState(() {
        currEmail = result.data.result.email;
      });
    }
    // setState(() {
    //   currEmail = result.Email;
    // });

    return result;
  }

  doSubmitEmail(String email) async {
    Dialogs().loadingDialog(context);
    final result = await APIService().sendEmailVerif(email);
    if (result is ErrorTrapModel) {
      Navigator.pop(context);
      setState(() {
        showInfoAlert(context, result.bodyError, '');
      });
    } else {
      if (result is MessageModel) {
        if (result.status) {
          Navigator.pop(context);
          setState(() {
            success = true;
          });
        } else {
          Navigator.pop(context);
          setState(() {
            showInfoAlert(context, result.message, '');
          });
        }
      }
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
        leading: Visibility(
          visible: !successVerif,
          child: IconButton(
            iconSize: 32,
            icon: const Icon(Icons.arrow_back_outlined),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.email,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      backgroundColor: whiteColor,
      body: success
          ? successVerif
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .emailVerificationSuccess,
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
                                  .emailVerificationSuccessThanks,
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
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.emailVerificationSend,
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
                            'assets/verificationemail.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .emailVerificationSendSub,
                                    style: reguler.copyWith(
                                      fontSize: 10,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${_confirmNewEmail.text}. ',
                                    style: bold.copyWith(
                                      fontSize: 10,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .emailVerificationSendSubSub,
                                    style: reguler.copyWith(
                                      fontSize: 10,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                  ),
                                ])),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/editEmail');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.2,
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .checkSpam,
                                      style: reguler.copyWith(
                                        fontSize: 10,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary3,
                                      ),
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.or,
                                      style: reguler.copyWith(
                                        fontSize: 10,
                                        color: widget.darkMode
                                            ? whiteColorDarkMode
                                            : blackSecondary3,
                                      ),
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .changeEmail,
                                      style: bold.copyWith(
                                        fontSize: 10,
                                        decoration: TextDecoration.underline,
                                        color: bluePrimary,
                                      ),
                                    ),
                                  ])),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 10, right: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                  ),
                                  backgroundColor: whiteCardColor,
                                  context: context,
                                  builder: (context) {
                                    return SingleChildScrollView(
                                      child: Container(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .needHelp,
                                                          style: bold.copyWith(
                                                              fontSize: 16,
                                                              color:
                                                                  blackPrimary)),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {},
                                                    child: Row(
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
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/wadialog.png',
                                                    width: 200,
                                                    height: 200,
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .needHelpSub,
                                                    style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: blackSecondary3),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                enableFeedback:
                                                    url.data.branch.whatsapp ==
                                                            ''
                                                        ? false
                                                        : true,
                                                onTap: () {
                                                  if (url.data.branch
                                                          .whatsapp !=
                                                      '') {
                                                    launchUrl(
                                                        Uri.parse(
                                                            'https://wa.me/${url.data.branch.whatsapp}'),
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, bottom: 5),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: whiteColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: url.data.branch
                                                                    .whatsapp ==
                                                                ''
                                                            ? greyColor
                                                            : greenPrimary,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                                child:
                                                                    Image.asset(
                                                                  'assets/wa2.png',
                                                                  width: 18,
                                                                  height: 18,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? null
                                                                      : greyColor,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            2),
                                                                child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .installationBranch,
                                                                    style: bold.copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: url.data.branch.whatsapp ==
                                                                                ''
                                                                            ? greyColor
                                                                            : greenPrimary)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launchUrl(
                                                      Uri.parse(
                                                          'https://wa.me/${url.data.head.whatsapp}'),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: greenPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: greenPrimary,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                                child:
                                                                    Image.asset(
                                                                  'assets/wa2.png',
                                                                  width: 18,
                                                                  height: 18,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            2),
                                                                child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .cc24H,
                                                                    style: bold.copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : whiteColor)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Image.asset(
                                      'assets/wa2.png',
                                      width: 18,
                                      height: 18,
                                    ),
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!.callForHelp,
                                      style: reguler.copyWith(fontSize: 12))
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                emailVerifCheck();
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
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .checkVerificationStatus,
                                  style: reguler.copyWith(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          : FutureBuilder(
              future: _getProfile,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data is ErrorTrapModel) {
                    return Container(
                      color: whiteColor,
                      child: Padding(
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
                      ),
                    );
                  } else {
                    profileData = snapshot.data as ProfileModel;
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SingleChildScrollView(
                        physics: const ScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        child: Column(
                          children: [
                            Visibility(
                              visible: profileData.data.result.email.isNotEmpty
                                  ? true
                                  : false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!.changeEmail,
                                      style: bold.copyWith(
                                        fontSize: 16,
                                        color: blueGradient,
                                      )),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!
                                              .currentEmail,
                                          style: bold.copyWith(
                                            fontSize: 14,
                                            color: blackPrimary,
                                          )),
                                      Visibility(
                                          visible: currentEmail,
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
                                      onChanged: (value) {
                                        value != currEmail
                                            ? setState(
                                                () {
                                                  currentEmail = false;
                                                },
                                              )
                                            : setState(
                                                () {
                                                  currentEmail = true;
                                                },
                                              );
                                      },
                                      controller: _oldEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      style: reguler.copyWith(
                                        fontSize: 13,
                                        color: blackPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        suffixIcon: Visibility(
                                            visible: _oldEmail.text.isEmpty
                                                ? false
                                                : true,
                                            child: InkWell(
                                              onTap: () {
                                                _oldEmail.clear();
                                              },
                                              child: Image.asset(
                                                  'assets/edit_icon.png'),
                                            )),
                                        filled: true,
                                        fillColor: whiteCardColor,
                                        hintText: profileData.data.result.email,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabled: false,
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
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(AppLocalizations.of(context)!.newEmail,
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
                                    onChanged: (value) {
                                      setState(() {
                                        getNewEmail = value;
                                      });
                                    },
                                    controller: _newEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    style: reguler.copyWith(
                                      fontSize: 13,
                                      color: blackPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteCardColor,
                                      hintText: AppLocalizations.of(context)!
                                          .insertNewEmail,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!
                                            .confirmNewEmail,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: blackPrimary,
                                        )),
                                    Visibility(
                                        visible: newEmail,
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
                                    onChanged: (value) {
                                      value != getNewEmail
                                          ? setState(
                                              () {
                                                newEmail = false;
                                              },
                                            )
                                          : setState(
                                              () {
                                                newEmail = true;
                                              },
                                            );
                                    },
                                    controller: _confirmNewEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    style: reguler.copyWith(
                                      fontSize: 13,
                                      color: blackPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: Visibility(
                                          visible: _confirmNewEmail.text.isEmpty
                                              ? false
                                              : true,
                                          child: InkWell(
                                            onTap: () {
                                              _confirmNewEmail.clear();
                                            },
                                            child: Image.asset(
                                                'assets/edit_icon.png'),
                                          )),
                                      filled: true,
                                      fillColor: whiteCardColor,
                                      hintText: AppLocalizations.of(context)!
                                          .insertConfirmNewEmail,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppLocalizations.of(context)!.editEmailContent,
                                style: reguler.copyWith(
                                  fontSize: 10,
                                  color: blackSecondary3,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                (90 / 100),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            doSubmitEmail(
                                                _newEmail.text.trim());
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                  color: greenPrimary,
                                                ),
                                              ),
                                              backgroundColor: greenPrimary,
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                              )),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .changeAndVerifEmail,
                                            style: bold.copyWith(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                return Container(
                  color: whiteColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/gpsidbaru.png',
                          width: 130,
                        ),
                      ),
                      LoadingAnimationWidget.waveDots(
                        size: 50,
                        color:
                            widget.darkMode ? whiteColorDarkMode : whiteColor,
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
