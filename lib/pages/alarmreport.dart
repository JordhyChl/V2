// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, avoid_print, avoid_function_literals_in_foreach_calls, use_build_context_synchronously, unused_field, unused_local_variable

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/alarm.model.dart';
import 'package:gpsid/model/alarmid.model.dart';
import 'package:gpsid/model/alarmtype.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AlarmReport extends StatefulWidget {
  final String licensePlate;
  final String imei;
  final String timeStart;
  final String timeEnd;
  final String expDate;
  final AlarmIDModel alarmID;
  final bool darkMode;
  @override
  State<AlarmReport> createState() => AlarmReportState();

  const AlarmReport(
      {Key? key,
      required this.imei,
      required this.timeStart,
      required this.timeEnd,
      required this.licensePlate,
      required this.expDate,
      required this.alarmID,
      required this.darkMode})
      : super(key: key);
}

class AlarmReportState extends State<AlarmReport> {
  var size, height, width;
  bool _isError = false;
  String _errCode = '';
  late Future<dynamic> _getAlarmReport;
  int page = 1;
  int perPage = 25;
  bool _isData = true;
  late List<ResultAlarmReport> initAlarmReport;
  late List<ResultAlarmType> initAlarmType;
  TextEditingController endDateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  late int _diff;
  late DateTime _now;
  DateTime _expDate = DateTime.now();
  DateTime? _getExpired;
  int totalData = 0;
  String timeStart = '';
  String timeEnd = '';
  List<int> alarmTypeID = [
    1,
    301,
    2,
    304,
    300,
    305,
    6,
    30,
    20,
    310,
    311,
    254,
    255,
    7
  ];
  late AlarmIDModel alarmID;

  bool isCheck = false;
  bool loadmoreBtn = false;
  int currentData = 0;
  List<ResultAlarmType> temporary = [];
  late int getIndex;
  late DataAlarmType dataLocalAlarmType;
  late List<ResultAlarmType> temp2 = [];
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  String getDate = '';
  String getTime = '';
  bool disable = false;
  String getFinishDate = '';

  @override
  void initState() {
    super.initState();
    alarmID = widget.alarmID;
    _now = DateTime.now();
    _getExpired = DateTime.parse(widget.expDate);
    _expDate = _getExpired!.toLocal();
    _diff = _expDate.difference(_now).inDays;
    _getAlarmReport = getAlarmReport();
    // _getAlarmType = getAlarmType();
    timeStart = widget.timeStart;
    timeEnd = widget.timeEnd;
    startDateController.text = timeStart;
    endDateController.text = timeEnd;
  }

  _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _diff >= 0 ? _now : _expDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: _diff >= 0
            ? _now.subtract(const Duration(days: 365))
            : _expDate.subtract(const Duration(days: 365)),
        lastDate: _diff >= 0 ? _now : _expDate);
    if (picked != null) {
      setState(() {
        getDate = DateFormat('yyyy-MM-dd').format(picked);
        getFinishDate = getDate;
      });
      _selectStartTime(context, getDate, picked);
    }
  }

  _selectStartTime(BuildContext context, String date, DateTime start) async {
    DateTime? today = DateTime.now();
    String startDate = '';
    late int startFinishDiff;
    late int startFinishDiffExp;
    startFinishDiff = today.difference(start).inDays;
    startFinishDiffExp = _expDate.difference(start).inDays;
    startDate = _diff >= 0
        ? start.day != today.day
            ? startFinishDiff == 1
                ? DateFormat('yyyy-MM-dd')
                    .format(start.add(const Duration(days: 1)))
                : DateFormat('yyyy-MM-dd')
                    .format(start.add(const Duration(days: 2)))
            : DateFormat('yyyy-MM-dd').format(start)
        : start.day != _expDate.day
            ? startFinishDiffExp == 1
                ? DateFormat('yyyy-MM-dd')
                    .format(start.add(const Duration(days: 1)))
                : DateFormat('yyyy-MM-dd')
                    .format(start.add(const Duration(days: 2)))
            : DateFormat('yyyy-MM-dd').format(_expDate);
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 00, minute: 00));
    if (picked != null) {
      String hour, minute, time;
      setState(() {
        selectedTime = picked;
        hour = selectedTime.hour.toString().padLeft(2, '0');
        minute = selectedTime.minute.toString().padLeft(2, '0');
        time = '$hour:$minute';
        startDateController.text = '$date $time';
        print('Print test start: ${startDateController.text}');
        endDateController.text = '$startDate 23:59';
      });
    }
  }

  _selectFinisDate(BuildContext context) async {
    DateTime? startDate = DateTime.parse(getFinishDate);
    DateTime? today = DateTime.now();
    late int startFinishDiff;
    late int startFinishDiffExp;
    startFinishDiff = today.difference(startDate).inDays;
    startFinishDiffExp = _expDate.difference(startDate).inDays;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _diff >= 0
            ? startDate.day != today.day
                ? startFinishDiff == 1
                    ? startDate.add(const Duration(days: 1))
                    : startDate.add(const Duration(days: 2))
                : startDate
            : startDate.day != _expDate.day
                ? startFinishDiffExp == 1
                    ? startDate.add(const Duration(days: 1))
                    : startDate.add(const Duration(days: 2))
                : _expDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: startDate,
        lastDate: _diff >= 0
            ? startDate.day != today.day
                ? startFinishDiff == 1
                    ? startDate.add(const Duration(days: 1))
                    : startDate.add(const Duration(days: 2))
                : startDate
            : startDate.day != _expDate.day
                ? startFinishDiffExp == 1
                    ? startDate.add(const Duration(days: 1))
                    : startDate.add(const Duration(days: 2))
                : _expDate);
    if (picked != null) {
      setState(() {
        getDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _selectFinishTime(context, getDate);
    }
  }

  _selectFinishTime(BuildContext context, String date) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    if (picked != null) {
      String hour, minute, time;
      setState(() {
        selectedTime = picked;
        hour = selectedTime.hour.toString().padLeft(2, '0');
        minute = selectedTime.minute.toString().padLeft(2, '0');
        time = '$hour:$minute';
        endDateController.text = '$date $time';
        print('Print test end: ${endDateController.text}');
      });
    }
  }

  sort(int index) {}

  getLocal() async {
    var getAlarmTypeLocal = await GeneralService().readLocalAlarmStorage();
    if (getAlarmTypeLocal != false) {
      initAlarmType.clear();
      setState(() {
        // initAlarmType = getAlarmTypeLocal.result;
        initAlarmType.addAll(getAlarmTypeLocal.result);
      });
      alarmTypeID.clear();
      initAlarmType.forEach((el) {
        if (el.checked) {
          setState(() {
            alarmTypeID.add(el.alertNo);
          });
        }
      });
      print('alarm type: $alarmTypeID');
      // sort(getIndex);
    } else {
      dataLocalAlarmType = DataAlarmType(
          result: [ResultAlarmType(code: '', alertNo: 999, checked: false)]);
    }
  }

  setAlarmType(int index, String code, int alertno, bool checked) async {
    // if (initAlarmType[index].checked == true) {
    //   temporary.add(initAlarmType[index]);
    // }
    temporary.add(initAlarmType[index]);
    print(temporary);
    // initAlarmType.forEach((el) {
    //   if (el.checked == true) {
    //     if (temporary.isNotEmpty) {
    //       if (el.alertNo != temporary[getIndex].alertNo) {
    //         setState(() {
    //           temporary.add(el);
    //         });
    //       }
    //     } else {
    //       setState(() {
    //         temporary.add(el);
    //       });
    //     }
    //   }
    // });

    // initAlarmType.forEach((el) {
    //   if (el.checked) {
    //     temporaryII.add(el);
    //     print('temp2 ${temporaryII}');
    //   }
    // });
    // setState(() {
    //   temporary.addAll(temporaryII);
    // });
    // print(temporary);
  }

  saveToLocal(int index) async {
    late List<ResultAlarmType> getFinal = [];
    // temporary.forEach((el) {
    //   if (el.checked) {
    //     getFinal.add(el);
    //   }
    // });
    getFinal.addAll(initAlarmType);
    alarmTypeID.clear();
    initAlarmType.forEach((el) {
      if (el.checked) {
        setState(() {
          alarmTypeID.add(el.alertNo);
        });
      }
    });
    print(getFinal);
    DataAlarmType data = DataAlarmType(result: getFinal);
    AlarmIDModel dataID = AlarmIDModel(alarmID: alarmTypeID);
    await GeneralService().writeLocalAlarmTypeStorage(data);
    await GeneralService().writeLocalAlarmTypeID(dataID);
    print(data);
    print(dataID);
    // showSuccess(context, 'Success');
    refreshAlarmReport(page, perPage, widget.imei, timeStart, timeEnd);
  }

  checkLocal() async {
    // final getData = await GeneralService().readLocalAlarmStorage();
    // print(getData);
    final getData = await GeneralService().readLocalAlarmTypeID();
    print(getData);
  }

  deleteLocal() async {
    await GeneralService().deleteLocalAlarmStorage();
  }

  loadMore(int pageR, int perPageR, String imeiR, String timeStartR,
      String timeEndR) async {
    Dialogs().loadingDialog(context);
    page++;
    APIService()
        .getAlarmReport(pageR, perPageR, imeiR, timeStartR, timeEndR,
            alarmID.alarmID.isEmpty ? alarmTypeID : alarmID.alarmID)
        .then((snapshot) {
      if (snapshot is ErrorTrapModel) {
        loadmoreBtn = false;
        setState(() {
          _isError = true;
          _errCode = '76853alarmReportLoadMore';
        });
        Dialogs().hideLoaderDialog(context);
      } else {
        setState(() {
          _isError = false;
          _errCode = '';
          initAlarmReport.addAll(snapshot.data.result);
          currentData = initAlarmReport.length;
          totalData = snapshot.data.totalAllData;
          totalData <= currentData ? loadmoreBtn = false : loadmoreBtn = true;
        });

        Dialogs().hideLoaderDialog(context);
      }
    });
  }

  refreshAlarmReport(int pageR, int perPageR, String imeiR, String timeStartR,
      String timeEndR) async {
    Dialogs().loadingDialog(context);
    APIService()
        .getAlarmReport(
            pageR, perPageR, imeiR, timeStartR, timeEndR, alarmTypeID)
        .then((snapshot) {
      if (snapshot is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        Navigator.of(context).pop();
        setState(() {
          _isError = true;
          _errCode = '76853alarmreport';
          disable = true;
        });
      } else if (snapshot == 'false') {
        // initAlarmReport.clear();
        setState(() {
          _isError = true;
          _errCode = '';
          _isData = false;
          totalData = 0;
          loadmoreBtn = false;
        });
        Dialogs().hideLoaderDialog(context);
        Navigator.of(context).pop();
      }
      // if (snapshot == 'false') {
      //   setState(() {
      //     _isData = false;
      //     _isError = true;
      //     _errCode = '76853alarmreport';
      //   });
      // }
      else {
        initAlarmReport.clear();
        setState(() {
          if (snapshot.data.result.length == 0) {
            _isData = false;
          } else {
            _isData = true;
            _isError = false;
            _errCode = '';
          }
          startDateController.text = timeStartR;
          endDateController.text = timeEndR;
          // durationController.text = '15 Minutes';
          initAlarmReport.addAll(snapshot.data.result);
          totalData = snapshot.data.totalAllData;
          if (totalData > currentData) {
            setState(() {
              loadmoreBtn = true;
            });
          } else {
            setState(() {
              loadmoreBtn = false;
            });
          }
          // totalHour = snapshot.data.totalParkingTime;
        });
        Dialogs().hideLoaderDialog(context);
        Navigator.of(context).pop();
      }
    });
  }

  Future<dynamic> getAlarmReport() async {
    final result = await APIService().getAlarmReport(
        page,
        perPage,
        widget.imei,
        widget.timeStart,
        widget.timeEnd,
        alarmID.alarmID.isEmpty ? alarmTypeID : alarmID.alarmID);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853alarmreport';
        disable = true;
      });
    } else if (result == 'false') {
      Future.delayed(const Duration(seconds: 1), () async {
        await getLocal();
      });

      setState(() {
        disable = true;
        _isError = true;
        _errCode = '76853alarmreport';
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        getLocal();
      });
      setState(() {
        getAlarmType();
        if (result.data.result.length == 0) {
          _isData = false;
        } else {
          disable = false;
          _isError = false;
          _errCode = '';
          totalData = result.data.totalAllData;
          if (totalData > currentData) {
            setState(() {
              loadmoreBtn = true;
            });
          } else {
            setState(() {
              loadmoreBtn = false;
            });
          }
          // totalHour = result.data.totalParkingTime;
        }
        startDateController.text = widget.timeStart;
        endDateController.text = widget.timeEnd;
        // durationController.text = '15 Minutes';
      });
    }
    return result;
  }

  getAlarmType() async {
    final result = await APIService().getAlarmType();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853alarmType';
      });
      // Dialogs().hideLoaderDialog(context);
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        initAlarmType = result.data.result;
      });

      // Dialogs().hideLoaderDialog(context);
    }
    return result;
  }

  String convertLatLng(double decimal, bool isLat) {
    String degreeBefore = "${decimal.toString().split(".")[0]}°";
    String degree = degreeBefore.substring(0, 1) == '-'
        ? degreeBefore.substring(1, degreeBefore.length)
        : degreeBefore;
    double minutesBeforeConversion =
        double.parse("0.${decimal.toString().split(".")[1]}");
    String minutes =
        "${(minutesBeforeConversion * 60).toString().split('.')[0]}'";
    double secondsBeforeConversion = double.parse(
        "0.${(minutesBeforeConversion * 60).toString().split('.')[1]}");
    String seconds =
        '${double.parse((secondsBeforeConversion * 60).toString()).toStringAsFixed(2)}"';
    String dmsOutput =
        "$degree$minutes$seconds${isLat ? decimal > 0 ? 'N' : 'S' : decimal > 0 ? 'E' : 'w'}";
    return dmsOutput;
  }

  Future<void> getAddressII(String pLat, String pLng, int index) async {
    String posDegree =
        '${convertLatLng(double.parse(pLat), true)} ${convertLatLng(double.parse(pLng), false)}';
    String gMapsUrl =
        "https://www.google.com/maps/place/$posDegree/@$pLat,$pLng,17z";

    final response = await http.Client().get(Uri.parse(gMapsUrl));
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var metas = document.getElementsByTagName("meta");
      for (var meta in metas) {
        bool isAdrress = false;
        var attrs = meta.attributes;
        attrs.forEach((key, value) {
          if (key == 'itemprop' && value == 'description') {
            isAdrress = true;
          }
        });
        if (isAdrress) {
          attrs.forEach((key, value) {
            if (key == 'content') {
              setState(() {
                initAlarmReport[index].address = value;
              });
            }
          });
        }
      }
    } else {
      throw Exception();
    }
  }

  Future<void> getAddress(String pLat, String pLng, int index) async {
    final result = await APIService().getAddress(pLat, pLng);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '45864';
      });
    } else {
      if (mounted) {
        var addressResult;
        addressResult = json.decode(result);
        setState(() {
          _isError = false;
          _errCode = '';
          initAlarmReport[index].address = addressResult['message'];
          // initStopReport[index].gsmNo = addressResult['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 143,
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
          title: Column(
            children: [
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alarm,
                        textAlign: TextAlign.center,
                        style: bold.copyWith(
                          fontSize: 16,
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                widget.licensePlate,
                style: reguler.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                '${AppLocalizations.of(context)!.totalData}: ${totalData.toString()}',
                style: reguler.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: blueGradientSecondary1,
                        ),
                      ),
                      backgroundColor: whiteColor,
                      // disabledBackgroundColor: greyColor,
                      // backgroundColor: Theme.of(context).accentColor,
                      textStyle: const TextStyle(
                        color: Colors.black,
                      )),
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor:
                            widget.darkMode ? whiteCardColor : whiteColor,
                        isDismissible: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        context: context,
                        builder: (BuildContext context) {
                          // startDateController.text = widget.timeStart;
                          // endDateController.text = widget.timeEnd;
                          // durationController.text = '15 Minutes';
                          return StatefulBuilder(builder: (context, setState) {
                            return SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Container(),
                                            Text(
                                              'Set date time',
                                              style: bold.copyWith(
                                                fontSize: 16,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Container(),

                                            GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: Icon(
                                                Icons.close,
                                                size: 40,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .startDateTime,
                                              style: bold.copyWith(
                                                fontSize: 12,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _selectStartDate(context),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.2,
                                                height: 40,
                                                child: TextField(
                                                  style: reguler.copyWith(
                                                      color: blackPrimary),
                                                  textAlign: TextAlign.center,
                                                  enabled: false,
                                                  controller:
                                                      startDateController,
                                                  decoration: InputDecoration(
                                                    disabledBorder:
                                                        UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    blueGradientSecondary2)),
                                                    fillColor: widget.darkMode
                                                        ? whiteColor
                                                        : whiteCardColor,
                                                    filled: true,
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .insertStartDate,
                                                    hintStyle: reguler.copyWith(
                                                      fontSize: 10,
                                                      color: blackSecondary3,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      bottom: 10,
                                                      left: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .endDateTime,
                                              style: bold.copyWith(
                                                fontSize: 12,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () => getFinishDate
                                                      .isNotEmpty
                                                  ? _selectFinisDate(context)
                                                  : showInfoAlert(
                                                      context,
                                                      'Select start date first',
                                                      ''),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.2,
                                                height: 40,
                                                child: TextField(
                                                  style: reguler.copyWith(
                                                      color: blackPrimary),
                                                  textAlign: TextAlign.center,
                                                  enabled: false,
                                                  controller: endDateController,
                                                  decoration: InputDecoration(
                                                    disabledBorder:
                                                        UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    blueGradientSecondary2)),
                                                    fillColor: widget.darkMode
                                                        ? whiteColor
                                                        : whiteCardColor,
                                                    filled: true,
                                                    hintText: 'Insert end date',
                                                    hintStyle: reguler.copyWith(
                                                      fontSize: 10,
                                                      color: blackSecondary3,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      bottom: 10,
                                                      left: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          refreshAlarmReport(
                                              page,
                                              perPage,
                                              widget.imei,
                                              startDateController.text,
                                              endDateController.text);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: whiteColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              side: BorderSide(
                                                  color: blueGradient,
                                                  width: 1),
                                            ),
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                            )),
                                        child: Text(
                                          'Submit',
                                          style: reguler.copyWith(
                                            fontSize: 12,
                                            color: blueGradient,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // ElevatedButton(
                                    //     style: ElevatedButton.styleFrom(
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(10.0),
                                    //           side: BorderSide(
                                    //             color: blueGradientSecondary1,
                                    //           ),
                                    //         ),
                                    //         backgroundColor:
                                    //             blueGradientSecondary1,
                                    //         // disabledBackgroundColor: greyColor,
                                    //         // backgroundColor: Theme.of(context).accentColor,
                                    //         textStyle: const TextStyle(
                                    //           color: Colors.black,
                                    //         )),
                                    //     onPressed: () {
                                    //       refreshAlarmReport(
                                    //           page,
                                    //           perPage,
                                    //           widget.imei,
                                    //           startDateController.text,
                                    //           endDateController.text);
                                    //     },
                                    //     child: const Text('Submit'))
                                    //
                                  ],
                                ),
                              ),
                            );
                          });
                        });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 15,
                        color: widget.darkMode
                            ? whiteColorDarkMode
                            : blackSecondary2,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '$timeStart - $timeEnd',
                        style: reguler.copyWith(
                          fontSize: 11,
                          color: widget.darkMode
                              ? whiteColorDarkMode
                              : blackSecondary2,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          backgroundColor: whiteColor,
        ),
        body: Container(
          color: whiteColor,
          child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Stack(
                    children: [
                      FutureBuilder(
                          future: _getAlarmReport,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data is ErrorTrapModel) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                            AppLocalizations.of(context)!
                                                .error500,
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
                                            AppLocalizations.of(context)!
                                                .error500Sub,
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
                              }
                              if (_isData == false) {
                                return Center(
                                  child: ListView.builder(
                                    itemCount: 1,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 60),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/handling/emptyalarmnotif.png',
                                                height: 240,
                                                width: 240,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 50,
                                                    right: 50,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .emptyAlarmNotif,
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
                                                    left: 30,
                                                    right: 30,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .emptyAlarmNotifSub,
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
                                    },
                                  ),
                                );
                              }
                              if (snapshot.data == '{}') {
                                return Center(
                                  child: ListView.builder(
                                    itemCount: 1,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 60),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/handling/emptyalarmnotif.png',
                                                height: 240,
                                                width: 240,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 50,
                                                    right: 50,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .emptyAlarmNotif,
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
                                                    left: 30,
                                                    right: 30,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .emptyAlarmNotifSub,
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
                                    },
                                  ),
                                );
                              }
                              if (snapshot.data == 'false') {
                                return Center(
                                  child: ListView.builder(
                                    itemCount: 1,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 60),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/handling/emptyalarmnotif.png',
                                                height: 240,
                                                width: 240,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 50,
                                                    right: 50,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .emptyAlarmNotif,
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
                                                    left: 30,
                                                    right: 30,
                                                    top: 10),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .emptyAlarmNotifSub,
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
                                    },
                                  ),
                                );
                              } else {
                                initAlarmReport = snapshot.data.data.result;
                                totalData = snapshot.data.data.totalAllData;
                                // totalHour = snapshot.data.data.totalParkingTime;
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: initAlarmReport.length,
                                    itemBuilder: (context, index) {
                                      DateTime? time = DateTime.parse(
                                          initAlarmReport[index].time);
                                      String timeFormat =
                                          DateFormat('yyyy-MM-dd HH mm')
                                              .format(time.toLocal());
                                      LatLng cPosition = LatLng(
                                        initAlarmReport[index].lat,
                                        initAlarmReport[index].lon,
                                      );
                                      String img = '';
                                      // initAlarmReport.forEach((el) {
                                      //   if (el.alert == 1) {
                                      //     img = 'assets/sosalarm.png';
                                      //   }
                                      //   if (el.alert == 2) {
                                      //     img = 'assets/alarmoff.png';
                                      //   }
                                      //   if (el.alert == 3) {
                                      //     img = 'assets/alarmoff.png';
                                      //   }
                                      // });
                                      return Container(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, left: 10, right: 10),
                                        child: Card(
                                          color: whiteCardColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 1.5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                // Image.asset(
                                                //   'assets/${items.iconAlarm}.png',
                                                //   width: 24,
                                                // ),
                                                Image.asset(
                                                  'assets/alarmoff.png',
                                                  width: 24,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      timeFormat,
                                                      style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary3,
                                                      ),
                                                    ),
                                                    Text(
                                                      initAlarmReport[index]
                                                          .alertText,
                                                      style: bold.copyWith(
                                                          fontSize: 10,
                                                          color: blackPrimary),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    // Text(
                                                    //   items.plat.toString(),
                                                    //   style: bold.copyWith(
                                                    //     fontSize: 12,
                                                    //     color: blackPrimary,
                                                    //   ),
                                                    // ),
                                                    Text(
                                                      widget.licensePlate,
                                                      style: bold.copyWith(
                                                        fontSize: 12,
                                                        color: blackPrimary,
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      width: 200,
                                                      child: InkWell(
                                                        onLongPress: () {
                                                          getAddressII(
                                                              initAlarmReport[
                                                                      index]
                                                                  .lat
                                                                  .toString(),
                                                              initAlarmReport[
                                                                      index]
                                                                  .lon
                                                                  .toString(),
                                                              index);
                                                        },
                                                        onTap: () {
                                                          getAddress(
                                                              initAlarmReport[
                                                                      index]
                                                                  .lat
                                                                  .toString(),
                                                              initAlarmReport[
                                                                      index]
                                                                  .lon
                                                                  .toString(),
                                                              index);
                                                        },
                                                        child: Text(
                                                          initAlarmReport[index]
                                                              .address,
                                                          style: bold.copyWith(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // const SizedBox(
                                                    //   height: 4,
                                                    // ),
                                                    // Text(
                                                    //   items.statusAct
                                                    //       .toString(),
                                                    //   style:
                                                    //       reguler.copyWith(
                                                    //     fontSize: 12,
                                                    //     color:
                                                    //         blackSecondary2,
                                                    //   ),
                                                    // ),
                                                    // Text(
                                                    //   timeFormat,
                                                    //   style: reguler.copyWith(
                                                    //     fontSize: 12,
                                                    //     color: blackSecondary2,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              }
                            }
                            //SKELETON
                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return Card(
                                      margin: const EdgeInsets.all(15),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: SizedBox(
                                        height: 121,
                                        child: SkeletonTheme(
                                            themeMode: widget.darkMode
                                                ? ThemeMode.dark
                                                : ThemeMode.light,
                                            child: const SkeletonAvatar(
                                              style: SkeletonAvatarStyle(
                                                  shape: BoxShape.rectangle,
                                                  width: 140,
                                                  height: 30),
                                            )),
                                      ));
                                });
                          }),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
                child: GestureDetector(
                  onTap: () {
                    !disable
                        ? showModalBottomSheet(
                            backgroundColor: whiteCardColor,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return SingleChildScrollView(
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      20,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Container(),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .filterAlarm,
                                                style: bold.copyWith(
                                                  fontSize: 16,
                                                  color: blackPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .all,
                                                style: reguler.copyWith(
                                                  fontSize: 14,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary3,
                                                ),
                                              ),
                                              Theme(
                                                data: ThemeData(
                                                    unselectedWidgetColor:
                                                        blackPrimary),
                                                child: Checkbox(
                                                  activeColor: bluePrimary,
                                                  value: isCheck,
                                                  onChanged: (value) {
                                                    !isCheck
                                                        ? initAlarmType
                                                            .forEach((el) {
                                                            setState(() {
                                                              isCheck = true;
                                                              el.checked = true;
                                                            });
                                                          })
                                                        : initAlarmType
                                                            .forEach((el) {
                                                            setState(() {
                                                              isCheck = false;
                                                              el.checked =
                                                                  false;
                                                            });
                                                          });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2,
                                          child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: initAlarmType.length,
                                            itemBuilder: (context, index) {
                                              getIndex = index;
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          initAlarmType[index]
                                                              .code,
                                                          style:
                                                              reguler.copyWith(
                                                            fontSize: 14,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3,
                                                          ),
                                                        ),
                                                        Theme(
                                                          data: ThemeData(
                                                              unselectedWidgetColor:
                                                                  blackPrimary),
                                                          child: Checkbox(
                                                            activeColor:
                                                                bluePrimary,
                                                            value:
                                                                initAlarmType[
                                                                        index]
                                                                    .checked,
                                                            onChanged: (value) {
                                                              !initAlarmType[
                                                                          index]
                                                                      .checked
                                                                  ? setState(
                                                                      () {
                                                                      initAlarmType[index]
                                                                              .checked =
                                                                          true;
                                                                      setAlarmType(
                                                                          index,
                                                                          initAlarmType[index]
                                                                              .code,
                                                                          initAlarmType[index]
                                                                              .alertNo,
                                                                          initAlarmType[index]
                                                                              .checked);
                                                                    })
                                                                  : setState(
                                                                      () {
                                                                      initAlarmType[index]
                                                                              .checked =
                                                                          false;
                                                                    });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                            child: Column(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: whiteColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    side: BorderSide(
                                                        color: blueGradient,
                                                        width: 1),
                                                  ),
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                  )),
                                              onPressed: () {
                                                // loadMore(page, pe);
                                                // loadMore(
                                                //     page,
                                                //     perPage,
                                                //     widget.imei,
                                                //     startDateController.text,
                                                //     endDateController.text);
                                                saveToLocal(getIndex);
                                              },
                                              child: Center(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Save',
                                                    style: reguler.copyWith(
                                                      fontSize: 12,
                                                      color: blueGradient,
                                                    ),
                                                  )
                                                ],
                                              )),
                                            )
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            })
                        : {};
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 112,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: !disable
                            ? widget.darkMode
                                ? whiteColorDarkMode
                                : blackSecondary3
                            : greyColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 10,
                          color: !disable
                              ? widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary3
                              : greyColor,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          AppLocalizations.of(context)!.filterAlarm,
                          style: reguler.copyWith(
                            fontSize: 10,
                            color: !disable
                                ? widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary3
                                : greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  parkingReportModel(context) {
    return Container(
      width: double.infinity,
      height: height / 3.5,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whiteCardColor,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Image.asset('assets/stopreportimage.png'),
              Positioned(
                bottom: 20,
                left: 10,
                right: 10,
                child: SizedBox(
                  width: 120,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bluePrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StopMap()));
                    },
                    child: Text(
                      'Open Maps',
                      style: reguler.copyWith(
                        fontSize: 10,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 190,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TimelineTile(
                  afterLineStyle: LineStyle(color: greyColor, thickness: 1),
                  indicatorStyle: IndicatorStyle(
                    indicator: Image.asset('assets/start_icon.png'),
                  ),
                  isFirst: true,
                  endChild: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.startParking,
                          style: reguler.copyWith(
                            fontSize: 8,
                            color: blackSecondary3,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Sabtu, 1 April 2022, 22:00',
                          style: bold.copyWith(
                            fontSize: 8,
                            color: blackPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.5,
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                          color: greyColor,
                        ),
                      ],
                    ),
                  ),
                ),
                TimelineTile(
                  beforeLineStyle: LineStyle(color: greyColor, thickness: 1),
                  indicatorStyle: IndicatorStyle(
                    indicator: Image.asset('assets/parking_icon.png'),
                  ),
                  isLast: true,
                  endChild: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.doneParking,
                          style: reguler.copyWith(
                            fontSize: 8,
                            color: blackSecondary3,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Sabtu, 1 April 2022, 22:00',
                          style: bold.copyWith(
                            fontSize: 8,
                            color: blackPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.5,
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                          color: greyColor,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  AppLocalizations.of(context)!.address,
                  style: reguler.copyWith(
                    fontSize: 8,
                    color: blackSecondary3,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Jl. Cideng Timur No.81, Petojo Sel., Kecamatan Gambir, Kota Jakarta Pusat, Daerah Khusus Ibukota Jakarta 10160',
                  style: bold.copyWith(
                    fontSize: 8,
                    color: blackPrimary,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StopMap extends StatelessWidget {
  const StopMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/stopmap.png',
            fit: BoxFit.fill,
          ),
          Positioned(
              top: 60,
              left: 30,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bluePrimary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: whiteColor,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
