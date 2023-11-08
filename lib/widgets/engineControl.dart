// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, file_names, use_build_context_synchronously, deprecated_member_use, prefer_adjacent_string_concatenation, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/vehicledetail.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class EngineControl extends StatefulWidget {
  final List<FeaturesVehicleDetail> feature;
  final String phoneNumber;
  final String imei;
  final bool darkMode;
  const EngineControl(
      {Key? key,
      required this.feature,
      required this.phoneNumber,
      required this.imei,
      required this.darkMode})
      : super(key: key);

  @override
  State<EngineControl> createState() => _EngineControlState();
}

class _EngineControlState extends State<EngineControl> {
  var size, height, width;
  bool isDisabled = false;
  TextEditingController textController = TextEditingController();
  late LocalData data;
  late List<FeaturesVehicleDetail> getFeature;
  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    getLocal();
    getFeature = widget.feature;
  }

  getLocal() async {
    var getLocal = await GeneralService().readLocalUserStorage();
    setState(() {
      data = getLocal;
    });
  }

  _doCommand(String command, int onOff) async {
    await Dialogs().loadingDialog(context);
    if (getFeature[0].isDashcam) {
      print('is Dashcam : ${getFeature[0].isDashcam}');
      final result = await APIService()
          .liveStreamDashcamCommand(widget.imei.toString(), command);
      if (result is ErrorTrapModel) {
        setState(() {});
        await Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.bodyError, '');
      } else {
        setState(() {});
        if (onOff == 1) {
          if (result.msg == 'OK!') {
            await Dialogs().hideLoaderDialog(context);
            showInfoAlert(context,
                AppLocalizations.of(context)!.engineOnCommandSuccess, '');
            // Alerts().showSuccessLoginAlert(context, _result.message);
          } else {
            await Dialogs().hideLoaderDialog(context);
            // Alerts()
            //     .showInfoAlert(context, AppLocalizations.of(context).commandFailed);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.engineOnCommandFailed,
                AppLocalizations.of(context)!.engineOnCommandFailedSub);
          }
        } else if (onOff == 0) {
          if (result.msg == 'OK!') {
            await Dialogs().hideLoaderDialog(context);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.engineOffCommandSuccess,
                AppLocalizations.of(context)!.engineOffCommandSuccessSub);
            // Alerts().showSuccessLoginAlert(context, _result.message);
          } else {
            await Dialogs().hideLoaderDialog(context);
            // Alerts()
            //     .showInfoAlert(context, AppLocalizations.of(context).commandFailed);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.engineOffCommandFailed,
                AppLocalizations.of(context)!.engineOffCommandFailedSub);
          }
        }
      }
    } else {
      print('is Dashcam : ${getFeature[0].isDashcam}');
      final result =
          await APIService().doSendCommand(widget.imei.toString(), command);

      if (result is ErrorTrapModel) {
        setState(() {});
        await Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.bodyError, '');
      } else {
        setState(() {});
        if (onOff == 1) {
          if (result.status) {
            await Dialogs().hideLoaderDialog(context);
            showInfoAlert(context,
                AppLocalizations.of(context)!.engineOnCommandSuccess, '');
            // Alerts().showSuccessLoginAlert(context, _result.message);
          } else {
            await Dialogs().hideLoaderDialog(context);
            // Alerts()
            //     .showInfoAlert(context, AppLocalizations.of(context).commandFailed);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.engineOnCommandFailed,
                AppLocalizations.of(context)!.engineOnCommandFailedSub);
          }
        } else if (onOff == 0) {
          if (result.status) {
            await Dialogs().hideLoaderDialog(context);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.engineOffCommandSuccess,
                AppLocalizations.of(context)!.engineOffCommandSuccessSub);
            // Alerts().showSuccessLoginAlert(context, _result.message);
          } else {
            await Dialogs().hideLoaderDialog(context);
            // Alerts()
            //     .showInfoAlert(context, AppLocalizations.of(context).commandFailed);
            showInfoAlert(
                context,
                AppLocalizations.of(context)!.engineOffCommandFailed,
                AppLocalizations.of(context)!.engineOffCommandFailedSub);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return GestureDetector(
      onTap: () {
        getFeature.isNotEmpty
            ? getFeature[0].isEngineOn != false
                ? showModalBottomSheet(
                    backgroundColor:
                        widget.darkMode ? whiteCardColor : whiteColor,
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
                          (BuildContext context, StateSetter setStateModal) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: MediaQuery.of(context).viewInsets,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
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
                                    children: [
                                      Image.asset(
                                        'assets/mobil_bergerak.png',
                                        width: 120,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .engineOnOffConfirm,
                                        style: bold.copyWith(
                                          fontSize: 12,
                                          color: blackPrimary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .engineOnOffConfirmSub,
                                        style: reguler.copyWith(
                                            fontSize: 10,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : blackSecondary3),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .password,
                                          style: bold.copyWith(
                                            fontSize: 10,
                                            color: blackPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      SizedBox(
                                        width: width,
                                        height: 40,
                                        child: TextFormField(
                                          // onChanged: (value) {
                                          //   if (value.isEmpty) {
                                          //     setState(() {
                                          //       isDisabled = false;
                                          //     });
                                          //   } else {
                                          //     setState(() {
                                          //       isDisabled = true;
                                          //     });
                                          //   }
                                          // },
                                          // autofocus: true,
                                          onChanged: (value) {
                                            value = textController.text.trim();
                                            if (value == data.Password) {
                                              setStateModal(
                                                () {
                                                  isDisabled = true;
                                                },
                                              );
                                            } else {
                                              setStateModal(
                                                () {
                                                  isDisabled = false;
                                                },
                                              );
                                            }
                                          },
                                          controller: textController,
                                          obscuringCharacter: '*',
                                          obscureText: _isHidden,
                                          style: reguler.copyWith(
                                              color: blackPrimary),
                                          decoration: InputDecoration(
                                            fillColor: widget.darkMode
                                                ? whiteColor
                                                : whiteCardColor,
                                            filled: true,
                                            hintText:
                                                AppLocalizations.of(context)!
                                                    .insertPassword,
                                            hintStyle: reguler.copyWith(
                                              fontSize: 10,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : blackSecondary3,
                                            ),
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                if (_isHidden) {
                                                  setStateModal(() {
                                                    _isHidden = false;
                                                  });
                                                } else {
                                                  setStateModal(() {
                                                    _isHidden = true;
                                                  });
                                                }
                                                // _togglePassword();
                                                // setStateModal() {
                                                //   _isHidden = !_isHidden;
                                                // }
                                                // _isHidden ? false : true;
                                              },
                                              child: Icon(
                                                _isHidden
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: blackPrimary,
                                              ),
                                            ),
                                            // const Icon(Icons.visibility_off),
                                            contentPadding:
                                                const EdgeInsets.all(
                                              15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    width: width,
                                    height: height / 5,
                                    // decoration: BoxDecoration(
                                    //   border: Border(
                                    //     top: BorderSide(
                                    //       width: 1,
                                    //       color: greyColor,
                                    //     ),
                                    //   ),
                                    // ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buttonEngineOnGPRS(
                                              widget.darkMode
                                                  ? greyColor
                                                  : whiteColor,
                                              bluePrimary,
                                              bluePrimary,
                                              greyColor,
                                              widget.darkMode
                                                  ? greyColor
                                                  : whiteColor,
                                              true,
                                            ),
                                            _buttonEngineOffGPRS(
                                              widget.darkMode
                                                  ? greyColor
                                                  : whiteColor,
                                              redPrimary,
                                              redPrimary,
                                              greyColor,
                                              widget.darkMode
                                                  ? greyColor
                                                  : whiteColor,
                                              true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buttonEngineOnSMS(
                                              bluePrimary,
                                              whiteColor,
                                              bluePrimary,
                                              whiteColor,
                                              greyColor,
                                              false,
                                            ),
                                            _buttonEngineOffSMS(
                                              redPrimary,
                                              whiteColor,
                                              redPrimary,
                                              whiteColor,
                                              greyColor,
                                              false,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    })
                : {}
            : {};
      },
      child: Column(
        children: [
          Image.asset(
            getFeature.isEmpty
                ? 'assets/icon/vehicledetail/engineonoffdisable.png'
                : getFeature[0].isEngineOn != false
                    ? 'assets/icon/vehicledetail/engineonoff.png'
                    : 'assets/icon/vehicledetail/engineonoffdisable.png',
            width: 32,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            AppLocalizations.of(context)!.ctrlEngine,
            textAlign: TextAlign.center,
            style: bold.copyWith(
              fontSize: 10,
              color: widget.darkMode ? whiteColorDarkMode : blackSecondary1,
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buttonEngineOnGPRS(
    Color textColor,
    Color bgColor,
    Color borderColor,
    Color disabled,
    Color disabledText,
    bool bolder,
  ) {
    return Expanded(
      // width: 165,
      // height: 42,
      child: Padding(
        padding: const EdgeInsets.only(left: 1, right: 1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: disabled,
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: isDisabled ? borderColor : greyColor, width: 1),
              )),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12),
          //   side:
          //       BorderSide(color: isDisabled ? borderColor : greyColor, width: 1),
          // ),
          // disabledColor: disabled,
          // color: bgColor,
          // onPressed: isDisabled
          //     ? () async {
          //         String getBody = '';
          //         getBody = Uri.encodeQueryComponent(getFeature[0].smsOn);
          //         await launch("sms:" +
          //             '${widget.phoneNumber}?body=${getBody.replaceAll('+', '%20')}');
          //       }
          //     : null,
          onPressed: isDisabled
              ? () {
                  _doCommand(getFeature[0].smsOn, 1);
                  // _doCommand('getstatus');
                }
              : null,
          child: Text(AppLocalizations.of(context)!.engineOnGPRS,
              textAlign: TextAlign.center,
              style: bolder
                  ? bold.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )
                  : reguler.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )),
        ),
      ),
    );
  }

  Expanded _buttonEngineOffGPRS(
    Color textColor,
    Color bgColor,
    Color borderColor,
    Color disabled,
    Color disabledText,
    bool bolder,
  ) {
    return Expanded(
      // width: 165,
      // height: 42,
      child: Padding(
        padding: const EdgeInsets.only(left: 1, right: 1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: disabled,
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: isDisabled ? borderColor : greyColor, width: 1),
              )),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12),
          //   side:
          //       BorderSide(color: isDisabled ? borderColor : greyColor, width: 1),
          // ),
          // disabledColor: disabled,
          // color: bgColor,
          onPressed: isDisabled
              ? () {
                  _doCommand(getFeature[0].smsOff, 0);
                }
              : null,
          child: Text(AppLocalizations.of(context)!.engineOffGPRS,
              textAlign: TextAlign.center,
              style: bolder
                  ? bold.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )
                  : reguler.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )),
        ),
      ),
    );
  }

  Expanded _buttonEngineOnSMS(
    Color textColor,
    Color bgColor,
    Color borderColor,
    Color disabled,
    Color disabledText,
    bool bolder,
  ) {
    return Expanded(
      // width: 165,
      // height: 42,
      child: Padding(
        padding: const EdgeInsets.only(left: 1, right: 1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: disabled,
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: isDisabled ? borderColor : greyColor, width: 1),
              )),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12),
          //   side:
          //       BorderSide(color: isDisabled ? borderColor : greyColor, width: 1),
          // ),
          // disabledColor: disabled,
          // color: bgColor,
          onPressed: isDisabled
              ? () async {
                  String getBody = '';
                  getBody = Uri.encodeQueryComponent(getFeature[0].smsOn);
                  // await launch("sms:" +
                  //     '${widget.phoneNumber}?body=${getBody.replaceAll('+', '%20')}');
                  if (Platform.isAndroid) {
                    //ganti kirim ke api
                    //c20 hapus spasi 2 di depan (potong 2 karakter) //gajadi
                    // await launch("sms:" + '$_gsm?body=$_getBody');
                    await launch("sms:" +
                        '${widget.phoneNumber}?body=${getBody.replaceAll('+', '%20')}');
                  } else if (Platform.isIOS) {
                    String url =
                        'sms:${widget.phoneNumber}&body=${getFeature[0].smsOn.replaceAll(' ', '%20')}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  }
                }
              : null,
          child: Text(AppLocalizations.of(context)!.engineOnSMS,
              textAlign: TextAlign.center,
              style: bolder
                  ? bold.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )
                  : reguler.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )),
        ),
      ),
    );
  }

  Expanded _buttonEngineOffSMS(
    Color textColor,
    Color bgColor,
    Color borderColor,
    Color disabled,
    Color disabledText,
    bool bolder,
  ) {
    return Expanded(
      // width: 165,
      // height: 42,
      child: Padding(
        padding: const EdgeInsets.only(left: 1, right: 1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: disabled,
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: isDisabled ? borderColor : greyColor, width: 1),
              )),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12),
          //   side:
          //       BorderSide(color: isDisabled ? borderColor : greyColor, width: 1),
          // ),
          // disabledColor: disabled,
          // color: bgColor,
          onPressed: isDisabled
              ? () async {
                  String getBody = '';
                  getBody = Uri.encodeQueryComponent(getFeature[0].smsOff);
                  // await launch("sms:" +
                  //     '${widget.phoneNumber}?body=${getBody.replaceAll('+', '%20')}');

                  if (Platform.isAndroid) {
                    //ganti kirim ke api
                    //c20 hapus spasi 2 di depan (potong 2 karakter) //gajadi
                    // await launch("sms:" + '$_gsm?body=$_getBody');
                    await launch("sms:" +
                        '${widget.phoneNumber}?body=${getBody.replaceAll('+', '%20')}');
                  } else if (Platform.isIOS) {
                    String url =
                        'sms:${widget.phoneNumber}&body=${getFeature[0].smsOff.replaceAll(' ', '%20')}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  }
                }
              : null,
          child: Text(AppLocalizations.of(context)!.engineOffSMS,
              textAlign: TextAlign.center,
              style: bolder
                  ? bold.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )
                  : reguler.copyWith(
                      fontSize: 10,
                      color: isDisabled ? textColor : disabledText,
                    )),
        ),
      ),
    );
  }
}
