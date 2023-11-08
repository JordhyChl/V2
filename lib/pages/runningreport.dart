// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/runningreport.model.dart';
import 'package:gpsid/pages/trackreplaypage.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timeline_tile/timeline_tile.dart';

class RunningReportPage extends StatefulWidget {
  final String licensePlate;
  final String imei;
  final String timeStart;
  final String timeEnd;
  final String expDate;
  final int icon;
  final bool darkMode;
  @override
  State<RunningReportPage> createState() => RunningReportPageState();

  const RunningReportPage(
      {Key? key,
      required this.imei,
      required this.timeStart,
      required this.timeEnd,
      required this.licensePlate,
      required this.expDate,
      required this.icon,
      required this.darkMode})
      : super(key: key);
}

class RunningReportPageState extends State<RunningReportPage> {
  var size, height, width;
  late Future<dynamic> _getRunningReport;
  int page = 1;
  int perPage = 25;
  bool _isData = true;
  late List<ResultRunningReport> initRunningReport;
  late BitmapDescriptor markerbitmap;
  TextEditingController endDateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  late int _diff;
  late DateTime _now;
  DateTime _expDate = DateTime.now();
  DateTime? _getExpired;
  int totalData = 0;
  int totalHour = 0;
  static const List<String> setDuration = <String>[
    '1 Minutes',
    '5 Minutes',
    '10 Minutes',
    '15 Minute'
  ];
  int selectedDuration = 0;
  String timeStart = '';
  String timeEnd = '';
  var _startIcon;
  var _finishIcon;
  bool loadmoreBtn = false;
  // int currentData = 0;
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  String getDate = '';
  String getTime = '';
  String getFinishDate = '';

  @override
  void initState() {
    super.initState();
    firstLoad();
    _now = DateTime.now();
    _getExpired = DateTime.parse(widget.expDate);
    _expDate = _getExpired!.toLocal();
    _diff = _expDate.difference(_now).inDays;
    _getRunningReport = getRunningReport();
    timeStart = widget.timeStart;
    timeEnd = widget.timeEnd;
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

  firstLoad() async {
    _startIcon = await getBytesFromAsset('assets/startmarker.png', 50);
    _finishIcon = await getBytesFromAsset('assets/endmarker.png', 50);
    return [];
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHour = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // if (duration.inMinutes) {

    // }
    return twoDigitHour == '00'
        ? "$twoDigitMinutes Minutes $twoDigitSeconds Seconds"
        : "$twoDigitHour Hour $twoDigitMinutes Minutes $twoDigitSeconds Seconds";
  }

  String _printDurationCard(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}H ${twoDigitMinutes}M ${twoDigitSeconds}S";
  }

  refreshRunningReport(int pageR, int perPageR, String imeiR, String timeStartR,
      String timeEndR, int minDuration) async {
    Dialogs().loadingDialog(context);
    APIService()
        .getRunningReport(pageR, perPageR, imeiR, timeStartR, timeEndR)
        .then((snapshot) {
      if (snapshot is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        setState(() {});
      }
      if (snapshot == 'false') {
        initRunningReport.clear();
        setState(() {
          _isData = false;
          totalData = 0;
          totalHour = 0;
        });
        Dialogs().hideLoaderDialog(context);
        Navigator.of(context).pop();
      } else {
        initRunningReport.clear();
        setState(() {
          if (snapshot.data.result.length == 0) {
            _isData = false;
          } else {
            _isData = true;
          }
          startDateController.text = timeStartR;
          endDateController.text = timeEndR;
          // durationController.text = '15 Minutes';
          initRunningReport.addAll(snapshot.data.result);
          totalData = snapshot.data.totalAllData;
          totalHour = snapshot.data.totalRunningTime;
        });
        Dialogs().hideLoaderDialog(context);
        Navigator.of(context).pop();
      }
    });
  }

  Future<dynamic> getRunningReport() async {
    final result = await APIService().getRunningReport(
        page, perPage, widget.imei, widget.timeStart, widget.timeEnd);
    if (result is ErrorTrapModel) {
      setState(() {});
    }
    if (result == 'false') {
      setState(() {});
    } else {
      setState(() {
        if (result.data.result.length == 0) {
          _isData = false;
        } else {
          totalData = result.data.totalAllData;
          // currentData = result.data.perPage;
          totalHour = result.data.totalRunningTime;
        }
        startDateController.text = widget.timeStart;
        endDateController.text = widget.timeEnd;
        // durationController.text = '15 Minutes';
      });
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

  Future<void> getAddressII(
      String pLat, String pLng, int index, bool end) async {
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
              if (end) {
                setState(() {
                  initRunningReport[index].endAddress = value;
                });
              } else {
                setState(() {
                  initRunningReport[index].startAddress = value;
                });
              }
            }
          });
        }
      }
    } else {
      throw Exception();
    }
  }

  Future<void> getAddress(String pLat, String pLng, int index, bool end) async {
    final result = await APIService().getAddress(pLat, pLng);
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      if (mounted) {
        var addressResult;
        addressResult = json.decode(result);
        setState(() {
          if (end) {
            initRunningReport[index].endAddress = addressResult['message'];
          } else {
            initRunningReport[index].startAddress = addressResult['message'];
          }
          // initRunningReport[index]. = addressResult['message'];
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
                        AppLocalizations.of(context)!.runningReport,
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
                'Total data: ${totalData.toString()}',
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
                                color: widget.darkMode
                                    ? whiteCardColor
                                    : whiteColor,
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
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                              borderSide:
                                                                  BorderSide(
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
                                                      hintStyle:
                                                          reguler.copyWith(
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
                                          refreshRunningReport(
                                              page,
                                              perPage,
                                              widget.imei,
                                              startDateController.text,
                                              endDateController.text,
                                              selectedDuration);
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
                                    //       refreshJourneyReport(
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
              FutureBuilder(
                  future: _getRunningReport,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                      }
                      if (_isData == false) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/handling/runningreport_empty.png',
                                  height: 240,
                                  width: 240,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .runningreportEmpty,
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
                                        .runningreportEmptySub,
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
                      if (snapshot.data == '{}') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/handling/runningreport_empty.png',
                                  height: 240,
                                  width: 240,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .runningreportEmpty,
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
                                        .runningreportEmptySub,
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
                      if (snapshot.data == 'false') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/handling/runningreport_empty.png',
                                  height: 240,
                                  width: 240,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .runningreportEmpty,
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
                                        .runningreportEmptySub,
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
                        initRunningReport = snapshot.data.data.result;
                        totalData = snapshot.data.data.totalAllData;
                        totalHour = snapshot.data.data.totalRunningTime;
                        // currentData = snapshot.data.data.perPage;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 10),
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .totalMovingTime,
                                    style: reguler.copyWith(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: whiteCardColor,
                                    ),
                                    width: double.infinity,
                                    height: 50,
                                    child: Text(
                                      _printDuration(
                                          Duration(seconds: totalHour)),
                                      style: bold.copyWith(
                                        fontSize: 16,
                                        color: blackPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: initRunningReport.length,
                                  itemBuilder: (context, index) {
                                    double ctrLat = (initRunningReport[index]
                                                .startLat +
                                            initRunningReport[index].endLat) /
                                        2;
                                    double ctrLon = (initRunningReport[index]
                                                .startLon +
                                            initRunningReport[index].endLon) /
                                        2;
                                    LatLng centerPosition = LatLng(
                                      ctrLat,
                                      ctrLon,
                                    );
                                    LatLng start = LatLng(
                                      initRunningReport[index].startLat,
                                      initRunningReport[index].startLon,
                                    );
                                    LatLng end = LatLng(
                                      initRunningReport[index].endLat,
                                      initRunningReport[index].endLon,
                                    );
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 20, left: 8, right: 8),
                                      decoration: BoxDecoration(
                                          color: whiteCardColor,
                                          boxShadow: [
                                            BoxShadow(
                                                color: widget.darkMode
                                                    ? whiteCardColor
                                                    : blackPrimary
                                                        .withOpacity(0.12),
                                                spreadRadius: 0,
                                                blurRadius: 8,
                                                offset: const Offset(0, 2))
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      // shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(4),
                                      //   side: BorderSide(
                                      //     color: whiteCardColor,
                                      //     width: 1,
                                      //   ),
                                      // ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5),
                                              child: SizedBox(
                                                width: 120,
                                                child: Stack(
                                                  children: [
                                                    SizedBox(
                                                      width: 120,
                                                      height: 180,
                                                      child: GoogleMap(
                                                        trafficEnabled: false,
                                                        buildingsEnabled: true,
                                                        liteModeEnabled:
                                                            Platform.isAndroid
                                                                ? true
                                                                : false,
                                                        initialCameraPosition:
                                                            CameraPosition(
                                                          target:
                                                              centerPosition,
                                                          zoom: initRunningReport[
                                                                          index]
                                                                      .driveMilage >
                                                                  8000
                                                              ? 9.0
                                                              : 13.0,
                                                        ),
                                                        markers: Set<Marker>.of(
                                                          {
                                                            Marker(
                                                              markerId:
                                                                  MarkerId(
                                                                start
                                                                    .toString(),
                                                              ),
                                                              position: start,
                                                              icon: BitmapDescriptor
                                                                  .fromBytes(
                                                                      _startIcon),
                                                            ),
                                                            Marker(
                                                              markerId:
                                                                  MarkerId(
                                                                end.toString(),
                                                              ),
                                                              position: end,
                                                              icon: BitmapDescriptor
                                                                  .fromBytes(
                                                                      _finishIcon),
                                                            ),
                                                          },
                                                        ),
                                                        scrollGesturesEnabled:
                                                            false,
                                                        mapToolbarEnabled:
                                                            false,
                                                        zoomControlsEnabled:
                                                            false,
                                                        myLocationButtonEnabled:
                                                            false,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 20,
                                                      left: 10,
                                                      right: 10,
                                                      child: SizedBox(
                                                        width: 120,
                                                        height: 30,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                bluePrimary,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        TrackreplayPage(
                                                                  imei: widget
                                                                      .imei,
                                                                  timeStart:
                                                                      initRunningReport[
                                                                              index]
                                                                          .start,
                                                                  timeEnd:
                                                                      initRunningReport[
                                                                              index]
                                                                          .end,
                                                                  licensePlate:
                                                                      initRunningReport[
                                                                              index]
                                                                          .plate,
                                                                  expDate: widget
                                                                      .expDate,
                                                                  vehicleStatus:
                                                                      '',
                                                                  icon: widget
                                                                      .icon,
                                                                  darkMode: widget
                                                                      .darkMode,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .play_circle_outline_outlined,
                                                                  size: 15),
                                                              Text(
                                                                'Playback',
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : whiteColor,
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
                                            // const SizedBox(
                                            //   width: 8,
                                            // ),
                                            Expanded(
                                              // width: 190,
                                              // height: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TimelineTile(
                                                    afterLineStyle: LineStyle(
                                                        color: greyColor,
                                                        thickness: 1),
                                                    indicatorStyle:
                                                        IndicatorStyle(
                                                      indicator: Image.asset(
                                                          'assets/start_icon.png'),
                                                    ),
                                                    isFirst: true,
                                                    endChild: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            initRunningReport[
                                                                    index]
                                                                .start,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 8,
                                                              color:
                                                                  blackPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          InkWell(
                                                            onLongPress: () {
                                                              getAddressII(
                                                                  initRunningReport[
                                                                          index]
                                                                      .startLat
                                                                      .toString(),
                                                                  initRunningReport[
                                                                          index]
                                                                      .startLon
                                                                      .toString(),
                                                                  index,
                                                                  false);
                                                            },
                                                            onTap: () {
                                                              getAddress(
                                                                  initRunningReport[
                                                                          index]
                                                                      .startLat
                                                                      .toString(),
                                                                  initRunningReport[
                                                                          index]
                                                                      .startLon
                                                                      .toString(),
                                                                  index,
                                                                  false);
                                                            },
                                                            child: Text(
                                                              initRunningReport[
                                                                      index]
                                                                  .startAddress,
                                                              style:
                                                                  bold.copyWith(
                                                                fontSize: 8,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary3,
                                                              ),
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
                                                    beforeLineStyle: LineStyle(
                                                        color: greyColor,
                                                        thickness: 1),
                                                    indicatorStyle:
                                                        IndicatorStyle(
                                                      indicator: Image.asset(
                                                          'assets/stop_icon.png'),
                                                    ),
                                                    isLast: true,
                                                    endChild: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            initRunningReport[
                                                                    index]
                                                                .end,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 8,
                                                              color:
                                                                  blackPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          InkWell(
                                                            onLongPress: () {
                                                              getAddressII(
                                                                  initRunningReport[
                                                                          index]
                                                                      .startLat
                                                                      .toString(),
                                                                  initRunningReport[
                                                                          index]
                                                                      .startLon
                                                                      .toString(),
                                                                  index,
                                                                  true);
                                                            },
                                                            onTap: () {
                                                              getAddress(
                                                                  initRunningReport[
                                                                          index]
                                                                      .endLat
                                                                      .toString(),
                                                                  initRunningReport[
                                                                          index]
                                                                      .endLon
                                                                      .toString(),
                                                                  index,
                                                                  true);
                                                            },
                                                            child: Text(
                                                              initRunningReport[
                                                                      index]
                                                                  .endAddress,
                                                              style:
                                                                  bold.copyWith(
                                                                fontSize: 8,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary3,
                                                              ),
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
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        // width: 100,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .electric_car,
                                                                  size: 12,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .totalEngineOn,
                                                                          style:
                                                                              bold.copyWith(
                                                                            fontSize:
                                                                                8,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        _printDurationCard(Duration(
                                                                            seconds:
                                                                                initRunningReport[index].duration)),
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              8,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons.speed,
                                                                  size: 12,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .avgSpeed,
                                                                          style:
                                                                              bold.copyWith(
                                                                            fontSize:
                                                                                8,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${initRunningReport[index].averageSpeed.toString()} Km/h',
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              8,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons.speed,
                                                                  size: 12,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .maxSpeed,
                                                                          style:
                                                                              bold.copyWith(
                                                                            fontSize:
                                                                                8,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${initRunningReport[index].maxSpeed.toString()} Km/h',
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              8,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons.adjust,
                                                                  size: 12,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .driveMilage,
                                                                          style:
                                                                              bold.copyWith(
                                                                            fontSize:
                                                                                8,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${NumberFormat.currency(
                                                                          locale:
                                                                              'id',
                                                                          decimalDigits:
                                                                              0,
                                                                          symbol:
                                                                              '',
                                                                        ).format(
                                                                          double.parse(
                                                                                initRunningReport[index].driveMilage.toString(),
                                                                              ) /
                                                                              1000,
                                                                        )} km',
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              8,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        );
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
          ),
        ));
  }
}
