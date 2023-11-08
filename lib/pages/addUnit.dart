// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/checkgsm.model.dart';
import 'package:gpsid/model/checkimei.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/registeraccount.model.dart';
import 'package:gpsid/model/unitregister.model.dart';
import 'package:gpsid/model/vehicleiconregister.model.dart';
import 'package:gpsid/model/vehicletyperegister.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AddUnit extends StatefulWidget {
  final String ownerName;
  final bool darkMode;
  final String token;
  const AddUnit(
      {super.key,
      required this.darkMode,
      required this.token,
      required this.ownerName});

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  final TextEditingController imeiTextInput = TextEditingController();
  final TextEditingController gsmTextInput = TextEditingController();
  final TextEditingController platTextInput = TextEditingController();
  final TextEditingController vehicleNameTextInput = TextEditingController();
  final TextEditingController vehicleTypeTextInput = TextEditingController();
  final TextEditingController vehicleIconTextInput = TextEditingController();
  final TextEditingController companyEntityTextInput = TextEditingController();
  final TextEditingController companyTextInput = TextEditingController();
  final TextEditingController nameTitleTextInput = TextEditingController();
  final TextEditingController nameTextInput = TextEditingController();
  // final TextEditingController branchTextInput = TextEditingController();
  final TextEditingController phoneNumberTextInput = TextEditingController();
  final TextEditingController referralTextInput = TextEditingController();
  int step = 1;
  int stepUnit = 1;
  bool vehicleList = false;
  int customerType = 0;
  int titleSelected = 0;
  int entitySelected = 0;
  int imeiRegistered = 0;
  int gsmRegistered = 0;
  String gpsName = '';
  List<Unit> unitRegister = [];
  int vehicleType = 0;
  bool vehicleIcon = false;
  int vehicleIconID = 0;
  List<dynamic> vehicleIconList = [];
  int branchValue = 0;
  RegisterAccountModel register = RegisterAccountModel(data: [
    DataRegister(
        user: UserRegister(
            prename: '',
            fullname: '',
            branch: 0,
            customerType: 0,
            phoneNumberCode: '+62',
            phoneNumber: '',
            refferal: '',
            isAgree: 0,
            prenameco: '',
            companyName: '',
            isMobile: 1),
        unit: [
          UnitRegister(
              imei: '',
              gsmNumber: '',
              plate: '',
              vehicleName: '',
              vehicleType: 0,
              icon: 0,
              lt_warranty: 0,
              expired_gsm: '',
              simcard_id: '')
        ])
  ]);
  bool agree = false;
  bool successRegist = false;
  int ltWarranty = 0;
  String expiredGSM = '';
  String simcardId = '';

  @override
  void initState() {
    super.initState();
    checkOwnerName();
  }

  checkOwnerName() {
    setState(() {
      nameTextInput.text = widget.ownerName;
    });
  }

  addUnit() {
    unitRegister.add(Unit(
        plat: platTextInput.text,
        vehName: vehicleNameTextInput.text,
        gpsName: gpsName,
        gsmNo: gsmTextInput.text.substring(0, 3).contains('620')
            ? gsmTextInput.text.replaceRange(0, 3, '0')
            : gsmTextInput.text[0] == '8'
                ? '0${gsmTextInput.text}'
                : gsmTextInput.text[0] == '0'
                    ? gsmTextInput.text.substring(0).contains('0')
                        ? gsmTextInput.text.replaceRange(0, 1, '0')
                        : gsmTextInput.text
                    : gsmTextInput.text[0] == '+'
                        ? gsmTextInput.text.replaceRange(0, 3, '0')
                        : gsmTextInput.text[1] == '0'
                            ? gsmTextInput.text.replaceRange(0, 1, '0')
                            : gsmTextInput.text.substring(0, 2).contains('62')
                                ? gsmTextInput.text.replaceRange(0, 2, '0')
                                : gsmTextInput.text,
        imei: imeiTextInput.text,
        vehicleType: vehicleType,
        img: Img(
            accOn: vehicleIconList[0],
            park: vehicleIconList[1],
            alarm: vehicleIconList[2],
            lost: vehicleIconList[3]),
        icon: vehicleIconID,
        lt_warranty: ltWarranty,
        expired_gsm: expiredGSM,
        simcard_id: simcardId));
    setState(() {
      imeiTextInput.clear();
      gsmTextInput.clear();
      platTextInput.clear();
      vehicleNameTextInput.clear();
      vehicleTypeTextInput.clear();
      vehicleIconTextInput.clear();
      companyEntityTextInput.clear();
      companyTextInput.clear();
      nameTitleTextInput.clear();
      widget.ownerName.isEmpty
          ? nameTextInput.clear()
          : nameTextInput.text = widget.ownerName;
      // branchTextInput.clear();
      phoneNumberTextInput.clear();
      referralTextInput.clear();
      gsmRegistered = 0;
      imeiRegistered = 0;
      vehicleList = true;
      vehicleIcon = false;
      stepUnit = 1;
      ltWarranty = 0;
      expiredGSM = '';
      simcardId = '';
    });
    print(unitRegister);
    Navigator.pop(context);
  }

  registerAccount() async {
    Dialogs().loadingDialog(context);
    late List<Unit> I;
    List<UnitRegister> II = [];
    I = unitRegister;
    I.forEach((el) {
      II.addAll([
        UnitRegister(
            imei: el.imei,
            gsmNumber: el.gsmNo,
            plate: el.plat,
            vehicleName: el.vehName,
            vehicleType: el.vehicleType,
            icon: el.icon,
            lt_warranty: el.lt_warranty,
            simcard_id: el.simcard_id,
            expired_gsm: el.expired_gsm)
      ]);
    });
    register = RegisterAccountModel(data: [
      DataRegister(
          user: UserRegister(
              prename: nameTitleTextInput.text,
              fullname: nameTextInput.text,
              branch: branchValue,
              customerType: customerType,
              phoneNumberCode: '+62',
              phoneNumber: phoneNumberTextInput.text
                      .substring(0, 3)
                      .contains('620')
                  ? phoneNumberTextInput.text.replaceRange(0, 3, '0')
                  : phoneNumberTextInput.text[0] == '8'
                      ? '0${phoneNumberTextInput.text}'
                      : phoneNumberTextInput.text[0] == '0'
                          ? phoneNumberTextInput.text.substring(0).contains('0')
                              ? phoneNumberTextInput.text
                                  .replaceRange(0, 1, '0')
                              : phoneNumberTextInput.text
                          : phoneNumberTextInput.text[0] == '+'
                              ? phoneNumberTextInput.text
                                  .replaceRange(0, 3, '0')
                              : phoneNumberTextInput.text[1] == '0'
                                  ? phoneNumberTextInput.text
                                      .replaceRange(0, 1, '0')
                                  : phoneNumberTextInput.text
                                          .substring(0, 2)
                                          .contains('62')
                                      ? phoneNumberTextInput.text
                                          .replaceRange(0, 2, '0')
                                      : phoneNumberTextInput.text,
              refferal: referralTextInput.text,
              isAgree: 1,
              prenameco: customerType == 1 ? companyEntityTextInput.text : '',
              companyName: customerType == 1 ? companyTextInput.text : '',
              isMobile: 1),
          unit: II)
    ]);
    final result =
        await APIService().registerAccount(widget.token, jsonEncode(register));
    if (result is MessageModel) {
      if (result.status) {
        Dialogs().hideLoaderDialog(context);
        setState(() {
          successRegist = true;
          agree = false;
          step = 1;
          imeiTextInput.clear();
          gsmTextInput.clear();
          platTextInput.clear();
          vehicleNameTextInput.clear();
          vehicleTypeTextInput.clear();
          vehicleIconTextInput.clear();
          companyEntityTextInput.clear();
          companyTextInput.clear();
          nameTitleTextInput.clear();
          // nameTextInput.clear();
          // branchTextInput.clear();
          phoneNumberTextInput.clear();
          referralTextInput.clear();
          gsmRegistered = 0;
          imeiRegistered = 0;
          vehicleList = false;
          vehicleIcon = false;
          stepUnit = 1;
          unitRegister.clear();
          register.data.clear();
          ltWarranty = 0;
          expiredGSM = '';
          simcardId = '';
        });

        Navigator.of(context).pushReplacementNamed("/login");
        showSuccessRegister(
            context,
            AppLocalizations.of(context)!.registerSuccess,
            AppLocalizations.of(context)!.registerSuccessSub);
      } else {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.message, '');
      }
    } else {
      Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, 'Register failed', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 8,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              color: widget.darkMode ? whiteCardColor : bluePrimary),
        ),
        title: Column(
          children: [
            GestureDetector(
              onTap: () {
                // setState(() {
                //   step == 1 ? step = 2 : step = 1;
                // });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Text(
                  AppLocalizations.of(context)!.addUnit,
                  style: bold.copyWith(
                      fontSize: 16,
                      color: widget.darkMode ? whiteColorDarkMode : whiteColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: step == 1
                              ? widget.darkMode
                                  ? blueSecondary
                                  : blueSecondary
                              : widget.darkMode
                                  ? blueSecondary
                                  : blueSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 1,
                              color: step == 1
                                  ? widget.darkMode
                                      ? blueSecondary
                                      : blueSecondary
                                  : widget.darkMode
                                      ? blueSecondary
                                      : blueSecondary),
                        ),
                        height: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: step == 1
                              ? widget.darkMode
                                  ? whiteColorDarkMode
                                  : whiteColorDarkMode
                              : widget.darkMode
                                  ? blueSecondary
                                  : blueSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 1,
                              color: step == 1
                                  ? widget.darkMode
                                      ? whiteColorDarkMode
                                      : whiteColorDarkMode
                                  : widget.darkMode
                                      ? blueSecondary
                                      : blueSecondary),
                        ),
                        height: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: step == 1
          ? Container(
              color: whiteColor,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          isDismissible: false,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                          ),
                          backgroundColor: whiteColor,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return SingleChildScrollView(
                                  child: Container(
                                    padding: MediaQuery.of(context).viewInsets,
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: stepUnit == 1
                                            ? Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              height: 10,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stepUnit ==
                                                                        1
                                                                    ? widget.darkMode
                                                                        ? bluePrimary
                                                                        : bluePrimary
                                                                    : bluePrimary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: stepUnit == 1
                                                                        ? widget.darkMode
                                                                            ? bluePrimary
                                                                            : bluePrimary
                                                                        : bluePrimary),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              height: 10,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stepUnit ==
                                                                        1
                                                                    ? widget.darkMode
                                                                        ? whiteColorDarkMode
                                                                        : whiteColorDarkMode
                                                                    : bluePrimary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: stepUnit == 1
                                                                        ? widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : whiteColorDarkMode
                                                                        : bluePrimary),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .imei,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color:
                                                                      blackPrimary,
                                                                )),
                                                            Visibility(
                                                              visible: imeiTextInput
                                                                          .text
                                                                          .length >
                                                                      5
                                                                  ? true
                                                                  : false,
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (imeiTextInput
                                                                          .text
                                                                          .length >
                                                                      5) {
                                                                    Dialogs()
                                                                        .loadingDialog(
                                                                            context);
                                                                    final result = await APIService().checkImei(
                                                                        widget
                                                                            .token,
                                                                        imeiTextInput
                                                                            .text);
                                                                    if (result
                                                                        is CheckImeiModel) {
                                                                      Dialogs()
                                                                          .hideLoaderDialog(
                                                                              context);
                                                                      if (result
                                                                          .status) {
                                                                        setState(
                                                                            () {
                                                                          imeiRegistered =
                                                                              1;
                                                                          gpsName =
                                                                              '${result.data[0].typeGps} ${result.data[0].name}';
                                                                          branchValue = result
                                                                              .data[0]
                                                                              .branchID;
                                                                          ltWarranty = result
                                                                              .data[0]
                                                                              .lt_warranty;
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          imeiRegistered =
                                                                              2;
                                                                        });
                                                                      }
                                                                    } else if (result
                                                                        is MessageModel) {
                                                                      Dialogs()
                                                                          .hideLoaderDialog(
                                                                              context);
                                                                      setState(
                                                                          () {
                                                                        imeiRegistered =
                                                                            2;
                                                                      });
                                                                    }
                                                                  } else {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                    showInfoAlert(
                                                                        context,
                                                                        AppLocalizations.of(context)!
                                                                            .pleaseCheckIMEI,
                                                                        '');
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        greenPrimary,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(4),
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            greenPrimary),
                                                                  ),
                                                                  child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .checkIMEI,
                                                                      style: reguler
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            greenSecondary,
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                        .length >
                                                                    5) {
                                                                  setState(
                                                                      () {});
                                                                } else {
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                              controller:
                                                                  imeiTextInput,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    whiteCardColor,
                                                                hintText:
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .imei,
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
                                                                enabled: true,
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
                                                                    color:
                                                                        blueGradient,
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
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              imeiRegistered ==
                                                                      0
                                                                  ? false
                                                                  : true,
                                                          child: Text(
                                                              imeiRegistered ==
                                                                      1
                                                                  ? '• ${AppLocalizations.of(context)!.imeiRegistered}'
                                                                  : '• ${AppLocalizations.of(context)!.imeiNotRegistered}',
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 12,
                                                                color: imeiRegistered ==
                                                                        1
                                                                    ? greenPrimary
                                                                    : redPrimary,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .gsmNumber,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color:
                                                                      blackPrimary,
                                                                )),
                                                            Visibility(
                                                              visible: gsmTextInput
                                                                          .text
                                                                          .length >
                                                                      9
                                                                  ? true
                                                                  : false,
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (gsmTextInput
                                                                          .text
                                                                          .length >
                                                                      9) {
                                                                    Dialogs()
                                                                        .loadingDialog(
                                                                            context);
                                                                    final result = await APIService().checkGSM(
                                                                        widget.token,
                                                                        // phoneNumberTextInput.text
                                                                        gsmTextInput.text.substring(0, 3).contains('620')
                                                                            ? gsmTextInput.text.replaceRange(0, 3, '0')
                                                                            : gsmTextInput.text[0] == '8'
                                                                                ? '0${gsmTextInput.text}'
                                                                                : gsmTextInput.text[0] == '0'
                                                                                    ? gsmTextInput.text.substring(0).contains('0')
                                                                                        ? gsmTextInput.text.replaceRange(0, 1, '0')
                                                                                        : gsmTextInput.text
                                                                                    : gsmTextInput.text[0] == '+'
                                                                                        ? gsmTextInput.text.replaceRange(0, 3, '0')
                                                                                        : gsmTextInput.text[1] == '0'
                                                                                            ? gsmTextInput.text.replaceRange(0, 1, '0')
                                                                                            : gsmTextInput.text.substring(0, 2).contains('62')
                                                                                                ? gsmTextInput.text.replaceRange(0, 2, '0')
                                                                                                : gsmTextInput.text);
                                                                    if (result
                                                                        is CheckGSMModel) {
                                                                      Dialogs()
                                                                          .hideLoaderDialog(
                                                                              context);
                                                                      setState(
                                                                          () {
                                                                        gsmRegistered =
                                                                            1;
                                                                        expiredGSM = result
                                                                            .data
                                                                            .expired;
                                                                        simcardId = result
                                                                            .data
                                                                            .simcardId;
                                                                      });
                                                                      // if (result
                                                                      //     .status) {
                                                                      //   setState(
                                                                      //       () {
                                                                      //     gsmRegistered =
                                                                      //         1;
                                                                      //   });
                                                                      // } else {
                                                                      //   setState(
                                                                      //       () {
                                                                      //     gsmRegistered =
                                                                      //         2;
                                                                      //   });
                                                                      // }
                                                                    } else if (result
                                                                        is MessageModel) {
                                                                      Dialogs()
                                                                          .hideLoaderDialog(
                                                                              context);
                                                                      showInfoAlert(
                                                                          context,
                                                                          result
                                                                              .message,
                                                                          '');
                                                                    } else {
                                                                      if (result
                                                                          is ErrorTrapModel) {
                                                                        Dialogs()
                                                                            .hideLoaderDialog(context);
                                                                        showInfoAlert(
                                                                            context,
                                                                            result.statusError,
                                                                            '');
                                                                      }
                                                                    }
                                                                  } else {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                    showInfoAlert(
                                                                        context,
                                                                        AppLocalizations.of(context)!
                                                                            .pleaseCheckGSM,
                                                                        '');
                                                                  }
                                                                  print(
                                                                      'GSM: ${gsmTextInput.text.substring(0, 3).contains('620') ? gsmTextInput.text.replaceRange(0, 3, '0') : gsmTextInput.text[0] == '8' ? '0${gsmTextInput.text}' : gsmTextInput.text[0] == '0' ? gsmTextInput.text.substring(0).contains('0') ? gsmTextInput.text.replaceRange(0, 1, '0') : gsmTextInput.text : gsmTextInput.text[0] == '+' ? gsmTextInput.text.replaceRange(0, 3, '0') : gsmTextInput.text[1] == '0' ? gsmTextInput.text.replaceRange(0, 1, '0') : gsmTextInput.text.substring(0, 2).contains('62') ? gsmTextInput.text.replaceRange(0, 2, '0') : gsmTextInput.text}');
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        greenPrimary,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(4),
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            greenPrimary),
                                                                  ),
                                                                  child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .checkGSM,
                                                                      style: reguler
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            greenSecondary,
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              // onChanged: (value) {
                                                              //   value != currEmail
                                                              //       ? setState(
                                                              //           () {
                                                              //             currentEmail = false;
                                                              //           },
                                                              //         )
                                                              //       : setState(
                                                              //           () {
                                                              //             currentEmail = true;
                                                              //           },
                                                              //         );
                                                              // },
                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                        .length >
                                                                    9) {
                                                                  setState(
                                                                      () {});
                                                                } else {
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                              controller:
                                                                  gsmTextInput,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    whiteCardColor,
                                                                hintText: AppLocalizations.of(
                                                                        context)!
                                                                    .gsmNumber,
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
                                                                enabled: true,
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
                                                                    color:
                                                                        blueGradient,
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
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              gsmRegistered == 0
                                                                  ? false
                                                                  : true,
                                                          child: Text(
                                                              gsmRegistered == 1
                                                                  ? '• ${AppLocalizations.of(context)!.gsmRegistered}'
                                                                  : '• ${AppLocalizations.of(context)!.gsmNotRegistered}',
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 12,
                                                                color: gsmRegistered ==
                                                                        1
                                                                    ? greenPrimary
                                                                    : redPrimary,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .licensePlate,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  blackPrimary,
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              // onChanged: (value) {
                                                              //   value != currEmail
                                                              //       ? setState(
                                                              //           () {
                                                              //             currentEmail = false;
                                                              //           },
                                                              //         )
                                                              //       : setState(
                                                              //           () {
                                                              //             currentEmail = true;
                                                              //           },
                                                              //         );
                                                              // },
                                                              controller:
                                                                  platTextInput,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    whiteCardColor,
                                                                hintText: AppLocalizations.of(
                                                                        context)!
                                                                    .licensePlate,
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
                                                                enabled: true,
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
                                                                    color:
                                                                        blueGradient,
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
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            imeiTextInput
                                                                .clear();
                                                            gsmTextInput
                                                                .clear();
                                                            platTextInput
                                                                .clear();
                                                            vehicleNameTextInput
                                                                .clear();
                                                            vehicleTypeTextInput
                                                                .clear();
                                                            vehicleIconTextInput
                                                                .clear();
                                                            companyEntityTextInput
                                                                .clear();
                                                            companyTextInput
                                                                .clear();
                                                            nameTitleTextInput
                                                                .clear();
                                                            nameTextInput
                                                                .clear();
                                                            // branchTextInput
                                                            //     .clear();
                                                            phoneNumberTextInput
                                                                .clear();
                                                            referralTextInput
                                                                .clear();
                                                            setState(() {
                                                              gsmRegistered = 0;
                                                              imeiRegistered =
                                                                  0;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3.3,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        bluePrimary),
                                                              ),
                                                              // height: 10,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .cancel,
                                                                      style: reguler.copyWith(
                                                                          color:
                                                                              bluePrimary,
                                                                          fontSize:
                                                                              14),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (imeiRegistered == 1 &&
                                                                gsmRegistered ==
                                                                    1 &&
                                                                platTextInput
                                                                    .text
                                                                    .isNotEmpty) {
                                                              setState(
                                                                () {
                                                                  stepUnit == 1
                                                                      ? stepUnit =
                                                                          2
                                                                      : stepUnit =
                                                                          1;
                                                                },
                                                              );
                                                            } else {
                                                              showInfoAlert(
                                                                  context,
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .dataIncomplete,
                                                                  '');
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    greenPrimary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        greenPrimary),
                                                              ),
                                                              // height: 10,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .next,
                                                                      style: reguler.copyWith(
                                                                          color:
                                                                              whiteColorDarkMode,
                                                                          fontSize:
                                                                              14),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              height: 10,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stepUnit ==
                                                                        1
                                                                    ? widget.darkMode
                                                                        ? bluePrimary
                                                                        : bluePrimary
                                                                    : bluePrimary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: stepUnit == 1
                                                                        ? widget.darkMode
                                                                            ? bluePrimary
                                                                            : bluePrimary
                                                                        : bluePrimary),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              height: 10,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stepUnit ==
                                                                        1
                                                                    ? widget.darkMode
                                                                        ? whiteColorDarkMode
                                                                        : whiteColorDarkMode
                                                                    : bluePrimary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: stepUnit == 1
                                                                        ? widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : whiteColorDarkMode
                                                                        : bluePrimary),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .vehicleName,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  blackPrimary,
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              // onChanged: (value) {
                                                              //   value != currEmail
                                                              //       ? setState(
                                                              //           () {
                                                              //             currentEmail = false;
                                                              //           },
                                                              //         )
                                                              //       : setState(
                                                              //           () {
                                                              //             currentEmail = true;
                                                              //           },
                                                              //         );
                                                              // },
                                                              controller:
                                                                  vehicleNameTextInput,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    whiteCardColor,
                                                                hintText: AppLocalizations.of(
                                                                        context)!
                                                                    .insertVehicleName,
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
                                                                enabled: true,
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
                                                                    color:
                                                                        blueGradient,
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
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .vehicleType,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  blackPrimary,
                                                            )),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            Dialogs()
                                                                .loadingDialog(
                                                                    context);
                                                            final result =
                                                                await APIService()
                                                                    .vehicleTypeRegister(
                                                                        widget
                                                                            .token);
                                                            print(result);
                                                            if (result
                                                                is VehicleTypeRegisterModel) {
                                                              Dialogs()
                                                                  .hideLoaderDialog(
                                                                      context);
                                                              showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    whiteCardColor,
                                                                context:
                                                                    context,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              12),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              12)),
                                                                ),
                                                                builder:
                                                                    (context) {
                                                                  return StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                      return SizedBox(
                                                                        height: MediaQuery.of(context).size.height /
                                                                            3.5,
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          scrollDirection:
                                                                              Axis.vertical,
                                                                          physics:
                                                                              const BouncingScrollPhysics(),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                            child:
                                                                                ListView.builder(
                                                                              itemCount: result.data.length,
                                                                              physics: const BouncingScrollPhysics(),
                                                                              shrinkWrap: true,
                                                                              itemBuilder: (context, index) {
                                                                                return GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      vehicleType = result.data[index].value;
                                                                                      vehicleTypeTextInput.text = result.data[index].title;
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                    print(vehicleType);
                                                                                  },
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          // Text(
                                                                                          //   '${index + 1}.',
                                                                                          //   style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1, fontSize: 12),
                                                                                          // ),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.symmetric(vertical: 15),
                                                                                            child: Text(
                                                                                              result.data[index].title,
                                                                                              style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1, fontSize: 12),
                                                                                              textAlign: TextAlign.center,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      Divider(
                                                                                        height: 1,
                                                                                        thickness: 0.5,
                                                                                        indent: 0,
                                                                                        endIndent: 0,
                                                                                        color: widget.darkMode ? whiteColorDarkMode : greyColorSecondary,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            } else if (result
                                                                is MessageModel) {
                                                              Dialogs()
                                                                  .hideLoaderDialog(
                                                                      context);
                                                            } else {
                                                              Dialogs()
                                                                  .hideLoaderDialog(
                                                                      context);
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8),
                                                            child: SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    vehicleTypeTextInput,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 13,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                                decoration:
                                                                    InputDecoration(
                                                                  filled: true,
                                                                  fillColor:
                                                                      whiteCardColor,
                                                                  hintText: AppLocalizations.of(
                                                                          context)!
                                                                      .chooseVehicleType,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  suffixIcon:
                                                                      Icon(
                                                                    Icons
                                                                        .keyboard_arrow_down_outlined,
                                                                    color:
                                                                        blackPrimary,
                                                                  ),
                                                                  enabled:
                                                                      false,
                                                                  disabledBorder:
                                                                      UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      width: 1,
                                                                      color:
                                                                          blackPrimary,
                                                                    ),
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
                                                                      color:
                                                                          blueGradient,
                                                                    ),
                                                                  ),
                                                                  hintStyle: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  ),
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 9),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .vehicleIcon,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  blackPrimary,
                                                            )),
                                                        vehicleIcon
                                                            ? GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  Dialogs()
                                                                      .loadingDialog(
                                                                          context);
                                                                  final result =
                                                                      await APIService().vehicleIconRegister(
                                                                          widget
                                                                              .token,
                                                                          vehicleType);
                                                                  print(result);
                                                                  if (result
                                                                      is VehicleIconRegisterModel) {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                    showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          whiteCardColor,
                                                                      context:
                                                                          context,
                                                                      shape:
                                                                          const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(12),
                                                                            topRight: Radius.circular(12)),
                                                                      ),
                                                                      builder:
                                                                          (context) {
                                                                        return StatefulBuilder(
                                                                          builder:
                                                                              (context, setStateModal) {
                                                                            return SizedBox(
                                                                              height: MediaQuery.of(context).size.height / 3.5,
                                                                              child: SingleChildScrollView(
                                                                                scrollDirection: Axis.vertical,
                                                                                physics: const BouncingScrollPhysics(),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                                  child: ListView.builder(
                                                                                    itemCount: result.data.length,
                                                                                    physics: const BouncingScrollPhysics(),
                                                                                    shrinkWrap: true,
                                                                                    itemBuilder: (context, index) {
                                                                                      return Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              // Text(
                                                                                              //   '${index + 1}.',
                                                                                              //   style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1, fontSize: 12),
                                                                                              // ),
                                                                                              GestureDetector(
                                                                                                onTap: () {
                                                                                                  // setState(() {
                                                                                                  //   vehicleType = result.data[index].value;
                                                                                                  //   vehicleTypeTextInput.text = result.data[index].title;
                                                                                                  // });
                                                                                                  // Navigator.pop(context);
                                                                                                  // print(vehicleType);
                                                                                                  setState(() {
                                                                                                    vehicleIconList.isNotEmpty ? vehicleIconList.clear() : {};
                                                                                                    vehicleIconList.addAll([
                                                                                                      result.data[index].accOn,
                                                                                                      result.data[index].parking,
                                                                                                      result.data[index].alarm,
                                                                                                      result.data[index].lost
                                                                                                    ]);
                                                                                                    vehicleIconID = result.data[index].value;
                                                                                                    print(vehicleIconID);
                                                                                                    vehicleIcon = true;
                                                                                                    Navigator.pop(context);
                                                                                                  });
                                                                                                },
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Image.network(
                                                                                                        result.data[index].accOn,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                      Image.network(
                                                                                                        result.data[index].parking,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                      Image.network(
                                                                                                        result.data[index].alarm,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                      Image.network(
                                                                                                        result.data[index].lost,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          Divider(
                                                                                            height: 1,
                                                                                            thickness: 0.5,
                                                                                            indent: 0,
                                                                                            endIndent: 0,
                                                                                            color: widget.darkMode ? whiteColorDarkMode : greyColorSecondary,
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    );
                                                                  } else if (result
                                                                      is MessageModel) {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                    showInfoAlert(
                                                                        context,
                                                                        result
                                                                            .message,
                                                                        '');
                                                                  } else {
                                                                    Dialogs()
                                                                        .hideLoaderDialog(
                                                                            context);
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          whiteCardColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                      // border: Border.all(
                                                                      //     width: 1,
                                                                      //     color: bluePrimary),
                                                                    ),
                                                                    height: 40,
                                                                    child: ListView
                                                                        .builder(
                                                                      itemCount:
                                                                          vehicleIconList
                                                                              .length,
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return Row(
                                                                          children: [
                                                                            Image.network(
                                                                              vehicleIconList[index],
                                                                              width: 35,
                                                                              height: 35,
                                                                            ),
                                                                            // Image.network(
                                                                            //   vehicleIconList[1],
                                                                            //   width: 30,
                                                                            //   height: 30,
                                                                            // ),
                                                                            // Image.network(
                                                                            //   vehicleIconList[2],
                                                                            //   width: 30,
                                                                            //   height: 30,
                                                                            // ),
                                                                            // Image.network(
                                                                            //   vehicleIconList[3],
                                                                            //   width: 30,
                                                                            //   height: 30,
                                                                            // ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  final result =
                                                                      await APIService().vehicleIconRegister(
                                                                          widget
                                                                              .token,
                                                                          vehicleType);
                                                                  print(result);
                                                                  if (result
                                                                      is VehicleIconRegisterModel) {
                                                                    showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          whiteCardColor,
                                                                      context:
                                                                          context,
                                                                      shape:
                                                                          const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(12),
                                                                            topRight: Radius.circular(12)),
                                                                      ),
                                                                      builder:
                                                                          (context) {
                                                                        return StatefulBuilder(
                                                                          builder:
                                                                              (context, setStateModal) {
                                                                            return SizedBox(
                                                                              height: MediaQuery.of(context).size.height / 3.5,
                                                                              child: SingleChildScrollView(
                                                                                scrollDirection: Axis.vertical,
                                                                                physics: const BouncingScrollPhysics(),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                                  child: ListView.builder(
                                                                                    itemCount: result.data.length,
                                                                                    physics: const BouncingScrollPhysics(),
                                                                                    shrinkWrap: true,
                                                                                    itemBuilder: (context, index) {
                                                                                      return Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              // Text(
                                                                                              //   '${index + 1}.',
                                                                                              //   style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary1, fontSize: 12),
                                                                                              // ),
                                                                                              GestureDetector(
                                                                                                onTap: () {
                                                                                                  // setState(() {
                                                                                                  //   vehicleType = result.data[index].value;
                                                                                                  //   vehicleTypeTextInput.text = result.data[index].title;
                                                                                                  // });
                                                                                                  // Navigator.pop(context);
                                                                                                  // print(vehicleType);
                                                                                                  setState(() {
                                                                                                    vehicleIconList.isNotEmpty ? vehicleIconList.clear() : {};
                                                                                                    vehicleIconList.addAll([
                                                                                                      result.data[index].accOn,
                                                                                                      result.data[index].parking,
                                                                                                      result.data[index].alarm,
                                                                                                      result.data[index].lost
                                                                                                    ]);
                                                                                                    vehicleIcon = true;
                                                                                                    vehicleIconID = result.data[index].value;
                                                                                                    print(vehicleIconID);
                                                                                                    Navigator.pop(context);
                                                                                                  });
                                                                                                },
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Image.network(
                                                                                                        result.data[index].accOn,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                      Image.network(
                                                                                                        result.data[index].parking,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                      Image.network(
                                                                                                        result.data[index].alarm,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                      Image.network(
                                                                                                        result.data[index].lost,
                                                                                                        width: 50,
                                                                                                        height: 50,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          Divider(
                                                                                            height: 1,
                                                                                            thickness: 0.5,
                                                                                            indent: 0,
                                                                                            endIndent: 0,
                                                                                            color: widget.darkMode ? whiteColorDarkMode : greyColorSecondary,
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          whiteCardColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                      // border: Border.all(
                                                                      //     width: 1,
                                                                      //     color: bluePrimary),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            // Row(
                                                                            //     children: [
                                                                            //       Image.network(
                                                                            //         'https://img.gps.id/dev-seen/vehicle/acc_on_20230321135812.png',
                                                                            //         width: 30,
                                                                            //         height: 30,
                                                                            //       ),
                                                                            //       Image.network(
                                                                            //         'https://img.gps.id/dev-seen/vehicle/parking_20230321135812.png',
                                                                            //         width: 30,
                                                                            //         height: 30,
                                                                            //       ),
                                                                            //       Image.network(
                                                                            //         'https://img.gps.id/dev-seen/vehicle/lost_20230321135812.png',
                                                                            //         width: 30,
                                                                            //         height: 30,
                                                                            //       ),
                                                                            //       Image.network(
                                                                            //         'https://img.gps.id/dev-seen/vehicle/alarm_20230321135812.png',
                                                                            //         width: 30,
                                                                            //         height: 30,
                                                                            //       ),
                                                                            //     ],
                                                                            //   )
                                                                            Text(AppLocalizations.of(context)!.chooseVehicleIcon,
                                                                                style: reguler.copyWith(
                                                                                  fontSize: 13,
                                                                                  color: blackPrimary,
                                                                                )),
                                                                            Icon(
                                                                              Icons.keyboard_arrow_down_outlined,
                                                                              color: blackPrimary,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3.3,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        bluePrimary),
                                                              ),
                                                              // height: 10,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .cancel,
                                                                      style: reguler.copyWith(
                                                                          color:
                                                                              bluePrimary,
                                                                          fontSize:
                                                                              14),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            // setState(
                                                            //   () {
                                                            //     stepUnit == 1
                                                            //         ? stepUnit =
                                                            //             2
                                                            //         : stepUnit =
                                                            //             1;
                                                            //   },
                                                            // );
                                                            addUnit();
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    greenPrimary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        greenPrimary),
                                                              ),
                                                              // height: 10,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .save,
                                                                      style: reguler.copyWith(
                                                                          color:
                                                                              whiteColorDarkMode,
                                                                          fontSize:
                                                                              14),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(width: 1, color: bluePrimary),
                        ),
                        // height: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+ ',
                                style: reguler.copyWith(
                                    color: bluePrimary, fontSize: 14),
                              ),
                              Text(
                                AppLocalizations.of(context)!.addUnit,
                                style: reguler.copyWith(
                                    color: bluePrimary, fontSize: 14),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: vehicleList,
                        child: Expanded(
                          // height: MediaQuery.of(context).size.height / 3.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              color: whiteColor,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  child: ListView.builder(
                                    itemCount: unitRegister.length,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 15),
                                        decoration: BoxDecoration(
                                          color: widget.darkMode
                                              ? whiteCardColor
                                              : whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              width: 1, color: bluePrimary),
                                        ),
                                        // height: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 50,
                                                    child: Image.network(
                                                      unitRegister[index]
                                                          .img
                                                          .accOn,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          unitRegister[index]
                                                              .plat,
                                                          style: bold.copyWith(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary1,
                                                              fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Text(
                                                          unitRegister[index]
                                                              .vehName,
                                                          style: bold.copyWith(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary1,
                                                              fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: blueSecondary
                                                              .withOpacity(0.3),
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  bluePrimary),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 2),
                                                        child: Text(
                                                          unitRegister[index]
                                                              .gpsName,
                                                          style: bold.copyWith(
                                                              color:
                                                                  bluePrimary,
                                                              fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: Divider(
                                                  height: 1,
                                                  thickness: 0.5,
                                                  indent: 0,
                                                  endIndent: 0,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary3,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .gsmnumber,
                                                        style: reguler.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      Text(
                                                        unitRegister[index]
                                                            .gsmNo,
                                                        style: bold.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .imei,
                                                        style: reguler.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      Text(
                                                        unitRegister[index]
                                                            .imei,
                                                        style: bold.copyWith(
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      unitRegister.removeWhere(
                                                          (el) =>
                                                              el.imei ==
                                                                  unitRegister[
                                                                          index]
                                                                      .imei ||
                                                              el.gsmNo ==
                                                                  unitRegister[
                                                                          index]
                                                                      .gsmNo);
                                                      print(unitRegister);
                                                      if (unitRegister
                                                          .isEmpty) {
                                                        setState(() {
                                                          vehicleList = false;
                                                        });
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.delete_outlined,
                                                      color: bluePrimary,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                    Visibility(
                      visible: !vehicleList,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Image.asset(
                              'assets/handling/runningreport_empty.png',
                              width: 200,
                              height: 200,
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                AppLocalizations.of(context)!.unitRegister,
                                style: reguler.copyWith(
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackSecondary3,
                                    fontSize: 14),
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (vehicleList) {
                          setState(() {
                            step = 2;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: vehicleList ? greenPrimary : greyColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: vehicleList ? greenPrimary : greyColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.next,
                                  style: reguler.copyWith(
                                      color: whiteColorDarkMode, fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              color: whiteColor,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.customerType,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          customerType = 0;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // color:
                                            //     bluePrimary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                width: 1,
                                                color: customerType == 0
                                                    ? bluePrimary
                                                    : widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : greyColor),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .individual,
                                                  style: reguler.copyWith(
                                                      color: customerType == 0
                                                          ? bluePrimary
                                                          : widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : greyColor,
                                                      fontSize: 14),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          customerType = 1;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // color:
                                            //     bluePrimary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                width: 1,
                                                color: customerType == 1
                                                    ? bluePrimary
                                                    : widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : greyColor),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .company,
                                                  style: reguler.copyWith(
                                                      color: customerType == 1
                                                          ? bluePrimary
                                                          : widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : greyColor,
                                                      fontSize: 14),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: customerType == 1 ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.companyName,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
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
                                            builder: (context, setState) {
                                              return SingleChildScrollView(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5,
                                                      horizontal: 15),
                                                  child: Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 1;
                                                            companyEntityTextInput
                                                                .text = 'PT';
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
                                                              'PT',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          1
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
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
                                                        color:
                                                            greyColorSecondary,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 2;
                                                            companyEntityTextInput
                                                                .text = 'CV';
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                          // await prefs.setBool(
                                                          //     'darkmode', true);
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
                                                              'CV',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          2
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
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
                                                        color:
                                                            greyColorSecondary,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 3;
                                                            companyEntityTextInput
                                                                .text = 'TBK';
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
                                                              'TBK',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          3
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
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
                                                        color:
                                                            greyColorSecondary,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 4;
                                                            companyEntityTextInput
                                                                .text = 'Corp';
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
                                                              'Corp',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          4
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
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
                                                        color:
                                                            greyColorSecondary,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 5;
                                                            companyEntityTextInput
                                                                .text = 'Inc';
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
                                                              'Inc',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          5
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
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
                                                        color:
                                                            greyColorSecondary,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 6;
                                                            companyEntityTextInput
                                                                .text = 'UD';
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
                                                              'UD',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          6
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
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
                                                        color:
                                                            greyColorSecondary,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            entitySelected = 7;
                                                            companyEntityTextInput
                                                                .text = 'Ltd';
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
                                                              'Ltd',
                                                              style: reguler.copyWith(
                                                                  color: entitySelected ==
                                                                          7
                                                                      ? bluePrimary
                                                                      : blackPrimary),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Divider(
                                                      //   height: 1,
                                                      //   thickness: 1,
                                                      //   indent: 0,
                                                      //   endIndent: 0,
                                                      //   color:
                                                      //       greyColorSecondary,
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        controller: companyEntityTextInput,
                                        keyboardType: TextInputType.text,
                                        style: reguler.copyWith(
                                          fontSize: 13,
                                          color: blackPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: whiteCardColor,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .entity,
                                          suffixIcon: Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            color: blackPrimary,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabled: false,
                                          disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: blackPrimary,
                                            ),
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
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: TextFormField(
                                        controller: companyTextInput,
                                        keyboardType: TextInputType.text,
                                        style: reguler.copyWith(
                                          fontSize: 13,
                                          color: blackPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: whiteCardColor,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .inputCompanyName,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabled: true,
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
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.ownerName,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                )),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
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
                                          builder: (context, setState) {
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
                                                          titleSelected = 1;
                                                          nameTitleTextInput
                                                                  .text =
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .mr;
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
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .mr,
                                                            style: reguler.copyWith(
                                                                color: titleSelected ==
                                                                        1
                                                                    ? bluePrimary
                                                                    : blackPrimary),
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
                                                          titleSelected = 2;
                                                          nameTitleTextInput
                                                                  .text =
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .mrs;
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                        // await prefs.setBool(
                                                        //     'darkmode', true);
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
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .mrs,
                                                            style: reguler.copyWith(
                                                                color: titleSelected ==
                                                                        2
                                                                    ? bluePrimary
                                                                    : blackPrimary),
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
                                                          titleSelected = 3;
                                                          nameTitleTextInput
                                                                  .text =
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .ms;
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                        // await prefs.setBool(
                                                        //     'darkmode', true);
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
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .ms,
                                                            style: reguler.copyWith(
                                                                color: titleSelected ==
                                                                        3
                                                                    ? bluePrimary
                                                                    : blackPrimary),
                                                            textAlign: TextAlign
                                                                .center,
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
                                    );
                                  },
                                  child: SizedBox(
                                    width: 120,
                                    child: TextFormField(
                                      controller: nameTitleTextInput,
                                      keyboardType: TextInputType.text,
                                      style: reguler.copyWith(
                                        fontSize: 13,
                                        color: blackPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: whiteCardColor,
                                        hintText:
                                            AppLocalizations.of(context)!.title,
                                        suffixIcon: Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: blackPrimary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabled: false,
                                        disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: blackPrimary,
                                          ),
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
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: TextFormField(
                                      controller: nameTextInput,
                                      keyboardType: TextInputType.text,
                                      style: reguler.copyWith(
                                        fontSize: 13,
                                        color: blackPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: whiteCardColor,
                                        hintText: widget.ownerName.isNotEmpty
                                            ? widget.ownerName
                                            : AppLocalizations.of(context)!
                                                .insertName,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabled: widget.ownerName.isNotEmpty
                                            ? false
                                            : true,
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
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(AppLocalizations.of(context)!.branch,
                      //           style: bold.copyWith(
                      //             fontSize: 14,
                      //             color: blackPrimary,
                      //           )),
                      //       GestureDetector(
                      //         onTap: () async {
                      //           final result = await APIService()
                      //               .branchRegister(widget.token);
                      //           print(result);
                      //           if (result is BranchRegisterModel) {
                      //             showModalBottomSheet(
                      //               isScrollControlled: true,
                      //               backgroundColor: whiteCardColor,
                      //               context: context,
                      //               shape: const RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.only(
                      //                     topLeft: Radius.circular(12),
                      //                     topRight: Radius.circular(12)),
                      //               ),
                      //               builder: (context) {
                      //                 return StatefulBuilder(
                      //                   builder: (context, setState) {
                      //                     return SizedBox(
                      //                       height: MediaQuery.of(context)
                      //                               .size
                      //                               .height /
                      //                           3.5,
                      //                       child: SingleChildScrollView(
                      //                         scrollDirection: Axis.vertical,
                      //                         physics:
                      //                             const BouncingScrollPhysics(),
                      //                         child: Padding(
                      //                           padding:
                      //                               const EdgeInsets.symmetric(
                      //                                   vertical: 10,
                      //                                   horizontal: 15),
                      //                           child: ListView.builder(
                      //                             itemCount: result.data.length,
                      //                             physics:
                      //                                 const BouncingScrollPhysics(),
                      //                             shrinkWrap: true,
                      //                             itemBuilder:
                      //                                 (context, index) {
                      //                               return GestureDetector(
                      //                                 onTap: () {
                      //                                   setState(() {
                      //                                     // vehicleType = result
                      //                                     //     .data[index]
                      //                                     //     .value;
                      //                                     // vehicleTypeTextInput
                      //                                     //         .text =
                      //                                     //     result.data[index]
                      //                                     //         .title;
                      //                                     branchTextInput.text =
                      //                                         result.data[index]
                      //                                             .name;
                      //                                     branchValue = result
                      //                                         .data[index].id;
                      //                                   });
                      //                                   Navigator.pop(context);
                      //                                   print(vehicleType);
                      //                                 },
                      //                                 child: Padding(
                      //                                   padding:
                      //                                       const EdgeInsets
                      //                                               .only(
                      //                                           bottom: 15),
                      //                                   child: Column(
                      //                                     crossAxisAlignment:
                      //                                         CrossAxisAlignment
                      //                                             .start,
                      //                                     children: [
                      //                                       Padding(
                      //                                         padding:
                      //                                             const EdgeInsets
                      //                                                     .symmetric(
                      //                                                 vertical:
                      //                                                     5),
                      //                                         child: Text(
                      //                                           result
                      //                                               .data[index]
                      //                                               .name,
                      //                                           style: reguler.copyWith(
                      //                                               color: widget
                      //                                                       .darkMode
                      //                                                   ? whiteColorDarkMode
                      //                                                   : blackSecondary1,
                      //                                               fontSize:
                      //                                                   12),
                      //                                           textAlign:
                      //                                               TextAlign
                      //                                                   .start,
                      //                                         ),
                      //                                       ),
                      //                                       Padding(
                      //                                         padding:
                      //                                             const EdgeInsets
                      //                                                     .symmetric(
                      //                                                 vertical:
                      //                                                     5),
                      //                                         child: Text(
                      //                                           result
                      //                                               .data[index]
                      //                                               .address,
                      //                                           style: reguler.copyWith(
                      //                                               color: widget
                      //                                                       .darkMode
                      //                                                   ? whiteColorDarkMode
                      //                                                   : blackSecondary1,
                      //                                               fontSize:
                      //                                                   12),
                      //                                           textAlign:
                      //                                               TextAlign
                      //                                                   .start,
                      //                                         ),
                      //                                       ),
                      //                                       Divider(
                      //                                         height: 1,
                      //                                         thickness: 0.5,
                      //                                         indent: 0,
                      //                                         endIndent: 0,
                      //                                         color: widget
                      //                                                 .darkMode
                      //                                             ? whiteColorDarkMode
                      //                                             : greyColorSecondary,
                      //                                       ),
                      //                                     ],
                      //                                   ),
                      //                                 ),

                      //                                 // Column(
                      //                                 //   crossAxisAlignment:
                      //                                 //       CrossAxisAlignment
                      //                                 //           .start,
                      //                                 //   children: [

                      //                                 //     Padding(
                      //                                 //       padding:
                      //                                 //           const EdgeInsets
                      //                                 //                   .symmetric(
                      //                                 //               vertical:
                      //                                 //                   15),
                      //                                 //       child: Text(
                      //                                 //         result.data[index]
                      //                                 //             .address,
                      //                                 //         style: reguler.copyWith(
                      //                                 //             color: widget
                      //                                 //                     .darkMode
                      //                                 //                 ? whiteColorDarkMode
                      //                                 //                 : blackSecondary1,
                      //                                 //             fontSize: 12),
                      //                                 //         textAlign:
                      //                                 //             TextAlign
                      //                                 //                 .start,
                      //                                 //       ),
                      //                                 //     ),
                      //                                 //     Divider(
                      //                                 //       height: 1,
                      //                                 //       thickness: 0.5,
                      //                                 //       indent: 0,
                      //                                 //       endIndent: 0,
                      //                                 //       color: widget
                      //                                 //               .darkMode
                      //                                 //           ? whiteColorDarkMode
                      //                                 //           : greyColorSecondary,
                      //                                 //     ),
                      //                                 //   ],
                      //                                 // ),
                      //                               );
                      //                             },
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     );
                      //                   },
                      //                 );
                      //               },
                      //             );
                      //           }
                      //         },
                      //         child: SizedBox(
                      //           width: double.infinity,
                      //           child: TextFormField(
                      //             controller: branchTextInput,
                      //             keyboardType: TextInputType.text,
                      //             style: reguler.copyWith(
                      //               fontSize: 13,
                      //               color: blackPrimary,
                      //             ),
                      //             decoration: InputDecoration(
                      //               filled: true,
                      //               fillColor: whiteCardColor,
                      //               hintText:
                      //                   AppLocalizations.of(context)!.branch,
                      //               suffixIcon: Icon(
                      //                 Icons.keyboard_arrow_down_outlined,
                      //                 color: blackPrimary,
                      //               ),
                      //               border: OutlineInputBorder(
                      //                 borderRadius: BorderRadius.circular(5),
                      //                 borderSide: BorderSide.none,
                      //               ),
                      //               enabled: false,
                      //               disabledBorder: UnderlineInputBorder(
                      //                 borderSide: BorderSide(
                      //                   width: 1,
                      //                   color: blackPrimary,
                      //                 ),
                      //               ),
                      //               enabledBorder: UnderlineInputBorder(
                      //                 borderSide: BorderSide(
                      //                   width: 1,
                      //                   color: blackPrimary,
                      //                 ),
                      //               ),
                      //               focusedBorder: UnderlineInputBorder(
                      //                 borderSide: BorderSide(
                      //                   width: 3,
                      //                   color: blueGradient,
                      //                 ),
                      //               ),
                      //               hintStyle: reguler.copyWith(
                      //                 fontSize: 12,
                      //                 color: widget.darkMode
                      //                     ? whiteColorDarkMode
                      //                     : blackSecondary3,
                      //               ),
                      //               contentPadding: const EdgeInsets.symmetric(
                      //                 vertical: 12,
                      //                 horizontal: 20,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.phoneNumber,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                )),
                            Row(
                              children: [
                                SizedBox(
                                  width: 95,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    style: reguler.copyWith(
                                      fontSize: 13,
                                      color: blackPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteCardColor,
                                      hintText: '+62',
                                      suffixIcon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: blackPrimary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabled: false,
                                      disabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: blackPrimary,
                                        ),
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: TextFormField(
                                      controller: phoneNumberTextInput,
                                      keyboardType: TextInputType.phone,
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabled: true,
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
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${AppLocalizations.of(context)!.referralCode} (Optional)',
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: TextFormField(
                                  // onChanged: (value) {
                                  //   value != currEmail
                                  //       ? setState(
                                  //           () {
                                  //             currentEmail = false;
                                  //           },
                                  //         )
                                  //       : setState(
                                  //           () {
                                  //             currentEmail = true;
                                  //           },
                                  //         );
                                  // },
                                  controller: referralTextInput,
                                  keyboardType: TextInputType.text,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: whiteCardColor,
                                    hintText: AppLocalizations.of(context)!
                                        .referralCode,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabled: true,
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
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 35,
                              child: Checkbox(
                                value: agree,
                                side: MaterialStateBorderSide.resolveWith(
                                  (states) => BorderSide(
                                    color: blackPrimary,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    agree == false
                                        ? agree = true
                                        : agree = false;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.iAgree,
                                      style: reguler.copyWith(
                                        fontSize: 12,
                                        color: blackPrimary,
                                      )),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(
                                          Uri.parse(
                                              'https://gps.id/help/eula.html'),
                                          mode: LaunchMode.externalApplication);
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .termsAndConditionSuperspring,
                                        style: bold.copyWith(
                                            fontSize: 12,
                                            color: blueGradient,
                                            decoration:
                                                TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // setState(
                                //   () {
                                //     stepUnit == 1 ? stepUnit = 2 : stepUnit = 1;
                                //   },
                                // );
                                // if (nameTitleTextInput.text.isEmpty) {

                                // }
                                if (customerType == 0) {
                                  // if (companyTextInput.text.isEmpty ||
                                  //     companyEntityTextInput.text.isEmpty) {
                                  //   setState(() {
                                  //     companyDetailEmpty = true;
                                  //   });
                                  // }
                                  if (nameTextInput.text.isEmpty ||
                                      nameTitleTextInput.text.isEmpty ||
                                      // branchTextInput.text.isEmpty ||
                                      phoneNumberTextInput.text.isEmpty ||
                                      !agree) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: redPrimary,
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .completeProfile,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: whiteColorDarkMode,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    registerAccount();
                                  }
                                } else {
                                  if (companyEntityTextInput.text.isEmpty ||
                                      companyTextInput.text.isEmpty ||
                                      nameTextInput.text.isEmpty ||
                                      nameTitleTextInput.text.isEmpty ||
                                      // branchTextInput.text.isEmpty ||
                                      phoneNumberTextInput.text.isEmpty ||
                                      !agree) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: redPrimary,
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .completeProfile,
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: whiteColorDarkMode,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    registerAccount();
                                  }
                                }

                                // registerAccount();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: greenPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        width: 1, color: greenPrimary),
                                  ),
                                  // height: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .createAccount,
                                          style: reguler.copyWith(
                                              color: whiteColorDarkMode,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  step = 1;
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        width: 1, color: bluePrimary),
                                  ),
                                  // height: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.back,
                                          style: reguler.copyWith(
                                              color: bluePrimary, fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
