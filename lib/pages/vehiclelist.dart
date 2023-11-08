// ignore_for_file: avoid_print, use_build_context_synchronously, must_be_immutable, unused_field, unused_local_variable, prefer_final_fields

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/vehicle.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/pages/vehicledetail.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../widgets/add_vehicle.dart';

class VehicleList extends StatefulWidget {
  final String status;
  bool darkMode;
  VehicleList({super.key, required this.status, required this.darkMode});

  @override
  State<VehicleList> createState() => VehicleListState();
}

class VehicleListState extends State<VehicleList>
    with TickerProviderStateMixin {
  int current = 0;
  bool refreshList = false;
  // bool _isData = true;
  TextEditingController suggestion = TextEditingController();
  TextEditingController search = TextEditingController();
  List<Vehicle> _searchPost = [];
  List<String> sort = [];
  bool _isError = false;
  String _errCode = '';
  late Future<dynamic> _getVehicleList;
  late ErrorTrapModel _errorMessage;
  late List<ResultVehicleList> sortVehicleList;
  late List<ResultVehicleList> initVehicleList;
  late List<ResultVehicleList> vehicleList;
  late List<ResultVehicleList> allVehicleList;
  late List<ResultVehicleList> movingVehicleList;
  late List<ResultVehicleList> parkingVehicleList;
  late List<ResultVehicleList> stopVehicleList;
  late List<ResultVehicleList> lostVehicleList;
  int page = 1;
  int perPage = 25;
  bool loadmoreBtn = false;
  bool loadmoreBtnPressed = false;
  int totalData = 0;
  int currentData = 0;
  late LocalData localData;
  final List<dynamic> _getParent = [];
  final disp = [];
  late File displayImage;
  dynamic appDir;
  Uint8List? conv;

  // List<Widget> pages = [
  //   VehicleCard(VehicleModel(apiURL: '')),
  //   VehicleCard(VehicleModel(apiURL: 'status=bergerak')),
  //   VehicleCard(VehicleModel(apiURL: 'status=parkir')),
  //   VehicleCard(VehicleModel(apiURL: 'status=berhenti')),
  // ];
  @override
  void initState() {
    super.initState();
    print(_searchPost);
    _getVehicleList = getVehicleList(false);
    print(widget.status);
    getLocal();
    getDir();
    // getParent();
  }

  getDir() async {
    appDir = await path_provider.getApplicationDocumentsDirectory();
  }

  // getParent() async {
  //   final result = await APIService().getParent();
  //   if (result is GetParentModel) {
  //     int index = 0;
  //     result.data.parent.forEach((el) {
  //       setState(() {
  //         _getParent.add(el.iD);
  //       });
  //     });
  //     setState(() {
  //       index = result.data.parent.length - 1;
  //       _isError = false;
  //       _getParent.add(result.data.iD);
  //     });
  //   } else {
  //     setState(() {
  //       _isError = true;
  //     });
  //     _getVehicleList = getVehicleList();
  //   }
  // }

  getLocal() async {
    localData = await GeneralService().readLocalUserStorage();
  }

  Future<dynamic> getVehicleList(bool refresh) async {
    if (widget.status == 'Moving' || widget.status == 'Bergerak') {
      setState(() {
        !refreshList ? current = 1 : {};
      });
    }
    if (widget.status == 'Park' || widget.status == 'Parkir') {
      setState(() {
        !refreshList ? current = 2 : {};
      });
    }
    if (widget.status == 'Stop' || widget.status == 'Berhenti') {
      setState(() {
        !refreshList ? current = 3 : {};
      });
    }
    if (widget.status == 'Lost' || widget.status == 'Tidak update') {
      setState(() {
        !refreshList ? current = 4 : {};
      });
    }
    final result = await APIService().getVehicleList(page, perPage);
    if (result is ErrorTrapModel) {
      setState(() {
        refreshList = false;
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
          AppLocalizations.of(context)!.moving,
          AppLocalizations.of(context)!.park,
          AppLocalizations.of(context)!.stop,
          AppLocalizations.of(context)!.lost,
        ];
      });
      refresh ? refreshList = false : {};
      refresh ? initVehicleList.clear() : {};
    }
    return result;
  }

  // loadMore() async {
  //   Dialogs().loadingDialog(context);
  //   loadmoreBtnPressed = true;
  //   page++;
  //   APIService().getVehicleList(page, perPage).then((snapshot) {
  //     if (snapshot is ErrorTrapModel) {
  //       loadmoreBtn = false;
  //       setState(() {
  //         _isError = true;
  //         _errCode = '76853vehicleListLoadMore';
  //       });
  //       Dialogs().hideLoaderDialog(context);
  //     } else {
  //       setState(() {
  //         _isError = false;
  //         _errCode = '';
  //         initVehicleList.addAll(snapshot.data.result);
  //         loadmoreBtnPressed = false;
  //         currentData = initVehicleList.length;
  //         currentData <= totalData ? loadmoreBtn = false : loadmoreBtn = true;
  //       });
  //       List<ResultVehicleList> resultMoving = [];
  //       List<ResultVehicleList> resultParking = [];
  //       List<ResultVehicleList> resultStop = [];
  //       for (var el in initVehicleList) {
  //         if (el.status == 'Online') {
  //           resultMoving.add(el);
  //         }
  //         if (el.status == 'Parking') {
  //           resultParking.add(el);
  //         }
  //         if (el.status == 'Stop') {
  //           resultStop.add(el);
  //         }
  //         setState(() {
  //           movingVehicleList = resultMoving;
  //           parkingVehicleList = resultParking;
  //           stopVehicleList = resultStop;
  //         });
  //       }

  //       Dialogs().hideLoaderDialog(context);
  //     }
  //   });
  // }

  Future doRefresh() async {
    if (mounted) {
      setState(() {
        refreshList = true;
      });
      // await Dialogs().loadingDialog(context);
      _getVehicleList = getVehicleList(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
                          AppLocalizations.of(context)!.listVehicle,
                          textAlign: TextAlign.center,
                          style: bold.copyWith(
                            fontSize: 16,
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${AppLocalizations.of(context)!.showing} $currentData ${AppLocalizations.of(context)!.ofs} $totalData ${AppLocalizations.of(context)!.yourVehicle}',
                  style: reguler.copyWith(
                      fontSize: 12,
                      color: widget.darkMode ? whiteColorDarkMode : null),
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
                        controller: search,
                        textAlign: TextAlign.start,
                        style:
                            bold.copyWith(fontSize: 10, color: blackSecondary2),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(12),
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
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : null,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ))
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
                                ? widget.darkMode
                                    ? blueGradient
                                    : index == 0
                                        ? blueGradient
                                        : index == 1
                                            ? blueGradient
                                            : index == 2
                                                ? blackSecondary1
                                                : index == 3
                                                    ? blackSecondary1
                                                    : index == 4
                                                        ? yellowPrimary
                                                        : whiteColor
                                : widget.darkMode
                                    ? whiteCardColor
                                    : whiteColor,
                            border: Border.all(
                              width: 1,
                              color: current == index
                                  ? widget.darkMode
                                      ? blueGradient
                                      : index == 1
                                          ? blueGradient
                                          : index == 2
                                              ? blackSecondary1
                                              : index == 3
                                                  ? blackSecondary1
                                                  : index == 4
                                                      ? yellowPrimary
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
                                    ? index == 1
                                        ? whiteColor
                                        : index == 2
                                            ? whiteColor
                                            : index == 3
                                                ? whiteColor
                                                : index == 4
                                                    ? whiteColor
                                                    : whiteColor
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
                padding: const EdgeInsets.only(left: 20, right: 20, top: 7),
                child: Stack(
                  children: [
                    FutureBuilder(
                        future: _getVehicleList,
                        builder: (BuildContext contxt,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData && !refreshList) {
                            if (snapshot.data is ErrorTrapModel) {
                              ErrorTrapModel errorTrapModel = snapshot.data;
                              if (errorTrapModel.statusError
                                      .contains('Failed host lookup:') ||
                                  errorTrapModel.statusError.contains(
                                      'Connection closed before full header was received')) {
                                return Column(
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
                                        AppLocalizations.of(context)!
                                            .noConnection,
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
                                            .noConnectionSub,
                                        textAlign: TextAlign.center,
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: blackSecondary2,
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
                                                await doRefresh();
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
                                                      AppLocalizations.of(
                                                              context)!
                                                          .tryAgain,
                                                      style: bold.copyWith(
                                                        fontSize: 14,
                                                        color: whiteColor,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                );
                              } else {
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
                                                'assets/handling/500error.png',
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
                                                      .error500,
                                                  textAlign: TextAlign.center,
                                                  style: bold.copyWith(
                                                    fontSize: 14,
                                                    color: blackSecondary2,
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
                                                      .error500Sub,
                                                  textAlign: TextAlign.center,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: blackSecondary2,
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

                              // RefreshIndicator(
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(top: 60),
                              //     child: Align(
                              //       alignment: Alignment.topCenter,
                              //       child: Column(
                              //         mainAxisAlignment: MainAxisAlignment.start,
                              //         children: [
                              //           Image.asset(
                              //             'assets/handling/500error.png',
                              //             height: 240,
                              //             width: 240,
                              //           ),
                              //           Padding(
                              //             padding: const EdgeInsets.only(
                              //                 left: 50, right: 50, top: 10),
                              //             child: Text(
                              //               AppLocalizations.of(context)!
                              //                   .error500,
                              //               textAlign: TextAlign.center,
                              //               style: bold.copyWith(
                              //                 fontSize: 14,
                              //                 color: blackSecondary2,
                              //               ),
                              //             ),
                              //           ),
                              //           Padding(
                              //             padding: const EdgeInsets.only(
                              //                 left: 30, right: 30, top: 10),
                              //             child: Text(
                              //               AppLocalizations.of(context)!
                              //                   .error500Sub,
                              //               textAlign: TextAlign.center,
                              //               style: reguler.copyWith(
                              //                 fontSize: 12,
                              //                 color: blackSecondary2,
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              //   onRefresh: () async {
                              //     await doRefresh();
                              //   },
                              // );
                            } else {
                              initVehicleList = snapshot.data.data.result;
                              vehicleList = initVehicleList;
                              movingVehicleList = initVehicleList;
                              parkingVehicleList = initVehicleList;
                              stopVehicleList = initVehicleList;
                              lostVehicleList = initVehicleList;
                              if (snapshot.data.data.totalAllData == 0) {
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
                                                'assets/handling/emptyall.png',
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
                                                      .emptyAll,
                                                  textAlign: TextAlign.center,
                                                  style: bold.copyWith(
                                                    fontSize: 14,
                                                    color: blackSecondary2,
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
                                                      .emptyAllSub,
                                                  textAlign: TextAlign.center,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: blackSecondary2,
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
                                if (current == 1) {
                                  List<ResultVehicleList> result = [];
                                  for (var el in movingVehicleList) {
                                    if (el.status == 'Online') {
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
                                          // getAppdir(
                                          //     index, movingVehicleList);
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 60),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/handling/emptymoving.png',
                                                    height: 240,
                                                    width: 240,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 50,
                                                            right: 50,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptymoving,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: bold.copyWith(
                                                        fontSize: 14,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary2,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            right: 30,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptymovingSub,
                                                      textAlign:
                                                          TextAlign.center,
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
                                  for (var el in parkingVehicleList) {
                                    if (el.status == 'Parking') {
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
                                          // getAppdir(
                                          //     index, parkingVehicleList);
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 60),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/handling/emptyparking.png',
                                                    height: 240,
                                                    width: 240,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 50,
                                                            right: 50,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptyParking,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: bold.copyWith(
                                                        fontSize: 14,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary2,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            right: 30,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptyParkingSub,
                                                      textAlign:
                                                          TextAlign.center,
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
                                if (current == 3) {
                                  List<ResultVehicleList> result = [];
                                  for (var el in stopVehicleList) {
                                    if (el.status == 'Stop') {
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
                                          // getAppdir(index, stopVehicleList);
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 60),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/handling/emptystop.png',
                                                    height: 240,
                                                    width: 240,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 50,
                                                            right: 50,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptyStop,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: bold.copyWith(
                                                        fontSize: 14,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary2,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            right: 30,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptyStopSub,
                                                      textAlign:
                                                          TextAlign.center,
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
                                if (current == 4) {
                                  List<ResultVehicleList> result = [];
                                  for (var el in lostVehicleList) {
                                    if (el.status == 'Lost') {
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
                                            padding:
                                                const EdgeInsets.only(top: 60),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/handling/emptylost.png',
                                                    height: 240,
                                                    width: 240,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 50,
                                                            right: 50,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptyLost,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: bold.copyWith(
                                                        fontSize: 14,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary2,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            right: 30,
                                                            top: 10),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .emptyLostSub,
                                                      textAlign:
                                                          TextAlign.center,
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
                                        // getAppdir(index, vehicleList);
                                        DateTime? pulsaPackage = DateTime.parse(
                                            vehicleList[index].expiredDate);
                                        DateTime? lastUpdate = DateTime.parse(
                                                vehicleList[index].lastData)
                                            .toLocal();
                                        String isExpired = DateFormat('Y-MM-dd')
                                            .format(DateTime.now());
                                        String dateFormatPulsaPackage =
                                            DateFormat('y-MM-dd')
                                                .format(pulsaPackage.toLocal());
                                        String dateFormatPulsaPackageAddCart =
                                            DateFormat('dd MMMM y')
                                                .format(pulsaPackage.toLocal());
                                        String dateFormatLastUpdate =
                                            DateFormat('y-MM-dd HH:mm:ss')
                                                .format(lastUpdate.toLocal());

                                        String getPulsaExpired =
                                            DateFormat('yMMdd')
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
                                                builder: (context) =>
                                                    VehicleDetail(
                                                  icon: vehicleList[index].icon,
                                                  imei: vehicleList[index].imei,
                                                  expDate: vehicleList[index]
                                                      .expiredDate,
                                                  deviceName: vehicleList[index]
                                                      .deviceName,
                                                  gpsType: vehicleList[index]
                                                      .gpsName,
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
                                                              .withOpacity(
                                                                  0.12),
                                                      spreadRadius: 0,
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2))
                                                ],
                                                border: Border.all(
                                                    width: 1,
                                                    color: widget.darkMode
                                                        ? whiteCardColor
                                                        : greyColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            // elevation: 3,
                                            // shape: RoundedRectangleBorder(
                                            //   borderRadius:
                                            //       BorderRadius.circular(8),
                                            //   side: BorderSide(
                                            //     color: greyColor,
                                            //     width: 1,
                                            //   ),
                                            // ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          vehicleList[index]
                                                              .deviceName,
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: bold.copyWith(
                                                            fontSize: 14,
                                                            color: widget
                                                                    .darkMode
                                                                ? whiteColorDarkMode
                                                                : blackSecondary1,
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                          visible: !localData
                                                                  .IsGenerated
                                                              ? vehicleList[
                                                                      index]
                                                                  .isDashcam
                                                              : false,
                                                          child: Container(
                                                            height: 20,
                                                            width: 85,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topRight,
                                                                end: Alignment
                                                                    .bottomLeft,
                                                                colors: [
                                                                  blueGradientSecondary1,
                                                                  blueGradientSecondary2,
                                                                  blueGradient
                                                                ],
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                Image.asset(
                                                                  'assets/icon/dashcam/dashcam.png',
                                                                  width: 16,
                                                                  height: 16,
                                                                  color:
                                                                      whiteColor,
                                                                ),
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .camera,
                                                                  style: reguler
                                                                      .copyWith(
                                                                          color:
                                                                              whiteColor,
                                                                          fontSize:
                                                                              10),
                                                                ),
                                                              ],
                                                            ),
                                                          ))

                                                      // Visibility(
                                                      //   visible: vehicleList[
                                                      //                   index]
                                                      //               .gpsName
                                                      //               .toLowerCase() ==
                                                      //           'x40'
                                                      //       ? true
                                                      //       : false,
                                                      //   child: Padding(
                                                      //     padding:
                                                      //         const EdgeInsets
                                                      //                 .only(
                                                      //             right: 5),
                                                      //     child:
                                                      //         Image.asset(
                                                      //       'assets/icon/dashcam/dashcam.png',
                                                      //       width: 30,
                                                      //       height: 30,
                                                      //       color: vehicleList[index].alert == '-' ||
                                                      //               vehicleList[index].alert ==
                                                      //                   '0' ||
                                                      //               vehicleList[index].alert ==
                                                      //                   ''
                                                      //           ? vehicleList[index].status.toLowerCase() ==
                                                      //                   'online'
                                                      //               ? bluePrimary
                                                      //               : vehicleList[index].status.toLowerCase() ==
                                                      //                       'lost'
                                                      //                   ? yellowPrimary
                                                      //                   : vehicleList[index].status.toLowerCase() == 'alarm'
                                                      //                       ? redPrimary
                                                      //                       : blackPrimary
                                                      //           : redPrimary,
                                                      //     ),
                                                      //   ),
                                                      // )
                                                    ],
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
                                                          // SizedBox(
                                                          //   width: 200,
                                                          //   child: Text(
                                                          //     vehicleList[
                                                          //             index]
                                                          //         .deviceName,
                                                          //     maxLines:
                                                          //         1,
                                                          //     overflow:
                                                          //         TextOverflow
                                                          //             .ellipsis,
                                                          //     style: bold
                                                          //         .copyWith(
                                                          //       fontSize:
                                                          //           14,
                                                          //       color:
                                                          //           blackSecondary1,
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          // const SizedBox(
                                                          //   height: 4,
                                                          // ),
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
                                                            // Row(
                                                            //   mainAxisAlignment:
                                                            //       MainAxisAlignment
                                                            //           .spaceBetween,
                                                            //   children: [
                                                            //     Column(
                                                            //       crossAxisAlignment:
                                                            //           CrossAxisAlignment
                                                            //               .start,
                                                            //       children: [
                                                            //         // SizedBox(
                                                            //         //   width: 200,
                                                            //         //   child: Text(
                                                            //         //     vehicleList[
                                                            //         //             index]
                                                            //         //         .deviceName,
                                                            //         //     maxLines:
                                                            //         //         1,
                                                            //         //     overflow:
                                                            //         //         TextOverflow
                                                            //         //             .ellipsis,
                                                            //         //     style: bold
                                                            //         //         .copyWith(
                                                            //         //       fontSize:
                                                            //         //           14,
                                                            //         //       color:
                                                            //         //           blackSecondary1,
                                                            //         //     ),
                                                            //         //   ),
                                                            //         // ),
                                                            //         // const SizedBox(
                                                            //         //   height: 4,
                                                            //         // ),
                                                            //         Row(
                                                            //           crossAxisAlignment:
                                                            //               CrossAxisAlignment
                                                            //                   .start,
                                                            //           children: [
                                                            //             Text(
                                                            //               '${AppLocalizations.of(context)!.lastUpdate} :',
                                                            //               style: reguler
                                                            //                   .copyWith(
                                                            //                 fontSize:
                                                            //                     9,
                                                            //                 color:
                                                            //                     blackSecondary2,
                                                            //               ),
                                                            //             ),
                                                            //             const SizedBox(
                                                            //               width:
                                                            //                   2,
                                                            //             ),
                                                            //             Text(
                                                            //               dateFormatLastUpdate,
                                                            //               style: reguler.copyWith(
                                                            //                   fontSize:
                                                            //                       9,
                                                            //                   color:
                                                            //                       blackSecondary2),
                                                            //             ),
                                                            //           ],
                                                            //         ),
                                                            //       ],
                                                            //     ),
                                                            //   ],
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 8,
                                                            // ),
                                                            Row(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .speed,
                                                                      size: 18,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : null,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text(
                                                                      '${vehicleList[index].speed.toString()} km/h',
                                                                      style: bold
                                                                          .copyWith(
                                                                        fontSize:
                                                                            8,
                                                                        color: widget.darkMode
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
                                                                              vehicleList[index].alert == '0' ||
                                                                              vehicleList[index].alert == ''
                                                                          ? vehicleList[index].status.toLowerCase() == 'online'
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
                                                                              vehicleList[index].alert == '0' ||
                                                                              vehicleList[index].alert == ''
                                                                          ? vehicleList[index].status == 'Stop'
                                                                              ? AppLocalizations.of(context)!.stop
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
                                                                        fontSize:
                                                                            9,
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
                                                                        fontSize:
                                                                            9,
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
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          5),
                                                              child:
                                                                  SkeletonAvatar(
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
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : greyColor,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Visibility(
                                                      visible: localData
                                                                      .Username ==
                                                                  'demo' ||
                                                              vehicleList[index]
                                                                      .imei ==
                                                                  '123456'
                                                          ? false
                                                          : true,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          AddPackage(
                                                            gsmNumber:
                                                                vehicleList[
                                                                        index]
                                                                    .gsmNo,
                                                            packageEnds:
                                                                dateFormatPulsaPackageAddCart,
                                                            deviceName:
                                                                vehicleList[
                                                                        index]
                                                                    .deviceName,
                                                            domain: '',
                                                            fullName: localData
                                                                .Fullname,
                                                            userName: localData
                                                                .Username,
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
          ])

          // Provider.of<InternetConnectionStatus>(context) ==
          //         InternetConnectionStatus.disconnected
          //     ? Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Image.asset(
          //             'assets/handling/noConnection.png',
          //             height: 240,
          //             width: 240,
          //           ),
          //           Padding(
          //             padding:
          //                 const EdgeInsets.only(left: 50, right: 50, top: 10),
          //             child: Text(
          //               AppLocalizations.of(context)!.noConnection,
          //               textAlign: TextAlign.center,
          //               style: bold.copyWith(
          //                 fontSize: 14,
          //                 color: blackSecondary2,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding:
          //                 const EdgeInsets.only(left: 30, right: 30, top: 10),
          //             child: Text(
          //               AppLocalizations.of(context)!.noConnectionSub,
          //               textAlign: TextAlign.center,
          //               style: reguler.copyWith(
          //                 fontSize: 12,
          //                 color: blackSecondary2,
          //               ),
          //             ),
          //           ),
          //           Align(
          //             alignment: Alignment.bottomCenter,
          //             child: Visibility(
          //                 visible: true,
          //                 child: Padding(
          //                   padding: const EdgeInsets.all(45.0),
          //                   child: InkWell(
          //                     onTap: () async {
          //                       await doRefresh();
          //                     },
          //                     child: Container(
          //                       height: 27,
          //                       width: 120,
          //                       decoration: BoxDecoration(
          //                           borderRadius: const BorderRadius.all(
          //                               Radius.circular(8)),
          //                           gradient: LinearGradient(
          //                             colors: [
          //                               blueGradientSecondary2,
          //                               blueGradientSecondary1
          //                             ],
          //                             begin: Alignment.topRight,
          //                             end: Alignment.bottomLeft,
          //                           )),
          //                       child: Center(
          //                         child: Text(
          //                             AppLocalizations.of(context)!.tryAgain,
          //                             style: bold.copyWith(
          //                               fontSize: 14,
          //                               color: whiteColor,
          //                             )),
          //                       ),
          //                     ),
          //                   ),
          //                 )),
          //           ),
          //         ],
          //       )
          //     : Column(children: [
          //         Container(
          //             width: double.infinity,
          //             height: sort.isEmpty ? 10 : 55,
          //             padding: const EdgeInsets.symmetric(
          //               vertical: 12,
          //               // horizontal: 20,
          //             ),
          //             decoration: BoxDecoration(
          //               color: whiteColor,
          //             ),
          //             child: ListView.builder(
          //                 padding: const EdgeInsets.only(left: 20, right: 20),
          //                 physics: const AlwaysScrollableScrollPhysics(),
          //                 itemCount: sort.length,
          //                 scrollDirection: Axis.horizontal,
          //                 itemBuilder: (context, index) {
          //                   return GestureDetector(
          //                     onTap: () {
          //                       setState(() {
          //                         current = index;
          //                         print(current);
          //                       });
          //                     },
          //                     child: Container(
          //                       width: 120,
          //                       margin: const EdgeInsets.only(
          //                         right: 8,
          //                       ),
          //                       // padding: const EdgeInsets.symmetric(
          //                       //   vertical: 1,
          //                       //   horizontal: 24,
          //                       // ),
          //                       height: 24,
          //                       decoration: BoxDecoration(
          //                         color: current == index
          //                             ? widget.darkMode
          //                                 ? blueGradient
          //                                 : index == 0
          //                                     ? blueGradient
          //                                     : index == 1
          //                                         ? blueGradient
          //                                         : index == 2
          //                                             ? blackSecondary1
          //                                             : index == 3
          //                                                 ? blackSecondary1
          //                                                 : index == 4
          //                                                     ? yellowPrimary
          //                                                     : whiteColor
          //                             : widget.darkMode
          //                                 ? whiteCardColor
          //                                 : whiteColor,
          //                         border: Border.all(
          //                           width: 1,
          //                           color: current == index
          //                               ? widget.darkMode
          //                                   ? blueGradient
          //                                   : index == 1
          //                                       ? blueGradient
          //                                       : index == 2
          //                                           ? blackSecondary1
          //                                           : index == 3
          //                                               ? blackSecondary1
          //                                               : index == 4
          //                                                   ? yellowPrimary
          //                                                   : blueGradient
          //                               : widget.darkMode
          //                                   ? whiteCardColor
          //                                   : greyColor,
          //                         ),
          //                         borderRadius: BorderRadius.circular(4),
          //                       ),
          //                       child: Align(
          //                         alignment: Alignment.center,
          //                         child: Text(
          //                           sort[index],
          //                           style: reguler.copyWith(
          //                             fontSize: 12,
          //                             color: current == index
          //                                 ? index == 1
          //                                     ? whiteColor
          //                                     : index == 2
          //                                         ? whiteColor
          //                                         : index == 3
          //                                             ? whiteColor
          //                                             : index == 4
          //                                                 ? whiteColor
          //                                                 : whiteColor
          //                                 : widget.darkMode
          //                                     ? whiteColorDarkMode
          //                                     : blackSecondary3,
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   );
          //                 })),
          //         Expanded(
          //           child: Padding(
          //             padding:
          //                 const EdgeInsets.only(left: 20, right: 20, top: 7),
          //             child: Stack(
          //               children: [
          //                 FutureBuilder(
          //                     future: _getVehicleList,
          //                     builder: (BuildContext contxt,
          //                         AsyncSnapshot<dynamic> snapshot) {
          //                       if (snapshot.hasData && !refreshList) {
          //                         if (snapshot.data is ErrorTrapModel) {
          //                           return RefreshIndicator(
          //                             onRefresh: () async {
          //                               await doRefresh();
          //                             },
          //                             child: ListView.builder(
          //                               physics:
          //                                   const AlwaysScrollableScrollPhysics(),
          //                               itemCount: 1,
          //                               itemBuilder: (context, index) {
          //                                 return Padding(
          //                                   padding:
          //                                       const EdgeInsets.only(top: 60),
          //                                   child: Align(
          //                                     alignment: Alignment.topCenter,
          //                                     child: Column(
          //                                       mainAxisAlignment:
          //                                           MainAxisAlignment.start,
          //                                       children: [
          //                                         Image.asset(
          //                                           'assets/handling/500error.png',
          //                                           height: 240,
          //                                           width: 240,
          //                                         ),
          //                                         Padding(
          //                                           padding:
          //                                               const EdgeInsets.only(
          //                                                   left: 50,
          //                                                   right: 50,
          //                                                   top: 10),
          //                                           child: Text(
          //                                             AppLocalizations.of(
          //                                                     context)!
          //                                                 .error500,
          //                                             textAlign:
          //                                                 TextAlign.center,
          //                                             style: bold.copyWith(
          //                                               fontSize: 14,
          //                                               color: blackSecondary2,
          //                                             ),
          //                                           ),
          //                                         ),
          //                                         Padding(
          //                                           padding:
          //                                               const EdgeInsets.only(
          //                                                   left: 30,
          //                                                   right: 30,
          //                                                   top: 10),
          //                                           child: Text(
          //                                             AppLocalizations.of(
          //                                                     context)!
          //                                                 .error500Sub,
          //                                             textAlign:
          //                                                 TextAlign.center,
          //                                             style: reguler.copyWith(
          //                                               fontSize: 12,
          //                                               color: blackSecondary2,
          //                                             ),
          //                                           ),
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ),
          //                                 );
          //                               },
          //                             ),
          //                           );

          //                           // RefreshIndicator(
          //                           //   child: Padding(
          //                           //     padding: const EdgeInsets.only(top: 60),
          //                           //     child: Align(
          //                           //       alignment: Alignment.topCenter,
          //                           //       child: Column(
          //                           //         mainAxisAlignment: MainAxisAlignment.start,
          //                           //         children: [
          //                           //           Image.asset(
          //                           //             'assets/handling/500error.png',
          //                           //             height: 240,
          //                           //             width: 240,
          //                           //           ),
          //                           //           Padding(
          //                           //             padding: const EdgeInsets.only(
          //                           //                 left: 50, right: 50, top: 10),
          //                           //             child: Text(
          //                           //               AppLocalizations.of(context)!
          //                           //                   .error500,
          //                           //               textAlign: TextAlign.center,
          //                           //               style: bold.copyWith(
          //                           //                 fontSize: 14,
          //                           //                 color: blackSecondary2,
          //                           //               ),
          //                           //             ),
          //                           //           ),
          //                           //           Padding(
          //                           //             padding: const EdgeInsets.only(
          //                           //                 left: 30, right: 30, top: 10),
          //                           //             child: Text(
          //                           //               AppLocalizations.of(context)!
          //                           //                   .error500Sub,
          //                           //               textAlign: TextAlign.center,
          //                           //               style: reguler.copyWith(
          //                           //                 fontSize: 12,
          //                           //                 color: blackSecondary2,
          //                           //               ),
          //                           //             ),
          //                           //           ),
          //                           //         ],
          //                           //       ),
          //                           //     ),
          //                           //   ),
          //                           //   onRefresh: () async {
          //                           //     await doRefresh();
          //                           //   },
          //                           // );
          //                         } else {
          //                           initVehicleList = snapshot.data.data.result;
          //                           vehicleList = initVehicleList;
          //                           movingVehicleList = initVehicleList;
          //                           parkingVehicleList = initVehicleList;
          //                           stopVehicleList = initVehicleList;
          //                           lostVehicleList = initVehicleList;
          //                           if (snapshot.data.data.totalAllData == 0) {
          //                             return RefreshIndicator(
          //                               onRefresh: () async {
          //                                 await doRefresh();
          //                               },
          //                               child: ListView.builder(
          //                                 physics:
          //                                     const AlwaysScrollableScrollPhysics(),
          //                                 itemCount: 1,
          //                                 itemBuilder: (context, index) {
          //                                   return Padding(
          //                                     padding: const EdgeInsets.only(
          //                                         top: 60),
          //                                     child: Align(
          //                                       alignment: Alignment.topCenter,
          //                                       child: Column(
          //                                         mainAxisAlignment:
          //                                             MainAxisAlignment.start,
          //                                         children: [
          //                                           Image.asset(
          //                                             'assets/handling/emptyall.png',
          //                                             height: 240,
          //                                             width: 240,
          //                                           ),
          //                                           Padding(
          //                                             padding:
          //                                                 const EdgeInsets.only(
          //                                                     left: 50,
          //                                                     right: 50,
          //                                                     top: 10),
          //                                             child: Text(
          //                                               AppLocalizations.of(
          //                                                       context)!
          //                                                   .emptyAll,
          //                                               textAlign:
          //                                                   TextAlign.center,
          //                                               style: bold.copyWith(
          //                                                 fontSize: 14,
          //                                                 color:
          //                                                     blackSecondary2,
          //                                               ),
          //                                             ),
          //                                           ),
          //                                           Padding(
          //                                             padding:
          //                                                 const EdgeInsets.only(
          //                                                     left: 30,
          //                                                     right: 30,
          //                                                     top: 10),
          //                                             child: Text(
          //                                               AppLocalizations.of(
          //                                                       context)!
          //                                                   .emptyAllSub,
          //                                               textAlign:
          //                                                   TextAlign.center,
          //                                               style: reguler.copyWith(
          //                                                 fontSize: 12,
          //                                                 color:
          //                                                     blackSecondary2,
          //                                               ),
          //                                             ),
          //                                           ),
          //                                         ],
          //                                       ),
          //                                     ),
          //                                   );
          //                                 },
          //                               ),
          //                             );
          //                           } else {
          //                             if (current == 1) {
          //                               List<ResultVehicleList> result = [];
          //                               for (var el in movingVehicleList) {
          //                                 if (el.status == 'Online') {
          //                                   result.add(el);
          //                                 }
          //                               }
          //                               if (result.isEmpty) {
          //                                 return RefreshIndicator(
          //                                   onRefresh: () async {
          //                                     await doRefresh();
          //                                   },
          //                                   child: ListView.builder(
          //                                     physics:
          //                                         const AlwaysScrollableScrollPhysics(),
          //                                     itemCount: 1,
          //                                     itemBuilder: (context, index) {
          //                                       // getAppdir(
          //                                       //     index, movingVehicleList);
          //                                       return Padding(
          //                                         padding:
          //                                             const EdgeInsets.only(
          //                                                 top: 60),
          //                                         child: Align(
          //                                           alignment:
          //                                               Alignment.topCenter,
          //                                           child: Column(
          //                                             mainAxisAlignment:
          //                                                 MainAxisAlignment
          //                                                     .start,
          //                                             children: [
          //                                               Image.asset(
          //                                                 'assets/handling/emptymoving.png',
          //                                                 height: 240,
          //                                                 width: 240,
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 50,
          //                                                         right: 50,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptymoving,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style:
          //                                                       bold.copyWith(
          //                                                     fontSize: 14,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 30,
          //                                                         right: 30,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptymovingSub,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style: reguler
          //                                                       .copyWith(
          //                                                     fontSize: 12,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                             ],
          //                                           ),
          //                                         ),
          //                                       );
          //                                     },
          //                                   ),
          //                                 );
          //                               } else {
          //                                 vehicleList = result;
          //                                 print(result);
          //                               }
          //                             }
          //                             if (current == 2) {
          //                               List<ResultVehicleList> result = [];
          //                               for (var el in parkingVehicleList) {
          //                                 if (el.status == 'Parking') {
          //                                   result.add(el);
          //                                 }
          //                               }
          //                               if (result.isEmpty) {
          //                                 return RefreshIndicator(
          //                                   onRefresh: () async {
          //                                     await doRefresh();
          //                                   },
          //                                   child: ListView.builder(
          //                                     physics:
          //                                         const AlwaysScrollableScrollPhysics(),
          //                                     itemCount: 1,
          //                                     itemBuilder: (context, index) {
          //                                       // getAppdir(
          //                                       //     index, parkingVehicleList);
          //                                       return Padding(
          //                                         padding:
          //                                             const EdgeInsets.only(
          //                                                 top: 60),
          //                                         child: Align(
          //                                           alignment:
          //                                               Alignment.topCenter,
          //                                           child: Column(
          //                                             mainAxisAlignment:
          //                                                 MainAxisAlignment
          //                                                     .start,
          //                                             children: [
          //                                               Image.asset(
          //                                                 'assets/handling/emptyparking.png',
          //                                                 height: 240,
          //                                                 width: 240,
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 50,
          //                                                         right: 50,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptyParking,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style:
          //                                                       bold.copyWith(
          //                                                     fontSize: 14,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 30,
          //                                                         right: 30,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptyParkingSub,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style: reguler
          //                                                       .copyWith(
          //                                                     fontSize: 12,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                             ],
          //                                           ),
          //                                         ),
          //                                       );
          //                                     },
          //                                   ),
          //                                 );
          //                               } else {
          //                                 vehicleList = result;
          //                                 print(result);
          //                               }
          //                             }
          //                             if (current == 3) {
          //                               List<ResultVehicleList> result = [];
          //                               for (var el in stopVehicleList) {
          //                                 if (el.status == 'Stop') {
          //                                   result.add(el);
          //                                 }
          //                               }
          //                               if (result.isEmpty) {
          //                                 return RefreshIndicator(
          //                                   onRefresh: () async {
          //                                     await doRefresh();
          //                                   },
          //                                   child: ListView.builder(
          //                                     physics:
          //                                         const AlwaysScrollableScrollPhysics(),
          //                                     itemCount: 1,
          //                                     itemBuilder: (context, index) {
          //                                       // getAppdir(index, stopVehicleList);
          //                                       return Padding(
          //                                         padding:
          //                                             const EdgeInsets.only(
          //                                                 top: 60),
          //                                         child: Align(
          //                                           alignment:
          //                                               Alignment.topCenter,
          //                                           child: Column(
          //                                             mainAxisAlignment:
          //                                                 MainAxisAlignment
          //                                                     .start,
          //                                             children: [
          //                                               Image.asset(
          //                                                 'assets/handling/emptystop.png',
          //                                                 height: 240,
          //                                                 width: 240,
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 50,
          //                                                         right: 50,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptyStop,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style:
          //                                                       bold.copyWith(
          //                                                     fontSize: 14,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 30,
          //                                                         right: 30,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptyStopSub,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style: reguler
          //                                                       .copyWith(
          //                                                     fontSize: 12,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                             ],
          //                                           ),
          //                                         ),
          //                                       );
          //                                     },
          //                                   ),
          //                                 );
          //                               } else {
          //                                 vehicleList = result;
          //                                 print(result);
          //                               }
          //                             }
          //                             if (current == 4) {
          //                               List<ResultVehicleList> result = [];
          //                               for (var el in lostVehicleList) {
          //                                 if (el.status == 'Lost') {
          //                                   result.add(el);
          //                                 }
          //                               }
          //                               if (result.isEmpty) {
          //                                 return RefreshIndicator(
          //                                   onRefresh: () async {
          //                                     await doRefresh();
          //                                   },
          //                                   child: ListView.builder(
          //                                     physics:
          //                                         const AlwaysScrollableScrollPhysics(),
          //                                     itemCount: 1,
          //                                     itemBuilder: (context, index) {
          //                                       return Padding(
          //                                         padding:
          //                                             const EdgeInsets.only(
          //                                                 top: 60),
          //                                         child: Align(
          //                                           alignment:
          //                                               Alignment.topCenter,
          //                                           child: Column(
          //                                             mainAxisAlignment:
          //                                                 MainAxisAlignment
          //                                                     .start,
          //                                             children: [
          //                                               Image.asset(
          //                                                 'assets/handling/emptylost.png',
          //                                                 height: 240,
          //                                                 width: 240,
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 50,
          //                                                         right: 50,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptyLost,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style:
          //                                                       bold.copyWith(
          //                                                     fontSize: 14,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                               Padding(
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                             .only(
          //                                                         left: 30,
          //                                                         right: 30,
          //                                                         top: 10),
          //                                                 child: Text(
          //                                                   AppLocalizations.of(
          //                                                           context)!
          //                                                       .emptyLostSub,
          //                                                   textAlign: TextAlign
          //                                                       .center,
          //                                                   style: reguler
          //                                                       .copyWith(
          //                                                     fontSize: 12,
          //                                                     color: widget
          //                                                             .darkMode
          //                                                         ? whiteColorDarkMode
          //                                                         : blackSecondary2,
          //                                                   ),
          //                                                 ),
          //                                               ),
          //                                             ],
          //                                           ),
          //                                         ),
          //                                       );
          //                                     },
          //                                   ),
          //                                 );
          //                               } else {
          //                                 vehicleList = result;
          //                                 print(result);
          //                               }
          //                             }

          //                             return RefreshIndicator(
          //                                 onRefresh: () async {
          //                                   await doRefresh();
          //                                 },
          //                                 child: ListView.builder(
          //                                   physics:
          //                                       const AlwaysScrollableScrollPhysics(),
          //                                   scrollDirection: Axis.vertical,
          //                                   itemCount: vehicleList.length,
          //                                   itemBuilder: (context, index) {
          //                                     // getAppdir(index, vehicleList);
          //                                     DateTime? pulsaPackage =
          //                                         DateTime.parse(
          //                                             vehicleList[index]
          //                                                 .expiredDate);
          //                                     DateTime? lastUpdate =
          //                                         DateTime.parse(
          //                                                 vehicleList[index]
          //                                                     .lastData)
          //                                             .toLocal();
          //                                     String isExpired =
          //                                         DateFormat('Y-MM-dd')
          //                                             .format(DateTime.now());
          //                                     String dateFormatPulsaPackage =
          //                                         DateFormat('y-MM-dd').format(
          //                                             pulsaPackage.toLocal());
          //                                     String
          //                                         dateFormatPulsaPackageAddCart =
          //                                         DateFormat('dd MMMM y')
          //                                             .format(pulsaPackage
          //                                                 .toLocal());
          //                                     String dateFormatLastUpdate =
          //                                         DateFormat('y-MM-dd HH:mm:ss')
          //                                             .format(
          //                                                 lastUpdate.toLocal());

          //                                     String getPulsaExpired =
          //                                         DateFormat('yMMdd').format(
          //                                             pulsaPackage.toLocal());
          //                                     String getNow =
          //                                         DateFormat('yMMdd').format(
          //                                             DateTime.now().toLocal());
          //                                     int pulsaExpired =
          //                                         int.parse(getPulsaExpired);
          //                                     int now = int.parse(getNow);
          //                                     return InkWell(
          //                                       onTap: () {
          //                                         Navigator.push(
          //                                           context,
          //                                           MaterialPageRoute(
          //                                             builder: (context) =>
          //                                                 VehicleDetail(
          //                                               icon: vehicleList[index]
          //                                                   .icon,
          //                                               imei: vehicleList[index]
          //                                                   .imei,
          //                                               expDate:
          //                                                   vehicleList[index]
          //                                                       .expiredDate,
          //                                               deviceName:
          //                                                   vehicleList[index]
          //                                                       .deviceName,
          //                                               gpsType:
          //                                                   vehicleList[index]
          //                                                       .gpsName,
          //                                               vehStatus:
          //                                                   vehicleList[index]
          //                                                       .status,
          //                                               darkMode:
          //                                                   widget.darkMode,
          //                                             ),
          //                                           ),
          //                                         );
          //                                         if (vehicleList[index]
          //                                                 .status
          //                                                 .toLowerCase() ==
          //                                             'lost') {
          //                                           lostAlert(
          //                                               context,
          //                                               localData.Username,
          //                                               AppLocalizations.of(
          //                                                       context)!
          //                                                   .lostTitle,
          //                                               AppLocalizations.of(
          //                                                       context)!
          //                                                   .lostSubTitle,
          //                                               vehicleList[index].imei,
          //                                               vehicleList[index]
          //                                                   .plate);
          //                                           // showInfoAlert(context, 'asd');
          //                                         }
          //                                       },
          //                                       child: Container(
          //                                         // shadowColor: Colors.transparent,
          //                                         margin: const EdgeInsets.only(
          //                                           bottom: 20,
          //                                         ),
          //                                         decoration: BoxDecoration(
          //                                             color: widget.darkMode
          //                                                 ? whiteCardColor
          //                                                 : whiteColor,
          //                                             boxShadow: [
          //                                               BoxShadow(
          //                                                   color: widget
          //                                                           .darkMode
          //                                                       ? whiteCardColor
          //                                                       : blackPrimary
          //                                                           .withOpacity(
          //                                                               0.12),
          //                                                   spreadRadius: 0,
          //                                                   blurRadius: 8,
          //                                                   offset:
          //                                                       const Offset(
          //                                                           0, 2))
          //                                             ],
          //                                             border: Border.all(
          //                                                 width: 1,
          //                                                 color: widget.darkMode
          //                                                     ? whiteCardColor
          //                                                     : greyColor),
          //                                             borderRadius:
          //                                                 BorderRadius.circular(
          //                                                     8)),
          //                                         // elevation: 3,
          //                                         // shape: RoundedRectangleBorder(
          //                                         //   borderRadius:
          //                                         //       BorderRadius.circular(8),
          //                                         //   side: BorderSide(
          //                                         //     color: greyColor,
          //                                         //     width: 1,
          //                                         //   ),
          //                                         // ),
          //                                         child: Padding(
          //                                           padding:
          //                                               const EdgeInsets.all(
          //                                                   12.0),
          //                                           child: Column(
          //                                             crossAxisAlignment:
          //                                                 CrossAxisAlignment
          //                                                     .start,
          //                                             children: [
          //                                               Row(
          //                                                 mainAxisAlignment:
          //                                                     MainAxisAlignment
          //                                                         .spaceBetween,
          //                                                 children: [
          //                                                   Expanded(
          //                                                     child: Text(
          //                                                       vehicleList[
          //                                                               index]
          //                                                           .deviceName,
          //                                                       maxLines: 1,
          //                                                       textAlign:
          //                                                           TextAlign
          //                                                               .start,
          //                                                       overflow:
          //                                                           TextOverflow
          //                                                               .ellipsis,
          //                                                       style: bold
          //                                                           .copyWith(
          //                                                         fontSize: 14,
          //                                                         color: widget
          //                                                                 .darkMode
          //                                                             ? whiteColorDarkMode
          //                                                             : blackSecondary1,
          //                                                       ),
          //                                                     ),
          //                                                   ),
          //                                                   Visibility(
          //                                                       visible: !localData
          //                                                               .IsGenerated
          //                                                           ? vehicleList[
          //                                                                   index]
          //                                                               .isDashcam
          //                                                           : false,
          //                                                       child:
          //                                                           Container(
          //                                                         height: 20,
          //                                                         width: 85,
          //                                                         decoration:
          //                                                             BoxDecoration(
          //                                                           borderRadius:
          //                                                               BorderRadius
          //                                                                   .circular(4),
          //                                                           gradient:
          //                                                               LinearGradient(
          //                                                             begin: Alignment
          //                                                                 .topRight,
          //                                                             end: Alignment
          //                                                                 .bottomLeft,
          //                                                             colors: [
          //                                                               blueGradientSecondary1,
          //                                                               blueGradientSecondary2,
          //                                                               blueGradient
          //                                                             ],
          //                                                           ),
          //                                                         ),
          //                                                         child: Row(
          //                                                           mainAxisAlignment:
          //                                                               MainAxisAlignment
          //                                                                   .spaceEvenly,
          //                                                           children: [
          //                                                             Image
          //                                                                 .asset(
          //                                                               'assets/icon/dashcam/dashcam.png',
          //                                                               width:
          //                                                                   16,
          //                                                               height:
          //                                                                   16,
          //                                                               color:
          //                                                                   whiteColor,
          //                                                             ),
          //                                                             Text(
          //                                                               AppLocalizations.of(context)!
          //                                                                   .camera,
          //                                                               style: reguler.copyWith(
          //                                                                   color:
          //                                                                       whiteColor,
          //                                                                   fontSize:
          //                                                                       10),
          //                                                             ),
          //                                                           ],
          //                                                         ),
          //                                                       ))

          //                                                   // Visibility(
          //                                                   //   visible: vehicleList[
          //                                                   //                   index]
          //                                                   //               .gpsName
          //                                                   //               .toLowerCase() ==
          //                                                   //           'x40'
          //                                                   //       ? true
          //                                                   //       : false,
          //                                                   //   child: Padding(
          //                                                   //     padding:
          //                                                   //         const EdgeInsets
          //                                                   //                 .only(
          //                                                   //             right: 5),
          //                                                   //     child:
          //                                                   //         Image.asset(
          //                                                   //       'assets/icon/dashcam/dashcam.png',
          //                                                   //       width: 30,
          //                                                   //       height: 30,
          //                                                   //       color: vehicleList[index].alert == '-' ||
          //                                                   //               vehicleList[index].alert ==
          //                                                   //                   '0' ||
          //                                                   //               vehicleList[index].alert ==
          //                                                   //                   ''
          //                                                   //           ? vehicleList[index].status.toLowerCase() ==
          //                                                   //                   'online'
          //                                                   //               ? bluePrimary
          //                                                   //               : vehicleList[index].status.toLowerCase() ==
          //                                                   //                       'lost'
          //                                                   //                   ? yellowPrimary
          //                                                   //                   : vehicleList[index].status.toLowerCase() == 'alarm'
          //                                                   //                       ? redPrimary
          //                                                   //                       : blackPrimary
          //                                                   //           : redPrimary,
          //                                                   //     ),
          //                                                   //   ),
          //                                                   // )
          //                                                 ],
          //                                               ),
          //                                               Row(
          //                                                 mainAxisAlignment:
          //                                                     MainAxisAlignment
          //                                                         .spaceBetween,
          //                                                 children: [
          //                                                   Column(
          //                                                     crossAxisAlignment:
          //                                                         CrossAxisAlignment
          //                                                             .start,
          //                                                     children: [
          //                                                       // SizedBox(
          //                                                       //   width: 200,
          //                                                       //   child: Text(
          //                                                       //     vehicleList[
          //                                                       //             index]
          //                                                       //         .deviceName,
          //                                                       //     maxLines:
          //                                                       //         1,
          //                                                       //     overflow:
          //                                                       //         TextOverflow
          //                                                       //             .ellipsis,
          //                                                       //     style: bold
          //                                                       //         .copyWith(
          //                                                       //       fontSize:
          //                                                       //           14,
          //                                                       //       color:
          //                                                       //           blackSecondary1,
          //                                                       //     ),
          //                                                       //   ),
          //                                                       // ),
          //                                                       // const SizedBox(
          //                                                       //   height: 4,
          //                                                       // ),
          //                                                       Row(
          //                                                         crossAxisAlignment:
          //                                                             CrossAxisAlignment
          //                                                                 .start,
          //                                                         children: [
          //                                                           Text(
          //                                                             '${AppLocalizations.of(context)!.lastUpdate}: ',
          //                                                             style: reguler
          //                                                                 .copyWith(
          //                                                               fontSize:
          //                                                                   9,
          //                                                               color: widget.darkMode
          //                                                                   ? whiteColorDarkMode
          //                                                                   : blackSecondary2,
          //                                                             ),
          //                                                           ),
          //                                                           Text(
          //                                                             dateFormatLastUpdate,
          //                                                             style: reguler.copyWith(
          //                                                                 fontSize:
          //                                                                     9,
          //                                                                 color: widget.darkMode
          //                                                                     ? whiteColorDarkMode
          //                                                                     : blackSecondary2),
          //                                                           ),
          //                                                         ],
          //                                                       ),
          //                                                     ],
          //                                                   ),
          //                                                 ],
          //                                               ),
          //                                               Row(
          //                                                 children: [
          //                                                   Expanded(
          //                                                     // flex: 1,
          //                                                     // width: 250,
          //                                                     child: Column(
          //                                                       crossAxisAlignment:
          //                                                           CrossAxisAlignment
          //                                                               .start,
          //                                                       children: [
          //                                                         // Row(
          //                                                         //   mainAxisAlignment:
          //                                                         //       MainAxisAlignment
          //                                                         //           .spaceBetween,
          //                                                         //   children: [
          //                                                         //     Column(
          //                                                         //       crossAxisAlignment:
          //                                                         //           CrossAxisAlignment
          //                                                         //               .start,
          //                                                         //       children: [
          //                                                         //         // SizedBox(
          //                                                         //         //   width: 200,
          //                                                         //         //   child: Text(
          //                                                         //         //     vehicleList[
          //                                                         //         //             index]
          //                                                         //         //         .deviceName,
          //                                                         //         //     maxLines:
          //                                                         //         //         1,
          //                                                         //         //     overflow:
          //                                                         //         //         TextOverflow
          //                                                         //         //             .ellipsis,
          //                                                         //         //     style: bold
          //                                                         //         //         .copyWith(
          //                                                         //         //       fontSize:
          //                                                         //         //           14,
          //                                                         //         //       color:
          //                                                         //         //           blackSecondary1,
          //                                                         //         //     ),
          //                                                         //         //   ),
          //                                                         //         // ),
          //                                                         //         // const SizedBox(
          //                                                         //         //   height: 4,
          //                                                         //         // ),
          //                                                         //         Row(
          //                                                         //           crossAxisAlignment:
          //                                                         //               CrossAxisAlignment
          //                                                         //                   .start,
          //                                                         //           children: [
          //                                                         //             Text(
          //                                                         //               '${AppLocalizations.of(context)!.lastUpdate} :',
          //                                                         //               style: reguler
          //                                                         //                   .copyWith(
          //                                                         //                 fontSize:
          //                                                         //                     9,
          //                                                         //                 color:
          //                                                         //                     blackSecondary2,
          //                                                         //               ),
          //                                                         //             ),
          //                                                         //             const SizedBox(
          //                                                         //               width:
          //                                                         //                   2,
          //                                                         //             ),
          //                                                         //             Text(
          //                                                         //               dateFormatLastUpdate,
          //                                                         //               style: reguler.copyWith(
          //                                                         //                   fontSize:
          //                                                         //                       9,
          //                                                         //                   color:
          //                                                         //                       blackSecondary2),
          //                                                         //             ),
          //                                                         //           ],
          //                                                         //         ),
          //                                                         //       ],
          //                                                         //     ),
          //                                                         //   ],
          //                                                         // ),
          //                                                         // const SizedBox(
          //                                                         //   height: 8,
          //                                                         // ),
          //                                                         Row(
          //                                                           children: [
          //                                                             Row(
          //                                                               children: [
          //                                                                 Icon(
          //                                                                   Icons.speed,
          //                                                                   size:
          //                                                                       18,
          //                                                                   color: widget.darkMode
          //                                                                       ? whiteColorDarkMode
          //                                                                       : null,
          //                                                                 ),
          //                                                                 const SizedBox(
          //                                                                     width: 5),
          //                                                                 Text(
          //                                                                   '${vehicleList[index].speed.toString()} km/h',
          //                                                                   style:
          //                                                                       bold.copyWith(
          //                                                                     fontSize: 8,
          //                                                                     color: widget.darkMode ? whiteColorDarkMode : blackSecondary1,
          //                                                                   ),
          //                                                                 ),
          //                                                                 const SizedBox(
          //                                                                   width:
          //                                                                       11,
          //                                                                 ),
          //                                                               ],
          //                                                             ),
          //                                                             Row(
          //                                                               children: [
          //                                                                 Icon(
          //                                                                   Icons.info_outline_rounded,
          //                                                                   size:
          //                                                                       18,
          //                                                                   color: vehicleList[index].alert == '-' || vehicleList[index].alert == '0' || vehicleList[index].alert == ''
          //                                                                       ? vehicleList[index].status.toLowerCase() == 'online'
          //                                                                           ? bluePrimary
          //                                                                           : vehicleList[index].status.toLowerCase() == 'lost'
          //                                                                               ? yellowPrimary
          //                                                                               : vehicleList[index].status.toLowerCase() == 'alarm'
          //                                                                                   ? redPrimary
          //                                                                                   : blackPrimary
          //                                                                       : redPrimary,
          //                                                                 ),
          //                                                                 const SizedBox(
          //                                                                   width:
          //                                                                       5,
          //                                                                 ),
          //                                                                 //belum ada status kendaraan
          //                                                                 Text(
          //                                                                   vehicleList[index].alert == '-' || vehicleList[index].alert == '0' || vehicleList[index].alert == ''
          //                                                                       ? vehicleList[index].status == 'Stop'
          //                                                                           ? AppLocalizations.of(context)!.stop
          //                                                                           : vehicleList[index].status == 'Parking'
          //                                                                               ? AppLocalizations.of(context)!.park
          //                                                                               : vehicleList[index].status == 'Lost'
          //                                                                                   ? AppLocalizations.of(context)!.lost
          //                                                                                   : vehicleList[index].status == 'Online'
          //                                                                                       ? AppLocalizations.of(context)!.moving
          //                                                                                       : ''
          //                                                                       : vehicleList[index].alert,
          //                                                                   style: bold.copyWith(
          //                                                                       fontSize: 8,
          //                                                                       // color: _colorCondition(
          //                                                                       //   vehicleList[index].status,
          //                                                                       // ),
          //                                                                       color: vehicleList[index].alert == '-' || vehicleList[index].alert == '0' || vehicleList[index].alert == ''
          //                                                                           ? vehicleList[index].status.toLowerCase() == 'online'
          //                                                                               ? bluePrimary
          //                                                                               : vehicleList[index].status.toLowerCase() == 'lost'
          //                                                                                   ? yellowPrimary
          //                                                                                   : vehicleList[index].status.toLowerCase() == 'alarm'
          //                                                                                       ? redPrimary
          //                                                                                       : blackPrimary
          //                                                                           : redPrimary),
          //                                                                 ),
          //                                                               ],
          //                                                             ),
          //                                                           ],
          //                                                         ),
          //                                                         const SizedBox(
          //                                                           height: 10,
          //                                                         ),
          //                                                         Row(
          //                                                           children: [
          //                                                             Row(
          //                                                               children: [
          //                                                                 //belum ada pulsa package
          //                                                                 Text(
          //                                                                   '${AppLocalizations.of(context)!.subscriptionEnded} :',
          //                                                                   style:
          //                                                                       reguler.copyWith(
          //                                                                     fontSize: 9,
          //                                                                     color: now < pulsaExpired
          //                                                                         ? vehicleList[index].sevenDays
          //                                                                             ? yellowPrimary
          //                                                                             : widget.darkMode
          //                                                                                 ? whiteColorDarkMode
          //                                                                                 : blackSecondary2
          //                                                                         : redPrimary,
          //                                                                   ),
          //                                                                 ),
          //                                                                 const SizedBox(
          //                                                                   width:
          //                                                                       2,
          //                                                                 ),
          //                                                                 Text(
          //                                                                   dateFormatPulsaPackage,
          //                                                                   style:
          //                                                                       reguler.copyWith(
          //                                                                     fontSize: 9,
          //                                                                     color: now < pulsaExpired
          //                                                                         ? vehicleList[index].sevenDays
          //                                                                             ? yellowPrimary
          //                                                                             : widget.darkMode
          //                                                                                 ? whiteColorDarkMode
          //                                                                                 : blackSecondary2
          //                                                                         : redPrimary,
          //                                                                   ),
          //                                                                 ),
          //                                                               ],
          //                                                             )
          //                                                           ],
          //                                                         ),
          //                                                         // const SizedBox(
          //                                                         //   height: 10,
          //                                                         // ),
          //                                                       ],
          //                                                     ),
          //                                                   ),
          //                                                   appDir is Directory
          //                                                       ? Image.file(
          //                                                           File(vehicleList[index].status.toLowerCase() ==
          //                                                                   'stop'
          //                                                               ? '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_parking.png'
          //                                                               : vehicleList[index].status.toLowerCase() ==
          //                                                                       'online'
          //                                                                   ? '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_accOn.png'
          //                                                                   : '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_${vehicleList[index].status.toLowerCase()}.png'),
          //                                                           width: 75,
          //                                                           height: 75,
          //                                                         )
          //                                                       : const Padding(
          //                                                           padding: EdgeInsets.only(
          //                                                               bottom:
          //                                                                   5),
          //                                                           child:
          //                                                               SkeletonAvatar(
          //                                                             style: SkeletonAvatarStyle(
          //                                                                 shape: BoxShape
          //                                                                     .rectangle,
          //                                                                 width:
          //                                                                     75,
          //                                                                 height:
          //                                                                     70),
          //                                                           ),
          //                                                         )
          //                                                 ],
          //                                               ),
          //                                               Divider(
          //                                                 height: 2,
          //                                                 thickness: 1,
          //                                                 indent: 0,
          //                                                 endIndent: 0,
          //                                                 color: widget.darkMode
          //                                                     ? whiteColorDarkMode
          //                                                     : greyColor,
          //                                               ),
          //                                               const SizedBox(
          //                                                 height: 10,
          //                                               ),
          //                                               Visibility(
          //                                                   visible: localData
          //                                                               .Username ==
          //                                                           'demo'
          //                                                       ? false
          //                                                       : true,
          //                                                   child: Row(
          //                                                     mainAxisAlignment:
          //                                                         MainAxisAlignment
          //                                                             .center,
          //                                                     children: [
          //                                                       AddPackage(
          //                                                         gsmNumber:
          //                                                             vehicleList[
          //                                                                     index]
          //                                                                 .gsmNo,
          //                                                         packageEnds:
          //                                                             dateFormatPulsaPackageAddCart,
          //                                                         deviceName: vehicleList[
          //                                                                 index]
          //                                                             .deviceName,
          //                                                         domain: '',
          //                                                         fullName:
          //                                                             localData
          //                                                                 .Fullname,
          //                                                         userName:
          //                                                             localData
          //                                                                 .Username,
          //                                                         darkMode: widget
          //                                                             .darkMode,
          //                                                       ),
          //                                                     ],
          //                                                   ))
          //                                             ],
          //                                           ),
          //                                         ),
          //                                       ),
          //                                     );
          //                                   },
          //                                 ));
          //                           }
          //                         }
          //                       }
          //                       //skeleton
          //                       return ListView.builder(
          //                           scrollDirection: Axis.vertical,
          //                           itemCount: 5,
          //                           itemBuilder: (context, index) {
          //                             return Card(
          //                                 margin: const EdgeInsets.only(
          //                                   bottom: 20,
          //                                 ),
          //                                 child: SizedBox(
          //                                   height: 121,
          //                                   child: SkeletonTheme(
          //                                       themeMode: widget.darkMode
          //                                           ? ThemeMode.dark
          //                                           : ThemeMode.light,
          //                                       child: const SkeletonAvatar(
          //                                         style: SkeletonAvatarStyle(
          //                                             shape: BoxShape.rectangle,
          //                                             width: 140,
          //                                             height: 30),
          //                                       )),
          //                                 ));
          //                           });
          //                     }),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ])
          ),
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
    );
  }

  @override
  void dispose() {
    //store cart disini
    // _timer.isActive ? _timer.cancel() : {};
    super.dispose();
  }
}

Future<List<Vehicle>> fetchData() async {
  final url = await rootBundle.loadString('json/vehiclelist.json');
  final jsonData = json.decode(url) as List<dynamic>;
  final list = jsonData.map((e) => Vehicle.fromJson(e)).toList();
  return list;
}


// https://iothub.gps.id/media/live/$cam/${widget.imei}.flv