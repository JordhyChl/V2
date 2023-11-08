// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, must_be_immutable, unused_field, unnecessary_null_comparison, unused_local_variable, avoid_function_literals_in_foreach_calls, unused_element, prefer_final_fields, constant_identifier_names, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gpsid/model/checklimit.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/pages/fullscreenvlc.dart';
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
import 'package:gpsid/pages/vehicleinfo.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:html/parser.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

enum PopMenuOption { Traffic, Satellite }

class Dashcam extends StatefulWidget {
  final String imei;
  final String expDate;
  final String deviceName;
  final String gpsType;
  final String vehStatus;
  final int icon;
  final bool isDashcam;
  int limit;
  final int totalCamera;
  final bool darkMode;

  Dashcam(
      {Key? key,
      required this.imei,
      required this.expDate,
      required this.deviceName,
      required this.gpsType,
      required this.vehStatus,
      required this.icon,
      required this.isDashcam,
      required this.limit,
      required this.totalCamera,
      required this.darkMode})
      : super(key: key);

  @override
  State<Dashcam> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends State<Dashcam>
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
  late Timer _timer2Minutes;
  String _refreshLabel = '30';
  String _refreshLabelDashcam = '0';
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
  // late VideoPlayerController videoPlayerController0;
  // late VideoPlayerController videoPlayerController1;
  late VlcPlayerController videoPlayerController0;
  late VlcPlayerController videoPlayerController1;
  String position = '';
  String duration = '';
  bool validPosition = false;
  double sliderValue = 0.0;
  int cam = 0;
  bool isPlaying = false;
  bool isPlaying1 = false;
  String startTime = '';
  bool timer2Minutes = false;
  bool twominutesleft = false;
  bool zerolimit = false;

  @override
  void initState() {
    super.initState();
    // setLiveStream('0');
    setStream(false);
    // videoPlayerController0 = VlcPlayerController.network(
    //     'https://iothub.gps.id/media/live/0/${widget.imei}.flv',
    //     autoPlay: true,
    //     hwAcc: HwAcc.auto,
    //     options: VlcPlayerOptions());
    // setState(() {});
    // videoPlayerController0 = VlcPlayerController.network(
    //     'https://iothub.gps.id/media/live/0/${widget.imei}.flv')
    //   ..initialize().then((_) {
    //     videoPlayerController0.play();
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });

    startDateController.text =
        DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
    _now = DateTime.now().toLocal();
    _getVehicleDetail = getVehicleDetail(widget.vehStatus, widget.icon);
    _getExpired = DateTime.parse(widget.expDate);
    _expDate = _getExpired!.toLocal();
    _diff = _expDate.difference(_now).inDays;
    _fromDate = _diff > 0
        ? GeneralService().getDate(_now)
        : GeneralService().getDate(_expDate);
    _toDate = _fromDate;
    startDateController.text = '${_fromDate!} ${_fromTime!}';
    startTimeController.text = _fromTime!;
    endDateController.text = '${_toDate!} ${_toTime!}';
    endTimeController.text = _toTime!;
    rootBundle.loadString('assets/maps.json').then(
      (value) {
        setState(() {
          mapStyle = value;
        });
      },
    );
  }

  setStream(bool isSwitch) async {
    videoPlayerController0 = VlcPlayerController.network(
        // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'https://iothub.gps.id/media/live/0/${widget.imei}.flv',
        autoPlay: true,
        hwAcc: HwAcc.auto,
        options: VlcPlayerOptions());
    videoPlayerController1 = VlcPlayerController.network(
        'https://iothub.gps.id/media/live/1/${widget.imei}.flv',
        // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        autoPlay: false,
        hwAcc: HwAcc.auto,
        options: VlcPlayerOptions());
    videoPlayerController0.addListener(() async {
      _refreshLabelDashcam =
          videoPlayerController0.value.position.inSeconds.toString();
      if (videoPlayerController0.value.position.inSeconds == 1) {
        setState(() {
          startTime = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.now().toLocal());
          isPlaying = true;
          timer2Minutes = false;
        });
        print('Get DateTIme cam 0 $startTime');
      }
      if (videoPlayerController0.value.position.inSeconds == 120) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            videoPlayerController0.pause();
          },
        );
        setState(() {
          timer2Minutes = true;
        });
      }
    });
  }

  void listener() async {
    if (!mounted) return;
    //
    if (videoPlayerController0.value.isInitialized) {
      var oPosition = videoPlayerController0.value.position;
      var oDuration = videoPlayerController0.value.duration;
      if (oPosition != null && oDuration != null) {
        if (oDuration.inHours == 0) {
          var strPosition = oPosition.toString().split('.')[0];
          var strDuration = oDuration.toString().split('.')[0];
          position =
              "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          duration =
              "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
        } else {
          position = oPosition.toString().split('.')[0];
          duration = oDuration.toString().split('.')[0];
        }
        validPosition = oDuration.compareTo(oPosition) >= 0;
        sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      }
      setState(() {});
    }
  }

  storeLog() async {
    Dialogs().loadingDialog(context);
    String action = '1';
    cam;
    _refreshLabelDashcam;
    startTime;
    String finishTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime.parse(startTime)
            .add(Duration(seconds: int.parse(_refreshLabelDashcam))));
    final result = await APIService().storeLimit(
        startTime,
        finishTime.toString(),
        _refreshLabelDashcam,
        widget.imei,
        action,
        cam.toString(),
        'RTMP,ON,INOUT');
    if (result is MessageModel) {
      Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, result.message, '');
    } else {
      final limitResult =
          await APIService().checkLimit(widget.imei, 'RTMP,ON,INOUT');
      if (limitResult is CheckLimitModel) {
        if (limitResult.status) {
          Dialogs().hideLoaderDialog(context);
          setState(() {
            widget.limit = limitResult.data.limitLive;
          });
        } else {
          Dialogs().hideLoaderDialog(context);
          // showInfoAlert(context, limitResult.message, '');
          showInfoAlert(
              context,
              limitResult.message ==
                      'Unable to load data, Please wait and refresh this page.'
                  ? AppLocalizations.of(context)!.errorPushing
                  : limitResult.message ==
                          'Your device is currently busy, Please wait and refresh this page.'
                      ? AppLocalizations.of(context)!.errorBusy
                      : limitResult.message,
              limitResult.message ==
                      'Unable to load data, Please wait and refresh this page.'
                  ? AppLocalizations.of(context)!.errorPushingSub
                  : limitResult.message ==
                          'Your device is currently busy, Please wait and refresh this page.'
                      ? AppLocalizations.of(context)!.errorPushingSub
                      : '');
        }
      } else {
        if (limitResult is MessageModel) {
          Dialogs().hideLoaderDialog(context);
          showInfoAlert(context, limitResult.message, '');
        }
      }
      // Dialogs().hideLoaderDialog(context);
    }
  }

  @override
  void dispose() async {
    super.dispose();
    cam == 0
        ? await videoPlayerController0.dispose()
        : await videoPlayerController1.dispose();
    String action = '1';
    cam;
    _refreshLabelDashcam;
    startTime;
    String finishTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime.parse(startTime)
            .add(Duration(seconds: int.parse(_refreshLabelDashcam))));
    final result = await APIService().storeLimit(
        startTime,
        finishTime.toString(),
        _refreshLabelDashcam,
        widget.imei,
        action,
        cam.toString(),
        'RTMP,ON,INOUT');
    if (result is MessageModel) {
      showInfoAlert(context, result.message, '');
    }
    _timer.isActive ? _timer.cancel() : {};
    // _timerDashcam.isActive ? _timerDashcam.cancel() : {};
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
    // String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigitSeconds;
  }

  // Stream<bool>stream() async*{
  //   if (isPlaying) {

  //   }
  // }

  String _printDurationII(Duration duration) {
    if (duration.inSeconds == 120) {
      // cam == 0
      //     ? videoPlayerController0.pause()
      //     : videoPlayerController1.pause();
      twominutesleft = true;
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else if (duration.inSeconds == 0) {
      zerolimit = true;
      cam == 0 ? isPlaying = false : isPlaying = false;
      cam == 0
          ? videoPlayerController0.pause()
          : videoPlayerController1.pause();
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "00:00:00";
    } else {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  // String twoMinutesDuration(Duration duration) {
  //   if (cam == 0) {
  //     if (videoPlayerController0.value.position.inSeconds == 5) {
  //       timer2Minutes = true;
  //       videoPlayerController0.stop();
  //       // storeLogMini();
  //       // return "You reach 2 minutes. Are you still there?";
  //     }
  //     return "You reach 2 minutes. Are you still there?";
  //   } else {
  //     if (videoPlayerController1.value.position.inSeconds == 5) {
  //       timer2Minutes = true;
  //       videoPlayerController1.stop();
  //       // storeLogMini();
  //       // return "You reach 2 minutes. Are you still there?";
  //     }
  //     return "You reach 2 minutes. Are you still there?";
  //   }
  // }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _refreshLabel = _printDuration(Duration(seconds: _refreshTime));
        _refreshTime--;
        _isLoading = false;
      });
      if (_refreshTime < 0) {
        _timer.cancel();
        // setState(() {
        //   _isLoading = true;
        // });
        // await onEnd();
        // _customInfoWindowController.hideInfoWindow!();
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
        _refreshLabel = '30';
        _refreshTime = 30;
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
                            child: const Icon(
                              Icons.close,
                              size: 30,
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
                              color: blackSecondary3,
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
                                  color: blackSecondary3,
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
                                  style: TextStyle(
                                      color: blackSecondary1, fontSize: 12),
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

  Future<void> getAddressII(String pLat, String pLng) async {
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

  Future<void> getAddress(String pLat, String pLng) async {
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
          address = addressResult['message'];
        });
      }
    }
  }

  _setPoi() async {
    await Dialogs().loadingDialog(context);
    if (_timer.isActive) {
      _timer.cancel();
      int oldRefreshTime = _refreshTime;
      setState(() {
        _refreshTime = oldRefreshTime;
      });
    }
    final poi = await APIService().getPOI();
    if (poi is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '59846';
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
      });
      if (poi is POIModel) {
        poi.data.result.forEach((el) async {
          String folder = 'Poi';
          String fileName = '${el.iconId}_${el.iconName}.png';
          final appDir = await path_provider.getApplicationDocumentsDirectory();
          final newPath = Directory('${appDir.path}/$folder');
          final imageFile = File(path.setExtension(newPath.path, '/$fileName'));
          disp.clear();
          disp.add(imageFile);
          displayImage = disp[0];
          Uint8List conv = await displayImage!.readAsBytes();
          BitmapDescriptor getImg = BitmapDescriptor.fromBytes(conv);
          final MarkerId markerId = MarkerId(el.id.toString());
          // final Marker poiMarker = _markers[markerId]!;
          final Marker marker = Marker(
            markerId: markerId,
            visible: showPOI,
            // rotation: double.parse(angle.toString()),
            position: LatLng(el.lat, el.lon),
            infoWindow: InfoWindow(title: el.name),
            icon: getImg,
          );
          if (mounted) {
            setState(() {
              _markers[markerId] = marker;
            });
          }
        });
        _startTimer();
      }
    }
    await Dialogs().hideLoaderDialog(context);
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

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'SS_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Image saved to gallery"),
      backgroundColor: blueGradient,
    ));
    return Platform.isAndroid ? result['filePath'] : '';
  }

  // void togglePanel() =>
  //     clicked ? _panelController.close() : _panelController.open();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: whiteColor,
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
            title: Stack(
              children: [
                InkWell(
                  // onTap: () => Navigator.pop(context),
                  onTap: () async {
                    if (_timer.isActive) {
                      cam == 0
                          ? await videoPlayerController0.dispose()
                          : await videoPlayerController1.dispose();
                      _timer.cancel();
                      // Dialogs().loadingDialog(context);
                      // final firstRes = await APIService()
                      //     .liveStreamDashcam(widget.imei, 'RTMP,OFF,INOUT');
                      // Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      cam == 0
                          ? await videoPlayerController0.dispose()
                          : await videoPlayerController1.dispose();
                      // Dialogs().loadingDialog(context);
                      // final firstRes = await APIService()
                      //     .liveStreamDashcam(widget.imei, 'RTMP,OFF,INOUT');
                      // Navigator.pop(context);
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
                          'Live Camera',
                          style: bold.copyWith(
                            fontSize: 14,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : whiteColor,
                          ),
                        ),
                        Text(
                          widget.deviceName,
                          style: bold.copyWith(
                            fontSize: 10,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : whiteColor,
                          ),
                        )
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
                                                      : vehicleDetail
                                                                  .data
                                                                  .result
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
                                              gsmNumber: vehicleDetail
                                                  .data.result.gsmNo,
                                              imei: widget.imei,
                                              plate: vehicleDetail
                                                  .data.result.plate,
                                              registerDate: vehicleDetail
                                                  .data.result.registerDate,
                                              isDashcam: vehicleDetail.data
                                                  .result.features[0].isDashcam,
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
            ),
          ),
          body: FutureBuilder(
              future: _getVehicleDetail,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data is ErrorTrapModel) {
                    //SKELETON
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

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        //maps
                        Column(
                          children: [
                            Visibility(
                                visible: cam == 0 ? true : false,
                                child: SizedBox(
                                  child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Stack(
                                        children: [
                                          VlcPlayer(
                                            controller: videoPlayerController0,
                                            aspectRatio: 16 / 9,
                                            placeholder: Container(
                                              color: blackPrimary,
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          ),
                                          Visibility(
                                              visible:
                                                  !isPlaying ? true : false,
                                              child: Container(
                                                color: blackPrimary,
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              )),
                                        ],
                                      )),
                                )),
                            Visibility(
                                visible: cam != 0 ? true : false,
                                child: SizedBox(
                                  child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Stack(
                                        children: [
                                          VlcPlayer(
                                            controller: videoPlayerController1,
                                            aspectRatio: 16 / 9,
                                            placeholder: Container(
                                              color: blackPrimary,
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          ),
                                          Visibility(
                                              visible:
                                                  !isPlaying1 ? true : false,
                                              child: Container(
                                                color: blackPrimary,
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              )),
                                        ],
                                      )),
                                )),
                            Expanded(
                              child: Stack(
                                children: [
                                  GoogleMap(
                                      myLocationEnabled: true,
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                      markers: Set<Marker>.of(_markers.values),
                                      initialCameraPosition: CameraPosition(
                                          target: LatLng(pLat, pLong),
                                          zoom: 15),
                                      onMapCreated: (controller) {
                                        setState(() {
                                          gMapController = controller;
                                        });
                                      },
                                      zoomGesturesEnabled: true,
                                      scrollGesturesEnabled: true,
                                      trafficEnabled: _myTrafficEnabled,
                                      mapType: _mapType),
                                  Positioned(
                                    // left: 15,
                                    right: 10,
                                    top: 5,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 3),
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
                                                        color: widget.darkMode
                                                            ? whiteCardColor
                                                            : blackSecondary2,
                                                        offset: const Offset(
                                                            0.0, 3),
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32)),
                                                child: Icon(
                                                  Icons.location_searching,
                                                  size: 18,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : whiteColor,
                                                )),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Visibility(
                                                visible: true,
                                                child: InkWell(
                                                  child: Container(
                                                    width: 60,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: widget.darkMode
                                                          ? whiteCardColor
                                                          : bluePrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: widget.darkMode
                                                              ? whiteCardColor
                                                              : Colors.grey,
                                                          offset: const Offset(
                                                              0.0, 3),
                                                          blurRadius: 5.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                          visible: _isLoading
                                                              ? true
                                                              : false,
                                                          child: SizedBox(
                                                            width: 22,
                                                            child: Stack(
                                                              children: [
                                                                Center(
                                                                  child: Stack(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/logoss.png',
                                                                        height:
                                                                            16,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : whiteColor,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Center(
                                                                  child: LoadingAnimationWidget.discreteCircle(
                                                                      size: 23,
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
                                                          visible: _isLoading
                                                              ? false
                                                              : true,
                                                          child: SizedBox(
                                                              width: 22,
                                                              child: Text(
                                                                _refreshLabel,
                                                                style: reguler.copyWith(
                                                                    fontSize:
                                                                        16,
                                                                    color: widget
                                                                            .darkMode
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
                                                    if (_timer.isActive) {
                                                      _timer.cancel();
                                                      // _customInfoWindowController
                                                      //     .hideInfoWindow!();
                                                      // await onEnd();
                                                      _getVehicleDetail =
                                                          getVehicleDetail(
                                                              vehicleDetail
                                                                  .data
                                                                  .result
                                                                  .vehicleStatus,
                                                              vehicleDetail.data
                                                                  .result.icon);
                                                    }
                                                  },
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    // left: ,
                                    right: 6,
                                    top: 55,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor:
                                                      whiteCardColor,
                                                  isDismissible: true,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              topRight: Radius
                                                                  .circular(
                                                                      8))),
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        AppLocalizations.of(context)!
                                                                            .mapStyle,
                                                                        style: reguler.copyWith(
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary1,
                                                                            fontSize:
                                                                                16)),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        launchUrl(
                                                                            mode:
                                                                                LaunchMode.externalApplication,
                                                                            Uri.parse('https://www.google.com/maps/search/?api=1&query=$pLat,$pLong'));
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.of(context)!
                                                                            .showonGMaps,
                                                                        style: reguler.copyWith(
                                                                            fontStyle: FontStyle
                                                                                .italic,
                                                                            decoration: TextDecoration
                                                                                .underline,
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                bluePrimary),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            12),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _myMapSatelliteEnabled = false;
                                                                              _mapType = MapType.normal;

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
                                                                            height:
                                                                                36,
                                                                            // width: 159,
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(width: 1, color: !_myMapSatelliteEnabled ? bluePrimary : greyColor), borderRadius: BorderRadius.circular(4)),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.location_on_outlined,
                                                                                  color: !_myMapSatelliteEnabled ? bluePrimary : greyColor,
                                                                                  size: 20,
                                                                                ),
                                                                                Text(
                                                                                  AppLocalizations.of(context)!.defaultMap,
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
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _myMapSatelliteEnabled = true;
                                                                              _mapType = MapType.satellite;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                36,
                                                                            // width: 159,
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(width: 1, color: !_myMapSatelliteEnabled ? greyColor : bluePrimary), borderRadius: BorderRadius.circular(4)),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.map_outlined,
                                                                                  color: !_myMapSatelliteEnabled ? greyColor : bluePrimary,
                                                                                  size: 20,
                                                                                ),
                                                                                Text(
                                                                                  AppLocalizations.of(context)!.satelliteMap,
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
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            15),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        AppLocalizations.of(context)!
                                                                            .mapDetail,
                                                                        style: reguler.copyWith(
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary1,
                                                                            fontSize:
                                                                                16)),
                                                                  ],
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => StreetView(
                                                                              Latitude: double.parse(vehicleDetail.data.result.lat),
                                                                              Longitude: double.parse(vehicleDetail.data.result.lon),
                                                                              Angle: angle)));
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 12),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            'assets/mapdetail/streetview.png',
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 15),
                                                                            child:
                                                                                Text(AppLocalizations.of(context)!.streetView, style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 12)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .arrow_forward_rounded,
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            blueGradient,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 8,
                                                                        bottom:
                                                                            3),
                                                                child: Divider(
                                                                  height: .5,
                                                                  thickness: .5,
                                                                  endIndent: 0,
                                                                  indent: 0,
                                                                  color:
                                                                      greyColor,
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
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            'assets/mapdetail/traffic.png',
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 15),
                                                                            child:
                                                                                Text(AppLocalizations.of(context)!.trafficView, style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 12)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Switch(
                                                                      value:
                                                                          _myTrafficEnabled,
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
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
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 3,
                                                                        bottom:
                                                                            3),
                                                                child: Divider(
                                                                  height: .5,
                                                                  thickness: .5,
                                                                  endIndent: 0,
                                                                  indent: 0,
                                                                  color:
                                                                      greyColor,
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  if (showPOI ==
                                                                      true) {
                                                                    setState(
                                                                        () {
                                                                      showPOI =
                                                                          false;
                                                                    });
                                                                    _setPoi();
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      showPOI =
                                                                          true;
                                                                    });
                                                                    _setPoi();
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
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            'assets/mapdetail/poi.png',
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 15),
                                                                            child:
                                                                                Text(AppLocalizations.of(context)!.poiView, style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 12)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Switch(
                                                                      value:
                                                                          showPOI,
                                                                      onChanged:
                                                                          (value) {
                                                                        if (showPOI ==
                                                                            true) {
                                                                          setState(
                                                                              () {
                                                                            showPOI =
                                                                                false;
                                                                          });
                                                                          _setPoi();
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            showPOI =
                                                                                true;
                                                                          });
                                                                          _setPoi();
                                                                        }
                                                                      },
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
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
                                                final MarkerId markerId =
                                                    MarkerId(vehicleDetail
                                                        .data.result.imei);
                                                // _doCenter(markerId);
                                                gMapController?.animateCamera(
                                                    CameraUpdate.newCameraPosition(
                                                        CameraPosition(
                                                            target: LatLng(
                                                                double.parse(
                                                                    vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .lat),
                                                                double.parse(
                                                                    vehicleDetail
                                                                        .data
                                                                        .result
                                                                        .lon)),
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
                                              onTap: () {
                                                // launchUrl(
                                                //     Uri.parse(url
                                                //         .data.results.whatsapp),
                                                //     mode: LaunchMode
                                                //         .externalApplication);
                                              },
                                              child: Image.asset(
                                                'assets/WA.png',
                                                width: 40,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 30,
                          left: 20,
                          right: 20,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                // width: 335,
                                height: 160,
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 3),
                                      blurRadius: 9.0,
                                    ),
                                  ],
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Visibility(
                                    //   visible: timer2Minutes,
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.start,
                                    //     children: [
                                    //       Text(
                                    //         twoMinutesDuration(Duration(
                                    //             seconds: cam == 0
                                    //                 ? videoPlayerController0
                                    //                     .value.position.inSeconds
                                    //                 : videoPlayerController1
                                    //                     .value.position.inSeconds)),
                                    //         style: reguler.copyWith(
                                    //             color: blackPrimary, fontSize: 10),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    Visibility(
                                      visible:
                                          zerolimit ? false : twominutesleft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'The usage limit is 2 minutes remaining',
                                            style: reguler.copyWith(
                                                color: blackPrimary,
                                                fontSize: 10),
                                          )
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: zerolimit,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'You reach the usage limit, Please Top up',
                                            style: reguler.copyWith(
                                                color: blackPrimary,
                                                fontSize: 10),
                                          )
                                        ],
                                      ),
                                    ),
                                    Text(
                                      widget.deviceName,
                                      style: bold.copyWith(
                                          color: blackPrimary, fontSize: 16),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Container(
                                            height: 23,
                                            width: 140,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: whiteCardColor,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        size: 8,
                                                        color: redPrimary,
                                                      ),
                                                      Text(
                                                        ' Limit Stream : ',
                                                        style: reguler.copyWith(
                                                            color: blackPrimary,
                                                            fontSize: 10),
                                                      ),
                                                      Text(
                                                        zerolimit
                                                            ? '00:00:00'
                                                            : _printDurationII(Duration(
                                                                seconds: cam ==
                                                                        0
                                                                    ? widget.limit -
                                                                        videoPlayerController0
                                                                            .value
                                                                            .position
                                                                            .inSeconds
                                                                    : widget.limit -
                                                                        videoPlayerController1
                                                                            .value
                                                                            .position
                                                                            .inSeconds)),
                                                        // widget.limit
                                                        //     .toString(),
                                                        style: bold.copyWith(
                                                            color: blackPrimary,
                                                            fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.totalCamera == 2
                                              ? true
                                              : false,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Container(
                                              height: 32,
                                              width: 88,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    blueGradientSecondary1,
                                                    blueGradientSecondary2,
                                                  ],
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  // Icon(
                                                  //   Icons.camera_alt_rounded,
                                                  //   size: 14,
                                                  //   color: whiteColor,
                                                  // ),
                                                  Image.asset(
                                                      'assets/icon/dashcam/camerachange.png',
                                                      width: 18),
                                                  InkWell(
                                                    onTap: () async {
                                                      if (widget.totalCamera ==
                                                          2) {
                                                        if (isPlaying ||
                                                            isPlaying1) {
                                                          await storeLog();
                                                          if (cam == 0) {
                                                            setState(() {
                                                              cam = 1;
                                                            });

                                                            videoPlayerController0
                                                                .dispose();
                                                            videoPlayerController1 =
                                                                VlcPlayerController.network(
                                                                    'https://iothub.gps.id/media/live/1/${widget.imei}.flv',
                                                                    // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
                                                                    autoPlay:
                                                                        true,
                                                                    hwAcc: HwAcc
                                                                        .auto,
                                                                    options:
                                                                        VlcPlayerOptions());
                                                            videoPlayerController1
                                                                .addListener(
                                                                    () async {
                                                              _refreshLabelDashcam =
                                                                  videoPlayerController1
                                                                      .value
                                                                      .position
                                                                      .inSeconds
                                                                      .toString();
                                                              if (videoPlayerController1
                                                                      .value
                                                                      .position
                                                                      .inSeconds ==
                                                                  120) {
                                                                Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                                  () {
                                                                    videoPlayerController1
                                                                        .pause();
                                                                  },
                                                                );
                                                                setState(() {
                                                                  timer2Minutes =
                                                                      true;
                                                                });
                                                              }
                                                              if (videoPlayerController1
                                                                      .value
                                                                      .position
                                                                      .inSeconds ==
                                                                  1) {
                                                                setState(() {
                                                                  startTime = DateFormat(
                                                                          'yyyy-MM-dd HH:mm:ss')
                                                                      .format(DateTime
                                                                              .now()
                                                                          .toLocal());
                                                                  isPlaying =
                                                                      false;
                                                                  isPlaying1 =
                                                                      true;
                                                                });
                                                                print(
                                                                    'Get DateTIme cam 1 $startTime');
                                                              }
                                                            });
                                                          } else {
                                                            setState(() {
                                                              cam = 0;
                                                            });
                                                            videoPlayerController1
                                                                .dispose();
                                                            videoPlayerController0 =
                                                                VlcPlayerController.network(
                                                                    'https://iothub.gps.id/media/live/0/${widget.imei}.flv',
                                                                    // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
                                                                    autoPlay:
                                                                        true,
                                                                    hwAcc: HwAcc
                                                                        .auto,
                                                                    options:
                                                                        VlcPlayerOptions());
                                                            videoPlayerController0
                                                                .addListener(
                                                                    () async {
                                                              _refreshLabelDashcam =
                                                                  videoPlayerController0
                                                                      .value
                                                                      .position
                                                                      .inSeconds
                                                                      .toString();
                                                              if (videoPlayerController0
                                                                      .value
                                                                      .position
                                                                      .inSeconds ==
                                                                  120) {
                                                                Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                                  () {
                                                                    videoPlayerController0
                                                                        .pause();
                                                                  },
                                                                );
                                                                setState(() {
                                                                  timer2Minutes =
                                                                      true;
                                                                });
                                                              }
                                                              if (videoPlayerController0
                                                                      .value
                                                                      .position
                                                                      .inSeconds ==
                                                                  1) {
                                                                setState(() {
                                                                  startTime = DateFormat(
                                                                          'yyyy-MM-dd HH:mm:ss')
                                                                      .format(DateTime
                                                                              .now()
                                                                          .toLocal());
                                                                  isPlaying =
                                                                      true;
                                                                  isPlaying1 =
                                                                      false;
                                                                });
                                                                print(
                                                                    'Get DateTime cam 1 $startTime');
                                                              }
                                                            });
                                                          }
                                                        } else {
                                                          print(
                                                              'still processing');
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      'CAM ${cam == 0 ? 1 : 2}',
                                                      style: bold.copyWith(
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : whiteColor,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Divider(
                                        height: .5,
                                        thickness: .5,
                                        color: whiteCardColor,
                                        endIndent: 0,
                                        indent: 0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              if (zerolimit) {
                                                print('reach limit');
                                                showInfoAlert(
                                                    context, 'reach limit', '');
                                              } else {
                                                if (isPlaying || isPlaying1) {
                                                  if (cam == 0
                                                      ? videoPlayerController0
                                                          .value.isPlaying
                                                      : videoPlayerController1
                                                          .value.isPlaying) {
                                                    await storeLog();
                                                    cam == 0
                                                        ? videoPlayerController0
                                                            .stop()
                                                        : videoPlayerController1
                                                            .stop();
                                                    // setState(() {});
                                                  } else {
                                                    // videoPlayerController0.play();
                                                    // setState(() {});
                                                    cam == 0
                                                        ? await videoPlayerController0
                                                            .play()
                                                        : await videoPlayerController1
                                                            .play();
                                                    setState(() {
                                                      timer2Minutes = false;
                                                    });
                                                    // setStream(true);
                                                  }
                                                } else {
                                                  print('still processing');
                                                }
                                              }
                                            },
                                            child: Image.asset(
                                              cam == 0
                                                  ? videoPlayerController0
                                                          .value.isPlaying
                                                      ? 'assets/icon/dashcam/pause.png'
                                                      : 'assets/icon/dashcam/play.png'
                                                  : videoPlayerController1
                                                          .value.isPlaying
                                                      ? 'assets/icon/dashcam/pause.png'
                                                      : 'assets/icon/dashcam/play.png',
                                              width: 25,
                                              height: 25,
                                              color: cam == 0
                                                  ? isPlaying
                                                      ? blueGradientSecondary2
                                                      : greyColor
                                                  : isPlaying1
                                                      ? blueGradientSecondary2
                                                      : greyColor,
                                            ),
                                          ),
                                          InkWell(
                                            child: Image.asset(
                                                'assets/icon/dashcam/takepict.png',
                                                width: 25,
                                                height: 25,
                                                color: cam == 0
                                                    ? isPlaying
                                                        ? blueGradientSecondary2
                                                        : greyColor
                                                    : isPlaying1
                                                        ? blueGradientSecondary2
                                                        : greyColor),
                                            onTap: () async {
                                              if (zerolimit) {
                                                print('reach limit');
                                                showInfoAlert(
                                                    context, 'reach limit', '');
                                              } else {
                                                final image = cam == 0
                                                    ? await videoPlayerController0
                                                        .takeSnapshot()
                                                    : await videoPlayerController1
                                                        .takeSnapshot();
                                                await saveImage(image);
                                              }
                                            },
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              if (zerolimit) {
                                                print('reach limit');
                                                showInfoAlert(
                                                    context, 'reach limit', '');
                                              } else {
                                                cam == 0
                                                    ? videoPlayerController0
                                                                .value.volume ==
                                                            100
                                                        ? videoPlayerController0
                                                            .setVolume(0)
                                                        : videoPlayerController0
                                                            .setVolume(100)
                                                    : videoPlayerController1
                                                                .value.volume ==
                                                            100
                                                        ? videoPlayerController1
                                                            .setVolume(0)
                                                        : videoPlayerController1
                                                            .setVolume(100);
                                              }
                                            },
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 5),
                                                child: Image.asset(
                                                    cam == 0
                                                        ? videoPlayerController0
                                                                    .value
                                                                    .volume ==
                                                                100
                                                            ? 'assets/icon/dashcam/sound.png'
                                                            : 'assets/icon/dashcam/mutesound.png'
                                                        : videoPlayerController1
                                                                    .value
                                                                    .volume ==
                                                                100
                                                            ? 'assets/icon/dashcam/sound.png'
                                                            : 'assets/icon/dashcam/mutesound.png',
                                                    width: 25,
                                                    height: 25,
                                                    color: cam == 0
                                                        ? isPlaying
                                                            ? blueGradientSecondary2
                                                            : greyColor
                                                        : isPlaying1
                                                            ? blueGradientSecondary2
                                                            : greyColor)

                                                // Image.asset(
                                                //   controller.value.volume == 100
                                                //       ? 'assets/icon/dashcam/sound.png'
                                                //       : 'assets/icon/dashcam/mutesound.png',
                                                //   width: 24,
                                                //   height: 24,
                                                //   color: whiteColor,
                                                // ),
                                                ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
                                              await Navigator.of(context)
                                                  .push(PageTransition(
                                                child: Scaffold(
                                                  backgroundColor: blackPrimary,
                                                  body: FullScreenVLC(
                                                    controller:
                                                        videoPlayerController0,
                                                    url:
                                                        'https://iothub.gps.id/media/live/$cam/${widget.imei}.flv',
                                                    limit:
                                                        widget.limit.toString(),
                                                    camera: cam.toString(),
                                                    imei: widget.imei,
                                                    file: '',
                                                    darkMode: widget.darkMode,
                                                  ),
                                                ),
                                                type: PageTransitionType.fade,
                                              ));
                                              // vlcPLayerFullScreen(
                                              //     context,
                                              //     videoPlayerController0,
                                              //     'https://iothub.gps.id/media/live/$cam/${widget.imei}.flv',
                                              //     widget.limit.toString(),
                                              //     cam.toString(),
                                              //     widget.imei,
                                              //     '');
                                            },
                                            child: Image.asset(
                                                'assets/icon/dashcam/fullscreen.png',
                                                width: 25,
                                                height: 25,
                                                // color: greyColor,
                                                color: cam == 0
                                                    ? isPlaying
                                                        ? blueGradientSecondary2
                                                        : greyColor
                                                    : isPlaying1
                                                        ? blueGradientSecondary2
                                                        : greyColor),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: timer2Minutes,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  // width: 335,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Are you still there? If you want to continue press play button',
                                          style: reguler.copyWith(
                                              color: blackPrimary,
                                              fontSize: 10),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // Positioned(
                        //   left: 20,
                        //   // right: 21,
                        //   top: 25,
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       // Row(
                        //       //   children: [
                        //       //     Image.asset(
                        //       //       'assets/whatsapp.png',
                        //       //       width: 99,
                        //       //     ),
                        //       //   ],
                        //       // ),
                        //       Visibility(
                        //           visible: widget.isDashcam,
                        //           child: InkWell(
                        //             child: Container(
                        //                 width: 134,
                        //                 height: 32,
                        //                 decoration: BoxDecoration(
                        //                   color: bluePrimary,
                        //                   borderRadius: BorderRadius.circular(15),
                        //                   boxShadow: const [
                        //                     BoxShadow(
                        //                       color: Colors.grey,
                        //                       offset: Offset(0.0, 3),
                        //                       blurRadius: 5.0,
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 child: Center(
                        //                   child: Row(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment.center,
                        //                     children: [
                        //                       Icon(
                        //                         Icons.camera_rounded,
                        //                         color: whiteColor,
                        //                         size: 20,
                        //                       ),
                        //                       Text(
                        //                         'Dashcam',
                        //                         style: reguler.copyWith(
                        //                             color: whiteColor,
                        //                             fontSize: 16),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 )),
                        //             onTap: () async {
                        //               // Navigator.pushNamed(context, '/dashcam');
                        //               Navigator.push(
                        //                 context,
                        //                 MaterialPageRoute(
                        //                   builder: (context) => DashcamSample(
                        //                     imei: vehicleDetail.data.result.imei,
                        //                     vehName: widget.deviceName,
                        //                   ),
                        //                 ),
                        //               );
                        //             },
                        //           )),
                        //     ],
                        //   ),
                        // ),
                        // Positioned(
                        //   left: 21,
                        //   right: 21,
                        //   top: 25,
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       // Row(
                        //       //   children: [
                        //       //     Image.asset(
                        //       //       'assets/whatsapp.png',
                        //       //       width: 99,
                        //       //     ),
                        //       //   ],
                        //       // ),
                        //       Column(
                        //         mainAxisAlignment: MainAxisAlignment.end,
                        //         children: [
                        //           Visibility(
                        //               visible: true,
                        //               child: InkWell(
                        //                 child: Container(
                        //                   width: 60,
                        //                   height: 32,
                        //                   decoration: BoxDecoration(
                        //                     color: bluePrimary,
                        //                     borderRadius:
                        //                         BorderRadius.circular(15),
                        //                     boxShadow: const [
                        //                       BoxShadow(
                        //                         color: Colors.grey,
                        //                         offset: Offset(0.0, 3),
                        //                         blurRadius: 5.0,
                        //                       ),
                        //                     ],
                        //                   ),
                        //                   child: Row(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment.center,
                        //                     children: [
                        //                       Image.asset(
                        //                         'assets/time.png',
                        //                         width: 20,
                        //                         color: whiteColor,
                        //                       ),
                        //                       const SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       Visibility(
                        //                         visible:
                        //                             _isLoading ? true : false,
                        //                         child: SizedBox(
                        //                           width: 22,
                        //                           child: Stack(
                        //                             children: [
                        //                               Center(
                        //                                 child: Stack(
                        //                                   children: [
                        //                                     Image.asset(
                        //                                       'assets/logoss.png',
                        //                                       height: 16,
                        //                                       color: whiteColor,
                        //                                     )
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                               Center(
                        //                                 child: LoadingAnimationWidget
                        //                                     .discreteCircle(
                        //                                         size: 23,
                        //                                         // color:
                        //                                         //     blueGradientSecondary2,
                        //                                         // secondRingColor:
                        //                                         //     blueGradientSecondary1,
                        //                                         // thirdRingColor:
                        //                                         //     whiteColor,
                        //                                         color:
                        //                                             whiteColor),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Visibility(
                        //                         visible:
                        //                             _isLoading ? false : true,
                        //                         child: SizedBox(
                        //                             width: 22,
                        //                             child: Text(
                        //                               _refreshLabel,
                        //                               style: reguler.copyWith(
                        //                                   fontSize: 16,
                        //                                   color: whiteColor),
                        //                             )
                        //                             // GradientText(
                        //                             //   _refreshLabel,
                        //                             //   style: reguler.copyWith(
                        //                             //       fontSize: 16),
                        //                             //   colors: [
                        //                             //     bgy1,
                        //                             //     bgy2,
                        //                             //     bgy3,
                        //                             //   ],
                        //                             // ),
                        //                             ),
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 onTap: () async {
                        //                   if (_timer.isActive) {
                        //                     _timer.cancel();
                        //                     // _customInfoWindowController
                        //                     //     .hideInfoWindow!();
                        //                     // await onEnd();
                        //                     _getVehicleDetail = getVehicleDetail(
                        //                         vehicleDetail
                        //                             .data.result.vehicleStatus,
                        //                         vehicleDetail.data.result.icon);
                        //                   }
                        //                 },
                        //               )),
                        //         ],
                        //       )
                        //     ],
                        //   ),
                        // ),
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

                        // Positioned(
                        //   // left: ,
                        //   right: 20,
                        //   top: 65,
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Column(
                        //         children: [
                        //           InkWell(
                        //             onTap: () {
                        //               showModalBottomSheet(
                        //                 isDismissible: true,
                        //                 shape: const RoundedRectangleBorder(
                        //                     borderRadius: BorderRadius.only(
                        //                         topLeft: Radius.circular(8),
                        //                         topRight: Radius.circular(8))),
                        //                 context: context,
                        //                 builder: (context) {
                        //                   return StatefulBuilder(
                        //                     builder: (context, setState) {
                        //                       return Padding(
                        //                         padding:
                        //                             const EdgeInsets.all(20.0),
                        //                         child: Column(
                        //                           children: [
                        //                             Padding(
                        //                               padding:
                        //                                   const EdgeInsets.only(
                        //                                       top: 10),
                        //                               child: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .spaceBetween,
                        //                                 children: [
                        //                                   Text(
                        //                                       AppLocalizations.of(
                        //                                               context)!
                        //                                           .mapStyle,
                        //                                       style: reguler.copyWith(
                        //                                           color:
                        //                                               blackSecondary1,
                        //                                           fontSize: 16)),
                        //                                   InkWell(
                        //                                     onTap: () {
                        //                                       launchUrl(
                        //                                           mode: LaunchMode
                        //                                               .externalApplication,
                        //                                           Uri.parse(
                        //                                               'https://www.google.com/maps/search/?api=1&query=${pLat},${pLong}'));
                        //                                     },
                        //                                     child: Text(
                        //                                       AppLocalizations.of(
                        //                                               context)!
                        //                                           .showonGMaps,
                        //                                       style: reguler.copyWith(
                        //                                           fontStyle:
                        //                                               FontStyle
                        //                                                   .italic,
                        //                                           decoration:
                        //                                               TextDecoration
                        //                                                   .underline,
                        //                                           fontSize: 10,
                        //                                           color:
                        //                                               bluePrimary),
                        //                                     ),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                             Padding(
                        //                               padding:
                        //                                   const EdgeInsets.only(
                        //                                       top: 12),
                        //                               child: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .spaceAround,
                        //                                 children: [
                        //                                   Expanded(
                        //                                       flex: 1,
                        //                                       child: InkWell(
                        //                                         onTap: () {
                        //                                           setState(() {
                        //                                             _myMapSatelliteEnabled =
                        //                                                 false;
                        //                                             _mapType =
                        //                                                 MapType
                        //                                                     .normal;

                        //                                             // _myMapSatelliteEnabled =
                        //                                             //     !_myMapSatelliteEnabled;
                        //                                             // _mapType = _myMapSatelliteEnabled
                        //                                             //     ? MapType
                        //                                             //         .satellite
                        //                                             //     : MapType
                        //                                             //         .normal;
                        //                                           });
                        //                                         },
                        //                                         child: Container(
                        //                                           height: 36,
                        //                                           // width: 159,
                        //                                           decoration: BoxDecoration(
                        //                                               border: Border.all(
                        //                                                   width:
                        //                                                       1,
                        //                                                   color: !_myMapSatelliteEnabled
                        //                                                       ? bluePrimary
                        //                                                       : greyColor),
                        //                                               borderRadius:
                        //                                                   BorderRadius.circular(
                        //                                                       4)),
                        //                                           child: Row(
                        //                                             mainAxisAlignment:
                        //                                                 MainAxisAlignment
                        //                                                     .center,
                        //                                             children: [
                        //                                               Icon(
                        //                                                 Icons
                        //                                                     .location_on_outlined,
                        //                                                 color: !_myMapSatelliteEnabled
                        //                                                     ? bluePrimary
                        //                                                     : greyColor,
                        //                                                 size: 20,
                        //                                               ),
                        //                                               Text(
                        //                                                 AppLocalizations.of(
                        //                                                         context)!
                        //                                                     .defaultMap,
                        //                                                 style: reguler.copyWith(
                        //                                                     fontSize:
                        //                                                         12,
                        //                                                     color:
                        //                                                         blackSecondary3),
                        //                                               )
                        //                                             ],
                        //                                           ),
                        //                                         ),
                        //                                       )),
                        //                                   const SizedBox(
                        //                                     width: 5,
                        //                                   ),
                        //                                   Expanded(
                        //                                       flex: 1,
                        //                                       child: InkWell(
                        //                                         onTap: () {
                        //                                           setState(() {
                        //                                             _myMapSatelliteEnabled =
                        //                                                 true;
                        //                                             _mapType = MapType
                        //                                                 .satellite;
                        //                                           });
                        //                                         },
                        //                                         child: Container(
                        //                                           height: 36,
                        //                                           // width: 159,
                        //                                           decoration: BoxDecoration(
                        //                                               border: Border.all(
                        //                                                   width:
                        //                                                       1,
                        //                                                   color: !_myMapSatelliteEnabled
                        //                                                       ? greyColor
                        //                                                       : bluePrimary),
                        //                                               borderRadius:
                        //                                                   BorderRadius.circular(
                        //                                                       4)),
                        //                                           child: Row(
                        //                                             mainAxisAlignment:
                        //                                                 MainAxisAlignment
                        //                                                     .center,
                        //                                             children: [
                        //                                               Icon(
                        //                                                 Icons
                        //                                                     .map_outlined,
                        //                                                 color: !_myMapSatelliteEnabled
                        //                                                     ? greyColor
                        //                                                     : bluePrimary,
                        //                                                 size: 20,
                        //                                               ),
                        //                                               Text(
                        //                                                 AppLocalizations.of(
                        //                                                         context)!
                        //                                                     .satelliteMap,
                        //                                                 style: reguler.copyWith(
                        //                                                     fontSize:
                        //                                                         12,
                        //                                                     color:
                        //                                                         blackSecondary3),
                        //                                               )
                        //                                             ],
                        //                                           ),
                        //                                         ),
                        //                                       )),
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                             Padding(
                        //                               padding:
                        //                                   const EdgeInsets.only(
                        //                                       top: 15),
                        //                               child: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .start,
                        //                                 children: [
                        //                                   Text(
                        //                                       AppLocalizations.of(
                        //                                               context)!
                        //                                           .mapDetail,
                        //                                       style: reguler.copyWith(
                        //                                           color:
                        //                                               blackSecondary1,
                        //                                           fontSize: 16)),
                        //                                   // Text(
                        //                                   //   'Tampilkan di Google Maps',
                        //                                   //   style: reguler.copyWith(
                        //                                   //       fontStyle:
                        //                                   //           FontStyle
                        //                                   //               .italic,
                        //                                   //       decoration:
                        //                                   //           TextDecoration
                        //                                   //               .underline,
                        //                                   //       fontSize: 10,
                        //                                   //       color:
                        //                                   //           bluePrimary),
                        //                                   // ),
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                             InkWell(
                        //                               onTap: () {
                        //                                 Navigator.push(
                        //                                     context,
                        //                                     MaterialPageRoute(
                        //                                         builder: (context) => StreetView(
                        //                                             Latitude: double.parse(
                        //                                                 vehicleDetail
                        //                                                     .data
                        //                                                     .result
                        //                                                     .lat),
                        //                                             Longitude: double.parse(
                        //                                                 vehicleDetail
                        //                                                     .data
                        //                                                     .result
                        //                                                     .lon),
                        //                                             Angle:
                        //                                                 angle)));
                        //                               },
                        //                               child: Padding(
                        //                                 padding:
                        //                                     const EdgeInsets.only(
                        //                                         top: 12),
                        //                                 child: Row(
                        //                                   mainAxisAlignment:
                        //                                       MainAxisAlignment
                        //                                           .spaceBetween,
                        //                                   children: [
                        //                                     Row(
                        //                                       children: [
                        //                                         Image.asset(
                        //                                           'assets/mapdetail/streetview.png',
                        //                                           height: 20,
                        //                                         ),
                        //                                         Padding(
                        //                                           padding:
                        //                                               const EdgeInsets
                        //                                                       .only(
                        //                                                   left:
                        //                                                       15),
                        //                                           child: Text(
                        //                                               AppLocalizations.of(
                        //                                                       context)!
                        //                                                   .streetView,
                        //                                               style: reguler.copyWith(
                        //                                                   color:
                        //                                                       blackSecondary3,
                        //                                                   fontSize:
                        //                                                       12)),
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                     Icon(
                        //                                       Icons
                        //                                           .arrow_forward_rounded,
                        //                                       size: 20,
                        //                                       color: blueGradient,
                        //                                     )
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                             Padding(
                        //                               padding:
                        //                                   const EdgeInsets.only(
                        //                                       top: 8, bottom: 3),
                        //                               child: Divider(
                        //                                 height: .5,
                        //                                 thickness: .5,
                        //                                 endIndent: 0,
                        //                                 indent: 0,
                        //                                 color: greyColor,
                        //                               ),
                        //                             ),
                        //                             InkWell(
                        //                               onTap: () {
                        //                                 setState(() {
                        //                                   _myTrafficEnabled =
                        //                                       !_myTrafficEnabled;
                        //                                 });
                        //                               },
                        //                               child: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .spaceBetween,
                        //                                 children: [
                        //                                   Expanded(
                        //                                     flex: 1,
                        //                                     // width: 285,
                        //                                     child: Row(
                        //                                       children: [
                        //                                         Image.asset(
                        //                                           'assets/mapdetail/traffic.png',
                        //                                           height: 20,
                        //                                         ),
                        //                                         Padding(
                        //                                           padding:
                        //                                               const EdgeInsets
                        //                                                       .only(
                        //                                                   left:
                        //                                                       15),
                        //                                           child: Text(
                        //                                               AppLocalizations.of(
                        //                                                       context)!
                        //                                                   .trafficView,
                        //                                               style: reguler.copyWith(
                        //                                                   color:
                        //                                                       blackSecondary3,
                        //                                                   fontSize:
                        //                                                       12)),
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                   ),
                        //                                   Switch(
                        //                                     value:
                        //                                         _myTrafficEnabled,
                        //                                     // activeColor: blackPrimary,
                        //                                     // activeThumbImage:
                        //                                     //     const AssetImage(
                        //                                     //         'assets/mapcenter.png'),
                        //                                     // inactiveThumbImage:
                        //                                     //     const AssetImage(
                        //                                     //         'assets/mapcenter.png'),
                        //                                     onChanged: (value) {
                        //                                       setState(() {
                        //                                         _myTrafficEnabled =
                        //                                             !_myTrafficEnabled;
                        //                                       });
                        //                                     },
                        //                                   )
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                             Padding(
                        //                               padding:
                        //                                   const EdgeInsets.only(
                        //                                       top: 3, bottom: 3),
                        //                               child: Divider(
                        //                                 height: .5,
                        //                                 thickness: .5,
                        //                                 endIndent: 0,
                        //                                 indent: 0,
                        //                                 color: greyColor,
                        //                               ),
                        //                             ),
                        //                             InkWell(
                        //                               onTap: () {
                        //                                 if (showPOI == true) {
                        //                                   setState(() {
                        //                                     showPOI = false;
                        //                                   });
                        //                                   _setPoi();
                        //                                 } else {
                        //                                   setState(() {
                        //                                     showPOI = true;
                        //                                   });
                        //                                   _setPoi();
                        //                                 }
                        //                               },
                        //                               child: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .spaceBetween,
                        //                                 children: [
                        //                                   Expanded(
                        //                                     flex: 1,
                        //                                     // width: 285,
                        //                                     child: Row(
                        //                                       children: [
                        //                                         Image.asset(
                        //                                           'assets/mapdetail/poi.png',
                        //                                           height: 20,
                        //                                         ),
                        //                                         Padding(
                        //                                           padding:
                        //                                               const EdgeInsets
                        //                                                       .only(
                        //                                                   left:
                        //                                                       15),
                        //                                           child: Text(
                        //                                               AppLocalizations.of(
                        //                                                       context)!
                        //                                                   .poiView,
                        //                                               style: reguler.copyWith(
                        //                                                   color:
                        //                                                       blackSecondary3,
                        //                                                   fontSize:
                        //                                                       12)),
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                   ),
                        //                                   Switch(
                        //                                     value: showPOI,
                        //                                     // activeColor: blackPrimary,
                        //                                     // activeThumbImage:
                        //                                     //     const AssetImage(
                        //                                     //         'assets/mapcenter.png'),
                        //                                     // inactiveThumbImage:
                        //                                     //     const AssetImage(
                        //                                     //         'assets/mapcenter.png'),
                        //                                     onChanged: (value) {
                        //                                       if (showPOI ==
                        //                                           true) {
                        //                                         setState(() {
                        //                                           showPOI = false;
                        //                                         });
                        //                                         _setPoi();
                        //                                       } else {
                        //                                         setState(() {
                        //                                           showPOI = true;
                        //                                         });
                        //                                         _setPoi();
                        //                                       }
                        //                                     },
                        //                                   )
                        //                                 ],
                        //                               ),
                        //                             )
                        //                           ],
                        //                         ),
                        //                       );
                        //                     },
                        //                   );
                        //                 },
                        //               );
                        //             },
                        //             child: Image.asset(
                        //               'assets/iconmenudeactive.png',
                        //               height: 40,
                        //             ),
                        //           ),
                        //           const SizedBox(
                        //             height: 8,
                        //           ),
                        //           InkWell(
                        //             onTap: () {
                        //               final MarkerId markerId = MarkerId(
                        //                   vehicleDetail.data.result.imei);
                        //               // _doCenter(markerId);
                        //               gMapController?.animateCamera(
                        //                   CameraUpdate.newCameraPosition(
                        //                       CameraPosition(
                        //                           target: LatLng(
                        //                               double.parse(vehicleDetail
                        //                                   .data.result.lat),
                        //                               double.parse(vehicleDetail
                        //                                   .data.result.lon)),
                        //                           zoom: 15.0)));
                        //             },
                        //             child: Image.asset(
                        //               'assets/mapicon.png',
                        //               width: 40,
                        //             ),
                        //           ),
                        //           const SizedBox(
                        //             height: 8,
                        //           ),
                        //           InkWell(
                        //             onTap: () {
                        //               launchUrl(
                        //                   Uri.parse(url.data.results.whatsapp),
                        //                   mode: LaunchMode.externalApplication);
                        //             },
                        //             child: Image.asset(
                        //               'assets/WA.png',
                        //               width: 40,
                        //             ),
                        //           ),
                        //           const SizedBox(
                        //             height: 8,
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.only(right: 3),
                        //             child: InkWell(
                        //               onTap: () {
                        //                 _currentLocation();
                        //                 // getLocation();
                        //               },
                        //               child: Container(
                        //                   width: 32,
                        //                   height: 32,
                        //                   decoration: BoxDecoration(
                        //                       color: blueGradient,
                        //                       boxShadow: [
                        //                         BoxShadow(
                        //                           color: blackSecondary2,
                        //                           offset: const Offset(0.0, 3),
                        //                           blurRadius: 6.0,
                        //                         ),
                        //                       ],
                        //                       borderRadius:
                        //                           BorderRadius.circular(32)),
                        //                   child: Icon(
                        //                     Icons.location_searching,
                        //                     size: 18,
                        //                     color: whiteColor,
                        //                   )),
                        //             ),
                        //           )
                        //         ],
                        //       ),
                        //       // Column(
                        //       //   mainAxisAlignment: MainAxisAlignment.end,
                        //       //   children: [
                        //       //     InkWell(
                        //       //       onTap: () {
                        //       //         final MarkerId markerId = MarkerId(
                        //       //             vehicleDetail.data.result.imei);
                        //       //         // _doCenter(markerId);
                        //       //         gMapController?.animateCamera(CameraUpdate
                        //       //             .newCameraPosition(CameraPosition(
                        //       //                 target: LatLng(
                        //       //                     vehicleDetail.data.result.lat,
                        //       //                     vehicleDetail.data.result.lon),
                        //       //                 zoom: 15.0)));
                        //       //       },
                        //       //       child: Image.asset(
                        //       //         'assets/mapicon.png',
                        //       //         width: 40,
                        //       //       ),
                        //       //     ),
                        //       //     const SizedBox(
                        //       //       height: 8,
                        //       //     ),
                        //       //     Image.asset(
                        //       //       'assets/WA.png',
                        //       //       width: 40,
                        //       //     ),
                        //       //     const SizedBox(
                        //       //       height: 8,
                        //       //     ),

                        //       //     // InkWell(
                        //       //     //   onTap: () async {
                        //       //     //     if (_timer.isActive) {
                        //       //     //       _timer.cancel();
                        //       //     //       await onEnd();
                        //       //     //     }
                        //       //     //   },
                        //       //     //   child: Image.asset(
                        //       //     //     'assets/refreshicon.png',
                        //       //     //     width: 32,
                        //       //     //   ),
                        //       //     // )
                        //       //   ],
                        //       // )
                        //     ],
                        //   ),
                        // ),
                      ],
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
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
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
        ),
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress) {
            return false;
          } else {
            return true;
          }
        });
  }

  printText() {
    print(textController.text);
  }
}
