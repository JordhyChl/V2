// ignore_for_file: avoid_print, use_build_context_synchronously, unused_field, unused_local_variable, prefer_final_fields

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/detailAddCart.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/getpackage.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/vehicle.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/pages/topuphistory.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ChooseVehicle extends StatefulWidget {
  final bool darkMode;
  final bool fromClara;
  const ChooseVehicle({
    super.key,
    required this.darkMode,
    required this.fromClara,
  });

  @override
  State<ChooseVehicle> createState() => ChooseVehicleState();
}

class ChooseVehicleState extends State<ChooseVehicle>
    with TickerProviderStateMixin {
  int current = 0;
  bool _isData = true;
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
  // int selected = 0;
  int selectAll = 0;
  bool showSelectAll = false;
  int totalUnit = 0;
  late GetPackageModel getPackageModel;
  int select = 0;

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

  Future<dynamic> getPackage(String gsm) async {
    // final result = await APIService().getPackage();
    int count = 0;
    int dashcamCount = 0;
    Dialogs().loadingDialog(context);
    for (var el in vehicleList) {
      if (el.isSelected) {
        count++;
        if (el.isDashcam) {
          dashcamCount++;
          setState(() {
            gsm = el.gsmNo;
          });
        }
      }
    }
    if (gsm.isNotEmpty && count > 1) {
      if (dashcamCount > 1) {
        final result = await APIService().getPackage(gsm);
        Dialogs().hideLoaderDialog(context);
        if (result is ErrorTrapModel) {
          showInfoAlert(context, result.statusError, '');
        }
        if (result is GetPackageModel) {
          setState(() {
            getPackageModel = result;
          });
          if (getPackageModel is MessageModel) {
            showInfoAlert(context, getPackageModel.message, '');
          } else {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
              ),
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      width: double.infinity,
                      height: 350,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              AppLocalizations.of(context)!.choosePackage,
                              style: bold.copyWith(
                                fontSize: 14,
                                color: blackSecondary1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              height: 2,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                              color: greyColor,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ),
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount:
                                          getPackageModel.data.results.length,
                                      itemBuilder: (context, indexPackage) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              setState(
                                                () {
                                                  // select = indexPackage + 1;
                                                  select = getPackageModel.data
                                                      .results[indexPackage].id;
                                                },
                                              );
                                              if (totalUnit != 0) {
                                                List<DetailsCart> addToCart =
                                                    [];
                                                for (var el in vehicleList) {
                                                  if (el.isSelected) {
                                                    addToCart.add(DetailsCart(
                                                        vehicle:
                                                            VehicleAddToCart(
                                                                plate: el.plate,
                                                                sim: el.gsmNo),
                                                        topupPack: select));
                                                  }
                                                }
                                                Dialogs()
                                                    .loadingDialog(context);
                                                final result =
                                                    await APIService()
                                                        .addCartV2(addToCart);
                                                if (result is ErrorTrapModel) {
                                                  Navigator.pop(context);
                                                  print(result);
                                                }
                                                if (result is MessageModel) {
                                                  if (result.message ==
                                                      'successfully added to cart') {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    print(result);
                                                    print(
                                                        'Test add cart : ${json.encode(addToCart)}');
                                                    totalUnit == 0
                                                        ? {}
                                                        : showModalBottomSheet(
                                                            backgroundColor:
                                                                whiteCardColor,
                                                            isScrollControlled:
                                                                true,
                                                            isDismissible: true,
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12)),
                                                            ),
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return StatefulBuilder(builder:
                                                                  (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setStateModal) {
                                                                return SingleChildScrollView(
                                                                  child:
                                                                      Container(
                                                                    padding: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          20.0),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  size: 30,
                                                                                  color: widget.darkMode ? whiteColorDarkMode : null,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Column(
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/cart.png',
                                                                                width: 120,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                                                child: SizedBox(
                                                                                  width: 200,
                                                                                  child: Text(
                                                                                    AppLocalizations.of(context)!.addToCartSuccess,
                                                                                    style: bold.copyWith(
                                                                                      fontSize: 12,
                                                                                      color: blackPrimary,
                                                                                    ),
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  decoration: BoxDecoration(
                                                                                    color: whiteColor,
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    border: Border.all(
                                                                                      width: 1,
                                                                                      color: bluePrimary,
                                                                                    ),
                                                                                  ),
                                                                                  child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                                                      child: Text(AppLocalizations.of(context)!.seeCart, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                            });
                                                  } else {
                                                    if (result.status) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/editprofile');
                                                      await showInfoAlert(
                                                          context,
                                                          result.message,
                                                          '');

                                                      print(result);
                                                    } else {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      showInfoAlert(context,
                                                          result.message, '');

                                                      print(result);
                                                    }
                                                  }
                                                } else {
                                                  Navigator.pop(context);
                                                  showInfoAlert(context,
                                                      result.message, '');
                                                  print(result);
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 5),
                                              width: width,
                                              // height: 60,
                                              decoration: BoxDecoration(
                                                // color: whiteCardColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  width: 1,
                                                  color: select ==
                                                          getPackageModel
                                                              .data
                                                              .results[
                                                                  indexPackage]
                                                              .id
                                                      ? bluePrimary
                                                      : greyColor,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    getPackageModel
                                                        .data
                                                        .results[indexPackage]
                                                        .packName,
                                                    style: reguler.copyWith(
                                                      fontSize: 14,
                                                      color: select ==
                                                              getPackageModel
                                                                  .data
                                                                  .results[
                                                                      indexPackage]
                                                                  .id
                                                          ? bluePrimary
                                                          : blackSecondary3,
                                                    ),
                                                  ),
                                                  getPackageModel
                                                              .data
                                                              .results[
                                                                  indexPackage]
                                                              .isPromo ==
                                                          1
                                                      ? Container(
                                                          // width: 40,
                                                          // height: 10,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                blueSecondary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                offset: Offset(
                                                                    0.0, 3),
                                                                blurRadius: 5.0,
                                                              ),
                                                            ],
                                                          ),
                                                          // width: 40,
                                                          // height: 10,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 12,
                                                                    right: 12),
                                                            child: Text(
                                                              'Promo',
                                                              style: bold.copyWith(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  Text(
                                                    NumberFormat.currency(
                                                      locale: 'id',
                                                      decimalDigits: 0,
                                                      symbol: 'Rp. ',
                                                    ).format(
                                                      int.parse(getPackageModel
                                                          .data
                                                          .results[indexPackage]
                                                          .price
                                                          .toString()),
                                                    ),
                                                    style: reguler.copyWith(
                                                      fontSize: 14,
                                                      color: select ==
                                                              getPackageModel
                                                                  .data
                                                                  .results[
                                                                      indexPackage]
                                                                  .id
                                                          ? bluePrimary
                                                          : blackSecondary3,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        }
        if (result is MessageModel) {
          showInfoAlert(context, result.message, '');
        } else {
          print(result);
        }
        return result;
      } else {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(
            context,
            'Kamu tidak bisa menambahkan unit ke keranjang dengan kategori unit yang berbeda',
            '');
      }
    } else {
      final result = await APIService().getPackage(gsm);
      Dialogs().hideLoaderDialog(context);
      if (result is ErrorTrapModel) {
        showInfoAlert(context, result.statusError, '');
      }
      if (result is GetPackageModel) {
        setState(() {
          getPackageModel = result;
        });
        if (getPackageModel is MessageModel) {
          showInfoAlert(context, getPackageModel.message, '');
        } else {
          showModalBottomSheet(
            backgroundColor: whiteCardColor,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: double.infinity,
                    height: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            AppLocalizations.of(context)!.choosePackage,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            height: 2,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                            color: greyColor,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(
                                20,
                              ),
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount:
                                        getPackageModel.data.results.length,
                                    itemBuilder: (context, indexPackage) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: GestureDetector(
                                          onTap: () async {
                                            setState(
                                              () {
                                                // select = indexPackage + 1;
                                                select = getPackageModel.data
                                                    .results[indexPackage].id;
                                              },
                                            );
                                            if (totalUnit != 0) {
                                              List<DetailsCart> addToCart = [];
                                              for (var el in vehicleList) {
                                                if (el.isSelected) {
                                                  addToCart.add(DetailsCart(
                                                      vehicle: VehicleAddToCart(
                                                          plate: el.plate,
                                                          sim: el.gsmNo),
                                                      topupPack: select));
                                                }
                                              }
                                              Dialogs().loadingDialog(context);
                                              final result = await APIService()
                                                  .addCartV2(addToCart);
                                              if (result is ErrorTrapModel) {
                                                Navigator.pop(context);
                                                print(result);
                                              }
                                              if (result is MessageModel) {
                                                if (result.message ==
                                                    'successfully added to cart') {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  print(result);
                                                  print(
                                                      'Test add cart : ${json.encode(addToCart)}');
                                                  totalUnit == 0
                                                      ? {}
                                                      : showModalBottomSheet(
                                                          backgroundColor:
                                                              whiteCardColor,
                                                          isScrollControlled:
                                                              true,
                                                          isDismissible: true,
                                                          shape:
                                                              const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        12),
                                                                topRight: Radius
                                                                    .circular(
                                                                        12)),
                                                          ),
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setStateModal) {
                                                              return SingleChildScrollView(
                                                                child:
                                                                    Container(
                                                                  padding: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        20.0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                size: 30,
                                                                                color: widget.darkMode ? whiteColorDarkMode : null,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          children: [
                                                                            Image.asset(
                                                                              'assets/cart.png',
                                                                              width: 120,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 15),
                                                                              child: SizedBox(
                                                                                width: 200,
                                                                                child: Text(
                                                                                  AppLocalizations.of(context)!.addToCartSuccess,
                                                                                  style: bold.copyWith(
                                                                                    fontSize: 12,
                                                                                    color: blackPrimary,
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                if (widget.fromClara) {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => HomePage(
                                                                                                selected: 3,
                                                                                                darkMode: widget.darkMode,
                                                                                                secondAccess: true,
                                                                                              )));
                                                                                } else {
                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                }
                                                                                // Navigator.pop(context);
                                                                                // Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: whiteColor,
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                  border: Border.all(
                                                                                    width: 1,
                                                                                    color: bluePrimary,
                                                                                  ),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                                                    child: Text(AppLocalizations.of(context)!.seeCart, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          });
                                                } else {
                                                  if (result.status) {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Navigator.pushNamed(context,
                                                        '/editprofile');
                                                    await showInfoAlert(context,
                                                        result.message, '');

                                                    print(result);
                                                  } else {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    showInfoAlert(context,
                                                        result.message, '');

                                                    print(result);
                                                  }
                                                }
                                              } else {
                                                Navigator.pop(context);
                                                showInfoAlert(context,
                                                    result.message, '');
                                                print(result);
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 5),
                                            width: width,
                                            // height: 60,
                                            decoration: BoxDecoration(
                                              // color: whiteCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                width: 1,
                                                color: select ==
                                                        getPackageModel
                                                            .data
                                                            .results[
                                                                indexPackage]
                                                            .id
                                                    ? bluePrimary
                                                    : greyColor,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  getPackageModel
                                                      .data
                                                      .results[indexPackage]
                                                      .packName,
                                                  style: reguler.copyWith(
                                                    fontSize: 14,
                                                    color: select ==
                                                            getPackageModel
                                                                .data
                                                                .results[
                                                                    indexPackage]
                                                                .id
                                                        ? bluePrimary
                                                        : widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary3,
                                                  ),
                                                ),
                                                getPackageModel
                                                            .data
                                                            .results[
                                                                indexPackage]
                                                            .isPromo ==
                                                        1
                                                    ? Container(
                                                        // width: 40,
                                                        // height: 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: blueSecondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              offset: Offset(
                                                                  0.0, 3),
                                                              blurRadius: 5.0,
                                                            ),
                                                          ],
                                                        ),
                                                        // width: 40,
                                                        // height: 10,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 12,
                                                                  right: 12),
                                                          child: Text(
                                                            'Promo',
                                                            style: bold.copyWith(
                                                                color: widget
                                                                        .darkMode
                                                                    ? whiteColorDarkMode
                                                                    : whiteColor,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                Text(
                                                  NumberFormat.currency(
                                                    locale: 'id',
                                                    decimalDigits: 0,
                                                    symbol: 'Rp. ',
                                                  ).format(
                                                    int.parse(getPackageModel
                                                        .data
                                                        .results[indexPackage]
                                                        .price
                                                        .toString()),
                                                  ),
                                                  style: reguler.copyWith(
                                                    fontSize: 14,
                                                    color: select ==
                                                            getPackageModel
                                                                .data
                                                                .results[
                                                                    indexPackage]
                                                                .id
                                                        ? bluePrimary
                                                        : widget.darkMode
                                                            ? whiteColorDarkMode
                                                            : blackSecondary3,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
      }
      if (result is MessageModel) {
        showInfoAlert(context, result.message, '');
      } else {
        print(result);
      }
      return result;
    }
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
        result.data.totalAllData >= 1
            ? showSelectAll = true
            : showSelectAll = false;
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
          toolbarHeight: 143,
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
                        AppLocalizations.of(context)!.chooseVehicle,
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
              // Text(
              //   '${AppLocalizations.of(context)!.showing} $totalData ${AppLocalizations.of(context)!.ofs} ${AppLocalizations.of(context)!.yourVehicle}',
              //   style: reguler.copyWith(
              //     fontSize: 12,
              //   ),
              // ),
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
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height / 12,
          decoration: BoxDecoration(
            color: widget.darkMode ? whiteCardColor : whiteColor,
            boxShadow: [
              BoxShadow(
                  color: widget.darkMode ? whiteCardColor : greyColor,
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalUnit,
                      style: reguler.copyWith(
                          color: widget.darkMode
                              ? whiteColorDarkMode
                              : blackSecondary3,
                          fontSize: 10),
                    ),
                    Text(
                      totalUnit == 0 ? '-' : totalUnit.toString(),
                      style: reguler.copyWith(
                          color: widget.darkMode
                              ? whiteColorDarkMode
                              : blackSecondary1,
                          fontSize: 16),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    await getPackage('');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 42,
                        decoration: BoxDecoration(
                          color: totalUnit == 0
                              ? widget.darkMode
                                  ? whiteColor
                                  : greyColorSecondary
                              : bluePrimary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                            color: totalUnit == 0
                                ? widget.darkMode
                                    ? whiteColor
                                    : greyColorSecondary
                                : bluePrimary,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              '+ ${AppLocalizations.of(context)!.addCart}',
                              style: reguler.copyWith(
                                  color:
                                      widget.darkMode ? greyColor : whiteColor,
                                  fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: Column(children: [
          Visibility(
            visible: showSelectAll,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 5, left: 21),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectAll == 0 ? selectAll = 1 : selectAll = 0;
                          for (var el in vehicleList) {
                            selectAll == 0
                                ? el.isSelected = false
                                : el.isSelected = true;
                          }
                          selectAll == 0
                              ? totalUnit = 0
                              : totalUnit = vehicleList.length;
                          print(vehicleList);
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 1,
                            color: selectAll == 1
                                ? bluePrimary
                                : greyColorSecondary,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: selectAll == 1 ? bluePrimary : null,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(AppLocalizations.of(context)!.selectAll,
                        style: reguler.copyWith(
                            color: widget.darkMode
                                ? whiteColorDarkMode
                                : blackSecondary3,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
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
                              : whiteCardColor,
                          border: Border.all(
                            width: 1,
                            color: widget.darkMode
                                ? Colors.transparent
                                : current == index
                                    ? index == 0
                                        ? blueGradient
                                        : index == 1
                                            ? yellowPrimary
                                            : index == 2
                                                ? redPrimary
                                                : blueGradient
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
                                      ? widget.darkMode
                                          ? whiteColorDarkMode
                                          : whiteColor
                                      : index == 1
                                          ? widget.darkMode
                                              ? whiteColorDarkMode
                                              : whiteColor
                                          : index == 2
                                              ? widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : whiteColor
                                              : whiteColor
                                  : blackSecondary3,
                            ),
                          ),
                        ),
                      ),
                    );
                  })),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  FutureBuilder(
                      future: _getVehicleList,
                      builder: (BuildContext contxt,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data is ErrorTrapModel) {
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
                                    String isExpired = DateFormat('Y-MM-dd')
                                        .format(DateTime.now());
                                    String dateFormatPulsaPackage =
                                        DateFormat('dd MMM yyyy')
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
                                        setState(() {
                                          vehicleList[index].isSelected
                                              ? vehicleList[index].isSelected =
                                                  false
                                              : vehicleList[index].isSelected =
                                                  true;
                                          vehicleList[index].isSelected
                                              ? totalUnit++
                                              : totalUnit--;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 1),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5),
                                              child: SizedBox(
                                                width: 24,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      // vehicleList[index].isSelected = true;
                                                      vehicleList[index]
                                                              .isSelected
                                                          ? vehicleList[index]
                                                                  .isSelected =
                                                              false
                                                          : vehicleList[index]
                                                                  .isSelected =
                                                              true;
                                                      vehicleList[index]
                                                              .isSelected
                                                          ? totalUnit++
                                                          : totalUnit--;
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: vehicleList[
                                                                      index]
                                                                  .isSelected
                                                              ? bluePrimary
                                                              : greyColorSecondary),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        width: 14,
                                                        height: 14,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: vehicleList[
                                                                      index]
                                                                  .isSelected
                                                              ? bluePrimary
                                                              : null,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                  color: widget.darkMode
                                                      ? whiteCardColor
                                                      : whiteColor,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: widget.darkMode
                                                            ? whiteCardColor
                                                            : greyColor
                                                                .withOpacity(
                                                                    0.12),
                                                        spreadRadius: 0,
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2))
                                                  ],
                                                  border: Border.all(
                                                      width: 1,
                                                      color: vehicleList[index]
                                                              .isSelected
                                                          ? bluePrimary
                                                          : widget.darkMode
                                                              ? whiteCardColor
                                                              : greyColorSecondary),
                                                  // selected == index
                                                  //     ? bluePrimary
                                                  //     : greyColorSecondary),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      appDir is Directory
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 5),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    6,
                                                                child:
                                                                    Image.file(
                                                                  File(vehicleList[index]
                                                                              .status
                                                                              .toLowerCase() ==
                                                                          'stop'
                                                                      ? '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_parking.png'
                                                                      : vehicleList[index].status.toLowerCase() ==
                                                                              'online'
                                                                          ? '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_accOn.png'
                                                                          : '${appDir.path}/localAssetType/${vehicleList[index].vehType.toLowerCase()}_${vehicleList[index].status.toLowerCase()}.png'),
                                                                  width: 75,
                                                                  height: 75,
                                                                ),
                                                              ),
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
                                                            ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3.5,
                                                              child: Flex(
                                                                direction: Axis
                                                                    .vertical,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    vehicleList[
                                                                            index]
                                                                        .deviceName,
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: bold
                                                                        .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary1,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    vehicleList[
                                                                            index]
                                                                        .gsmNo,
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: bold
                                                                        .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : blackSecondary3,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  5,
                                                              child: Flex(
                                                                direction: Axis
                                                                    .vertical,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width: 120,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: now <
                                                                              pulsaExpired
                                                                          ? vehicleList[index].sevenDays
                                                                              ? widget.darkMode
                                                                                  ? yellowPrimary
                                                                                  : yellowSecondary
                                                                              : null
                                                                          : widget.darkMode
                                                                              ? redPrimary
                                                                              : redSecondary,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        width:
                                                                            1,
                                                                        color: now <
                                                                                pulsaExpired
                                                                            ? vehicleList[index].sevenDays
                                                                                ? widget.darkMode
                                                                                    ? redPrimary
                                                                                    : yellowSecondary
                                                                                : Colors.transparent
                                                                            : widget.darkMode
                                                                                ? redPrimary
                                                                                : redSecondary,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                    ),
                                                                    child: Text(
                                                                      '${AppLocalizations.of(context)!.subscriptionEnded} :',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          2,
                                                                      style: reguler
                                                                          .copyWith(
                                                                        fontSize:
                                                                            10,
                                                                        color:
                                                                            blackPrimary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    dateFormatPulsaPackage,
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: bold
                                                                        .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                      color:
                                                                          blackPrimary,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
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
