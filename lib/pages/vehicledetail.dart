// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, unused_field, unused_local_variable, no_leading_underscores_for_local_identifiers, prefer_final_fields, constant_identifier_names, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gpsid/model/checklimit.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/pages/dascham.dart';
import 'package:gpsid/pages/dashcamhistory.dart';
import 'package:gpsid/pages/geometry.model.dart';
import 'package:gpsid/pages/streaminglog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/alarmid.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/poi.model.dart';
import 'package:gpsid/model/sharelocation.model.dart';
import 'package:gpsid/model/vehicledetail.model.dart';
import 'package:gpsid/pages/StreetView.dart';
import 'package:gpsid/pages/alarmreport.dart';
import 'package:gpsid/pages/hourmeter.dart';
import 'package:gpsid/pages/trackreplaypage.dart';
import 'package:gpsid/pages/runningreport.dart';
import 'package:gpsid/pages/parkingreport.dart';
import 'package:gpsid/pages/stopreport.dart';
import 'package:gpsid/pages/vehicleinfo.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/engineControl.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:widget_to_marker/widget_to_marker.dart';

enum PopMenuOption { Traffic, Satellite }

class VehicleDetail extends StatefulWidget {
  final String imei;
  final String expDate;
  final String deviceName;
  final String gpsType;
  final String vehStatus;
  final int icon;
  final bool darkMode;
  const VehicleDetail(
      {Key? key,
      required this.imei,
      required this.expDate,
      required this.deviceName,
      required this.gpsType,
      required this.vehStatus,
      required this.icon,
      required this.darkMode})
      : super(key: key);

  @override
  State<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends State<VehicleDetail>
    with SingleTickerProviderStateMixin {
  // final CustomInfoWindowController _customInfoWindowController =
  //     CustomInfoWindowController();
  TextEditingController textController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final PanelController _panelController = PanelController();
  bool isDisabled = false;
  bool _isError = false;
  String _errCode = '';
  late ErrorTrapModel _errorMessage;
  late Future<dynamic> _getVehicleDetail;
  String plate = '';
  double lat = 0.0;
  double long = 0.0;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  late BitmapDescriptor markerbitmap;
  bool clicked = true;
  late Timer _timer;
  String _refreshLabel = '30';
  int _refreshTime = 30;
  bool callCabin = false;
  bool _myTrafficEnabled = true;
  bool _myMapSatelliteEnabled = false;
  MapType _mapType = MapType.normal;
  GoogleMapController? gMapController;
  late DateTime _now;
  late int _diff;
  DateTime _expDate = DateTime.now();
  DateTime? _getExpired;
  String? _fromDate;
  String? _toDate;
  String? _fromTime = '00:00';
  String? _toTime = '23:59';
  var minimumDate;
  var maximumDate;
  bool _isLoading = false;
  late AlarmIDModel alarmID;
  // final Completer<GoogleMapController> _controller = Completer();
  late List<FeaturesVehicleDetail> feature;
  String shareDuration = '1';
  late VehicleDetailModel vehicleDetail;
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  String getDate = '';
  String getFinishDate = '';
  String getTime = '';
  String address = '';
  late double pLat;
  late double pLong;
  bool vehicleInfo = false;
  File? displayImage;
  final disp = [];
  bool isShow = false;
  bool showPOI = false;
  String lastUpdate = '';
  String alarm = '-';
  bool accOn = false;
  int speed = 0;
  String battery = '';
  String door = '';
  String temperature = '';
  late LinkModel url;
  bool seeAddress = false;
  int angle = 0;
  String mapStyle = '';
  String privilege = '';
  late LocalData localData;
  List<dynamic> countdownTimer = [5, 10, 15, 30, 60];
  int setTimer = 30;
  String setTimerString = '30';
  GeometryModel geometryModel = GeometryModel(polygon: []);
  Set<Polygon> polygon = {};

  @override
  void initState() {
    super.initState();
    _now = DateTime.now().toLocal();
    _getVehicleDetail = getVehicleDetail(widget.vehStatus, widget.icon);
    _getExpired = DateTime.parse(widget.expDate);
    _expDate = _getExpired!.toLocal();
    _diff = _expDate.difference(_now).inDays;
    _fromDate = _diff >= 0
        ? GeneralService().getDate(_now)
        : GeneralService().getDate(_expDate);
    _toDate = _fromDate;
    startDateController.text = '${_fromDate!} ${_fromTime!}';
    startTimeController.text = _fromTime!;
    endDateController.text = '${_toDate!} ${_toTime!}';
    endTimeController.text = _toTime!;
    getLocal();
    rootBundle.loadString('assets/maps.json').then(
      (value) {
        setState(() {
          mapStyle = value;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.isActive ? _timer.cancel() : {};
  }

  getLocal() async {
    localData = await GeneralService().readLocalUserStorage();
  }

  _selectStartDate(BuildContext context, bool isStreamingLog) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        helpText: AppLocalizations.of(context)!.selectStartDate,
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
      _selectStartTime(context, getDate, picked, isStreamingLog);
    }
  }

  _selectStartTime(BuildContext context, String date, DateTime start,
      bool isStreamingLog) async {
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
        helpText: AppLocalizations.of(context)!.selectStartTime,
        context: context,
        initialTime: const TimeOfDay(hour: 00, minute: 00));
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
      isStreamingLog ? _selectFinisDate(context, isStreamingLog) : {};
    }
  }

  _selectFinisDate(BuildContext context, bool isStreamingLog) async {
    DateTime? startDate = DateTime.parse(getFinishDate);
    DateTime? today = DateTime.now();
    late int startFinishDiff;
    late int startFinishDiffExp;
    startFinishDiff = today.difference(startDate).inDays;
    startFinishDiffExp = _expDate.difference(startDate).inDays;
    final DateTime? picked = await showDatePicker(
        context: context,
        helpText: AppLocalizations.of(context)!.selectFinishDate,
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
      _selectFinishTime(context, getDate, isStreamingLog);
    }
  }

  _selectFinishTime(
      BuildContext context, String date, bool isStreamingLog) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      helpText: AppLocalizations.of(context)!.selectFinishTime,
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
      isStreamingLog
          ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamingLog(
                  vehName: vehicleDetail.data.result.plate,
                  imei: widget.imei,
                  timeStart: startDateController.text,
                  timeEnd: endDateController.text,
                  darkMode: widget.darkMode,
                ),
              ))
          : {};
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    // String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigitSeconds;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _refreshLabel = _printDuration(Duration(seconds: _refreshTime));
        _refreshTime--;
        _isLoading = false;
      });
      if (_refreshTime < 0) {
        _timer.cancel();
        _getVehicleDetail = getVehicleDetail(
            vehicleDetail.data.result.vehicleStatus,
            vehicleDetail.data.result.icon);

        // _isEnabled = true;
      }
    });
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

  Future<dynamic> onEnd() async {
    _isLoading = true;
    // Dialogs().showLoaderDialog(context);
    final result = await APIService().getVehicleDetail(widget.imei);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853vehicleDetail';
        _errorMessage = result;
        // initPlatformState();
      });
      // Dialogs().hideLoaderDialog(context);
    } else {
      vehicleDetail = result;
      VehicleDetailModel getVehicleDetail = vehicleDetail;
      String folder = 'localAsset';
      // String fileName = getVehicleDetail.data.result.vehicleStatus
      //                 .toLowerCase() ==
      //             'online' ||
      //         getVehicleDetail.data.result.icon == 12
      //     ? '${vehicleDetail.data.result.icon}_accOn.png'
      //     : getVehicleDetail.data.result.vehicleStatus.toLowerCase() == 'stop'
      //         ? '${vehicleDetail.data.result.icon}_parking.png'
      //         : getVehicleDetail.data.result.vehicleStatus.toLowerCase() ==
      //                 'online'
      //             ? '${vehicleDetail.data.result.icon}_accOn.png'
      //             : '${vehicleDetail.data.result.icon}_${vehicleDetail.data.result.vehicleStatus.toLowerCase()}.png';
      String fileName = vehicleDetail.data.result.vehicleStatus.toLowerCase() !=
              '-'
          ? '${vehicleDetail.data.result.icon}_alarm.png'
          : vehicleDetail.data.result.vehicleStatus.toLowerCase() == 'online'
              ? '${vehicleDetail.data.result.icon}_accOn.png'
              : vehicleDetail.data.result.vehicleStatus.toLowerCase() ==
                      'no data'
                  ? '${vehicleDetail.data.result.icon}_lost.png'
                  : vehicleDetail.data.result.vehicleStatus.toLowerCase() ==
                          'stop'
                      ? '${vehicleDetail.data.result.icon}_parking.png'
                      : '${vehicleDetail.data.result.icon}_${vehicleDetail.data.result.vehicleStatus.toLowerCase()}.png';
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final newPath = Directory('${appDir.path}/$folder');
      final imageFile = File(path.setExtension(newPath.path, '/$fileName'));
      disp.clear();
      disp.add(imageFile);
      displayImage = disp[0];
      Uint8List conv = await displayImage!.readAsBytes();
      BitmapDescriptor getImg = BitmapDescriptor.fromBytes(conv);

      // final Uint8List markerIcon = await getBytesFromAsset(
      //     widget.vehStatus == 'Online'
      //         ? "assets/moving_marker_2.png"
      //         : "assets/stop_marker_2.png",
      //     96);

      // markerbitmap = BitmapDescriptor.fromBytes(markerIcon);
      markerbitmap = getImg;
      // BitmapDescriptor.fromAssetImage(
      //   const ImageConfiguration(size: Size(70, 70)),
      //   widget.vehStatus == 'Online'
      //       ? "assets/moving_marker_2.png"
      //       : "assets/stop_marker_2.png",
      // );
      setState(() {
        _isError = false;
        _errCode = '';
        plate = getVehicleDetail.data.result.plate;
        lat = double.parse(getVehicleDetail.data.result.lat);
        long = double.parse(getVehicleDetail.data.result.lon);
        _refreshLabel = '30';
        _refreshTime = 30;
        lastUpdate = getVehicleDetail.data.result.lastData;
        alarm = getVehicleDetail.data.result.description;
        accOn = getVehicleDetail.data.result.isAccOn;
        speed = getVehicleDetail.data.result.speed;
        battery = getVehicleDetail.data.result.battery;
        door = getVehicleDetail.data.result.door;
        temperature = getVehicleDetail.data.result.temperature;

        gMapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(getVehicleDetail.data.result.lat),
                    double.parse(getVehicleDetail.data.result.lat)),
                zoom: 15.0)));
      });
      _startTimer();
      // Dialogs().hideLoaderDialog(context);
    }
  }

  Future<dynamic> getVehicleDetail(String status, int icon) async {
    address = '';
    _isLoading = true;
    url = await GeneralService().readLocalUrl();
    final result = await APIService().getVehicleDetail(widget.imei);
    if (result is ErrorTrapModel) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errCode = '76853vehicleDetail';
        _errorMessage = result;
        // initPlatformState();
        // _startTimer();
      });
    } else {
      LocalData getLocal = await GeneralService().readLocalUserStorage();
      privilege = getLocal.Privilage.toString();
      DataVehicleDetail getVehicleDetail = result.data;
      String folder = 'localAsset';
      // icon == 12 ? icon = 4 : icon;
      String fileName = getVehicleDetail.result.description.toLowerCase() ==
                  '-' ||
              getVehicleDetail.result.description.toLowerCase() == ''
          ? getVehicleDetail.result.vehicleStatus.toLowerCase() == 'online'
              ? '${getVehicleDetail.result.icon}_accOn.png'
              : getVehicleDetail.result.vehicleStatus.toLowerCase() == 'no data'
                  ? '${getVehicleDetail.result.icon}_lost.png'
                  : getVehicleDetail.result.vehicleStatus.toLowerCase() ==
                          'stop'
                      ? '${getVehicleDetail.result.icon}_parking.png'
                      : '${getVehicleDetail.result.icon}_${getVehicleDetail.result.vehicleStatus.toLowerCase()}.png'
          : '${getVehicleDetail.result.icon}_alarm.png';
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final newPath = Directory('${appDir.path}/$folder');
      final imageFile = File(path.setExtension(newPath.path, '/$fileName'));
      disp.clear();
      disp.add(imageFile);
      displayImage = disp[0];
      Uint8List conv = await displayImage!.readAsBytes();
      BitmapDescriptor getImg = BitmapDescriptor.fromBytes(conv);
      markerbitmap = getImg;
      setState(() {
        _isError = false;
        _errCode = '';
        plate = getVehicleDetail.result.plate;
        lat = double.parse(getVehicleDetail.result.lat);
        long = double.parse(getVehicleDetail.result.lon);
        angle = getVehicleDetail.result.angle;
        lastUpdate = getVehicleDetail.result.lastData;
        alarm = getVehicleDetail.result.description;
        accOn = getVehicleDetail.result.isAccOn;
        speed = getVehicleDetail.result.speed;
        battery = getVehicleDetail.result.battery;
        door = getVehicleDetail.result.door;
        temperature = getVehicleDetail.result.temperature;
        // _refreshLabel = '30';
        // _refreshTime = 30;
        _refreshLabel = setTimerString;
        _refreshTime = setTimer;
        gMapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(getVehicleDetail.result.lat),
                    double.parse(getVehicleDetail.result.lon)),
                zoom: 15.0)));
      });
      _startTimer();
    }
    return result;
  }

  Future<void> bottomSheet(BuildContext context, Widget child,
      {double? height}) {
    return showModalBottomSheet(
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) => SizedBox(
          height: height ?? MediaQuery.of(context).size.height / 3,
          child: child),
    );
  }

  doShareloc(String imei, String hour) async {
    await Dialogs().loadingDialog(context);
    final result = await APIService().doShareLocation(imei, hour);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '93807';
      });
      Navigator.of(context).pop();
      // Alerts()
      //     .showInfoAlert(context, AppLocalizations.of(context).shareFailed);
      showInfoAlert(context, 'Share failed', '');
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
      });
      if (result is ShareLocationModel) {
        Navigator.of(context).pop();
        Share.share(result.data);
      } else {
        Navigator.of(context).pop();
        // Alerts()
        //     .showInfoAlert(context, AppLocalizations.of(context).shareFailed);
        showInfoAlert(context, 'Share failed', '');
      }
    }
  }

  showConfirmShareDialog(BuildContext context) {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: widget.darkMode ? whiteCardColor : whiteColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 350,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
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
                              color:
                                  widget.darkMode ? whiteColorDarkMode : null,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                              child: Image.asset(
                            'assets/mobil_bergerak.png',
                            width: 120,
                            // height: 120.0,
                          )),
                          Text(
                            AppLocalizations.of(context)!.shareLocation,
                            style: bold.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            AppLocalizations.of(context)!.shareLocationDetail,
                            style: reguler.copyWith(
                              fontSize: 10,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary3,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            height: 40,
                            width: 335,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                  color: widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary3,
                                  style: BorderStyle.solid,
                                  width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DropdownButton(
                                  value: shareDuration,
                                  iconSize: 24,
                                  elevation: 16,
                                  dropdownColor: widget.darkMode
                                      ? whiteCardColor
                                      : whiteColor,
                                  style: TextStyle(
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary1,
                                      fontSize: 12),
                                  // underline: Container(
                                  //   height: 2,
                                  //   color: Theme.of(context).primaryColor,
                                  // ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      shareDuration = newValue.toString();
                                    });
                                    doShareloc(widget.imei, shareDuration);
                                  },
                                  items: <String>['1', '3', '6', '12', '24']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text('$value ${'Jam'}'),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
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

  Future<void> getAddressII(String _pLat, String _pLng) async {
    String posDegree =
        '${convertLatLng(double.parse(_pLat), true)} ${convertLatLng(double.parse(_pLng), false)}';
    String gMapsUrl =
        "https://www.google.com/maps/place/$posDegree/@$_pLat,$_pLng,17z";

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
                address = value;
              });
            }
          });
        }
      }
    } else {
      throw Exception();
    }
  }

  Future<void> getAddress(String _pLat, String _pLng) async {
    final _result = await APIService().getAddress(_pLat, _pLng);
    if (_result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '45864';
      });
    } else {
      if (mounted) {
        var addressResult;
        addressResult = json.decode(_result);
        setState(() {
          _isError = false;
          _errCode = '';
          address = addressResult['message'];
        });
      }
    }
  }

  Set<Polygon> myPolygon() {
    Set<Polygon> polygonSet = {};
    showPOI ? polygonSet = polygon : polygonSet = {};

    return polygonSet;
  }

  _setPoi(int changeIndex) async {
    await Dialogs().loadingDialog(context);
    if (_timer.isActive) {
      _timer.cancel();
      int _oldRefreshTime = _refreshTime;
      setState(() {
        _refreshTime = _oldRefreshTime;
      });
    }
    final _poi = await APIService().getPOI();
    if (_poi is ErrorTrapModel) {
      setState(() {});
    } else {
      setState(() {});
      if (_poi is POIModel) {
        geometryModel.polygon.clear();
        _poi.data.result.forEach((el) {
          if (el.geom.startsWith('POLYGON')) {
            String newPolygon = el.geom
                .replaceAll('POLYGON', '')
                .replaceAll('((', '')
                .replaceAll('))', '');
            List<String> a = [newPolygon];
            List<String> b = [];
            List<String> c = [];
            // List<LatLng> latlong = [];
            List<PolygonLatLng> polygonLatLng = [];
            String latitude = '';
            String longitude = '';
            a.reversed.forEach((el1) {
              b = el1.split(',').toList();
            });
            b.forEach((el2) {
              c = el2.toString().split(' ').reversed.toList();
              latitude = c[0];
              longitude = c[1];
              // latlong
              //     .add(LatLng(double.parse(latitude), double.parse(longitude)));
              polygonLatLng.add(PolygonLatLng(lat: latitude, lon: longitude));
            });
            geometryModel.polygon.add(
                PolygonData(polygonID: el.name, polygonLatLng: polygonLatLng));
          }
        });
        print(geometryModel);
        geometryModel.polygon.forEach((setPolygon) {
          List<LatLng> setCoordinates = [];
          if (setPolygon.polygonID == setPolygon.polygonID) {
            setPolygon.polygonLatLng.forEach((setLatLong) {
              setCoordinates.addAll([
                LatLng(
                    double.parse(setLatLong.lat), double.parse(setLatLong.lon))
              ]);
            });
            polygon.add(Polygon(
                polygonId: PolygonId(setPolygon.polygonID),
                points: setCoordinates,
                consumeTapEvents: true,
                strokeWidth: 3,
                fillColor: redPrimary.withOpacity(0.7),
                strokeColor: yellowPrimary));
          }
        });
        print(polygon);

        _poi.data.result.forEach((el) async {
          if (el.geom.toLowerCase().contains('point')) {
            String folder = 'Poi';
            String fileName = '${el.iconId}_${el.iconName}.png';
            final appDir =
                await path_provider.getApplicationDocumentsDirectory();
            final newPath = Directory('${appDir.path}/$folder');
            final imageFile =
                File(path.setExtension(newPath.path, '/$fileName'));
            setState(() {
              disp.clear();
              disp.add(imageFile);
              displayImage = disp[0];
            });
            Uint8List conv = await displayImage!.readAsBytes();
            BitmapDescriptor getImg = BitmapDescriptor.fromBytes(conv);
            final MarkerId markerId = MarkerId(el.id.toString());
            // final Marker poiMarker = _markers[markerId]!;
            final Marker marker = Marker(
              markerId: markerId,
              visible: showPOI,
              position: LatLng(el.lat, el.lon),
              infoWindow: InfoWindow(title: el.name),
              icon: getImg,
            );
            if (this.mounted) {
              setState(() {
                _markers[markerId] = marker;
              });
            }
          } else {
            geometryModel.polygon.forEach((polygonAvailable) async {
              final MarkerId markerId =
                  MarkerId(polygonAvailable.polygonID.toString());
              // final Marker poiMarker = _markers[markerId]!;
              final Marker marker = Marker(
                  markerId: markerId,
                  onTap: () {
                    gMapController?.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                            target: LatLng(
                                double.parse(
                                    polygonAvailable.polygonLatLng[0].lat),
                                double.parse(
                                    polygonAvailable.polygonLatLng[0].lon)),
                            zoom: 16.5)));
                  },
                  visible: showPOI,
                  position: LatLng(
                      double.parse(polygonAvailable.polygonLatLng[0].lat),
                      double.parse(polygonAvailable.polygonLatLng[0].lon)),
                  consumeTapEvents: true,
                  icon: await Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        color: blueSecondary),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Text(
                        'POI: ${polygonAvailable.polygonID}',
                        style: bold.copyWith(fontSize: 12),
                      ),
                    ),
                  ).toBitmapDescriptor());
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = marker;
                });
              }
            });
          }
          // else {
          //   final MarkerId markerId = MarkerId(el.id.toString());
          //   final Marker marker = Marker(
          //     markerId: markerId,
          //     visible: showPOI,
          //     position: LatLng(el.lat, el.lon),
          //     consumeTapEvents: true,
          //     onTap: () {
          //       gMapController?.animateCamera(CameraUpdate.newCameraPosition(
          //           CameraPosition(target: LatLng(el.lat, el.lon), zoom: 17)));
          //     },
          //     icon: await PolygonInfo(
          //       text: el.name,
          //       darkMode: widget.darkMode,
          //     ).toBitmapDescriptor(),
          //   );
          //   if (this.mounted) {
          //     setState(() {
          //       _markers[markerId] = marker;
          //     });
          //   }
          // }
        });
        _startTimer();
      }
    }
    await Dialogs().hideLoaderDialog(context);
    // changeIndex != 1 ? Navigator.pop(context) : {};
    Navigator.pop(context);
  }

  var size, height, width;

  void _currentLocation() async {
    LocationData currentLocation;
    var location = Location();
    currentLocation = await location.getLocation();

    gMapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(double.parse(currentLocation.latitude.toString()),
            double.parse(currentLocation.longitude.toString())),
        zoom: 17.0,
      ),
    ));
  }

  _selectStartDateHistory(BuildContext context, int limit) async {
    String dateChoose = '';
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().toLocal(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now().subtract(const Duration(days: 365)).toLocal(),
        lastDate: DateTime.now().toLocal());
    if (picked != null) {
      dateChoose = DateFormat('yyyy-MM-dd').format(picked);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashcamHistory(
            imei: widget.imei,
            deviceName: widget.deviceName,
            limit: limit,
            date: dateChoose,
            totalCamera: vehicleDetail.data.result.totalCamera,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
  }

  // void togglePanel() =>
  //     clicked ? _panelController.close() : _panelController.open();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      appBar: AppBar(
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
          title: Stack(
            children: [
              InkWell(
                // onTap: () => Navigator.pop(context),
                onTap: () {
                  if (_timer.isActive) {
                    _timer.cancel();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.vehicleDetail,
                        style: bold.copyWith(
                          fontSize: 14,
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                        ),
                      ),
                      Text(
                        widget.deviceName,
                        style: bold.copyWith(
                          fontSize: 10,
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: vehicleInfo,
                      child: GestureDetector(
                        // onTap: () => Navigator.pushNamed(context, '/vehicleinfo'),
                        onTap: () {
                          !_isError
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VehicleInfo(
                                            status: vehicleDetail.data.result
                                                        .vehicleStatus
                                                        .toLowerCase() ==
                                                    'online'
                                                ? AppLocalizations.of(context)!
                                                    .moving
                                                : vehicleDetail.data.result
                                                            .vehicleStatus
                                                            .toLowerCase() ==
                                                        'stop'
                                                    ? AppLocalizations.of(context)!
                                                        .stop
                                                    : vehicleDetail.data.result
                                                                .vehicleStatus
                                                                .toLowerCase() ==
                                                            'parking'
                                                        ? AppLocalizations.of(context)!
                                                            .park
                                                        : vehicleDetail
                                                                    .data
                                                                    .result
                                                                    .vehicleStatus
                                                                    .toLowerCase() ==
                                                                'no data'
                                                            ? AppLocalizations.of(context)!
                                                                .lost
                                                            : vehicleDetail
                                                                .data
                                                                .result
                                                                .vehicleStatus,
                                            odoMeter: vehicleDetail
                                                .data.result.odoMeter
                                                .toString(),
                                            warranty: vehicleDetail
                                                .data.result.lifetimeWarranty,
                                            activeWarranty: widget.expDate,
                                            lastPosition: vehicleDetail
                                                .data.result.lastUpdate,
                                            lastData: vehicleDetail
                                                .data.result.lastData,
                                            pulsaPackageEnd: widget.expDate,
                                            latitude: pLat,
                                            longitude: pLong,
                                            vehiclePositionAddress:
                                                '${vehicleDetail.data.result.lon} ${vehicleDetail.data.result.lat}',
                                            deviceName: widget.deviceName,
                                            gpsType: widget.gpsType,
                                            gsmNumber:
                                                vehicleDetail.data.result.gsmNo,
                                            imei: widget.imei,
                                            plate:
                                                vehicleDetail.data.result.plate,
                                            registerDate: vehicleDetail
                                                .data.result.registerDate,
                                            isDashcam: vehicleDetail.data.result
                                                .features[0].isDashcam,
                                            darkMode: widget.darkMode,
                                          )))
                              : {};
                        },
                        child: Image.asset(
                          widget.darkMode
                              ? 'assets/menuicondark.png'
                              : 'assets/menuicon.png',
                          width: 32,
                        ),
                      )),
                ],
              ),
            ],
          )),
      body: FutureBuilder(
          future: _getVehicleDetail,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is ErrorTrapModel) {
                //SKELETON
                return Container(
                  color: widget.darkMode ? whiteCardColor : whiteColor,
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
                vehicleInfo = true;
                vehicleDetail = snapshot.data;
                pLat = double.parse(vehicleDetail.data.result.lat);
                pLong = double.parse(vehicleDetail.data.result.lon);
                if (vehicleDetail.data.result.features.isNotEmpty) {
                  if (vehicleDetail.data.result.features[0].isCall) {
                    callCabin = true;
                  } else {
                    callCabin = false;
                  }
                } else {
                  callCabin = false;
                }
                // callCabin = vehicleDetail.data.result.features;
                // final Completer<GoogleMapController> _controller = Completer();
                final MarkerId markerId =
                    MarkerId(vehicleDetail.data.result.imei);

                final Marker marker = Marker(
                  markerId: markerId,
                  position: LatLng(pLat, pLong),
                  icon: markerbitmap,
                  rotation: double.parse(angle.toString()),
                );
                _markers[markerId] = marker;
                feature = vehicleDetail.data.result.features;
                lastUpdate = vehicleDetail.data.result.lastData;
                alarm = vehicleDetail.data.result.description;
                accOn = vehicleDetail.data.result.isAccOn;
                speed = vehicleDetail.data.result.speed;
                battery = vehicleDetail.data.result.battery;
                door = vehicleDetail.data.result.door;
                temperature = vehicleDetail.data.result.temperature;

                return SlidingUpPanel(
                  controller: _panelController,
                  maxHeight: address == '' ? 340 : 365,
                  minHeight: 90,
                  color: Colors.transparent,
                  boxShadow: const [],
                  defaultPanelState: PanelState.OPEN,
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      //maps
                      GoogleMap(
                          myLocationEnabled: true,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          markers: Set<Marker>.of(_markers.values),
                          initialCameraPosition: CameraPosition(
                              target: LatLng(pLat, pLong), zoom: 15),
                          onMapCreated: (controller) {
                            setState(() {
                              gMapController = controller;
                            });
                          },
                          polygons: myPolygon(),
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          trafficEnabled: _myTrafficEnabled,
                          mapType: _mapType),

                      Positioned(
                        left: 20,
                        // right: 21,
                        top: 25,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Row(
                            //   children: [
                            //     Image.asset(
                            //       'assets/whatsapp.png',
                            //       width: 99,
                            //     ),
                            //   ],
                            // ),
                            Visibility(
                                visible: !localData.IsGenerated
                                    ? vehicleDetail
                                        .data.result.features[0].isDashcam
                                    : false,
                                child: InkWell(
                                  child: Container(
                                      width: 134,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: widget.darkMode
                                            ? whiteCardColor
                                            : bluePrimary,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 3),
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_rounded,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : whiteColor,
                                              size: 18,
                                            ),
                                            Text(
                                              'Live Camera',
                                              style: reguler.copyWith(
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : whiteColor,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      )),
                                  onTap: () async {
                                    // Navigator.pushNamed(context, '/dashcam');
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => DashcamSample(
                                    //       imei: vehicleDetail.data.result.imei,
                                    //       vehName: widget.deviceName,
                                    //     ),
                                    //   ),
                                    // );

                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: widget.darkMode
                                          ? whiteCardColor
                                          : whiteColor,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10))),
                                      builder: (context) {
                                        return SizedBox(
                                          width: double.infinity,
                                          height: 150,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.start,
                                              //   children: [
                                              //     Padding(
                                              //       padding: const EdgeInsets
                                              //               .symmetric(
                                              //           horizontal: 13),
                                              //       child: Text(
                                              //         'Live Stream',
                                              //         style: reguler.copyWith(
                                              //             color: blackPrimary,
                                              //             fontSize: 14),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: InkWell(
                                                  onTap: () async {
                                                    Dialogs()
                                                        .loadingDialog(context);

                                                    final limitResult =
                                                        await APIService()
                                                            .checkLimit(
                                                                widget.imei,
                                                                'RTMP,ON,INOUT');
                                                    if (limitResult
                                                        is CheckLimitModel) {
                                                      if (limitResult.status) {
                                                        if (limitResult.data
                                                                .limitLive ==
                                                            0) {
                                                          Dialogs()
                                                              .hideLoaderDialog(
                                                                  context);
                                                          showInfoAlert(
                                                              context,
                                                              'Your limit is up, Please Top up',
                                                              '');
                                                        } else {
                                                          Dialogs()
                                                              .hideLoaderDialog(
                                                                  context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Dashcam(
                                                                imei:
                                                                    widget.imei,
                                                                expDate: widget
                                                                    .expDate,
                                                                deviceName: widget
                                                                    .deviceName,
                                                                gpsType: widget
                                                                    .gpsType,
                                                                vehStatus: widget
                                                                    .vehStatus,
                                                                icon:
                                                                    widget.icon,
                                                                isDashcam:
                                                                    vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .features[
                                                                            0]
                                                                        .isDashcam,
                                                                limit: limitResult
                                                                    .data
                                                                    .limitLive,
                                                                totalCamera:
                                                                    vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .totalCamera,
                                                                darkMode: widget
                                                                    .darkMode,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        Dialogs()
                                                            .hideLoaderDialog(
                                                                context);
                                                        showInfoAlert(
                                                            context,
                                                            limitResult.message,
                                                            '');
                                                      }
                                                    } else {
                                                      if (limitResult
                                                          is MessageModel) {
                                                        Dialogs()
                                                            .hideLoaderDialog(
                                                                context);
                                                        showInfoAlert(
                                                            context,
                                                            limitResult.message ==
                                                                    'Unable to load data, Please wait and refresh this page.'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .errorPushing
                                                                : limitResult
                                                                            .message ==
                                                                        'Your device is currently busy, Please wait and refresh this page.'
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .errorBusy
                                                                    : limitResult
                                                                        .message,
                                                            limitResult.message ==
                                                                    'Unable to load data, Please wait and refresh this page.'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .errorPushingSub
                                                                : limitResult
                                                                            .message ==
                                                                        'Your device is currently busy, Please wait and refresh this page.'
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .errorPushingSub
                                                                    : '');
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                      width: double.infinity,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: bluePrimary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child:
                                                                  Image.asset(
                                                                'assets/icon/dashcam/dashcam.png',
                                                                width: 20,
                                                                height: 20,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : whiteColor,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Live Stream',
                                                              style: reguler.copyWith(
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : whiteColor,
                                                                  fontSize: 10),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: InkWell(
                                                  onTap: () async {
                                                    Dialogs()
                                                        .loadingDialog(context);

                                                    final limitResult =
                                                        await APIService()
                                                            .checkLimit(
                                                                widget.imei,
                                                                'RTMP,ON,INOUT');
                                                    if (limitResult
                                                        is CheckLimitModel) {
                                                      if (limitResult.status) {
                                                        if (limitResult.data
                                                                .limitLive ==
                                                            0) {
                                                          Dialogs()
                                                              .hideLoaderDialog(
                                                                  context);
                                                          showInfoAlert(
                                                              context,
                                                              'Your limit is up, Please Top up',
                                                              '');
                                                        } else {
                                                          Dialogs()
                                                              .hideLoaderDialog(
                                                                  context);
                                                          _selectStartDateHistory(
                                                              context,
                                                              limitResult.data
                                                                  .limitLive);
                                                        }
                                                      } else {
                                                        Dialogs()
                                                            .hideLoaderDialog(
                                                                context);
                                                        showInfoAlert(
                                                            context,
                                                            limitResult.message,
                                                            '');
                                                      }
                                                    } else {
                                                      if (limitResult
                                                          is MessageModel) {
                                                        Dialogs()
                                                            .hideLoaderDialog(
                                                                context);
                                                        // showInfoAlert(
                                                        //     context,
                                                        //     limitResult.message,
                                                        //     '');
                                                        showInfoAlert(
                                                            context,
                                                            limitResult.message ==
                                                                    'Unable to load data, Please wait and refresh this page.'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .errorPushing
                                                                : limitResult
                                                                            .message ==
                                                                        'Your device is currently busy, Please wait and refresh this page.'
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .errorBusy
                                                                    : limitResult
                                                                        .message,
                                                            limitResult.message ==
                                                                    'Unable to load data, Please wait and refresh this page.'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .errorPushingSub
                                                                : limitResult
                                                                            .message ==
                                                                        'Your device is currently busy, Please wait and refresh this page.'
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .errorPushingSub
                                                                    : '');
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                      width: double.infinity,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        border: Border.all(
                                                            color: bluePrimary),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        // boxShadow: const [
                                                        //   BoxShadow(
                                                        //     color: Colors.grey,
                                                        //     offset:
                                                        //         Offset(0.0, 3),
                                                        //     blurRadius: 5.0,
                                                        //   ),
                                                        // ],
                                                      ),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // Icon(
                                                            //   Icons
                                                            //       .camera_rounded,
                                                            //   color: whiteColor,
                                                            //   size: 20,
                                                            // ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child:
                                                                  Image.asset(
                                                                'assets/icon/dashcam/history.png',
                                                                width: 20,
                                                                height: 20,
                                                                color:
                                                                    bluePrimary,
                                                              ),
                                                            ),
                                                            Text(
                                                              'History',
                                                              style: reguler
                                                                  .copyWith(
                                                                      color:
                                                                          bluePrimary,
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: InkWell(
                                                  onTap: () async {
                                                    _selectStartDate(
                                                        context, true);
                                                  },
                                                  child: SizedBox(
                                                      width: double.infinity,
                                                      height: 32,
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                                child: Icon(
                                                                  Icons
                                                                      .list_outlined,
                                                                  size: 20,
                                                                  color:
                                                                      bluePrimary,
                                                                )),
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .logStreaming,
                                                              style: reguler.copyWith(
                                                                  color:
                                                                      bluePrimary,
                                                                  fontSize: 10,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                    // showModalBottomSheet(
                                    //   context: context,
                                    //   builder: (context) {
                                    //     return SizedBox(
                                    //       width: double.infinity,
                                    //       height: 100,
                                    //       child: Row(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.spaceAround,
                                    //         children: [
                                    //           Container(
                                    //               width: 134,
                                    //               height: 32,
                                    //               decoration: BoxDecoration(
                                    //                 color: bluePrimary,
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                         15),
                                    //                 boxShadow: const [
                                    //                   BoxShadow(
                                    //                     color: Colors.grey,
                                    //                     offset: Offset(0.0, 3),
                                    //                     blurRadius: 5.0,
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //               child: Center(
                                    //                 child: Row(
                                    //                   mainAxisAlignment:
                                    //                       MainAxisAlignment
                                    //                           .center,
                                    //                   children: [
                                    //                     Icon(
                                    //                       Icons.camera_rounded,
                                    //                       color: whiteColor,
                                    //                       size: 20,
                                    //                     ),
                                    //                     Text(
                                    //                       'Live Stream',
                                    //                       style:
                                    //                           reguler.copyWith(
                                    //                               color:
                                    //                                   whiteColor,
                                    //                               fontSize: 16),
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               )),
                                    //           Container(
                                    //               width: 134,
                                    //               height: 32,
                                    //               decoration: BoxDecoration(
                                    //                 color: bluePrimary,
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                         15),
                                    //                 boxShadow: const [
                                    //                   BoxShadow(
                                    //                     color: Colors.grey,
                                    //                     offset: Offset(0.0, 3),
                                    //                     blurRadius: 5.0,
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //               child: Center(
                                    //                 child: Row(
                                    //                   mainAxisAlignment:
                                    //                       MainAxisAlignment
                                    //                           .center,
                                    //                   children: [
                                    //                     Icon(
                                    //                       Icons.camera_rounded,
                                    //                       color: whiteColor,
                                    //                       size: 20,
                                    //                     ),
                                    //                     Text(
                                    //                       'History',
                                    //                       style:
                                    //                           reguler.copyWith(
                                    //                               color:
                                    //                                   whiteColor,
                                    //                               fontSize: 16),
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               ))
                                    //         ],
                                    //       ),
                                    //     );
                                    //   },
                                    // );
                                  },
                                )),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 21,
                        right: 21,
                        top: 25,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Row(
                            //   children: [
                            //     Image.asset(
                            //       'assets/whatsapp.png',
                            //       width: 99,
                            //     ),
                            //   ],
                            // ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                    visible: true,
                                    child: InkWell(
                                      child: Container(
                                        width: 70,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: widget.darkMode
                                              ? whiteCardColor
                                              : bluePrimary,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 3),
                                              blurRadius: 5.0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/time.png',
                                              width: 20,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : whiteColor,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Visibility(
                                              visible:
                                                  _isLoading ? true : false,
                                              child: SizedBox(
                                                width: 22,
                                                child: Stack(
                                                  children: [
                                                    Center(
                                                      child: Stack(
                                                        children: [
                                                          Image.asset(
                                                            'assets/logoss.png',
                                                            height: 16,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : whiteColor,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Center(
                                                      child: LoadingAnimationWidget
                                                          .discreteCircle(
                                                              size: 23,
                                                              // color:
                                                              //     blueGradientSecondary2,
                                                              // secondRingColor:
                                                              //     blueGradientSecondary1,
                                                              // thirdRingColor:
                                                              //     whiteColor,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : whiteColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  _isLoading ? false : true,
                                              child: SizedBox(
                                                  width: 22,
                                                  child: Text(
                                                    _refreshLabel,
                                                    style: reguler.copyWith(
                                                        fontSize: 16,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor),
                                                  )
                                                  // GradientText(
                                                  //   _refreshLabel,
                                                  //   style: reguler.copyWith(
                                                  //       fontSize: 16),
                                                  //   colors: [
                                                  //     bgy1,
                                                  //     bgy2,
                                                  //     bgy3,
                                                  //   ],
                                                  // ),
                                                  ),
                                            )
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        // if (_timer.isActive) {
                                        //   _timer.cancel();
                                        //   _getVehicleDetail = getVehicleDetail(
                                        //       vehicleDetail
                                        //           .data.result.vehicleStatus,
                                        //       vehicleDetail.data.result.icon);
                                        // }
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            isDismissible: true,
                                            backgroundColor: whiteCardColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight:
                                                      Radius.circular(12)),
                                            ),
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      StateSetter
                                                          setStateModal) {
                                                return SingleChildScrollView(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 5,
                                                        horizontal: 15),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          countdownTimer.length,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                // selected = index;
                                                                setTimer =
                                                                    countdownTimer[
                                                                        index];
                                                                setTimerString =
                                                                    countdownTimer[
                                                                            index]
                                                                        .toString();
                                                              });
                                                              if (_timer
                                                                  .isActive) {
                                                                _timer.cancel();
                                                                _getVehicleDetail = getVehicleDetail(
                                                                    vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .vehicleStatus,
                                                                    vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .icon);
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Center(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            12.0),
                                                                        child:
                                                                            Text(
                                                                          '${countdownTimer[index]} ${AppLocalizations.of(context)!.second}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: reguler.copyWith(
                                                                              fontSize: 14,
                                                                              color: widget.darkMode ? whiteColorDarkMode : blackSecondary2),
                                                                        ),
                                                                      )),
                                                                  Divider(
                                                                    height: 1,
                                                                    thickness:
                                                                        1,
                                                                    indent: 0,
                                                                    endIndent:
                                                                        0,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : greyColorSecondary,
                                                                  ),
                                                                ],
                                                              ),
                                                            ));
                                                      },
                                                    ),
                                                  ),
                                                );
                                              });
                                            });
                                      },
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                      // Slidable(
                      //   // Specify a key if the Slidable is dismissible.
                      //   key: const ValueKey(0),

                      //   // The start action pane is the one at the left or the top side.
                      //   // startActionPane: ActionPane(
                      //   //   // A motion is a widget used to control how the pane animates.
                      //   //   motion: const ScrollMotion(),

                      //   //   // A pane can dismiss the Slidable.
                      //   //   dismissible: DismissiblePane(onDismissed: () {}),

                      //   //   // All actions are defined in the children parameter.
                      //   //   children: [
                      //   //     // A SlidableAction can have an icon and/or a label.
                      //   //     SlidableAction(
                      //   //       onPressed: doNothing,
                      //   //       backgroundColor: Color(0xFFFE4A49),
                      //   //       foregroundColor: Colors.white,
                      //   //       icon: Icons.delete,
                      //   //       label: 'Delete',
                      //   //     ),
                      //   //     SlidableAction(
                      //   //       onPressed: doNothing,
                      //   //       backgroundColor: Color(0xFF21B7CA),
                      //   //       foregroundColor: Colors.white,
                      //   //       icon: Icons.share,
                      //   //       label: 'Share',
                      //   //     ),
                      //   //   ],
                      //   // ),

                      //   // The end action pane is the one at the right or the bottom side.
                      //   endActionPane: ActionPane(
                      //     motion: const ScrollMotion(),
                      //     children: [
                      //       Column(
                      //         children: [
                      //           Text('asdasd'),
                      //           Text('asdasd'),
                      //           Text('asdasd'),
                      //           Text('asdasd'),
                      //         ],
                      //       ),
                      //       SlidableAction(
                      //         // An action can be bigger than the others.
                      //         flex: 2,
                      //         onPressed: doNothing,
                      //         backgroundColor: Color(0xFF7BC043),
                      //         foregroundColor: Colors.white,
                      //         icon: Icons.archive,
                      //         label: 'Archive',
                      //       ),
                      //       SlidableAction(
                      //         onPressed: doNothing,
                      //         backgroundColor: Color(0xFF0392CF),
                      //         foregroundColor: Colors.white,
                      //         icon: Icons.save,
                      //         label: 'Save',
                      //       ),
                      //     ],
                      //   ),

                      //   // The child of the Slidable is what the user sees when the
                      //   // component is not dragged.
                      //   child:
                      //       const ListTile(title: Icon(Icons.arrow_back_ios)),
                      // ),

                      Positioned(
                        // left: ,
                        right: 20,
                        top: 65,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isDismissible: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      context: context,
                                      backgroundColor: whiteCardColor,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return SizedBox(
                                              height: 316,
                                              width: double.infinity,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .mapStyle,
                                                              style: reguler.copyWith(
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary1,
                                                                  fontSize:
                                                                      16)),
                                                          InkWell(
                                                            onTap: () {
                                                              launchUrl(
                                                                  mode: LaunchMode
                                                                      .externalApplication,
                                                                  Uri.parse(
                                                                      'https://www.google.com/maps/search/?api=1&query=$pLat,$pLong'));
                                                            },
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .showonGMaps,
                                                              style: reguler.copyWith(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  fontSize: 10,
                                                                  color:
                                                                      bluePrimary),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 12),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _myMapSatelliteEnabled =
                                                                        false;
                                                                    _mapType =
                                                                        MapType
                                                                            .normal;

                                                                    // _myMapSatelliteEnabled =
                                                                    //     !_myMapSatelliteEnabled;
                                                                    // _mapType = _myMapSatelliteEnabled
                                                                    //     ? MapType
                                                                    //         .satellite
                                                                    //     : MapType
                                                                    //         .normal;
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 36,
                                                                  // width: 159,
                                                                  decoration: BoxDecoration(
                                                                      color: _myMapSatelliteEnabled
                                                                          ? null
                                                                          : whiteColor,
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: !_myMapSatelliteEnabled
                                                                              ? bluePrimary
                                                                              : greyColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .location_on_outlined,
                                                                        color: !_myMapSatelliteEnabled
                                                                            ? bluePrimary
                                                                            : greyColor,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .defaultMap,
                                                                        style: reguler.copyWith(
                                                                            fontSize: 12,
                                                                            color: !_myMapSatelliteEnabled
                                                                                ? bluePrimary
                                                                                : widget.darkMode
                                                                                    ? whiteColorDarkMode
                                                                                    : greyColor),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Expanded(
                                                              flex: 1,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _myMapSatelliteEnabled =
                                                                        true;
                                                                    _mapType =
                                                                        MapType
                                                                            .satellite;
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 36,
                                                                  // width: 159,
                                                                  decoration: BoxDecoration(
                                                                      color: !_myMapSatelliteEnabled
                                                                          ? null
                                                                          : whiteColor,
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: !_myMapSatelliteEnabled
                                                                              ? greyColor
                                                                              : bluePrimary),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .map_outlined,
                                                                        color: !_myMapSatelliteEnabled
                                                                            ? greyColor
                                                                            : bluePrimary,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .satelliteMap,
                                                                        style: reguler.copyWith(
                                                                            fontSize: 12,
                                                                            color: _myMapSatelliteEnabled
                                                                                ? bluePrimary
                                                                                : widget.darkMode
                                                                                    ? whiteColorDarkMode
                                                                                    : greyColor),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .mapDetail,
                                                              style: reguler.copyWith(
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : blackSecondary1,
                                                                  fontSize:
                                                                      16)),
                                                          // Text(
                                                          //   'Tampilkan di Google Maps',
                                                          //   style: reguler.copyWith(
                                                          //       fontStyle:
                                                          //           FontStyle
                                                          //               .italic,
                                                          //       decoration:
                                                          //           TextDecoration
                                                          //               .underline,
                                                          //       fontSize: 10,
                                                          //       color:
                                                          //           bluePrimary),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => StreetView(
                                                                    Latitude: double.parse(
                                                                        vehicleDetail
                                                                            .data
                                                                            .result
                                                                            .lat),
                                                                    Longitude: double.parse(
                                                                        vehicleDetail
                                                                            .data
                                                                            .result
                                                                            .lon),
                                                                    Angle:
                                                                        angle)));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 12),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/mapdetail/streetview.png',
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              15),
                                                                  child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .streetView,
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                          fontSize:
                                                                              12)),
                                                                ),
                                                              ],
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_rounded,
                                                              size: 20,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blueGradient,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8,
                                                              bottom: 3),
                                                      child: Divider(
                                                        height: .5,
                                                        thickness: .5,
                                                        endIndent: 0,
                                                        indent: 0,
                                                        color: greyColor,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _myTrafficEnabled =
                                                              !_myTrafficEnabled;
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            // width: 285,
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/mapdetail/traffic.png',
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              15),
                                                                  child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .trafficView,
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                          fontSize:
                                                                              12)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Switch(
                                                            value:
                                                                _myTrafficEnabled,
                                                            // activeColor: blackPrimary,
                                                            // activeThumbImage:
                                                            //     const AssetImage(
                                                            //         'assets/mapcenter.png'),
                                                            // inactiveThumbImage:
                                                            //     const AssetImage(
                                                            //         'assets/mapcenter.png'),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _myTrafficEnabled =
                                                                    !_myTrafficEnabled;
                                                              });
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 3,
                                                              bottom: 3),
                                                      child: Divider(
                                                        height: .5,
                                                        thickness: .5,
                                                        endIndent: 0,
                                                        indent: 0,
                                                        color: greyColor,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (showPOI == true) {
                                                          setState(() {
                                                            showPOI = false;
                                                          });
                                                          _setPoi(1);
                                                        } else {
                                                          setState(() {
                                                            showPOI = true;
                                                          });
                                                          _setPoi(1);
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            // width: 285,
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/mapdetail/poi.png',
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              15),
                                                                  child: Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .poiView,
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                          fontSize:
                                                                              12)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Switch(
                                                            value: showPOI,
                                                            // activeColor: blackPrimary,
                                                            // activeThumbImage:
                                                            //     const AssetImage(
                                                            //         'assets/mapcenter.png'),
                                                            // inactiveThumbImage:
                                                            //     const AssetImage(
                                                            //         'assets/mapcenter.png'),
                                                            onChanged: (value) {
                                                              if (showPOI ==
                                                                  true) {
                                                                setState(() {
                                                                  showPOI =
                                                                      false;
                                                                });
                                                                _setPoi(1);
                                                              } else {
                                                                setState(() {
                                                                  showPOI =
                                                                      true;
                                                                });
                                                                _setPoi(1);
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Image.asset(
                                    widget.darkMode
                                        ? 'assets/iconmenuactivedark.png'
                                        : 'assets/iconmenuactive.png',
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    final MarkerId markerId = MarkerId(
                                        vehicleDetail.data.result.imei);
                                    // _doCenter(markerId);
                                    gMapController?.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target: LatLng(
                                                    double.parse(vehicleDetail
                                                        .data.result.lat),
                                                    double.parse(vehicleDetail
                                                        .data.result.lon)),
                                                zoom: 15.0)));
                                  },
                                  child: Image.asset(
                                    widget.darkMode
                                        ? 'assets/mapicondark.png'
                                        : 'assets/mapicon.png',
                                    width: 40,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () async {
                                    // launchUrl(
                                    //     Uri.parse(url.data.results.whatsapp),
                                    //     mode: LaunchMode.externalApplication);
                                    Dialogs().loadingDialog(context);
                                    LinkModel url =
                                        await GeneralService().readLocalUrl();
                                    Dialogs().hideLoaderDialog(context);
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      backgroundColor: widget.darkMode
                                          ? whiteCardColor
                                          : whiteColor,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12)),
                                      ),
                                      context: context,
                                      builder: (context) {
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
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Icon(
                                                                Icons.close,
                                                                size: 30,
                                                                color:
                                                                    blackPrimary,
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
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary3),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    enableFeedback: url
                                                                .data
                                                                .branch
                                                                .whatsapp ==
                                                            ''
                                                        ? false
                                                        : true,
                                                    onTap: () {
                                                      if (url.data.branch
                                                              .whatsapp !=
                                                          '') {
                                                        launchUrl(
                                                            Uri.parse(
                                                                'https://wa.me/${url.data.branch.whatsapp}?text=Halo%20SUPERSPRING%2C%20%0A%0Asaya%20pengguna%20GPS.id%20dengan%20username%20${localData.Username}.%20Saya%20sedang%20mengalami%20kendala%20saat%20mengakses%20informasi%20kendaraan%20dengan%20plat%20nomor%20${vehicleDetail.data.result.plate}.%20Mohon%20dibantu%20untuk%20pengecekan%20lebih%20lanjut.'),
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 5),
                                                      child: Container(
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: whiteColor,
                                                          // color: all ? blueGradient : whiteColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                            width: 1,
                                                            color: url
                                                                        .data
                                                                        .branch
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
                                                                  // Icon(
                                                                  //   Icons
                                                                  //       .whatsapp_outlined,
                                                                  //   color: url.data.branch.whatsapp ==
                                                                  //           ''
                                                                  //       ? greyColor
                                                                  //       : greenPrimary,
                                                                  //   size: 15,
                                                                  // ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            2),
                                                                    child: Text(
                                                                        AppLocalizations.of(context)!
                                                                            .installationBranch,
                                                                        style: bold.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: url.data.branch.whatsapp == ''
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
                                                      // 'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'
                                                      launchUrl(
                                                          Uri.parse(
                                                              'https://wa.me/${url.data.head.whatsapp}?text=Halo%20SUPERSPRING%2C%20%0A%0Asaya%20pengguna%20GPS.id%20dengan%20username%20${localData.Username}.%20Saya%20sedang%20mengalami%20kendala%20saat%20mengakses%20informasi%20kendaraan%20dengan%20plat%20nomor%20${vehicleDetail.data.result.plate}.%20Mohon%20dibantu%20untuk%20pengecekan%20lebih%20lanjut.'),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: greenPrimary,
                                                          // color: all ? blueGradient : whiteColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
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
                                                                  // Icon(
                                                                  //   Icons
                                                                  //       .whatsapp_outlined,
                                                                  //   color:
                                                                  //       whiteColor,
                                                                  //   size: 15,
                                                                  // ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            2),
                                                                    child: Text(
                                                                        AppLocalizations.of(context)!
                                                                            .cc24H,
                                                                        style: bold.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                whiteColor)),
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
                                  child: Image.asset(
                                    'assets/WA.png',
                                    width: 40,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: InkWell(
                                    onTap: () {
                                      _currentLocation();
                                      // getLocation();
                                    },
                                    child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                            color: widget.darkMode
                                                ? whiteCardColor
                                                : blueGradient,
                                            boxShadow: [
                                              BoxShadow(
                                                color: blackSecondary2,
                                                offset: const Offset(0.0, 3),
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(32)),
                                        child: Icon(
                                          Icons.location_searching,
                                          size: 18,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : whiteColor,
                                        )),
                                  ),
                                )
                              ],
                            ),
                            // Column(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     InkWell(
                            //       onTap: () {
                            //         final MarkerId markerId = MarkerId(
                            //             vehicleDetail.data.result.imei);
                            //         // _doCenter(markerId);
                            //         gMapController?.animateCamera(CameraUpdate
                            //             .newCameraPosition(CameraPosition(
                            //                 target: LatLng(
                            //                     vehicleDetail.data.result.lat,
                            //                     vehicleDetail.data.result.lon),
                            //                 zoom: 15.0)));
                            //       },
                            //       child: Image.asset(
                            //         'assets/mapicon.png',
                            //         width: 40,
                            //       ),
                            //     ),
                            //     const SizedBox(
                            //       height: 8,
                            //     ),
                            //     Image.asset(
                            //       'assets/WA.png',
                            //       width: 40,
                            //     ),
                            //     const SizedBox(
                            //       height: 8,
                            //     ),

                            //     // InkWell(
                            //     //   onTap: () async {
                            //     //     if (_timer.isActive) {
                            //     //       _timer.cancel();
                            //     //       await onEnd();
                            //     //     }
                            //     //   },
                            //     //   child: Image.asset(
                            //     //     'assets/refreshicon.png',
                            //     //     width: 32,
                            //     //   ),
                            //     // )
                            //   ],
                            // )
                          ],
                        ),
                      ),
                    ],
                  ),
                  panelBuilder: (controller) {
                    return Column(children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Column(children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      clicked = !clicked;
                                    });
                                    !clicked
                                        ? _panelController.close()
                                        : _panelController.open();
                                    // togglePanel();
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: widget.darkMode
                                          ? whiteCardColor
                                          : bluePrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.darkMode
                                              ? whiteCardColor
                                              : Colors.grey,
                                          offset: const Offset(0.0, 3),
                                          blurRadius: 9.0,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: clicked
                                        ? Icon(
                                            Icons.expand_more,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : whiteColor,
                                            size: 30,
                                          )
                                        : Icon(
                                            Icons.expand_less,
                                            size: 30,
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : whiteColor,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    // width: 74,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: vehicleDetail.data.result
                                                          .description ==
                                                      '-' ||
                                                  vehicleDetail.data.result
                                                          .description ==
                                                      ''
                                              ? vehicleDetail.data.result
                                                          .vehicleStatus ==
                                                      'Alarm'
                                                  ? redPrimary
                                                  : vehicleDetail.data.result
                                                              .vehicleStatus ==
                                                          'Lost'
                                                      ? yellowPrimary
                                                      : vehicleDetail
                                                                  .data
                                                                  .result
                                                                  .vehicleStatus
                                                                  .toLowerCase() ==
                                                              'no data'
                                                          ? yellowPrimary
                                                          : vehicleDetail
                                                                      .data
                                                                      .result
                                                                      .vehicleStatus ==
                                                                  'Online'
                                                              ? bluePrimary
                                                              : blackSecondary1
                                              : redPrimary,
                                          width: 1),
                                      color: vehicleDetail.data.result
                                                      .description ==
                                                  '-' ||
                                              vehicleDetail.data.result
                                                      .description ==
                                                  ''
                                          ? vehicleDetail.data.result
                                                      .vehicleStatus ==
                                                  'Alarm'
                                              ? redPrimary
                                              : vehicleDetail.data.result
                                                          .vehicleStatus ==
                                                      'Lost'
                                                  ? yellowPrimary
                                                  : vehicleDetail.data.result
                                                              .vehicleStatus
                                                              .toLowerCase() ==
                                                          'no data'
                                                      ? yellowPrimary
                                                      : vehicleDetail
                                                                  .data
                                                                  .result
                                                                  .vehicleStatus ==
                                                              'Online'
                                                          ? bluePrimary
                                                          : blackSecondary1
                                          : redPrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.darkMode
                                              ? whiteCardColor
                                              : Colors.grey,
                                          offset: const Offset(0.0, 1.0),
                                          blurRadius: 9.0,
                                        ),
                                      ],
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 13.3,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : whiteColor,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                vehicleDetail.data.result.description == '-' ||
                                                        vehicleDetail.data.result.description ==
                                                            ''
                                                    ? vehicleDetail.data.result.vehicleStatus
                                                                .toLowerCase() ==
                                                            'online'
                                                        ? AppLocalizations.of(context)!
                                                            .moving
                                                            .toUpperCase()
                                                        : vehicleDetail.data.result.vehicleStatus.toLowerCase() ==
                                                                'parking'
                                                            ? AppLocalizations.of(context)!
                                                                .park
                                                                .toUpperCase()
                                                            : vehicleDetail.data.result.vehicleStatus.toLowerCase() ==
                                                                    'stop'
                                                                ? AppLocalizations.of(context)!
                                                                    .stop
                                                                    .toUpperCase()
                                                                : vehicleDetail.data.result.vehicleStatus.toLowerCase() ==
                                                                        'no data'
                                                                    ? AppLocalizations.of(context)!
                                                                        .lost
                                                                        .toUpperCase()
                                                                    : vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .vehicleStatus
                                                                        .toUpperCase()
                                                    : AppLocalizations.of(context)!
                                                        .alarm
                                                        .toUpperCase(),
                                                style: reguler.copyWith(
                                                    fontSize: 10,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : whiteColor)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    vehicleDetail.data.result
                                                                .engine.day ==
                                                            0
                                                        ? ''
                                                        : vehicleDetail
                                                                    .data
                                                                    .result
                                                                    .engine
                                                                    .day >
                                                                1
                                                            ? '${vehicleDetail.data.result.engine.day} ${AppLocalizations.of(context)!.day}s '
                                                            : '${vehicleDetail.data.result.engine.day} ${AppLocalizations.of(context)!.day} ',
                                                    style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor)),
                                                Text(
                                                    vehicleDetail.data.result
                                                                .engine.hour ==
                                                            0
                                                        ? ''
                                                        : vehicleDetail
                                                                    .data
                                                                    .result
                                                                    .engine
                                                                    .hour >
                                                                1
                                                            ? '${vehicleDetail.data.result.engine.hour} ${AppLocalizations.of(context)!.hour}s '
                                                            : '${vehicleDetail.data.result.engine.hour} ${AppLocalizations.of(context)!.hour} ',
                                                    style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor)),
                                                Text(
                                                    vehicleDetail
                                                                .data
                                                                .result
                                                                .engine
                                                                .minute ==
                                                            0
                                                        ? ''
                                                        : vehicleDetail
                                                                    .data
                                                                    .result
                                                                    .engine
                                                                    .minute >
                                                                1
                                                            ? '${vehicleDetail.data.result.engine.minute} ${AppLocalizations.of(context)!.minutes}s '
                                                            : '${vehicleDetail.data.result.engine.minute} ${AppLocalizations.of(context)!.minutes} ',
                                                    style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor)),
                                                Text(
                                                    vehicleDetail
                                                                .data
                                                                .result
                                                                .engine
                                                                .second ==
                                                            0
                                                        ? ''
                                                        : vehicleDetail
                                                                    .data
                                                                    .result
                                                                    .engine
                                                                    .second >
                                                                1
                                                            ? '${vehicleDetail.data.result.engine.second} ${AppLocalizations.of(context)!.second}s'
                                                            : '${vehicleDetail.data.result.engine.second} ${AppLocalizations.of(context)!.second}',
                                                    style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: width,
                                height: address == '' ? 140 : 170,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: vehicleDetail.data.result
                                                      .description ==
                                                  '-' ||
                                              vehicleDetail.data.result
                                                      .description ==
                                                  ''
                                          ? vehicleDetail.data.result
                                                      .vehicleStatus ==
                                                  'Alarm'
                                              ? redPrimary
                                              : vehicleDetail.data.result
                                                          .vehicleStatus ==
                                                      'Lost'
                                                  ? yellowPrimary
                                                  : vehicleDetail.data.result
                                                              .vehicleStatus
                                                              .toLowerCase() ==
                                                          'no data'
                                                      ? yellowPrimary
                                                      : vehicleDetail
                                                                  .data
                                                                  .result
                                                                  .vehicleStatus ==
                                                              'Online'
                                                          ? bluePrimary
                                                          : blackSecondary1
                                          : redPrimary,
                                      width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.darkMode
                                          ? whiteCardColor
                                          : Colors.grey,
                                      offset: const Offset(0.0, 3),
                                      blurRadius: 9.0,
                                    ),
                                  ],
                                  color: whiteColor,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: alarm == '-'
                                              ? Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${AppLocalizations.of(context)!.lastUpdate} : ',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: reguler.copyWith(
                                                        fontSize: 11,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary3,
                                                      ),
                                                    ),
                                                    Text(
                                                      lastUpdate,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: bold.copyWith(
                                                        fontSize: 11,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackPrimary,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${AppLocalizations.of(context)!.lastUpdate} : ',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: reguler.copyWith(
                                                        fontSize: 11,
                                                        color: blackSecondary3,
                                                      ),
                                                    ),
                                                    Text(
                                                      lastUpdate,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: bold.copyWith(
                                                        fontSize: 11,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackPrimary,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                        ),
                                        Visibility(
                                            visible: alarm == '-' || alarm == ''
                                                ? false
                                                : true,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.notifications_none,
                                                  size: 16,
                                                  color: vehicleDetail
                                                                  .data
                                                                  .result
                                                                  .description ==
                                                              '-' ||
                                                          vehicleDetail
                                                                  .data
                                                                  .result
                                                                  .description ==
                                                              ''
                                                      ? blackSecondary3
                                                      : redPrimary,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(alarm,
                                                    style: bold.copyWith(
                                                      fontSize: 10,
                                                      color: vehicleDetail
                                                                      .data
                                                                      .result
                                                                      .description ==
                                                                  '-' ||
                                                              vehicleDetail
                                                                      .data
                                                                      .result
                                                                      .description ==
                                                                  ''
                                                          ? blackSecondary3
                                                          : redPrimary,
                                                    )),
                                              ],
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Divider(
                                      height: .5,
                                      thickness: .5,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : greyColor,
                                      endIndent: 0,
                                      indent: 0,
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              // Image.asset(
                                              //   'assets/batteryicon.png',
                                              //   width: 20,
                                              //   color: blackPrimary,
                                              // ),
                                              Icon(
                                                Icons
                                                    .power_settings_new_outlined,
                                                size: 12,
                                                color: blackPrimary,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                // vehicleDetail.data.result.features
                                                //         .isEmpty
                                                //     ? 'N/A'
                                                //     : vehicleDetail.data.result
                                                //             .features[0].isAcc
                                                //         ? 'Acc on'
                                                //         : 'Acc off',
                                                vehicleDetail.data.result
                                                        .features[0].isAcc
                                                    ? accOn
                                                        ? 'Acc On'
                                                        : 'Acc Off'
                                                    : 'N/A',
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackPrimary,
                                                ),
                                              ),
                                              // Image.file(File(displayImage!.path))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.speed,
                                                size: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackPrimary,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                '$speed Km/h',
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackPrimary,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/batteryicon.png',
                                                    width: 12,
                                                    color: blackPrimary,
                                                  ),
                                                  Visibility(
                                                      visible: battery == '-1'
                                                          ? true
                                                          : false,
                                                      child: Icon(
                                                        Icons.flash_on_rounded,
                                                        size: 15,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackPrimary,
                                                      ))
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                '${battery == '-1' ? '100' : battery}%',
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackPrimary,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              // Icon(
                                              //   Icons.car_rental_outlined,
                                              //   size: 20,
                                              //   color: blackPrimary,
                                              // ),
                                              Image.asset(
                                                'assets/doorlock.png',
                                                width: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackPrimary,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                door,
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackPrimary,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons
                                                    .device_thermostat_outlined,
                                                size: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackPrimary,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                '$temperature*',
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackPrimary,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Divider(
                                      height: .5,
                                      thickness: .5,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : greyColor,
                                      endIndent: 0,
                                      indent: 0,
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    InkWell(
                                      onLongPress: () async {
                                        await getAddressII(
                                            lat.toString(), long.toString());
                                      },
                                      onTap: () async {
                                        await getAddress(
                                            lat.toString(), long.toString());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Text(
                                          address == ''
                                              ? AppLocalizations.of(context)!
                                                  .seeAddress
                                              : address,
                                          // accOn ? 'Acc On' : 'Acc Off',
                                          textAlign: TextAlign.center,
                                          style: bold.copyWith(
                                              fontSize: 10,
                                              color: address == ''
                                                  ? blueGradient
                                                  : widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary3,
                                              decoration: address == ''
                                                  ? TextDecoration.underline
                                                  : TextDecoration.none),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  // horizontal: 16,
                                  vertical: 10,
                                ),
                                width: width,
                                height: 87,
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0),
                                      blurRadius: 9.0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: EngineControl(
                                          feature: feature,
                                          phoneNumber:
                                              vehicleDetail.data.result.gsmNo,
                                          imei: vehicleDetail.data.result.imei,
                                          darkMode: widget.darkMode,
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            showConfirmShareDialog(context);
                                          },
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icon/vehicledetail/sharelocation.png',
                                                width: 32,
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .shareLocation,
                                                textAlign: TextAlign.center,
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            !callCabin
                                                ? {}
                                                :
                                                // Navigator.of(context).pop();
                                                launchUrl(Uri.parse(
                                                    "tel:${vehicleDetail.data.result.gsmNo}"));
                                          },
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                callCabin
                                                    ? 'assets/icon/vehicledetail/cabincall.png'
                                                    : 'assets/icon/vehicledetail/cabincalldisable.png',
                                                width: 32,
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .callCabin,
                                                textAlign: TextAlign.center,
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                isDismissible: true,
                                                backgroundColor: widget.darkMode
                                                    ? whiteCardColor
                                                    : whiteColor,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  12),
                                                          topRight:
                                                              Radius.circular(
                                                                  12)),
                                                ),
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return SingleChildScrollView(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(
                                                          20,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    // Container(),
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .checkReport,
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            16,
                                                                        color:
                                                                            blackPrimary,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    // Container(),

                                                                    GestureDetector(
                                                                      onTap: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        size:
                                                                            40,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : null,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .startDateTime,
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            blackPrimary,
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
                                                                          .center,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap: () => _selectStartDate(
                                                                          context,
                                                                          false),
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            1.2,
                                                                        height:
                                                                            40,
                                                                        child:
                                                                            TextField(
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          enabled:
                                                                              false,
                                                                          controller:
                                                                              startDateController,
                                                                          style:
                                                                              reguler.copyWith(color: blackPrimary),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            disabledBorder:
                                                                                UnderlineInputBorder(borderSide: BorderSide(color: blueGradientSecondary2)),
                                                                            fillColor: widget.darkMode
                                                                                ? whiteColor
                                                                                : whiteCardColor,
                                                                            filled:
                                                                                true,
                                                                            hintText:
                                                                                AppLocalizations.of(context)!.insertStartDate,
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
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .endDateTime,
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            blackPrimary,
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
                                                                          .center,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap: () => getFinishDate
                                                                              .isNotEmpty
                                                                          ? _selectFinisDate(
                                                                              context,
                                                                              false)
                                                                          : showInfoAlert(
                                                                              context,
                                                                              'Select start date first',
                                                                              ''),
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            1.2,
                                                                        height:
                                                                            40,
                                                                        child:
                                                                            TextField(
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          enabled:
                                                                              false,
                                                                          controller:
                                                                              endDateController,
                                                                          style:
                                                                              reguler.copyWith(color: blackPrimary),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            disabledBorder:
                                                                                UnderlineInputBorder(borderSide: BorderSide(color: blueGradientSecondary2)),
                                                                            fillColor: widget.darkMode
                                                                                ? whiteColor
                                                                                : whiteCardColor,
                                                                            filled:
                                                                                true,
                                                                            hintText:
                                                                                AppLocalizations.of(context)!.insertEndDate,
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
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 40,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                print(json
                                                                    .encode({
                                                                  "imei": widget
                                                                      .imei,
                                                                  "timeStart":
                                                                      startDateController
                                                                          .text,
                                                                  "timeEnd":
                                                                      endDateController
                                                                          .text
                                                                }));
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StopReportPage(
                                                                      imei: widget
                                                                          .imei,
                                                                      timeStart:
                                                                          startDateController
                                                                              .text,
                                                                      timeEnd:
                                                                          endDateController
                                                                              .text,
                                                                      licensePlate:
                                                                          widget
                                                                              .deviceName,
                                                                      expDate:
                                                                          widget
                                                                              .expDate,
                                                                      icon: vehicleDetail
                                                                          .data
                                                                          .result
                                                                          .icon
                                                                          .toString(),
                                                                      darkMode:
                                                                          widget
                                                                              .darkMode,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icon/vehicledetail/report/stopreport.png',
                                                                        width:
                                                                            32,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .stopReport,
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 24,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary1,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(
                                                              height: .5,
                                                              thickness: .5,
                                                              endIndent: 0,
                                                              indent: 35,
                                                              color: greyColor,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ParkingReportPage(
                                                                      imei: widget
                                                                          .imei,
                                                                      timeStart:
                                                                          startDateController
                                                                              .text,
                                                                      timeEnd:
                                                                          endDateController
                                                                              .text,
                                                                      licensePlate:
                                                                          widget
                                                                              .deviceName,
                                                                      expDate:
                                                                          widget
                                                                              .expDate,
                                                                      icon: vehicleDetail
                                                                          .data
                                                                          .result
                                                                          .icon
                                                                          .toString(),
                                                                      darkMode:
                                                                          widget
                                                                              .darkMode,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icon/vehicledetail/report/parkreport.png',
                                                                        width:
                                                                            32,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .parkingReport,
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 24,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(
                                                              height: .5,
                                                              thickness: .5,
                                                              endIndent: 0,
                                                              indent: 35,
                                                              color: greyColor,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                // Navigator.pushNamed(
                                                                //     context,
                                                                //     '/trackreplay');
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RunningReportPage(
                                                                      imei: widget
                                                                          .imei,
                                                                      timeStart:
                                                                          startDateController
                                                                              .text,
                                                                      timeEnd:
                                                                          endDateController
                                                                              .text,
                                                                      licensePlate:
                                                                          widget
                                                                              .deviceName,
                                                                      expDate:
                                                                          widget
                                                                              .expDate,
                                                                      icon: vehicleDetail
                                                                          .data
                                                                          .result
                                                                          .icon,
                                                                      darkMode:
                                                                          widget
                                                                              .darkMode,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icon/vehicledetail/report/runningreport.png',
                                                                        width:
                                                                            32,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .runningReport,
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 24,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(
                                                              height: .5,
                                                              thickness: .5,
                                                              endIndent: 0,
                                                              indent: 35,
                                                              color: greyColor,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                // Navigator.pushNamed(
                                                                //     context,
                                                                //     '/journeyreport');
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              TrackreplayPage(
                                                                        imei: widget
                                                                            .imei,
                                                                        timeStart:
                                                                            startDateController.text,
                                                                        timeEnd:
                                                                            endDateController.text,
                                                                        licensePlate:
                                                                            widget.deviceName,
                                                                        expDate:
                                                                            widget.expDate,
                                                                        vehicleStatus: vehicleDetail
                                                                            .data
                                                                            .result
                                                                            .vehicleStatus,
                                                                        icon: vehicleDetail
                                                                            .data
                                                                            .result
                                                                            .icon,
                                                                        darkMode:
                                                                            widget.darkMode,
                                                                      ),
                                                                    ));
                                                                // Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //     builder:
                                                                //         (context) =>
                                                                //             TrackreplayPage(
                                                                //       imei: widget
                                                                //           .imei,
                                                                //       timeStart:
                                                                //           startDateController
                                                                //               .text,
                                                                //       timeEnd:
                                                                //           endDateController
                                                                //               .text,
                                                                //       licensePlate:
                                                                //           vehicleDetail
                                                                //               .data
                                                                //               .result
                                                                //               .plate,
                                                                //       expDate: widget
                                                                //           .expDate,
                                                                //     ),
                                                                //   ),
                                                                // );
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icon/vehicledetail/report/trackreplay.png',
                                                                        width:
                                                                            32,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .trackReplay,
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 24,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(
                                                              height: .5,
                                                              thickness: .5,
                                                              endIndent: 0,
                                                              indent: 35,
                                                              color: greyColor,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            HourMeterPage(
                                                                      imei: widget
                                                                          .imei,
                                                                      timeStart:
                                                                          startDateController
                                                                              .text,
                                                                      timeEnd:
                                                                          endDateController
                                                                              .text,
                                                                      licensePlate:
                                                                          widget
                                                                              .deviceName,
                                                                      expDate:
                                                                          widget
                                                                              .expDate,
                                                                      icon: vehicleDetail
                                                                          .data
                                                                          .result
                                                                          .icon,
                                                                      darkMode:
                                                                          widget
                                                                              .darkMode,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icon/vehicledetail/report/hourmeter.png',
                                                                        width:
                                                                            32,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .hourMeter,
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 24,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(
                                                              height: .5,
                                                              thickness: .5,
                                                              endIndent: 0,
                                                              indent: 35,
                                                              color: greyColor,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            InkWell(
                                                              onTap: () async {
                                                                var getAlarmID =
                                                                    await GeneralService()
                                                                        .readLocalAlarmTypeID();

                                                                // print(getAlarmID.alarmID);
                                                                setState(() {
                                                                  getAlarmID !=
                                                                          false
                                                                      ? alarmID =
                                                                          getAlarmID
                                                                      : alarmID =
                                                                          AlarmIDModel(
                                                                              alarmID: [
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
                                                                            ]);
                                                                });
                                                                print(alarmID);
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              AlarmReport(
                                                                        imei: widget
                                                                            .imei,
                                                                        timeStart:
                                                                            startDateController.text,
                                                                        timeEnd:
                                                                            endDateController.text,
                                                                        licensePlate:
                                                                            widget.deviceName,
                                                                        expDate:
                                                                            widget.expDate,
                                                                        alarmID:
                                                                            alarmID,
                                                                        darkMode:
                                                                            widget.darkMode,
                                                                      ),
                                                                    ));
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icon/vehicledetail/report/alarmreport.png',
                                                                        width:
                                                                            32,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .alarm,
                                                                        style: bold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 24,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            // const SizedBox(
                                                            //   height: 20,
                                                            // ),
                                                            // Divider(
                                                            //   height: .5,
                                                            //   thickness: .5,
                                                            //   endIndent: 0,
                                                            //   indent: 35,
                                                            //   color: greyColor,
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 20,
                                                            // ),
                                                            // InkWell(
                                                            //   onTap: () async {
                                                            //     Navigator.push(
                                                            //         context,
                                                            //         MaterialPageRoute(
                                                            //           builder:
                                                            //               (context) =>
                                                            //                   StreamingLog(
                                                            //             imei: widget
                                                            //                 .imei,
                                                            //             timeStart:
                                                            //                 startDateController.text,
                                                            //             timeEnd:
                                                            //                 endDateController.text
                                                            //           ),
                                                            //         ));
                                                            //   },
                                                            //   child: Row(
                                                            //     mainAxisAlignment:
                                                            //         MainAxisAlignment
                                                            //             .spaceBetween,
                                                            //     children: [
                                                            //       Row(
                                                            //         children: [
                                                            //           Image
                                                            //               .asset(
                                                            //             'assets/icon/dashcam/dashcam.png',
                                                            //             width:
                                                            //                 30,
                                                            //             height:
                                                            //                 30,
                                                            //             color:
                                                            //                 blueGradient,
                                                            //           ),
                                                            //           const SizedBox(
                                                            //             width:
                                                            //                 8,
                                                            //           ),
                                                            //           Text(
                                                            //             "Dashcam Streaming Log",
                                                            //             style: bold
                                                            //                 .copyWith(
                                                            //               fontSize:
                                                            //                   12,
                                                            //               color:
                                                            //                   blackSecondary1,
                                                            //             ),
                                                            //           ),
                                                            //         ],
                                                            //       ),
                                                            //       Icon(
                                                            //         Icons
                                                            //             .arrow_forward,
                                                            //         size: 24,
                                                            //         color:
                                                            //             blackSecondary3,
                                                            //       )
                                                            //     ],
                                                            //   ),
                                                            // )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                });
                                          },
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icon/vehicledetail/report.png',
                                                width: 32,
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .checkReport,
                                                textAlign: TextAlign.center,
                                                style: bold.copyWith(
                                                  fontSize: 10,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ]),
                          );
                        },
                      ),
                    ]);
                  },
                );
              }
            }
            //SKELETON
            // return const Center(
            //   child: Text('Please wait'),
            // );
            vehicleInfo = false;
            return Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  mapType: _mapType,
                  myLocationButtonEnabled: false,
                  // polygons: myPolygon(),
                  // markers: Set<Marker>.of(_markers.values),
                  trafficEnabled: _myTrafficEnabled,
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(-6.187233, 106.8060391)),
                  onMapCreated: (controller) {
                    gMapController = controller;
                    gMapController?.setMapStyle(mapStyle);
                  },
                  // onMapCreated: (controller) {
                  //   // _controller.complete(gMapController);
                  //   setState(() {
                  //     gMapController = controller;
                  //   });
                  //   _setVehicle('all');
                  // },
                ),
                Column(
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
                      color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                      // secondRingColor: blueGradientSecondary1,
                      // thirdRingColor: whiteColor,
                    )
                  ],
                ),
                // Center(
                //   child: LoadingAnimationWidget.waveDots(
                //     size: 50,
                //     color: blueGradientSecondary2,
                //     // secondRingColor: blueGradientSecondary1,
                //     // thirdRingColor: whiteColor,
                //   ),
                // )
              ],
            );
          }),
    );
  }

  printText() {
    print(textController.text);
  }
}
