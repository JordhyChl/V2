// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, depend_on_referenced_packages, unused_field, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/parkingreportlist.model.dart';
import 'package:gpsid/pages/fullmap.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class ParkingReportPage extends StatefulWidget {
  final String licensePlate;
  final String imei;
  final String timeStart;
  final String timeEnd;
  final String expDate;
  final String icon;
  final bool darkMode;
  @override
  State<ParkingReportPage> createState() => ParkingReportPageState();

  const ParkingReportPage(
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

class ParkingReportPageState extends State<ParkingReportPage> {
  var size, height, width;
  bool _isError = false;
  String _errCode = '';
  late Future<dynamic> _getParkingReport;
  int page = 1;
  int perPage = 25;
  bool _isData = true;
  late List<ResultParkingModel> initParkingReport;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
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
  static const double _kItemExtent = 32.0;
  static const List<String> setDuration = <String>[
    '1 Minutes',
    '5 Minutes',
    '10 Minutes',
    '15 Minute'
  ];
  int selectedDuration = 0;
  int initDuration = 0;
  String timeStart = '';
  String timeEnd = '';
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  String getDate = '';
  String getTime = '';
  File? displayImage;
  final disp = [];
  String getFinishDate = '';

  @override
  void initState() {
    super.initState();
    _now = DateTime.now().toLocal();
    _getExpired = DateTime.parse(widget.expDate);
    _expDate = _getExpired!.toLocal();
    _diff = _expDate.difference(_now).inDays;
    _getParkingReport = getParkingReport();
    timeStart = widget.timeStart;
    timeEnd = widget.timeEnd;
    durationController.text = setDuration[0];
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
                initParkingReport[index].address = value;
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
          initParkingReport[index].address = addressResult['message'];
          // initStopReport[index].gsmNo = addressResult['message'];
        });
      }
    }
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

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              // padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  refreshParkingReport(int pageR, int perPageR, String imeiR, String timeStartR,
      String timeEndR, int minDuration) async {
    Dialogs().loadingDialog(context);
    APIService()
        .getParkingReport(
            pageR, perPageR, imeiR, timeStartR, timeEndR, minDuration, 86400)
        .then((snapshot) {
      if (snapshot is ErrorTrapModel) {
        Dialogs().hideLoaderDialog(context);
        setState(() {
          _isError = true;
          _errCode = '76853parkingreport';
        });
      } else {
        if (snapshot is MessageModel) {
          // initParkingReport.clear();
          setState(() {
            _isError = true;
            _errCode = '';
            _isData = false;
            totalData = 0;
            totalHour = 0;
          });
          Dialogs().hideLoaderDialog(context);
          Navigator.of(context).pop();
        } else {
          initParkingReport.clear();
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
            initParkingReport.addAll(snapshot.data.result);
            totalData = snapshot.data.totalAllData;
            totalHour = snapshot.data.totalParkingTime;
          });
          Dialogs().hideLoaderDialog(context);
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<dynamic> getParkingReport() async {
    final result = await APIService().getParkingReport(page, perPage,
        widget.imei, widget.timeStart, widget.timeEnd, 60, 86400);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853parkingreport';
      });
    }
    if (result == 'false') {
      setState(() {
        _isError = true;
        _errCode = '76853parkingreport';
      });
    } else {
      String folder = 'localAsset';
      String fileName =
          widget.icon == '12' ? '4_parking.png' : '${widget.icon}_parking.png';
      // String fileName = '${widget.icon}_parking.png';
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final newPath = Directory('${appDir.path}/$folder');
      final imageFile = File(path.setExtension(newPath.path, '/$fileName'));
      setState(() {
        disp.clear();
        disp.add(imageFile);
        displayImage = disp[0];
      });
      Uint8List conv = await displayImage!.readAsBytes();
      BitmapDescriptor getImg = BitmapDescriptor.fromBytes(conv);
      // markerbitmap = await BitmapDescriptor.fromAssetImage(
      //   const ImageConfiguration(),
      //   "assets/park_marker.png",
      // );
      markerbitmap = getImg;
      setState(() {
        if (result is MessageModel) {
          _isData = false;
        } else {
          _isError = false;
          _errCode = '';
          totalData = result.data.totalAllData;
          totalHour = result.data.totalParkingTime;
        }
        startDateController.text = widget.timeStart;
        endDateController.text = widget.timeEnd;
        // durationController.text = '15 Minutes';
      });
    }
    return result;
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
              gradient: widget.darkMode
                  ? LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        whiteCardColor,
                        whiteCardColor,
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        blueGradientSecondary1,
                        blueGradientSecondary2,
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
                        child: Icon(
                          Icons.arrow_back,
                          size: 32,
                          color: widget.darkMode ? whiteColorDarkMode : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.parkingReport,
                        textAlign: TextAlign.center,
                        style: bold.copyWith(
                          fontSize: 16,
                          color: whiteColorDarkMode,
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
                style:
                    reguler.copyWith(fontSize: 12, color: whiteColorDarkMode),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Total data: ${totalData.toString()}',
                style:
                    reguler.copyWith(fontSize: 12, color: whiteColorDarkMode),
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
                      textStyle: TextStyle(
                        color: blackPrimary,
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
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .minDuration,
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
                                                  // bottomSheet(
                                                  //     context,
                                                  //     showDatePicker(
                                                  //         'to')),
                                                  _showDialog(
                                                CupertinoPicker(
                                                  magnification: 1.22,
                                                  squeeze: 1.2,
                                                  backgroundColor:
                                                      whiteCardColor,
                                                  useMagnifier: true,
                                                  scrollController:
                                                      FixedExtentScrollController(
                                                    initialItem: initDuration,
                                                  ),
                                                  itemExtent: _kItemExtent,
                                                  // This is called when selected item is changed.
                                                  onSelectedItemChanged:
                                                      (int selectedItem) {
                                                    setState(() {
                                                      selectedDuration =
                                                          selectedItem;
                                                      selectedDuration == 0
                                                          ? selectedDuration =
                                                              60
                                                          : selectedDuration ==
                                                                  1
                                                              ? selectedDuration =
                                                                  300
                                                              : selectedDuration ==
                                                                      2
                                                                  ? selectedDuration =
                                                                      600
                                                                  : selectedDuration =
                                                                      900;
                                                      durationController.text =
                                                          setDuration[
                                                              selectedItem];
                                                      initDuration =
                                                          selectedItem;
                                                    });
                                                  },
                                                  children:
                                                      List<Widget>.generate(
                                                          setDuration.length,
                                                          (int index) {
                                                    return Center(
                                                      child: Text(
                                                        setDuration[index],
                                                        style: reguler.copyWith(
                                                            fontSize: 14,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),
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
                                                      durationController,
                                                  decoration: InputDecoration(
                                                    fillColor: widget.darkMode
                                                        ? whiteColor
                                                        : whiteCardColor,
                                                    filled: true,
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .chooseDuration,
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
                                          refreshParkingReport(
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
                                    //       refreshParkingReport(
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
                      Expanded(
                        child: Text(
                          '$timeStart - $timeEnd - ${selectedDuration == 60 ? '1 Minute' : selectedDuration == 300 ? '5 Minute' : selectedDuration == 600 ? '10 Minute' : selectedDuration == 900 ? '15 Minute' : '1 Minute'}',
                          textAlign: TextAlign.center,
                          style: reguler.copyWith(
                            fontSize: 11,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : blackSecondary2,
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          backgroundColor: whiteColor,
        ),
        body: Stack(
          children: [
            FutureBuilder(
                future: _getParkingReport,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                    }
                    if (_isData == false) {
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
                                  'assets/handling/parkingreport_empty.png',
                                  height: 240,
                                  width: 240,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .parkreportEmpty,
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
                                        .parkreportEmptySub,
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
                    }
                    if (snapshot.data == '{}') {
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
                                  'assets/handling/parkingreport_empty.png',
                                  height: 240,
                                  width: 240,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .parkreportEmpty,
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
                                        .parkreportEmptySub,
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
                    }
                    if (snapshot.data == 'false') {
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
                                  'assets/handling/parkingreport_empty.png',
                                  height: 240,
                                  width: 240,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .parkreportEmpty,
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
                                        .parkreportEmptySub,
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
                      initParkingReport = snapshot.data.data.result;
                      totalData = snapshot.data.data.totalAllData;
                      totalHour = snapshot.data.data.totalParkingTime;
                      return Container(
                        color: whiteColor,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 10),
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .totalPakingTime,
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
                                  scrollDirection: Axis.vertical,
                                  itemCount: initParkingReport.length,
                                  itemBuilder: (context, index) {
                                    LatLng cPosition = LatLng(
                                      initParkingReport[index].lat,
                                      initParkingReport[index].lon,
                                    );
                                    return Column(
                                      children: [
                                        Container(
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
                                                    offset: Offset(0, 2))
                                              ],
                                              // border: Border.all(
                                              //     width: 1, color: greyColor),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          // shape: RoundedRectangleBorder(
                                          //   borderRadius:
                                          //       BorderRadius.circular(4),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5),
                                                  child: SizedBox(
                                                    width: 120,
                                                    child: Stack(
                                                      children: [
                                                        SizedBox(
                                                          width: 120,
                                                          height: 180,
                                                          child: GoogleMap(
                                                            trafficEnabled:
                                                                false,
                                                            buildingsEnabled:
                                                                true,
                                                            liteModeEnabled:
                                                                Platform.isAndroid
                                                                    ? true
                                                                    : false,
                                                            initialCameraPosition:
                                                                CameraPosition(
                                                              target: cPosition,
                                                              zoom: 13.0,
                                                            ),
                                                            markers:
                                                                Set<Marker>.of(
                                                              {
                                                                Marker(
                                                                  icon:
                                                                      markerbitmap,
                                                                  markerId:
                                                                      MarkerId(
                                                                    cPosition
                                                                        .toString(),
                                                                  ),
                                                                  position:
                                                                      cPosition,
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
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ElevatedButton
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
                                                                            FullMapPage(
                                                                      pLat: initParkingReport[
                                                                              index]
                                                                          .lat,
                                                                      pLng: initParkingReport[
                                                                              index]
                                                                          .lon,
                                                                      plate: initParkingReport[
                                                                              index]
                                                                          .plate,
                                                                      darkMode:
                                                                          widget
                                                                              .darkMode,
                                                                    ),
                                                                  ),
                                                                );
                                                                // Navigator.push(
                                                                //     context,
                                                                //     MaterialPageRoute(
                                                                //         builder: (context) =>
                                                                //             const StopMap()));
                                                              },
                                                              child: Text(
                                                                'Open Maps',
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : whiteColor,
                                                                ),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      TimelineTile(
                                                        afterLineStyle:
                                                            LineStyle(
                                                                color:
                                                                    greyColor,
                                                                thickness: 1),
                                                        indicatorStyle:
                                                            IndicatorStyle(
                                                          indicator: Image.asset(
                                                              'assets/start_icon.png'),
                                                        ),
                                                        isFirst: true,
                                                        endChild: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 12),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .startParking,
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 8,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary3,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                initParkingReport[
                                                                        index]
                                                                    .start,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 8,
                                                                  color:
                                                                      blackPrimary,
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
                                                                color:
                                                                    greyColor,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TimelineTile(
                                                        beforeLineStyle:
                                                            LineStyle(
                                                                color:
                                                                    greyColor,
                                                                thickness: 1),
                                                        indicatorStyle:
                                                            IndicatorStyle(
                                                          indicator: Image.asset(
                                                              'assets/parking_icon.png'),
                                                        ),
                                                        isLast: true,
                                                        endChild: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
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
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .doneParking,
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 8,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary3,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                initParkingReport[
                                                                        index]
                                                                    .end,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 8,
                                                                  color:
                                                                      blackPrimary,
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
                                                                color:
                                                                    greyColor,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .address,
                                                        style: reguler.copyWith(
                                                          fontSize: 8,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: InkWell(
                                                            onLongPress: () {
                                                              getAddressII(
                                                                  initParkingReport[
                                                                          index]
                                                                      .lat
                                                                      .toString(),
                                                                  initParkingReport[
                                                                          index]
                                                                      .lon
                                                                      .toString(),
                                                                  index);
                                                            },
                                                            onTap: () {
                                                              getAddress(
                                                                  initParkingReport[
                                                                          index]
                                                                      .lat
                                                                      .toString(),
                                                                  initParkingReport[
                                                                          index]
                                                                      .lon
                                                                      .toString(),
                                                                  index);
                                                            },
                                                            child: Text(
                                                              initParkingReport[
                                                                      index]
                                                                  .address,
                                                              style:
                                                                  bold.copyWith(
                                                                fontSize: 8,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        'Duration',
                                                        style: reguler.copyWith(
                                                          fontSize: 8,
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        _printDuration(Duration(
                                                            seconds:
                                                                initParkingReport[
                                                                        index]
                                                                    .duration)),
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
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  //SKELETON
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          color: whiteColor,
                          child: Card(
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
                              )),
                        );
                      });
                }),
            // Padding(
            //   padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            //   child: Column(
            //     children: [
            //       Text(
            //         AppLocalizations.of(context)!.totalParking,
            //         style: reguler.copyWith(
            //           fontSize: 12,
            //           color: blackSecondary3,
            //         ),
            //       ),
            //       const SizedBox(
            //         height: 5,
            //       ),
            //       Container(
            //         alignment: Alignment.center,
            //         decoration: BoxDecoration(
            //           color: whiteCardColor,
            //         ),
            //         width: double.infinity,
            //         height: 50,
            //         child: Text(
            //           _printDuration(Duration(seconds: totalHour)),
            //           style: bold.copyWith(
            //             fontSize: 16,
            //             color: blackPrimary,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        )
        //  Container(
        //   padding: const EdgeInsets.all(20),
        //   width: width,
        //   height: height,
        //   child: SingleChildScrollView(
        //     child: Column(
        //       children: [
        //         Text(
        //           AppLocalizations.of(context)!.totalStop,
        //           style: reguler.copyWith(
        //             fontSize: 12,
        //             color: blackSecondary3,
        //           ),
        //         ),
        //         const SizedBox(
        //           height: 5,
        //         ),
        //         Container(
        //           alignment: Alignment.center,
        //           decoration: BoxDecoration(
        //             color: whiteCardColor,
        //           ),
        //           width: double.infinity,
        //           height: 50,
        //           child: Text(
        //             '1 Jam 16 Menit 49 Detik',
        //             style: bold.copyWith(
        //               fontSize: 16,
        //               color: blackPrimary,
        //             ),
        //           ),
        //         ),
        //         const SizedBox(
        //           height: 20,
        //         ),
        //         stopReportModel(context),
        //         const SizedBox(
        //           height: 20,
        //         ),
        //         stopReportModel(context),
        //         const SizedBox(
        //           height: 20,
        //         ),
        //         stopReportModel(context),
        //       ],
        //     ),
        //   ),
        // ),
        );
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
