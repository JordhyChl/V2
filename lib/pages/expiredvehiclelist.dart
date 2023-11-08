// ignore_for_file: avoid_print, must_be_immutable, unused_field, prefer_final_fields

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/vehicle.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/pages/vehicledetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../widgets/add_vehicle.dart';

class ExpiredVehicleList extends StatefulWidget {
  bool darkMode;
  ExpiredVehicleList({super.key, required this.darkMode});

  @override
  State<ExpiredVehicleList> createState() => ExpiredVehicleListState();
}

class ExpiredVehicleListState extends State<ExpiredVehicleList>
    with TickerProviderStateMixin {
  int current = 0;
  TextEditingController suggestion = TextEditingController();
  List<Vehicle> _searchPost = [];
  // List<String> sort = [];
  bool _isError = false;
  String _errCode = '';
  late Future<dynamic> _getVehicleList;
  late ErrorTrapModel _errorMessage;
  late List<ResultVehicleList> sortVehicleList;
  late List<ResultVehicleList> initVehicleList;
  late List<ResultVehicleList> vehicleList;
  int page = 1;
  int perPage = 25;
  bool loadmoreBtn = false;
  bool loadmoreBtnPressed = false;
  int totalData = 0;
  int currentData = 0;
  late LocalData localData;
  final List<dynamic> _getParent = [];
  List<String> sort = [];
  dynamic appDir;

  @override
  void initState() {
    super.initState();
    print(_searchPost);
    _getVehicleList = getVehicleList();
    // print(widget.status);
    getLocal();
    getDir();
    // getParent();
  }

  getDir() async {
    appDir = await path_provider.getApplicationDocumentsDirectory();
  }

  getLocal() async {
    localData = await GeneralService().readLocalUserStorage();
  }

  Future<dynamic> getVehicleList() async {
    final result = await APIService().getVehicleList(page, perPage);
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853vehicleList';
        _errorMessage = result;
        // initPlatformState();
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        totalData = result.data.totalAllData;
        currentData = result.data.result.length;
        if (totalData > currentData) {
          setState(() {
            loadmoreBtn = true;
          });
        } else {
          setState(() {
            loadmoreBtn = false;
          });
        }
        sort = [
          AppLocalizations.of(context)!.all,
          AppLocalizations.of(context)!.expireSoon,
          AppLocalizations.of(context)!.expireNow
        ];
      });
    }
    return result;
  }

  Future doRefresh() async {
    if (mounted) {
      initVehicleList.clear();
      await Dialogs().loadingDialog(context);
      _getVehicleList = getVehicleList();
      Future.delayed(const Duration(seconds: 1), () async {
        await Dialogs().hideLoaderDialog(context);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 150,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: widget.darkMode
                  ? LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [whiteCardColor, whiteCardColor],
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
                        AppLocalizations.of(context)!.expireVehList,
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
              Text(
                '${AppLocalizations.of(context)!.showing} $totalData ${AppLocalizations.of(context)!.ofs} ${AppLocalizations.of(context)!.yourVehicle}',
                style: reguler.copyWith(
                    fontSize: 12,
                    color: widget.darkMode ? whiteColorDarkMode : whiteColor),
              ),
              const SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/searchvehicle');
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    // boxShadow: [
                    //   BoxShadow(
                    //       color: blackPrimary.withOpacity(0.5),
                    //       blurRadius: 7,
                    //       offset: const Offset(0, 10))
                    // ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    style: bold.copyWith(fontSize: 14, color: blackSecondary2),
                    decoration: InputDecoration(
                        enabled: false,
                        fillColor: whiteColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: reguler.copyWith(
                          fontSize: 10,
                          color: widget.darkMode
                              ? whiteColorDarkMode
                              : blackSecondary3,
                        ),
                        hintText: AppLocalizations.of(context)!.insertPlate,
                        suffixIcon: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/search.png',
                                color:
                                    widget.darkMode ? whiteColorDarkMode : null,
                              ),
                            )
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
          backgroundColor: bluePrimary,
        ),
        body: Column(children: [
          Container(
              width: double.infinity,
              height: sort.isEmpty ? 10 : 55,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                // horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: whiteColor,
              ),
              child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: sort.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          current = index;
                          print(current);
                        });
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(
                          right: 8,
                        ),
                        // padding: const EdgeInsets.symmetric(
                        //   vertical: 1,
                        //   horizontal: 24,
                        // ),
                        height: 24,
                        decoration: BoxDecoration(
                          color: current == index
                              ? index == 0
                                  ? blueGradient
                                  : index == 1
                                      ? yellowPrimary
                                      : index == 2
                                          ? redPrimary
                                          : whiteColor
                              : widget.darkMode
                                  ? whiteCardColor
                                  : whiteColor,
                          border: Border.all(
                            width: 1,
                            color: current == index
                                ? index == 0
                                    ? blueGradient
                                    : index == 1
                                        ? yellowPrimary
                                        : index == 2
                                            ? redPrimary
                                            : blueGradient
                                : widget.darkMode
                                    ? whiteCardColor
                                    : greyColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            sort[index],
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: current == index
                                  ? index == 0
                                      ? whiteColor
                                      : index == 1
                                          ? whiteColor
                                          : index == 2
                                              ? whiteColor
                                              : blackSecondary3
                                  : widget.darkMode
                                      ? whiteColorDarkMode
                                      : blackSecondary3,
                            ),
                          ),
                        ),
                      ),
                    );
                  })),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  FutureBuilder(
                      future: _getVehicleList,
                      builder: (BuildContext contxt,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data is ErrorTrapModel) {
                            //skeleton
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
                          } else {
                            initVehicleList = snapshot.data.data.result;
                            initVehicleList.sort(
                              (two, one) {
                                int a = one.sevenDays
                                    .toString()
                                    .compareTo(two.sevenDays.toString());
                                if (a != 0) {
                                  return a;
                                }
                                return two.expiredDate
                                    .compareTo(one.expiredDate);
                              },
                            );
                            vehicleList = initVehicleList;
                            if (initVehicleList.isEmpty) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  await doRefresh();
                                },
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                                              'assets/handling/noexpiredvehicle.png',
                                              height: 240,
                                              width: 240,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 50, right: 50, top: 10),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .noExpire,
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
                                                    .noExpireSub,
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
                            if (current == 1) {
                              List<ResultVehicleList> result = [];
                              for (var el in initVehicleList) {
                                if (el.sevenDays) {
                                  result.add(el);
                                }
                              }
                              if (result.isEmpty) {
                                return RefreshIndicator(
                                  onRefresh: () async {
                                    await doRefresh();
                                  },
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
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
                                                'assets/handling/noexpiredvehicle.png',
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
                                                      .noExpire,
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
                                                      .noExpireSub,
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
                                vehicleList = result;
                                print(result);
                              }
                            }
                            if (current == 2) {
                              List<ResultVehicleList> result = [];
                              for (var el in initVehicleList) {
                                if (el.isExpired) {
                                  result.add(el);
                                }
                              }
                              if (result.isEmpty) {
                                return RefreshIndicator(
                                  onRefresh: () async {
                                    await doRefresh();
                                  },
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
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
                                                'assets/handling/noexpiredvehicle.png',
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
                                                      .noExpire,
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
                                                      .noExpireSub,
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
                                vehicleList = result;
                                print(result);
                              }
                            }
                            return RefreshIndicator(
                                onRefresh: () async {
                                  await doRefresh();
                                },
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: vehicleList.length,
                                  itemBuilder: (context, index) {
                                    DateTime? pulsaPackage = DateTime.parse(
                                        vehicleList[index].expiredDate);
                                    DateTime? lastUpdate = DateTime.parse(
                                            vehicleList[index].lastData)
                                        .toLocal();
                                    String dateFormatPulsaPackage =
                                        DateFormat('y-MM-dd')
                                            .format(pulsaPackage.toLocal());
                                    String dateFormatPulsaPackageAddCart =
                                        DateFormat('dd MMMM y')
                                            .format(pulsaPackage.toLocal());
                                    String dateFormatLastUpdate =
                                        DateFormat('y-MM-dd HH:mm:ss')
                                            .format(lastUpdate.toLocal());

                                    String getPulsaExpired = DateFormat('yMMdd')
                                        .format(pulsaPackage.toLocal());
                                    String getNow = DateFormat('yMMdd')
                                        .format(DateTime.now().toLocal());
                                    int pulsaExpired =
                                        int.parse(getPulsaExpired);
                                    int now = int.parse(getNow);
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VehicleDetail(
                                              icon: vehicleList[index].icon,
                                              imei: vehicleList[index].imei,
                                              expDate: vehicleList[index]
                                                  .expiredDate,
                                              deviceName:
                                                  vehicleList[index].deviceName,
                                              gpsType:
                                                  vehicleList[index].gpsName,
                                              vehStatus:
                                                  vehicleList[index].status,
                                              darkMode: widget.darkMode,
                                            ),
                                          ),
                                        );
                                        if (vehicleList[index]
                                                .status
                                                .toLowerCase() ==
                                            'lost') {
                                          lostAlert(
                                              context,
                                              localData.Username,
                                              AppLocalizations.of(context)!
                                                  .lostTitle,
                                              AppLocalizations.of(context)!
                                                  .lostSubTitle,
                                              vehicleList[index].imei,
                                              vehicleList[index].plate);
                                          // showInfoAlert(context, 'asd');
                                        }
                                      },
                                      child: Container(
                                        // shadowColor: Colors.transparent,
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        decoration: BoxDecoration(
                                            color: widget.darkMode
                                                ? whiteCardColor
                                                : whiteColor,
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
                                            border: Border.all(
                                                width: 1,
                                                color: widget.darkMode
                                                    ? whiteCardColor
                                                    : greyColor),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vehicleList[index].deviceName,
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                style: bold.copyWith(
                                                  fontSize: 14,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : blackSecondary1,
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
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${AppLocalizations.of(context)!.lastUpdate}: ',
                                                            style: reguler
                                                                .copyWith(
                                                              fontSize: 9,
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary2,
                                                            ),
                                                          ),
                                                          Text(
                                                            dateFormatLastUpdate,
                                                            style: reguler.copyWith(
                                                                fontSize: 9,
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : blackSecondary2),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    // flex: 1,
                                                    // width: 250,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.speed,
                                                                  size: 18,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  '${vehicleList[index].speed.toString()} km/h',
                                                                  style: bold
                                                                      .copyWith(
                                                                    fontSize: 8,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary1,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 11,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .info_outline_rounded,
                                                                  size: 18,
                                                                  color: vehicleList[index].alert == '-' ||
                                                                          vehicleList[index].alert ==
                                                                              '0' ||
                                                                          vehicleList[index].alert ==
                                                                              ''
                                                                      ? vehicleList[index].status.toLowerCase() ==
                                                                              'online'
                                                                          ? bluePrimary
                                                                          : vehicleList[index].status.toLowerCase() == 'lost'
                                                                              ? yellowPrimary
                                                                              : vehicleList[index].status.toLowerCase() == 'alarm'
                                                                                  ? redPrimary
                                                                                  : blackPrimary
                                                                      : redPrimary,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                //belum ada status kendaraan
                                                                Text(
                                                                  vehicleList[index].alert == '-' ||
                                                                          vehicleList[index].alert ==
                                                                              '0' ||
                                                                          vehicleList[index].alert ==
                                                                              ''
                                                                      ? vehicleList[index].status ==
                                                                              'Stop'
                                                                          ? AppLocalizations.of(context)!
                                                                              .stop
                                                                          : vehicleList[index].status == 'Parking'
                                                                              ? AppLocalizations.of(context)!.park
                                                                              : vehicleList[index].status == 'Lost'
                                                                                  ? AppLocalizations.of(context)!.lost
                                                                                  : vehicleList[index].status == 'Online'
                                                                                      ? AppLocalizations.of(context)!.moving
                                                                                      : ''
                                                                      : vehicleList[index].alert,
                                                                  style: bold.copyWith(
                                                                      fontSize: 8,
                                                                      // color: _colorCondition(
                                                                      //   vehicleList[index].status,
                                                                      // ),
                                                                      color: vehicleList[index].alert == '-' || vehicleList[index].alert == '0' || vehicleList[index].alert == ''
                                                                          ? vehicleList[index].status.toLowerCase() == 'online'
                                                                              ? bluePrimary
                                                                              : vehicleList[index].status.toLowerCase() == 'lost'
                                                                                  ? yellowPrimary
                                                                                  : vehicleList[index].status.toLowerCase() == 'alarm'
                                                                                      ? redPrimary
                                                                                      : blackPrimary
                                                                          : redPrimary),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                //belum ada pulsa package
                                                                Text(
                                                                  '${AppLocalizations.of(context)!.subscriptionEnded} :',
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize: 9,
                                                                    color: now <
                                                                            pulsaExpired
                                                                        ? vehicleList[index].sevenDays
                                                                            ? yellowPrimary
                                                                            : widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary2
                                                                        : redPrimary,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Text(
                                                                  dateFormatPulsaPackage,
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize: 9,
                                                                    color: now <
                                                                            pulsaExpired
                                                                        ? vehicleList[index].sevenDays
                                                                            ? yellowPrimary
                                                                            : widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary2
                                                                        : redPrimary,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        // const SizedBox(
                                                        //   height: 10,
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  appDir is Directory
                                                      ? Image.file(
                                                          File(vehicleList[
                                                                          index]
                                                                      .status
                                                                      .toLowerCase() ==
                                                                  'stop'
                                                              ? '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_parking.png'
                                                              : vehicleList[index]
                                                                          .status
                                                                          .toLowerCase() ==
                                                                      'online'
                                                                  ? '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_accOn.png'
                                                                  : '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_${vehicleList[index].status.toLowerCase()}.png'),
                                                          width: 75,
                                                          height: 75,
                                                        )
                                                      : const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5),
                                                          child: SkeletonAvatar(
                                                            style: SkeletonAvatarStyle(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                width: 75,
                                                                height: 70),
                                                          ),
                                                        )
                                                ],
                                              ),
                                              Divider(
                                                height: 2,
                                                thickness: 1,
                                                indent: 0,
                                                endIndent: 0,
                                                color: greyColor,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Visibility(
                                                  visible: localData.Username ==
                                                          'demo'
                                                      ? false
                                                      : true,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      AddPackage(
                                                        gsmNumber:
                                                            vehicleList[index]
                                                                .gsmNo,
                                                        packageEnds:
                                                            dateFormatPulsaPackageAddCart,
                                                        deviceName:
                                                            vehicleList[index]
                                                                .deviceName,
                                                        domain: '',
                                                        fullName:
                                                            localData.Fullname,
                                                        userName:
                                                            localData.Username,
                                                        darkMode:
                                                            widget.darkMode,
                                                      ),
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ));
                          }
                        }
                        //skeleton

                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
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
            ),
          ),
        ]));
  }

  @override
  void dispose() {
    //store cart disini
    // _timer.isActive ? _timer.cancel() : {};
    super.dispose();
  }
}
