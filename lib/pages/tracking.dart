// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, avoid_function_literals_in_foreach_calls, unnecessary_this, use_build_context_synchronously, duplicate_ignore, depend_on_referenced_packages, prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/poi.model.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/pages/StreetView.dart';
import 'package:gpsid/pages/geometry.model.dart';
import 'package:gpsid/pages/vehicledetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'dart:math' show cos, sqrt, asin;

class Tracking extends StatefulWidget {
  final bool darkMode;
  const Tracking({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  final PanelController _panelController = PanelController();
  TextEditingController textController = TextEditingController();
  bool isDisabled = false;
  String plate = '';
  double lat = 0.0;
  double long = 0.0;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  // late BitmapDescriptor markerbitmap;
  double zoomMaps = 10;
  int current = 0;
  bool vehicleStatus = false;
  GoogleMapController? gMapController;
  late Future<dynamic> _getVehicleList;
  late POIModel poi;
  late List<ResultVehicleList> initVehicle;
  late List<ResultVehicleList> vehicleList;
  late List<ResultVehicleList> movingVehicleList;
  late List<ResultVehicleList> parkingVehicleList;
  late List<ResultVehicleList> stopVehicleList;
  // double _lat = 0.0;
  // double _long = 0.0;
  // int index = 0;
  int speed = 0;
  String status = 'N/A';
  String battery = 'N/A';
  String temp = 'N/A';
  bool _isLoading = false;
  String _refreshLabel = '30';
  int _refreshTime = 30;
  int _refreshTimeII = 05;
  late Timer _timer;
  late Timer _timerII;
  bool _myTrafficEnabled = true;
  bool _myMapSatelliteEnabled = false;
  MapType _mapType = MapType.normal;
  int angle = 0;
  bool all = false;
  bool moving = false;
  bool park = false;
  bool stop = false;
  List<String> page = [];
  double getLat = 0.0;
  double getLong = 0.0;
  bool showPOI = false;
  bool _isShowPOI = false;
  File? displayImage;
  final disp = [];
  String mapStyle = '';
  String mapStyleStandard = '';
  Location currentLocation = Location();
  String valueTab = '';
  bool switchLabel = false;
  late LocalData localData;
  int setTimer = 0;
  String setTimerString = '0';
  List<dynamic> countdownTimer = [5, 10, 15, 30, 60];
  String vehicleName = '';
  int icon = 0;
  String imei = '';
  String expDate = '';
  String gpsType = '';
  GeometryModel geometryModel = GeometryModel(polygon: []);
  Set<Polygon> polygon = {};

  @override
  void initState() {
    super.initState();
    setMap();
    _getVehicleList = getVehicleList();
    // rootBundle.loadString('assets/maps.json').then(
    //   (value) {
    //     setState(() {
    //       mapStyle = value;
    //     });
    //   },
    // );
    // rootBundle.loadString('assets/mapsstandard.json').then(
    //   (val) {
    //     setState(() {
    //       mapStyleStandard = val;
    //     });
    //   },
    // );
  }

  setMap() async {
    late bool darkMode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool? darkmode = prefs.getBool('darkmode');
    darkMode = darkmode!;
    print(darkmode);
    if (darkMode) {}

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
  }

  // getPOI() async {
  //   int i = 0;
  //   final MarkerId markerId = MarkerId(i.toString());
  //   final result = await APIService().getPOI();
  //   if (result is POIModel) {
  //     _controller.showMarkerInfoWindow( MarkerId(_markers[markerId].)
  //         );
  //   }
  // }

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
    // ignore: use_build_context_synchronously
    await Dialogs().hideLoaderDialog(context);
    changeIndex != 1 ? Navigator.pop(context) : {};
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
        setState(() {
          _isLoading = true;
        });
        await onEnd();
      }
    });
  }

  void _startTimerII() {
    _timerII = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _refreshTimeII--;
      });
      if (_refreshTimeII < 0) {
        // await onEnd();
        _timerII.cancel();
        setState(() {});
        await onEndII();
        // _timerII.cancel();
        // setState(() {
        //   _refreshLabelII = '5';
        //   _refreshTimeII = 5;
        //   _isLoadingII = false;
        // });
      }
    });
  }

  onEndII() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        _refreshTimeII = 05;
      },
    );
    // setState(() {
    //   _refreshLabelII = '5';
    //   _refreshTimeII = 5;
    //   _isLoadingII = false;
    // });
    _startTimerII();
  }

  Future<dynamic> onEnd() async {
    _isLoading = true;
    final result = await APIService().getVehicleList(0, 0);
    if (result is ErrorTrapModel) {
      setState(() {});
    } else {
      initVehicle = result.data.result;
      _setVehicle(current == 1
          ? 'moving'
          : current == 2
              ? 'park'
              : current == 3
                  ? 'stop'
                  : current == 4
                      ? 'lost'
                      : 'all');
      setState(() {
        _refreshLabel = setTimerString == '0' ? '30' : setTimerString;
        _refreshTime = setTimer == 0 ? 30 : setTimer;
      });
      _startTimer();
    }
  }

  Future<dynamic> getVehicleList() async {
    localData = await GeneralService().readLocalUserStorage();
    final result = await APIService().getVehicleList(0, 0);
    if (result is ErrorTrapModel) {
      setState(() {
        // initPlatformState();
      });
    } else {
      List<ResultVehicleList> listVehicle = [];
      if (result is VehicleListModel) {
        if (result.data.result.length == 1) {
          listVehicle.addAll(result.data.result);
        } else {
          result.data.result.forEach((el) {
            if (el.lat != '0.0' && el.lon != '0.0') {
              listVehicle.add(el);
            }
          });
        }
      }
      // listVehicle = result.data.result;
      print(listVehicle);
      setState(() {
        List<LatLng> listLatLng = [];
        listVehicle.forEach((el) {
          listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
        });

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
            gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                boundsFromLatLngList(listLatLng), 50));
          },
        );

        gMapController?.setMapStyle(mapStyleStandard);
        Future.delayed(
          const Duration(seconds: 2),
          () {
            _setVehicle('all');
          },
        );
        moving = true;
        page = [
          AppLocalizations.of(context)!.all,
          AppLocalizations.of(context)!.moving,
          AppLocalizations.of(context)!.park,
          AppLocalizations.of(context)!.stop,
          AppLocalizations.of(context)!.lost,
        ];
        _startTimer();
        _startTimerII();
      });
    }
    return result;
  }

  var size, height, width;

  void togglePanel() => _panelController.isPanelOpen
      ? _panelController.close()
      : _panelController.open();

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
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigitSeconds;
  }

  void _setVehicle(String sort) async {
    int i = 0;
    // String _stopDur = '';
    if (initVehicle.isNotEmpty) {
      if (sort == 'stop') {
        List<LatLng> listLatLng = [];
        valueTab = sort;
        File? displayImage;
        final disp = [];
        initVehicle.forEach((el) async {
          if (el.status == 'Stop') {
            listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
            late BitmapDescriptor markerbitmap;
            String folder = 'localAsset';
            String fileName = '${el.icon}_parking.png';
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
            markerbitmap = getImg;
            getBytesFromAsset('assets/stop_marker_2.png', 96).then((onValue) {
              // _stopDur = _printDuration(Duration(seconds: el.duration));
              final MarkerId markerId = MarkerId(i.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker marker = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: markerbitmap,
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = marker;
                  i++;
                });
              }
            });
          }
        });
        if (listLatLng.isNotEmpty) {
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
              gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
        }
      }
      if (sort == 'moving') {
        List<LatLng> listLatLng = [];
        valueTab = sort;
        File? displayImage;
        final disp = [];
        initVehicle.forEach((el) async {
          if (el.status == 'Online') {
            listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
            late BitmapDescriptor markerbitmap;
            String folder = 'localAsset';
            String fileName = '${el.icon}_accOn.png';
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
            markerbitmap = getImg;
            getBytesFromAsset('assets/stop_marker_2.png', 96).then((onValue) {
              // _stopDur = _printDuration(Duration(seconds: el.duration));
              final MarkerId markerId = MarkerId(i.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker marker = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: markerbitmap,
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = marker;
                  i++;
                });
              }
            });
          }
        });
        if (listLatLng.isNotEmpty) {
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
              gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
        }
      }
      if (sort == 'lost') {
        List<LatLng> listLatLng = [];
        valueTab = sort;
        File? displayImage;
        final disp = [];
        initVehicle.forEach((el) async {
          if (el.status.toLowerCase() == 'lost') {
            listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
            late BitmapDescriptor markerbitmap;
            String folder = 'localAsset';
            // String fileName = el.icon == 12
            //     ? '4_${el.status.toLowerCase()}.png'
            //     : '${el.icon}_${el.status.toLowerCase()}.png';
            String fileName = '${el.icon}_${el.status.toLowerCase()}.png';
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
            markerbitmap = getImg;
            getBytesFromAsset('assets/stop_marker_2.png', 96).then((onValue) {
              // _stopDur = _printDuration(Duration(seconds: el.duration));
              final MarkerId markerId = MarkerId(i.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker marker = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status = el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: markerbitmap,
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = marker;
                  i++;
                });
              }
            });
          }
        });
        if (listLatLng.isNotEmpty) {
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
              gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
        }
      }
      if (sort == 'park') {
        List<LatLng> listLatLng = [];
        valueTab = sort;
        File? displayImage;
        final disp = [];
        initVehicle.forEach((el) async {
          if (el.status == 'Parking') {
            listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
            late BitmapDescriptor markerbitmap;
            String folder = 'localAsset';
            String fileName = '${el.icon}_${el.status.toLowerCase()}.png';
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
            markerbitmap = getImg;
            getBytesFromAsset('assets/stop_marker_2.png', 96).then((onValue) {
              // _stopDur = _printDuration(Duration(seconds: el.duration));
              final MarkerId markerId = MarkerId(i.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker marker = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: markerbitmap,
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = marker;
                  i++;
                });
              }
            });
          }
        });
        if (listLatLng.isNotEmpty) {
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
              gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
        }
      }
      if (sort == 'all') {
        List<LatLng> listLatLng = [];
        valueTab = sort;
        File? displayImage;
        final disp = [];
        initVehicle.forEach((el) async {
          listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
          late BitmapDescriptor markerbitmap;
          String folder = 'localAsset';
          String fileName = el.status.toLowerCase() == 'online'
              ? '${el.icon}_accOn.png'
              : el.status.toLowerCase() == 'online'
                  ? '${el.icon}_accOn.png'
                  : el.status.toLowerCase() == 'stop'
                      ? '${el.icon}_parking.png'
                      : '${el.icon}_${el.status.toLowerCase()}.png';
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
          getBytesFromAsset(
                  el.status == 'Stop'
                      ? 'assets/stop_marker_2.png'
                      : 'assets/moving_marker_2.png',
                  96)
              .then((onValue) {
            // _stopDur = _printDuration(Duration(seconds: el.duration));
            final MarkerId markerId = MarkerId(i.toString());

            double pLat = double.parse(el.lat);
            double pLong = double.parse(el.lon);

            final Marker marker = Marker(
              markerId: markerId,
              position: LatLng(pLat, pLong),
              rotation: double.parse(el.angle.toString()),
              consumeTapEvents: true,
              onTap: () {
                setState(() {
                  icon = el.icon;
                  imei = el.imei;
                  expDate = el.expiredDate;
                  vehicleName = el.deviceName;
                  gpsType = el.gpsName;
                  getLat = pLat;
                  getLong = pLong;
                  vehicleStatus = true;
                  speed = el.speed;
                  lat = double.parse(el.lat);
                  long = double.parse(el.lon);
                  angle = el.angle;
                  temp = el.temperature;
                  battery = el.battery;
                  status =
                      el.status == 'Online' ? status = 'Moving' : el.status;
                });
                gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
              },
              icon: markerbitmap,
            );
            if (this.mounted) {
              setState(() {
                _markers[markerId] = marker;
                i++;
              });
            }
          });
        });
        if (listLatLng.isNotEmpty) {
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
              gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
        }
      }
      if (switchLabel) {
        List<LatLng> listLatLng = [];
        initVehicle.forEach((el) async {
          if (valueTab == 'all') {
            listLatLng.add(LatLng(double.parse(el.lat), double.parse(el.lon)));
            final MarkerId markerId = MarkerId(el.imei.toString());

            double pLat = double.parse(el.lat);
            double pLong = double.parse(el.lon);

            final Marker markerII = Marker(
              markerId: markerId,
              position: LatLng(pLat, pLong),
              // rotation: double.parse(el.angle.toString()),
              consumeTapEvents: true,
              onTap: () {
                setState(() {
                  icon = el.icon;
                  imei = el.imei;
                  expDate = el.expiredDate;
                  vehicleName = el.deviceName;
                  gpsType = el.gpsName;
                  getLat = pLat;
                  getLong = pLong;
                  vehicleStatus = true;
                  speed = el.speed;
                  lat = double.parse(el.lat);
                  long = double.parse(el.lon);
                  angle = el.angle;
                  temp = el.temperature;
                  battery = el.battery;
                  status =
                      el.status == 'Online' ? status = 'Moving' : el.status;
                });
                gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
              },
              icon: await TextOnImage(
                text: el.deviceName,
                status: el.status,
                darkMode: widget.darkMode,
              ).toBitmapDescriptor(),
            );
            if (this.mounted) {
              setState(() {
                _markers[markerId] = markerII;
                // i++;
              });
            }
          }
          if (valueTab == 'stop') {
            if (el.status == 'Stop') {
              listLatLng
                  .add(LatLng(double.parse(el.lat), double.parse(el.lon)));
              final MarkerId markerId = MarkerId(el.imei.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker markerII = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                // rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: await TextOnImage(
                  text: el.deviceName,
                  status: el.status,
                  darkMode: widget.darkMode,
                ).toBitmapDescriptor(),
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = markerII;
                  // i++;
                });
              }
            }
          }
          if (valueTab == 'moving') {
            if (el.status == 'Online') {
              listLatLng
                  .add(LatLng(double.parse(el.lat), double.parse(el.lon)));
              final MarkerId markerId = MarkerId(el.imei.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker markerII = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                // rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: await TextOnImage(
                  text: el.deviceName,
                  status: el.status,
                  darkMode: widget.darkMode,
                ).toBitmapDescriptor(),
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = markerII;
                  // i++;
                });
              }
            }
          }
          if (valueTab == 'lost') {
            if (el.status == 'Lost') {
              listLatLng
                  .add(LatLng(double.parse(el.lat), double.parse(el.lon)));
              final MarkerId markerId = MarkerId(el.imei.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker markerII = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                // rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: await TextOnImage(
                  text: el.deviceName,
                  status: el.status,
                  darkMode: widget.darkMode,
                ).toBitmapDescriptor(),
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = markerII;
                  // i++;
                });
              }
            }
          }
          if (valueTab == 'park') {
            if (el.status == 'Parking') {
              listLatLng
                  .add(LatLng(double.parse(el.lat), double.parse(el.lon)));
              final MarkerId markerId = MarkerId(el.imei.toString());

              double pLat = double.parse(el.lat);
              double pLong = double.parse(el.lon);

              final Marker markerII = Marker(
                markerId: markerId,
                position: LatLng(pLat, pLong),
                // rotation: double.parse(el.angle.toString()),
                consumeTapEvents: true,
                onTap: () {
                  setState(() {
                    icon = el.icon;
                    imei = el.imei;
                    expDate = el.expiredDate;
                    vehicleName = el.deviceName;
                    gpsType = el.gpsName;
                    getLat = pLat;
                    getLong = pLong;
                    vehicleStatus = true;
                    speed = el.speed;
                    lat = double.parse(el.lat);
                    long = double.parse(el.lon);
                    angle = el.angle;
                    temp = el.temperature;
                    battery = el.battery;
                    status =
                        el.status == 'Online' ? status = 'Moving' : el.status;
                  });
                  gMapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(pLat, pLong), zoom: 17.0)));
                },
                icon: await TextOnImage(
                  text: el.deviceName,
                  status: el.status,
                  darkMode: widget.darkMode,
                ).toBitmapDescriptor(),
              );
              if (this.mounted) {
                setState(() {
                  _markers[markerId] = markerII;
                  // i++;
                });
              }
            }
          }
        });
        if (listLatLng.isNotEmpty) {
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
              gMapController?.animateCamera(CameraUpdate.newLatLngBounds(
                  boundsFromLatLngList(listLatLng), 50));
            },
          );
        }
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return WillPopScope(
        child: Scaffold(
          body: FutureBuilder(
              future: _getVehicleList,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data is ErrorTrapModel) {
                    return Container(
                      color: widget.darkMode ? whiteCardColor : whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/handling/noConnection.png',
                                height: 240,
                                width: 240,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 10),
                                child: Text(
                                  AppLocalizations.of(context)!.noConnection,
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
                                  AppLocalizations.of(context)!.noConnectionSub,
                                  textAlign: TextAlign.center,
                                  style: reguler.copyWith(
                                    fontSize: 12,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackSecondary2,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Visibility(
                                    visible: true,
                                    child: Padding(
                                      padding: const EdgeInsets.all(45.0),
                                      child: InkWell(
                                        onTap: () async {
                                          _getVehicleList = getVehicleList();
                                        },
                                        child: Container(
                                          height: 27,
                                          width: 120,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(8)),
                                              gradient: LinearGradient(
                                                colors: [
                                                  blueGradientSecondary2,
                                                  blueGradientSecondary1
                                                ],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                              )),
                                          child: Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .tryAgain,
                                                style: bold.copyWith(
                                                  fontSize: 14,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : whiteColor,
                                                )),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    initVehicle = snapshot.data.data.result;
                    vehicleList = initVehicle;
                    movingVehicleList = initVehicle;
                    parkingVehicleList = initVehicle;
                    stopVehicleList = initVehicle;
                    // index = initVehicle.length - 1;
                    if (current == 1) {
                      List<ResultVehicleList> result = [];
                      for (var el in movingVehicleList) {
                        if (el.status == 'Online') {
                          result.add(el);
                        }
                      }
                      vehicleList = result;
                      print(result);
                    }
                    if (current == 2) {
                      List<ResultVehicleList> result = [];
                      for (var el in parkingVehicleList) {
                        if (el.status == 'Parking') {
                          result.add(el);
                        }
                      }
                      vehicleList = result;
                      print(result);
                    }
                    if (current == 3) {
                      List<ResultVehicleList> result = [];
                      for (var el in stopVehicleList) {
                        if (el.status == 'Stop') {
                          result.add(el);
                        }
                      }
                      vehicleList = result;
                      print(result);
                    }

                    getLat = vehicleList.isNotEmpty
                        ? double.parse(vehicleList[0].lat)
                        : 0.0;
                    getLong = vehicleList.isNotEmpty
                        ? double.parse(vehicleList[0].lon)
                        : 0.0;
                    double iphoneHeight = MediaQuery.of(context).size.height;
                    return Stack(
                      // fit: StackFit.expand,
                      children: [
                        //maps
                        GoogleMap(
                          zoomControlsEnabled: false,
                          // padding: EdgeInsets.only(
                          //   top: 285.0,
                          // ),
                          mapType: _mapType,
                          compassEnabled: false,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          polygons: myPolygon(),
                          markers: Set<Marker>.of(_markers.values),
                          trafficEnabled: _myTrafficEnabled,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(getLat, getLong), zoom: 13),
                          onMapCreated: (controller) {
                            // _controller.complete(gMapController);
                            setState(() {
                              gMapController = controller;
                            });
                            _setVehicle('all');
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: Platform.isIOS
                                  ? iphoneHeight >= 800
                                      ? 45
                                      : 25
                                  : 25,
                              left: 10),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 120,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 45,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (mounted) {
                                                if (_timer.isActive) {
                                                  _timer.cancel();
                                                  Navigator.pop(context);
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_back_outlined,
                                                    color: bluePrimary,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/searchvehicle');
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Container(
                                            // width: double.infinity,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: TextField(
                                              // controller: suggestion,
                                              autofocus: false,
                                              enabled: false,
                                              // onChanged: (value) {
                                              //   if (value == '') {
                                              //     setState(() {
                                              //       _isData = true;
                                              //     });
                                              //   } else {
                                              //     setState(() {
                                              //       _isData = false;
                                              //     });
                                              //     _searchPost
                                              //         .where((element) => element.plat!.contains(value))
                                              //         .toList();
                                              //   }
                                              // },
                                              style: bold.copyWith(
                                                color: blackSecondary1,
                                              ),
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide(
                                                      color: greyColor,
                                                      width: 1),
                                                ),
                                                isDense: true,
                                                fillColor: greyColor,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide:
                                                        BorderSide.none),
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .insertPlate,
                                                hintStyle: reguler.copyWith(
                                                  fontSize: 11,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary1,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.search,
                                                  size: 25,
                                                  color: bluePrimary,
                                                ),
                                                // suffixIcon: const Icon(
                                                //   Icons.search,
                                                //   size: 25,
                                                // ),
                                                // contentPadding:
                                                //     const EdgeInsets.only(top: 10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                    width: width,
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      // horizontal: 5,
                                    ),
                                    // decoration: BoxDecoration(
                                    //   color: whiteColor,
                                    // ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: page.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  current = index;
                                                  if (index == 0) {
                                                    _markers.clear();
                                                    if (!_isShowPOI) {
                                                      _setPoi(1);
                                                      _setVehicle('all');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    } else {
                                                      _setVehicle('all');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    }
                                                  }
                                                  if (index == 1) {
                                                    _markers.clear();
                                                    if (!_isShowPOI) {
                                                      _setPoi(1);
                                                      _setVehicle('moving');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    } else {
                                                      _setVehicle('moving');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    }
                                                  }
                                                  if (index == 2) {
                                                    _markers.clear();
                                                    if (!_isShowPOI) {
                                                      _setPoi(1);
                                                      _setVehicle('park');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    } else {
                                                      _setVehicle('park');
                                                      vehicleStatus = false;
                                                    }
                                                  }
                                                  if (index == 3) {
                                                    _markers.clear();
                                                    if (!_isShowPOI) {
                                                      _setPoi(1);
                                                      _setVehicle('stop');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    } else {
                                                      _setVehicle('stop');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    }
                                                  }
                                                  if (index == 4) {
                                                    _markers.clear();
                                                    if (!_isShowPOI) {
                                                      _setPoi(1);
                                                      _setVehicle('lost');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    } else {
                                                      _setVehicle('lost');
                                                      vehicleStatus = false;
                                                      switchLabel = false;
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 5, left: 5),
                                                width: 120,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: current == index
                                                      ? index == 0
                                                          ? blueGradient
                                                          : index == 1
                                                              ? blueGradient
                                                              : index == 2
                                                                  ? blackSecondary3
                                                                  : index == 3
                                                                      ? blackSecondary3
                                                                      : index ==
                                                                              4
                                                                          ? yellowPrimary
                                                                          : whiteColor
                                                      : widget.darkMode
                                                          ? whiteCardColor
                                                          : whiteColor,
                                                  border: Border.all(
                                                    width: 1,
                                                    color: current == index
                                                        ? index == 1
                                                            ? blueGradient
                                                            : index == 2
                                                                ? blackSecondary3
                                                                : index == 3
                                                                    ? blackSecondary3
                                                                    : index == 4
                                                                        ? yellowPrimary
                                                                        : blueGradient
                                                        : blueGradient,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Align(
                                                  child: Text(
                                                    page[index],
                                                    style: reguler.copyWith(
                                                      fontSize: 12,
                                                      color: current == index
                                                          ? index == 1
                                                              ? whiteColor
                                                              : index == 2
                                                                  ? widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : whiteColor
                                                                  : index == 3
                                                                      ? widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : whiteColor
                                                                      : index ==
                                                                              4
                                                                          ? whiteColor
                                                                          : whiteColor
                                                          : widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blueGradient,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ))
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              top: Platform.isIOS
                                  ? iphoneHeight >= 800
                                      ? 135
                                      : 120
                                  : 120,
                              right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (!switchLabel) {
                                        initVehicle.forEach((el) async {
                                          if (valueTab == 'all') {
                                            final MarkerId markerId =
                                                MarkerId(el.imei.toString());

                                            double pLat = double.parse(el.lat);
                                            double pLong = double.parse(el.lon);

                                            final Marker markerII = Marker(
                                              markerId: markerId,
                                              position: LatLng(pLat, pLong),
                                              consumeTapEvents: true,
                                              // rotation: double.parse(el.angle.toString()),
                                              onTap: () {
                                                setState(() {
                                                  icon = el.icon;
                                                  imei = el.imei;
                                                  expDate = el.expiredDate;
                                                  vehicleName = el.deviceName;
                                                  gpsType = el.gpsName;
                                                  getLat = pLat;
                                                  getLong = pLong;
                                                  vehicleStatus = true;
                                                  speed = el.speed;
                                                  lat = double.parse(el.lat);
                                                  long = double.parse(el.lon);
                                                  angle = el.angle;
                                                  temp = el.temperature;
                                                  battery = el.battery;
                                                  status = el.status == 'Online'
                                                      ? status = 'Moving'
                                                      : el.status;
                                                });
                                                gMapController?.animateCamera(
                                                    CameraUpdate
                                                        .newCameraPosition(
                                                            CameraPosition(
                                                                target: LatLng(
                                                                    pLat,
                                                                    pLong),
                                                                zoom: 17.0)));
                                              },
                                              // infoWindow: InfoWindow(
                                              //   title: el.deviceName,
                                              //   onTap: () {
                                              //     // Navigator.push(
                                              //     //   context,
                                              //     //   MaterialPageRoute(
                                              //     //     builder: (context) => VehicleDetail(
                                              //     //         icon: el.icon,
                                              //     //         imei: el.imei,
                                              //     //         expDate: el.expiredDate,
                                              //     //         deviceName: el.deviceName,
                                              //     //         gpsType: el.gpsName,
                                              //     //         vehStatus: el.status),
                                              //     //   ),
                                              //     // );
                                              //     // if (el.status.toLowerCase() == 'lost') {
                                              //     //   lostAlert(
                                              //     //       context,
                                              //     //       AppLocalizations.of(context)!.lostTitle,
                                              //     //       AppLocalizations.of(context)!.lostSubTitle,
                                              //     //       el.imei,
                                              //     //       el.plate);
                                              //     // }
                                              //   },
                                              // ),
                                              icon: await TextOnImage(
                                                text: el.deviceName,
                                                status: el.status,
                                                darkMode: widget.darkMode,
                                              ).toBitmapDescriptor(),
                                            );
                                            if (this.mounted) {
                                              setState(() {
                                                _markers[markerId] = markerII;
                                                // i++;
                                              });
                                            }
                                          }
                                          if (valueTab == 'stop') {
                                            if (el.status == 'Stop') {
                                              final MarkerId markerId =
                                                  MarkerId(el.imei.toString());

                                              double pLat =
                                                  double.parse(el.lat);
                                              double pLong =
                                                  double.parse(el.lon);

                                              final Marker markerII = Marker(
                                                markerId: markerId,
                                                position: LatLng(pLat, pLong),
                                                consumeTapEvents: true,
                                                // rotation: double.parse(el.angle.toString()),
                                                onTap: () {
                                                  setState(() {
                                                    icon = el.icon;
                                                    imei = el.imei;
                                                    expDate = el.expiredDate;
                                                    vehicleName = el.deviceName;
                                                    gpsType = el.gpsName;
                                                    getLat = pLat;
                                                    getLong = pLong;
                                                    vehicleStatus = true;
                                                    speed = el.speed;
                                                    lat = double.parse(el.lat);
                                                    long = double.parse(el.lon);
                                                    angle = el.angle;
                                                    temp = el.temperature;
                                                    battery = el.battery;
                                                    status =
                                                        el.status == 'Online'
                                                            ? status = 'Moving'
                                                            : el.status;
                                                  });
                                                  gMapController?.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                                  target: LatLng(
                                                                      pLat,
                                                                      pLong),
                                                                  zoom: 17.0)));
                                                },
                                                // infoWindow: InfoWindow(
                                                //   title: el.deviceName,
                                                //   onTap: () {
                                                //     // Navigator.push(
                                                //     //   context,
                                                //     //   MaterialPageRoute(
                                                //     //     builder: (context) => VehicleDetail(
                                                //     //         icon: el.icon,
                                                //     //         imei: el.imei,
                                                //     //         expDate: el.expiredDate,
                                                //     //         deviceName: el.deviceName,
                                                //     //         gpsType: el.gpsName,
                                                //     //         vehStatus: el.status),
                                                //     //   ),
                                                //     // );
                                                //     // if (el.status.toLowerCase() == 'lost') {
                                                //     //   lostAlert(
                                                //     //       context,
                                                //     //       AppLocalizations.of(context)!.lostTitle,
                                                //     //       AppLocalizations.of(context)!.lostSubTitle,
                                                //     //       el.imei,
                                                //     //       el.plate);
                                                //     // }
                                                //   },
                                                // ),
                                                icon: await TextOnImage(
                                                  text: el.deviceName,
                                                  status: el.status,
                                                  darkMode: widget.darkMode,
                                                ).toBitmapDescriptor(),
                                              );
                                              if (this.mounted) {
                                                setState(() {
                                                  _markers[markerId] = markerII;
                                                  // i++;
                                                });
                                              }
                                            }
                                          }
                                          if (valueTab == 'moving') {
                                            if (el.status == 'Online') {
                                              final MarkerId markerId =
                                                  MarkerId(el.imei.toString());

                                              double pLat =
                                                  double.parse(el.lat);
                                              double pLong =
                                                  double.parse(el.lon);

                                              final Marker markerII = Marker(
                                                markerId: markerId,
                                                position: LatLng(pLat, pLong),
                                                consumeTapEvents: true,
                                                // rotation: double.parse(el.angle.toString()),
                                                onTap: () {
                                                  setState(() {
                                                    icon = el.icon;
                                                    imei = el.imei;
                                                    expDate = el.expiredDate;
                                                    vehicleName = el.deviceName;
                                                    gpsType = el.gpsName;
                                                    getLat = pLat;
                                                    getLong = pLong;
                                                    vehicleStatus = true;
                                                    speed = el.speed;
                                                    lat = double.parse(el.lat);
                                                    long = double.parse(el.lon);
                                                    angle = el.angle;
                                                    temp = el.temperature;
                                                    battery = el.battery;
                                                    status =
                                                        el.status == 'Online'
                                                            ? status = 'Moving'
                                                            : el.status;
                                                  });
                                                  gMapController?.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                                  target: LatLng(
                                                                      pLat,
                                                                      pLong),
                                                                  zoom: 17.0)));
                                                },
                                                // infoWindow: InfoWindow(
                                                //   title: el.deviceName,
                                                //   onTap: () {
                                                //     // Navigator.push(
                                                //     //   context,
                                                //     //   MaterialPageRoute(
                                                //     //     builder: (context) => VehicleDetail(
                                                //     //         icon: el.icon,
                                                //     //         imei: el.imei,
                                                //     //         expDate: el.expiredDate,
                                                //     //         deviceName: el.deviceName,
                                                //     //         gpsType: el.gpsName,
                                                //     //         vehStatus: el.status),
                                                //     //   ),
                                                //     // );
                                                //     // if (el.status.toLowerCase() == 'lost') {
                                                //     //   lostAlert(
                                                //     //       context,
                                                //     //       AppLocalizations.of(context)!.lostTitle,
                                                //     //       AppLocalizations.of(context)!.lostSubTitle,
                                                //     //       el.imei,
                                                //     //       el.plate);
                                                //     // }
                                                //   },
                                                // ),
                                                icon: await TextOnImage(
                                                  text: el.deviceName,
                                                  status: el.status,
                                                  darkMode: widget.darkMode,
                                                ).toBitmapDescriptor(),
                                              );
                                              if (this.mounted) {
                                                setState(() {
                                                  _markers[markerId] = markerII;
                                                  // i++;
                                                });
                                              }
                                            }
                                          }
                                          if (valueTab == 'lost') {
                                            if (el.status == 'Lost') {
                                              final MarkerId markerId =
                                                  MarkerId(el.imei.toString());

                                              double pLat =
                                                  double.parse(el.lat);
                                              double pLong =
                                                  double.parse(el.lon);

                                              final Marker markerII = Marker(
                                                markerId: markerId,
                                                position: LatLng(pLat, pLong),
                                                consumeTapEvents: true,
                                                // rotation: double.parse(el.angle.toString()),
                                                onTap: () {
                                                  setState(() {
                                                    icon = el.icon;
                                                    imei = el.imei;
                                                    expDate = el.expiredDate;
                                                    vehicleName = el.deviceName;
                                                    gpsType = el.gpsName;
                                                    getLat = pLat;
                                                    getLong = pLong;
                                                    vehicleStatus = true;
                                                    speed = el.speed;
                                                    lat = double.parse(el.lat);
                                                    long = double.parse(el.lon);
                                                    angle = el.angle;
                                                    temp = el.temperature;
                                                    battery = el.battery;
                                                    status =
                                                        el.status == 'Online'
                                                            ? status = 'Moving'
                                                            : el.status;
                                                  });
                                                  gMapController?.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                                  target: LatLng(
                                                                      pLat,
                                                                      pLong),
                                                                  zoom: 17.0)));
                                                },
                                                // infoWindow: InfoWindow(
                                                //   title: el.deviceName,
                                                //   onTap: () {
                                                //     // Navigator.push(
                                                //     //   context,
                                                //     //   MaterialPageRoute(
                                                //     //     builder: (context) => VehicleDetail(
                                                //     //         icon: el.icon,
                                                //     //         imei: el.imei,
                                                //     //         expDate: el.expiredDate,
                                                //     //         deviceName: el.deviceName,
                                                //     //         gpsType: el.gpsName,
                                                //     //         vehStatus: el.status),
                                                //     //   ),
                                                //     // );
                                                //     // if (el.status.toLowerCase() == 'lost') {
                                                //     //   lostAlert(
                                                //     //       context,
                                                //     //       AppLocalizations.of(context)!.lostTitle,
                                                //     //       AppLocalizations.of(context)!.lostSubTitle,
                                                //     //       el.imei,
                                                //     //       el.plate);
                                                //     // }
                                                //   },
                                                // ),
                                                icon: await TextOnImage(
                                                  text: el.deviceName,
                                                  status: el.status,
                                                  darkMode: widget.darkMode,
                                                ).toBitmapDescriptor(),
                                              );
                                              if (this.mounted) {
                                                setState(() {
                                                  _markers[markerId] = markerII;
                                                  // i++;
                                                });
                                              }
                                            }
                                          }
                                          if (valueTab == 'park') {
                                            if (el.status == 'Parking') {
                                              final MarkerId markerId =
                                                  MarkerId(el.imei.toString());

                                              double pLat =
                                                  double.parse(el.lat);
                                              double pLong =
                                                  double.parse(el.lon);

                                              final Marker markerII = Marker(
                                                markerId: markerId,
                                                position: LatLng(pLat, pLong),
                                                consumeTapEvents: true,
                                                // rotation: double.parse(el.angle.toString()),
                                                onTap: () {
                                                  setState(() {
                                                    icon = el.icon;
                                                    imei = el.imei;
                                                    expDate = el.expiredDate;
                                                    vehicleName = el.deviceName;
                                                    gpsType = el.gpsName;
                                                    getLat = pLat;
                                                    getLong = pLong;
                                                    vehicleStatus = true;
                                                    speed = el.speed;
                                                    lat = double.parse(el.lat);
                                                    long = double.parse(el.lon);
                                                    angle = el.angle;
                                                    temp = el.temperature;
                                                    battery = el.battery;
                                                    status =
                                                        el.status == 'Online'
                                                            ? status = 'Moving'
                                                            : el.status;
                                                  });
                                                  gMapController?.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                                  target: LatLng(
                                                                      pLat,
                                                                      pLong),
                                                                  zoom: 17.0)));
                                                },
                                                // infoWindow: InfoWindow(
                                                //   title: el.deviceName,
                                                //   onTap: () {
                                                //     // Navigator.push(
                                                //     //   context,
                                                //     //   MaterialPageRoute(
                                                //     //     builder: (context) => VehicleDetail(
                                                //     //         icon: el.icon,
                                                //     //         imei: el.imei,
                                                //     //         expDate: el.expiredDate,
                                                //     //         deviceName: el.deviceName,
                                                //     //         gpsType: el.gpsName,
                                                //     //         vehStatus: el.status),
                                                //     //   ),
                                                //     // );
                                                //     // if (el.status.toLowerCase() == 'lost') {
                                                //     //   lostAlert(
                                                //     //       context,
                                                //     //       AppLocalizations.of(context)!.lostTitle,
                                                //     //       AppLocalizations.of(context)!.lostSubTitle,
                                                //     //       el.imei,
                                                //     //       el.plate);
                                                //     // }
                                                //   },
                                                // ),
                                                icon: await TextOnImage(
                                                  text: el.deviceName,
                                                  status: el.status,
                                                  darkMode: widget.darkMode,
                                                ).toBitmapDescriptor(),
                                              );
                                              if (this.mounted) {
                                                setState(() {
                                                  _markers[markerId] = markerII;
                                                  // i++;
                                                });
                                              }
                                            }
                                          }
                                        });
                                        setState(() {
                                          switchLabel = !switchLabel;
                                        });
                                      }
                                    },
                                    child: Visibility(
                                        visible: switchLabel ? false : true,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10, top: 5),
                                          child: Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  purpleGradient,
                                                  blueGradient,
                                                ],
                                              ),
                                              // color: bluePrimary,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: widget.darkMode
                                                      ? whiteCardColor
                                                      : Colors.grey,
                                                  offset: const Offset(0.0, 3),
                                                  blurRadius: 5.0,
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/icon/tracking/hide.png',
                                                    width: 20,
                                                    color: whiteColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .showLabel,
                                                    style: reguler.copyWith(
                                                        fontSize: 10,
                                                        color: whiteColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        switchLabel = !switchLabel;
                                      });
                                      _markers.clear();
                                      _setVehicle(valueTab);
                                      vehicleStatus = false;
                                    },
                                    child: Visibility(
                                      visible: switchLabel ? true : false,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, top: 5),
                                        child: Container(
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [
                                                purpleGradient,
                                                redPrimary,
                                              ],
                                            ),
                                            // color: bluePrimary,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: widget.darkMode
                                                    ? whiteCardColor
                                                    : Colors.grey,
                                                offset: const Offset(0.0, 3),
                                                blurRadius: 5.0,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/icon/tracking/show.png',
                                                  width: 20,
                                                  color: whiteColor,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .hideLabel,
                                                  style: reguler.copyWith(
                                                      fontSize: 10,
                                                      color: whiteColor),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: widget.darkMode
                                                        ? whiteCardColor
                                                        : Colors.grey,
                                                    offset:
                                                        const Offset(0.0, 3),
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
                                                    visible: _isLoading
                                                        ? false
                                                        : true,
                                                    child: SizedBox(
                                                        width: 22,
                                                        child: Text(
                                                          _refreshLabel,
                                                          style: reguler.copyWith(
                                                              fontSize: 16,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : whiteColor),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                            onTap: () async {
                                              // if (_timer.isActive) {
                                              //   _timer.cancel();
                                              //   await onEnd();
                                              // }
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      whiteCardColor,
                                                  isScrollControlled: true,
                                                  isDismissible: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(12),
                                                            topRight:
                                                                Radius.circular(
                                                                    12)),
                                                  ),
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setStateModal) {
                                                      return SingleChildScrollView(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      15),
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                countdownTimer
                                                                    .length,
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      // selected = index;
                                                                      setTimer =
                                                                          countdownTimer[
                                                                              index];
                                                                      setTimerString =
                                                                          countdownTimer[index]
                                                                              .toString();
                                                                    });
                                                                    if (_timer
                                                                        .isActive) {
                                                                      _timer
                                                                          .cancel();
                                                                      await onEnd();
                                                                    }
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Center(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(12.0),
                                                                              child: Text(
                                                                                '${countdownTimer[index]} ${AppLocalizations.of(context)!.second}',
                                                                                textAlign: TextAlign.center,
                                                                                style: reguler.copyWith(fontSize: 14, color: widget.darkMode ? whiteColorDarkMode : blackSecondary2),
                                                                              ),
                                                                            )),
                                                                        Divider(
                                                                          height:
                                                                              1,
                                                                          thickness:
                                                                              1,
                                                                          indent:
                                                                              0,
                                                                          endIndent:
                                                                              0,
                                                                          color:
                                                                              greyColorSecondary,
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
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
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
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
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
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary1,
                                                                    fontSize:
                                                                        16)),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 12),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Expanded(
                                                                flex: 1,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
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
                                                                            BorderRadius.circular(4)),
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
                                                                          'Default',
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
                                                                child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _myMapSatelliteEnabled =
                                                                      true;
                                                                  _mapType = MapType
                                                                      .satellite;
                                                                });
                                                              },
                                                              child: Container(
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
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      'Sattelite',
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
                                                                .only(top: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .mapDetail,
                                                                style: reguler
                                                                    .copyWith(
                                                                        color:
                                                                            blackSecondary1,
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
                                                                      Latitude:
                                                                          lat,
                                                                      Longitude:
                                                                          long,
                                                                      Angle:
                                                                          angle)));
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 12),
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
                                                                    color: vehicleStatus
                                                                        ? blueGradient
                                                                        : greyColor,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            15),
                                                                    child: Text(
                                                                        AppLocalizations.of(context)!
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
                                                                color: vehicleStatus
                                                                    ? blueGradient
                                                                    : greyColor,
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
                                                                bottom: 3),
                                                        child: Divider(
                                                          height: .5,
                                                          thickness: .5,
                                                          endIndent: 0,
                                                          indent: 0,
                                                          color: greyColor,
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
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
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
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
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
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
                                                                    'POI',
                                                                    style: reguler.copyWith(
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : blackSecondary3,
                                                                        fontSize:
                                                                            12)),
                                                              ),
                                                            ],
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
                                                              print('stop');
                                                              if (showPOI ==
                                                                  true) {
                                                                setState(() {
                                                                  showPOI =
                                                                      false;
                                                                  _setPoi(0);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  showPOI =
                                                                      true;
                                                                  _setPoi(0);
                                                                });
                                                              }
                                                            },
                                                          )
                                                        ],
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
                                    onTap: () async {
                                      Dialogs().loadingDialog(context);
                                      LinkModel url =
                                          await GeneralService().readLocalUrl();
                                      Dialogs().hideLoaderDialog(context);
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: true,
                                        backgroundColor: whiteColor,
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
                                                                    fontSize:
                                                                        16,
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
                                                                child:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  size: 30,
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
                                                              color:
                                                                  blackSecondary3),
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
                                                        url.data.branch
                                                                    .whatsapp ==
                                                                ''
                                                            ? {}
                                                            : launchUrl(
                                                                Uri.parse(
                                                                    'https://wa.me/${url.data.branch.whatsapp}'),
                                                                mode: LaunchMode
                                                                    .externalApplication);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10,
                                                                bottom: 5),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: whiteColor,
                                                            // color: all ? blueGradient : whiteColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
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
                                                                        .all(
                                                                        12),
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
                                                                              fontSize: 12,
                                                                              color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
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
                                                                'https://wa.me/${url.data.head.whatsapp}'),
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: greenPrimary,
                                                            // color: all ? blueGradient : whiteColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  greenPrimary,
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
                                                                        .all(
                                                                        12),
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
                                                                              fontSize: 12,
                                                                              color: whiteColor)),
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
                                  Visibility(
                                      visible: Platform.isIOS ? true : true,
                                      child: Padding(
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
                                                      offset:
                                                          const Offset(0.0, 3),
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
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleDetail(
                                  icon: icon,
                                  imei: imei,
                                  expDate: expDate,
                                  deviceName: vehicleName,
                                  gpsType: gpsType,
                                  vehStatus: status,
                                  darkMode: widget.darkMode,
                                ),
                              ),
                            );
                            if (status.toLowerCase() == 'lost') {
                              lostAlert(
                                  context,
                                  localData.Username,
                                  AppLocalizations.of(context)!.lostTitle,
                                  AppLocalizations.of(context)!.lostSubTitle,
                                  imei,
                                  plate);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 35),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Visibility(
                                    visible: vehicleStatus,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      width: width * 0.9,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: status.toLowerCase() == 'parking'
                                            ? blackSecondary3
                                            : status.toLowerCase() == 'stop'
                                                ? blackSecondary3
                                                : status.toLowerCase() == 'lost'
                                                    ? yellowPrimary
                                                    : status.toLowerCase() ==
                                                            'alarm'
                                                        ? redPrimary
                                                        : bluePrimary,
                                        // gradient: LinearGradient(
                                        //   begin: Alignment.topRight,
                                        //   end: Alignment.bottomLeft,
                                        //   colors: [
                                        //     blueGradientSecondary1,
                                        //     blueGradientSecondary2,
                                        //   ],
                                        // ),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            vehicleName,
                                            style: bold.copyWith(
                                              fontSize: 12,
                                              color: status.toLowerCase() ==
                                                      'parking'
                                                  ? widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : whiteColor
                                                  : status.toLowerCase() ==
                                                          'stop'
                                                      ? widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : whiteColor
                                                      : whiteColor,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Visibility(
                                    visible: vehicleStatus,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      width: width * 0.9,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        // gradient: LinearGradient(
                                        //   begin: Alignment.topRight,
                                        //   end: Alignment.bottomLeft,
                                        //   colors: [
                                        //     blueGradientSecondary1,
                                        //     blueGradientSecondary2,
                                        //   ],
                                        // ),
                                        color: bluePrimary,
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(4),
                                            bottomRight: Radius.circular(4)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              // _selectMarker(markerId);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.speed,
                                                  size: 20,
                                                  color: whiteColor,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '$speed km/h',
                                                  style: bold.copyWith(
                                                    fontSize: 12,
                                                    color: whiteColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/batteryicon.png',
                                                width: 20,
                                                color: whiteColor,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                '${battery == '-1' ? '100' : battery}%',
                                                style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: whiteColor,
                                                ),
                                              ),
                                              Visibility(
                                                  visible: battery == '-1'
                                                      ? true
                                                      : false,
                                                  child: Icon(
                                                    Icons.flash_on_rounded,
                                                    size: 15,
                                                    color: whiteColor,
                                                  ))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.thermostat,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                '$temp*',
                                                style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: whiteColor,
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                status.toLowerCase() == 'online'
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .moving
                                                    : status.toLowerCase() ==
                                                            'stop'
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .stop
                                                        : status.toLowerCase() ==
                                                                'parking'
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .park
                                                            : status.toLowerCase() ==
                                                                    'no data'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .lost
                                                                : status,
                                                style: bold.copyWith(
                                                  fontSize: 12,
                                                  color: whiteColor,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }
                }
                return Stack(
                  children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      mapType: _mapType,
                      myLocationButtonEnabled: false,
                      // polygons: myPolygon(),
                      markers: Set<Marker>.of(_markers.values),
                      trafficEnabled: _myTrafficEnabled,
                      initialCameraPosition: const CameraPosition(
                          target: LatLng(-6.187233, 106.8060391)),
                      onMapCreated: (controller) {
                        // _controller.complete(gMapController);
                        gMapController = controller;
                        gMapController?.setMapStyle(mapStyle);
                        // _setVehicle('all');
                      },
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

  @override
  void dispose() {
    _timer.isActive ? _timer.cancel() : {};
    _timerII.isActive ? _timerII.cancel() : {};
    super.dispose();
  }
}

class TextOnImage extends StatelessWidget {
  const TextOnImage(
      {super.key,
      required this.text,
      required this.status,
      required this.darkMode});
  final String text;
  final String status;
  final bool darkMode;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: status == 'Online'
              ? bluePrimary
              : status == 'Parking'
                  ? darkMode
                      ? blackSecondary3
                      : blackPrimary
                  : status == 'Stop'
                      ? darkMode
                          ? blackSecondary3
                          : blackPrimary
                      : status == 'Lost'
                          ? yellowPrimary
                          : status == 'Alarm'
                              ? redPrimary
                              : blueGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          text,
          style: reguler.copyWith(
              color: status == 'Lost'
                  ? blackPrimary
                  : darkMode
                      ? whiteColorDarkMode
                      : whiteColor,
              fontSize: 12),
        ),
      ),
    );
  }
}

class PolygonInfo extends StatelessWidget {
  const PolygonInfo(
      {super.key,
      required this.text,
      required this.darkMode,
      required this.showPoi});
  final String text;
  final bool darkMode;
  final bool showPoi;
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showPoi,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.local_activity_rounded,
            color: blueGradient,
            size: 25,
          ),
          Container(
            color: blueSecondary,
            child: Text(
              'POI: $text',
              style: bold.copyWith(color: whiteColorDarkMode, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
