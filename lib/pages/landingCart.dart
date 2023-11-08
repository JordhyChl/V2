// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, unnecessary_this, prefer_const_constructors, avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/getcart.model.dart';
import 'package:gpsid/model/getpackage.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/pendingtransaction.model.dart';
import 'package:gpsid/model/vehicle.dart';
import 'package:gpsid/pages/paymentmethod.dart';
import 'package:gpsid/pages/taxinvoice.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingCart extends StatefulWidget {
  final bool darkMode;
  const LandingCart({super.key, required this.darkMode});

  @override
  State<LandingCart> createState() => LandingCartState();
}

class LandingCartState extends State<LandingCart>
    with TickerProviderStateMixin {
  var size, height, width;
  int current = 0;
  TextEditingController suggestion = TextEditingController();
  List<String> page = [];
  int selected = 0;
  int selectedCart = 0;
  bool cartTapped = false;
  bool isCheck = false;
  int totalPrice = 0;
  int totalUnit = 0;

  late Future<dynamic> _getCart;
  late Future<dynamic> _getPending;
  late GetCartModel cartData;
  late PendingModel listPending;
  late GetPackageModel getPackageModel;
  int indexPackage = 0;
  String packName = '';
  bool loading = false;
  late LocalData localData;
  int selectAll = 0;
  bool showSelectAll = false;
  int totalUnitSelected = 0;
  dynamic appDir;
  Uint8List? conv;
  List<dynamic> idCart = [];
  int select = 0;
  bool thereIsPending = false;
  late LinkModel url;

  @override
  void initState() {
    super.initState();
    // _getVehicleList = getVehicleList();
    _getCart = getCart();
    _getPending = getPending();
    getDir();
    // _getPackage = getPackage();
  }

  getDir() async {
    appDir = await path_provider.getApplicationDocumentsDirectory();
  }

  Future<dynamic> getCart() async {
    url = await GeneralService().readLocalUrl();
    localData = await GeneralService().readLocalUserStorage();
    final result = await APIService().getCartV2();
    if (result is GetCartModel) {
      setState(() {
        loading = false;
      });
      print(result.status);
      idCart = [];
      selectAll = 0;
      totalUnitSelected = 0;
      selected = 0;
    } else {
      setState(() {
        loading = false;
      });
      print(result);
    }
    // await getPackage();
    return result;
  }

  Future<dynamic> getPending() async {
    setState(() {
      thereIsPending = false;
    });
    final res = await APIService().getPendingList();
    if (res is PendingModel) {
      setState(() {
        if (res.data.isEmpty) {
          thereIsPending = true;
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        thereIsPending = false;
      });
    }
    return res;
  }

  Future _doRefresh() async {
    if (this.mounted) {
      // await Dialogs().loadingDialog(context);
      setState(() {
        loading = true;
      });
      totalPrice = 0;
      _getCart = getCart();
      _getPending = getPending();
      // Future.delayed(const Duration(seconds: 1), () async {
      // await Dialogs().hideLoaderDialog(context);
      // setState(() {});
      // });
    }
  }

  Future _doRefreshIndicator() async {
    if (this.mounted) {
      // await Dialogs().loadingDialog(context);
      setState(() {
        loading = true;
      });
      totalPrice = 0;
      _getCart = getCart();
      _getPending = getPending();
      Future.delayed(const Duration(seconds: 1), () async {
        // await Dialogs().hideLoaderDialog(context);
        // setState(() {
        //   loading = false;
        // });
      });
    }
  }

  deleteCart(List<dynamic> cartID) async {
    Dialogs().loadingDialog(context);
    final result = await APIService().deleteCartV2(cartID);
    if (result is MessageModel) {
      if (result.status == true) {
        Navigator.pop(context);
        _doRefresh();
        print(idCart);
        // await Dialogs().hideLoaderDialog(context);
        // showSuccess(context, result.message);
      } else {
        Navigator.pop(context);
        // await Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.message, '');
      }
    } else {
      // await Dialogs().hideLoaderDialog(context);
      Navigator.pop(context);
      showInfoAlert(context, result, '');
    }
  }

  updatePack(int cartID, int packID) async {
    // Dialogs().showLoaderDialog(context);
    final result = await APIService().updateCart(cartID, packID);
    if (result is MessageModel) {
      if (result.status == true) {
        _doRefresh();
        setState(() {
          select = 0;
        });
        // await Dialogs().hideLoaderDialog(context);
        // showSuccess(context, result.message);
      } else {
        // await Dialogs().hideLoaderDialog(context);
        showSuccess(context, result.message);
        setState(() {
          select = 0;
        });
      }
    } else {
      // await Dialogs().hideLoaderDialog(context);
      showSuccess(context, result);
      setState(() {
        select = 0;
      });
    }
  }

  doCheckSelect(index) async {
    // vehicleList.forEach((el) {
    //   if (vehicleList[index] =) {

    //   }
    // });
    // if (isCheck) {
    //   isCheck[index] = false;
    //   index
    // } else {
    //   isCheck[index] = true;
    // }

    // if (vehicleListData[index].imei == imeiCheck) {
    //   setState(() {
    //     selectedCart = true;
    //   });
    // }
  }

  Future<dynamic> getPackage(String gsm) async {
    // final result = await APIService().getPackage();
    final result = await APIService().getPackage(gsm);
    if (result is ErrorTrapModel) {
      showInfoAlert(context, result.statusError, '');
    }
    if (result is GetPackageModel) {
      setState(() {
        getPackageModel = result;
      });
    } else {
      print(result);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: InkWell(
                onTap: () async {
                  await Navigator.pushNamed(context, '/transaction');
                  _doRefresh();
                },
                child: Image.asset(
                  'assets/icon/transaction.png',
                  width: 32,
                  height: 32,
                )),
          ),
        ],
        toolbarHeight: 65,
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
        centerTitle: true,
        title: Text(
          GeneralService()
              .setTitleCase(AppLocalizations.of(context)!.topupCart),
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: thereIsPending
                    ? EdgeInsets.only(top: 0)
                    : EdgeInsets.only(top: 10),
                child: FutureBuilder(
                  future: _getPending,
                  builder:
                      (BuildContext contxt, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data is ErrorTrapModel) {
                        return Container();
                      }
                      if (snapshot.data is MessageModel) {
                        _getCart = getCart();
                      } else {
                        listPending = snapshot.data;
                        if (listPending.data.isEmpty) {
                          return Container();
                        } else {
                          return Visibility(
                            visible: !loading,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: yellowSecondary,
                                  border: Border.all(
                                    width: 1,
                                    color: yellowSecondary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                        context, '/pendingpayment');
                                    _doRefresh();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          'assets/icon/pendingtransaction.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        Text(
                                          '${listPending.data.length} ${AppLocalizations.of(context)!.waitingTransaction}',
                                          style: reguler.copyWith(
                                              color: blackSecondary1,
                                              fontSize: 10),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    }
                    return Container();
                  },
                ),
              ),
              Expanded(
                  child: FutureBuilder(
                      future: _getCart,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (loading) {
                          return ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Card(
                                    margin: const EdgeInsets.all(15),
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
                        } else {
                          if (snapshot.hasData) {
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
                                                await _doRefreshIndicator();
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
                                              left: 50, right: 50, top: 10),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .error500,
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
                              }
                            }
                            if (snapshot.data is MessageModel) {
                              return RefreshIndicator(
                                  onRefresh: () async {
                                    await _doRefreshIndicator();
                                  },
                                  child: ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
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
                                                  'assets/handling/emptycart.png',
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
                                                        .emptyCart,
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
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          top: 10),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .emptyCartSub,
                                                    textAlign: TextAlign.center,
                                                    style: reguler.copyWith(
                                                      fontSize: 12,
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary2,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.2,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        // await Navigator.pushNamed(
                                                        //     context,
                                                        //     '/vehiclelist');
                                                        await Navigator.pushNamed(
                                                            context,
                                                            '/choosevehicletopup');
                                                        _doRefresh();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor: widget
                                                                      .darkMode
                                                                  ? whiteCardColor
                                                                  : whiteColor,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                side: BorderSide(
                                                                    color:
                                                                        blueGradient,
                                                                    width: 1),
                                                              ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .addUnit,
                                                        style: reguler.copyWith(
                                                          fontSize: 12,
                                                          color: blueGradient,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }));
                            } else {
                              cartData = snapshot.data;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          idCart = [];
                                          setState(() {
                                            totalPrice = 0;
                                            totalUnitSelected = 0;
                                            selectAll == 0
                                                ? selectAll = 1
                                                : selectAll = 0;
                                            for (var el
                                                in cartData.data.results) {
                                              if (el.isAvailable) {
                                                if (selectAll == 0) {
                                                  totalPrice = 0;
                                                  el.isSelected = false;
                                                } else {
                                                  totalPrice += el.harga;
                                                  el.isSelected = true;
                                                  selectAll == 0
                                                      ? totalUnitSelected = 0
                                                      : totalUnitSelected =
                                                          cartData.data.results
                                                              .length;
                                                  idCart.add(el.id);
                                                }
                                              }
                                            }
                                          });
                                          print(idCart);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 5, left: 12),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 24,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
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
                                                        color: selectAll == 1
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
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .selectAll,
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12, bottom: 5, right: 12),
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (totalUnitSelected != 0) {
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  isDismissible: false,
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
                                                  backgroundColor:
                                                      widget.darkMode
                                                          ? whiteCardColor
                                                          : whiteColor,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setStateModal) {
                                                      return SingleChildScrollView(
                                                        child: Container(
                                                          padding:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .viewInsets,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20.0),
                                                            child: Column(
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    Image.asset(
                                                                      'assets/deletecart.png',
                                                                      width:
                                                                          120,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          vertical:
                                                                              15),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          totalUnitSelected == cartData.data.results.length
                                                                              ? AppLocalizations.of(context)!.deleteAllCart
                                                                              : AppLocalizations.of(context)!.deleteCart,
                                                                          style:
                                                                              bold.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                blackPrimary,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context);
                                                                          // Dialogs().loadingDialog(context);
                                                                          List<dynamic>
                                                                              idCart =
                                                                              [];
                                                                          cartData
                                                                              .data
                                                                              .results
                                                                              .forEach((el) async {
                                                                            if (el.isSelected) {
                                                                              idCart.add(el.id);
                                                                            }
                                                                            print(idCart);
                                                                            // await deleteCart(
                                                                            //     idCart);
                                                                          });
                                                                          await deleteCart(
                                                                              idCart);
                                                                          setState(
                                                                              () {
                                                                            selectAll =
                                                                                0;
                                                                          });
                                                                          // Navigator.pop(context);
                                                                          // Navigator.pop(context);
                                                                          // Dialogs().loadingDialog(context);
                                                                          // await deleteCart([
                                                                          //   cartData.data.results[index].id
                                                                          // ]);
                                                                          // Navigator.pop(context);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                bluePrimary,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            border:
                                                                                Border.all(
                                                                              width: 1,
                                                                              color: bluePrimary,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                                              child: Text(AppLocalizations.of(context)!.deleteCartButton, style: reguler.copyWith(color: whiteColor, fontSize: 12)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              whiteColor,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          border:
                                                                              Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                bluePrimary,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 10),
                                                                            child:
                                                                                Text(AppLocalizations.of(context)!.cancelDeleteCart, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
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
                                              // Dialogs().loadingDialog(
                                              //     context);
                                              // List<dynamic> idCart =
                                              //     [];
                                              // cartData.data.results
                                              //     .forEach(
                                              //         (el) async {
                                              //   if (el.isSelected) {
                                              //     idCart.add(el.id);
                                              //   }
                                              //   print(idCart);
                                              //   // await deleteCart(
                                              //   //     idCart);
                                              // });
                                              // await deleteCart(
                                              //     idCart);
                                              // setState(() {
                                              //   selectAll = 0;
                                              // });
                                              // Navigator.pop(context);
                                            }

                                            // Dialogs().showLoaderDialog(
                                            //     context);
                                            // deleteCart(cartData.data.results[index].id);
                                          },
                                          child: Image.asset(
                                            'assets/trash5.png',
                                            color: widget.darkMode
                                                ? whiteColorDarkMode
                                                : greyColor,
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Divider(
                                      height: 2,
                                      thickness: 1,
                                      indent: 0,
                                      endIndent: 0,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : greyColorSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () async {
                                        await _doRefreshIndicator();
                                      },
                                      child: ListView.builder(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          itemCount:
                                              cartData.data.results.length,
                                          itemBuilder: (context, index) {
                                            // totalPrice = cartData
                                            //         .data.results[index].harga +
                                            //     cartData.data.results[index].harga;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5),
                                                    child: SizedBox(
                                                      width: 24,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            if (cartData
                                                                .data
                                                                .results[index]
                                                                .isAvailable) {
                                                              cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected
                                                                  ? cartData
                                                                          .data
                                                                          .results[
                                                                              index]
                                                                          .isSelected =
                                                                      false
                                                                  : cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected = true;
                                                              cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected
                                                                  ? totalUnitSelected++
                                                                  : totalUnitSelected--;
                                                              cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected
                                                                  ? totalPrice +=
                                                                      cartData
                                                                          .data
                                                                          .results[
                                                                              index]
                                                                          .harga
                                                                  : totalPrice -=
                                                                      cartData
                                                                          .data
                                                                          .results[
                                                                              index]
                                                                          .harga;
                                                              idCart.isNotEmpty
                                                                  ? idCart = []
                                                                  : {};
                                                              for (var el
                                                                  in cartData
                                                                      .data
                                                                      .results) {
                                                                if (el
                                                                    .isSelected) {
                                                                  idCart.add(
                                                                      el.id);
                                                                }
                                                              }
                                                              print(
                                                                  'total = $totalUnitSelected');
                                                            } else {
                                                              print(DateTime
                                                                      .now()
                                                                  .difference(DateTime.parse(cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .expired))
                                                                  .inDays);
                                                              showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  isDismissible:
                                                                      false,
                                                                  backgroundColor: widget
                                                                          .darkMode
                                                                      ? whiteCardColor
                                                                      : whiteColor,
                                                                  shape:
                                                                      const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                12),
                                                                        topRight:
                                                                            Radius.circular(12)),
                                                                  ),
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setStateModal) {
                                                                      return SingleChildScrollView(
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              MediaQuery.of(context).viewInsets,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(20.0),
                                                                            child:
                                                                                Column(
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
                                                                                        color: widget.darkMode ? whiteColorDarkMode : null,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  children: [
                                                                                    Image.asset(
                                                                                      'assets/handling/terminated.png',
                                                                                      width: 200,
                                                                                      height: 200,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                      child: SizedBox(
                                                                                        width: double.infinity,
                                                                                        child: Text(
                                                                                          DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180Title : AppLocalizations.of(context)!.unitTerminated7Title,
                                                                                          style: bold.copyWith(
                                                                                            fontSize: 14,
                                                                                            color: blackPrimary,
                                                                                          ),
                                                                                          textAlign: TextAlign.center,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                      child: SizedBox(
                                                                                        width: double.infinity,
                                                                                        child: Text(
                                                                                          DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180SubTitle : AppLocalizations.of(context)!.unitTerminated7SubTitle,
                                                                                          style: reguler.copyWith(
                                                                                            fontSize: 14,
                                                                                            color: blackPrimary,
                                                                                          ),
                                                                                          textAlign: TextAlign.center,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    InkWell(
                                                                                      enableFeedback: url.data.branch.whatsapp == '' ? false : true,
                                                                                      onTap: () {
                                                                                        if (url.data.branch.whatsapp != '') {
                                                                                          launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
                                                                                          Navigator.pop(context);
                                                                                        }
                                                                                        // url.data.branch.whatsapp == '' ? {} : launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                                                                                        child: Container(
                                                                                          width: double.infinity,
                                                                                          decoration: BoxDecoration(
                                                                                            color: whiteColor,
                                                                                            // color: all ? blueGradient : whiteColor,
                                                                                            borderRadius: BorderRadius.circular(8),
                                                                                            border: Border.all(
                                                                                              width: 1,
                                                                                              color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
                                                                                            ),
                                                                                          ),
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.all(12),
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    // Icon(
                                                                                                    //   Icons.whatsapp_outlined,
                                                                                                    //   color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
                                                                                                    //   size: 15,
                                                                                                    // ),
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 2),
                                                                                                      child: Text(AppLocalizations.of(context)!.installationBranch, style: bold.copyWith(fontSize: 12, color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
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
                                                                                        launchUrl(Uri.parse('https://wa.me/${url.data.head.whatsapp}'), mode: LaunchMode.externalApplication);
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(top: 10),
                                                                                        child: Container(
                                                                                          width: double.infinity,
                                                                                          decoration: BoxDecoration(
                                                                                            color: greenPrimary,
                                                                                            // color: all ? blueGradient : whiteColor,
                                                                                            borderRadius: BorderRadius.circular(8),
                                                                                            border: Border.all(
                                                                                              width: 1,
                                                                                              color: greenPrimary,
                                                                                            ),
                                                                                          ),
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.all(12),
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    // Icon(
                                                                                                    //   Icons.whatsapp_outlined,
                                                                                                    //   color: whiteColor,
                                                                                                    //   size: 15,
                                                                                                    // ),
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 2),
                                                                                                      child: Text(AppLocalizations.of(context)!.cc24H, style: bold.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                                  });
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                              width: 1,
                                                              color: cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected
                                                                  ? bluePrimary
                                                                  : greyColorSecondary,
                                                            ),
                                                          ),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Container(
                                                              width: 14,
                                                              height: 14,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: cartData
                                                                        .data
                                                                        .results[
                                                                            index]
                                                                        .isSelected
                                                                    ? bluePrimary
                                                                    : null,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (cartData
                                                            .data
                                                            .results[index]
                                                            .isAvailable) {
                                                          cartData
                                                                  .data
                                                                  .results[
                                                                      index]
                                                                  .isSelected
                                                              ? cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected =
                                                                  false
                                                              : cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected =
                                                                  true;
                                                          cartData
                                                                  .data
                                                                  .results[
                                                                      index]
                                                                  .isSelected
                                                              ? totalUnitSelected++
                                                              : totalUnitSelected--;
                                                          cartData
                                                                  .data
                                                                  .results[
                                                                      index]
                                                                  .isSelected
                                                              ? totalPrice +=
                                                                  cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .harga
                                                              : totalPrice -=
                                                                  cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .harga;
                                                          idCart.isNotEmpty
                                                              ? idCart = []
                                                              : {};
                                                          for (var el
                                                              in cartData.data
                                                                  .results) {
                                                            if (el.isSelected) {
                                                              idCart.add(el.id);
                                                            }
                                                          }
                                                          print(
                                                              'total = $totalUnitSelected');
                                                        } else {
                                                          print(DateTime.now()
                                                              .difference(DateTime
                                                                  .parse(cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .expired))
                                                              .inDays);
                                                          showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              isDismissible:
                                                                  false,
                                                              backgroundColor: widget
                                                                      .darkMode
                                                                  ? whiteCardColor
                                                                  : whiteColor,
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
                                                                        padding:
                                                                            const EdgeInsets.all(20.0),
                                                                        child:
                                                                            Column(
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
                                                                                    color: widget.darkMode ? whiteColorDarkMode : null,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Column(
                                                                              children: [
                                                                                Image.asset(
                                                                                  'assets/handling/terminated.png',
                                                                                  width: 200,
                                                                                  height: 200,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    child: Text(
                                                                                      DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180Title : AppLocalizations.of(context)!.unitTerminated7Title,
                                                                                      style: bold.copyWith(
                                                                                        fontSize: 14,
                                                                                        color: blackPrimary,
                                                                                      ),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    child: Text(
                                                                                      DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180SubTitle : AppLocalizations.of(context)!.unitTerminated7SubTitle,
                                                                                      style: reguler.copyWith(
                                                                                        fontSize: 14,
                                                                                        color: blackPrimary,
                                                                                      ),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                InkWell(
                                                                                  enableFeedback: url.data.branch.whatsapp == '' ? false : true,
                                                                                  onTap: () {
                                                                                    if (url.data.branch.whatsapp != '') {
                                                                                      launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
                                                                                      Navigator.pop(context);
                                                                                    }
                                                                                    // url.data.branch.whatsapp == '' ? {} : launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 10, bottom: 5),
                                                                                    child: Container(
                                                                                      width: double.infinity,
                                                                                      decoration: BoxDecoration(
                                                                                        color: whiteColor,
                                                                                        // color: all ? blueGradient : whiteColor,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        border: Border.all(
                                                                                          width: 1,
                                                                                          color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
                                                                                        ),
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(12),
                                                                                            child: Row(
                                                                                              children: [
                                                                                                // Icon(
                                                                                                //   Icons.whatsapp_outlined,
                                                                                                //   color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
                                                                                                //   size: 15,
                                                                                                // ),
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.only(left: 2),
                                                                                                  child: Text(AppLocalizations.of(context)!.installationBranch, style: bold.copyWith(fontSize: 12, color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
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
                                                                                    launchUrl(Uri.parse('https://wa.me/${url.data.head.whatsapp}'), mode: LaunchMode.externalApplication);
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 10),
                                                                                    child: Container(
                                                                                      width: double.infinity,
                                                                                      decoration: BoxDecoration(
                                                                                        color: greenPrimary,
                                                                                        // color: all ? blueGradient : whiteColor,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        border: Border.all(
                                                                                          width: 1,
                                                                                          color: greenPrimary,
                                                                                        ),
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(12),
                                                                                            child: Row(
                                                                                              children: [
                                                                                                // Icon(
                                                                                                //   Icons.whatsapp_outlined,
                                                                                                //   color: whiteColor,
                                                                                                //   size: 15,
                                                                                                // ),
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.only(left: 2),
                                                                                                  child: Text(AppLocalizations.of(context)!.cc24H, style: bold.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
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
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                              });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: widget.darkMode
                                                            ? whiteCardColor
                                                            : whiteColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteCardColor
                                                                  : greyColorSecondary
                                                                      .withOpacity(
                                                                          0.3),
                                                              spreadRadius: 0,
                                                              blurRadius: 5,
                                                              offset:
                                                                  Offset(0, 3))
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: cartData
                                                                  .data
                                                                  .results[
                                                                      index]
                                                                  .isAvailable
                                                              ? cartData
                                                                      .data
                                                                      .results[
                                                                          index]
                                                                      .isSelected
                                                                  ? bluePrimary
                                                                  : whiteCardColor
                                                              : redPrimary,
                                                        ),
                                                      ),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 12,
                                                              top: 12),
                                                      // color: whiteColor,
                                                      // elevation: 3,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 8),
                                                                          child: appDir is Directory
                                                                              ? Image.file(
                                                                                  File('${appDir.path}/localAssetType/${cartData.data.results[index].vehicleType.toLowerCase()}_parking.png'),
                                                                                  width: 42,
                                                                                  height: 42,
                                                                                )
                                                                              : const SkeletonAvatar(
                                                                                  style: SkeletonAvatarStyle(shape: BoxShape.rectangle, width: 42, height: 42),
                                                                                ),
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              // height: 25,
                                                                              decoration: BoxDecoration(
                                                                                color: widget.darkMode ? whiteColor : blackSecondary1,
                                                                                borderRadius: BorderRadius.circular(4),
                                                                                border: Border.all(
                                                                                  width: 1,
                                                                                  color: widget.darkMode ? whiteColor : blackSecondary1,
                                                                                ),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(cartData.data.results[index].information[0], style: reguler.copyWith(fontSize: 10, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 4,
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                //phone number dumy
                                                                                Text(
                                                                                  cartData.data.results[index].sim,
                                                                                  style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary1),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      showModalBottomSheet(
                                                                          isScrollControlled:
                                                                              true,
                                                                          isDismissible:
                                                                              false,
                                                                          backgroundColor: widget.darkMode
                                                                              ? whiteCardColor
                                                                              : whiteColor,
                                                                          shape:
                                                                              const RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                                          ),
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return StatefulBuilder(builder:
                                                                                (BuildContext context, StateSetter setStateModal) {
                                                                              return SingleChildScrollView(
                                                                                child: Container(
                                                                                  padding: MediaQuery.of(context).viewInsets,
                                                                                  alignment: Alignment.center,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(20.0),
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Column(
                                                                                          children: [
                                                                                            Image.asset(
                                                                                              'assets/deletecart.png',
                                                                                              width: 120,
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(vertical: 15),
                                                                                              child: SizedBox(
                                                                                                width: 200,
                                                                                                child: Text(
                                                                                                  AppLocalizations.of(context)!.deleteCart,
                                                                                                  style: bold.copyWith(
                                                                                                    fontSize: 12,
                                                                                                    color: blackPrimary,
                                                                                                  ),
                                                                                                  textAlign: TextAlign.center,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(bottom: 10),
                                                                                              child: GestureDetector(
                                                                                                onTap: () async {
                                                                                                  Navigator.pop(context);
                                                                                                  // Dialogs().loadingDialog(context);
                                                                                                  await deleteCart([
                                                                                                    cartData.data.results[index].id
                                                                                                  ]);
                                                                                                  // Navigator.pop(context);
                                                                                                },
                                                                                                child: Container(
                                                                                                  width: double.infinity,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: bluePrimary,
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
                                                                                                      child: Text(AppLocalizations.of(context)!.deleteCartButton, style: reguler.copyWith(color: whiteColor, fontSize: 12)),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            GestureDetector(
                                                                                              onTap: () {
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
                                                                                                    child: Text(AppLocalizations.of(context)!.cancelDeleteCart, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
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
                                                                      // Dialogs().loadingDialog(context);
                                                                      // await deleteCart([
                                                                      //   cartData.data.results[index].id
                                                                      // ]);
                                                                      // Navigator.pop(context);
                                                                    },
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/trash5.png',
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : greyColor,
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                    ),
                                                                  )

                                                                  // const SizedBox(
                                                                  //   width: 10,
                                                                  // ),
                                                                ],
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
                                                                    //phone number dumy
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.of(context)!
                                                                            .choosePackage,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                10,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        if (cartData
                                                                            .data
                                                                            .results[index]
                                                                            .isAvailable) {
                                                                          Dialogs()
                                                                              .loadingDialog(context);
                                                                          await getPackage(cartData
                                                                              .data
                                                                              .results[index]
                                                                              .sim);
                                                                          Dialogs()
                                                                              .hideLoaderDialog(context);
                                                                          showModalBottomSheet(
                                                                            context:
                                                                                context,
                                                                            backgroundColor: widget.darkMode
                                                                                ? whiteCardColor
                                                                                : whiteColor,
                                                                            shape:
                                                                                const RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                                            ),
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return StatefulBuilder(
                                                                                builder: (BuildContext context, StateSetter setState) {
                                                                                  return SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: 350,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        // const SizedBox(
                                                                                        //   height: 20,
                                                                                        // ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  TextScroll(
                                                                                                    cartData.data.results[index].information[0],
                                                                                                    style: bold.copyWith(
                                                                                                      fontSize: 10,
                                                                                                      color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                                                                                                    ),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    cartData.data.results[index].sim,
                                                                                                    style: bold.copyWith(
                                                                                                      fontSize: 14,
                                                                                                      color: widget.darkMode ? whiteColorDarkMode : blackSecondary1,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Text(
                                                                                                    AppLocalizations.of(context)!.packageEnds,
                                                                                                    style: reguler.copyWith(
                                                                                                      fontSize: 10,
                                                                                                      color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
                                                                                                    ),
                                                                                                  ),
                                                                                                  TextScroll(
                                                                                                    DateFormat('dd MMMM yyyy').format(DateTime.parse(cartData.data.results[index].nextExpired).toLocal()),
                                                                                                    style: bold.copyWith(
                                                                                                      fontSize: 14,
                                                                                                      color: widget.darkMode ? whiteColorDarkMode : blackSecondary1,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                                          child: Divider(
                                                                                            height: 2,
                                                                                            thickness: 1,
                                                                                            indent: 0,
                                                                                            endIndent: 0,
                                                                                            color: widget.darkMode ? whiteColorDarkMode : greyColor,
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
                                                                                                    itemCount: getPackageModel.data.results.length,
                                                                                                    itemBuilder: (context, indexPackage) {
                                                                                                      return Padding(
                                                                                                        padding: const EdgeInsets.only(bottom: 10),
                                                                                                        child: GestureDetector(
                                                                                                          onTap: () async {
                                                                                                            setState(
                                                                                                              () {
                                                                                                                select = indexPackage + 1;
                                                                                                              },
                                                                                                            );
                                                                                                            print('Test ${getPackageModel.data.results[indexPackage].id} // ${cartData.data.results[index].id}');
                                                                                                            Dialogs().loadingDialog(context);
                                                                                                            await updatePack(cartData.data.results[index].id, getPackageModel.data.results[indexPackage].id);
                                                                                                            Navigator.pop(context);
                                                                                                            Navigator.pop(context);
                                                                                                          },
                                                                                                          child: Container(
                                                                                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                                                                                                            width: width,
                                                                                                            // height: 60,
                                                                                                            decoration: BoxDecoration(
                                                                                                              // color: whiteCardColor,
                                                                                                              borderRadius: BorderRadius.circular(8),
                                                                                                              border: Border.all(
                                                                                                                width: 1,
                                                                                                                color: select == indexPackage + 1
                                                                                                                    ? bluePrimary
                                                                                                                    : widget.darkMode
                                                                                                                        ? whiteColorDarkMode
                                                                                                                        : greyColor,
                                                                                                              ),
                                                                                                            ),
                                                                                                            child: Row(
                                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  getPackageModel.data.results[indexPackage].packName,
                                                                                                                  style: reguler.copyWith(
                                                                                                                    fontSize: 14,
                                                                                                                    color: select == indexPackage + 1
                                                                                                                        ? bluePrimary
                                                                                                                        : widget.darkMode
                                                                                                                            ? whiteColorDarkMode
                                                                                                                            : blackSecondary3,
                                                                                                                  ),
                                                                                                                ),
                                                                                                                getPackageModel.data.results[indexPackage].isPromo == 1
                                                                                                                    ? Container(
                                                                                                                        // width: 40,
                                                                                                                        // height: 10,
                                                                                                                        decoration: BoxDecoration(
                                                                                                                          color: blueSecondary,
                                                                                                                          borderRadius: BorderRadius.circular(15),
                                                                                                                          boxShadow: [
                                                                                                                            BoxShadow(
                                                                                                                              color: widget.darkMode ? whiteCardColor : Colors.grey,
                                                                                                                              offset: Offset(0.0, 3),
                                                                                                                              blurRadius: 5.0,
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                        // width: 40,
                                                                                                                        // height: 10,
                                                                                                                        child: Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 12, right: 12),
                                                                                                                          child: Text(
                                                                                                                            'Promo',
                                                                                                                            style: bold.copyWith(color: widget.darkMode ? whiteColorDarkMode : whiteColor, fontSize: 12),
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
                                                                                                                    int.parse(getPackageModel.data.results[indexPackage].price.toString()),
                                                                                                                  ),
                                                                                                                  style: reguler.copyWith(
                                                                                                                    fontSize: 14,
                                                                                                                    color: select == indexPackage + 1
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
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            25,
                                                                        // width: 100,
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 10),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: widget.darkMode
                                                                              ? whiteCardColor
                                                                              : whiteColor,
                                                                          borderRadius:
                                                                              BorderRadius.circular(4),
                                                                          border:
                                                                              Border.all(
                                                                            width:
                                                                                1,
                                                                            color: cartData.data.results[index].isAvailable
                                                                                ? bluePrimary
                                                                                : greyColor,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(cartData.data.results[index].packName,
                                                                                style: reguler.copyWith(
                                                                                  fontSize: 10,
                                                                                  color: cartData.data.results[index].isAvailable ? bluePrimary : greyColor,
                                                                                )),
                                                                            Icon(
                                                                              Icons.arrow_forward_ios_outlined,
                                                                              color: cartData.data.results[index].isAvailable ? bluePrimary : greyColor,
                                                                              size: 11,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    //phone number dumy
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.of(context)!
                                                                            .price,
                                                                        style: reguler.copyWith(
                                                                            fontSize:
                                                                                10,
                                                                            color: widget.darkMode
                                                                                ? whiteColorDarkMode
                                                                                : blackSecondary3),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      NumberFormat
                                                                          .currency(
                                                                        locale:
                                                                            'id',
                                                                        decimalDigits:
                                                                            0,
                                                                        symbol:
                                                                            'Rp. ',
                                                                      ).format(
                                                                        int.parse(cartData
                                                                            .data
                                                                            .results[index]
                                                                            .harga
                                                                            .toString()),
                                                                      ),
                                                                      style: reguler.copyWith(
                                                                          fontSize:
                                                                              16,
                                                                          color: cartData.data.results[index].isAvailable
                                                                              ? greenPrimary
                                                                              : greyColor),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            // SizedBox(
                                                            //   width: MediaQuery.of(context)
                                                            //           .size
                                                            //           .width /
                                                            //       3,
                                                            //   child:
                                                            //       Padding(
                                                            //     padding:
                                                            //         const EdgeInsets.only(top: 20),
                                                            //     child:
                                                            //         Column(
                                                            //       crossAxisAlignment:
                                                            //           CrossAxisAlignment.start,
                                                            //       children: [
                                                            //         const SizedBox(
                                                            //           height: 10,
                                                            //         ),
                                                            //       ],
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          10),
                                                              child: Divider(
                                                                height: 2,
                                                                thickness: 1,
                                                                indent: 0,
                                                                endIndent: 0,
                                                                color:
                                                                    greyColorSecondary,
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
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .expire,
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                    Text(
                                                                      DateFormat('dd MMMM yyyy').format(DateTime.parse(cartData
                                                                              .data
                                                                              .results[index]
                                                                              .expired)
                                                                          .toLocal()),
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary2,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .nextExpire,
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary3,
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                    Text(
                                                                      DateFormat('dd MMMM yyyy').format(DateTime.parse(cartData
                                                                              .data
                                                                              .results[index]
                                                                              .nextExpired)
                                                                          .toLocal()),
                                                                      style: reguler.copyWith(
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : blackSecondary2,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // GestureDetector(
                                                                //   onTap:
                                                                //       () {
                                                                //     deleteCart(cartData.data.results[index].id);
                                                                //   },
                                                                //   child:
                                                                //       Image.asset(
                                                                //     'assets/trash5.png',
                                                                //     width:
                                                                //         15,
                                                                //   ),
                                                                // )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    // height: 130,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 100.0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 5.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: widget.darkMode
                                                ? whiteCardColor
                                                : whiteColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: widget.darkMode
                                                    ? whiteCardColor
                                                    : greyColor,
                                                offset: Offset(0.0, 1.0),
                                                blurRadius: 9.0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // const SizedBox(
                                                  //   width: 10,
                                                  // ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .totalUnit,
                                                            style: reguler.copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    blackPrimary)),
                                                        Text(
                                                            totalUnitSelected
                                                                .toString(),
                                                            style: bold.copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    blackPrimary)),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .totalPrice,
                                                            style: reguler.copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    blackPrimary)),
                                                        Text(
                                                          NumberFormat.currency(
                                                            locale: 'id',
                                                            decimalDigits: 0,
                                                            symbol: 'Rp. ',
                                                          ).format(
                                                            totalPrice,
                                                          ),
                                                          style: bold.copyWith(
                                                              fontSize: 11,
                                                              color:
                                                                  blackPrimary),
                                                        )
                                                        // Text(
                                                        //   'Rp. 1.500.000',
                                                        //   style: bold.copyWith(
                                                        //       fontSize: 14,
                                                        //       color: blackPrimary),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  // const SizedBox(
                                                  //   width: 40,
                                                  // ),

                                                  // const SizedBox(
                                                  //   width: 40,
                                                  // ),
                                                  // Padding(
                                                  //   padding:
                                                  //       const EdgeInsets
                                                  //           .all(8.0),
                                                  //   child: Column(
                                                  //     crossAxisAlignment:
                                                  //         CrossAxisAlignment
                                                  //             .start,
                                                  //     children: [
                                                  //       Row(
                                                  //         mainAxisAlignment:
                                                  //             MainAxisAlignment
                                                  //                 .start,
                                                  //         children: [
                                                  //           const SizedBox(
                                                  //             height:
                                                  //                 25,
                                                  //           ),
                                                  //           GestureDetector(
                                                  //             onTap:
                                                  //                 () {
                                                  //               setState(
                                                  //                   () {
                                                  //                 selected == 1
                                                  //                     ? selected = 0
                                                  //                     : selected = 1;
                                                  //                 print(selected);
                                                  //               });
                                                  //             },
                                                  //             child:
                                                  //                 Container(
                                                  //               width:
                                                  //                   20,
                                                  //               height:
                                                  //                   20,
                                                  //               decoration:
                                                  //                   BoxDecoration(
                                                  //                 borderRadius:
                                                  //                     BorderRadius.circular(4),
                                                  //                 border:
                                                  //                     Border.all(
                                                  //                   width: 1,
                                                  //                   color: selected == 1 ? blueGradient : blueGradient,
                                                  //                 ),
                                                  //               ),
                                                  //               child:
                                                  //                   Align(
                                                  //                 alignment:
                                                  //                     Alignment.center,
                                                  //                 child:
                                                  //                     Container(
                                                  //                   width: 12,
                                                  //                   height: 12,
                                                  //                   decoration: BoxDecoration(
                                                  //                     color: selected == 1 ? bluePrimary : whiteColor,
                                                  //                     borderRadius: BorderRadius.circular(3),
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //           ),
                                                  //           const SizedBox(
                                                  //             width:
                                                  //                 5,
                                                  //           ),
                                                  //           GestureDetector(
                                                  //             onTap:
                                                  //                 () async {
                                                  //               await Navigator.pushNamed(
                                                  //                   context,
                                                  //                   '/taxinvoice');
                                                  //               _doRefresh();
                                                  //             },
                                                  //             child:
                                                  //                 Column(
                                                  //               children: [
                                                  //                 Text(
                                                  //                   AppLocalizations.of(context)!.taxInvoice,
                                                  //                   style: reguler.copyWith(fontSize: 11, color: blackPrimary),
                                                  //                 ),
                                                  //                 Text(
                                                  //                   '(Edit)',
                                                  //                   style: bold.copyWith(fontSize: 11, color: blackPrimary),
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           )
                                                  //         ],
                                                  //       ),
                                                  //       // Text('Tax invoice',
                                                  //       //     style: reguler.copyWith(
                                                  //       //         fontSize: 14, color: blackPrimary)),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              // const SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Divider(
                                              //   height: 2,
                                              //   thickness: 1,
                                              //   indent: 0,
                                              //   endIndent: 0,
                                              //   color: greyColor,
                                              // ),
                                              // const SizedBox(
                                              //   height: 5,
                                              // ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 40.0,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        // await Navigator
                                                        //     .pushNamed(
                                                        //         context,
                                                        //         '/vehiclelist');
                                                        await Navigator.pushNamed(
                                                            context,
                                                            '/choosevehicletopup');
                                                        _doRefresh();
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          border: Border.all(
                                                            width: 1,
                                                            color: blueGradient,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '+ ${AppLocalizations.of(context)!.addUnit}',
                                                              style: reguler
                                                                  .copyWith(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          blueGradient),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          if (totalUnitSelected !=
                                                              0) {
                                                            showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                isDismissible:
                                                                    false,
                                                                backgroundColor: widget
                                                                        .darkMode
                                                                    ? whiteCardColor
                                                                    : whiteColor,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              12),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              12)),
                                                                ),
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return StatefulBuilder(builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setStateModal) {
                                                                    return SingleChildScrollView(
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            MediaQuery.of(context).viewInsets,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(20.0),
                                                                          child:
                                                                              Column(
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
                                                                                      width: double.infinity,
                                                                                      child: Text(
                                                                                        AppLocalizations.of(context)!.askTaxInvoice,
                                                                                        style: bold.copyWith(
                                                                                          fontSize: 12,
                                                                                          color: blackPrimary,
                                                                                        ),
                                                                                        textAlign: TextAlign.center,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  GestureDetector(
                                                                                    onTap: () async {
                                                                                      // Navigator.pop(context);
                                                                                      Navigator.pop(context);
                                                                                      List<dynamic> cart = [];
                                                                                      for (var el in cartData.data.results) {
                                                                                        if (el.isSelected) {
                                                                                          cart.add(el);
                                                                                        }
                                                                                      }
                                                                                      print(cart);
                                                                                      if (cartData.data.results.length >= 100) {
                                                                                        showInfoAlert(context, 'The transaction cannot be continued because the number of transactions exceeds 100 vehicles', '');
                                                                                      } else {
                                                                                        await Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => TaxInvoice(
                                                                                              idCart: idCart,
                                                                                              totalUnit: totalUnitSelected,
                                                                                              totalPrice: totalPrice,
                                                                                              cart: cart,
                                                                                              darkMode: widget.darkMode,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                        _doRefresh();
                                                                                      }
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
                                                                                          child: Text(AppLocalizations.of(context)!.useTaxInvoice, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 10),
                                                                                    child: GestureDetector(
                                                                                      onTap: () async {
                                                                                        // Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                        if (cartData.data.results.length >= 100) {
                                                                                          showInfoAlert(context, 'The transaction cannot be continued because the number of transactions exceeds 100 vehicles', '');
                                                                                        } else {
                                                                                          List<dynamic> cart = [];
                                                                                          for (var el in cartData.data.results) {
                                                                                            if (el.isSelected) {
                                                                                              cart.add(el);
                                                                                            }
                                                                                          }
                                                                                          print(cart);
                                                                                          await Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                              builder: (context) => PaymentMethod(
                                                                                                totalUnit: totalUnitSelected,
                                                                                                totalPrice: totalPrice,
                                                                                                npwp: 0,
                                                                                                idCart: idCart,
                                                                                                npwpNo: '',
                                                                                                npwpName: '',
                                                                                                npwpAddress: '',
                                                                                                npwpEmail: '',
                                                                                                npwpWa: '',
                                                                                                cart: cart,
                                                                                                darkMode: widget.darkMode,
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                          _doRefresh();
                                                                                        }
                                                                                      },
                                                                                      child: Container(
                                                                                        width: double.infinity,
                                                                                        decoration: BoxDecoration(
                                                                                          color: bluePrimary,
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
                                                                                            child: Text(AppLocalizations.of(context)!.withoutTaxInvoice, style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : whiteColor, fontSize: 12)),
                                                                                          ),
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
                                                          } else {}
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: totalUnitSelected ==
                                                                    0
                                                                ? widget.darkMode
                                                                    ? whiteColor
                                                                    : greyColor
                                                                : bluePrimary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            border: Border.all(
                                                              width: 1,
                                                              color: totalUnitSelected ==
                                                                      0
                                                                  ? greyColor
                                                                  : blueGradient,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .choosePaymentMethod,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: reguler.copyWith(
                                                                    fontSize:
                                                                        11,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : whiteColor),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }
                          }
                        }

                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Card(
                                  margin: const EdgeInsets.all(15),
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
                      }))
            ],
          )
        ],
      ),
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
      //                 color: widget.darkMode
      //                     ? whiteColorDarkMode
      //                     : blackSecondary2,
      //               ),
      //             ),
      //           ),
      //           Align(
      //             alignment: Alignment.bottomCenter,
      //             child: Visibility(
      //                 visible: true,
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(45.0),
      //                   child: GestureDetector(
      //                     onTap: () async {
      //                       await _doRefreshIndicator();
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
      //                               color: widget.darkMode
      //                                   ? whiteColorDarkMode
      //                                   : whiteColor,
      //                             )),
      //                       ),
      //                     ),
      //                   ),
      //                 )),
      //           ),
      //         ],
      //       )
      //     : Stack(
      //         children: [
      //           Column(
      //             children: [
      //               Padding(
      //                 padding: thereIsPending
      //                     ? EdgeInsets.only(top: 0)
      //                     : EdgeInsets.only(top: 10),
      //                 child: FutureBuilder(
      //                   future: _getPending,
      //                   builder: (BuildContext contxt,
      //                       AsyncSnapshot<dynamic> snapshot) {
      //                     if (snapshot.hasData) {
      //                       if (snapshot.data is ErrorTrapModel) {
      //                         return Container();
      //                       }
      //                       if (snapshot.data is MessageModel) {
      //                         _getCart = getCart();
      //                       } else {
      //                         listPending = snapshot.data;
      //                         if (listPending.data.isEmpty) {
      //                           return Container();
      //                         } else {
      //                           return Visibility(
      //                             visible: !loading,
      //                             child: Padding(
      //                               padding: const EdgeInsets.symmetric(
      //                                   horizontal: 10),
      //                               child: Container(
      //                                 decoration: BoxDecoration(
      //                                   color: yellowSecondary,
      //                                   border: Border.all(
      //                                     width: 1,
      //                                     color: yellowSecondary,
      //                                   ),
      //                                   borderRadius:
      //                                       BorderRadius.circular(4),
      //                                 ),
      //                                 child: InkWell(
      //                                   onTap: () async {
      //                                     await Navigator.pushNamed(
      //                                         context, '/pendingpayment');
      //                                     _doRefresh();
      //                                   },
      //                                   child: Padding(
      //                                     padding:
      //                                         const EdgeInsets.symmetric(
      //                                             vertical: 10,
      //                                             horizontal: 10),
      //                                     child: Row(
      //                                       mainAxisAlignment:
      //                                           MainAxisAlignment
      //                                               .spaceBetween,
      //                                       children: [
      //                                         Image.asset(
      //                                           'assets/icon/pendingtransaction.png',
      //                                           height: 24,
      //                                           width: 24,
      //                                         ),
      //                                         Text(
      //                                           '${listPending.data.length} ${AppLocalizations.of(context)!.waitingTransaction}',
      //                                           style: reguler.copyWith(
      //                                               color: blackSecondary1,
      //                                               fontSize: 10),
      //                                         ),
      //                                         Icon(
      //                                           Icons
      //                                               .arrow_forward_ios_rounded,
      //                                           size: 10,
      //                                         )
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           );
      //                         }
      //                       }
      //                     }
      //                     return Container();
      //                   },
      //                 ),
      //               ),
      //               Expanded(
      //                   child: FutureBuilder(
      //                       future: _getCart,
      //                       builder: (BuildContext context,
      //                           AsyncSnapshot<dynamic> snapshot) {
      //                         if (loading) {
      //                           return ListView.builder(
      //                               scrollDirection: Axis.vertical,
      //                               itemCount: 5,
      //                               itemBuilder: (context, index) {
      //                                 return Card(
      //                                     margin: const EdgeInsets.all(15),
      //                                     elevation: 3,
      //                                     shape: RoundedRectangleBorder(
      //                                       borderRadius:
      //                                           BorderRadius.circular(4),
      //                                     ),
      //                                     child: SizedBox(
      //                                       height: 121,
      //                                       child: SkeletonTheme(
      //                                           themeMode: widget.darkMode
      //                                               ? ThemeMode.dark
      //                                               : ThemeMode.light,
      //                                           child: const SkeletonAvatar(
      //                                             style:
      //                                                 SkeletonAvatarStyle(
      //                                                     shape: BoxShape
      //                                                         .rectangle,
      //                                                     width: 140,
      //                                                     height: 30),
      //                                           )),
      //                                     ));
      //                               });
      //                         } else {
      //                           if (snapshot.hasData) {
      //                             if (snapshot.data is ErrorTrapModel) {
      //                               return Padding(
      //                                 padding:
      //                                     const EdgeInsets.only(top: 60),
      //                                 child: Align(
      //                                   alignment: Alignment.topCenter,
      //                                   child: Column(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment.start,
      //                                     children: [
      //                                       Image.asset(
      //                                         'assets/handling/500error.png',
      //                                         height: 240,
      //                                         width: 240,
      //                                       ),
      //                                       Padding(
      //                                         padding:
      //                                             const EdgeInsets.only(
      //                                                 left: 50,
      //                                                 right: 50,
      //                                                 top: 10),
      //                                         child: Text(
      //                                           AppLocalizations.of(
      //                                                   context)!
      //                                               .error500,
      //                                           textAlign: TextAlign.center,
      //                                           style: bold.copyWith(
      //                                             fontSize: 14,
      //                                             color: widget.darkMode
      //                                                 ? whiteColorDarkMode
      //                                                 : blackSecondary2,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       Padding(
      //                                         padding:
      //                                             const EdgeInsets.only(
      //                                                 left: 30,
      //                                                 right: 30,
      //                                                 top: 10),
      //                                         child: Text(
      //                                           AppLocalizations.of(
      //                                                   context)!
      //                                               .error500Sub,
      //                                           textAlign: TextAlign.center,
      //                                           style: reguler.copyWith(
      //                                             fontSize: 12,
      //                                             color: widget.darkMode
      //                                                 ? whiteColorDarkMode
      //                                                 : blackSecondary2,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               );
      //                             }
      //                             if (snapshot.data is MessageModel) {
      //                               return RefreshIndicator(
      //                                   onRefresh: () async {
      //                                     await _doRefreshIndicator();
      //                                   },
      //                                   child: ListView.builder(
      //                                       physics:
      //                                           AlwaysScrollableScrollPhysics(),
      //                                       itemCount: 1,
      //                                       itemBuilder: (context, index) {
      //                                         return Padding(
      //                                           padding:
      //                                               const EdgeInsets.only(
      //                                                   top: 60),
      //                                           child: Align(
      //                                             alignment:
      //                                                 Alignment.topCenter,
      //                                             child: Column(
      //                                               mainAxisAlignment:
      //                                                   MainAxisAlignment
      //                                                       .start,
      //                                               children: [
      //                                                 Image.asset(
      //                                                   'assets/handling/emptycart.png',
      //                                                   height: 240,
      //                                                   width: 240,
      //                                                 ),
      //                                                 Padding(
      //                                                   padding:
      //                                                       const EdgeInsets
      //                                                               .only(
      //                                                           left: 50,
      //                                                           right: 50,
      //                                                           top: 10),
      //                                                   child: Text(
      //                                                     AppLocalizations.of(
      //                                                             context)!
      //                                                         .emptyCart,
      //                                                     textAlign:
      //                                                         TextAlign
      //                                                             .center,
      //                                                     style:
      //                                                         bold.copyWith(
      //                                                       fontSize: 14,
      //                                                       color: widget
      //                                                               .darkMode
      //                                                           ? whiteColorDarkMode
      //                                                           : blackSecondary2,
      //                                                     ),
      //                                                   ),
      //                                                 ),
      //                                                 Padding(
      //                                                   padding:
      //                                                       const EdgeInsets
      //                                                               .only(
      //                                                           left: 30,
      //                                                           right: 30,
      //                                                           top: 10),
      //                                                   child: Text(
      //                                                     AppLocalizations.of(
      //                                                             context)!
      //                                                         .emptyCartSub,
      //                                                     textAlign:
      //                                                         TextAlign
      //                                                             .center,
      //                                                     style: reguler
      //                                                         .copyWith(
      //                                                       fontSize: 12,
      //                                                       color: widget
      //                                                               .darkMode
      //                                                           ? whiteColorDarkMode
      //                                                           : blackSecondary2,
      //                                                     ),
      //                                                   ),
      //                                                 ),
      //                                                 Padding(
      //                                                   padding:
      //                                                       const EdgeInsets
      //                                                               .only(
      //                                                           top: 15),
      //                                                   child: SizedBox(
      //                                                     width: MediaQuery.of(
      //                                                                 context)
      //                                                             .size
      //                                                             .width /
      //                                                         1.2,
      //                                                     child:
      //                                                         ElevatedButton(
      //                                                       onPressed:
      //                                                           () async {
      //                                                         // await Navigator.pushNamed(
      //                                                         //     context,
      //                                                         //     '/vehiclelist');
      //                                                         await Navigator
      //                                                             .pushNamed(
      //                                                                 context,
      //                                                                 '/choosevehicletopup');
      //                                                         _doRefresh();
      //                                                       },
      //                                                       style: ElevatedButton
      //                                                           .styleFrom(
      //                                                               backgroundColor: widget.darkMode
      //                                                                   ? whiteCardColor
      //                                                                   : whiteColor,
      //                                                               shape:
      //                                                                   RoundedRectangleBorder(
      //                                                                 borderRadius:
      //                                                                     BorderRadius.circular(10.0),
      //                                                                 side: BorderSide(
      //                                                                     color: blueGradient,
      //                                                                     width: 1),
      //                                                               ),
      //                                                               textStyle:
      //                                                                   const TextStyle(
      //                                                                 color:
      //                                                                     Colors.white,
      //                                                               )),
      //                                                       child: Text(
      //                                                         AppLocalizations.of(
      //                                                                 context)!
      //                                                             .addUnit,
      //                                                         style: reguler
      //                                                             .copyWith(
      //                                                           fontSize:
      //                                                               12,
      //                                                           color:
      //                                                               blueGradient,
      //                                                         ),
      //                                                       ),
      //                                                     ),
      //                                                   ),
      //                                                 )
      //                                               ],
      //                                             ),
      //                                           ),
      //                                         );
      //                                       }));
      //                             } else {
      //                               cartData = snapshot.data;
      //                               return Column(
      //                                 children: [
      //                                   Row(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment
      //                                             .spaceBetween,
      //                                     children: [
      //                                       GestureDetector(
      //                                         onTap: () {
      //                                           idCart = [];
      //                                           setState(() {
      //                                             totalPrice = 0;
      //                                             totalUnitSelected = 0;
      //                                             selectAll == 0
      //                                                 ? selectAll = 1
      //                                                 : selectAll = 0;
      //                                             for (var el in cartData
      //                                                 .data.results) {
      //                                               if (el.isAvailable) {
      //                                                 if (selectAll == 0) {
      //                                                   totalPrice = 0;
      //                                                   el.isSelected =
      //                                                       false;
      //                                                 } else {
      //                                                   totalPrice +=
      //                                                       el.harga;
      //                                                   el.isSelected =
      //                                                       true;
      //                                                   selectAll == 0
      //                                                       ? totalUnitSelected =
      //                                                           0
      //                                                       : totalUnitSelected =
      //                                                           cartData
      //                                                               .data
      //                                                               .results
      //                                                               .length;
      //                                                   idCart.add(el.id);
      //                                                 }
      //                                               }
      //                                             }
      //                                           });
      //                                           print(idCart);
      //                                         },
      //                                         child: Padding(
      //                                           padding:
      //                                               const EdgeInsets.only(
      //                                                   top: 12,
      //                                                   bottom: 5,
      //                                                   left: 12),
      //                                           child: Row(
      //                                             children: [
      //                                               SizedBox(
      //                                                 width: 24,
      //                                                 child: Container(
      //                                                   width: 24,
      //                                                   height: 24,
      //                                                   decoration:
      //                                                       BoxDecoration(
      //                                                     borderRadius:
      //                                                         BorderRadius
      //                                                             .circular(
      //                                                                 4),
      //                                                     border:
      //                                                         Border.all(
      //                                                       width: 1,
      //                                                       color: selectAll ==
      //                                                               1
      //                                                           ? bluePrimary
      //                                                           : greyColorSecondary,
      //                                                     ),
      //                                                   ),
      //                                                   child: Align(
      //                                                     alignment:
      //                                                         Alignment
      //                                                             .center,
      //                                                     child: Container(
      //                                                       width: 14,
      //                                                       height: 14,
      //                                                       decoration:
      //                                                           BoxDecoration(
      //                                                         color: selectAll ==
      //                                                                 1
      //                                                             ? bluePrimary
      //                                                             : null,
      //                                                         borderRadius:
      //                                                             BorderRadius
      //                                                                 .circular(
      //                                                                     3),
      //                                                       ),
      //                                                     ),
      //                                                   ),
      //                                                 ),
      //                                               ),
      //                                               Padding(
      //                                                 padding:
      //                                                     const EdgeInsets
      //                                                             .only(
      //                                                         left: 8),
      //                                                 child: Text(
      //                                                     AppLocalizations
      //                                                             .of(
      //                                                                 context)!
      //                                                         .selectAll,
      //                                                     style: reguler.copyWith(
      //                                                         color: widget
      //                                                                 .darkMode
      //                                                             ? whiteColorDarkMode
      //                                                             : blackSecondary3,
      //                                                         fontSize:
      //                                                             12)),
      //                                               ),
      //                                             ],
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       Padding(
      //                                         padding:
      //                                             const EdgeInsets.only(
      //                                                 top: 12,
      //                                                 bottom: 5,
      //                                                 right: 12),
      //                                         child: GestureDetector(
      //                                           onTap: () async {
      //                                             if (totalUnitSelected !=
      //                                                 0) {
      //                                               showModalBottomSheet(
      //                                                   isScrollControlled:
      //                                                       true,
      //                                                   isDismissible:
      //                                                       false,
      //                                                   shape:
      //                                                       const RoundedRectangleBorder(
      //                                                     borderRadius: BorderRadius.only(
      //                                                         topLeft: Radius
      //                                                             .circular(
      //                                                                 12),
      //                                                         topRight: Radius
      //                                                             .circular(
      //                                                                 12)),
      //                                                   ),
      //                                                   backgroundColor: widget
      //                                                           .darkMode
      //                                                       ? whiteCardColor
      //                                                       : whiteColor,
      //                                                   context: context,
      //                                                   builder:
      //                                                       (BuildContext
      //                                                           context) {
      //                                                     return StatefulBuilder(builder:
      //                                                         (BuildContext
      //                                                                 context,
      //                                                             StateSetter
      //                                                                 setStateModal) {
      //                                                       return SingleChildScrollView(
      //                                                         child:
      //                                                             Container(
      //                                                           padding: MediaQuery.of(
      //                                                                   context)
      //                                                               .viewInsets,
      //                                                           alignment:
      //                                                               Alignment
      //                                                                   .center,
      //                                                           child:
      //                                                               Padding(
      //                                                             padding: const EdgeInsets
      //                                                                     .all(
      //                                                                 20.0),
      //                                                             child:
      //                                                                 Column(
      //                                                               children: [
      //                                                                 Column(
      //                                                                   children: [
      //                                                                     Image.asset(
      //                                                                       'assets/deletecart.png',
      //                                                                       width: 120,
      //                                                                     ),
      //                                                                     Padding(
      //                                                                       padding: const EdgeInsets.symmetric(vertical: 15),
      //                                                                       child: SizedBox(
      //                                                                         width: 200,
      //                                                                         child: Text(
      //                                                                           totalUnitSelected == cartData.data.results.length ? AppLocalizations.of(context)!.deleteAllCart : AppLocalizations.of(context)!.deleteCart,
      //                                                                           style: bold.copyWith(
      //                                                                             fontSize: 12,
      //                                                                             color: blackPrimary,
      //                                                                           ),
      //                                                                           textAlign: TextAlign.center,
      //                                                                         ),
      //                                                                       ),
      //                                                                     ),
      //                                                                     Padding(
      //                                                                       padding: const EdgeInsets.only(bottom: 10),
      //                                                                       child: GestureDetector(
      //                                                                         onTap: () async {
      //                                                                           Navigator.pop(context);
      //                                                                           // Dialogs().loadingDialog(context);
      //                                                                           List<dynamic> idCart = [];
      //                                                                           cartData.data.results.forEach((el) async {
      //                                                                             if (el.isSelected) {
      //                                                                               idCart.add(el.id);
      //                                                                             }
      //                                                                             print(idCart);
      //                                                                             // await deleteCart(
      //                                                                             //     idCart);
      //                                                                           });
      //                                                                           await deleteCart(idCart);
      //                                                                           setState(() {
      //                                                                             selectAll = 0;
      //                                                                           });
      //                                                                           // Navigator.pop(context);
      //                                                                           // Navigator.pop(context);
      //                                                                           // Dialogs().loadingDialog(context);
      //                                                                           // await deleteCart([
      //                                                                           //   cartData.data.results[index].id
      //                                                                           // ]);
      //                                                                           // Navigator.pop(context);
      //                                                                         },
      //                                                                         child: Container(
      //                                                                           width: double.infinity,
      //                                                                           decoration: BoxDecoration(
      //                                                                             color: bluePrimary,
      //                                                                             borderRadius: BorderRadius.circular(8),
      //                                                                             border: Border.all(
      //                                                                               width: 1,
      //                                                                               color: bluePrimary,
      //                                                                             ),
      //                                                                           ),
      //                                                                           child: Align(
      //                                                                             alignment: Alignment.center,
      //                                                                             child: Padding(
      //                                                                               padding: const EdgeInsets.symmetric(vertical: 10),
      //                                                                               child: Text(AppLocalizations.of(context)!.deleteCartButton, style: reguler.copyWith(color: whiteColor, fontSize: 12)),
      //                                                                             ),
      //                                                                           ),
      //                                                                         ),
      //                                                                       ),
      //                                                                     ),
      //                                                                     GestureDetector(
      //                                                                       onTap: () {
      //                                                                         Navigator.pop(context);
      //                                                                       },
      //                                                                       child: Container(
      //                                                                         width: double.infinity,
      //                                                                         decoration: BoxDecoration(
      //                                                                           color: whiteColor,
      //                                                                           borderRadius: BorderRadius.circular(8),
      //                                                                           border: Border.all(
      //                                                                             width: 1,
      //                                                                             color: bluePrimary,
      //                                                                           ),
      //                                                                         ),
      //                                                                         child: Align(
      //                                                                           alignment: Alignment.center,
      //                                                                           child: Padding(
      //                                                                             padding: const EdgeInsets.symmetric(vertical: 10),
      //                                                                             child: Text(AppLocalizations.of(context)!.cancelDeleteCart, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
      //                                                                           ),
      //                                                                         ),
      //                                                                       ),
      //                                                                     )
      //                                                                   ],
      //                                                                 ),
      //                                                               ],
      //                                                             ),
      //                                                           ),
      //                                                         ),
      //                                                       );
      //                                                     });
      //                                                   });
      //                                               // Dialogs().loadingDialog(
      //                                               //     context);
      //                                               // List<dynamic> idCart =
      //                                               //     [];
      //                                               // cartData.data.results
      //                                               //     .forEach(
      //                                               //         (el) async {
      //                                               //   if (el.isSelected) {
      //                                               //     idCart.add(el.id);
      //                                               //   }
      //                                               //   print(idCart);
      //                                               //   // await deleteCart(
      //                                               //   //     idCart);
      //                                               // });
      //                                               // await deleteCart(
      //                                               //     idCart);
      //                                               // setState(() {
      //                                               //   selectAll = 0;
      //                                               // });
      //                                               // Navigator.pop(context);
      //                                             }

      //                                             // Dialogs().showLoaderDialog(
      //                                             //     context);
      //                                             // deleteCart(cartData.data.results[index].id);
      //                                           },
      //                                           child: Image.asset(
      //                                             'assets/trash5.png',
      //                                             color: widget.darkMode
      //                                                 ? whiteColorDarkMode
      //                                                 : greyColor,
      //                                             width: 20,
      //                                             height: 20,
      //                                           ),
      //                                         ),
      //                                       )
      //                                     ],
      //                                   ),
      //                                   Padding(
      //                                     padding:
      //                                         const EdgeInsets.symmetric(
      //                                             vertical: 10),
      //                                     child: Divider(
      //                                       height: 2,
      //                                       thickness: 1,
      //                                       indent: 0,
      //                                       endIndent: 0,
      //                                       color: widget.darkMode
      //                                           ? whiteColorDarkMode
      //                                           : greyColorSecondary,
      //                                     ),
      //                                   ),
      //                                   Expanded(
      //                                     child: RefreshIndicator(
      //                                       onRefresh: () async {
      //                                         await _doRefreshIndicator();
      //                                       },
      //                                       child: ListView.builder(
      //                                           physics:
      //                                               AlwaysScrollableScrollPhysics(),
      //                                           itemCount: cartData
      //                                               .data.results.length,
      //                                           itemBuilder:
      //                                               (context, index) {
      //                                             // totalPrice = cartData
      //                                             //         .data.results[index].harga +
      //                                             //     cartData.data.results[index].harga;
      //                                             return Padding(
      //                                               padding:
      //                                                   const EdgeInsets
      //                                                           .symmetric(
      //                                                       horizontal: 12),
      //                                               child: Row(
      //                                                 children: [
      //                                                   Padding(
      //                                                     padding:
      //                                                         const EdgeInsets
      //                                                                 .only(
      //                                                             right: 5),
      //                                                     child: SizedBox(
      //                                                       width: 24,
      //                                                       child:
      //                                                           GestureDetector(
      //                                                         onTap: () {
      //                                                           setState(
      //                                                               () {
      //                                                             if (cartData
      //                                                                 .data
      //                                                                 .results[
      //                                                                     index]
      //                                                                 .isAvailable) {
      //                                                               cartData.data.results[index].isSelected
      //                                                                   ? cartData.data.results[index].isSelected =
      //                                                                       false
      //                                                                   : cartData.data.results[index].isSelected =
      //                                                                       true;
      //                                                               cartData.data.results[index].isSelected
      //                                                                   ? totalUnitSelected++
      //                                                                   : totalUnitSelected--;
      //                                                               cartData.data.results[index].isSelected
      //                                                                   ? totalPrice +=
      //                                                                       cartData.data.results[index].harga
      //                                                                   : totalPrice -= cartData.data.results[index].harga;
      //                                                               idCart.isNotEmpty
      //                                                                   ? idCart =
      //                                                                       []
      //                                                                   : {};
      //                                                               for (var el in cartData
      //                                                                   .data
      //                                                                   .results) {
      //                                                                 if (el
      //                                                                     .isSelected) {
      //                                                                   idCart.add(el.id);
      //                                                                 }
      //                                                               }
      //                                                               print(
      //                                                                   'total = $totalUnitSelected');
      //                                                             } else {
      //                                                               print(DateTime.now()
      //                                                                   .difference(DateTime.parse(cartData.data.results[index].expired))
      //                                                                   .inDays);
      //                                                               showModalBottomSheet(
      //                                                                   isScrollControlled:
      //                                                                       true,
      //                                                                   isDismissible:
      //                                                                       false,
      //                                                                   backgroundColor: widget.darkMode
      //                                                                       ? whiteCardColor
      //                                                                       : whiteColor,
      //                                                                   shape:
      //                                                                       const RoundedRectangleBorder(
      //                                                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      //                                                                   ),
      //                                                                   context:
      //                                                                       context,
      //                                                                   builder:
      //                                                                       (BuildContext context) {
      //                                                                     return StatefulBuilder(builder: (BuildContext context, StateSetter setStateModal) {
      //                                                                       return SingleChildScrollView(
      //                                                                         child: Container(
      //                                                                           padding: MediaQuery.of(context).viewInsets,
      //                                                                           alignment: Alignment.center,
      //                                                                           child: Padding(
      //                                                                             padding: const EdgeInsets.all(20.0),
      //                                                                             child: Column(
      //                                                                               children: [
      //                                                                                 Row(
      //                                                                                   mainAxisAlignment: MainAxisAlignment.end,
      //                                                                                   children: [
      //                                                                                     GestureDetector(
      //                                                                                       onTap: () {
      //                                                                                         Navigator.pop(context);
      //                                                                                       },
      //                                                                                       child: Icon(
      //                                                                                         Icons.close,
      //                                                                                         size: 30,
      //                                                                                         color: widget.darkMode ? whiteColorDarkMode : null,
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   ],
      //                                                                                 ),
      //                                                                                 Column(
      //                                                                                   children: [
      //                                                                                     Image.asset(
      //                                                                                       'assets/handling/terminated.png',
      //                                                                                       width: 200,
      //                                                                                       height: 200,
      //                                                                                     ),
      //                                                                                     Padding(
      //                                                                                       padding: const EdgeInsets.symmetric(vertical: 5),
      //                                                                                       child: SizedBox(
      //                                                                                         width: double.infinity,
      //                                                                                         child: Text(
      //                                                                                           DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180Title : AppLocalizations.of(context)!.unitTerminated7Title,
      //                                                                                           style: bold.copyWith(
      //                                                                                             fontSize: 14,
      //                                                                                             color: blackPrimary,
      //                                                                                           ),
      //                                                                                           textAlign: TextAlign.center,
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                     Padding(
      //                                                                                       padding: const EdgeInsets.symmetric(vertical: 5),
      //                                                                                       child: SizedBox(
      //                                                                                         width: double.infinity,
      //                                                                                         child: Text(
      //                                                                                           DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180SubTitle : AppLocalizations.of(context)!.unitTerminated7SubTitle,
      //                                                                                           style: reguler.copyWith(
      //                                                                                             fontSize: 14,
      //                                                                                             color: blackPrimary,
      //                                                                                           ),
      //                                                                                           textAlign: TextAlign.center,
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                     InkWell(
      //                                                                                       enableFeedback: url.data.branch.whatsapp == '' ? false : true,
      //                                                                                       onTap: () {
      //                                                                                         if (url.data.branch.whatsapp != '') {
      //                                                                                           launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
      //                                                                                           Navigator.pop(context);
      //                                                                                         }
      //                                                                                         // url.data.branch.whatsapp == '' ? {} : launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
      //                                                                                       },
      //                                                                                       child: Padding(
      //                                                                                         padding: const EdgeInsets.only(top: 10, bottom: 5),
      //                                                                                         child: Container(
      //                                                                                           width: double.infinity,
      //                                                                                           decoration: BoxDecoration(
      //                                                                                             color: whiteColor,
      //                                                                                             // color: all ? blueGradient : whiteColor,
      //                                                                                             borderRadius: BorderRadius.circular(8),
      //                                                                                             border: Border.all(
      //                                                                                               width: 1,
      //                                                                                               color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
      //                                                                                             ),
      //                                                                                           ),
      //                                                                                           child: Row(
      //                                                                                             mainAxisAlignment: MainAxisAlignment.center,
      //                                                                                             children: [
      //                                                                                               Padding(
      //                                                                                                 padding: const EdgeInsets.all(12),
      //                                                                                                 child: Row(
      //                                                                                                   children: [
      //                                                                                                     // Icon(
      //                                                                                                     //   Icons.whatsapp_outlined,
      //                                                                                                     //   color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
      //                                                                                                     //   size: 15,
      //                                                                                                     // ),
      //                                                                                                     Padding(
      //                                                                                                       padding: const EdgeInsets.only(left: 2),
      //                                                                                                       child: Text(AppLocalizations.of(context)!.installationBranch, style: bold.copyWith(fontSize: 12, color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
      //                                                                                                     ),
      //                                                                                                   ],
      //                                                                                                 ),
      //                                                                                               ),
      //                                                                                             ],
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                     InkWell(
      //                                                                                       onTap: () {
      //                                                                                         // 'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'
      //                                                                                         launchUrl(Uri.parse('https://wa.me/${url.data.head.whatsapp}'), mode: LaunchMode.externalApplication);
      //                                                                                         Navigator.pop(context);
      //                                                                                       },
      //                                                                                       child: Padding(
      //                                                                                         padding: const EdgeInsets.only(top: 10),
      //                                                                                         child: Container(
      //                                                                                           width: double.infinity,
      //                                                                                           decoration: BoxDecoration(
      //                                                                                             color: greenPrimary,
      //                                                                                             // color: all ? blueGradient : whiteColor,
      //                                                                                             borderRadius: BorderRadius.circular(8),
      //                                                                                             border: Border.all(
      //                                                                                               width: 1,
      //                                                                                               color: greenPrimary,
      //                                                                                             ),
      //                                                                                           ),
      //                                                                                           child: Row(
      //                                                                                             mainAxisAlignment: MainAxisAlignment.center,
      //                                                                                             children: [
      //                                                                                               Padding(
      //                                                                                                 padding: const EdgeInsets.all(12),
      //                                                                                                 child: Row(
      //                                                                                                   children: [
      //                                                                                                     // Icon(
      //                                                                                                     //   Icons.whatsapp_outlined,
      //                                                                                                     //   color: whiteColor,
      //                                                                                                     //   size: 15,
      //                                                                                                     // ),
      //                                                                                                     Padding(
      //                                                                                                       padding: const EdgeInsets.only(left: 2),
      //                                                                                                       child: Text(AppLocalizations.of(context)!.cc24H, style: bold.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
      //                                                                                                     ),
      //                                                                                                   ],
      //                                                                                                 ),
      //                                                                                               ),
      //                                                                                             ],
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   ],
      //                                                                                 ),
      //                                                                               ],
      //                                                                             ),
      //                                                                           ),
      //                                                                         ),
      //                                                                       );
      //                                                                     });
      //                                                                   });
      //                                                             }
      //                                                           });
      //                                                         },
      //                                                         child:
      //                                                             Container(
      //                                                           width: 24,
      //                                                           height: 24,
      //                                                           decoration:
      //                                                               BoxDecoration(
      //                                                             borderRadius:
      //                                                                 BorderRadius.circular(
      //                                                                     4),
      //                                                             border:
      //                                                                 Border
      //                                                                     .all(
      //                                                               width:
      //                                                                   1,
      //                                                               color: cartData.data.results[index].isSelected
      //                                                                   ? bluePrimary
      //                                                                   : greyColorSecondary,
      //                                                             ),
      //                                                           ),
      //                                                           child:
      //                                                               Align(
      //                                                             alignment:
      //                                                                 Alignment
      //                                                                     .center,
      //                                                             child:
      //                                                                 Container(
      //                                                               width:
      //                                                                   14,
      //                                                               height:
      //                                                                   14,
      //                                                               decoration:
      //                                                                   BoxDecoration(
      //                                                                 color: cartData.data.results[index].isSelected
      //                                                                     ? bluePrimary
      //                                                                     : null,
      //                                                                 borderRadius:
      //                                                                     BorderRadius.circular(3),
      //                                                               ),
      //                                                             ),
      //                                                           ),
      //                                                         ),
      //                                                       ),
      //                                                     ),
      //                                                   ),
      //                                                   Expanded(
      //                                                       child:
      //                                                           GestureDetector(
      //                                                     onTap: () {
      //                                                       setState(() {
      //                                                         if (cartData
      //                                                             .data
      //                                                             .results[
      //                                                                 index]
      //                                                             .isAvailable) {
      //                                                           cartData
      //                                                                   .data
      //                                                                   .results[
      //                                                                       index]
      //                                                                   .isSelected
      //                                                               ? cartData.data.results[index].isSelected =
      //                                                                   false
      //                                                               : cartData
      //                                                                   .data
      //                                                                   .results[index]
      //                                                                   .isSelected = true;
      //                                                           cartData
      //                                                                   .data
      //                                                                   .results[index]
      //                                                                   .isSelected
      //                                                               ? totalUnitSelected++
      //                                                               : totalUnitSelected--;
      //                                                           cartData
      //                                                                   .data
      //                                                                   .results[
      //                                                                       index]
      //                                                                   .isSelected
      //                                                               ? totalPrice += cartData
      //                                                                   .data
      //                                                                   .results[
      //                                                                       index]
      //                                                                   .harga
      //                                                               : totalPrice -= cartData
      //                                                                   .data
      //                                                                   .results[index]
      //                                                                   .harga;
      //                                                           idCart.isNotEmpty
      //                                                               ? idCart =
      //                                                                   []
      //                                                               : {};
      //                                                           for (var el
      //                                                               in cartData
      //                                                                   .data
      //                                                                   .results) {
      //                                                             if (el
      //                                                                 .isSelected) {
      //                                                               idCart.add(
      //                                                                   el.id);
      //                                                             }
      //                                                           }
      //                                                           print(
      //                                                               'total = $totalUnitSelected');
      //                                                         } else {
      //                                                           print(DateTime
      //                                                                   .now()
      //                                                               .difference(DateTime.parse(cartData
      //                                                                   .data
      //                                                                   .results[index]
      //                                                                   .expired))
      //                                                               .inDays);
      //                                                           showModalBottomSheet(
      //                                                               isScrollControlled:
      //                                                                   true,
      //                                                               isDismissible:
      //                                                                   false,
      //                                                               backgroundColor: widget.darkMode
      //                                                                   ? whiteCardColor
      //                                                                   : whiteColor,
      //                                                               shape:
      //                                                                   const RoundedRectangleBorder(
      //                                                                 borderRadius: BorderRadius.only(
      //                                                                     topLeft: Radius.circular(12),
      //                                                                     topRight: Radius.circular(12)),
      //                                                               ),
      //                                                               context:
      //                                                                   context,
      //                                                               builder:
      //                                                                   (BuildContext
      //                                                                       context) {
      //                                                                 return StatefulBuilder(builder:
      //                                                                     (BuildContext context, StateSetter setStateModal) {
      //                                                                   return SingleChildScrollView(
      //                                                                     child: Container(
      //                                                                       padding: MediaQuery.of(context).viewInsets,
      //                                                                       alignment: Alignment.center,
      //                                                                       child: Padding(
      //                                                                         padding: const EdgeInsets.all(20.0),
      //                                                                         child: Column(
      //                                                                           children: [
      //                                                                             Row(
      //                                                                               mainAxisAlignment: MainAxisAlignment.end,
      //                                                                               children: [
      //                                                                                 GestureDetector(
      //                                                                                   onTap: () {
      //                                                                                     Navigator.pop(context);
      //                                                                                   },
      //                                                                                   child: Icon(
      //                                                                                     Icons.close,
      //                                                                                     size: 30,
      //                                                                                     color: widget.darkMode ? whiteColorDarkMode : null,
      //                                                                                   ),
      //                                                                                 ),
      //                                                                               ],
      //                                                                             ),
      //                                                                             Column(
      //                                                                               children: [
      //                                                                                 Image.asset(
      //                                                                                   'assets/handling/terminated.png',
      //                                                                                   width: 200,
      //                                                                                   height: 200,
      //                                                                                 ),
      //                                                                                 Padding(
      //                                                                                   padding: const EdgeInsets.symmetric(vertical: 5),
      //                                                                                   child: SizedBox(
      //                                                                                     width: double.infinity,
      //                                                                                     child: Text(
      //                                                                                       DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180Title : AppLocalizations.of(context)!.unitTerminated7Title,
      //                                                                                       style: bold.copyWith(
      //                                                                                         fontSize: 14,
      //                                                                                         color: blackPrimary,
      //                                                                                       ),
      //                                                                                       textAlign: TextAlign.center,
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                 ),
      //                                                                                 Padding(
      //                                                                                   padding: const EdgeInsets.symmetric(vertical: 5),
      //                                                                                   child: SizedBox(
      //                                                                                     width: double.infinity,
      //                                                                                     child: Text(
      //                                                                                       DateTime.now().difference(DateTime.parse(cartData.data.results[index].expired)).inDays >= 180 ? AppLocalizations.of(context)!.unitTerminated180SubTitle : AppLocalizations.of(context)!.unitTerminated7SubTitle,
      //                                                                                       style: reguler.copyWith(
      //                                                                                         fontSize: 14,
      //                                                                                         color: blackPrimary,
      //                                                                                       ),
      //                                                                                       textAlign: TextAlign.center,
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                 ),
      //                                                                                 InkWell(
      //                                                                                   enableFeedback: url.data.branch.whatsapp == '' ? false : true,
      //                                                                                   onTap: () {
      //                                                                                     if (url.data.branch.whatsapp != '') {
      //                                                                                       launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
      //                                                                                       Navigator.pop(context);
      //                                                                                     }
      //                                                                                     // url.data.branch.whatsapp == '' ? {} : launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
      //                                                                                   },
      //                                                                                   child: Padding(
      //                                                                                     padding: const EdgeInsets.only(top: 10, bottom: 5),
      //                                                                                     child: Container(
      //                                                                                       width: double.infinity,
      //                                                                                       decoration: BoxDecoration(
      //                                                                                         color: whiteColor,
      //                                                                                         // color: all ? blueGradient : whiteColor,
      //                                                                                         borderRadius: BorderRadius.circular(8),
      //                                                                                         border: Border.all(
      //                                                                                           width: 1,
      //                                                                                           color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                       child: Row(
      //                                                                                         mainAxisAlignment: MainAxisAlignment.center,
      //                                                                                         children: [
      //                                                                                           Padding(
      //                                                                                             padding: const EdgeInsets.all(12),
      //                                                                                             child: Row(
      //                                                                                               children: [
      //                                                                                                 // Icon(
      //                                                                                                 //   Icons.whatsapp_outlined,
      //                                                                                                 //   color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
      //                                                                                                 //   size: 15,
      //                                                                                                 // ),
      //                                                                                                 Padding(
      //                                                                                                   padding: const EdgeInsets.only(left: 2),
      //                                                                                                   child: Text(AppLocalizations.of(context)!.installationBranch, style: bold.copyWith(fontSize: 12, color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
      //                                                                                                 ),
      //                                                                                               ],
      //                                                                                             ),
      //                                                                                           ),
      //                                                                                         ],
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                 ),
      //                                                                                 InkWell(
      //                                                                                   onTap: () {
      //                                                                                     // 'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'
      //                                                                                     launchUrl(Uri.parse('https://wa.me/${url.data.head.whatsapp}'), mode: LaunchMode.externalApplication);
      //                                                                                     Navigator.pop(context);
      //                                                                                   },
      //                                                                                   child: Padding(
      //                                                                                     padding: const EdgeInsets.only(top: 10),
      //                                                                                     child: Container(
      //                                                                                       width: double.infinity,
      //                                                                                       decoration: BoxDecoration(
      //                                                                                         color: greenPrimary,
      //                                                                                         // color: all ? blueGradient : whiteColor,
      //                                                                                         borderRadius: BorderRadius.circular(8),
      //                                                                                         border: Border.all(
      //                                                                                           width: 1,
      //                                                                                           color: greenPrimary,
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                       child: Row(
      //                                                                                         mainAxisAlignment: MainAxisAlignment.center,
      //                                                                                         children: [
      //                                                                                           Padding(
      //                                                                                             padding: const EdgeInsets.all(12),
      //                                                                                             child: Row(
      //                                                                                               children: [
      //                                                                                                 // Icon(
      //                                                                                                 //   Icons.whatsapp_outlined,
      //                                                                                                 //   color: whiteColor,
      //                                                                                                 //   size: 15,
      //                                                                                                 // ),
      //                                                                                                 Padding(
      //                                                                                                   padding: const EdgeInsets.only(left: 2),
      //                                                                                                   child: Text(AppLocalizations.of(context)!.cc24H, style: bold.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
      //                                                                                                 ),
      //                                                                                               ],
      //                                                                                             ),
      //                                                                                           ),
      //                                                                                         ],
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                 ),
      //                                                                               ],
      //                                                                             ),
      //                                                                           ],
      //                                                                         ),
      //                                                                       ),
      //                                                                     ),
      //                                                                   );
      //                                                                 });
      //                                                               });
      //                                                         }
      //                                                       });
      //                                                     },
      //                                                     child: Container(
      //                                                       decoration:
      //                                                           BoxDecoration(
      //                                                         color: widget
      //                                                                 .darkMode
      //                                                             ? whiteCardColor
      //                                                             : whiteColor,
      //                                                         boxShadow: [
      //                                                           BoxShadow(
      //                                                               color: widget.darkMode
      //                                                                   ? whiteCardColor
      //                                                                   : greyColorSecondary.withOpacity(
      //                                                                       0.3),
      //                                                               spreadRadius:
      //                                                                   0,
      //                                                               blurRadius:
      //                                                                   5,
      //                                                               offset: Offset(
      //                                                                   0,
      //                                                                   3))
      //                                                         ],
      //                                                         borderRadius:
      //                                                             BorderRadius
      //                                                                 .circular(
      //                                                                     12),
      //                                                         border: Border
      //                                                             .all(
      //                                                           width: 1,
      //                                                           color: cartData
      //                                                                   .data
      //                                                                   .results[index]
      //                                                                   .isAvailable
      //                                                               ? cartData.data.results[index].isSelected
      //                                                                   ? bluePrimary
      //                                                                   : whiteCardColor
      //                                                               : redPrimary,
      //                                                         ),
      //                                                       ),
      //                                                       margin:
      //                                                           const EdgeInsets
      //                                                                   .only(
      //                                                               bottom:
      //                                                                   12,
      //                                                               top:
      //                                                                   12),
      //                                                       // color: whiteColor,
      //                                                       // elevation: 3,
      //                                                       child: Padding(
      //                                                         padding:
      //                                                             const EdgeInsets
      //                                                                     .all(
      //                                                                 12.0),
      //                                                         child: Column(
      //                                                           children: [
      //                                                             Padding(
      //                                                               padding:
      //                                                                   const EdgeInsets.only(bottom: 10),
      //                                                               child:
      //                                                                   Row(
      //                                                                 mainAxisAlignment:
      //                                                                     MainAxisAlignment.spaceBetween,
      //                                                                 crossAxisAlignment:
      //                                                                     CrossAxisAlignment.start,
      //                                                                 children: [
      //                                                                   Expanded(
      //                                                                     child: Row(
      //                                                                       children: [
      //                                                                         Padding(
      //                                                                           padding: const EdgeInsets.only(right: 8),
      //                                                                           child: appDir is Directory
      //                                                                               ? Image.file(
      //                                                                                   File('${appDir.path}/localAssetType/${cartData.data.results[index].vehicleType.toLowerCase()}_parking.png'),
      //                                                                                   width: 42,
      //                                                                                   height: 42,
      //                                                                                 )
      //                                                                               : const SkeletonAvatar(
      //                                                                                   style: SkeletonAvatarStyle(shape: BoxShape.rectangle, width: 42, height: 42),
      //                                                                                 ),
      //                                                                         ),
      //                                                                         Column(
      //                                                                           crossAxisAlignment: CrossAxisAlignment.start,
      //                                                                           children: [
      //                                                                             Container(
      //                                                                               // height: 25,
      //                                                                               decoration: BoxDecoration(
      //                                                                                 color: widget.darkMode ? whiteColor : blackSecondary1,
      //                                                                                 borderRadius: BorderRadius.circular(4),
      //                                                                                 border: Border.all(
      //                                                                                   width: 1,
      //                                                                                   color: widget.darkMode ? whiteColor : blackSecondary1,
      //                                                                                 ),
      //                                                                               ),
      //                                                                               child: Padding(
      //                                                                                 padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      //                                                                                 child: Column(
      //                                                                                   mainAxisAlignment: MainAxisAlignment.center,
      //                                                                                   children: [
      //                                                                                     Text(cartData.data.results[index].information[0], style: reguler.copyWith(fontSize: 10, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
      //                                                                                   ],
      //                                                                                 ),
      //                                                                               ),
      //                                                                             ),
      //                                                                             const SizedBox(
      //                                                                               height: 4,
      //                                                                             ),
      //                                                                             Row(
      //                                                                               children: [
      //                                                                                 //phone number dumy
      //                                                                                 Text(
      //                                                                                   cartData.data.results[index].sim,
      //                                                                                   style: reguler.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : blackSecondary1),
      //                                                                                 ),
      //                                                                               ],
      //                                                                             ),
      //                                                                           ],
      //                                                                         ),
      //                                                                       ],
      //                                                                     ),
      //                                                                   ),
      //                                                                   GestureDetector(
      //                                                                     onTap: () async {
      //                                                                       showModalBottomSheet(
      //                                                                           isScrollControlled: true,
      //                                                                           isDismissible: false,
      //                                                                           backgroundColor: widget.darkMode ? whiteCardColor : whiteColor,
      //                                                                           shape: const RoundedRectangleBorder(
      //                                                                             borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      //                                                                           ),
      //                                                                           context: context,
      //                                                                           builder: (BuildContext context) {
      //                                                                             return StatefulBuilder(builder: (BuildContext context, StateSetter setStateModal) {
      //                                                                               return SingleChildScrollView(
      //                                                                                 child: Container(
      //                                                                                   padding: MediaQuery.of(context).viewInsets,
      //                                                                                   alignment: Alignment.center,
      //                                                                                   child: Padding(
      //                                                                                     padding: const EdgeInsets.all(20.0),
      //                                                                                     child: Column(
      //                                                                                       children: [
      //                                                                                         Column(
      //                                                                                           children: [
      //                                                                                             Image.asset(
      //                                                                                               'assets/deletecart.png',
      //                                                                                               width: 120,
      //                                                                                             ),
      //                                                                                             Padding(
      //                                                                                               padding: const EdgeInsets.symmetric(vertical: 15),
      //                                                                                               child: SizedBox(
      //                                                                                                 width: 200,
      //                                                                                                 child: Text(
      //                                                                                                   AppLocalizations.of(context)!.deleteCart,
      //                                                                                                   style: bold.copyWith(
      //                                                                                                     fontSize: 12,
      //                                                                                                     color: blackPrimary,
      //                                                                                                   ),
      //                                                                                                   textAlign: TextAlign.center,
      //                                                                                                 ),
      //                                                                                               ),
      //                                                                                             ),
      //                                                                                             Padding(
      //                                                                                               padding: const EdgeInsets.only(bottom: 10),
      //                                                                                               child: GestureDetector(
      //                                                                                                 onTap: () async {
      //                                                                                                   Navigator.pop(context);
      //                                                                                                   // Dialogs().loadingDialog(context);
      //                                                                                                   await deleteCart([
      //                                                                                                     cartData.data.results[index].id
      //                                                                                                   ]);
      //                                                                                                   // Navigator.pop(context);
      //                                                                                                 },
      //                                                                                                 child: Container(
      //                                                                                                   width: double.infinity,
      //                                                                                                   decoration: BoxDecoration(
      //                                                                                                     color: bluePrimary,
      //                                                                                                     borderRadius: BorderRadius.circular(8),
      //                                                                                                     border: Border.all(
      //                                                                                                       width: 1,
      //                                                                                                       color: bluePrimary,
      //                                                                                                     ),
      //                                                                                                   ),
      //                                                                                                   child: Align(
      //                                                                                                     alignment: Alignment.center,
      //                                                                                                     child: Padding(
      //                                                                                                       padding: const EdgeInsets.symmetric(vertical: 10),
      //                                                                                                       child: Text(AppLocalizations.of(context)!.deleteCartButton, style: reguler.copyWith(color: whiteColor, fontSize: 12)),
      //                                                                                                     ),
      //                                                                                                   ),
      //                                                                                                 ),
      //                                                                                               ),
      //                                                                                             ),
      //                                                                                             GestureDetector(
      //                                                                                               onTap: () {
      //                                                                                                 Navigator.pop(context);
      //                                                                                               },
      //                                                                                               child: Container(
      //                                                                                                 width: double.infinity,
      //                                                                                                 decoration: BoxDecoration(
      //                                                                                                   color: whiteColor,
      //                                                                                                   borderRadius: BorderRadius.circular(8),
      //                                                                                                   border: Border.all(
      //                                                                                                     width: 1,
      //                                                                                                     color: bluePrimary,
      //                                                                                                   ),
      //                                                                                                 ),
      //                                                                                                 child: Align(
      //                                                                                                   alignment: Alignment.center,
      //                                                                                                   child: Padding(
      //                                                                                                     padding: const EdgeInsets.symmetric(vertical: 10),
      //                                                                                                     child: Text(AppLocalizations.of(context)!.cancelDeleteCart, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
      //                                                                                                   ),
      //                                                                                                 ),
      //                                                                                               ),
      //                                                                                             )
      //                                                                                           ],
      //                                                                                         ),
      //                                                                                       ],
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                 ),
      //                                                                               );
      //                                                                             });
      //                                                                           });
      //                                                                       // Dialogs().loadingDialog(context);
      //                                                                       // await deleteCart([
      //                                                                       //   cartData.data.results[index].id
      //                                                                       // ]);
      //                                                                       // Navigator.pop(context);
      //                                                                     },
      //                                                                     child: Image.asset(
      //                                                                       'assets/trash5.png',
      //                                                                       color: widget.darkMode ? whiteColorDarkMode : greyColor,
      //                                                                       width: 20,
      //                                                                       height: 20,
      //                                                                     ),
      //                                                                   )

      //                                                                   // const SizedBox(
      //                                                                   //   width: 10,
      //                                                                   // ),
      //                                                                 ],
      //                                                               ),
      //                                                             ),
      //                                                             Row(
      //                                                               mainAxisAlignment:
      //                                                                   MainAxisAlignment.spaceBetween,
      //                                                               children: [
      //                                                                 Column(
      //                                                                   crossAxisAlignment:
      //                                                                       CrossAxisAlignment.start,
      //                                                                   children: [
      //                                                                     //phone number dumy
      //                                                                     Padding(
      //                                                                       padding: const EdgeInsets.only(bottom: 5),
      //                                                                       child: Text(
      //                                                                         AppLocalizations.of(context)!.choosePackage,
      //                                                                         style: reguler.copyWith(fontSize: 10, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
      //                                                                       ),
      //                                                                     ),
      //                                                                     GestureDetector(
      //                                                                       onTap: () async {
      //                                                                         if (cartData.data.results[index].isAvailable) {
      //                                                                           Dialogs().loadingDialog(context);
      //                                                                           await getPackage(cartData.data.results[index].sim);
      //                                                                           Dialogs().hideLoaderDialog(context);
      //                                                                           showModalBottomSheet(
      //                                                                             context: context,
      //                                                                             backgroundColor: widget.darkMode ? whiteCardColor : whiteColor,
      //                                                                             shape: const RoundedRectangleBorder(
      //                                                                               borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      //                                                                             ),
      //                                                                             builder: (BuildContext context) {
      //                                                                               return StatefulBuilder(
      //                                                                                 builder: (BuildContext context, StateSetter setState) {
      //                                                                                   return SizedBox(
      //                                                                                     width: double.infinity,
      //                                                                                     height: 350,
      //                                                                                     child: Column(
      //                                                                                       children: [
      //                                                                                         // const SizedBox(
      //                                                                                         //   height: 20,
      //                                                                                         // ),
      //                                                                                         Padding(
      //                                                                                           padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      //                                                                                           child: Row(
      //                                                                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                                                                             children: [
      //                                                                                               Column(
      //                                                                                                 crossAxisAlignment: CrossAxisAlignment.start,
      //                                                                                                 children: [
      //                                                                                                   TextScroll(
      //                                                                                                     cartData.data.results[index].information[0],
      //                                                                                                     style: bold.copyWith(
      //                                                                                                       fontSize: 10,
      //                                                                                                       color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
      //                                                                                                     ),
      //                                                                                                   ),
      //                                                                                                   Text(
      //                                                                                                     cartData.data.results[index].sim,
      //                                                                                                     style: bold.copyWith(
      //                                                                                                       fontSize: 14,
      //                                                                                                       color: widget.darkMode ? whiteColorDarkMode : blackSecondary1,
      //                                                                                                     ),
      //                                                                                                   ),
      //                                                                                                 ],
      //                                                                                               ),
      //                                                                                               Column(
      //                                                                                                 crossAxisAlignment: CrossAxisAlignment.start,
      //                                                                                                 children: [
      //                                                                                                   Text(
      //                                                                                                     AppLocalizations.of(context)!.packageEnds,
      //                                                                                                     style: reguler.copyWith(
      //                                                                                                       fontSize: 10,
      //                                                                                                       color: widget.darkMode ? whiteColorDarkMode : blackSecondary3,
      //                                                                                                     ),
      //                                                                                                   ),
      //                                                                                                   TextScroll(
      //                                                                                                     DateFormat('dd MMMM yyyy').format(DateTime.parse(cartData.data.results[index].nextExpired).toLocal()),
      //                                                                                                     style: bold.copyWith(
      //                                                                                                       fontSize: 14,
      //                                                                                                       color: widget.darkMode ? whiteColorDarkMode : blackSecondary1,
      //                                                                                                     ),
      //                                                                                                   ),
      //                                                                                                 ],
      //                                                                                               ),
      //                                                                                             ],
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                         Padding(
      //                                                                                           padding: const EdgeInsets.symmetric(horizontal: 20),
      //                                                                                           child: Divider(
      //                                                                                             height: 2,
      //                                                                                             thickness: 1,
      //                                                                                             indent: 0,
      //                                                                                             endIndent: 0,
      //                                                                                             color: widget.darkMode ? whiteColorDarkMode : greyColor,
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                         Expanded(
      //                                                                                           child: SingleChildScrollView(
      //                                                                                             child: Container(
      //                                                                                               padding: const EdgeInsets.all(
      //                                                                                                 20,
      //                                                                                               ),
      //                                                                                               child: Column(
      //                                                                                                 children: [
      //                                                                                                   ListView.builder(
      //                                                                                                     shrinkWrap: true,
      //                                                                                                     scrollDirection: Axis.vertical,
      //                                                                                                     physics: const BouncingScrollPhysics(),
      //                                                                                                     itemCount: getPackageModel.data.results.length,
      //                                                                                                     itemBuilder: (context, indexPackage) {
      //                                                                                                       return Padding(
      //                                                                                                         padding: const EdgeInsets.only(bottom: 10),
      //                                                                                                         child: GestureDetector(
      //                                                                                                           onTap: () async {
      //                                                                                                             setState(
      //                                                                                                               () {
      //                                                                                                                 select = indexPackage + 1;
      //                                                                                                               },
      //                                                                                                             );
      //                                                                                                             print('Test ${getPackageModel.data.results[indexPackage].id} // ${cartData.data.results[index].id}');
      //                                                                                                             Dialogs().loadingDialog(context);
      //                                                                                                             await updatePack(cartData.data.results[index].id, getPackageModel.data.results[indexPackage].id);
      //                                                                                                             Navigator.pop(context);
      //                                                                                                             Navigator.pop(context);
      //                                                                                                           },
      //                                                                                                           child: Container(
      //                                                                                                             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      //                                                                                                             width: width,
      //                                                                                                             // height: 60,
      //                                                                                                             decoration: BoxDecoration(
      //                                                                                                               // color: whiteCardColor,
      //                                                                                                               borderRadius: BorderRadius.circular(8),
      //                                                                                                               border: Border.all(
      //                                                                                                                 width: 1,
      //                                                                                                                 color: select == indexPackage + 1
      //                                                                                                                     ? bluePrimary
      //                                                                                                                     : widget.darkMode
      //                                                                                                                         ? whiteColorDarkMode
      //                                                                                                                         : greyColor,
      //                                                                                                               ),
      //                                                                                                             ),
      //                                                                                                             child: Row(
      //                                                                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                                                                                               children: [
      //                                                                                                                 Text(
      //                                                                                                                   getPackageModel.data.results[indexPackage].packName,
      //                                                                                                                   style: reguler.copyWith(
      //                                                                                                                     fontSize: 14,
      //                                                                                                                     color: select == indexPackage + 1
      //                                                                                                                         ? bluePrimary
      //                                                                                                                         : widget.darkMode
      //                                                                                                                             ? whiteColorDarkMode
      //                                                                                                                             : blackSecondary3,
      //                                                                                                                   ),
      //                                                                                                                 ),
      //                                                                                                                 getPackageModel.data.results[indexPackage].isPromo == 1
      //                                                                                                                     ? Container(
      //                                                                                                                         // width: 40,
      //                                                                                                                         // height: 10,
      //                                                                                                                         decoration: BoxDecoration(
      //                                                                                                                           color: blueSecondary,
      //                                                                                                                           borderRadius: BorderRadius.circular(15),
      //                                                                                                                           boxShadow: [
      //                                                                                                                             BoxShadow(
      //                                                                                                                               color: widget.darkMode ? whiteCardColor : Colors.grey,
      //                                                                                                                               offset: Offset(0.0, 3),
      //                                                                                                                               blurRadius: 5.0,
      //                                                                                                                             ),
      //                                                                                                                           ],
      //                                                                                                                         ),
      //                                                                                                                         // width: 40,
      //                                                                                                                         // height: 10,
      //                                                                                                                         child: Padding(
      //                                                                                                                           padding: const EdgeInsets.only(left: 12, right: 12),
      //                                                                                                                           child: Text(
      //                                                                                                                             'Promo',
      //                                                                                                                             style: bold.copyWith(color: widget.darkMode ? whiteColorDarkMode : whiteColor, fontSize: 12),
      //                                                                                                                           ),
      //                                                                                                                         ),
      //                                                                                                                       )
      //                                                                                                                     : Container(),
      //                                                                                                                 Text(
      //                                                                                                                   NumberFormat.currency(
      //                                                                                                                     locale: 'id',
      //                                                                                                                     decimalDigits: 0,
      //                                                                                                                     symbol: 'Rp. ',
      //                                                                                                                   ).format(
      //                                                                                                                     int.parse(getPackageModel.data.results[indexPackage].price.toString()),
      //                                                                                                                   ),
      //                                                                                                                   style: reguler.copyWith(
      //                                                                                                                     fontSize: 14,
      //                                                                                                                     color: select == indexPackage + 1
      //                                                                                                                         ? bluePrimary
      //                                                                                                                         : widget.darkMode
      //                                                                                                                             ? whiteColorDarkMode
      //                                                                                                                             : blackSecondary3,
      //                                                                                                                   ),
      //                                                                                                                 )
      //                                                                                                               ],
      //                                                                                                             ),
      //                                                                                                           ),
      //                                                                                                         ),
      //                                                                                                       );
      //                                                                                                     },
      //                                                                                                   ),
      //                                                                                                 ],
      //                                                                                               ),
      //                                                                                             ),
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                       ],
      //                                                                                     ),
      //                                                                                   );
      //                                                                                 },
      //                                                                               );
      //                                                                             },
      //                                                                           );
      //                                                                         }
      //                                                                       },
      //                                                                       child: Container(
      //                                                                         height: 25,
      //                                                                         // width: 100,
      //                                                                         padding: EdgeInsets.symmetric(horizontal: 10),
      //                                                                         decoration: BoxDecoration(
      //                                                                           color: widget.darkMode ? whiteCardColor : whiteColor,
      //                                                                           borderRadius: BorderRadius.circular(4),
      //                                                                           border: Border.all(
      //                                                                             width: 1,
      //                                                                             color: cartData.data.results[index].isAvailable ? bluePrimary : greyColor,
      //                                                                           ),
      //                                                                         ),
      //                                                                         child: Row(
      //                                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                                                           children: [
      //                                                                             Text(cartData.data.results[index].packName,
      //                                                                                 style: reguler.copyWith(
      //                                                                                   fontSize: 10,
      //                                                                                   color: cartData.data.results[index].isAvailable ? bluePrimary : greyColor,
      //                                                                                 )),
      //                                                                             Icon(
      //                                                                               Icons.arrow_forward_ios_outlined,
      //                                                                               color: cartData.data.results[index].isAvailable ? bluePrimary : greyColor,
      //                                                                               size: 11,
      //                                                                             )
      //                                                                           ],
      //                                                                         ),
      //                                                                       ),
      //                                                                     ),
      //                                                                   ],
      //                                                                 ),
      //                                                                 Column(
      //                                                                   crossAxisAlignment:
      //                                                                       CrossAxisAlignment.end,
      //                                                                   children: [
      //                                                                     //phone number dumy
      //                                                                     Padding(
      //                                                                       padding: const EdgeInsets.only(bottom: 5),
      //                                                                       child: Text(
      //                                                                         AppLocalizations.of(context)!.price,
      //                                                                         style: reguler.copyWith(fontSize: 10, color: widget.darkMode ? whiteColorDarkMode : blackSecondary3),
      //                                                                       ),
      //                                                                     ),
      //                                                                     Text(
      //                                                                       NumberFormat.currency(
      //                                                                         locale: 'id',
      //                                                                         decimalDigits: 0,
      //                                                                         symbol: 'Rp. ',
      //                                                                       ).format(
      //                                                                         int.parse(cartData.data.results[index].harga.toString()),
      //                                                                       ),
      //                                                                       style: reguler.copyWith(fontSize: 16, color: cartData.data.results[index].isAvailable ? greenPrimary : greyColor),
      //                                                                     ),
      //                                                                   ],
      //                                                                 ),
      //                                                               ],
      //                                                             ),
      //                                                             // SizedBox(
      //                                                             //   width: MediaQuery.of(context)
      //                                                             //           .size
      //                                                             //           .width /
      //                                                             //       3,
      //                                                             //   child:
      //                                                             //       Padding(
      //                                                             //     padding:
      //                                                             //         const EdgeInsets.only(top: 20),
      //                                                             //     child:
      //                                                             //         Column(
      //                                                             //       crossAxisAlignment:
      //                                                             //           CrossAxisAlignment.start,
      //                                                             //       children: [
      //                                                             //         const SizedBox(
      //                                                             //           height: 10,
      //                                                             //         ),
      //                                                             //       ],
      //                                                             //     ),
      //                                                             //   ),
      //                                                             // ),
      //                                                             Padding(
      //                                                               padding:
      //                                                                   const EdgeInsets.symmetric(vertical: 10),
      //                                                               child:
      //                                                                   Divider(
      //                                                                 height:
      //                                                                     2,
      //                                                                 thickness:
      //                                                                     1,
      //                                                                 indent:
      //                                                                     0,
      //                                                                 endIndent:
      //                                                                     0,
      //                                                                 color:
      //                                                                     greyColorSecondary,
      //                                                               ),
      //                                                             ),
      //                                                             Row(
      //                                                               mainAxisAlignment:
      //                                                                   MainAxisAlignment.spaceBetween,
      //                                                               children: [
      //                                                                 Column(
      //                                                                   crossAxisAlignment:
      //                                                                       CrossAxisAlignment.start,
      //                                                                   children: [
      //                                                                     Text(
      //                                                                       AppLocalizations.of(context)!.expire,
      //                                                                       style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 10),
      //                                                                     ),
      //                                                                     Text(
      //                                                                       DateFormat('dd MMMM yyyy').format(DateTime.parse(cartData.data.results[index].expired).toLocal()),
      //                                                                       style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary2, fontSize: 12),
      //                                                                     ),
      //                                                                   ],
      //                                                                 ),
      //                                                                 Column(
      //                                                                   crossAxisAlignment:
      //                                                                       CrossAxisAlignment.end,
      //                                                                   children: [
      //                                                                     Text(
      //                                                                       AppLocalizations.of(context)!.nextExpire,
      //                                                                       style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary3, fontSize: 10),
      //                                                                     ),
      //                                                                     Text(
      //                                                                       DateFormat('dd MMMM yyyy').format(DateTime.parse(cartData.data.results[index].nextExpired).toLocal()),
      //                                                                       style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : blackSecondary2, fontSize: 12),
      //                                                                     ),
      //                                                                   ],
      //                                                                 ),
      //                                                                 // GestureDetector(
      //                                                                 //   onTap:
      //                                                                 //       () {
      //                                                                 //     deleteCart(cartData.data.results[index].id);
      //                                                                 //   },
      //                                                                 //   child:
      //                                                                 //       Image.asset(
      //                                                                 //     'assets/trash5.png',
      //                                                                 //     width:
      //                                                                 //         15,
      //                                                                 //   ),
      //                                                                 // )
      //                                                               ],
      //                                                             ),
      //                                                           ],
      //                                                         ),
      //                                                       ),
      //                                                     ),
      //                                                   ))
      //                                                 ],
      //                                               ),
      //                                             );
      //                                           }),
      //                                     ),
      //                                   ),
      //                                   SizedBox(
      //                                     width: double.infinity,
      //                                     // height: 130,
      //                                     child: Padding(
      //                                       padding:
      //                                           const EdgeInsets.all(10.0),
      //                                       child: Align(
      //                                         alignment:
      //                                             Alignment.bottomCenter,
      //                                         child: Container(
      //                                           height: 100.0,
      //                                           padding: const EdgeInsets
      //                                               .symmetric(
      //                                             vertical: 5.0,
      //                                             horizontal: 5.0,
      //                                           ),
      //                                           decoration: BoxDecoration(
      //                                             borderRadius:
      //                                                 BorderRadius.circular(
      //                                                     12.0),
      //                                             color: widget.darkMode
      //                                                 ? whiteCardColor
      //                                                 : whiteColor,
      //                                             boxShadow: [
      //                                               BoxShadow(
      //                                                 color: widget.darkMode
      //                                                     ? whiteCardColor
      //                                                     : greyColor,
      //                                                 offset:
      //                                                     Offset(0.0, 1.0),
      //                                                 blurRadius: 9.0,
      //                                               ),
      //                                             ],
      //                                           ),
      //                                           child: Column(
      //                                             mainAxisAlignment:
      //                                                 MainAxisAlignment
      //                                                     .spaceBetween,
      //                                             children: [
      //                                               Row(
      //                                                 mainAxisAlignment:
      //                                                     MainAxisAlignment
      //                                                         .spaceBetween,
      //                                                 children: [
      //                                                   // const SizedBox(
      //                                                   //   width: 10,
      //                                                   // ),
      //                                                   Padding(
      //                                                     padding:
      //                                                         const EdgeInsets
      //                                                             .all(8.0),
      //                                                     child: Column(
      //                                                       crossAxisAlignment:
      //                                                           CrossAxisAlignment
      //                                                               .start,
      //                                                       children: [
      //                                                         Text(
      //                                                             AppLocalizations.of(
      //                                                                     context)!
      //                                                                 .totalUnit,
      //                                                             style: reguler.copyWith(
      //                                                                 fontSize:
      //                                                                     11,
      //                                                                 color:
      //                                                                     blackPrimary)),
      //                                                         Text(
      //                                                             totalUnitSelected
      //                                                                 .toString(),
      //                                                             style: bold.copyWith(
      //                                                                 fontSize:
      //                                                                     11,
      //                                                                 color:
      //                                                                     blackPrimary)),
      //                                                       ],
      //                                                     ),
      //                                                   ),
      //                                                   Padding(
      //                                                     padding:
      //                                                         const EdgeInsets
      //                                                             .all(8.0),
      //                                                     child: Column(
      //                                                       crossAxisAlignment:
      //                                                           CrossAxisAlignment
      //                                                               .end,
      //                                                       children: [
      //                                                         Text(
      //                                                             AppLocalizations.of(
      //                                                                     context)!
      //                                                                 .totalPrice,
      //                                                             style: reguler.copyWith(
      //                                                                 fontSize:
      //                                                                     11,
      //                                                                 color:
      //                                                                     blackPrimary)),
      //                                                         Text(
      //                                                           NumberFormat
      //                                                               .currency(
      //                                                             locale:
      //                                                                 'id',
      //                                                             decimalDigits:
      //                                                                 0,
      //                                                             symbol:
      //                                                                 'Rp. ',
      //                                                           ).format(
      //                                                             totalPrice,
      //                                                           ),
      //                                                           style: bold.copyWith(
      //                                                               fontSize:
      //                                                                   11,
      //                                                               color:
      //                                                                   blackPrimary),
      //                                                         )
      //                                                         // Text(
      //                                                         //   'Rp. 1.500.000',
      //                                                         //   style: bold.copyWith(
      //                                                         //       fontSize: 14,
      //                                                         //       color: blackPrimary),
      //                                                         // ),
      //                                                       ],
      //                                                     ),
      //                                                   ),
      //                                                   // const SizedBox(
      //                                                   //   width: 40,
      //                                                   // ),

      //                                                   // const SizedBox(
      //                                                   //   width: 40,
      //                                                   // ),
      //                                                   // Padding(
      //                                                   //   padding:
      //                                                   //       const EdgeInsets
      //                                                   //           .all(8.0),
      //                                                   //   child: Column(
      //                                                   //     crossAxisAlignment:
      //                                                   //         CrossAxisAlignment
      //                                                   //             .start,
      //                                                   //     children: [
      //                                                   //       Row(
      //                                                   //         mainAxisAlignment:
      //                                                   //             MainAxisAlignment
      //                                                   //                 .start,
      //                                                   //         children: [
      //                                                   //           const SizedBox(
      //                                                   //             height:
      //                                                   //                 25,
      //                                                   //           ),
      //                                                   //           GestureDetector(
      //                                                   //             onTap:
      //                                                   //                 () {
      //                                                   //               setState(
      //                                                   //                   () {
      //                                                   //                 selected == 1
      //                                                   //                     ? selected = 0
      //                                                   //                     : selected = 1;
      //                                                   //                 print(selected);
      //                                                   //               });
      //                                                   //             },
      //                                                   //             child:
      //                                                   //                 Container(
      //                                                   //               width:
      //                                                   //                   20,
      //                                                   //               height:
      //                                                   //                   20,
      //                                                   //               decoration:
      //                                                   //                   BoxDecoration(
      //                                                   //                 borderRadius:
      //                                                   //                     BorderRadius.circular(4),
      //                                                   //                 border:
      //                                                   //                     Border.all(
      //                                                   //                   width: 1,
      //                                                   //                   color: selected == 1 ? blueGradient : blueGradient,
      //                                                   //                 ),
      //                                                   //               ),
      //                                                   //               child:
      //                                                   //                   Align(
      //                                                   //                 alignment:
      //                                                   //                     Alignment.center,
      //                                                   //                 child:
      //                                                   //                     Container(
      //                                                   //                   width: 12,
      //                                                   //                   height: 12,
      //                                                   //                   decoration: BoxDecoration(
      //                                                   //                     color: selected == 1 ? bluePrimary : whiteColor,
      //                                                   //                     borderRadius: BorderRadius.circular(3),
      //                                                   //                   ),
      //                                                   //                 ),
      //                                                   //               ),
      //                                                   //             ),
      //                                                   //           ),
      //                                                   //           const SizedBox(
      //                                                   //             width:
      //                                                   //                 5,
      //                                                   //           ),
      //                                                   //           GestureDetector(
      //                                                   //             onTap:
      //                                                   //                 () async {
      //                                                   //               await Navigator.pushNamed(
      //                                                   //                   context,
      //                                                   //                   '/taxinvoice');
      //                                                   //               _doRefresh();
      //                                                   //             },
      //                                                   //             child:
      //                                                   //                 Column(
      //                                                   //               children: [
      //                                                   //                 Text(
      //                                                   //                   AppLocalizations.of(context)!.taxInvoice,
      //                                                   //                   style: reguler.copyWith(fontSize: 11, color: blackPrimary),
      //                                                   //                 ),
      //                                                   //                 Text(
      //                                                   //                   '(Edit)',
      //                                                   //                   style: bold.copyWith(fontSize: 11, color: blackPrimary),
      //                                                   //                 ),
      //                                                   //               ],
      //                                                   //             ),
      //                                                   //           )
      //                                                   //         ],
      //                                                   //       ),
      //                                                   //       // Text('Tax invoice',
      //                                                   //       //     style: reguler.copyWith(
      //                                                   //       //         fontSize: 14, color: blackPrimary)),
      //                                                   //     ],
      //                                                   //   ),
      //                                                   // ),
      //                                                 ],
      //                                               ),
      //                                               // const SizedBox(
      //                                               //   height: 5,
      //                                               // ),
      //                                               // Divider(
      //                                               //   height: 2,
      //                                               //   thickness: 1,
      //                                               //   indent: 0,
      //                                               //   endIndent: 0,
      //                                               //   color: greyColor,
      //                                               // ),
      //                                               // const SizedBox(
      //                                               //   height: 5,
      //                                               // ),
      //                                               SizedBox(
      //                                                 width:
      //                                                     double.infinity,
      //                                                 height: 40.0,
      //                                                 child: Row(
      //                                                   mainAxisAlignment:
      //                                                       MainAxisAlignment
      //                                                           .spaceEvenly,
      //                                                   children: [
      //                                                     GestureDetector(
      //                                                       onTap:
      //                                                           () async {
      //                                                         // await Navigator
      //                                                         //     .pushNamed(
      //                                                         //         context,
      //                                                         //         '/vehiclelist');
      //                                                         await Navigator
      //                                                             .pushNamed(
      //                                                                 context,
      //                                                                 '/choosevehicletopup');
      //                                                         _doRefresh();
      //                                                       },
      //                                                       child:
      //                                                           Container(
      //                                                         height: 40,
      //                                                         width: MediaQuery.of(
      //                                                                     context)
      //                                                                 .size
      //                                                                 .width /
      //                                                             3,
      //                                                         decoration:
      //                                                             BoxDecoration(
      //                                                           borderRadius:
      //                                                               BorderRadius.circular(
      //                                                                   15),
      //                                                           border:
      //                                                               Border
      //                                                                   .all(
      //                                                             width: 1,
      //                                                             color:
      //                                                                 blueGradient,
      //                                                           ),
      //                                                         ),
      //                                                         child: Column(
      //                                                           mainAxisAlignment:
      //                                                               MainAxisAlignment
      //                                                                   .center,
      //                                                           children: [
      //                                                             Text(
      //                                                               '+ ${AppLocalizations.of(context)!.addUnit}',
      //                                                               style: reguler.copyWith(
      //                                                                   fontSize:
      //                                                                       11,
      //                                                                   color:
      //                                                                       blueGradient),
      //                                                             ),
      //                                                           ],
      //                                                         ),
      //                                                       ),
      //                                                     ),
      //                                                     const SizedBox(
      //                                                       width: 10,
      //                                                     ),
      //                                                     Expanded(
      //                                                       child:
      //                                                           GestureDetector(
      //                                                         onTap:
      //                                                             () async {
      //                                                           if (totalUnitSelected !=
      //                                                               0) {
      //                                                             showModalBottomSheet(
      //                                                                 isScrollControlled:
      //                                                                     true,
      //                                                                 isDismissible:
      //                                                                     false,
      //                                                                 backgroundColor: widget.darkMode
      //                                                                     ? whiteCardColor
      //                                                                     : whiteColor,
      //                                                                 shape:
      //                                                                     const RoundedRectangleBorder(
      //                                                                   borderRadius:
      //                                                                       BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      //                                                                 ),
      //                                                                 context:
      //                                                                     context,
      //                                                                 builder:
      //                                                                     (BuildContext context) {
      //                                                                   return StatefulBuilder(builder:
      //                                                                       (BuildContext context, StateSetter setStateModal) {
      //                                                                     return SingleChildScrollView(
      //                                                                       child: Container(
      //                                                                         padding: MediaQuery.of(context).viewInsets,
      //                                                                         alignment: Alignment.center,
      //                                                                         child: Padding(
      //                                                                           padding: const EdgeInsets.all(20.0),
      //                                                                           child: Column(
      //                                                                             children: [
      //                                                                               Row(
      //                                                                                 mainAxisAlignment: MainAxisAlignment.end,
      //                                                                                 children: [
      //                                                                                   GestureDetector(
      //                                                                                     onTap: () {
      //                                                                                       Navigator.pop(context);
      //                                                                                     },
      //                                                                                     child: Icon(
      //                                                                                       Icons.close,
      //                                                                                       size: 30,
      //                                                                                       color: widget.darkMode ? whiteColorDarkMode : null,
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                 ],
      //                                                                               ),
      //                                                                               Column(
      //                                                                                 children: [
      //                                                                                   Image.asset(
      //                                                                                     'assets/cart.png',
      //                                                                                     width: 120,
      //                                                                                   ),
      //                                                                                   Padding(
      //                                                                                     padding: const EdgeInsets.symmetric(vertical: 15),
      //                                                                                     child: SizedBox(
      //                                                                                       width: double.infinity,
      //                                                                                       child: Text(
      //                                                                                         AppLocalizations.of(context)!.askTaxInvoice,
      //                                                                                         style: bold.copyWith(
      //                                                                                           fontSize: 12,
      //                                                                                           color: blackPrimary,
      //                                                                                         ),
      //                                                                                         textAlign: TextAlign.center,
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                   GestureDetector(
      //                                                                                     onTap: () async {
      //                                                                                       // Navigator.pop(context);
      //                                                                                       Navigator.pop(context);
      //                                                                                       List<dynamic> cart = [];
      //                                                                                       for (var el in cartData.data.results) {
      //                                                                                         if (el.isSelected) {
      //                                                                                           cart.add(el);
      //                                                                                         }
      //                                                                                       }
      //                                                                                       print(cart);
      //                                                                                       if (cartData.data.results.length >= 100) {
      //                                                                                         showInfoAlert(context, 'The transaction cannot be continued because the number of transactions exceeds 100 vehicles', '');
      //                                                                                       } else {
      //                                                                                         await Navigator.push(
      //                                                                                           context,
      //                                                                                           MaterialPageRoute(
      //                                                                                             builder: (context) => TaxInvoice(
      //                                                                                               idCart: idCart,
      //                                                                                               totalUnit: totalUnitSelected,
      //                                                                                               totalPrice: totalPrice,
      //                                                                                               cart: cart,
      //                                                                                               darkMode: widget.darkMode,
      //                                                                                             ),
      //                                                                                           ),
      //                                                                                         );
      //                                                                                         _doRefresh();
      //                                                                                       }
      //                                                                                     },
      //                                                                                     child: Container(
      //                                                                                       width: double.infinity,
      //                                                                                       decoration: BoxDecoration(
      //                                                                                         color: whiteColor,
      //                                                                                         borderRadius: BorderRadius.circular(8),
      //                                                                                         border: Border.all(
      //                                                                                           width: 1,
      //                                                                                           color: bluePrimary,
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                       child: Align(
      //                                                                                         alignment: Alignment.center,
      //                                                                                         child: Padding(
      //                                                                                           padding: const EdgeInsets.symmetric(vertical: 10),
      //                                                                                           child: Text(AppLocalizations.of(context)!.useTaxInvoice, style: reguler.copyWith(color: bluePrimary, fontSize: 12)),
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   ),
      //                                                                                   Padding(
      //                                                                                     padding: const EdgeInsets.only(top: 10),
      //                                                                                     child: GestureDetector(
      //                                                                                       onTap: () async {
      //                                                                                         // Navigator.pop(context);
      //                                                                                         Navigator.pop(context);
      //                                                                                         if (cartData.data.results.length >= 100) {
      //                                                                                           showInfoAlert(context, 'The transaction cannot be continued because the number of transactions exceeds 100 vehicles', '');
      //                                                                                         } else {
      //                                                                                           List<dynamic> cart = [];
      //                                                                                           for (var el in cartData.data.results) {
      //                                                                                             if (el.isSelected) {
      //                                                                                               cart.add(el);
      //                                                                                             }
      //                                                                                           }
      //                                                                                           print(cart);
      //                                                                                           await Navigator.push(
      //                                                                                             context,
      //                                                                                             MaterialPageRoute(
      //                                                                                               builder: (context) => PaymentMethod(
      //                                                                                                 totalUnit: totalUnitSelected,
      //                                                                                                 totalPrice: totalPrice,
      //                                                                                                 npwp: 0,
      //                                                                                                 idCart: idCart,
      //                                                                                                 npwpNo: '',
      //                                                                                                 npwpName: '',
      //                                                                                                 npwpAddress: '',
      //                                                                                                 npwpEmail: '',
      //                                                                                                 npwpWa: '',
      //                                                                                                 cart: cart,
      //                                                                                                 darkMode: widget.darkMode,
      //                                                                                               ),
      //                                                                                             ),
      //                                                                                           );
      //                                                                                           _doRefresh();
      //                                                                                         }
      //                                                                                       },
      //                                                                                       child: Container(
      //                                                                                         width: double.infinity,
      //                                                                                         decoration: BoxDecoration(
      //                                                                                           color: bluePrimary,
      //                                                                                           borderRadius: BorderRadius.circular(8),
      //                                                                                           border: Border.all(
      //                                                                                             width: 1,
      //                                                                                             color: bluePrimary,
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                         child: Align(
      //                                                                                           alignment: Alignment.center,
      //                                                                                           child: Padding(
      //                                                                                             padding: const EdgeInsets.symmetric(vertical: 10),
      //                                                                                             child: Text(AppLocalizations.of(context)!.withoutTaxInvoice, style: reguler.copyWith(color: widget.darkMode ? whiteColorDarkMode : whiteColor, fontSize: 12)),
      //                                                                                           ),
      //                                                                                         ),
      //                                                                                       ),
      //                                                                                     ),
      //                                                                                   )
      //                                                                                 ],
      //                                                                               ),
      //                                                                             ],
      //                                                                           ),
      //                                                                         ),
      //                                                                       ),
      //                                                                     );
      //                                                                   });
      //                                                                 });
      //                                                           } else {}
      //                                                         },
      //                                                         child:
      //                                                             Container(
      //                                                           height: 40,
      //                                                           width: MediaQuery.of(context)
      //                                                                   .size
      //                                                                   .width /
      //                                                               2,
      //                                                           decoration:
      //                                                               BoxDecoration(
      //                                                             color: totalUnitSelected ==
      //                                                                     0
      //                                                                 ? widget.darkMode
      //                                                                     ? whiteColor
      //                                                                     : greyColor
      //                                                                 : bluePrimary,
      //                                                             borderRadius:
      //                                                                 BorderRadius.circular(
      //                                                                     15),
      //                                                             border:
      //                                                                 Border
      //                                                                     .all(
      //                                                               width:
      //                                                                   1,
      //                                                               color: totalUnitSelected ==
      //                                                                       0
      //                                                                   ? greyColor
      //                                                                   : blueGradient,
      //                                                             ),
      //                                                           ),
      //                                                           child:
      //                                                               Column(
      //                                                             mainAxisAlignment:
      //                                                                 MainAxisAlignment
      //                                                                     .center,
      //                                                             children: [
      //                                                               Text(
      //                                                                 AppLocalizations.of(context)!
      //                                                                     .choosePaymentMethod,
      //                                                                 textAlign:
      //                                                                     TextAlign.center,
      //                                                                 style: reguler.copyWith(
      //                                                                     fontSize: 11,
      //                                                                     color: widget.darkMode ? whiteColorDarkMode : whiteColor),
      //                                                               ),
      //                                                             ],
      //                                                           ),
      //                                                         ),
      //                                                       ),
      //                                                     ),
      //                                                   ],
      //                                                 ),
      //                                               ),
      //                                             ],
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ),
      //                                   )
      //                                 ],
      //                               );
      //                             }
      //                           }
      //                         }

      //                         return ListView.builder(
      //                             scrollDirection: Axis.vertical,
      //                             itemCount: 5,
      //                             itemBuilder: (context, index) {
      //                               return Card(
      //                                   margin: const EdgeInsets.all(15),
      //                                   elevation: 3,
      //                                   shape: RoundedRectangleBorder(
      //                                     borderRadius:
      //                                         BorderRadius.circular(4),
      //                                   ),
      //                                   child: SizedBox(
      //                                     height: 121,
      //                                     child: SkeletonTheme(
      //                                         themeMode: widget.darkMode
      //                                             ? ThemeMode.dark
      //                                             : ThemeMode.light,
      //                                         child: const SkeletonAvatar(
      //                                           style: SkeletonAvatarStyle(
      //                                               shape:
      //                                                   BoxShape.rectangle,
      //                                               width: 140,
      //                                               height: 30),
      //                                         )),
      //                                   ));
      //                             });
      //                       }))
      //             ],
      //           )
      //         ],
      //       ),
      // SizedBox(
      //   height: MediaQuery.of(context).size.height,
      //   child: Column(
      //     children: [
      //       const SizedBox(
      //         height: 40,
      //       ),
      //       Center(
      //           child: Image.asset(
      //         'assets/addtocart.png',
      //         width: MediaQuery.of(context).size.width / 1.5,
      //       )),
      //       const SizedBox(
      //         height: 40,
      //       ),
      //       Text(
      //         AppLocalizations.of(context)!.emptyTopUpCart,
      //         style: bold.copyWith(
      //           fontSize: 12,
      //           color: blackPrimary,
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 10,
      //       ),
      //       Text(
      //         AppLocalizations.of(context)!.addYourTopUpCart,
      //         style: reguler.copyWith(
      //           fontSize: 10,
      //           color: blackPrimary,
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 30,
      //       ),
      //       SizedBox(
      //         width: MediaQuery.of(context).size.width / 1.2,
      //         child: ElevatedButton(
      //           onPressed: () {
      //             Navigator.pushNamed(context, '/vehiclelist');
      //           },
      //           style: ElevatedButton.styleFrom(
      //               primary: whiteColor,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(10.0),
      //                 side: BorderSide(color: blueGradient, width: 1),
      //               ),
      //               textStyle: const TextStyle(
      //                 color: Colors.white,
      //               )),
      //           child: Text(
      //             AppLocalizations.of(context)!.addUnit,
      //             style: reguler.copyWith(
      //               fontSize: 12,
      //               color: blueGradient,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Container pricePackage(
    int index,
    int topupPack,
    String topupDay,
    String packageName,
    String price,
    StateSetter setState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 19),
      width: width,
      height: 63,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: greyColor, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = index;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      width: 1,
                      color: selected == index ? bluePrimary : blackPrimary,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: selected == index ? bluePrimary : null,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                packageName,
                style: bold.copyWith(
                  fontSize: 12,
                  color: selected == index ? bluePrimary : blackPrimary,
                ),
              ),
            ],
          ),
          Text(
            NumberFormat.currency(
              locale: 'id',
              decimalDigits: 0,
              symbol: 'Rp. ',
            ).format(
              int.parse(price),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Text(
          //   'Rp.$price',
          //   style: bold.copyWith(
          //     fontSize: 12,
          //     color: selected == index ? bluePrimary : blackPrimary,
          //   ),
          // ),
        ],
      ),
    );
  }
}

Future<List<Vehicle>> fetchData() async {
  final url = await rootBundle.loadString('json/vehiclelist.json');
  final jsonData = json.decode(url) as List<dynamic>;
  final list = jsonData.map((e) => Vehicle.fromJson(e)).toList();
  return list;
}
