// ignore_for_file: avoid_print, library_prefixes, depend_on_referenced_packages, unused_field, unused_local_variable, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:gpsid/model/poi.model.dart';
import 'package:gpsid/pages/StreetView.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/parkingreportlist.model.dart';
import 'package:gpsid/model/stopreportlist.model.dart';
import 'package:gpsid/model/trackreplay.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui' as ui;
import 'package:flutter_google_street_view/flutter_google_street_view.dart'
    as SV;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class TrackreplayPage extends StatefulWidget {
  final String licensePlate;
  final String imei;
  final String timeStart;
  final String timeEnd;
  final String expDate;
  final String vehicleStatus;
  final int icon;
  final bool darkMode;
  @override
  State<TrackreplayPage> createState() => TrackreplayPageState();

  const TrackreplayPage(
      {Key? key,
      required this.imei,
      required this.timeStart,
      required this.timeEnd,
      required this.licensePlate,
      required this.expDate,
      required this.vehicleStatus,
      required this.icon,
      required this.darkMode})
      : super(key: key);
}

class TrackreplayPageState extends State<TrackreplayPage> {
  var size, height, width;
  late Future<dynamic> _getTrackReplay;
  late Future<dynamic> _getStop;
  late Future<dynamic> _getPark;
  late StopReportListModel initStopMarker;
  late ParkingReportListModel initParkMarker;
  late TrackReplayModel initTrackReplay;
  int page = 1;
  int perPage = 25;
  bool _isError = false;
  String _errCode = '';
  int _totalDistance = 0;
  int indexLength = 0;
  late Polyline _polyline;
  late Set<Polyline> _polylineII = {};
  int _startMillage = 0;
  int _totalMileage = 0;
  double _lat = 0.0;
  double _long = 0.0;
  int _angle = 0;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> vehicleMarker = <MarkerId, Marker>{};
  String initStop = '';
  String initPark = '';
  String initTrack = '';
  String vehStatus = '';
  bool _isPlay = false;
  bool _isPause = false;
  SV.LatLng _streetViewLongLat = const SV.LatLng(0, 0);
  late Timer _timer;
  int _millage = 0;
  int _speed = 0;
  String _time = '';
  int _speedSlider = 0;
  late GoogleMapController _controller;
  String time = '';
  bool slideUp = false;
  String fastForward = '';
  bool faster = false;
  bool showPark = true;
  bool showStop = true;
  bool noParkMarker = false;
  bool noStopMarker = false;
  String address = '';
  String addressII = '';
  late double pLat;
  late double pLong;
  late double angle;
  // PanelController pc = PanelController();
  late var res;
  String mapStyle = '';
  String mapStyleStandard = '';
  final disp = [];
  File? displayImage;
  late BitmapDescriptor markerbitmap;
  LatLng loc1 = const LatLng(27.6602292, 85.308027);
  LatLng loc2 = const LatLng(27.6599592, 85.3102498);
  LatLng loc3 = const LatLng(27.661838, 85.308543);
  int speed = 1000;
  double zoomMaps = 16.0;
  int _refreshTime = 30;
  bool showPOI = false;
  bool _myTrafficEnabled = false;
  bool _myMapSatelliteEnabled = false;
  MapType _mapType = MapType.normal;
  final controller = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/maps.json').then(
      (value) {
        setState(() {
          mapStyle = value;
        });
      },
    );
    rootBundle.loadString('assets/mapsstandard.json').then(
      (val) {
        setState(() {
          mapStyleStandard = val;
        });
      },
    );
    DateTime? getTime = DateTime.parse(widget.timeStart);
    String formatTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(getTime);
    time = formatTime;
    _time = time;
    vehStatus = widget.vehicleStatus;
    if (widget.vehicleStatus == 'Online') {
      setState(() {
        vehStatus = 'moving';
      });
    } else {
      setState(() {
        vehStatus = widget.vehicleStatus;
      });
    }
    _getTrackReplay = getTrackReplay();
    _getStop = getStopMarker();
    _getPark = getParkMarker();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<dynamic> getTrackReplay() async {
    final result = await APIService().getTrackReplay(
        page, perPage, widget.imei, widget.timeStart, widget.timeEnd);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853trackreplay';
      });
    } else {
      if (result is TrackReplayModel) {
        List<ResultTrackReplay> listTrackreplay = [];
        if (result.data.result.length == 1) {
          listTrackreplay.addAll(result.data.result);
        } else {
          result.data.result.forEach((el) {
            if (el.lat != 0.0 && el.lon != 0.0) {
              listTrackreplay.add(el);
            }
          });
        }
        List<LatLng> listLatLng = [];
        listTrackreplay.forEach((el) {
          listLatLng.add(LatLng(el.lat, el.lon));
        });
        setState(() {
          _isError = false;
          _errCode = '';
          indexLength = result.data.result.length;
          LatLngBounds boundsFromLatLngList(List<LatLng> list) {
            double? x0, x1, y0, y1;
            for (LatLng latLng in list) {
              if (x0 == null || x1 == null || y0 == null || y1 == null) {
                x0 = x1 = latLng.latitude;
                y0 = y1 = latLng.longitude;
              } else {
                if (latLng.latitude > x1) x1 = latLng.latitude;
                if (latLng.latitude < x0) x0 = latLng.latitude;
                if (latLng.longitude > y1) y1 = latLng.longitude;
                if (latLng.longitude < y0) y0 = latLng.longitude;
              }
            }

            return LatLngBounds(
                northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
          }

          Future.delayed(
            const Duration(seconds: 2),
            () {
              _controller.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
          // _controller.setMapStyle(mapStyleStandard);
        });
        return result;
      } else {
        return [];
      }
    }
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
                addressII = value;
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
        // var addressResult;
        var addressResult = json.decode(result);
        setState(() {
          _isError = false;
          _errCode = '';

          address = addressResult['message'];
          addressII = addressResult['message'];
          // pc.close();
          // initStopReport[index].gsmNo = addressResult['message'];
        });
      }
    }
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

  Future<dynamic> getStopMarker() async {
    final result = await APIService().getStopReport(page, perPage, widget.imei,
        widget.timeStart, widget.timeEnd, 60, 86400);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '36926Stop';
        noStopMarker = true;
      });
    } else {
      if (result is StopReportListModel) {
        setState(() {
          noStopMarker = false;
        });
        return result;
      }
      if (result is MessageModel) {
        setState(() {
          noStopMarker = true;
        });
        return result;
      } else {
        setState(() {
          noParkMarker = true;
        });
        return [];
      }
    }
  }

  Future<dynamic> getParkMarker() async {
    final result = await APIService().getParkingReport(page, perPage,
        widget.imei, widget.timeStart, widget.timeEnd, 60, 86400);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '36926Park';
        noParkMarker = true;
      });
    } else {
      if (result is ParkingReportListModel) {
        setState(() {
          noParkMarker = false;
        });
        return result;
      } else {
        setState(() {
          noParkMarker = true;
        });
        return [];
      }
    }
  }

  void _addMarker() async {
    String? label = '';
    switch (vehStatus.toLowerCase()) {
      case "moving":
        label = vehStatus;
        break;
      case "stop":
        label = vehStatus;
        break;
      case "lost":
        label = vehStatus;
        break;
      case "alarm":
        label = vehStatus;
        break;
      case "parking":
        label = vehStatus;
        break;
      default:
    }

    int iconSize = (MediaQuery.of(context).size.width / 10).round() * 2;

    ResultTrackReplay startTrack = initTrackReplay.data.result[0];
    // _startMillage = _startTrack.mileage;
    ResultTrackReplay finishTrack =
        initTrackReplay.data.result[indexLength - 1];

    _totalMileage = initTrackReplay.data.totalDistance;

    // dynamic dataBytes = await APIService().getIconFullGmaps(label);

    // ui.Codec codec = await ui.instantiateImageCodec(
    //     dataBytes.buffer.asUint8List(),
    //     targetWidth: iconSize);
    // ui.FrameInfo fi = await codec.getNextFrame();
    // var imgByte = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
    //     .buffer
    //     .asUint8List();

    final MarkerId markerId = MarkerId(widget.imei);
    pLat = startTrack.lat;
    pLong = startTrack.lon;
    _lat = pLat;
    _long = pLong;
    _angle = startTrack.angle;
    // final Marker marker = Marker(
    //   markerId: const MarkerId('icon'),
    //   position: LatLng(pLat, pLng),
    //   onTap: () {
    //     setState(() {
    //       _lat = pLat;
    //       _long = pLng;
    //     });
    //   },
    //   infoWindow: InfoWindow(title: widget.licensePlate),
    //   icon: await BitmapDescriptor.fromAssetImage(
    //     const ImageConfiguration(),
    //     'assets/moving_marker_2.png',
    //   ),
    //   rotation: double.parse(startTrack.angle.toString()),
    // );

    //start marker
    getBytesFromAsset('assets/startmarker.png', 96).then((onValue) async {
      const MarkerId markerId = MarkerId('start');

      double pLat = startTrack.lat;
      double pLng = startTrack.lon;

      // await getStartAddress(pLat.toString(), pLng.toString());

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(pLat, pLng),
        onTap: () {
          setState(() {
            _lat = pLat;
            _long = pLng;
          });
        },
        infoWindow: InfoWindow(
          title: GeneralService().setTitleCase('Start'),
        ),
        icon: BitmapDescriptor.fromBytes(onValue),
      );
      setState(() {
        _markers[markerId] = marker;
      });

      // if (mounted) {
      //   setState(() {
      //     _markers[markerId] = marker;
      //   });
      // }
    });

    //finish marker
    getBytesFromAsset('assets/endmarker.png', 96).then((onValue) async {
      const MarkerId markerId = MarkerId('finish');

      double pLat = finishTrack.lat;
      double pLng = finishTrack.lon;
      // await getFinishAddress(pLat.toString(), pLng.toString());

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(pLat, pLng),
        onTap: () {
          setState(() {
            _lat = pLat;
            _long = pLng;
          });
        },
        infoWindow: InfoWindow(
          title: GeneralService().setTitleCase('Finish'),
        ),
        icon: BitmapDescriptor.fromBytes(onValue),
      );
      setState(() {
        _markers[markerId] = marker;
      });
    });

    // if (this.mounted) {
    //   setState(() {});
    // }
    // if (this.mounted) {
    //   setState(() {
    //     _markers[markerId] = marker;
    //   });
    // }
    // setState(() {});
  }

  setColor(int speed) {}

  void _setPolyLines() async {
    List<LatLng> latLng = [];
    for (var el in initTrackReplay.data.result) {
      latLng.add(LatLng(el.lat, el.lon));
    }
    Polyline polyline;
    int index = 0;
    setState(() {
      _polylineII.add(Polyline(
        polylineId: const PolylineId('all'),
        visible: true,
        width: 5, //width of polyline
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        points: latLng,
        color: greenPrimary, //color of polyline
      ));
    });

    initTrackReplay.data.result.forEach((er) async {
      // latLng.add(LatLng(er.lat, er.lon));
      if (er.speed >= 0 && er.speed <= 30) {
        setState(() {
          _polylineII.add(Polyline(
            polylineId: PolylineId(er.lat.toString()),
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            // jointType: JointType.round,
            visible: true,
            width: 5, //width of polyline
            points: [
              LatLng(initTrackReplay.data.result[index].lat,
                  initTrackReplay.data.result[index].lon),
              LatLng(
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lat,
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lon)
            ],
            color: greenPrimary, //color of polyline
          ));
          index == initTrackReplay.data.result.length - 1 ? {} : index++;
        });

        // setState(() {});
      } else if (er.speed >= 30 && er.speed <= 60) {
        setState(() {
          _polylineII.add(Polyline(
            polylineId: PolylineId(er.lat.toString()),
            endCap: Cap.roundCap,
            jointType: JointType.round,
            visible: true,
            width: 5, //width of polyline
            points: [
              LatLng(initTrackReplay.data.result[index].lat,
                  initTrackReplay.data.result[index].lon),
              LatLng(
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lat,
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lon)
            ],
            color: bluePrimary, //color of polyline
          ));
          index == initTrackReplay.data.result.length - 1 ? {} : index++;
        });

        // setState(() {});
      } else if (er.speed >= 60 && er.speed <= 100) {
        setState(() {
          _polylineII.add(Polyline(
            polylineId: PolylineId(er.lat.toString()),
            endCap: Cap.roundCap,
            jointType: JointType.round,
            visible: true,
            width: 5, //width of polyline
            points: [
              LatLng(initTrackReplay.data.result[index].lat,
                  initTrackReplay.data.result[index].lon),
              LatLng(
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lat,
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lon)
            ],
            color: yellowPrimary, //color of polyline
          ));
          index == initTrackReplay.data.result.length - 1 ? {} : index++;
        });

        // setState(() {});
      } else if (er.speed >= 100) {
        setState(() {
          _polylineII.add(Polyline(
            polylineId: PolylineId(er.lat.toString()),
            endCap: Cap.roundCap,
            jointType: JointType.round,
            visible: true,
            width: 5, //width of polyline
            points: [
              LatLng(initTrackReplay.data.result[index].lat,
                  initTrackReplay.data.result[index].lon),
              LatLng(
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lat,
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lon)
            ],
            color: redPrimary, //color of polyline
          ));
          index == initTrackReplay.data.result.length - 1 ? {} : index++;
        });

        // setState(() {});
      } else {
        setState(() {
          _polylineII.add(Polyline(
            polylineId: PolylineId(er.lat.toString()),
            endCap: Cap.roundCap,
            jointType: JointType.round,
            visible: true,
            width: 5, //width of polyline
            points: [
              LatLng(initTrackReplay.data.result[index].lat,
                  initTrackReplay.data.result[index].lon),
              LatLng(
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lat,
                  initTrackReplay
                      .data
                      .result[index == initTrackReplay.data.result.length - 1
                          ? index
                          : index + 1]
                      .lon)
            ],
            color: greenPrimary, //color of polyline
          ));
          index == initTrackReplay.data.result.length - 1 ? {} : index++;
        });

        // setState(() {});
      }

      // data = GetPolyLineModel(polyline: [
      //   PolylineData(
      //       id: index,
      //       latlng: [LatlngData(lat: er.lat, lon: er.lon)],
      //       speed: er.speed)
      // ]);
    });
    // data.polyline.forEach((ee) {
    //   if (ee.speed < 35) {
    //     _polylineII.add(Polyline(
    //       polylineId: PolylineId(ee.id.toString()),
    //       visible: true,
    //       width: 5, //width of polyline
    //       points: [LatLng(ee.latlng[index].lat, ee.latlng[index].lon)],
    //       color: Colors.deepPurpleAccent, //color of polyline
    //     ));
    //   } else {
    //     _polylineII.add(Polyline(
    //       polylineId: PolylineId(ee.id.toString()),
    //       visible: true,
    //       width: 5, //width of polyline
    //       points: [LatLng(ee.latlng[index].lat, ee.latlng[index].lon)],
    //       color: Colors.deepOrangeAccent, //color of polyline
    //     ));
    //   }
    //   setState(() {});
    // });

    // _polylineII.add(Polyline(
    //   polylineId: PolylineId(loc1.toString()),
    //   visible: true,
    //   width: 5, //width of polyline
    //   points: [
    //     loc1, //start point
    //     loc2, //end point
    //   ],
    //   color: Colors.deepPurpleAccent, //color of polyline
    // ));

    // _polylineII.add(Polyline(
    //   polylineId: PolylineId(loc2.toString()),
    //   visible: true,
    //   width: 5, //width of polyline
    //   points: [
    //     loc2, //start point
    //     loc3, //end point
    //   ],
    //   color: Colors.deepOrangeAccent, //color of polyline
    // ));
  }

  // void _setPolyLines() async {
  //   List<LatLng> latlng = [];
  //   int index = 0;
  //   int speed = 0;

  //   latlng.clear();
  //   // for (var data in initTrackReplay.data.result) {
  //   //   double pLat = data.lat;
  //   //   double pLng = data.lon;
  //   //   latlng.add(LatLng(pLat, pLng));
  //   //   speed = data.speed;
  //   //   // if (data.speed > 10) {
  //   //   //   _polyline.add(Polyline(
  //   //   //     polylineId: PolylineId(index.toString()),
  //   //   //     visible: true,
  //   //   //     points: latlng,
  //   //   //     color: bluePrimary,
  //   //   //     width: 5,
  //   //   //   ));
  //   //   //   index++;
  //   //   // } else {
  //   //   //   _polyline.add(Polyline(
  //   //   //     polylineId: PolylineId(index.toString()),
  //   //   //     visible: true,
  //   //   //     points: latlng,
  //   //   //     color: redPrimary,
  //   //   //     width: 5,
  //   //   //   ));
  //   //   //   index++;
  //   //   // }
  //   // }
  //   List<LatLng> latLng30 = [];
  //   List<LatLng> latLng60 = [];
  //   List<LatLng> latLng100 = [];
  //   final Set<Polyline> _polyline30 = {};
  //   final Set<Polyline> _polyline60 = {};
  //   final Set<Polyline> _polyline100 = {};

  //   initTrackReplay.data.result.forEach((er) {
  //     latlng.add(LatLng(er.lat, er.lon));
  //   });

  //   initTrackReplay.data.result.forEach((el) {
  //     _polyline.add(Polyline(
  //       polylineId: PolylineId('bbb'),
  //       visible: true,
  //       points: [LatLng(el.lat, el.lon)],
  //       color: el.speed > 100 ? redPrimary : blueGradient,
  //       width: 5,
  //     ));
  //     // _polyline.add(Polyline(
  //     //   polylineId: PolylineId('bbb'),
  //     //   visible: true,
  //     //   points: latlng,
  //     //   color: blueGradient,
  //     //   width: 5,
  //     // ));
  //     // _polylineII.add(_polyline);
  //     // _polylineII.add(Polyline(
  //     //     polylineId: PolylineId('asd'),
  //     //     color: el.speed > 100 ? redPrimary : blueGradient,
  //     //     width: 5,
  //     //     points: [
  //     //       LatLng(_polyline.points[0].latitude, _polyline.points[0].longitude)
  //     //     ]));
  //   });
  //   _polylineII.add(Polyline(
  //       polylineId: PolylineId(index.toString()),
  //       color: initTrackReplay.data.result[index].speed > 0 &&
  //               initTrackReplay.data.result[index].speed <= 32
  //           ? redPrimary
  //           : purplePrimary,
  //       width: 5,
  //       points: _polyline[index].points));
  //   index++;
  //   print(latLng100);
  //   print(latLng60);
  //   print(latLng30);
  //   print(_polyline30);
  //   print(_polyline60);
  //   print(_polyline100);
  // }

  _setStop() async {
    // _addMarker();
    // _setPolyLines();
    int i = 11;
    String stopDur = '';
    if (initStopMarker.data.result.isNotEmpty) {
      for (var el in initStopMarker.data.result) {
        print('datalength stop = ${initStopMarker.data.result.length}');
        getBytesFromAsset('assets/stop.png', 96).then((onValue) {
          stopDur = _printDuration(Duration(seconds: el.duration));
          final MarkerId markerId = MarkerId(i.toString());

          double pLat = el.lat;
          double pLong = el.lon;
          final Marker marker = Marker(
            visible: showStop,
            markerId: markerId,
            position: LatLng(pLat, pLong),
            onTap: () {
              setState(() {
                _lat = pLat;
                _long = pLong;
              });
            },
            infoWindow: InfoWindow(
              // title:
              // Text(
              //   _printDuration(Duration(seconds: _getStopMarker.))
              // );
              title: 'Stop: $stopDur',
            ),
            icon: BitmapDescriptor.fromBytes(onValue),
          );
          if (mounted) {
            setState(() {
              _markers[markerId] = marker;
              i++;
            });
          }
        });
      }
    }
  }

  _setPark() async {
    // _addMarker();
    // _setPolyLines();
    int i = 00;
    String parkDur = '';
    if (initParkMarker.data.result.isNotEmpty) {
      for (var el in initParkMarker.data.result) {
        print('datalength park = ${initParkMarker.data.result.length}');
        getBytesFromAsset('assets/parking.png', 96).then((onValue) {
          parkDur = _printDuration(Duration(seconds: el.duration));
          final MarkerId markerId = MarkerId(i.toString());

          double pLat = el.lat;
          double pLong = el.lon;

          final Marker marker = Marker(
            visible: showPark,
            markerId: markerId,
            position: LatLng(pLat, pLong),
            onTap: () {
              setState(() {
                _lat = pLat;
                _long = pLong;
              });
            },
            infoWindow: InfoWindow(
              // title:
              // Text(
              //   _printDuration(Duration(seconds: _getStopMarker.))
              // );
              title: 'Park: $parkDur',
            ),
            icon: BitmapDescriptor.fromBytes(onValue),
          );
          if (mounted) {
            setState(() {
              _markers[markerId] = marker;
              i++;
            });
          }
        });
      }
    }
  }

  _setSatellite(bool enable) {
    enable
        ? setState(() {
            _myMapSatelliteEnabled = true;
            _mapType = MapType.satellite;
          })
        : setState(() {
            _myMapSatelliteEnabled = false;
            _mapType = MapType.normal;
          });
  }

  _setTraffic() async {
    setState(() {
      _myTrafficEnabled = !_myTrafficEnabled;
    });
  }

  _setPoi() async {
    await Dialogs().loadingDialog(context);
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
          // String fileName = '5_Hospital.png';
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
            infoWindow: InfoWindow(title: el.id.toString()),
            icon: getImg,
          );
          if (mounted) {
            setState(() {
              _markers[markerId] = marker;
            });
          }
        });
        // _startTimer();
      }
    }
    await Dialogs().hideLoaderDialog(context);
    Navigator.pop(context);
  }

  void _playPlaybackReplayData(bool setFaseter) async {
    fastForward == '2x' ||
            fastForward == '4x' ||
            fastForward == '8x' ||
            fastForward == '16x' ||
            fastForward == ''
        ? setFaseter
            ? {}
            : _isPlay = !_isPlay
        : {};
    String label = '';
    switch (vehStatus.toLowerCase()) {
      case "moving":
        label = vehStatus;
        break;
      case "stop":
        label = vehStatus;
        break;
      case "lost":
        label = vehStatus;
        break;
      case "alert":
        label = vehStatus;
        break;
      case "parking":
        label = vehStatus;
        break;
      default:
    }

    final MarkerId markerId = MarkerId(vehStatus);
    // dynamic dataBytes = await APIService().getIconFullGmaps(label);
    if (_isPause) {
      setState(() {
        // _controller.hideMarkerInfoWindow(markerId);
        _streetViewLongLat = _streetViewLongLat;
        // _newAngle = pAngleII;
        _markers[markerId] = _markers[markerId]!;
        // vehicleMarker[markerId] = vehicleMarker[markerId]!;
        _millage = _millage;
        _speed = _speed;
        _time = _time;
        _speedSlider = _speedSlider;
        // pc.close();
        address = '';
        addressII = '';
      });
    }

    // ui.Codec codec = await ui
    //     .instantiateImageCodec(dataBytes.buffer.asUint8List(), targetWidth: 64);
    // ui.FrameInfo fi = await codec.getNextFrame();
    // var imgByte = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
    //     .buffer
    //     .asUint8List();

    // setState(() {
    //   fastForward == '2x'
    //       ? speed = 800
    //       : fastForward == '4x'
    //           ? speed = 600
    //           : fastForward == '8x'
    //               ? speed = 800
    //               : fastForward == '16x'
    //                   ? 160
    //                   : speed = 1000;
    // });

    _timer = Timer.periodic(Duration(milliseconds: speed), (timer) async {
      int currIdx = _speedSlider;
      pLat = initTrackReplay.data.result[currIdx].lat;
      pLong = initTrackReplay.data.result[currIdx].lon;
      angle =
          double.parse(initTrackReplay.data.result[currIdx].angle.toString());
      int pAngle = initTrackReplay.data.result[currIdx].angle;
      String folder = 'localAsset';
      String fileName = initTrackReplay.data.result[currIdx].status
                  .toLowerCase() ==
              'online'
          ? '${widget.icon}_accOn.png'
          : initTrackReplay.data.result[currIdx].status.toLowerCase() ==
                  'no data'
              ? '${widget.icon}_lost.png'
              : initTrackReplay.data.result[currIdx].status.toLowerCase() ==
                      'stop'
                  ? '${widget.icon}_parking.png'
                  : '${widget.icon}_${initTrackReplay.data.result[currIdx].status.toLowerCase()}.png';
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
      markerbitmap = getImg;
      int index = 0;
      index = _speedSlider;
      final MarkerId markerIdII = MarkerId(index.toString());
      _lat = pLat;
      _long = pLong;
      _angle = pAngle;
      final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(pLat, pLong),
          infoWindow:
              InfoWindow(title: widget.licensePlate, snippet: addressII),
          icon: markerbitmap,
          rotation: angle,
          anchor: const Offset(0.5, 0.2));

      _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: marker.position,
          zoom: zoomMaps,
        ),
      ));
      DateTime? duration =
          DateTime.parse(initTrackReplay.data.result[currIdx].time).toLocal();

      time = DateFormat('yyyy-MM-dd HH:mm:ss').format(duration);

      setState(() {
        _streetViewLongLat = SV.LatLng(pLat, pLong);
        // _newAngle = pAngleII;
        _markers[markerId] = marker;
        // vehicleMarker[markerId] = marker;
        _millage = initTrackReplay.data.result[currIdx].milleage;
        _speed = initTrackReplay.data.result[currIdx].speed;
        _time = time;
        _speedSlider++;
      });

      if (_speedSlider == initTrackReplay.data.result.length) {
        _stopPlay();
      }
    });
  }

  _pausePlayback() async {
    // int currIdx = _speedSlider;
    await getAddress(pLat.toString(), pLong.toString());
    final MarkerId markerId = MarkerId(vehStatus);
    int currIdx = _speedSlider;
    String folder = 'localAsset';
    // icon == 12 ? icon = 4 : icon;
    String fileName = initTrackReplay.data.result[currIdx].status
                .toLowerCase() ==
            'online'
        ? '${widget.icon}_accOn.png'
        : initTrackReplay.data.result[currIdx].status.toLowerCase() == 'no data'
            ? '${widget.icon}_lost.png'
            : initTrackReplay.data.result[currIdx].status.toLowerCase() ==
                    'stop'
                ? '${widget.icon}_parking.png'
                : '${widget.icon}_${initTrackReplay.data.result[currIdx].status.toLowerCase()}.png';
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
    markerbitmap = getImg;
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(pLat, pLong),
      infoWindow: InfoWindow(title: widget.licensePlate, snippet: addressII),
      // icon: BitmapDescriptor.fromBytes(imgByte),
      // icon: await BitmapDescriptor.fromAssetImage(
      //   const ImageConfiguration(),
      //   'assets/moving_marker_2.png',
      // ),
      icon: markerbitmap,
      onTap: () async {
        await getAddressII(pLat.toString(), pLong.toString());
      },
      rotation: angle,
    );
    setState(() {
      // _timer.cancel();
      // _isPlay = !_isPlay;
      _streetViewLongLat = _streetViewLongLat;
      // _newAngle = pAngleII;
      // _markers[markerId] = _markers[markerId]!;
      _millage = _millage;
      _speed = _speed;
      _time = _time;
      _speedSlider = _speedSlider;
      _markers[markerId] = marker;
      // vehicleMarker[markerId] = marker;
    });
  }

  void _stopPlay() {
    _timer.cancel();
    setState(() {
      _speedSlider = 0;
      _isPlay = !_isPlay;
    });
  }

  fasterTrackreplay() {
    if (fastForward == '') {
      setState(() {
        fastForward = '2x';
        faster = true;
        speed = 800;
      });
    } else {
      if (fastForward == '2x') {
        setState(() {
          fastForward = '4x';
          faster = true;
          speed = 600;
        });
      } else {
        if (fastForward == '4x') {
          setState(() {
            fastForward = '8x';
            faster = true;
            speed = 200;
          });
        } else {
          if (fastForward == '8x') {
            setState(() {
              fastForward = '16x';
              faster = true;
              speed = 160;
            });
          } else {
            if (fastForward == '16x') {
              setState(() {
                fastForward = '';
                faster = false;
                speed = 1000;
              });
            }
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
          leading: IconButton(
            iconSize: 32,
            // padding: const EdgeInsets.only(top: 20),
            icon: const Icon(Icons.arrow_back_outlined),
            color: Colors.white,
            // onPressed: () => Navigator.of(context).pop(),
            onPressed: () {
              if (_isPlay) {
                _stopPlay();
              }
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.trackReplay,
                style: bold.copyWith(
                  fontSize: 16,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
              Text(
                widget.licensePlate,
                style: bold.copyWith(
                  fontSize: 12,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: whiteColor,
          child: FutureBuilder(
              future: Future.wait([_getTrackReplay, _getStop, _getPark]),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data[0] is ErrorTrapModel ||
                      snapshot.data[1] is ErrorTrapModel ||
                      snapshot.data[2] is ErrorTrapModel) {
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
                    if (snapshot.data[0] is TrackReplayModel) {
                      initTrackReplay = snapshot.data[0];
                      angle = double.parse(
                          initTrackReplay.data.result[0].angle.toString());
                      if (snapshot.data[1] is StopReportListModel) {
                        initStopMarker = snapshot.data[1];
                      } else {
                        snapshot.data[1] = false;
                        // initStopMarker = MessageModel.fromJson({});
                      }

                      if (snapshot.data[2] is ParkingReportListModel) {
                        initParkMarker = snapshot.data[2];
                      } else {
                        snapshot.data[2] = false;
                        // initParkMarker = ParkingReportListModel.fromJson({});
                      }

                      double pLat = initTrackReplay.data.result[0].lat;
                      double pLng = initTrackReplay.data.result[0].lon;
                      _totalDistance = initTrackReplay.data.totalDistance;

                      return Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                GoogleMap(
                                    // trafficEnabled: true,
                                    // minMaxZoomPreference:
                                    //     const MinMaxZoomPreference(50, 60),
                                    myLocationButtonEnabled: false,
                                    myLocationEnabled: false,
                                    trafficEnabled: _myTrafficEnabled,
                                    // compassEnabled: true,
                                    zoomControlsEnabled: false,
                                    zoomGesturesEnabled: true,
                                    mapType: _mapType,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(pLat, pLng),
                                      // zoom: 12.0,
                                    ),
                                    markers: Set<Marker>.of(_markers.values),
                                    polylines: _polylineII,
                                    onMapCreated: (GoogleMapController
                                        controllerParam) async {
                                      _controller = controllerParam;
                                      _addMarker();
                                      _setPolyLines();
                                      // await createPolyline();
                                      snapshot.data[1] == false
                                          ? {}
                                          : _setStop();
                                      // _setStop();
                                      snapshot.data[2] == false
                                          ? {}
                                          : _setPark();
                                      // !controller.isCompleted
                                      //     ? controller
                                      //         .complete(controllerParam)
                                      //     : {};
                                      controller.complete(controllerParam);
                                      // snapshot.data[2] != null ? _setPark() : {};
                                      // _setPoi();
                                    }),
                                // Visibility(
                                //   visible: true,
                                //   child: Animarker(
                                //     markers:
                                //         Set<Marker>.of(vehicleMarker.values),
                                //     mapId: controller.future
                                //         .then<int>((value) => value.mapId),
                                //     duration: Duration(milliseconds: speed),
                                //     // isActiveTrip: false,
                                //     shouldAnimateCamera: false,
                                //     child: GoogleMap(
                                //         // trafficEnabled: true,
                                //         // minMaxZoomPreference:
                                //         //     const MinMaxZoomPreference(50, 60),
                                //         myLocationButtonEnabled: false,
                                //         myLocationEnabled: false,
                                //         trafficEnabled: _myTrafficEnabled,
                                //         // compassEnabled: true,
                                //         zoomControlsEnabled: false,
                                //         zoomGesturesEnabled: true,
                                //         mapType: _mapType,
                                //         initialCameraPosition: CameraPosition(
                                //           target: LatLng(pLat, pLng),
                                //           zoom: 12.0,
                                //         ),
                                //         markers:
                                //             Set<Marker>.of(_markers.values),
                                //         polylines: _polylineII,
                                //         onMapCreated: (GoogleMapController
                                //             controllerParam) async {
                                //           _controller = controllerParam;
                                //           _addMarker();
                                //           _setPolyLines();
                                //           // await createPolyline();
                                //           snapshot.data[1] == false
                                //               ? {}
                                //               : _setStop();
                                //           // _setStop();
                                //           snapshot.data[2] == false
                                //               ? {}
                                //               : _setPark();
                                //           // !controller.isCompleted
                                //           //     ? controller
                                //           //         .complete(controllerParam)
                                //           //     : {};
                                //           controller.complete(controllerParam);
                                //           // snapshot.data[2] != null ? _setPark() : {};
                                //           // _setPoi();
                                //         }),
                                //   ),
                                // ),
                                // Visibility(
                                //   visible: faster,
                                //   child: GoogleMap(
                                //       // trafficEnabled: true,
                                //       // minMaxZoomPreference:
                                //       //     const MinMaxZoomPreference(50, 60),
                                //       myLocationButtonEnabled: false,
                                //       myLocationEnabled: false,
                                //       trafficEnabled: _myTrafficEnabled,
                                //       // compassEnabled: true,
                                //       zoomControlsEnabled: false,
                                //       zoomGesturesEnabled: true,
                                //       mapType: _mapType,
                                //       initialCameraPosition: CameraPosition(
                                //         target: LatLng(pLat, pLng),
                                //         zoom: 12.0,
                                //       ),
                                //       markers: Set<Marker>.of(_markers.values),
                                //       polylines: _polylineII,
                                //       onMapCreated: (GoogleMapController
                                //           controllerParam) async {
                                //         _controller = controllerParam;
                                //         _addMarker();
                                //         _setPolyLines();
                                //         // await createPolyline();
                                //         snapshot.data[1] == false
                                //             ? {}
                                //             : _setStop();
                                //         // _setStop();
                                //         snapshot.data[2] == false
                                //             ? {}
                                //             : _setPark();
                                //         !controller.isCompleted
                                //             ? controller
                                //                 .complete(controllerParam)
                                //             : {};
                                //         // snapshot.data[2] != null ? _setPark() : {};
                                //         // _setPoi();
                                //       }),
                                // ),
                                Positioned(
                                  // left: ,
                                  right: 10,
                                  top: 110,
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
                                                isDismissible: true,
                                                backgroundColor: whiteCardColor,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            8),
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
                                                                      top: 10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .mapStyle,
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
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
                                                                      top: 12),
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
                                                                          _setSatellite(
                                                                              false);
                                                                          setState(
                                                                              () {
                                                                            _myMapSatelliteEnabled =
                                                                                false;
                                                                            // _mapType =
                                                                            //     MapType.normal;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              36,
                                                                          // width: 159,
                                                                          decoration: BoxDecoration(
                                                                              color: _myMapSatelliteEnabled ? null : whiteColor,
                                                                              border: Border.all(width: 1, color: !_myMapSatelliteEnabled ? bluePrimary : greyColor),
                                                                              borderRadius: BorderRadius.circular(4)),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
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
                                                                          _setSatellite(
                                                                              true);
                                                                          setState(
                                                                              () {
                                                                            _myMapSatelliteEnabled =
                                                                                true;
                                                                            // _mapType =
                                                                            //     MapType.satellite;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              36,
                                                                          // width: 159,
                                                                          decoration: BoxDecoration(
                                                                              color: !_myMapSatelliteEnabled ? null : whiteColor,
                                                                              border: Border.all(width: 1, color: !_myMapSatelliteEnabled ? greyColor : bluePrimary),
                                                                              borderRadius: BorderRadius.circular(4)),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
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
                                                                            Latitude:
                                                                                pLat,
                                                                            Longitude:
                                                                                pLong,
                                                                            Angle:
                                                                                initTrackReplay.data.result[indexLength - 1].angle)));
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            12),
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
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 15),
                                                                          child: Text(
                                                                              AppLocalizations.of(context)!.streetView,
                                                                              style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 12)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .arrow_forward_rounded,
                                                                      size: 20,
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
                                                                // setState(() {
                                                                //   _myTrafficEnabled =
                                                                //       !_myTrafficEnabled;
                                                                // });
                                                                // _setTraffic();
                                                                setState(() {
                                                                  _setTraffic();
                                                                  _myTrafficEnabled
                                                                      ? !_myTrafficEnabled
                                                                      : _myTrafficEnabled;
                                                                  // _myTrafficEnabled =
                                                                  //     !_myTrafficEnabled;
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
                                                                        Image
                                                                            .asset(
                                                                          'assets/mapdetail/traffic.png',
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 15),
                                                                          child: Text(
                                                                              AppLocalizations.of(context)!.trafficView,
                                                                              style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 12)),
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
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        _setTraffic();
                                                                        _myTrafficEnabled
                                                                            ? !_myTrafficEnabled
                                                                            : _myTrafficEnabled;
                                                                        // _myTrafficEnabled =
                                                                        //     !_myTrafficEnabled;
                                                                      });
                                                                      // setState(
                                                                      //     () {
                                                                      //   _myTrafficEnabled =
                                                                      //       !_myTrafficEnabled;
                                                                      // });
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
                                                                  setState(() {
                                                                    showPOI =
                                                                        false;
                                                                  });
                                                                  _setPoi();
                                                                } else {
                                                                  setState(() {
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
                                                                    child: Row(
                                                                      children: [
                                                                        Image
                                                                            .asset(
                                                                          'assets/mapdetail/poi.png',
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 15),
                                                                          child: Text(
                                                                              AppLocalizations.of(context)!.poiView,
                                                                              style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 12)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Switch(
                                                                    value:
                                                                        showPOI,
                                                                    // activeColor: blackPrimary,
                                                                    // activeThumbImage:
                                                                    //     const AssetImage(
                                                                    //         'assets/mapcenter.png'),
                                                                    // inactiveThumbImage:
                                                                    //     const AssetImage(
                                                                    //         'assets/mapcenter.png'),
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  // visible: !noParkMarker,
                                  visible: true,
                                  child: Positioned(
                                      // bottom: 20,
                                      // top: 5,
                                      right: 0,
                                      // left: 0,
                                      child: SizedBox(
                                        height: 70,
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Switch(
                                            value: showPark,
                                            activeColor: blueGradientSecondary1,
                                            activeThumbImage: const AssetImage(
                                                'assets/parking.png'),
                                            inactiveThumbImage:
                                                const AssetImage(
                                                    'assets/parking.png'),
                                            onChanged: !noParkMarker
                                                ? (value) {
                                                    print('parking');
                                                    setState(() {
                                                      showPark == true
                                                          ? showPark = false
                                                          : showPark = true;
                                                      snapshot.data[0] == false
                                                          ? {}
                                                          : _setPark();
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ),
                                      )),
                                ),
                                Visibility(
                                    // visible: !noStopMarker,
                                    visible: true,
                                    child: Positioned(
                                        // bottom: 20,
                                        top: 45,
                                        right: 0,
                                        // left: 0,
                                        child: SizedBox(
                                          height: 70,
                                          // width: 85,
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: Switch(
                                              value: showStop,
                                              activeColor: widget.darkMode
                                                  ? blackSecondary1
                                                  : blackPrimary,
                                              activeThumbImage:
                                                  const AssetImage(
                                                      'assets/stop.png'),
                                              inactiveThumbImage:
                                                  const AssetImage(
                                                      'assets/stop.png'),
                                              onChanged: !noStopMarker
                                                  ? (value) {
                                                      print('stop');
                                                      setState(() {
                                                        showStop == true
                                                            ? showStop = false
                                                            : showStop = true;
                                                        snapshot.data[1] ==
                                                                false
                                                            ? {}
                                                            : _setStop();
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          ),
                                        ))),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                  height: 200,
                                  color: whiteCardColor,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          // Row(
                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                          //   children: [
                                          //     Icon(
                                          //       slideUp
                                          //           ? Icons.keyboard_arrow_down_rounded
                                          //           : Icons.keyboard_arrow_up_rounded,
                                          //       color: blueGradient,
                                          //     )
                                          //   ],
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20, top: 10),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                color: blueGradient,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _isPlay
                                                              ? _stopPlay()
                                                              : _playPlaybackReplayData(
                                                                  false);
                                                        });
                                                        // _playPlaybackReplayData();
                                                      },
                                                      child: Icon(
                                                        _isPlay
                                                            ? Icons
                                                                .stop_circle_outlined
                                                            : Icons
                                                                .play_circle_outline_outlined,
                                                        // Icons.play_circle_fill_outlined,
                                                        color: Colors.white,
                                                        size: 30.0,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        _isPlay
                                                            ? setState(() {
                                                                _isPause = true;
                                                                _isPlay =
                                                                    !_isPlay;
                                                                _timer.cancel();
                                                                _pausePlayback();
                                                                // pc.open();
                                                              })
                                                            : {};
                                                      },
                                                      child: const Icon(
                                                        Icons
                                                            .pause_circle_outline_outlined,
                                                        color: Colors.white,
                                                        size: 30.0,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Slider(
                                                        thumbColor: widget
                                                                .darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteCardColor,
                                                        activeColor:
                                                            blueGradientSecondary1,
                                                        inactiveColor: widget
                                                                .darkMode
                                                            ? whiteColorDarkMode
                                                            : whiteColor,
                                                        onChanged:
                                                            (double val) {
                                                          setState(() {
                                                            _speedSlider =
                                                                val.round();
                                                            if (_speedSlider ==
                                                                initTrackReplay
                                                                    .data
                                                                    .result
                                                                    .length) {
                                                              _stopPlay();
                                                            }
                                                          });
                                                        },
                                                        value: double.parse(
                                                            _speedSlider
                                                                .toString()),
                                                        max: double.parse(
                                                            initTrackReplay.data
                                                                .result.length
                                                                .toString()),
                                                        label:
                                                            '${_speedSlider.round()}',
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        // int i = 0;
                                                        // _isPlay
                                                        //     ? setState(() {
                                                        //         _pausePlayback();
                                                        //         _isPause = true;
                                                        //       })
                                                        //     : {};
                                                        setState(() {
                                                          _isPlay;
                                                          if (fastForward ==
                                                              '') {
                                                            fastForward = '2x';
                                                            faster = true;
                                                            speed = 800;
                                                            zoomMaps = 15.0;
                                                            _timer.cancel();
                                                            _playPlaybackReplayData(
                                                                true);
                                                          } else {
                                                            if (fastForward ==
                                                                '2x') {
                                                              fastForward =
                                                                  '4x';
                                                              faster = true;
                                                              speed = 600;
                                                              zoomMaps = 15.0;
                                                              _timer.cancel();
                                                              _playPlaybackReplayData(
                                                                  true);
                                                            } else {
                                                              if (fastForward ==
                                                                  '4x') {
                                                                fastForward =
                                                                    '8x';
                                                                faster = true;
                                                                speed = 200;
                                                                zoomMaps = 13.0;
                                                                _timer.cancel();
                                                                _playPlaybackReplayData(
                                                                    true);
                                                              } else {
                                                                if (fastForward ==
                                                                    '8x') {
                                                                  fastForward =
                                                                      '16x';
                                                                  faster = true;
                                                                  speed = 160;
                                                                  zoomMaps =
                                                                      13.0;
                                                                  _timer
                                                                      .cancel();
                                                                  _playPlaybackReplayData(
                                                                      true);
                                                                } else {
                                                                  if (fastForward ==
                                                                      '16x') {
                                                                    fastForward =
                                                                        '';
                                                                    faster =
                                                                        false;
                                                                    speed =
                                                                        1000;
                                                                    zoomMaps =
                                                                        16.0;
                                                                    _timer
                                                                        .cancel();
                                                                    _playPlaybackReplayData(
                                                                        false);
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        });
                                                        // fasterTrackreplay();
                                                      },
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .fast_forward_outlined,
                                                            color: Colors.white,
                                                            size: 30.0,
                                                          ),
                                                          Text(
                                                            fastForward,
                                                            style:
                                                                bold.copyWith(
                                                              fontSize: 12,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : whiteColor,
                                                            ),
                                                          )
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      // Image.asset('assets/bar.png'),
                                      Column(
                                        children: [
                                          // const SizedBox(
                                          //   height: 24,
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 11),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          4),
                                                              child: Icon(
                                                                Icons.speed,
                                                                size: 24,
                                                                color:
                                                                    bluePrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              '$_speed km/h',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 9,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          4),
                                                              child: Icon(
                                                                Icons.schedule,
                                                                size: 24,
                                                                color:
                                                                    bluePrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              _time,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 9,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4),
                                                                child:
                                                                    Image.asset(
                                                                  'assets/icon/vehicledetail/odometer.png',
                                                                  width: 23,
                                                                )

                                                                // Icon(
                                                                //   Icons
                                                                //       .speed_outlined,
                                                                //   size: 24,
                                                                //   color:
                                                                //       bluePrimary,
                                                                // ),
                                                                ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              '${NumberFormat.currency(
                                                                locale: 'id',
                                                                decimalDigits:
                                                                    0,
                                                                symbol: '',
                                                              ).format(
                                                                double.parse(
                                                                      _millage
                                                                          .toString(),
                                                                    ) /
                                                                    1000,
                                                              )} km',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: reguler
                                                                  .copyWith(
                                                                fontSize: 9,
                                                                color:
                                                                    blackPrimary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                    // left: BorderSide(
                                                    //     width: 1,
                                                    //     color: greyColor),
                                                    // right: BorderSide(
                                                    //     width: 1,
                                                    //     color: greyColor),
                                                    top: BorderSide(
                                                        width: 1,
                                                        color: greyColor),
                                                    // bottom: BorderSide(
                                                    //     width: 1,
                                                    //     color:
                                                    //         greyColor)
                                                  )),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 11),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .from,
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                widget
                                                                    .timeStart,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .to,
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                widget.timeEnd,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .distance,
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary3,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                '${NumberFormat.currency(
                                                                  locale: 'id',
                                                                  decimalDigits:
                                                                      0,
                                                                  symbol: '',
                                                                ).format(
                                                                  double.parse(
                                                                        _totalDistance
                                                                            .toString(),
                                                                      ) /
                                                                      1000,
                                                                )} km',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                                // minFontSize: 10,
                                                                // maxLines: 1,
                                                                // overflow: TextOverflow
                                                                //     .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 14,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Center(
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
                                  color: blackSecondary2,
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
                                  color: blackSecondary2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                }
                return Stack(
                  children: [
                    GoogleMap(
                        // trafficEnabled: true,
                        // minMaxZoomPreference:
                        //     const MinMaxZoomPreference(50, 60),
                        trafficEnabled: _myTrafficEnabled,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        // compassEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: const CameraPosition(
                            target: LatLng(-6.187233, 106.8060391)),
                        markers: Set<Marker>.of(_markers.values),
                        // polylines: _polyline,
                        onMapCreated: (GoogleMapController controllerParam) {
                          _controller = controllerParam;
                          _controller.setMapStyle(mapStyle);
                        }),
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
                        )
                      ],
                    ),
                  ],
                );
              }),
        ));
  }
}
