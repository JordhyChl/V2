// ignore_for_file: avoid_print, use_build_context_synchronously, must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

class SearchVehicle extends StatefulWidget {
  bool darkMode;
  SearchVehicle({super.key, required this.darkMode});

  @override
  State<SearchVehicle> createState() => SearchVehicleState();
}

class SearchVehicleState extends State<SearchVehicle>
    with TickerProviderStateMixin {
  int current = 0;
  TextEditingController searchField = TextEditingController();
  List<String> sort = [];
  bool _isError = false;
  late Future<dynamic> _getVehicleList;
  late List<ResultVehicleList> sortVehicleList;
  late List<ResultVehicleList> initVehicleList;
  // late List<ResultVehicleList> vehicleList;
  List<ResultVehicleList> vehicleList = [];
  int page = 1;
  int perPage = 25;
  bool loadmoreBtn = true;
  bool loadmoreBtnPressed = false;
  int totalData = 0;
  int currentData = 0;
  late LocalData localData;
  dynamic appDir;
  // bool darkMode = false;

  // List<Widget> pages = [
  //   VehicleCard(VehicleModel(apiURL: '')),
  //   VehicleCard(VehicleModel(apiURL: 'status=bergerak')),
  //   VehicleCard(VehicleModel(apiURL: 'status=parkir')),
  //   VehicleCard(VehicleModel(apiURL: 'status=berhenti')),
  // ];
  @override
  void initState() {
    super.initState();
    _getVehicleList = getVehicleList();
    getDir();
  }

  getDir() async {
    appDir = await path_provider.getApplicationDocumentsDirectory();
  }

  Future<dynamic> getVehicleList() async {
    localData = await GeneralService().readLocalUserStorage();
    final result = await APIService().getVehicleList(page, perPage);
    if (result is ErrorTrapModel) {
      setState(() {
        // initPlatformState();
      });
    } else {
      setState(() {
        totalData = result.data.totalAllData;
        currentData = result.data.result.length;
        // if (totalData > currentData) {
        //   setState(() {
        //     loadmoreBtn = true;
        //   });
        // } else {
        //   setState(() {
        //     loadmoreBtn = false;
        //   });
        // }
        // sort = [
        //   AppLocalizations.of(context)!.all,
        //   AppLocalizations.of(context)!.moving,
        //   AppLocalizations.of(context)!.park,
        //   AppLocalizations.of(context)!.stop,
        //   AppLocalizations.of(context)!.lost,
        // ];
      });
      // refresh ? refreshList = false : {};
      // refresh ? initVehicleList.clear() : {};
    }
    return result;
  }

  doSearch(String value) async {
    localData = await GeneralService().readLocalUserStorage();
    if (searchField.text.isNotEmpty) {
      Dialogs().loadingDialog(context);
      // vehicleList.clear();
      final result = await APIService().searchVehicle(value);
      if (result is ErrorTrapModel) {
        setState(() {
          _isError = true;
          FocusManager.instance.primaryFocus?.unfocus();
        });
        Dialogs().hideLoaderDialog(context);
      }
      if (result == null) {
        // showInfo(context);
        setState(() {
          _isError = true;
          FocusManager.instance.primaryFocus?.unfocus();
        });
        Dialogs().hideLoaderDialog(context);
      } else {
        setState(() {
          _isError = false;
          vehicleList.clear();
          vehicleList.addAll(result.data.result);
          FocusManager.instance.primaryFocus?.unfocus();
        });
        Dialogs().hideLoaderDialog(context);
      }
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
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
                      AppLocalizations.of(context)!.searchVehicle,
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
            // Text(
            //   '${AppLocalizations.of(context)!.showing} $currentData ${AppLocalizations.of(context)!.ofs} $totalData ${AppLocalizations.of(context)!.yourVehicle}',
            //   style: reguler.copyWith(
            //     fontSize: 12,
            //   ),
            // ),
            const SizedBox(
              height: 8,
            ),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: searchField,
                textAlign: TextAlign.start,
                textInputAction: TextInputAction.search,
                autofocus: true,
                onSubmitted: (value) {
                  doSearch(searchField.text);
                },
                // textAlignVertical: TextAlignVertical.bottom,
                style: bold.copyWith(
                    fontSize: 10,
                    color:
                        widget.darkMode ? whiteColorDarkMode : blackSecondary2),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12),
                    enabled: true,
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
                    suffixIcon: InkWell(
                      onTap: () {
                        doSearch(searchField.text);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/search.png',
                          color: widget.darkMode ? whiteColorDarkMode : null,
                        ),
                      ),
                    )),
              ),
            )
          ],
        ),
        backgroundColor: bluePrimary,
      ),
      body: _isError
          ? Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/handling/stopreport_empty.png',
                      height: 240,
                      width: 240,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 50, right: 50, top: 10),
                      child: Text(
                        AppLocalizations.of(context)!.searchEmpty,
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
                      padding:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: Text(
                        AppLocalizations.of(context)!.searchEmptySub,
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
            )
          : Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              // width: double.infinity,
              child: FutureBuilder(
                future: _getVehicleList,
                builder:
                    (BuildContext contxt, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data is ErrorTrapModel) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          // await doRefresh();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
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
                          },
                        ),
                      );
                    } else {
                      vehicleList = snapshot.data.data.result;
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: vehicleList.length,
                        itemBuilder: (context, index) {
                          DateTime? pulsaPackage =
                              DateTime.parse(vehicleList[index].expiredDate);
                          DateTime? lastUpdate =
                              DateTime.parse(vehicleList[index].lastData)
                                  .toLocal();
                          String dateFormatPulsaPackage = DateFormat('y-MM-dd')
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
                          int pulsaExpired = int.parse(getPulsaExpired);
                          int now = int.parse(getNow);
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleDetail(
                                    icon: vehicleList[index].icon,
                                    imei: vehicleList[index].imei,
                                    expDate: vehicleList[index].expiredDate,
                                    deviceName: vehicleList[index].deviceName,
                                    gpsType: vehicleList[index].gpsName,
                                    vehStatus: vehicleList[index].status,
                                    darkMode: widget.darkMode,
                                  ),
                                ),
                              );
                              if (vehicleList[index].status.toLowerCase() ==
                                  'lost') {
                                lostAlert(
                                    context,
                                    localData.Username,
                                    AppLocalizations.of(context)!.lostTitle,
                                    AppLocalizations.of(context)!.lostSubTitle,
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
                                            : blackPrimary.withOpacity(0.12),
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ],
                                  border: Border.all(
                                      width: 1,
                                      color: widget.darkMode
                                          ? whiteCardColor
                                          : greyColor),
                                  borderRadius: BorderRadius.circular(8)),
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
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${AppLocalizations.of(context)!.lastUpdate}: ',
                                                  style: reguler.copyWith(
                                                    fontSize: 9,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary2,
                                                  ),
                                                ),
                                                Text(
                                                  dateFormatLastUpdate,
                                                  style: reguler.copyWith(
                                                      fontSize: 9,
                                                      color: widget.darkMode
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
                                                CrossAxisAlignment.start,
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
                                                        Icons.speed,
                                                        size: 18,
                                                        color: widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : null,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        '${vehicleList[index].speed.toString()} km/h',
                                                        style: bold.copyWith(
                                                          fontSize: 8,
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
                                                        color: vehicleList[
                                                                            index]
                                                                        .alert ==
                                                                    '-' ||
                                                                vehicleList[index]
                                                                        .alert ==
                                                                    '0' ||
                                                                vehicleList[index]
                                                                        .alert ==
                                                                    ''
                                                            ? vehicleList[index]
                                                                        .status
                                                                        .toLowerCase() ==
                                                                    'online'
                                                                ? bluePrimary
                                                                : vehicleList[index]
                                                                            .status
                                                                            .toLowerCase() ==
                                                                        'lost'
                                                                    ? yellowPrimary
                                                                    : vehicleList[index].status.toLowerCase() ==
                                                                            'alarm'
                                                                        ? redPrimary
                                                                        : widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : blackPrimary
                                                            : redPrimary,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      //belum ada status kendaraan
                                                      Text(
                                                        vehicleList[index]
                                                                        .alert ==
                                                                    '-' ||
                                                                vehicleList[index]
                                                                        .alert ==
                                                                    '0' ||
                                                                vehicleList[index]
                                                                        .alert ==
                                                                    ''
                                                            ? vehicleList[index]
                                                                        .status ==
                                                                    'Stop'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .stop
                                                                : vehicleList[index]
                                                                            .status ==
                                                                        'Parking'
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .park
                                                                    : vehicleList[index].status ==
                                                                            'Lost'
                                                                        ? AppLocalizations.of(context)!
                                                                            .lost
                                                                        : vehicleList[index].status ==
                                                                                'Online'
                                                                            ? AppLocalizations.of(context)!
                                                                                .moving
                                                                            : ''
                                                            : vehicleList[index]
                                                                .alert,
                                                        style: bold.copyWith(
                                                            fontSize: 8,
                                                            // color: _colorCondition(
                                                            //   vehicleList[index].status,
                                                            // ),
                                                            color: vehicleList[
                                                                                index]
                                                                            .alert ==
                                                                        '-' ||
                                                                    vehicleList[index]
                                                                            .alert ==
                                                                        '0' ||
                                                                    vehicleList[index]
                                                                            .alert ==
                                                                        ''
                                                                ? vehicleList[index]
                                                                            .status
                                                                            .toLowerCase() ==
                                                                        'online'
                                                                    ? bluePrimary
                                                                    : vehicleList[index].status.toLowerCase() ==
                                                                            'lost'
                                                                        ? yellowPrimary
                                                                        : vehicleList[index].status.toLowerCase() ==
                                                                                'alarm'
                                                                            ? redPrimary
                                                                            : widget.darkMode
                                                                                ? whiteColorDarkMode
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
                                                        style: reguler.copyWith(
                                                          fontSize: 9,
                                                          color: now <
                                                                  pulsaExpired
                                                              ? vehicleList[
                                                                          index]
                                                                      .sevenDays
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
                                                        style: reguler.copyWith(
                                                          fontSize: 9,
                                                          color: now <
                                                                  pulsaExpired
                                                              ? vehicleList[
                                                                          index]
                                                                      .sevenDays
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
                                                File(vehicleList[index]
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
                                                    EdgeInsets.only(bottom: 5),
                                                child: SkeletonAvatar(
                                                  style: SkeletonAvatarStyle(
                                                      shape: BoxShape.rectangle,
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
                                        visible: localData.Username == 'demo' ||
                                                vehicleList[index].imei ==
                                                    '123456'
                                            ? false
                                            : true,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AddPackage(
                                              gsmNumber:
                                                  vehicleList[index].gsmNo,
                                              packageEnds:
                                                  dateFormatPulsaPackageAddCart,
                                              deviceName:
                                                  vehicleList[index].deviceName,
                                              domain: '',
                                              fullName: localData.Fullname,
                                              userName: localData.Username,
                                              darkMode: widget.darkMode,
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
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
                },
              )),
    );
  }
}

Future<List<Vehicle>> fetchData() async {
  final url = await rootBundle.loadString('json/vehiclelist.json');
  final jsonData = json.decode(url) as List<dynamic>;
  final list = jsonData.map((e) => Vehicle.fromJson(e)).toList();
  return list;
}
