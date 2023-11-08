// ignore_for_file: unused_field, unused_local_variable, avoid_print, prefer_final_fields

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/vehicle.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/AddToCart.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => CartState();
}

class CartState extends State<Cart> with TickerProviderStateMixin {
  int current = 0;
  bool _isData = true;
  TextEditingController suggestion = TextEditingController();
  List<Vehicle> _searchPost = [];
  List<String> sort = [];
  bool _isError = false;
  String _errCode = '';
  late Future<dynamic> _getVehicleList;
  late ErrorTrapModel _errorMessage;
  late List<ResultVehicleList> vehicleList;
  // List<Widget> pages = [
  //   VehicleCard(VehicleModel(apiURL: '')),
  //   VehicleCard(VehicleModel(apiURL: 'status=bergerak')),
  //   VehicleCard(VehicleModel(apiURL: 'status=parkir')),
  //   VehicleCard(VehicleModel(apiURL: 'status=berhenti')),
  // ];
  int selected = 0;
  int selectedCart = 0;
  bool cartTapped = false;
  bool isCheck = false;
  int page = 1;
  int perPage = 25;

  @override
  void initState() {
    super.initState();
    print(_searchPost);
    _getVehicleList = getVehicleList();
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
      });
    }
    return result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        toolbarHeight: 110,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                blueGradientSecondary1,
                blueGradientSecondary2,
              ],
            ),
          ),
        ),
        leadingWidth: MediaQuery.of(context).size.width / 4,
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: IconButton(
                iconSize: 32,
                // padding: const EdgeInsets.only(top: 20),
                icon: const Icon(Icons.arrow_back_outlined),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selected == 1 ? selected = 0 : selected = 1;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          width: 1,
                          color: selected == 1 ? whiteColor : whiteColor,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: selected == 1 ? whiteColor : bluePrimary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.selectAll,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            // InkWell(
            //   onTap: () {
            //     setState(() {
            //       selected == 1 ? selected = 0 : selected = 1;
            //     });
            //   },
            //   child:
            // ),
          ],
        ),
        centerTitle: true,
        title: Text(
          GeneralService().setTitleCase(AppLocalizations.of(context)!.cart),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isData == true
          ? Column(
              children: [
                Container(
                    width: double.infinity,
                    height: 55,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor,
                    ),
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: sort.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                current = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                right: 24,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 16,
                              ),
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: current == index
                                      ? bluePrimary
                                      : greyColor,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Align(
                                child: Text(
                                  sort[index],
                                  style: reguler.copyWith(
                                    fontSize: 12,
                                    color: current == index
                                        ? bluePrimary
                                        : blackSecondary3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })),
                Expanded(
                  child: GestureDetector(
                    // onTap: () =>
                    //     Navigator.pushNamed(context, '/vehicledetail'),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const VehicleDetail(
                      //       imei: '866551037844326',
                      //     ),
                      //   ),
                      // );
                    },
                    child: FutureBuilder(
                        future: fetchData(),
                        builder: (context, data) {
                          if (data.hasError) {
                            return Center(
                              child: Text('${data.error}'),
                            );
                          } else if (data.hasData) {
                            sort = [
                              AppLocalizations.of(context)!.all,
                              AppLocalizations.of(context)!.day7,
                              AppLocalizations.of(context)!.day30,
                              AppLocalizations.of(context)!.day90,
                            ];
                            return Padding(
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
                                            return ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                itemCount: 10,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 20,
                                                    ),
                                                    color: whiteCardColor,
                                                    elevation: 3,
                                                    child: const SkeletonAvatar(
                                                      style:
                                                          SkeletonAvatarStyle(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              width: 311,
                                                              height: 141),
                                                    ),
                                                  );
                                                });
                                          } else {
                                            vehicleList =
                                                snapshot.data.data.result;
                                            return ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: vehicleList.length,
                                              itemBuilder: (context, index) {
                                                DateTime? pulsaPackage =
                                                    DateTime.parse(
                                                        vehicleList[index]
                                                            .expiredDate);
                                                DateTime? lastUpdate =
                                                    DateTime.parse(
                                                        vehicleList[index]
                                                            .lastData);
                                                String dateFormatPulsaPackage =
                                                    DateFormat('dd MMMM y')
                                                        .format(pulsaPackage
                                                            .toLocal());
                                                String dateFormatLastUpdate =
                                                    DateFormat(
                                                            'y-MM-dd HH:m:ss')
                                                        .format(lastUpdate
                                                            .toLocal());
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.2,
                                                      child: Card(
                                                        margin: const EdgeInsets
                                                            .only(
                                                          bottom: 20,
                                                        ),
                                                        color: whiteCardColor,
                                                        elevation: 3,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child: Column(
                                                            children: [
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
                                                                        AppLocalizations.of(context)!
                                                                            .expire,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            color:
                                                                                greyColor),
                                                                      ),
                                                                      Text(
                                                                        dateFormatPulsaPackage,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .nextExpire,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            color:
                                                                                greyColor),
                                                                      ),
                                                                      Text(
                                                                        dateFormatPulsaPackage,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Image.asset(
                                                                    'assets/trash5.png',
                                                                    width: 15,
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Divider(
                                                                height: 2,
                                                                thickness: 1,
                                                                indent: 0,
                                                                endIndent: 0,
                                                                color:
                                                                    greyColor,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Checkbox(
                                                                    value:
                                                                        isCheck,
                                                                    onChanged:
                                                                        (value) {
                                                                      !isCheck
                                                                          ? setState(
                                                                              () {
                                                                              isCheck = true;
                                                                            })
                                                                          : setState(
                                                                              () {
                                                                              isCheck = false;
                                                                            });
                                                                    },
                                                                  ),
                                                                  Image.asset(
                                                                    vehicleList[index].status ==
                                                                            'Stop'
                                                                        ? 'assets/mobil_berhenti.png'
                                                                        : vehicleList[index].status ==
                                                                                'Parking'
                                                                            ? 'assets/mobil_parkir.png'
                                                                            : vehicleList[index].status == 'Online'
                                                                                ? 'assets/mobil_bergerak.png'
                                                                                : 'assets/mobil_nodata.png',
                                                                    // 'assets/${items[index].vehicles.toString()}_${items[index].status.toString().toLowerCase()}.png',
                                                                    width: 30,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 110,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                //phone number dumy
                                                                                Row(
                                                                                  children: [
                                                                                    SizedBox(width: 90, child: Text('${vehicleList[index].gpsName} - ${vehicleList[index].deviceName}', style: reguler.copyWith(fontSize: 12, color: greyColor))),
                                                                                    // AutoSizeText(
                                                                                    //   vehicleList[index].gpsName,
                                                                                    //   style: reguler.copyWith(fontSize: 12, color: greyColor),
                                                                                    //   minFontSize: 12,
                                                                                    //   maxLines: 1,
                                                                                    //   overflow: TextOverflow.ellipsis,
                                                                                    // ),
                                                                                    // Text(
                                                                                    //   ' - ',
                                                                                    //   style: reguler.copyWith(
                                                                                    //     fontSize: 12,
                                                                                    //     color: greyColor,
                                                                                    //   ),
                                                                                    // ),
                                                                                    // SizedBox(
                                                                                    //   width: MediaQuery.of(context).size.width / 8,
                                                                                    //   child: AutoSizeText(
                                                                                    //     vehicleList[index].deviceName,
                                                                                    //     style: reguler.copyWith(
                                                                                    //       fontSize: 12,
                                                                                    //       color: greyColor,
                                                                                    //     ),
                                                                                    //     minFontSize: 12,
                                                                                    //     maxLines: 1,
                                                                                    //     overflow: TextOverflow.ellipsis,
                                                                                    //   ),
                                                                                    // ),
                                                                                  ],
                                                                                ),
                                                                                // Text(
                                                                                //   '-',
                                                                                //   style: reguler.copyWith(fontSize: 12, color: greyColor),
                                                                                //   textAlign: TextAlign.center,
                                                                                // ),
                                                                                // SizedBox(
                                                                                //   width: MediaQuery.of(context).size.width / 8,
                                                                                //   child: AutoSizeText(
                                                                                //     vehicleList[index].deviceName,
                                                                                //     style: reguler.copyWith(
                                                                                //       fontSize: 12,
                                                                                //       color: greyColor,
                                                                                //     ),
                                                                                //     minFontSize: 10,
                                                                                //     maxLines: 1,
                                                                                //     overflow: TextOverflow.visible,
                                                                                //   ),
                                                                                // ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              width: 100,
                                                                              child: SizedBox(width: 90, child: Text(vehicleList[index].plate, style: bold.copyWith(fontSize: 18, color: blackSecondary1))),
                                                                              // AutoSizeText(
                                                                              //   vehicleList[index].plate,
                                                                              //   style: bold.copyWith(
                                                                              //     fontSize: 18,
                                                                              //     color: blackSecondary1,
                                                                              //   ),
                                                                              //   minFontSize: 15,
                                                                              //   maxLines: 1,
                                                                              //   overflow: TextOverflow.visible,
                                                                              // ),
                                                                            ),
                                                                            // Text(
                                                                            //   vehicleList[index].plate,
                                                                            //   style:
                                                                            //       bold.copyWith(
                                                                            //     fontSize: 18,
                                                                            //     color: blackSecondary1,
                                                                            //   ),
                                                                            // ),
                                                                            const SizedBox(
                                                                              height: 4,
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                //phone number dumy
                                                                                Text(
                                                                                  '081122334455',
                                                                                  style: reguler.copyWith(fontSize: 12, color: greyColor),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  // const SizedBox(
                                                                  //   width: 10,
                                                                  // ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            20),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            //phone number dumy
                                                                            Text(
                                                                              AppLocalizations.of(context)!.choosePackage,
                                                                              style: reguler.copyWith(fontSize: 12, color: greyColor),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                90,
                                                                            height:
                                                                                25.0,
                                                                            child:
                                                                                AddToCart()
                                                                            //     ElevatedButton(
                                                                            //   onPressed:
                                                                            //       () {
                                                                            //     // _doAddCart();
                                                                            //     AddPackage();
                                                                            //   },
                                                                            //   style:
                                                                            //       ElevatedButton.styleFrom(backgroundColor: greenPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                                                            //   child:
                                                                            //       Row(
                                                                            //     mainAxisAlignment: MainAxisAlignment.center,
                                                                            //     children: [
                                                                            //       SizedBox(
                                                                            //         width: 40,
                                                                            //         child: AutoSizeText(
                                                                            //           '360 + 30 Hari',
                                                                            //           style: reguler.copyWith(fontSize: 12, color: whiteColor),
                                                                            //           minFontSize: 6,
                                                                            //           maxLines: 1,
                                                                            //           overflow: TextOverflow.ellipsis,
                                                                            //         ),
                                                                            //       ),
                                                                            //       const Icon(
                                                                            //         Icons.keyboard_arrow_down_outlined,
                                                                            //         size: 12,
                                                                            //       )
                                                                            //     ],
                                                                            //   ),
                                                                            // ),
                                                                            ),
                                                                        // Text(
                                                                        //   'Pilih',
                                                                        //   style: bold.copyWith(
                                                                        //     fontSize: 18,
                                                                        //     color: blackSecondary1,
                                                                        //   ),
                                                                        // ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            //phone number dumy
                                                                            Text(
                                                                              AppLocalizations.of(context)!.price,
                                                                              style: reguler.copyWith(fontSize: 12, color: greyColor),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            //phone number dumy
                                                                            Text(
                                                                              'Rp. 600.000',
                                                                              style: reguler.copyWith(fontSize: 12, color: greenPrimary),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        }
                                        //skeleton
                                        return ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: 10,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                margin: const EdgeInsets.only(
                                                  bottom: 20,
                                                ),
                                                color: whiteCardColor,
                                                elevation: 3,
                                                child: const SkeletonAvatar(
                                                  style: SkeletonAvatarStyle(
                                                      shape: BoxShape.rectangle,
                                                      width: 311,
                                                      height: 141),
                                                ),
                                              );
                                            });
                                      }),
                                  // Align(
                                  //   alignment: Alignment.bottomCenter,
                                  //   child: Container(
                                  //     height: 80.0,
                                  //     padding: const EdgeInsets.symmetric(
                                  //       vertical: 5.0,
                                  //       horizontal: 5.0,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       borderRadius:
                                  //           BorderRadius.circular(5.0),
                                  //       color: Colors.white,
                                  //       boxShadow: const [
                                  //         BoxShadow(
                                  //           color: Colors.grey,
                                  //           offset: Offset(0.0, 1.0),
                                  //           blurRadius: 6.0,
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     child: Column(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         const Text(
                                  //           'showing data of : ...',
                                  //           style: TextStyle(
                                  //             color: Colors.black,
                                  //             fontSize: 14.0,
                                  //           ),
                                  //         ),
                                  //         const SizedBox(
                                  //           height: 5,
                                  //         ),
                                  //         SizedBox(
                                  //           width: MediaQuery.of(context)
                                  //               .size
                                  //               .width,
                                  //           height: 40.0,
                                  //           child: ElevatedButton(
                                  //             onPressed: () {
                                  //               // _doAddCart();
                                  //             },
                                  //             style: ElevatedButton.styleFrom(
                                  //               backgroundColor: greenPrimary,
                                  //             ),
                                  //             child: Text(
                                  //               '+ Keranjang top up',
                                  //               style: TextStyle(
                                  //                   color: whiteColor),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  Visibility(
                                      visible: false,
                                      child: Positioned(
                                        bottom:
                                            MediaQuery.of(context).size.height /
                                                100,
                                        right: 0,
                                        left: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                child: Column(
                                              children: [
                                                OutlinedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          whiteColor,
                                                      fixedSize:
                                                          const Size(170, 24),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      side: BorderSide(
                                                          width: 1,
                                                          color: bluePrimary)),
                                                  onPressed: () {
                                                    // loadMore();
                                                  },
                                                  child: Center(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .arrow_downward_outlined,
                                                        color:
                                                            Color(0xff45a4dd),
                                                        size: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        'Load more',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                              color:
                                                                  bluePrimary,
                                                            ),
                                                      ),
                                                    ],
                                                  )),
                                                )
                                              ],
                                            )),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 110.0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0),
                            blurRadius: 9.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.totalPrice,
                                      style: reguler.copyWith(
                                          fontSize: 12, color: blackPrimary)),
                                  Text(
                                    'Rp. 1.500.000',
                                    style: bold.copyWith(
                                        fontSize: 14, color: blackPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.totalUnit,
                                      style: reguler.copyWith(
                                          fontSize: 12, color: blackPrimary)),
                                  Text('9 Unit',
                                      style: bold.copyWith(
                                          fontSize: 14, color: blackPrimary)),
                                ],
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selected == 1
                                                ? selected = 0
                                                : selected = 1;
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              width: 1,
                                              color: selected == 1
                                                  ? whiteColor
                                                  : whiteColor,
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: selected == 1
                                                    ? whiteColor
                                                    : bluePrimary,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/taxinvoice');
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .taxInvoice,
                                          style: reguler.copyWith(
                                              fontSize: 14,
                                              color: blackPrimary),
                                        ),
                                      )
                                    ],
                                  ),
                                  // Text('Tax invoice',
                                  //     style: reguler.copyWith(
                                  //         fontSize: 14, color: blackPrimary)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 2,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                            color: greyColor,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 40.0,
                            child: Row(
                              children: [
                                Container(
                                  height: 90,
                                  width: MediaQuery.of(context).size.width / 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      width: 1,
                                      color: blueGradient,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ ${AppLocalizations.of(context)!.addUnit}',
                                        style: reguler.copyWith(
                                            fontSize: 12, color: blueGradient),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/paymentmethod');
                                  },
                                  child: Container(
                                    height: 90,
                                    width:
                                        MediaQuery.of(context).size.width / 1.8,
                                    decoration: BoxDecoration(
                                      color: bluePrimary,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        width: 1,
                                        color: blueGradient,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .choosePaymentMethod,
                                          style: reguler.copyWith(
                                              fontSize: 12, color: whiteColor),
                                        ),
                                      ],
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     Padding(
                //       padding: const EdgeInsets.only(left: 20),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             AppLocalizations.of(context)!.totalCart,
                //             style: TextStyle(color: blackPrimary),
                //           ),
                //           Text(
                //             '2 ${AppLocalizations.of(context)!.unitCart}',
                //             style: TextStyle(
                //                 color: blackPrimary,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //         ],
                //       ),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.only(left: 130),
                //       child: Container(
                //         width: MediaQuery.of(context).size.width / 2,
                //         // height: 40,
                //         padding: const EdgeInsets.only(bottom: 10),
                //         // padding: const EdgeInsets.symmetric(
                //         //   // vertical: 12,
                //         //   horizontal: 20,
                //         // ),
                //         decoration: BoxDecoration(color: whiteColor),
                //         child: SizedBox(
                //           width: MediaQuery.of(context).size.width / 2,
                //           height: 40.0,
                //           child: ElevatedButton(
                //             onPressed: () {
                //               // _doAddCart();
                //             },
                //             style: ElevatedButton.styleFrom(
                //                 backgroundColor: greenPrimary,
                //                 shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(10))),
                //             child: Text(
                //               '+ ${AppLocalizations.of(context)!.topupCart}',
                //               style: TextStyle(color: whiteColor),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FutureBuilder(
                future: fetchData(),
                builder: (context, data) {
                  if (data.hasError) {
                    return Center(
                      child: Text('${data.error}'),
                    );
                  } else if (data.hasData) {
                    var items = data.data as List<Vehicle>;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        var item = items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: greyColor,
                              ),
                            ),
                          ),
                          width: double.infinity,
                          height: 65,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/${item.vehicles}_nodata.png',
                                    width: 40,
                                  ),
                                  const SizedBox(
                                    width: 23,
                                  ),
                                  Text(
                                      '${item.plat} - ${item.unit} - ${item.device}'),
                                ],
                              ),
                              Image.asset(
                                'assets/arrow_upward.png',
                                width: 40,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
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
