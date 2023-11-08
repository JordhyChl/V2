// ignore_for_file: depend_on_referenced_packages, unused_field, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/poi.model.dart';
import 'package:gpsid/pages/StreetView.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class FullMapPage extends StatefulWidget {
  final double pLat;
  final double pLng;
  final String plate;
  final bool darkMode;

  const FullMapPage({
    Key? key,
    required this.pLat,
    required this.pLng,
    required this.plate,
    required this.darkMode,
  }) : super(key: key);

  @override
  _FullMapPageState createState() => _FullMapPageState();
}

class _FullMapPageState extends State<FullMapPage> {
  late GoogleMapController _controller;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  bool showPOI = false;
  bool _myTrafficEnabled = true;
  bool _myMapSatelliteEnabled = false;
  MapType _mapType = MapType.normal;
  bool _isError = false;
  String _errCode = '';
  final disp = [];
  File? displayImage;

  @override
  void initState() {
    super.initState();
    _markers[MarkerId(widget.plate)] = Marker(
      markerId: MarkerId(widget.plate),
      position: LatLng(widget.pLat, widget.pLng),
      infoWindow: InfoWindow(title: widget.plate),
    );
  }

  _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _controller.showMarkerInfoWindow(MarkerId(widget.plate));
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
            rotation: 0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            trafficEnabled: _myTrafficEnabled,
            mapType: _mapType,
            buildingsEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.pLat, widget.pLng),
              zoom: 13,
            ),
            markers: Set<Marker>.of(_markers.values),
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            // left: ,
            right: 10,
            top: 70,
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
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8))),
                            context: context,
                            backgroundColor: whiteCardColor,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  AppLocalizations.of(context)!
                                                      .mapStyle,
                                                  style: reguler.copyWith(
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary1,
                                                      fontSize: 16)),
                                              InkWell(
                                                onTap: () {
                                                  launchUrl(
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                      Uri.parse(
                                                          'https://www.google.com/maps/search/?api=1&query=${widget.pLat},${widget.pLng}'));
                                                },
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .showonGMaps,
                                                  style: reguler.copyWith(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontSize: 10,
                                                      color: bluePrimary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      _setSatellite(false);
                                                      setState(() {
                                                        _myMapSatelliteEnabled =
                                                            false;
                                                        // _mapType =
                                                        //     MapType.normal;
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 36,
                                                      // width: 159,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              _myMapSatelliteEnabled
                                                                  ? null
                                                                  : whiteColor,
                                                          border: Border.all(
                                                              width: 1,
                                                              color: !_myMapSatelliteEnabled
                                                                  ? bluePrimary
                                                                  : greyColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            color:
                                                                !_myMapSatelliteEnabled
                                                                    ? bluePrimary
                                                                    : greyColor,
                                                            size: 20,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
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
                                                      _setSatellite(true);
                                                      setState(() {
                                                        _myMapSatelliteEnabled =
                                                            true;
                                                        // _mapType =
                                                        //     MapType.satellite;
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 36,
                                                      // width: 159,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              !_myMapSatelliteEnabled
                                                                  ? null
                                                                  : whiteColor,
                                                          border: Border.all(
                                                              width: 1,
                                                              color: !_myMapSatelliteEnabled
                                                                  ? greyColor
                                                                  : bluePrimary),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.map_outlined,
                                                            color:
                                                                !_myMapSatelliteEnabled
                                                                    ? greyColor
                                                                    : bluePrimary,
                                                            size: 20,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
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
                                              const EdgeInsets.only(top: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  AppLocalizations.of(context)!
                                                      .mapDetail,
                                                  style: reguler.copyWith(
                                                      color: blackSecondary1,
                                                      fontSize: 16)),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StreetView(
                                                            Latitude:
                                                                widget.pLat,
                                                            Longitude:
                                                                widget.pLng,
                                                            Angle: 0)));
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
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
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .streetView,
                                                          style: reguler.copyWith(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                              fontSize: 12)),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 20,
                                                  color: blueGradient,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, bottom: 3),
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
                                                MainAxisAlignment.spaceBetween,
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
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .trafficView,
                                                          style: reguler.copyWith(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                              fontSize: 12)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: _myTrafficEnabled,
                                                // activeColor: blackPrimary,
                                                // activeThumbImage:
                                                //     const AssetImage(
                                                //         'assets/mapcenter.png'),
                                                // inactiveThumbImage:
                                                //     const AssetImage(
                                                //         'assets/mapcenter.png'),
                                                onChanged: (value) {
                                                  setState(() {
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
                                          padding: const EdgeInsets.only(
                                              top: 3, bottom: 3),
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
                                              _setPoi();
                                            } else {
                                              setState(() {
                                                showPOI = true;
                                              });
                                              _setPoi();
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .poiView,
                                                          style: reguler.copyWith(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                              fontSize: 12)),
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
                                                  if (showPOI == true) {
                                                    setState(() {
                                                      showPOI = false;
                                                    });
                                                    _setPoi();
                                                  } else {
                                                    setState(() {
                                                      showPOI = true;
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
                        )),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     final MarkerId markerId = MarkerId(
                    //         vehicleDetail.data.result.imei);
                    //     // _doCenter(markerId);
                    //     gMapController?.animateCamera(
                    //         CameraUpdate.newCameraPosition(
                    //             CameraPosition(
                    //                 target: LatLng(
                    //                     double.parse(vehicleDetail
                    //                         .data.result.lat),
                    //                     double.parse(vehicleDetail
                    //                         .data.result.lon)),
                    //                 zoom: 15.0)));
                    //   },
                    //   child: Image.asset(
                    //     'assets/mapicon.png',
                    //     width: 40,
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     launchUrl(
                    //         Uri.parse(url.data.results.whatsapp),
                    //         mode: LaunchMode.externalApplication);
                    //   },
                    //   child: Image.asset(
                    //     'assets/WA.png',
                    //     width: 40,
                    //   ),
                    // ),
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
          Positioned(
            top: 64.0,
            left: 10.0,
            child: SizedBox(
              height: 40.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.darkMode ? whiteCardColor : whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: widget.darkMode ? whiteColorDarkMode : bluePrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
