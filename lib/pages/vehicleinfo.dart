// ignore_for_file: unused_field, unused_local_variable, prefer_typing_uninitialized_variables, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/device.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

class VehicleInfo extends StatefulWidget {
  final String status;
  final String odoMeter;
  final String warranty;
  final String activeWarranty;
  final String lastPosition;
  final String lastData;
  final String pulsaPackageEnd;
  final String vehiclePositionAddress;
  final double latitude;
  final double longitude;
  final String gpsType;
  final String imei;
  final String deviceName;
  final String plate;
  final String gsmNumber;
  final String registerDate;
  final bool isDashcam;
  final bool darkMode;
  const VehicleInfo(
      {Key? key,
      required this.status,
      required this.odoMeter,
      required this.warranty,
      required this.activeWarranty,
      required this.lastPosition,
      required this.lastData,
      required this.pulsaPackageEnd,
      required this.vehiclePositionAddress,
      required this.gpsType,
      required this.imei,
      required this.deviceName,
      required this.plate,
      required this.gsmNumber,
      required this.latitude,
      required this.longitude,
      required this.registerDate,
      required this.isDashcam,
      required this.darkMode})
      : super(key: key);

  @override
  State<VehicleInfo> createState() => _VehicleInfoState();
}

class _VehicleInfoState extends State<VehicleInfo> {
  bool _isError = false;
  String _errCode = '';
  String address = 'Show address';
  late Future<dynamic> _getDeviceInfo;
  late DeviceModel deviceInfo;
  late LocalData localData;

  @override
  initState() {
    super.initState();
    _getDeviceInfo = getDeviceInfo(widget.imei);
    // getAddress(widget.latitude.toString(), widget.longitude.toString());
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

  Future<dynamic> getDeviceInfo(String imei) async {
    final result = await APIService().getDeviceInfo(imei);
    localData = await GeneralService().readLocalUserStorage();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '45864DeviceInfo';
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
      });
    }
    return result;
  }

  String _printDurationII(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)} ${AppLocalizations.of(context)!.minutes}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: widget.darkMode
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                            whiteCardColor,
                            whiteCardColor,
                          ])
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                            blueGradientSecondary2,
                            blueGradientSecondary1,
                          ])),
          ),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              size: 38,
            ),
          ),
          title: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.vehicleInfo,
                style: bold.copyWith(
                    fontSize: 14,
                    color: widget.darkMode ? whiteColorDarkMode : whiteColor),
              ),
              Text(
                widget.plate,
                style: bold.copyWith(
                    fontSize: 10,
                    color: widget.darkMode ? whiteColorDarkMode : whiteColor),
              ),
            ],
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: FutureBuilder(
                future: _getDeviceInfo,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data is ErrorTrapModel) {
                      return Center(
                        child: Text(
                          'No data',
                          style: reguler.copyWith(
                              color: blackPrimary, fontSize: 14),
                        ),
                      );
                    } else {
                      deviceInfo = snapshot.data;
                      return ScrollNavigation(
                        bodyStyle: NavigationBodyStyle(
                          background: whiteColor,
                        ),
                        barStyle: NavigationBarStyle(
                            position: NavigationPosition.top,
                            elevation: 0.0,
                            background: whiteColor),
                        showIdentifier: true,
                        identiferStyle: NavigationIdentiferStyle(
                          color: bluePrimary,
                        ),
                        physics: true,
                        pages: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              rowWidget(
                                  AppLocalizations.of(context)!.unitStatus,
                                  widget.status.toLowerCase() == 'online'
                                      ? AppLocalizations.of(context)!.moving
                                      : widget.status),
                              rowWidget(
                                  AppLocalizations.of(context)!.odoMeter,
                                  '${NumberFormat.currency(
                                    locale: 'id',
                                    decimalDigits: 0,
                                    symbol: '',
                                  ).format(int.parse(widget.odoMeter) / 1000)} km'),
                              rowWidget(AppLocalizations.of(context)!.warranty,
                                  widget.warranty),
                              rowWidget(
                                  AppLocalizations.of(context)!.registerDate,
                                  DateFormat('yyyy-MM-dd HH:mm').format(
                                      DateTime.parse(widget.registerDate))),
                              rowWidget(
                                  AppLocalizations.of(context)!.lastPosition,
                                  DateFormat('yyyy-MM-dd HH:mm').format(
                                      DateTime.parse(widget.lastPosition))),
                              rowWidget(
                                  AppLocalizations.of(context)!.lastData,
                                  DateFormat('yyyy-MM-dd HH:mm')
                                      .format(DateTime.parse(widget.lastData))),
                              rowWidget(
                                  AppLocalizations.of(context)!
                                      .pulsaPackageEnded,
                                  DateFormat('yyyy-MM-dd HH:mm').format(
                                      DateTime.parse(widget.activeWarranty))),
                              InkWell(
                                onLongPress: () {
                                  getAddressII(widget.latitude.toString(),
                                      widget.longitude.toString());
                                },
                                onTap: () {
                                  getAddress(widget.latitude.toString(),
                                      widget.longitude.toString());
                                },
                                child: rowWidgetAddress(
                                    AppLocalizations.of(context)!
                                        .vehiclePosition,
                                    address),
                              ),
                              rowWidgetLatLong('Latitude & Longitude',
                                  '${widget.latitude},${widget.longitude}'),
                            ],
                          ),
                          SingleChildScrollView(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              rowWidget(AppLocalizations.of(context)!.gpsType,
                                  widget.gpsType),
                              localData.Username == 'demo'
                                  ? rowWidget(
                                      AppLocalizations.of(context)!.imei, 'xxx')
                                  : rowWidget(
                                      AppLocalizations.of(context)!.imei,
                                      widget.imei),
                              rowWidget(
                                  AppLocalizations.of(context)!.deviceName,
                                  widget.deviceName),
                              rowWidget(
                                  AppLocalizations.of(context)!.numberPlate,
                                  widget.plate),
                              localData.Username == 'demo'
                                  ? rowWidgetPhone(
                                      AppLocalizations.of(context)!.gsmNumber,
                                      'xxxx')
                                  : rowWidgetPhone(
                                      AppLocalizations.of(context)!.gsmNumber,
                                      deviceInfo.data.result.gsmNumber),
                              rowWidget(
                                  AppLocalizations.of(context)!.vehicleType,
                                  deviceInfo.data.result.vehicleType),
                              // rowWidget('Icon',
                              //     deviceInfo.data.result.icon.toString()),
                              rowWidget(
                                  AppLocalizations.of(context)!
                                      .vehicleRegistration,
                                  deviceInfo.data.result.stnk == '' ||
                                          deviceInfo.data.result.stnk == '0'
                                      ? '-'
                                      : deviceInfo.data.result.stnk),
                              rowWidget(
                                  AppLocalizations.of(context)!.ownerName,
                                  deviceInfo.data.result.ownerName == '' ||
                                          deviceInfo.data.result.ownerName ==
                                              '0'
                                      ? '-'
                                      : deviceInfo.data.result.ownerName),
                              // rowWidget(
                              //     AppLocalizations.of(context)!.technician,
                              //     deviceInfo.data.result.instalationTech),
                              rowWidget(
                                  AppLocalizations.of(context)!.year,
                                  deviceInfo.data.result.year.toString() ==
                                              '0' ||
                                          deviceInfo.data.result.year
                                                  .toString() ==
                                              ''
                                      ? '-'
                                      : deviceInfo.data.result.year.toString()),
                              rowWidget(
                                  AppLocalizations.of(context)!.engineNumber,
                                  deviceInfo.data.result.nomesin == '' ||
                                          deviceInfo.data.result.nomesin == '0'
                                      ? '-'
                                      : deviceInfo.data.result.nomesin),
                              rowWidget(
                                  AppLocalizations.of(context)!.chasNumber,
                                  deviceInfo.data.result.norangka == '' ||
                                          deviceInfo.data.result.norangka == '0'
                                      ? '-'
                                      : deviceInfo.data.result.norangka),

                              rowWidget(
                                  AppLocalizations.of(context)!.speedLimit,
                                  deviceInfo.data.result.speedLimit
                                                  .toString() ==
                                              '0' ||
                                          deviceInfo.data.result.speedLimit
                                                  .toString() ==
                                              ''
                                      ? '-'
                                      : deviceInfo.data.result.speedLimit
                                          .toString()),
                              Visibility(
                                  visible: widget.isDashcam,
                                  child: rowWidget(
                                      'Live Camera Limit',
                                      _printDurationII(Duration(
                                          seconds: deviceInfo
                                              .data.result.limitLive)))),
                            ],
                          )),
                        ],
                        items: [
                          ScrollNavigationItem(
                              activeIcon: Text(
                                AppLocalizations.of(context)!.vehicleDetail,
                                textAlign: TextAlign.center,
                                style: reguler.copyWith(
                                  fontSize: 14,
                                  color: bluePrimary,
                                ),
                              ),
                              icon: Text(
                                AppLocalizations.of(context)!.vehicleDetail,
                                textAlign: TextAlign.center,
                                style: reguler.copyWith(
                                    fontSize: 14, color: blackPrimary),
                              )),
                          ScrollNavigationItem(
                              activeIcon: Text(
                                AppLocalizations.of(context)!.deviceInfo,
                                textAlign: TextAlign.center,
                                style: reguler.copyWith(
                                  fontSize: 14,
                                  color: bluePrimary,
                                ),
                              ),
                              icon: Text(
                                AppLocalizations.of(context)!.deviceInfo,
                                textAlign: TextAlign.center,
                                style: reguler.copyWith(
                                    fontSize: 14, color: blackPrimary),
                              )),
                        ],
                      );
                    }
                  }
                  return const Center(
                    child: Text('Loading...'),
                  );
                })));
  }

  rowWidget(dynamic status, String data) {
    return Column(
      children: [
        Divider(
          height: 2,
          thickness: 2,
          endIndent: 0,
          indent: 0,
          color: whiteCardColor,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: reguler.copyWith(
                fontSize: 12,
                color: widget.darkMode ? blackPrimary : blackSecondary3,
              ),
            ),
            Text(
              data,
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
      ],
    );
  }

  rowWidgetPhone(dynamic status, String data) {
    return Column(
      children: [
        Divider(
          height: 2,
          thickness: 2,
          endIndent: 0,
          indent: 0,
          color: whiteCardColor,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: reguler.copyWith(
                fontSize: 12,
                color: widget.darkMode ? blackPrimary : blackSecondary3,
              ),
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: data)).then((_) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Copied")));
                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.copy_outlined,
                      color: widget.darkMode ? blackPrimary : blackSecondary2,
                      size: 15,
                    ),
                  ),
                  Text(
                    data,
                    style: bold.copyWith(
                      fontSize: 12,
                      color: blackPrimary,
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
      ],
    );
  }

  rowWidgetLatLong(dynamic status, String data) {
    return Column(
      children: [
        Divider(
          height: 2,
          thickness: 2,
          endIndent: 0,
          indent: 0,
          color: whiteCardColor,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: reguler.copyWith(
                fontSize: 12,
                color: widget.darkMode ? blackPrimary : blackSecondary3,
              ),
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: data)).then((_) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Copied")));
                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.copy_outlined,
                      color: widget.darkMode ? blackPrimary : blackSecondary2,
                      size: 15,
                    ),
                  ),
                  Text(
                    data,
                    style: bold.copyWith(
                      fontSize: 12,
                      color: blackPrimary,
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
      ],
    );
  }

  rowWidgetAddress(dynamic status, String data) {
    return Column(
      children: [
        Divider(
          height: 2,
          thickness: 2,
          endIndent: 0,
          indent: 0,
          color: whiteCardColor,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: reguler.copyWith(
                fontSize: 12,
                color: widget.darkMode ? blackPrimary : blackSecondary3,
              ),
            ),
            Expanded(
              // width: 200,
              child: Text(
                data,
                textAlign: TextAlign.end,
                style: bold.copyWith(
                  fontSize: 12,
                  color: blackPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
